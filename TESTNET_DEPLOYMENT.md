# Corridor Testnet Deployment Guide

## Complete Guide for Base Sepolia Deployment

**Target:** Base Sepolia Testnet  
**Timeline:** 2-3 hours for complete deployment and testing  
**Prerequisites:** Foundry, Git, Base Sepolia ETH

---

## Table of Contents

1. [Pre-Deployment Checklist](#pre-deployment-checklist)
2. [Environment Setup](#environment-setup)
3. [Get Testnet Funds](#get-testnet-funds)
4. [Deploy Contracts](#deploy-contracts)
5. [Verify Contracts](#verify-contracts)
6. [Initialize & Test](#initialize--test)
7. [Document Addresses](#document-addresses)
8. [Troubleshooting](#troubleshooting)

---

## Pre-Deployment Checklist

### ✅ Before You Start

- [ ] Foundry installed and updated (`foundryup`)
- [ ] Git repository up to date
- [ ] Wallet with testnet ETH (at least 0.5 ETH on Base Sepolia)
- [ ] Basescan API key (for verification)
- [ ] Text editor ready for addresses

### ✅ System Check

```bash
# Verify Foundry installation
forge --version
cast --version

# Verify you're in project directory
pwd  # Should show: .../corridor

# Verify contracts compile
forge build

# Verify tests pass
forge test
```

**Expected Output:**

```
Compiler run successful
16 tests passed
```

---

## Environment Setup

### Step 1: Create Environment File

```bash
# Create .env file
cat > .env << 'EOF'
# Deployment Configuration
PRIVATE_KEY=your_private_key_here_without_0x
GOVERNANCE_ADDRESS=your_governance_address_here

# RPC URLs
BASE_SEPOLIA_RPC=https://sepolia.base.org

# Block Explorer
BASESCAN_API_KEY=your_basescan_api_key

# Contract Addresses (will be filled after deployment)
CORRIDOR_HOOK=
MOCK_ORACLE=
CORRIDOR_REACTIVE=
EOF
```

### Step 2: Get Your Private Key

**⚠️ SECURITY WARNING:** Use a testnet-only wallet!

```bash
# If you have MetaMask:
# 1. Account Details → Show Private Key
# 2. Copy without '0x' prefix

# Or create new wallet with cast:
cast wallet new

# Save the private key and address
```

### Step 3: Get Basescan API Key

1. Visit: https://basescan.org/
2. Sign up for free account
3. API Keys → Create New Key
4. Copy API key to .env file

### Step 4: Set Governance Address

```bash
# Use your deployment wallet address as governance
# Or use a separate governance address

# Get your address from private key:
cast wallet address --private-key $PRIVATE_KEY
```

### Step 5: Load Environment

```bash
# Load variables
source .env

# Verify (should NOT show your actual key)
echo "RPC: $BASE_SEPOLIA_RPC"
echo "Governance: $GOVERNANCE_ADDRESS"
```

---

## Get Testnet Funds

### Option 1: Official Base Faucet (Recommended)

1. Visit: https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet
2. Connect your wallet
3. Request testnet ETH
4. Wait 1-2 minutes

### Option 2: Sepolia ETH Bridge

If you have Sepolia ETH:

1. Visit: https://bridge.base.org/deposit
2. Select Sepolia → Base Sepolia
3. Bridge your ETH

### Verify Balance

```bash
# Check your balance
cast balance $GOVERNANCE_ADDRESS --rpc-url $BASE_SEPOLIA_RPC

# Should show: at least 500000000000000000 (0.5 ETH)
```

---

## Deploy Contracts

### Step 1: Review Deployment Script

```bash
# View the deployment script
cat script/Deploy.s.sol | head -50
```

### Step 2: Dry Run (Simulation)

```bash
# Simulate deployment (no actual transaction)
forge script script/Deploy.s.sol:DeployCorridorHook \
    --rpc-url $BASE_SEPOLIA_RPC \
    --private-key $PRIVATE_KEY \
    --sender $GOVERNANCE_ADDRESS

# Review output for any errors
```

**Expected Output:**

```
Script ran successfully.
Gas used: ~3,000,000
```

### Step 3: Actual Deployment

```bash
# Deploy contracts
forge script script/Deploy.s.sol:DeployCorridorHook \
    --rpc-url $BASE_SEPOLIA_RPC \
    --private-key $PRIVATE_KEY \
    --broadcast \
    --verify \
    --etherscan-api-key $BASESCAN_API_KEY \
    -vvvv

# This will:
# 1. Deploy MockPriceOracle
# 2. Deploy CorridorHook
# 3. Automatically verify contracts on Basescan
```

**⏰ Expected Time:** 2-5 minutes

**Expected Output:**

```
✅ [Success] Hash: 0x...
Contract deployed to: 0x...
Beginning contract verification...
Submitting verification for [CorridorHook] 0x...
Submitted contract for verification:
        Response: `OK`
        GUID: `abc123...`
Contract verification status:
Response: `OK`
```

### Step 4: Save Deployment Addresses

The script will output addresses. Save them:

```bash
# Example output format:
# MockPriceOracle deployed at: 0x1234...
# CorridorHook deployed at: 0x5678...

# Update your .env file
cat >> .env << EOF

# Deployed Contract Addresses
CORRIDOR_HOOK=0x5678...  # Replace with actual address
MOCK_ORACLE=0x1234...    # Replace with actual address
EOF

# Reload environment
source .env
```

### Step 5: Verify Deployment Success

```bash
# Check if contracts exist
cast code $CORRIDOR_HOOK --rpc-url $BASE_SEPOLIA_RPC | wc -c
# Should show a large number (contract bytecode length)

# Check hook configuration
cast call $CORRIDOR_HOOK "communityGovernance()" --rpc-url $BASE_SEPOLIA_RPC
# Should return your governance address

cast call $CORRIDOR_HOOK "volatilityThreshold()" --rpc-url $BASE_SEPOLIA_RPC
# Should return: 500 (0x01f4 in hex)

cast call $CORRIDOR_HOOK "baseFee()" --rpc-url $BASE_SEPOLIA_RPC
# Should return: 30

cast call $CORRIDOR_HOOK "maxVolatilityFee()" --rpc-url $BASE_SEPOLIA_RPC
# Should return: 100
```

---

## Verify Contracts

### Automatic Verification

If `--verify` flag worked during deployment, your contracts are already verified!

Check at: `https://sepolia.basescan.org/address/YOUR_CONTRACT_ADDRESS`

### Manual Verification (If Needed)

```bash
# Verify CorridorHook
forge verify-contract \
    $CORRIDOR_HOOK \
    src/CorridorHook.sol:CorridorHook \
    --chain-id 84532 \
    --etherscan-api-key $BASESCAN_API_KEY \
    --constructor-args $(cast abi-encode "constructor(address,address,uint256)" \
        "0x8C4BcBE6b9eF47855f97E675296FA3F6fafa5F1A" \
        $GOVERNANCE_ADDRESS \
        500)

# Verify MockPriceOracle
forge verify-contract \
    $MOCK_ORACLE \
    src/mocks/MockPriceOracle.sol:MockPriceOracle \
    --chain-id 84532 \
    --etherscan-api-key $BASESCAN_API_KEY
```

### Verify on Basescan

1. Visit: `https://sepolia.basescan.org/address/$CORRIDOR_HOOK`
2. Check for green ✅ "Contract Source Code Verified"
3. Review the Contract tab to see source code

---

## Initialize & Test

### Step 1: Initialize Mock Oracle

```bash
# Create a test pool ID (32 bytes)
POOL_ID="0x0000000000000000000000000000000000000000000000000000000000000001"

# Set initial NGN/USD price (1650 NGN per USD, 8 decimals)
INITIAL_PRICE=165000000000  # 1650.00000000

# Initialize price
cast send $MOCK_ORACLE \
    "updatePrice(bytes32,uint256)" \
    $POOL_ID \
    $INITIAL_PRICE \
    --private-key $PRIVATE_KEY \
    --rpc-url $BASE_SEPOLIA_RPC

# Verify price was set
cast call $MOCK_ORACLE \
    "getPrice(bytes32)" \
    $POOL_ID \
    --rpc-url $BASE_SEPOLIA_RPC
# Should return: 165000000000
```

### Step 2: Test Dynamic Fee Mechanism

```bash
# Check initial dynamic fee for pool
cast call $CORRIDOR_HOOK \
    "poolDynamicFee(bytes32)" \
    $POOL_ID \
    --rpc-url $BASE_SEPOLIA_RPC
# Should return: 0 (not initialized yet)

# Note: Dynamic fee gets set when pool is initialized via PoolManager
# For hackathon demo, we'll show the calculation works
```

### Step 3: Test Volatility Simulation

```bash
# Simulate 8% volatility (800 basis points)
cast send $MOCK_ORACLE \
    "simulateVolatility(bytes32,uint256,bool)" \
    $POOL_ID \
    800 \
    false \
    --private-key $PRIVATE_KEY \
    --rpc-url $BASE_SEPOLIA_RPC

# Check new price
cast call $MOCK_ORACLE \
    "getPrice(bytes32)" \
    $POOL_ID \
    --rpc-url $BASE_SEPOLIA_RPC
# Should show reduced price (8% less than 165000000000)
```

### Step 4: Test Pause Functionality

```bash
# Manually pause pool (simulate Reactive Network trigger)
cast send $CORRIDOR_HOOK \
    "pausePool(bytes32,uint256)" \
    $POOL_ID \
    800 \
    --private-key $PRIVATE_KEY \
    --rpc-url $BASE_SEPOLIA_RPC

# Verify pool is paused
cast call $CORRIDOR_HOOK \
    "poolPaused(bytes32)" \
    $POOL_ID \
    --rpc-url $BASE_SEPOLIA_RPC
# Should return: true

# Resume pool
cast send $CORRIDOR_HOOK \
    "resumePool(bytes32)" \
    $POOL_ID \
    --private-key $PRIVATE_KEY \
    --rpc-url $BASE_SEPOLIA_RPC

# Verify pool is resumed
cast call $CORRIDOR_HOOK \
    "poolPaused(bytes32)" \
    $POOL_ID \
    --rpc-url $BASE_SEPOLIA_RPC
# Should return: false
```

### Step 5: Test Fee Updates

```bash
# Update pool fee based on volatility (simulate Reactive Network)
cast send $CORRIDOR_HOOK \
    "updatePoolFee(bytes32,uint256)" \
    $POOL_ID \
    250 \
    --private-key $PRIVATE_KEY \
    --rpc-url $BASE_SEPOLIA_RPC

# Check updated fee
cast call $CORRIDOR_HOOK \
    "poolDynamicFee(bytes32)" \
    $POOL_ID \
    --rpc-url $BASE_SEPOLIA_RPC
# Should return: 65 (calculated: 30 + (250 * 70 / 500))

# Test high volatility fee
cast send $CORRIDOR_HOOK \
    "updatePoolFee(bytes32,uint256)" \
    $POOL_ID \
    700 \
    --private-key $PRIVATE_KEY \
    --rpc-url $BASE_SEPOLIA_RPC

# Check max fee applied
cast call $CORRIDOR_HOOK \
    "poolDynamicFee(bytes32)" \
    $POOL_ID \
    --rpc-url $BASE_SEPOLIA_RPC
# Should return: 100 (max fee)
```

---

## Document Addresses

### Create Deployment Record

```bash
# Create deployment record file
cat > DEPLOYED_ADDRESSES.md << EOF
# Corridor Testnet Deployment

## Deployment Information

**Network:** Base Sepolia (Chain ID: 84532)
**Deployed:** $(date)
**Deployer:** $GOVERNANCE_ADDRESS

## Contract Addresses

### Core Contracts

**CorridorHook:**
\`$CORRIDOR_HOOK\`
[View on Basescan](https://sepolia.basescan.org/address/$CORRIDOR_HOOK)

**MockPriceOracle:**
\`$MOCK_ORACLE\`
[View on Basescan](https://sepolia.basescan.org/address/$MOCK_ORACLE)

## Configuration

- **Governance:** \`$GOVERNANCE_ADDRESS\`
- **Volatility Threshold:** 500 bps (5%)
- **Base Fee:** 30 bps (0.3%)
- **Max Fee:** 100 bps (1%)

## Test Pool

- **Pool ID:** \`$POOL_ID\`
- **Initial Price:** 165000000000 (1650 NGN/USD)

## Verification Status

- ✅ CorridorHook: Verified on Basescan
- ✅ MockPriceOracle: Verified on Basescan

## Next Steps

1. ✅ Contracts deployed and verified
2. ⏳ Integrate with Uniswap v4 PoolManager
3. ⏳ Deploy Reactive Network contract
4. ⏳ Create demo video
5. ⏳ Submit to hackathon

---

**Deployment Successful! 🎉**
EOF

# View the file
cat DEPLOYED_ADDRESSES.md
```

### Update README with Deployment Info

```bash
# Add testnet section to README
cat >> README.md << EOF

## 🌐 Testnet Deployment

**Network:** Base Sepolia
**CorridorHook:** [\`$CORRIDOR_HOOK\`](https://sepolia.basescan.org/address/$CORRIDOR_HOOK)
**MockPriceOracle:** [\`$MOCK_ORACLE\`](https://sepolia.basescan.org/address/$MOCK_ORACLE)

Try it yourself on Base Sepolia testnet!
EOF
```

---

## Troubleshooting

### Issue: "Insufficient funds"

```bash
# Check balance
cast balance $GOVERNANCE_ADDRESS --rpc-url $BASE_SEPOLIA_RPC

# Solution: Get more testnet ETH from faucet
```

### Issue: "Nonce too low"

```bash
# Check current nonce
cast nonce $GOVERNANCE_ADDRESS --rpc-url $BASE_SEPOLIA_RPC

# Solution: Wait a minute and try again
```

### Issue: "Verification failed"

```bash
# Manual verification
forge verify-contract \
    $CORRIDOR_HOOK \
    src/CorridorHook.sol:CorridorHook \
    --chain-id 84532 \
    --etherscan-api-key $BASESCAN_API_KEY \
    --watch

# Check status
forge verify-check <GUID> --chain-id 84532
```

### Issue: "RPC Error"

```bash
# Try alternative RPC
export BASE_SEPOLIA_RPC="https://base-sepolia.blockpi.network/v1/rpc/public"

# Or use Alchemy/Infura if you have an account
```

### Issue: "Contract already deployed at address"

```bash
# This is OK if it's a re-deployment
# Use a different salt or continue with existing deployment
```

---

## Post-Deployment Checklist

### ✅ Verification

- [ ] Contracts deployed successfully
- [ ] Contracts verified on Basescan
- [ ] Configuration correct (governance, fees, threshold)
- [ ] Test transactions successful
- [ ] Addresses documented

### ✅ Testing

- [ ] Oracle price updates work
- [ ] Pool pause/resume functions
- [ ] Dynamic fee calculations correct
- [ ] Governance functions accessible
- [ ] Events emitted correctly

### ✅ Documentation

- [ ] DEPLOYED_ADDRESSES.md created
- [ ] Addresses added to README
- [ ] .env file updated
- [ ] Git committed and pushed

---

## Next Steps

### 1. Commit Deployment Info

```bash
git add DEPLOYED_ADDRESSES.md README.md .env.example
git commit -m "deploy: testnet deployment to Base Sepolia complete

- CorridorHook deployed and verified
- MockPriceOracle deployed and verified
- All tests passing on testnet
- Ready for demo"
git push origin main
```

### 2. Create Demo Video

See `VIDEO_SCRIPT.md` (coming next!)

### 3. Prepare Hackathon Submission

- [ ] Demo video recorded
- [ ] GitHub repo polished
- [ ] Testnet deployed
- [ ] Submission form filled
- [ ] Social media posts ready

---

## Quick Reference

### Useful Commands

```bash
# Check contract
cast code $CORRIDOR_HOOK --rpc-url $BASE_SEPOLIA_RPC

# Call read function
cast call $CORRIDOR_HOOK "function()" --rpc-url $BASE_SEPOLIA_RPC

# Send transaction
cast send $CORRIDOR_HOOK "function()" --private-key $PRIVATE_KEY --rpc-url $BASE_SEPOLIA_RPC

# Check transaction
cast receipt <TX_HASH> --rpc-url $BASE_SEPOLIA_RPC

# Monitor events
cast logs --address $CORRIDOR_HOOK --rpc-url $BASE_SEPOLIA_RPC
```

### Important Links

- **Base Sepolia Explorer:** https://sepolia.basescan.org/
- **Base Sepolia Faucet:** https://www.coinbase.com/faucets/base-ethereum-sepolia-faucet
- **Base Docs:** https://docs.base.org/
- **Foundry Book:** https://book.getfoundry.sh/

---

**Deployment Guide Complete! Ready to deploy! 🚀**
