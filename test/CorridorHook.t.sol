// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Test} from "forge-std/Test.sol";
import {CorridorHook} from "../src/CorridorHook.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";

contract CorridorHookTest is Test {
    using PoolIdLibrary for PoolKey;

    CorridorHook public hook;
    IPoolManager public poolManager;
    address public governance;
    address public reactiveCallbackProxy;
    address public lpProvider;

    uint256 constant VOLATILITY_THRESHOLD = 500; // 5%

    // Events
    event VolatilityThresholdUpdated(
        uint256 oldThreshold,
        uint256 newThreshold
    );
    event PoolPausedByVolatility(PoolId indexed poolId, uint256 priceChange);
    event PoolResumed(PoolId indexed poolId);
    event DynamicFeeUpdated(PoolId indexed poolId, uint24 newFee);
    event CommunityLPAdded(address indexed lp, uint256 amount);
    event CommunityLPRemoved(address indexed lp, uint256 amount);
    event FeeParametersUpdated(uint24 newBaseFee, uint24 newMaxFee);
    event ReactiveContractUpdated(address indexed newReactive);
    event GovernanceTransferred(
        address indexed oldGovernance,
        address indexed newGovernance
    );

    function setUp() public {
        // Setup addresses
        governance = makeAddr("governance");
        reactiveCallbackProxy = makeAddr("reactive");
        lpProvider = makeAddr("lpProvider");
        poolManager = IPoolManager(makeAddr("poolManager"));

        // Deploy hook
        vm.prank(governance);
        hook = new CorridorHook(poolManager, governance, VOLATILITY_THRESHOLD);
    }

    function test_Constructor() public view {
        assertEq(address(hook.poolManager()), address(poolManager));
        assertEq(hook.communityGovernance(), governance);
        assertEq(hook.volatilityThreshold(), VOLATILITY_THRESHOLD);
        assertEq(hook.baseFee(), 30); // 0.3%
        assertEq(hook.maxVolatilityFee(), 100); // 1%
    }

    function test_SetReactiveContract() public {
        vm.prank(governance);
        hook.setReactiveContract(reactiveCallbackProxy);

        assertEq(hook.reactiveCallbackProxy(), reactiveCallbackProxy);
    }

    function test_SetReactiveContract_RevertUnauthorized() public {
        vm.prank(makeAddr("attacker"));
        vm.expectRevert(CorridorHook.Unauthorized.selector);
        hook.setReactiveContract(reactiveCallbackProxy);
    }

    function test_SetVolatilityThreshold() public {
        uint256 newThreshold = 1000; // 10%

        vm.prank(governance);
        vm.expectEmit(true, true, true, true);
        emit VolatilityThresholdUpdated(VOLATILITY_THRESHOLD, newThreshold);
        hook.setVolatilityThreshold(newThreshold);

        assertEq(hook.volatilityThreshold(), newThreshold);
    }

    function test_SetVolatilityThreshold_RevertInvalid() public {
        vm.prank(governance);
        vm.expectRevert(CorridorHook.InvalidVolatilityThreshold.selector);
        hook.setVolatilityThreshold(0);

        vm.prank(governance);
        vm.expectRevert(CorridorHook.InvalidVolatilityThreshold.selector);
        hook.setVolatilityThreshold(10001);
    }

    function test_SetFeeParameters() public {
        uint24 newBaseFee = 50; // 0.5%
        uint24 newMaxFee = 200; // 2%

        vm.prank(governance);
        hook.setFeeParameters(newBaseFee, newMaxFee);

        assertEq(hook.baseFee(), newBaseFee);
        assertEq(hook.maxVolatilityFee(), newMaxFee);
    }

    function test_SetFeeParameters_RevertInvalid() public {
        vm.prank(governance);
        vm.expectRevert(CorridorHook.InvalidFeeParameters.selector);
        hook.setFeeParameters(200, 100); // base > max

        vm.prank(governance);
        vm.expectRevert(CorridorHook.InvalidFeeParameters.selector);
        hook.setFeeParameters(100, 10001); // max > 100%
    }

    function test_UpdatePoolFee_LowVolatility() public {
        // Setup
        vm.prank(governance);
        hook.setReactiveContract(reactiveCallbackProxy);

        PoolKey memory key = _createPoolKey();
        PoolId poolId = key.toId();

        // Initialize pool
        vm.prank(address(poolManager));
        hook.beforeInitialize(address(this), key, 0);

        // Update fee with low volatility (2.5%)
        uint256 volatility = 250; // 2.5%
        // Expected fee: baseFee (30) + (250 * (100-30) / 500) = 30 + 35 = 65

        vm.prank(reactiveCallbackProxy);
        vm.expectEmit(true, true, true, true);
        emit DynamicFeeUpdated(poolId, 65);
        hook.updatePoolFee(address(0), poolId, volatility);

        assertEq(hook.poolDynamicFee(poolId), 65);
    }

    function test_UpdatePoolFee_HighVolatility() public {
        // Setup
        vm.prank(governance);
        hook.setReactiveContract(reactiveCallbackProxy);

        PoolKey memory key = _createPoolKey();
        PoolId poolId = key.toId();

        // Initialize pool
        vm.prank(address(poolManager));
        hook.beforeInitialize(address(this), key, 0);

        // Update fee with high volatility (7%)
        uint256 volatility = 700; // 7%

        vm.prank(reactiveCallbackProxy);
        vm.expectEmit(true, true, true, true);
        emit DynamicFeeUpdated(poolId, 100); // maxVolatilityFee
        hook.updatePoolFee(address(0), poolId, volatility);

        assertEq(hook.poolDynamicFee(poolId), 100);
    }

    function test_PausePool() public {
        // Setup
        vm.prank(governance);
        hook.setReactiveContract(reactiveCallbackProxy);

        PoolKey memory key = _createPoolKey();
        PoolId poolId = key.toId();

        // Pause pool
        vm.prank(reactiveCallbackProxy);
        vm.expectEmit(true, true, true, true);
        emit PoolPausedByVolatility(poolId, 1000);
        hook.pausePool(address(0), poolId, 1000);

        assertTrue(hook.poolPaused(poolId));
    }

    function test_ResumePool() public {
        // Setup
        vm.prank(governance);
        hook.setReactiveContract(reactiveCallbackProxy);

        PoolKey memory key = _createPoolKey();
        PoolId poolId = key.toId();

        // Pause then resume
        vm.prank(reactiveCallbackProxy);
        hook.pausePool(address(0), poolId, 1000);

        vm.prank(reactiveCallbackProxy);
        vm.expectEmit(true, true, true, true);
        emit PoolResumed(poolId);
        hook.resumePool(address(0), poolId);

        assertFalse(hook.poolPaused(poolId));
    }

    function test_BeforeSwap_RevertWhenPaused() public {
        // Setup
        vm.prank(governance);
        hook.setReactiveContract(reactiveCallbackProxy);

        PoolKey memory key = _createPoolKey();
        PoolId poolId = key.toId();

        // Pause pool
        vm.prank(reactiveCallbackProxy);
        hook.pausePool(address(0), poolId, 1000);

        // Try to swap
        IPoolManager.SwapParams memory params;
        vm.prank(address(poolManager));
        vm.expectRevert(CorridorHook.PoolPaused.selector);
        hook.beforeSwap(address(this), key, params, "");
    }

    function test_BeforeSwap_ReturnsDynamicFee() public {
        PoolKey memory key = _createPoolKey();
        PoolId poolId = key.toId();

        // Initialize pool
        vm.prank(address(poolManager));
        hook.beforeInitialize(address(this), key, 0);

        // Swap
        IPoolManager.SwapParams memory params;
        vm.prank(address(poolManager));
        (bytes4 selector, , uint24 fee) = hook.beforeSwap(
            address(this),
            key,
            params,
            ""
        );

        assertEq(selector, IHooks.beforeSwap.selector);
        assertEq(fee, 30); // baseFee
    }

    function test_CommunityLPTracking() public {
        PoolKey memory key = _createPoolKey();
        IPoolManager.ModifyLiquidityParams memory params;

        // Add liquidity
        vm.prank(address(poolManager));
        vm.expectEmit(true, true, true, true);
        emit CommunityLPAdded(lpProvider, 1);
        hook.beforeAddLiquidity(lpProvider, key, params, "");

        assertEq(hook.communityLPShares(lpProvider), 1);
        assertEq(hook.totalCommunityShares(), 1);

        // Remove liquidity
        vm.prank(address(poolManager));
        vm.expectEmit(true, true, true, true);
        emit CommunityLPRemoved(lpProvider, 1);
        hook.beforeRemoveLiquidity(lpProvider, key, params, "");

        assertEq(hook.communityLPShares(lpProvider), 0);
        assertEq(hook.totalCommunityShares(), 0);
    }

    function test_TransferGovernance() public {
        address newGovernance = makeAddr("newGovernance");

        vm.prank(governance);
        hook.transferGovernance(newGovernance);

        assertEq(hook.communityGovernance(), newGovernance);
    }

    function test_TransferGovernance_RevertUnauthorized() public {
        address newGovernance = makeAddr("newGovernance");

        vm.prank(makeAddr("attacker"));
        vm.expectRevert(CorridorHook.Unauthorized.selector);
        hook.transferGovernance(newGovernance);
    }

    // ============ Additional Coverage Tests ============

    function test_Constructor_RevertZeroPoolManager() public {
        vm.expectRevert(CorridorHook.InvalidAddress.selector);
        new CorridorHook(
            IPoolManager(address(0)),
            governance,
            VOLATILITY_THRESHOLD
        );
    }

    function test_Constructor_RevertZeroGovernance() public {
        vm.expectRevert(CorridorHook.InvalidAddress.selector);
        new CorridorHook(poolManager, address(0), VOLATILITY_THRESHOLD);
    }

    function test_Constructor_RevertInvalidThreshold() public {
        vm.expectRevert(CorridorHook.InvalidVolatilityThreshold.selector);
        new CorridorHook(poolManager, governance, 0);

        vm.expectRevert(CorridorHook.InvalidVolatilityThreshold.selector);
        new CorridorHook(poolManager, governance, 10001);
    }

    function test_AfterInitialize() public {
        PoolKey memory key = _createPoolKey();

        vm.prank(address(poolManager));
        bytes4 selector = hook.afterInitialize(address(this), key, 0, 0);

        assertEq(selector, IHooks.afterInitialize.selector);
    }

    function test_AfterSwap() public {
        PoolKey memory key = _createPoolKey();
        IPoolManager.SwapParams memory params;

        vm.prank(address(poolManager));
        (bytes4 selector, int128 delta) = hook.afterSwap(
            address(this),
            key,
            params,
            BalanceDelta.wrap(0),
            ""
        );

        assertEq(selector, IHooks.afterSwap.selector);
        assertEq(delta, 0);
    }

    function test_AfterAddLiquidity() public {
        PoolKey memory key = _createPoolKey();
        IPoolManager.ModifyLiquidityParams memory params;

        vm.prank(address(poolManager));
        (bytes4 selector, BalanceDelta delta) = hook.afterAddLiquidity(
            address(this),
            key,
            params,
            BalanceDelta.wrap(0),
            BalanceDelta.wrap(0),
            ""
        );

        assertEq(selector, IHooks.afterAddLiquidity.selector);
        assertEq(BalanceDelta.unwrap(delta), 0);
    }

    function test_AfterRemoveLiquidity() public {
        PoolKey memory key = _createPoolKey();
        IPoolManager.ModifyLiquidityParams memory params;

        vm.prank(address(poolManager));
        (bytes4 selector, BalanceDelta delta) = hook.afterRemoveLiquidity(
            address(this),
            key,
            params,
            BalanceDelta.wrap(0),
            BalanceDelta.wrap(0),
            ""
        );

        assertEq(selector, IHooks.afterRemoveLiquidity.selector);
        assertEq(BalanceDelta.unwrap(delta), 0);
    }

    function test_BeforeDonate() public {
        PoolKey memory key = _createPoolKey();

        vm.prank(address(poolManager));
        bytes4 selector = hook.beforeDonate(address(this), key, 100, 100, "");

        assertEq(selector, IHooks.beforeDonate.selector);
    }

    function test_AfterDonate() public {
        PoolKey memory key = _createPoolKey();

        vm.prank(address(poolManager));
        bytes4 selector = hook.afterDonate(address(this), key, 100, 100, "");

        assertEq(selector, IHooks.afterDonate.selector);
    }

    function test_UpdatePoolFee_ByGovernance() public {
        PoolKey memory key = _createPoolKey();
        PoolId poolId = key.toId();

        // Initialize pool
        vm.prank(address(poolManager));
        hook.beforeInitialize(address(this), key, 0);

        // Update fee by governance (without reactive contract)
        uint256 volatility = 250;

        vm.prank(governance);
        vm.expectEmit(true, true, true, true);
        emit DynamicFeeUpdated(poolId, 65);
        hook.updatePoolFee(address(0), poolId, volatility);

        assertEq(hook.poolDynamicFee(poolId), 65);
    }

    function test_UpdatePoolFee_RevertUnauthorized() public {
        PoolKey memory key = _createPoolKey();
        PoolId poolId = key.toId();

        vm.prank(makeAddr("attacker"));
        vm.expectRevert(CorridorHook.Unauthorized.selector);
        hook.updatePoolFee(address(0), poolId, 100);
    }

    function test_PausePool_ByGovernance() public {
        PoolKey memory key = _createPoolKey();
        PoolId poolId = key.toId();

        vm.prank(governance);
        vm.expectEmit(true, true, true, true);
        emit PoolPausedByVolatility(poolId, 500);
        hook.pausePool(address(0), poolId, 500);

        assertTrue(hook.poolPaused(poolId));
    }

    function test_PausePool_RevertUnauthorized() public {
        PoolKey memory key = _createPoolKey();
        PoolId poolId = key.toId();

        vm.prank(makeAddr("attacker"));
        vm.expectRevert(CorridorHook.Unauthorized.selector);
        hook.pausePool(address(0), poolId, 100);
    }

    function test_ResumePool_ByGovernance() public {
        PoolKey memory key = _createPoolKey();
        PoolId poolId = key.toId();

        // Pause first
        vm.prank(governance);
        hook.pausePool(address(0), poolId, 500);

        // Resume by governance
        vm.prank(governance);
        vm.expectEmit(true, true, true, true);
        emit PoolResumed(poolId);
        hook.resumePool(address(0), poolId);

        assertFalse(hook.poolPaused(poolId));
    }

    function test_ResumePool_RevertUnauthorized() public {
        PoolKey memory key = _createPoolKey();
        PoolId poolId = key.toId();

        vm.prank(makeAddr("attacker"));
        vm.expectRevert(CorridorHook.Unauthorized.selector);
        hook.resumePool(address(0), poolId);
    }

    function test_BeforeRemoveLiquidity_WithoutShares() public {
        PoolKey memory key = _createPoolKey();
        IPoolManager.ModifyLiquidityParams memory params;
        address newLP = makeAddr("newLP");

        // Remove without having added (should not revert, just skip)
        vm.prank(address(poolManager));
        bytes4 selector = hook.beforeRemoveLiquidity(newLP, key, params, "");

        assertEq(selector, IHooks.beforeRemoveLiquidity.selector);
        assertEq(hook.communityLPShares(newLP), 0);
    }

    function test_UpdatePoolFee_AtExactThreshold() public {
        vm.prank(governance);
        hook.setReactiveContract(reactiveCallbackProxy);

        PoolKey memory key = _createPoolKey();
        PoolId poolId = key.toId();

        vm.prank(address(poolManager));
        hook.beforeInitialize(address(this), key, 0);

        // Volatility exactly at threshold (500 = 5%)
        uint256 volatility = 500;

        vm.prank(reactiveCallbackProxy);
        hook.updatePoolFee(address(0), poolId, volatility);

        // Should still use baseFee + calculation, not maxFee
        // Expected: baseFee (30) + (500 * (100-30) / 500) = 30 + 70 = 100
        assertEq(hook.poolDynamicFee(poolId), 100);
    }

    function test_SetFeeParameters_EmitsEvent() public {
        uint24 newBaseFee = 50;
        uint24 newMaxFee = 150;

        vm.prank(governance);
        vm.expectEmit(true, true, true, true);
        emit FeeParametersUpdated(newBaseFee, newMaxFee);
        hook.setFeeParameters(newBaseFee, newMaxFee);
    }

    function test_SetReactiveContract_EmitsEvent() public {
        vm.prank(governance);
        vm.expectEmit(true, true, true, true);
        emit ReactiveContractUpdated(reactiveCallbackProxy);
        hook.setReactiveContract(reactiveCallbackProxy);
    }

    function test_TransferGovernance_EmitsEvent() public {
        address newGovernance = makeAddr("newGovernance");

        vm.prank(governance);
        vm.expectEmit(true, true, true, true);
        emit GovernanceTransferred(governance, newGovernance);
        hook.transferGovernance(newGovernance);
    }

    function test_BeforeInitialize_SetsBaseFee() public {
        PoolKey memory key = _createPoolKey();
        PoolId poolId = key.toId();

        vm.prank(address(poolManager));
        bytes4 selector = hook.beforeInitialize(address(this), key, 0);

        assertEq(selector, IHooks.beforeInitialize.selector);
        assertEq(hook.poolDynamicFee(poolId), 30); // baseFee
    }

    function test_NotPoolManager_BeforeInitialize() public {
        PoolKey memory key = _createPoolKey();

        vm.expectRevert(CorridorHook.NotPoolManager.selector);
        hook.beforeInitialize(address(this), key, 0);
    }

    function test_NotPoolManager_BeforeSwap() public {
        PoolKey memory key = _createPoolKey();
        IPoolManager.SwapParams memory params;

        vm.expectRevert(CorridorHook.NotPoolManager.selector);
        hook.beforeSwap(address(this), key, params, "");
    }

    function test_NotPoolManager_BeforeAddLiquidity() public {
        PoolKey memory key = _createPoolKey();
        IPoolManager.ModifyLiquidityParams memory params;

        vm.expectRevert(CorridorHook.NotPoolManager.selector);
        hook.beforeAddLiquidity(address(this), key, params, "");
    }

    function test_NotPoolManager_BeforeRemoveLiquidity() public {
        PoolKey memory key = _createPoolKey();
        IPoolManager.ModifyLiquidityParams memory params;

        vm.expectRevert(CorridorHook.NotPoolManager.selector);
        hook.beforeRemoveLiquidity(address(this), key, params, "");
    }

    // Helper functions
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
}
