// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Script} from "forge-std/Script.sol";
import {console2} from "forge-std/console2.sol";
import {IPoolManager} from "v4-core/interfaces/IPoolManager.sol";
import {PoolKey} from "v4-core/types/PoolKey.sol";
import {PoolId, PoolIdLibrary} from "v4-core/types/PoolId.sol";
import {Currency} from "v4-core/types/Currency.sol";
import {IHooks} from "v4-core/interfaces/IHooks.sol";
import {LPFeeLibrary} from "v4-core/libraries/LPFeeLibrary.sol";

/// @title Create Pool
/// @notice Initializes a Uniswap v4 pool with the Corridor hook
contract CreatePool is Script {
    using PoolIdLibrary for PoolKey;

    // Unichain Sepolia PoolManager
    address constant POOL_MANAGER = 0x00B036B58a818B1BC34d502D3fE730Db729e62AC;

    // Example tokens - replace with actual USD/NGN token addresses
    address constant TOKEN0 = 0x1c7D4B196Cb0C7B01d743Fbc6116a902379C7238; // USDC on Unichain Sepolia
    address constant TOKEN1 = 0x0000000000000000000000000000000000000001; // Placeholder NGN

    function run() external {
        address corridorHook = vm.envAddress("CORRIDOR_HOOK");
        require(corridorHook != address(0), "Set CORRIDOR_HOOK in .env");

        console2.log("\n=== Creating Pool on Unichain ===");
        console2.log("Pool Manager:", POOL_MANAGER);
        console2.log("Hook:", corridorHook);
        console2.log("Token0:", TOKEN0);
        console2.log("Token1:", TOKEN1);

        // Ensure token0 < token1 (Uniswap v4 requirement)
        (Currency currency0, Currency currency1) = TOKEN0 < TOKEN1
            ? (Currency.wrap(TOKEN0), Currency.wrap(TOKEN1))
            : (Currency.wrap(TOKEN1), Currency.wrap(TOKEN0));

        // Create pool key with dynamic fee flag
        PoolKey memory key = PoolKey({
            currency0: currency0,
            currency1: currency1,
            fee: LPFeeLibrary.DYNAMIC_FEE_FLAG, // 0x800000 - enables dynamic fees
            tickSpacing: 60,
            hooks: IHooks(corridorHook)
        });

        // Calculate pool ID
        PoolId poolId = key.toId();

        console2.log("\nPool Configuration:");
        console2.log("Currency0:", Currency.unwrap(currency0));
        console2.log("Currency1:", Currency.unwrap(currency1));
        console2.log("Fee: DYNAMIC_FEE_FLAG");
        console2.log("Tick Spacing:", key.tickSpacing);
        console2.log("\n>>> POOL ID (save this!) <<<");
        console2.log(vm.toString(PoolId.unwrap(poolId)));

        // Initial price: 1:1 ratio (sqrtPriceX96 = sqrt(1) * 2^96)
        uint160 sqrtPriceX96 = 79228162514264337593543950336;

        vm.startBroadcast();

        // Initialize the pool
        IPoolManager(POOL_MANAGER).initialize(key, sqrtPriceX96);

        console2.log("\nPool initialized successfully!");

        vm.stopBroadcast();

        console2.log("\n=== Pool Creation Complete ===");
        console2.log("\n>>> UPDATE .env AND price-updater/.env <<<");
        console2.log("POOL_ID=", vm.toString(PoolId.unwrap(poolId)));
        console2.log("\nNext: Start price-updater service");
    }
}
