// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {PoolId} from "v4-core/types/PoolId.sol";

/// @title ICorridorHook
/// @notice Interface for Corridor Hook contract
interface ICorridorHook {
    /// @notice Pauses pool during extreme volatility
    function pausePool(PoolId poolId, uint256 priceChange) external;

    /// @notice Resumes pool after volatility stabilizes
    function resumePool(PoolId poolId) external;

    /// @notice Sets the Reactive Network contract address
    function setReactiveContract(address _reactiveContract) external;

    /// @notice Updates volatility threshold
    function setVolatilityThreshold(uint256 _newThreshold) external;
}
