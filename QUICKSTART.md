# Corridor Quick Start Guide

Get Corridor running in 5 minutes.

## Prerequisites

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup

# Verify installation
forge --version
```

## Installation

```bash
# Clone repository
git clone <repository-url>
cd corridor

# Install dependencies
forge install

# Build contracts
forge build
```

## Run Tests

```bash
# Run all tests
forge test

# Run with gas report
forge test --gas-report

# Run with detailed output
forge test -vvv

# Run specific test
forge test --match-test test_UpdatePoolFee_LowVolatility
```

Expected output:

```
Ran 16 tests for test/CorridorHook.t.sol:CorridorHookTest
[PASS] test_BeforeSwap_ReturnsDynamicFee()
[PASS] test_BeforeSwap_RevertWhenPaused()
[PASS] test_CommunityLPTracking()
[PASS] test_Constructor()
[PASS] test_PausePool()
[PASS] test_ResumePool()
[PASS] test_SetFeeParameters()
[PASS] test_SetFeeParameters_RevertInvalid()
[PASS] test_SetReactiveContract()
[PASS] test_SetReactiveContract_RevertUnauthorized()
[PASS] test_SetVolatilityThreshold()
[PASS] test_SetVolatilityThreshold_RevertInvalid()
[PASS] test_TransferGovernance()
[PASS] test_TransferGovernance_RevertUnauthorized()
[PASS] test_UpdatePoolFee_HighVolatility()
[PASS] test_UpdatePoolFee_LowVolatility()

Suite result: ok. 16 passed; 0 failed; 0 skipped
```

## Deploy to Testnet

### 1. Set Environment Variables

```bash
# Create .env file
cat > .env << EOF
PRIVATE_KEY=your_private_key_here
BASE_SEPOLIA_RPC=https://sepolia.base.org
GOVERNANCE_ADDRESS=your_governance_address
EOF

# Load environment
source .env
```

### 2. Get Testnet Tokens

Visit Base Sepolia faucet:

- https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet

### 3. Deploy Contracts

```bash
# Deploy to Base Sepolia
forge script script/Deploy.s.sol:DeployCorridorHook \
    --rpc-url $BASE_SEPOLIA_RPC \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify

# Save deployed addresses
# Hook: 0x...
# Oracle: 0x...
# Reactive: 0x... (if deployed)
```

## Interact with Contracts

### Using Cast

```bash
# Set contract addresses
HOOK=0x... # Your deployed hook address
ORACLE=0x... # Your deployed oracle address

# Check hook configuration
cast call $HOOK "volatilityThreshold()" --rpc-url $BASE_SEPOLIA_RPC
cast call $HOOK "baseFee()" --rpc-url $BASE_SEPOLIA_RPC
cast call $HOOK "maxVolatilityFee()" --rpc-url $BASE_SEPOLIA_RPC

# Set up price oracle (for testing)
POOL_ID=0x... # Your pool ID
cast send $ORACLE "updatePrice(bytes32,uint256)" \
    $POOL_ID 165000000000 \
    --private-key $PRIVATE_KEY \
    --rpc-url $BASE_SEPOLIA_RPC

# Simulate volatility
cast send $ORACLE "simulateVolatility(bytes32,uint256,bool)" \
    $POOL_ID 800 true \
    --private-key $PRIVATE_KEY \
    --rpc-url $BASE_SEPOLIA_RPC

# Check if pool is paused
cast call $HOOK "poolPaused(bytes32)" $POOL_ID \
    --rpc-url $BASE_SEPOLIA_RPC
```

### Using Foundry Scripts

```solidity
// script/Interact.s.sol
pragma solidity ^0.8.24;

import {Script} from "forge-std/Script.sol";
import {CorridorHook} from "../src/CorridorHook.sol";

contract InteractScript is Script {
    function run() external {
        address hookAddress = vm.envAddress("HOOK_ADDRESS");
        CorridorHook hook = CorridorHook(hookAddress);

        vm.startBroadcast();

        // Check configuration
        uint256 threshold = hook.volatilityThreshold();
        console.log("Volatility Threshold:", threshold);

        vm.stopBroadcast();
    }
}
```

## Monitor Events

### Watch for Volatility Events

```bash
# Terminal 1: Watch Reactive contract
cast logs --address $REACTIVE \
    --event "VolatilityDetected(address,uint256,uint256)" \
    --rpc-url $REACTIVE_RPC \
    --follow

# Terminal 2: Watch Hook contract
cast logs --address $HOOK \
    --event "PoolPausedByVolatility(bytes32,uint256)" \
    --rpc-url $BASE_SEPOLIA_RPC \
    --follow

