// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {CorridorReactive} from "../src/CorridorReactive.sol";

/// @title Deploy to Reactive Network
/// @notice Deploys CorridorReactive to Reactive Network (Lasna Testnet)
/// @dev This contract monitors Unichain and sends callbacks back
contract DeployToReactive is Script {
    // Default parameters
    uint256 constant VOLATILITY_THRESHOLD = 500; // 5%
    uint256 constant RSC_REACT_FUND = 0.5 ether; // Fund RSC with 0.5 REACT for subscriptions

    function run() external {
        // These MUST be set from your Unichain deployment
        address corridorHook = vm.envAddress("CORRIDOR_HOOK");
        address priceOracle = vm.envAddress("PRICE_ORACLE");

        require(corridorHook != address(0), "Set CORRIDOR_HOOK in .env");
        require(priceOracle != address(0), "Set PRICE_ORACLE in .env");

        address deployer = msg.sender;

        console2.log("\n=== Deploying to Reactive Network (Lasna) ===");
        console2.log("Deployer:", deployer);
        console2.log("Target Hook (Unichain):", corridorHook);
        console2.log("Target Oracle (Unichain):", priceOracle);
        console2.log("RSC Funding:", RSC_REACT_FUND / 1 ether, "REACT");

        vm.startBroadcast();

        // Deploy Reactive Contract with REACT funding for subscriptions
        CorridorReactive reactive = new CorridorReactive{value: RSC_REACT_FUND}(
            corridorHook,
            priceOracle,
            VOLATILITY_THRESHOLD
        );

        console2.log("\nCorridorReactive deployed:", address(reactive));

        vm.stopBroadcast();

        console2.log("\n=== Reactive Deployment Complete ===");
        console2.log("Reactive Contract:", address(reactive));
        console2.log("\n>>> FINAL STEP <<<");
        console2.log("Connect Hook to Callback Proxy on Unichain:");
        console2.log("  forge script script/ConnectContracts.s.sol \\");
        console2.log("    --rpc-url unichain_sepolia \\");
        console2.log("    --account deployer \\");
        console2.log("    --broadcast");
        console2.log("\nSet reactiveCallbackProxy to:");
        console2.log(
            "  0x9299472A6399Fd1027ebF067571Eb3e3D7837FC4 (Callback Proxy on Unichain)"
        );
    }
}
