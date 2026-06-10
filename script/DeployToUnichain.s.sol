// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {CorridorHook} from "../src/CorridorHook.sol";
import {MockPriceOracle} from "../src/mocks/MockPriceOracle.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";

/// @title Deploy to Unichain Sepolia
/// @notice Deploys Hook and Oracle to Unichain Sepolia (Origin/Destination Chain)
contract DeployToUnichain is Script {
    // Unichain Sepolia PoolManager
    address constant POOL_MANAGER = 0x00B036B58a818B1BC34d502D3fE730Db729e62AC;

    // Default parameters
    uint256 constant VOLATILITY_THRESHOLD = 500; // 5%

    function run() external {
        address deployer = msg.sender;
        address governance = vm.envOr("GOVERNANCE_ADDRESS", deployer);

        console2.log("\n=== Deploying to Unichain Sepolia ===");
        console2.log("Deployer:", deployer);
        console2.log("Governance:", governance);
        console2.log("Pool Manager:", POOL_MANAGER);

        vm.startBroadcast();

        // 1. Deploy Mock Price Oracle
        MockPriceOracle priceOracle = new MockPriceOracle();
        console2.log("\n1. MockPriceOracle deployed:", address(priceOracle));

        // 2. Deploy Corridor Hook
        CorridorHook hook = new CorridorHook(
            IPoolManager(POOL_MANAGER),
            governance,
            VOLATILITY_THRESHOLD
        );
        console2.log("2. CorridorHook deployed:", address(hook));

        vm.stopBroadcast();

        console2.log("\n=== Unichain Deployment Complete ===");
        console2.log("Hook Address:", address(hook));
        console2.log("Oracle Address:", address(priceOracle));
        console2.log("\n>>> SAVE THESE ADDRESSES <<<");
        console2.log("You'll need them for Reactive Network deployment!");
        console2.log("\nNext Step:");
        console2.log("Deploy to Reactive Network with:");
        console2.log("  CORRIDOR_HOOK=", address(hook));
        console2.log("  PRICE_ORACLE=", address(priceOracle));
    }
}