# Terminal 3: Watch fee updates
cast logs --address $HOOK \
    --event "DynamicFeeUpdated(bytes32,uint24)" \
    --rpc-url $BASE_SEPOLIA_RPC \
    --follow
```

## Common Tasks

### Update Volatility Threshold

```bash
# As governance
NEW_THRESHOLD=1000 # 10%

cast send $HOOK "setVolatilityThreshold(uint256)" \
    $NEW_THRESHOLD \
    --private-key $GOVERNANCE_PRIVATE_KEY \
    --rpc-url $BASE_SEPOLIA_RPC
```

### Update Fee Parameters

```bash
# As governance
BASE_FEE=50 # 0.5%
MAX_FEE=150 # 1.5%

cast send $HOOK "setFeeParameters(uint24,uint24)" \
    $BASE_FEE $MAX_FEE \
    --private-key $GOVERNANCE_PRIVATE_KEY \
    --rpc-url $BASE_SEPOLIA_RPC
```

### Connect Reactive Contract

```bash
# As governance
REACTIVE_ADDRESS=0x...

cast send $HOOK "setReactiveContract(address)" \
    $REACTIVE_ADDRESS \
    --private-key $GOVERNANCE_PRIVATE_KEY \
    --rpc-url $BASE_SEPOLIA_RPC
```

### Manual Pool Pause (Emergency)

```bash
# As governance
POOL_ID=0x...

cast send $HOOK "pausePool(bytes32,uint256)" \
    $POOL_ID 0 \
    --private-key $GOVERNANCE_PRIVATE_KEY \
    --rpc-url $BASE_SEPOLIA_RPC
```

### Resume Pool

```bash
# As governance
cast send $HOOK "resumePool(bytes32)" \
    $POOL_ID \
    --private-key $GOVERNANCE_PRIVATE_KEY \
    --rpc-url $BASE_SEPOLIA_RPC
```

## Troubleshooting

### Build Fails

```bash
# Clean and rebuild
forge clean
forge build

# Update dependencies
forge update
```

### Tests Fail

```bash
# Run with verbose output
forge test -vvvv

# Check specific test
forge test --match-test test_Constructor -vvvv
```

### Deployment Fails

```bash
# Check RPC connection
cast block-number --rpc-url $BASE_SEPOLIA_RPC

# Check balance
cast balance $YOUR_ADDRESS --rpc-url $BASE_SEPOLIA_RPC

# Verify private key
cast wallet address --private-key $PRIVATE_KEY
```

### Transaction Reverts

```bash
# Simulate transaction first
cast call $HOOK "pausePool(bytes32,uint256)" \
    $POOL_ID 0 \
    --from $YOUR_ADDRESS \
    --rpc-url $BASE_SEPOLIA_RPC

# Check error message
forge script script/Debug.s.sol --rpc-url $BASE_SEPOLIA_RPC
```

## Development Workflow

### 1. Make Changes

```bash
# Edit contracts
vim src/CorridorHook.sol

# Build
forge build
```

### 2. Test Changes

```bash
# Run tests
forge test

# Check gas impact
forge test --gas-report
```

### 3. Deploy Updates

```bash
# Deploy new version
forge script script/Deploy.s.sol:DeployCorridorHook \
    --rpc-url $BASE_SEPOLIA_RPC \
    --broadcast

# Update governance
# Transfer to new contract if needed
```

## Next Steps

1. **Read Documentation**
   - [README.md](README.md) - Project overview
   - [ARCHITECTURE.md](ARCHITECTURE.md) - Technical details
   - [DEMO.md](DEMO.md) - Usage scenarios

2. **Explore Code**
   - `src/CorridorHook.sol` - Main hook logic
   - `src/CorridorReactive.sol` - Reactive automation
   - `test/CorridorHook.t.sol` - Test suite

3. **Join Community**
   - Discord: [Link]
   - Twitter: [Link]
   - GitHub: [Link]

## Useful Commands Reference

```bash
# Build
forge build

# Test
forge test
forge test -vvv
forge test --gas-report
forge test --match-test <test_name>

# Deploy
forge script script/Deploy.s.sol --broadcast

# Interact
cast call <address> "<function>" --rpc-url <rpc>
cast send <address> "<function>" --private-key <key> --rpc-url <rpc>

# Monitor
cast logs --address <address> --event "<event>" --rpc-url <rpc> --follow

# Debug
forge test --debug <test_name>
cast run <tx_hash> --rpc-url <rpc>

# Format
forge fmt

# Coverage
forge coverage
```

## Support

Need help?

- Open an issue on GitHub
- Join our Discord
- Check documentation

---

**Happy Building! 🚀**
