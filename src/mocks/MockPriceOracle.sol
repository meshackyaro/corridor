// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

/// @title MockPriceOracle
/// @notice Mock price oracle for testing Corridor system
/// @dev Simulates NGN/USD price feeds with volatility
contract MockPriceOracle {
    // ============ Events ============
    event PriceUpdated(bytes32 indexed poolId, uint256 newPrice);

    // ============ State Variables ============

    /// @notice Current prices per pool
    mapping(bytes32 => uint256) public prices;

    /// @notice Price decimals (8 decimals like Chainlink)
    uint8 public constant DECIMALS = 8;

    /// @notice Owner address
    address public owner;

    // ============ Constructor ============

    constructor() {
        owner = msg.sender;
    }

    // ============ Functions ============

    /// @notice Updates price for a pool
    /// @param poolId Pool identifier
    /// @param newPrice New price (8 decimals)
    function updatePrice(bytes32 poolId, uint256 newPrice) external {
        require(msg.sender == owner, "Unauthorized");

        prices[poolId] = newPrice;
        emit PriceUpdated(poolId, newPrice);
    }

    /// @notice Gets latest price for a pool
    function getPrice(bytes32 poolId) external view returns (uint256) {
        return prices[poolId];
    }

    /// @notice Simulates volatile price movement
    /// @param poolId Pool identifier
    /// @param percentageChange Change in basis points (500 = 5%)
    /// @param increase True for price increase, false for decrease
    function simulateVolatility(
        bytes32 poolId,
        uint256 percentageChange,
        bool increase
    ) external {
        require(msg.sender == owner, "Unauthorized");

        uint256 currentPrice = prices[poolId];
        require(currentPrice > 0, "Price not initialized");

        uint256 change = (currentPrice * percentageChange) / 10000;
        uint256 newPrice = increase
            ? currentPrice + change
            : currentPrice - change;

        prices[poolId] = newPrice;
        emit PriceUpdated(poolId, newPrice);
    }

    /// @notice Transfers ownership
    function transferOwnership(address newOwner) external {
        require(msg.sender == owner, "Unauthorized");
        owner = newOwner;
    }
}
