// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Test} from "forge-std/Test.sol";
import {CorridorReactive} from "../src/CorridorReactive.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";

contract CorridorReactiveTest is Test {
    using PoolIdLibrary for PoolKey;

    CorridorReactive public reactive;
    address public corridorHook;
    address public priceOracle;
    address public owner;

    uint256 constant VOLATILITY_THRESHOLD = 500; // 5%

    // Events
    event VolatilityDetected(
        bytes32 indexed poolId,
        uint256 priceChange,
        uint256 timestamp
    );
    event PoolPauseTriggered(bytes32 indexed poolId, uint256 priceChange);
    event PoolResumeTriggered(bytes32 indexed poolId);
    event PriceUpdated(bytes32 indexed poolId, uint256 newPrice);

    function setUp() public {
        corridorHook = makeAddr("corridorHook");
        priceOracle = makeAddr("priceOracle");
        owner = address(this);

        reactive = new CorridorReactive(
            corridorHook,
            priceOracle,
            VOLATILITY_THRESHOLD
        );
    }

    function test_Constructor() public view {
        assertEq(reactive.corridorHook(), corridorHook);
        assertEq(reactive.priceOracle(), priceOracle);
        assertEq(reactive.volatilityThreshold(), VOLATILITY_THRESHOLD);
        assertEq(reactive.owner(), owner);
        assertEq(reactive.DESTINATION_CHAIN_ID(), 1301);
    }

    function test_Constructor_RevertZeroHook() public {
        vm.expectRevert(CorridorReactive.InvalidAddress.selector);
        new CorridorReactive(address(0), priceOracle, VOLATILITY_THRESHOLD);
    }

    function test_Constructor_RevertZeroOracle() public {
        vm.expectRevert(CorridorReactive.InvalidAddress.selector);
        new CorridorReactive(corridorHook, address(0), VOLATILITY_THRESHOLD);
    }

    function test_Constructor_RevertInvalidThreshold() public {
        vm.expectRevert(CorridorReactive.InvalidThreshold.selector);
        new CorridorReactive(corridorHook, priceOracle, 0);

        vm.expectRevert(CorridorReactive.InvalidThreshold.selector);
        new CorridorReactive(corridorHook, priceOracle, 10001);
    }

    function test_CalculateVolatility() public view {
        PoolKey memory key = _createPoolKey();
        PoolId poolId = key.toId();
        
        uint256 volatility = reactive.calculateVolatility(poolId, 1000e18);
        assertEq(volatility, 0); // No last price set
    }

    function test_SetVolatilityThreshold() public {
        uint256 newThreshold = 1000;
        reactive.setVolatilityThreshold(newThreshold);
        assertEq(reactive.volatilityThreshold(), newThreshold);
    }

    function test_SetCorridorHook() public {
        address newHook = makeAddr("newHook");
        reactive.setCorridorHook(newHook);
        assertEq(reactive.corridorHook(), newHook);
    }

    function test_TransferOwnership() public {
        address newOwner = makeAddr("newOwner");
        reactive.transferOwnership(newOwner);
        assertEq(reactive.owner(), newOwner);
    }

    // Helper
    function _createPoolKey() internal view returns (PoolKey memory) {
        return PoolKey({
            currency0: Currency.wrap(address(0x1)),
            currency1: Currency.wrap(address(0x2)),
            fee: 3000,
            tickSpacing: 60,
            hooks: IHooks(corridorHook)
        });
    }
}
