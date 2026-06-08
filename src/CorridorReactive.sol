// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {IReactive} from "./interfaces/IReactive.sol";
import {ICorridorHook} from "./interfaces/ICorridorHook.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";

/// @title CorridorReactive
/// @notice Reactive Network contract for automated volatility monitoring and IL protection
/// @dev Monitors price oracle events and triggers hook callbacks for IL protection
contract CorridorReactive is IReactive {
    using PoolIdLibrary for PoolId;
    // ============ Errors ============
    error Unauthorized();
    error InvalidThreshold();
    error CallbackFailed();
    error InvalidAddress();
    error PriceIsZero();
    error NoResubscriptionNeeded();

    // ============ Events ============
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

    // ============ State Variables ============

    /// @notice System contract address (Reactive Network)
    address public immutable SYSTEM_CONTRACT;

    /// @notice Callback proxy address for destination chain
    address public immutable CALLBACK_PROXY;

    /// @notice Corridor Hook address on destination chain (Base)
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

    /// @notice Destination chain ID (Unichain Sepolia = 1301, Unichain Mainnet = 130)
    uint256 public constant DESTINATION_CHAIN_ID = 1301;

    // ============ Constructor ============

    constructor(
        address _systemContract,
        address _callbackProxy,
        address _corridorHook,
        address _priceOracle,
        uint256 _volatilityThreshold
    ) {
        if (_systemContract == address(0)) revert InvalidAddress();
        if (_callbackProxy == address(0)) revert InvalidAddress();
        if (_corridorHook == address(0)) revert InvalidAddress();
        if (_priceOracle == address(0)) revert InvalidAddress();
        if (_volatilityThreshold == 0 || _volatilityThreshold > 10000)
            revert InvalidThreshold();

        SYSTEM_CONTRACT = _systemContract;
        CALLBACK_PROXY = _callbackProxy;
        corridorHook = _corridorHook;
        priceOracle = _priceOracle;
        volatilityThreshold = _volatilityThreshold;
        owner = msg.sender;

        // Subscribe to price oracle events
        _subscribe();
    }

    // ============ Modifiers ============

    modifier onlySystem() {
        if (msg.sender != SYSTEM_CONTRACT) revert Unauthorized();
        _;
    }

    modifier onlyOwner() {
        if (msg.sender != owner) revert Unauthorized();
        _;
    }

    // ============ Reactive Functions ============

    /// @notice Called by Reactive Network when subscribed events occur
    /// @dev Processes price update events and triggers callbacks if needed
    function react(
        uint256 /* chainId */,
        address /* _contract */,
        uint256 /* topic0 */,
        uint256 /* topic1 */,
        uint256 /* topic2 */,
        uint256 /* topic3 */,
        bytes calldata data,
        uint256 /* blockNumber */,
        uint256 /* opCode */
    ) external onlySystem {
        // Decode price update data
        // Expected format: (poolId, newPrice)
        (PoolId poolId, uint256 newPrice) = abi.decode(data, (PoolId, uint256));

        // Check for volatility
        _checkVolatility(poolId, newPrice);
    }

    // ============ Internal Functions ============

    /// @notice Subscribes to price oracle events
    function _subscribe() internal {
        // Subscribe to PriceUpdated events from oracle
        // This is a simplified version - actual implementation depends on oracle interface
        IReactiveSystem(SYSTEM_CONTRACT).subscribe(
            DESTINATION_CHAIN_ID,
            priceOracle,
            uint256(keccak256("PriceUpdated(bytes32,uint256)")), // Event signature
            0, // topic1
            0, // topic2
            0 // topic3
        );
    }

    /// @notice Checks price volatility and triggers callbacks
    function _checkVolatility(PoolId poolId, uint256 newPrice) internal {
        if (newPrice == 0) revert PriceIsZero();

        uint256 lastPrice = lastPrices[poolId];

        // First price update
        if (lastPrice == 0) {
            lastPrices[poolId] = newPrice;
            emit PriceUpdated(
                address(uint160(uint256(PoolId.unwrap(poolId)))),
                newPrice
            );
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
            address(uint160(uint256(PoolId.unwrap(poolId)))),
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
        emit PriceUpdated(
            address(uint160(uint256(PoolId.unwrap(poolId)))),
            newPrice
        );
    }

    /// @notice Triggers callback to pause pool on destination chain
    function _pausePool(PoolId poolId, uint256 priceChange) internal {
        poolPaused[poolId] = true;

        // Prepare callback data
        bytes memory payload = abi.encodeWithSignature(
            "pausePool(bytes32,uint256)",
            PoolId.unwrap(poolId),
            priceChange
        );

        // Send callback to destination chain
        _sendCallback(payload);

        emit PoolPauseTriggered(
            address(uint160(uint256(PoolId.unwrap(poolId)))),
            priceChange
        );
    }

    /// @notice Triggers callback to resume pool on destination chain
    function _resumePool(PoolId poolId) internal {
        poolPaused[poolId] = false;

        // Prepare callback data
        bytes memory payload = abi.encodeWithSignature(
            "resumePool(bytes32)",
            PoolId.unwrap(poolId)
        );

        // Send callback to destination chain
        _sendCallback(payload);

        emit PoolResumeTriggered(
            address(uint160(uint256(PoolId.unwrap(poolId))))
        );
    }

    /// @notice Triggers callback to update pool fee based on volatility
    /// @dev Only triggers if volatility is significant but below pause threshold
    function _updateFee(PoolId poolId, uint256 priceChange) internal {
        // Only update if there's meaningful volatility (>1%)
        if (priceChange < 100) return;

        // Prepare callback data
        bytes memory payload = abi.encodeWithSignature(
            "updatePoolFee(bytes32,uint256)",
            PoolId.unwrap(poolId),
            priceChange
        );

        // Send callback to destination chain
        _sendCallback(payload);

        emit FeeUpdateTriggered(
            address(uint160(uint256(PoolId.unwrap(poolId)))),
            priceChange
        );
    }

    /// @notice Sends callback to destination chain via Reactive Network
    function _sendCallback(bytes memory payload) internal {
        // Call callback proxy to send transaction to destination chain
        (bool success, ) = CALLBACK_PROXY.call(
            abi.encodeWithSignature(
                "sendCallback(uint256,address,bytes)",
                DESTINATION_CHAIN_ID,
                corridorHook,
                payload
            )
        );

        if (!success) revert CallbackFailed();
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

    /// @notice Updates price oracle address and resubscribes
    /// @param _newOracle New oracle contract address
    function setPriceOracle(address _newOracle) external onlyOwner {
        if (_newOracle == address(0)) revert InvalidAddress();
        if (_newOracle == priceOracle) revert NoResubscriptionNeeded();
        priceOracle = _newOracle;
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

// ============ Interfaces ============

/// @notice Reactive Network system contract interface
interface IReactiveSystem {
    function subscribe(
        uint256 chainId,
        address _contract,
        uint256 topic0,
        uint256 topic1,
        uint256 topic2,
        uint256 topic3
    ) external;
}
