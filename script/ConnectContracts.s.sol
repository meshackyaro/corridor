// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {CorridorHook} from "../src/CorridorHook.sol";

/// @title Connect Contracts
/// @notice Final step: Connect CorridorHook to Reactive Callback Proxy
/// @dev Run this on Unichain to authorize the Callback Proxy
contract ConnectContracts is Script {
    // Callback Proxy for Unichain Sepolia (on Unichain, not Lasna)
    address constant CALLBACK_PROXY =
        0x9299472A6399Fd1027ebF067571Eb3e3D7837FC4;

    function run() external {
        address corridorHook = vm.envAddress("CORRIDOR_HOOK");

        require(corridorHook != address(0), "Set CORRIDOR_HOOK in .env");

        console2.log("\n=== Connecting Hook to Callback Proxy on Unichain ===");
        console2.log("Hook:", corridorHook);
        console2.log("Callback Proxy:", CALLBACK_PROXY);

        vm.startBroadcast();

        CorridorHook hook = CorridorHook(corridorHook);
        hook.setReactiveContract(CALLBACK_PROXY);

        console2.log("\nHook authorized Callback Proxy!");

        vm.stopBroadcast();

        console2.log("\n=== Setup Complete ===");
        console2.log("Your Corridor system is now live!");
        console2.log("\nArchitecture:");
        console2.log("  Unichain Sepolia:");
        console2.log("    - Hook:", corridorHook);
        console2.log("    - Authorized Proxy:", CALLBACK_PROXY);
        console2.log("  Reactive Network (Lasna):");
        console2.log("    - Monitoring contract emits callbacks");
        console2.log("    - Callback Proxy executes them on Unichain");
    }
}
