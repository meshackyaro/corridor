# Corridor Deployment Guide

## Architecture Overview

```
┌─────────────────────────────────────┐
│     Unichain Sepolia (Chain 1301)   │
│  ┌─────────────┐  ┌──────────────┐  │
│  │CorridorHook │  │MockOracle    │  │
│  │(Destination)│  │(Origin Events│  │
│  └─────────────┘  └──────────────┘  │
└─────────────────────────────────────┘
           ▲                │
           │ Callback       │ Events
           │                ▼
┌─────────────────────────────────────┐
│  Reactive Network (Lasna Testnet)   │
│  ┌─────────────────────────────┐    │
│  │   CorridorReactive          │    │
│  │   (Monitoring & Logic)      │    │
│  └─────────────────────────────┘    │
└─────────────────────────────────────┘
```

## Prerequisites

1. **Foundry Installed**

   ```bash
   curl -L https://foundry.paradigm.xyz | bash
   foundryup
   ```

2. **Keystore Setup**

   ```bash
   cast wallet import deployer --interactive
   ```

3. **Testnet Funds**
   - **Unichain Sepolia ETH**: Bridge from Ethereum Sepolia
     - https://bridge.unichain.org/
     - https://superbridge.app/unichain-sepolia
   - **Reactive Network lREACT**: Get from faucet
     - https://reactive.network/faucet

## Step-by-Step Deployment

### Step 1: Deploy to Unichain Sepolia

Deploy Hook and Oracle to Unichain:

```bash
# Set RPC
export UNICHAIN_SEPOLIA_RPC=https://sepolia.unichain.org

# Deploy
forge script script/DeployToUnichain.s.sol:DeployToUnichain \
    --rpc-url $UNICHAIN_SEPOLIA_RPC \
    --account deployer \
    --broadcast
```

**Save the output addresses:**

```
Hook Address: 0xABC...
Oracle Address: 0xDEF...
```

### Step 2: Deploy to Reactive Network

Deploy monitoring contract to Reactive:

```bash
# Add addresses from Step 1 to .env
echo "CORRIDOR_HOOK=0xYOUR_HOOK_ADDRESS" >> .env
echo "PRICE_ORACLE=0xYOUR_ORACLE_ADDRESS" >> .env

# Set Reactive RPC
export REACTIVE_RPC=https://lasna-omni-rpc.rnk.dev/

# Deploy
forge script script/DeployToReactive.s.sol:DeployToReactive \
    --rpc-url $REACTIVE_RPC \
    --account deployer \
    --broadcast
```

**Save the output address:**

```
Reactive Contract: 0x123...
```

### Step 3: Connect the Contracts

Connect Hook to Reactive contract:

```bash
# Add Reactive address to .env
echo "REACTIVE_CONTRACT=0xYOUR_REACTIVE_ADDRESS" >> .env

# Connect (back on Unichain)
forge script script/ConnectContracts.s.sol:ConnectContracts \
    --rpc-url $UNICHAIN_SEPOLIA_RPC \
    --account deployer \
    --broadcast
```

## Verification

### 1. Check Unichain Deployments

Visit https://sepolia.uniscan.xyz/ and verify:

- CorridorHook is deployed
- MockPriceOracle is deployed

### 2. Check Reactive Deployment

Visit Reactive Network explorer and verify:

- CorridorReactive is deployed

### 3. Verify Connection

```bash
cast call $CORRIDOR_HOOK "reactiveContract()" --rpc-url $UNICHAIN_SEPOLIA_RPC
# Should return your REACTIVE_CONTRACT address
```

## Post-Deployment: Setup Price Updater

```bash
cd price-updater
cp .env.example .env

# Edit .env with your addresses
nano .env
```

Add:

```bash
MOCK_ORACLE_ADDRESS=0xYOUR_ORACLE_ADDRESS
CORRIDOR_HOOK_ADDRESS=0xYOUR_HOOK_ADDRESS
POOL_ID=0x...  # Your pool ID
```

Start updater:

```bash
npm install
npm run dev
```

## Complete Deployment Checklist

- [ ] Deploy CorridorHook to Unichain Sepolia
- [ ] Deploy MockPriceOracle to Unichain Sepolia
- [ ] Deploy CorridorReactive to Reactive Network
- [ ] Connect Hook to Reactive (call setReactiveContract)
- [ ] Configure price-updater with addresses
- [ ] Start price-updater service
- [ ] Test with sample transactions

## Troubleshooting

**"Deployment failed on Reactive"**

- Check you have lREACT tokens
- Verify RPC: https://lasna-omni-rpc.rnk.dev/

**"Connection failed"**

- Make sure you're calling setReactiveContract on Unichain, not Reactive
- Verify REACTIVE_CONTRACT address is correct

**"Price updates not working"**

- Check price-updater is running
- Verify MOCK_ORACLE_ADDRESS is correct
- Ensure you have Unichain Sepolia ETH for gas

## Network Information

**Unichain Sepolia**

- Chain ID: 1301
- RPC: https://sepolia.unichain.org
- Explorer: https://sepolia.uniscan.xyz/
- PoolManager: 0x00B036B58a818B1BC34d502D3fE730Db729e62AC

**Reactive Network (Lasna)**

- RPC: https://lasna-omni-rpc.rnk.dev/
- Faucet: https://reactive.network/faucet
- System Contract: 0x0000000000000000000000000000000000fffFfF
- Callback Proxy: 0x9299472A6399Fd1027ebF067571Eb3e3D7837FC4
