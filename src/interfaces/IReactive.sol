// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title IReactive
/// @notice Interface for Reactive Network contracts
interface IReactive {
    /// @notice Called by Reactive Network when subscribed events occur
    /// @param chainId The chain ID where the event originated
    /// @param _contract The contract address that emitted the event
    /// @param topic0 Event signature hash
    /// @param topic1 First indexed parameter
    /// @param topic2 Second indexed parameter
    /// @param topic3 Third indexed parameter
    /// @param data Event data (non-indexed parameters)
    /// @param blockNumber Block number where event was emitted
    /// @param opCode Operation code
    function react(
        uint256 chainId,
        address _contract,
        uint256 topic0,
        uint256 topic1,
        uint256 topic2,
        uint256 topic3,
        bytes calldata data,
        uint256 blockNumber,
        uint256 opCode
    ) external;
}
