// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {CorridorReactive} from "../src/CorridorReactive.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";

contract CorridorReactiveTest is Test {
    using PoolIdLibrary for PoolKey;

    CorridorReactive public reactive;
    address public systemContract;
    address public callbackProxy;
    address public corridorHook;
    address public priceOracle;
    address public owner;

    uint256 constant VOLATILITY_THRESHOLD = 500; // 5%

    // Events
    event VolatilityDetected(
        address indexed pool,
        uint256 priceChange,
        uint256 timestamp
    );
    event PoolPauseTriggered(address indexed pool, uint256 priceChange);
    event PoolResumeTriggered(address indexed pool);
    event PriceUpdated(address indexed pool, uint256 newPrice);
    event VolatilityThresholdUpdated(
        uint256 oldThreshold,
        uint256 newThreshold
    );
    event CorridorHookUpdated(address indexed newHook);
    event PriceOracleUpdated(address indexed newOracle);
    event OwnershipTransferred(
        address indexed oldOwner,
        address indexed newOwner
    );
    event FeeUpdateTriggered(address indexed pool, uint256 volatility);

    function setUp() public {
        // Setup addresses
        systemContract = makeAddr("systemContract");
        callbackProxy = makeAddr("callbackProxy");
        corridorHook = makeAddr("corridorHook");
        priceOracle = makeAddr("priceOracle");
        owner = address(this);

        // Mock the system contract subscribe call
        vm.mockCall(
            systemContract,
            abi.encodeWithSignature(
                "subscribe(uint256,address,uint256,uint256,uint256,uint256)"
            ),
            abi.encode()
        );

        // Deploy reactive contract
        reactive = new CorridorReactive(
            systemContract,
            callbackProxy,
            corridorHook,
            priceOracle,
            VOLATILITY_THRESHOLD
        );
    }

    // ============ Constructor Tests ============

    function test_Constructor() public view {
        assertEq(reactive.SYSTEM_CONTRACT(), systemContract);
        assertEq(reactive.CALLBACK_PROXY(), callbackProxy);
        assertEq(reactive.corridorHook(), corridorHook);
        assertEq(reactive.priceOracle(), priceOracle);
        assertEq(reactive.volatilityThreshold(), VOLATILITY_THRESHOLD);
        assertEq(reactive.owner(), owner);
        assertEq(reactive.DESTINATION_CHAIN_ID(), 84532); // Base Sepolia
    }

    function test_Constructor_RevertZeroSystemContract() public {
        vm.expectRevert(CorridorReactive.InvalidAddress.selector);
        new CorridorReactive(
            address(0),
            callbackProxy,
            corridorHook,
            priceOracle,
            VOLATILITY_THRESHOLD
        );
    }

    function test_Constructor_RevertZeroCallbackProxy() public {
        vm.expectRevert(CorridorReactive.InvalidAddress.selector);
        new CorridorReactive(
            systemContract,
            address(0),
            corridorHook,
            priceOracle,
            VOLATILITY_THRESHOLD
        );
    }

    function test_Constructor_RevertZeroHook() public {
        vm.expectRevert(CorridorReactive.InvalidAddress.selector);
        new CorridorReactive(
            systemContract,
            callbackProxy,
            address(0),
            priceOracle,
            VOLATILITY_THRESHOLD
        );
    }

    function test_Constructor_RevertZeroOracle() public {
        vm.expectRevert(CorridorReactive.InvalidAddress.selector);
        new CorridorReactive(
            systemContract,
            callbackProxy,
            corridorHook,
            address(0),
            VOLATILITY_THRESHOLD
        );
    }

    function test_Constructor_RevertInvalidThreshold() public {
        vm.expectRevert(CorridorReactive.InvalidThreshold.selector);
        new CorridorReactive(
            systemContract,
            callbackProxy,
            corridorHook,
            priceOracle,
            0
        );

        vm.expectRevert(CorridorReactive.InvalidThreshold.selector);
        new CorridorReactive(
            systemContract,
            callbackProxy,
            corridorHook,
            priceOracle,
            10001
        );
    }

    // ============ View Function Tests ============

    function test_CalculateVolatility() public {
        PoolId poolId = _createPoolId();

        // Set initial price (owner required)
        vm.prank(owner);
        reactive.manualCheckVolatility(poolId, 1000);

        // Calculate volatility for 10% increase
        uint256 volatility = reactive.calculateVolatility(poolId, 1100);
        assertEq(volatility, 1000); // 10% = 1000 bps

        // Calculate volatility for 5% decrease
        volatility = reactive.calculateVolatility(poolId, 950);
        assertEq(volatility, 500); // 5% = 500 bps
    }

    function test_CalculateVolatility_NoLastPrice() public {
        PoolId poolId = _createPoolId();

        // Should return 0 if no last price
        uint256 volatility = reactive.calculateVolatility(poolId, 1000);
        assertEq(volatility, 0);
    }

    function test_CalculateVolatility_ZeroNewPrice() public {
        PoolId poolId = _createPoolId();

        // Set initial price (owner required)
        vm.prank(owner);
        reactive.manualCheckVolatility(poolId, 1000);

        // Should return 0 for zero new price
        uint256 volatility = reactive.calculateVolatility(poolId, 0);
        assertEq(volatility, 0);
    }

    function test_CheckPauseStatus_WouldPause() public {
        PoolId poolId = _createPoolId();

        // Set initial price (owner required)
        vm.prank(owner);
        reactive.manualCheckVolatility(poolId, 1000);

        // Check if would pause at 7% volatility (above 5% threshold)
        (bool wouldPause, bool wouldResume) = reactive.checkPauseStatus(
            poolId,
            1070
        );

        assertTrue(wouldPause);
        assertFalse(wouldResume);
    }

    function test_CheckPauseStatus_WouldResume() public {
        PoolId poolId = _createPoolId();

        // Set initial price and pause pool (owner required)
        vm.prank(owner);
        reactive.manualCheckVolatility(poolId, 1000);

        // Trigger pause with high volatility
        vm.mockCall(
            callbackProxy,
            abi.encodeWithSignature(
                "sendCallback(uint256,address,bytes)",
                84532,
                corridorHook,
                abi.encodeWithSignature(
                    "pausePool(bytes32,uint256)",
                    PoolId.unwrap(poolId),
                    600
                )
            ),
            abi.encode()
        );

        vm.prank(owner);
        reactive.manualCheckVolatility(poolId, 1060); // 6% volatility

        assertTrue(reactive.poolPaused(poolId));

        // Check if would resume at 2.3% volatility (below 2.5% resume threshold)
        // From 1060 to 1036 = 2.26% volatility
        (bool wouldPause, bool wouldResume) = reactive.checkPauseStatus(
            poolId,
            1036
        );

        assertFalse(wouldPause);
        assertTrue(wouldResume);
    }

    // ============ Manual Trigger Tests ============

    function test_ManualCheckVolatility_FirstPrice() public {
        PoolId poolId = _createPoolId();

        vm.expectEmit(true, true, true, true);
        emit PriceUpdated(_poolIdToAddress(poolId), 1000);

        vm.prank(owner);
        reactive.manualCheckVolatility(poolId, 1000);

        assertEq(reactive.lastPrices(poolId), 1000);
        assertFalse(reactive.poolPaused(poolId));
    }

    function test_ManualCheckVolatility_LowVolatility() public {
        PoolId poolId = _createPoolId();

        // Set initial price
        vm.prank(owner);
        reactive.manualCheckVolatility(poolId, 1000);

        // Mock callback for fee update
        vm.mockCall(
            callbackProxy,
            abi.encodeWithSignature(
                "sendCallback(uint256,address,bytes)",
                84532,
                corridorHook,
                abi.encodeWithSignature(
                    "updatePoolFee(bytes32,uint256)",
                    PoolId.unwrap(poolId),
                    200
                )
            ),
            abi.encode()
        );

        // Update with 2% volatility (below threshold)
        vm.expectEmit(true, true, true, true);
        emit VolatilityDetected(_poolIdToAddress(poolId), 200, block.timestamp);

        vm.prank(owner);
        reactive.manualCheckVolatility(poolId, 1020);

        assertEq(reactive.lastPrices(poolId), 1020);
        assertFalse(reactive.poolPaused(poolId));
    }

    function test_ManualCheckVolatility_HighVolatility_Pause() public {
        PoolId poolId = _createPoolId();

        // Set initial price
        vm.prank(owner);
        reactive.manualCheckVolatility(poolId, 1000);

        // Mock callback for pause
        vm.mockCall(
            callbackProxy,
            abi.encodeWithSignature(
                "sendCallback(uint256,address,bytes)",
                84532,
                corridorHook,
                abi.encodeWithSignature(
                    "pausePool(bytes32,uint256)",
                    PoolId.unwrap(poolId),
                    600
                )
            ),
            abi.encode()
        );

        // Update with 6% volatility (above threshold)
        vm.expectEmit(true, true, true, true);
        emit PoolPauseTriggered(_poolIdToAddress(poolId), 600);

        vm.prank(owner);
        reactive.manualCheckVolatility(poolId, 1060);

        assertTrue(reactive.poolPaused(poolId));
    }

    function test_ManualCheckVolatility_Resume() public {
        PoolId poolId = _createPoolId();

        // Set initial price
        vm.prank(owner);
        reactive.manualCheckVolatility(poolId, 1000);

        // Pause pool (6% volatility)
        vm.mockCall(
            callbackProxy,
            abi.encodeWithSignature("sendCallback(uint256,address,bytes)"),
            abi.encode()
        );

        vm.prank(owner);
        reactive.manualCheckVolatility(poolId, 1060);
        assertTrue(reactive.poolPaused(poolId));

        // Resume: volatility from 1060 to 1035 = 2.35% (< 2.5% resume threshold)
        vm.expectEmit(true, false, false, false);
        emit PoolResumeTriggered(_poolIdToAddress(poolId));

        vm.prank(owner);
        reactive.manualCheckVolatility(poolId, 1035);

        assertFalse(reactive.poolPaused(poolId));
    }

    function test_ManualCheckVolatility_RevertZeroPrice() public {
        PoolId poolId = _createPoolId();

        vm.expectRevert(CorridorReactive.PriceIsZero.selector);
        vm.prank(owner);
        reactive.manualCheckVolatility(poolId, 0);
    }

    function test_ManualCheckVolatility_RevertUnauthorized() public {
        PoolId poolId = _createPoolId();

        vm.prank(makeAddr("attacker"));
        vm.expectRevert(CorridorReactive.Unauthorized.selector);
        reactive.manualCheckVolatility(poolId, 1000);
    }

    // ============ Configuration Tests ============

    function test_SetVolatilityThreshold() public {
        uint256 newThreshold = 1000; // 10%

        vm.expectEmit(true, true, true, true);
        emit VolatilityThresholdUpdated(VOLATILITY_THRESHOLD, newThreshold);

        reactive.setVolatilityThreshold(newThreshold);

        assertEq(reactive.volatilityThreshold(), newThreshold);
    }

    function test_SetVolatilityThreshold_RevertInvalid() public {
        vm.expectRevert(CorridorReactive.InvalidThreshold.selector);
        reactive.setVolatilityThreshold(0);

        vm.expectRevert(CorridorReactive.InvalidThreshold.selector);
        reactive.setVolatilityThreshold(10001);
    }

    function test_SetVolatilityThreshold_RevertUnauthorized() public {
        vm.prank(makeAddr("attacker"));
        vm.expectRevert(CorridorReactive.Unauthorized.selector);
        reactive.setVolatilityThreshold(1000);
    }

    function test_SetCorridorHook() public {
        address newHook = makeAddr("newHook");

        vm.expectEmit(true, true, true, true);
        emit CorridorHookUpdated(newHook);

        reactive.setCorridorHook(newHook);

        assertEq(reactive.corridorHook(), newHook);
    }

    function test_SetCorridorHook_RevertZeroAddress() public {
        vm.expectRevert(CorridorReactive.InvalidAddress.selector);
        reactive.setCorridorHook(address(0));
    }

    function test_SetCorridorHook_RevertUnauthorized() public {
        vm.prank(makeAddr("attacker"));
        vm.expectRevert(CorridorReactive.Unauthorized.selector);
        reactive.setCorridorHook(makeAddr("newHook"));
    }

    function test_SetPriceOracle() public {
        address newOracle = makeAddr("newOracle");

        // Mock the subscribe call
        vm.mockCall(
            systemContract,
            abi.encodeWithSignature(
                "subscribe(uint256,address,uint256,uint256,uint256,uint256)"
            ),
            abi.encode()
        );

        vm.expectEmit(true, true, true, true);
        emit PriceOracleUpdated(newOracle);

        reactive.setPriceOracle(newOracle);

        assertEq(reactive.priceOracle(), newOracle);
    }

    function test_SetPriceOracle_RevertZeroAddress() public {
        vm.expectRevert(CorridorReactive.InvalidAddress.selector);
        reactive.setPriceOracle(address(0));
    }

    function test_SetPriceOracle_RevertDuplicate() public {
        vm.expectRevert(CorridorReactive.NoResubscriptionNeeded.selector);
        reactive.setPriceOracle(priceOracle);
    }

    function test_SetPriceOracle_RevertUnauthorized() public {
        vm.prank(makeAddr("attacker"));
        vm.expectRevert(CorridorReactive.Unauthorized.selector);
        reactive.setPriceOracle(makeAddr("newOracle"));
    }

    function test_TransferOwnership() public {
        address newOwner = makeAddr("newOwner");

        vm.expectEmit(true, true, true, true);
        emit OwnershipTransferred(owner, newOwner);

        reactive.transferOwnership(newOwner);

        assertEq(reactive.owner(), newOwner);
    }

    function test_TransferOwnership_RevertZeroAddress() public {
        vm.expectRevert(CorridorReactive.InvalidAddress.selector);
        reactive.transferOwnership(address(0));
    }

    function test_TransferOwnership_RevertUnauthorized() public {
        vm.prank(makeAddr("attacker"));
        vm.expectRevert(CorridorReactive.Unauthorized.selector);
        reactive.transferOwnership(makeAddr("newOwner"));
    }

    // ============ React Function Tests ============

    function test_React() public {
        PoolId poolId = _createPoolId();
        bytes memory data = abi.encode(poolId, uint256(1000));

        vm.expectEmit(true, true, true, true);
        emit PriceUpdated(_poolIdToAddress(poolId), 1000);

        vm.prank(systemContract);
        reactive.react(84532, priceOracle, 0, 0, 0, 0, data, 1, 0);

        assertEq(reactive.lastPrices(poolId), 1000);
    }

    function test_React_RevertUnauthorized() public {
        PoolId poolId = _createPoolId();
        bytes memory data = abi.encode(poolId, uint256(1000));

        vm.prank(makeAddr("attacker"));
        vm.expectRevert(CorridorReactive.Unauthorized.selector);
        reactive.react(84532, priceOracle, 0, 0, 0, 0, data, 1, 0);
    }

    // ============ Helper Functions ============

    function _createPoolKey() internal pure returns (PoolKey memory) {
        return
            PoolKey({
                currency0: Currency.wrap(address(0x1)),
                currency1: Currency.wrap(address(0x2)),
                fee: 3000,
                tickSpacing: 60,
                hooks: IHooks(address(0))
            });
    }

    function _createPoolId() internal pure returns (PoolId) {
        return _createPoolKey().toId();
    }

    function _poolIdToAddress(PoolId poolId) internal pure returns (address) {
        return address(uint160(uint256(PoolId.unwrap(poolId))));
    }
}
