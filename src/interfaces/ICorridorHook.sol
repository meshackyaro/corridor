// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {PoolId} from "v4-core/types/PoolId.sol";

/// @title ICorridorHook
/// @notice Interface for Corridor Hook contract
interface ICorridorHook {
    /// @notice Pauses pool during extreme volatility
    /// @param rvm_id Reactive VM identifier (injected by Callback Proxy)
    function pausePool(
        address rvm_id,
        PoolId poolId,
        uint256 priceChange
    ) external;

    /// @notice Resumes pool after volatility stabilizes
    /// @param rvm_id Reactive VM identifier (injected by Callback Proxy)
    function resumePool(address rvm_id, PoolId poolId) external;

    /// @notice Updates pool fee based on volatility
    /// @param rvm_id Reactive VM identifier (injected by Callback Proxy)
    function updatePoolFee(
        address rvm_id,
        PoolId poolId,
        uint256 volatilityBps
    ) external;

    /// @notice Sets the Reactive Callback Proxy address
    function setReactiveContract(address _reactiveCallbackProxy) external;

    /// @notice Updates volatility threshold
    function setVolatilityThreshold(uint256 _newThreshold) external;
}
