// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title IReactive
/// @notice Interface for Reactive Network contracts
/// @dev Contracts that respond to cross-chain events must implement this interface
interface IReactive {
    /// @notice Called by Reactive Network when a subscribed event occurs
    /// @dev This function is triggered automatically when monitored events are detected
    /// @param chainId The chain ID where the event originated
    /// @param _contract The contract address that emitted the event
    /// @param topic0 Event signature hash (keccak256 of event signature)
    /// @param topic1 First indexed parameter (if any)
    /// @param topic2 Second indexed parameter (if any)
    /// @param topic3 Third indexed parameter (if any)
    /// @param data Non-indexed event data (ABI-encoded)
    /// @param blockNumber Block number where the event was emitted
    /// @param opCode Operation code (for advanced use cases)
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
