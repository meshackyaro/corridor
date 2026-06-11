// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {
    AbstractReactive
} from "reactive-lib/abstract-base/AbstractReactive.sol";
import {IReactive} from "reactive-lib/interfaces/IReactive.sol";
import {ICorridorHook} from "./interfaces/ICorridorHook.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";

/// @title CorridorReactive
/// @notice Reactive Network contract for automated volatility monitoring and IL protection
/// @dev Monitors price oracle events and triggers hook callbacks for IL protection
contract CorridorReactive is AbstractReactive {
    using PoolIdLibrary for PoolId;

    // ============ Errors ============
    error Unauthorized();
    error InvalidThreshold();
    error InvalidAddress();
    error PriceIsZero();
    error NoResubscriptionNeeded();

    // ============ Events ============
    event VolatilityDetected(
        bytes32 indexed poolId,
        uint256 priceChange,
        uint256 timestamp
    );
    event PoolPauseTriggered(bytes32 indexed poolId, uint256 priceChange);
    event PoolResumeTriggered(bytes32 indexed poolId);
    event PriceUpdated(bytes32 indexed poolId, uint256 newPrice);
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
    event FeeUpdateTriggered(bytes32 indexed poolId, uint256 volatility);
    event Subscribed(uint256 chainId, address oracle, uint256 topic0);

    // ============ State Variables ============

    /// @notice Corridor Hook address on destination chain (Unichain)
    address public corridorHook;

    /// @notice Price oracle address to monitor
    address public priceOracle;

    /// @notice Volatility threshold in basis points (500 = 5%)
    uint256 public volatilityThreshold;

    /// @notice Last recorded prices per pool
    mapping(PoolId => uint256) public lastPrices;

    /// @notice Pause status per pool
    mapping(PoolId => bool) public poolPaused;

    /// @notice Owner address for configuration
    address public owner;

    /// @notice Destination chain ID (Unichain Sepolia = 1301)
    uint256 public constant DESTINATION_CHAIN_ID = 1301;

    /// @notice Callback gas limit (generous to avoid out-of-gas failures)
    uint64 private constant CALLBACK_GAS_LIMIT = 500_000;

    /// @notice PriceUpdated event signature
    uint256 private constant PRICE_UPDATED_TOPIC0 =
        uint256(keccak256("PriceUpdated(bytes32,uint256)"));

    // ============ Constructor ============

    constructor(
        address _corridorHook,
        address _priceOracle,
        uint256 _volatilityThreshold
    ) payable {
        if (_corridorHook == address(0)) revert InvalidAddress();
        if (_priceOracle == address(0)) revert InvalidAddress();
        if (_volatilityThreshold == 0 || _volatilityThreshold > 10000)
            revert InvalidThreshold();

        corridorHook = _corridorHook;
        priceOracle = _priceOracle;
        volatilityThreshold = _volatilityThreshold;
        owner = msg.sender;

        // Note: Subscription moved to external function due to Lasna testnet requirements
        // Call subscribe() after deployment
    }

    // ============ Modifiers ============

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    // ============ Reactive Functions ============

    /// @notice Called by Reactive Network when subscribed events occur
    /// @dev Processes price update events and triggers callbacks if needed
    function react(LogRecord calldata log) external override vmOnly {
        // Defensive filtering (subscription already scopes these)
        if (log.chain_id != DESTINATION_CHAIN_ID) return;
        if (log._contract != priceOracle) return;
        if (log.topic_0 != PRICE_UPDATED_TOPIC0) return;

        // Decode: poolId is indexed (topic_1), newPrice is in data
        PoolId poolId = PoolId.wrap(bytes32(log.topic_1));
        uint256 newPrice = abi.decode(log.data, (uint256));

        // Check for volatility
        _checkVolatility(poolId, newPrice);
    }

    // ============ Internal Functions ============

    /// @notice Subscribes to price oracle events
    function _subscribe() internal {
        service.subscribe(
            DESTINATION_CHAIN_ID,
            priceOracle,
            PRICE_UPDATED_TOPIC0,
            REACTIVE_IGNORE, // topic1 - we want all poolIds
            REACTIVE_IGNORE, // topic2
            REACTIVE_IGNORE // topic3
        );

        emit Subscribed(
            DESTINATION_CHAIN_ID,
            priceOracle,
            PRICE_UPDATED_TOPIC0
        );
    }

    /// @notice Checks price volatility and triggers callbacks
    function _checkVolatility(PoolId poolId, uint256 newPrice) internal {
        if (newPrice == 0) revert PriceIsZero();

        uint256 lastPrice = lastPrices[poolId];

        // First price update
        if (lastPrice == 0) {
            lastPrices[poolId] = newPrice;
            emit PriceUpdated(PoolId.unwrap(poolId), newPrice);
            return;
        }

        // Calculate price change percentage (in basis points)
        uint256 priceChange;
        if (newPrice > lastPrice) {
            priceChange = ((newPrice - lastPrice) * 10000) / lastPrice;
        } else {
            priceChange = ((lastPrice - newPrice) * 10000) / lastPrice;
        }

        emit VolatilityDetected(
            PoolId.unwrap(poolId),
            priceChange,
            block.timestamp
        );

        // Extreme volatility: pause pool
        if (priceChange > volatilityThreshold && !poolPaused[poolId]) {
            _pausePool(poolId, priceChange);
        }
        // Volatility normalized: resume pool
        else if (
            priceChange <= (volatilityThreshold / 2) && poolPaused[poolId]
        ) {
            _resumePool(poolId);
        }
        // Update fee based on current volatility (even if not pausing)
        else if (!poolPaused[poolId]) {
            _updateFee(poolId, priceChange);
        }

        // Update last price
        lastPrices[poolId] = newPrice;
        emit PriceUpdated(PoolId.unwrap(poolId), newPrice);
    }

    /// @notice Triggers callback to pause pool on destination chain
    function _pausePool(PoolId poolId, uint256 priceChange) internal {
        poolPaused[poolId] = true;

        // Prepare callback data with rvm_id as first argument (placeholder address(0))
        bytes memory payload = abi.encodeWithSignature(
            "pausePool(address,bytes32,uint256)",
            address(0), // rvm_id placeholder - callback proxy will inject real value
            PoolId.unwrap(poolId),
            priceChange
        );

        // Send callback to destination chain
        emit Callback(
            DESTINATION_CHAIN_ID,
            corridorHook,
            CALLBACK_GAS_LIMIT,
            payload
        );

        emit PoolPauseTriggered(PoolId.unwrap(poolId), priceChange);
    }

    /// @notice Triggers callback to resume pool on destination chain
    function _resumePool(PoolId poolId) internal {
        poolPaused[poolId] = false;

        // Prepare callback data with rvm_id as first argument
        bytes memory payload = abi.encodeWithSignature(
            "resumePool(address,bytes32)",
            address(0), // rvm_id placeholder
            PoolId.unwrap(poolId)
        );

        // Send callback to destination chain
        emit Callback(
            DESTINATION_CHAIN_ID,
            corridorHook,
            CALLBACK_GAS_LIMIT,
            payload
        );

        emit PoolResumeTriggered(PoolId.unwrap(poolId));
    }

    /// @notice Triggers callback to update pool fee based on volatility
    /// @dev Only triggers if volatility is significant but below pause threshold
    function _updateFee(PoolId poolId, uint256 priceChange) internal {
        // Only update if there's meaningful volatility (>1%)
        if (priceChange < 100) return;

        // Prepare callback data with rvm_id as first argument
        bytes memory payload = abi.encodeWithSignature(
            "updatePoolFee(address,bytes32,uint256)",
            address(0), // rvm_id placeholder
            PoolId.unwrap(poolId),
            priceChange
        );

        // Send callback to destination chain
        emit Callback(
            DESTINATION_CHAIN_ID,
            corridorHook,
            CALLBACK_GAS_LIMIT,
            payload
        );

        emit FeeUpdateTriggered(PoolId.unwrap(poolId), priceChange);
    }

    // ============ Configuration Functions ============

    /// @notice Updates volatility threshold
    /// @param _newThreshold New threshold in basis points
    function setVolatilityThreshold(uint256 _newThreshold) external onlyOwner {
        if (_newThreshold == 0 || _newThreshold > 10000)
            revert InvalidThreshold();
        uint256 oldThreshold = volatilityThreshold;
        volatilityThreshold = _newThreshold;
        emit VolatilityThresholdUpdated(oldThreshold, _newThreshold);
    }

    /// @notice Updates corridor hook address
    /// @param _newHook New hook contract address
    function setCorridorHook(address _newHook) external onlyOwner {
        if (_newHook == address(0)) revert InvalidAddress();
        corridorHook = _newHook;
        emit CorridorHookUpdated(_newHook);
    }

    /// @notice Resubscribes to events (in case subscription goes inactive)
    /// @dev Can only be called on Reactive Network, not in ReactVM
    function subscribe() external onlyOwner rnOnly {
        _subscribe();
    }

    /// @notice Updates price oracle address and resubscribes
    /// @param _newOracle New oracle contract address
    function setPriceOracle(address _newOracle) external onlyOwner rnOnly {
        if (_newOracle == address(0)) revert InvalidAddress();
        if (_newOracle == priceOracle) revert NoResubscriptionNeeded();

        // Unsubscribe from old oracle
        service.unsubscribe(
            DESTINATION_CHAIN_ID,
            priceOracle,
            PRICE_UPDATED_TOPIC0,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE,
            REACTIVE_IGNORE
        );

        // Update oracle address
        priceOracle = _newOracle;

        // Subscribe to new oracle
        _subscribe();

        emit PriceOracleUpdated(_newOracle);
    }

    /// @notice Transfers ownership
    /// @param _newOwner New owner address
    function transferOwnership(address _newOwner) external onlyOwner {
        if (_newOwner == address(0)) revert InvalidAddress();
        address oldOwner = owner;
        owner = _newOwner;
        emit OwnershipTransferred(oldOwner, _newOwner);
    }

    /// @notice Manual trigger for testing
    /// @param poolId Pool identifier
    /// @param newPrice New price to check
    function manualCheckVolatility(
        PoolId poolId,
        uint256 newPrice
    ) external onlyOwner {
        _checkVolatility(poolId, newPrice);
    }

    /// @notice View function to calculate expected volatility
    /// @param poolId Pool identifier
    /// @param newPrice Hypothetical new price
    /// @return priceChange The calculated volatility in basis points
    function calculateVolatility(
        PoolId poolId,
        uint256 newPrice
    ) external view returns (uint256 priceChange) {
        uint256 lastPrice = lastPrices[poolId];
        if (lastPrice == 0 || newPrice == 0) return 0;

        if (newPrice > lastPrice) {
            priceChange = ((newPrice - lastPrice) * 10000) / lastPrice;
        } else {
            priceChange = ((lastPrice - newPrice) * 10000) / lastPrice;
        }
    }

    /// @notice Check if a pool would be paused at a given price
    /// @param poolId Pool identifier
    /// @param newPrice Hypothetical new price
    /// @return wouldPause True if pool would be paused
    /// @return wouldResume True if pool would be resumed
    function checkPauseStatus(
        PoolId poolId,
        uint256 newPrice
    ) external view returns (bool wouldPause, bool wouldResume) {
        uint256 priceChange = this.calculateVolatility(poolId, newPrice);
        bool isPaused = poolPaused[poolId];

        wouldPause = priceChange > volatilityThreshold && !isPaused;
        wouldResume = priceChange <= (volatilityThreshold / 2) && isPaused;
    }
}
