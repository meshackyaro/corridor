// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {CorridorReactive} from "../src/CorridorReactive.sol";

/// @title Deploy to Reactive Network
/// @notice Deploys CorridorReactive to Reactive Network (Lasna Testnet)
/// @dev This contract monitors Unichain and sends callbacks back
contract DeployToReactive is Script {
    // Reactive Network system contracts (same for all chains)
    address constant REACTIVE_SYSTEM_CONTRACT =
        0x0000000000000000000000000000000000fffFfF;

    // Callback Proxy for Unichain Sepolia on Reactive Network
    address constant CALLBACK_PROXY =
        0x9299472A6399Fd1027ebF067571Eb3e3D7837FC4;

    // Default parameters
    uint256 constant VOLATILITY_THRESHOLD = 500; // 5%

    function run() external {
        // These MUST be set from your Unichain deployment
        address corridorHook = vm.envAddress("CORRIDOR_HOOK");
        address priceOracle = vm.envAddress("PRICE_ORACLE");

        require(corridorHook != address(0), "Set CORRIDOR_HOOK in .env");
        require(priceOracle != address(0), "Set PRICE_ORACLE in .env");

        address deployer = msg.sender;

        console2.log("\n=== Deploying to Reactive Network (Lasna) ===");
        console2.log("Deployer:", deployer);
        console2.log("System Contract:", REACTIVE_SYSTEM_CONTRACT);
        console2.log("Callback Proxy:", CALLBACK_PROXY);
        console2.log("Target Hook (Unichain):", corridorHook);
        console2.log("Target Oracle (Unichain):", priceOracle);

        vm.startBroadcast();

        // Deploy Reactive Contract
        CorridorReactive reactive = new CorridorReactive(
            REACTIVE_SYSTEM_CONTRACT,
            CALLBACK_PROXY,
            corridorHook,
            priceOracle,
            VOLATILITY_THRESHOLD
        );

        console2.log("\nCorridorReactive deployed:", address(reactive));

        vm.stopBroadcast();

        console2.log("\n=== Reactive Deployment Complete ===");
        console2.log("Reactive Contract:", address(reactive));
        console2.log("\n>>> FINAL STEP <<<");
        console2.log("Connect Hook to Reactive on Unichain:");
        console2.log("  forge script script/ConnectContracts.s.sol \\");
        console2.log("    --rpc-url $UNICHAIN_SEPOLIA_RPC \\");
        console2.log("    --account deployer \\");
        console2.log("    --broadcast");
        console2.log("\nOr call manually:");
        console2.log("  hook.setReactiveContract(", address(reactive), ")");
    }
}
