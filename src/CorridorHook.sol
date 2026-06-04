// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {BalanceDelta} from "v4-core/types/BalanceDelta.sol";
import {
    BeforeSwapDelta,
    BeforeSwapDeltaLibrary
} from "v4-core/types/BeforeSwapDelta.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";

/// @title CorridorHook
/// @notice Community-owned remittance infrastructure for African currency corridors (USD/NGN)
/// @dev Implements IL protection, dynamic fees, and integration points for Reactive Network automation
contract CorridorHook is IHooks {
    using PoolIdLibrary for PoolKey;

    // ============ Errors ============
    error Unauthorized();
    error PoolPaused();
    error InvalidVolatilityThreshold();
    error InvalidFeeParameters();
    error NotPoolManager();
    error InvalidAddress();

    // ============ Events ============
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

    // ============ State Variables ============

    /// @notice Pool Manager
    IPoolManager public immutable poolManager;

    /// @notice Community governance address
    address public communityGovernance;

    /// @notice Reactive Network contract address for automation
    address public reactiveContract;

    /// @notice Volatility threshold (basis points) - triggers IL protection
    /// @dev 500 = 5% price movement triggers protection
    uint256 public volatilityThreshold;

    /// @notice Base fee in basis points (0.3% = 30)
    uint24 public baseFee;

    /// @notice Maximum fee during high volatility (1% = 100)
    uint24 public maxVolatilityFee;

    /// @notice Tracks if pool is paused due to extreme volatility
    mapping(PoolId => bool) public poolPaused;

    /// @notice Community LP tracking for yield distribution
    mapping(address => uint256) public communityLPShares;

    /// @notice Total community LP shares
    uint256 public totalCommunityShares;

    /// @notice Dynamic fee per pool
    mapping(PoolId => uint24) public poolDynamicFee;

    // ============ Modifiers ============

    modifier onlyPoolManager() {
        if (msg.sender != address(poolManager)) revert NotPoolManager();
        _;
    }

    // ============ Constructor ============

    constructor(
        IPoolManager _poolManager,
        address _communityGovernance,
        uint256 _volatilityThreshold
    ) {
        if (address(_poolManager) == address(0)) revert InvalidAddress();
        if (_communityGovernance == address(0)) revert InvalidAddress();
        if (_volatilityThreshold == 0 || _volatilityThreshold > 10000)
            revert InvalidVolatilityThreshold();

        poolManager = _poolManager;
        communityGovernance = _communityGovernance;
        volatilityThreshold = _volatilityThreshold;
        baseFee = 30; // 0.3%
        maxVolatilityFee = 100; // 1%
    }

    // ============ Hook Implementations ============

    function beforeInitialize(
        address,
        PoolKey calldata key,
        uint160
    ) external override onlyPoolManager returns (bytes4) {
        PoolId poolId = key.toId();

        // Initialize with base fee
        poolDynamicFee[poolId] = baseFee;

        return IHooks.beforeInitialize.selector;
    }

    function afterInitialize(
        address,
        PoolKey calldata,
        uint160,
        int24
    ) external override onlyPoolManager returns (bytes4) {
        return IHooks.afterInitialize.selector;
    }

    function beforeSwap(
        address,
        PoolKey calldata key,
        IPoolManager.SwapParams calldata,
        bytes calldata
    )
        external
        override
        onlyPoolManager
        returns (bytes4, BeforeSwapDelta, uint24)
    {
        PoolId poolId = key.toId();

        // Check if pool is paused
        if (poolPaused[poolId]) {
            revert PoolPaused();
        }

        // Return dynamic fee
        return (
            IHooks.beforeSwap.selector,
            BeforeSwapDeltaLibrary.ZERO_DELTA,
            poolDynamicFee[poolId]
        );
    }

    function afterSwap(
        address,
        PoolKey calldata,
        IPoolManager.SwapParams calldata,
        BalanceDelta,
        bytes calldata
    ) external override onlyPoolManager returns (bytes4, int128) {
        // Price tracking handled by Reactive Network monitoring oracle events
        return (IHooks.afterSwap.selector, 0);
    }

    function beforeAddLiquidity(
        address sender,
        PoolKey calldata,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    ) external override onlyPoolManager returns (bytes4) {
        // Track community LPs
        communityLPShares[sender] += 1;
        totalCommunityShares += 1;

        emit CommunityLPAdded(sender, 1);

        return IHooks.beforeAddLiquidity.selector;
    }

    function afterAddLiquidity(
        address,
        PoolKey calldata,
        IPoolManager.ModifyLiquidityParams calldata,
        BalanceDelta,
        BalanceDelta,
        bytes calldata
    ) external override onlyPoolManager returns (bytes4, BalanceDelta) {
        return (IHooks.afterAddLiquidity.selector, BalanceDelta.wrap(0));
    }

    function beforeRemoveLiquidity(
        address sender,
        PoolKey calldata,
        IPoolManager.ModifyLiquidityParams calldata,
        bytes calldata
    ) external override onlyPoolManager returns (bytes4) {
        // Update community LP tracking
        if (communityLPShares[sender] > 0) {
            communityLPShares[sender] -= 1;
            totalCommunityShares -= 1;
            emit CommunityLPRemoved(sender, 1);
        }

        return IHooks.beforeRemoveLiquidity.selector;
    }

    function afterRemoveLiquidity(
        address,
        PoolKey calldata,
        IPoolManager.ModifyLiquidityParams calldata,
        BalanceDelta,
        BalanceDelta,
        bytes calldata
    ) external override onlyPoolManager returns (bytes4, BalanceDelta) {
        return (IHooks.afterRemoveLiquidity.selector, BalanceDelta.wrap(0));
    }

    function beforeDonate(
        address,
        PoolKey calldata,
        uint256,
        uint256,
        bytes calldata
    ) external override onlyPoolManager returns (bytes4) {
        return IHooks.beforeDonate.selector;
    }

    function afterDonate(
        address,
        PoolKey calldata,
        uint256,
        uint256,
        bytes calldata
    ) external override onlyPoolManager returns (bytes4) {
        return IHooks.afterDonate.selector;
    }

    // ============ Reactive Network Integration Points ============

    /// @notice Sets the Reactive Network contract address
    /// @dev Called by governance to enable automation
    /// @param _reactiveContract Address of the Reactive Network contract
    function setReactiveContract(address _reactiveContract) external {
        if (msg.sender != communityGovernance) revert Unauthorized();
        reactiveContract = _reactiveContract;
        emit ReactiveContractUpdated(_reactiveContract);
    }

    /// @notice Updates pool fee based on volatility detected by Reactive Network
    /// @dev Called by Reactive Network contract
    function updatePoolFee(PoolId poolId, uint256 volatilityBps) external {
        if (
            msg.sender != reactiveContract && msg.sender != communityGovernance
        ) {
            revert Unauthorized();
        }

        uint24 newFee;
        if (volatilityBps > volatilityThreshold) {
            newFee = maxVolatilityFee;
        } else {
            uint24 additionalFee = uint24(
                (volatilityBps * (maxVolatilityFee - baseFee)) /
                    volatilityThreshold
            );
            newFee = baseFee + additionalFee;
        }

        poolDynamicFee[poolId] = newFee;
        emit DynamicFeeUpdated(poolId, newFee);
    }

    /// @notice Pauses pool during extreme volatility
    /// @dev Called by Reactive Network contract when volatility exceeds threshold
    function pausePool(PoolId poolId, uint256 priceChange) external {
        if (
            msg.sender != reactiveContract && msg.sender != communityGovernance
        ) {
            revert Unauthorized();
        }

        poolPaused[poolId] = true;
        emit PoolPausedByVolatility(poolId, priceChange);
    }

    /// @notice Resumes pool after volatility stabilizes
    /// @dev Called by Reactive Network contract or governance
    function resumePool(PoolId poolId) external {
        if (
            msg.sender != reactiveContract && msg.sender != communityGovernance
        ) {
            revert Unauthorized();
        }

        poolPaused[poolId] = false;
        emit PoolResumed(poolId);
    }

    // ============ Governance Functions ============

    /// @notice Updates volatility threshold
    function setVolatilityThreshold(uint256 _newThreshold) external {
        if (msg.sender != communityGovernance) revert Unauthorized();
        if (_newThreshold == 0 || _newThreshold > 10000)
            revert InvalidVolatilityThreshold();

        uint256 oldThreshold = volatilityThreshold;
        volatilityThreshold = _newThreshold;

        emit VolatilityThresholdUpdated(oldThreshold, _newThreshold);
    }

    /// @notice Updates fee parameters
    /// @param _baseFee New base fee in basis points
    /// @param _maxFee New maximum fee in basis points
    function setFeeParameters(uint24 _baseFee, uint24 _maxFee) external {
        if (msg.sender != communityGovernance) revert Unauthorized();
        if (_baseFee > _maxFee || _maxFee > 10000)
            revert InvalidFeeParameters();

        baseFee = _baseFee;
        maxVolatilityFee = _maxFee;
        emit FeeParametersUpdated(_baseFee, _maxFee);
    }

    /// @notice Transfers governance to new address
    /// @param _newGovernance Address of new governance
    function transferGovernance(address _newGovernance) external {
        if (msg.sender != communityGovernance) revert Unauthorized();
        address oldGovernance = communityGovernance;
        communityGovernance = _newGovernance;
        emit GovernanceTransferred(oldGovernance, _newGovernance);
    }
}
