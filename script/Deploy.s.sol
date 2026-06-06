// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {CorridorHook} from "../src/CorridorHook.sol";
import {CorridorReactive} from "../src/CorridorReactive.sol";
import {MockPriceOracle} from "../src/mocks/MockPriceOracle.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";

/// @title Deploy Corridor Hook
/// @notice Deployment script for Corridor remittance infrastructure
contract DeployCorridorHook is Script {
    // Unichain Sepolia addresses
    address constant POOL_MANAGER = 0x00b036b58a818b1bc34d502d3fe730db729e62ac; // v4 PoolManager on Unichain Sepolia

    // Reactive Network Lasna Testnet addresses
    // The Reactive contract will be deployed on Reactive Lasna and interact with Unichain Sepolia
    address constant REACTIVE_SYSTEM_CONTRACT =
        0x0000000000000000000000000000000000fffFfF; // System Contract (same for mainnet/testnet)
    address constant REACTIVE_CALLBACK_PROXY =
        0x9299472A6399Fd1027ebF067571Eb3e3D7837FC4; // Callback Proxy for Unichain Sepolia

    // Default parameters
    uint256 constant VOLATILITY_THRESHOLD = 500; // 5%

    function run() external {
        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address governance = vm.envOr("GOVERNANCE_ADDRESS", deployer);

        console2.log("Deploying Corridor Hook...");
        console2.log("Deployer:", deployer);
        console2.log("Governance:", governance);
        console2.log("Pool Manager:", POOL_MANAGER);

        vm.startBroadcast(deployerPrivateKey);

        // 1. Deploy Mock Price Oracle (for testing)
        MockPriceOracle priceOracle = new MockPriceOracle();
        console2.log("MockPriceOracle deployed at:", address(priceOracle));

        // 2. Deploy Corridor Hook
        CorridorHook hook = new CorridorHook(
            IPoolManager(POOL_MANAGER),
            governance,
            VOLATILITY_THRESHOLD
        );
        console2.log("CorridorHook deployed at:", address(hook));

        // 3. Deploy Reactive Contract (if addresses are set)
        if (
            REACTIVE_SYSTEM_CONTRACT != address(0) &&
            REACTIVE_CALLBACK_PROXY != address(0)
        ) {
            CorridorReactive reactive = new CorridorReactive(
                REACTIVE_SYSTEM_CONTRACT,
                REACTIVE_CALLBACK_PROXY,
                address(hook),
                address(priceOracle),
                VOLATILITY_THRESHOLD
            );
            console2.log("CorridorReactive deployed at:", address(reactive));

            // 4. Connect hook to reactive contract
            hook.setReactiveContract(address(reactive));
            console2.log("Hook connected to Reactive contract");
        } else {
            console2.log(
                "Skipping Reactive deployment - update addresses in script"
            );
        }

        vm.stopBroadcast();

        console2.log("\n=== Deployment Summary ===");
        console2.log("Hook Address:", address(hook));
        console2.log("Oracle Address:", address(priceOracle));
        console2.log("Governance:", governance);
        console2.log("Volatility Threshold:", VOLATILITY_THRESHOLD, "bps");
        console2.log("Base Fee:", hook.baseFee(), "bps");
        console2.log("Max Fee:", hook.maxVolatilityFee(), "bps");
        console2.log("\nNext steps:");
        console2.log("1. Initialize pool with this hook address");
        console2.log("2. Set up price oracle feeds");
        console2.log("3. Configure Reactive Network subscriptions");
        console2.log("4. Test with small transactions");
    }
}

/// @title Deploy to Unichain Mainnet
/// @notice Production deployment script for post-hookathon mainnet launch
/// @dev Addresses are placeholders - to be updated before mainnet deployment
contract DeployMainnet is Script {
    // Unichain Mainnet addresses
    address constant POOL_MANAGER = 0x1f98400000000000000000000000000000000004; // v4 PoolManager on Unichain Mainnet
    address constant CHAINLINK_NGN_USD = address(0); // TODO: Update with Chainlink feed

    // Reactive Network mainnet addresses
    address constant REACTIVE_SYSTEM_CONTRACT =
        0x0000000000000000000000000000000000fffFfF; // System Contract
    address constant REACTIVE_CALLBACK_PROXY = address(0); // TODO: Update with Unichain Mainnet callback proxy

    uint256 constant VOLATILITY_THRESHOLD = 500; // 5%

    function run() external {
        require(POOL_MANAGER != address(0), "Update POOL_MANAGER address");
        require(CHAINLINK_NGN_USD != address(0), "Update oracle address");
        require(
            REACTIVE_SYSTEM_CONTRACT != address(0),
            "Update Reactive addresses"
        );

        uint256 deployerPrivateKey = vm.envUint("PRIVATE_KEY");
        address deployer = vm.addr(deployerPrivateKey);
        address governance = vm.envAddress("GOVERNANCE_ADDRESS");

        require(governance != address(0), "Set GOVERNANCE_ADDRESS");
        require(governance != deployer, "Use multisig for governance");

        console2.log("=== MAINNET DEPLOYMENT ===");
        console2.log("Deployer:", deployer);
        console2.log("Governance:", governance);

        vm.startBroadcast(deployerPrivateKey);

        // Deploy Hook
        CorridorHook hook = new CorridorHook(
            IPoolManager(POOL_MANAGER),
            governance,
            VOLATILITY_THRESHOLD
        );

        // Deploy Reactive
        CorridorReactive reactive = new CorridorReactive(
            REACTIVE_SYSTEM_CONTRACT,
            REACTIVE_CALLBACK_PROXY,
            address(hook),
            CHAINLINK_NGN_USD,
            VOLATILITY_THRESHOLD
        );

        // Connect (governance will need to call this)
        // hook.setReactiveContract(address(reactive));

        vm.stopBroadcast();

        console2.log("\n=== DEPLOYMENT COMPLETE ===");
        console2.log("CorridorHook:", address(hook));
        console2.log("CorridorReactive:", address(reactive));
        console2.log("\nIMPORTANT: Governance must call:");
        console2.log("hook.setReactiveContract(", address(reactive), ")");
    }
}
