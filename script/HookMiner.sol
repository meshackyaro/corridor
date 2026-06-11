// SPDX-License-Identifier: MIT
pragma solidity ^0.8.26;

import {Hooks} from "v4-core/libraries/Hooks.sol";

/// @title HookMiner
/// @notice Minimal library for mining hook addresses
library HookMiner {
    uint160 constant FLAG_MASK = 0x3FFF; // bottom 14 bits
    uint256 constant MAX_LOOP = 160_444;

    /// @notice Find a salt that produces a hook address with the desired flags
    /// @param deployer The address that will deploy (CREATE2 deployer)
    /// @param flags The desired permission flags
    /// @param creationCode Hook contract creation code
    /// @param constructorArgs Encoded constructor arguments
    function find(
        address deployer,
        uint160 flags,
        bytes memory creationCode,
        bytes memory constructorArgs
    ) internal view returns (address, bytes32) {
        flags = flags & FLAG_MASK;
        bytes memory creationCodeWithArgs = abi.encodePacked(
            creationCode,
            constructorArgs
        );

        address hookAddress;
        for (uint256 salt; salt < MAX_LOOP; salt++) {
            hookAddress = computeAddress(deployer, salt, creationCodeWithArgs);

            if (
                uint160(hookAddress) & FLAG_MASK == flags &&
                hookAddress.code.length == 0
            ) {
                return (hookAddress, bytes32(salt));
            }
        }
        revert("HookMiner: could not find salt");
    }

    function computeAddress(
        address deployer,
        uint256 salt,
        bytes memory creationCodeWithArgs
    ) internal pure returns (address) {
        return
            address(
                uint160(
                    uint256(
                        keccak256(
                            abi.encodePacked(
                                bytes1(0xFF),
                                deployer,
                                salt,
                                keccak256(creationCodeWithArgs)
                            )
                        )
                    )
                )
            );
    }
}
