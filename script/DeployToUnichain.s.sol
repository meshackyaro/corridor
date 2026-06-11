// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {CorridorHook} from "../src/CorridorHook.sol";
import {MockPriceOracle} from "../src/mocks/MockPriceOracle.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {Hooks} from "v4-core/libraries/Hooks.sol";
import {HookMiner} from "./HookMiner.sol";

/// @title Deploy to Unichain Sepolia
/// @notice Deploys Hook and Oracle to Unichain Sepolia with CREATE2 mining
contract DeployToUnichain is Script {
    // Unichain Sepolia PoolManager
    address constant POOL_MANAGER = 0x00B036B58a818B1BC34d502D3fE730Db729e62AC;

    // CREATE2 Deployer (canonical deterministic deployer)
    address constant CREATE2_DEPLOYER =
        0x4e59b44847b379578588920cA78FbF26c0B4956C;

    // Default parameters
    uint256 constant VOLATILITY_THRESHOLD = 500; // 5%

    function run() external {
        address deployer = msg.sender;
        address governance = vm.envOr("GOVERNANCE_ADDRESS", deployer);

        console2.log("\n=== Deploying to Unichain Sepolia ===");
        console2.log("Deployer:", deployer);
        console2.log("Governance:", governance);
        console2.log("Pool Manager:", POOL_MANAGER);

        // Calculate hook permissions flags
        // beforeSwap is required for pause check + dynamic fees
        uint160 flags = uint160(
            Hooks.BEFORE_SWAP_FLAG | Hooks.BEFORE_INITIALIZE_FLAG
        );

        console2.log("\n>>> Mining hook address with CREATE2...");
        console2.log("Required flags:", flags);

        // Prepare constructor arguments
        bytes memory constructorArgs = abi.encode(
            IPoolManager(POOL_MANAGER),
            governance,
            VOLATILITY_THRESHOLD
        );

        // Mine salt for valid hook address
        (address hookAddress, bytes32 salt) = HookMiner.find(
            CREATE2_DEPLOYER,
            flags,
            type(CorridorHook).creationCode,
            constructorArgs
        );

        console2.log("Mined hook address:", hookAddress);
        console2.log("Salt:", uint256(salt));

        vm.startBroadcast();

        // 1. Deploy Mock Price Oracle
        MockPriceOracle priceOracle = new MockPriceOracle();
        console2.log("\n1. MockPriceOracle deployed:", address(priceOracle));

        // 2. Deploy Corridor Hook with CREATE2
        CorridorHook hook = new CorridorHook{salt: salt}(
            IPoolManager(POOL_MANAGER),
            governance,
            VOLATILITY_THRESHOLD
        );

        require(address(hook) == hookAddress, "Hook address mismatch");
        console2.log("2. CorridorHook deployed:", address(hook));

        vm.stopBroadcast();

        console2.log("\n=== Unichain Deployment Complete ===");
        console2.log("Hook Address:", address(hook));
        console2.log("Oracle Address:", address(priceOracle));
        console2.log("\n>>> SAVE THESE TO .env <<<");
        console2.log(
            "CORRIDOR_HOOK=",
            vm.toLowercase(vm.toString(address(hook)))
        );
        console2.log(
            "PRICE_ORACLE=",
            vm.toLowercase(vm.toString(address(priceOracle)))
        );
        console2.log("\nNext: Deploy to Reactive Network");
    }
}
