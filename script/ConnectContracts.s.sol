// SPDX-License-Identifier: MIT
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {CorridorHook} from "../src/CorridorHook.sol";

/// @title Connect Contracts
/// @notice Final step: Connect CorridorHook to CorridorReactive
/// @dev Run this on Unichain after deploying Reactive contract
contract ConnectContracts is Script {
    function run() external {
        address corridorHook = vm.envAddress("CORRIDOR_HOOK");
        address reactiveContract = vm.envAddress("REACTIVE_CONTRACT");

        require(corridorHook != address(0), "Set CORRIDOR_HOOK in .env");
        require(
            reactiveContract != address(0),
            "Set REACTIVE_CONTRACT in .env"
        );

        console2.log("\n=== Connecting Contracts on Unichain ===");
        console2.log("Hook:", corridorHook);
        console2.log("Reactive:", reactiveContract);

        vm.startBroadcast();

        CorridorHook hook = CorridorHook(corridorHook);
        hook.setReactiveContract(reactiveContract);

        console2.log("\nHook connected to Reactive contract!");

        vm.stopBroadcast();

        console2.log("\n=== Setup Complete ===");
        console2.log("Your Corridor system is now live!");
        console2.log("\nArchitecture:");
        console2.log("  Unichain Sepolia:");
        console2.log("    - Hook:", corridorHook);
        console2.log("    - Oracle: (from previous deployment)");
        console2.log("  Reactive Network:");
        console2.log("    - Monitoring:", reactiveContract);
    }
}
