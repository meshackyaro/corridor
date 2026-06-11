# Corridor - Fixed Deployment Guide

## ⚠️ BREAKING CHANGES

Your previously deployed contracts are **incompatible** and must be redeployed:

1. **Hook callback signatures changed** (added `rvm_id` parameter)
2. **Hook address must be mined** with CREATE2 for v4 validity
3. **Reactive contract completely rewritten** to use real `reactive-lib`

## Prerequisites

✅ Foundry installed  
✅ Keystore wallet configured (`cast wallet import deployer`)  
✅ **Unichain Sepolia ETH** (for hook + oracle deployment)  
✅ **Reactive Lasna REACT** (minimum 0.5 REACT for RSC funding)

**Get testnet funds:**

- Unichain: https://bridge.unichain.org/ or https://superbridge.app/unichain-sepolia
- Reactive: https://dev.reactive.network/docs/faucet

## Architecture

```
┌──────────────────────────────────┐
│   Unichain Sepolia (Chain 1301)  │
│                                  │
│  ┌─────────────┐  ┌───────────┐ │
│  │ CorridorHook│  │MockOracle │ │
│  │ (mined addr)│  │           │ │
│  └──────┬──────┘  └─────┬─────┘ │
│         ▲                │       │
└─────────┼────────────────┼───────┘
          │                │
     Callback          PriceUpdated
     Proxy calls       event emitted
          │                │
          │                ▼
┌─────────┴────────────────────────┐
│ Reactive Lasna (Chain 5318007)   │
│                                  │
│  ┌────────────────────────────┐  │
│  │   CorridorReactive (RSC)   │  │
│  │   - Subscribes to events   │  │
│  │   - Emits Callback events  │  │
│  └────────────────────────────┘  │
└──────────────────────────────────┘
```

**Key addresses:**

- Callback Proxy (on Unichain): `0x9299472A6399Fd1027ebF067571Eb3e3D7837FC4`
- Unichain PoolManager: `0x00B036B58a818B1BC34d502D3fE730Db729e62AC`

## Step-by-Step Deployment

### Step 1: Deploy to Unichain Sepolia

Deploys Hook (with CREATE2 mining) and Oracle:

```bash
forge script script/DeployToUnichain.s.sol:DeployToUnichain \
    --rpc-url unichain_sepolia \
    --account deployer \
    --broadcast \
    -vvvv
```

**Save the output addresses:**

```
CORRIDOR_HOOK=0x... (mined address with valid flags)
PRICE_ORACLE=0x...
```

**Add to `.env`:**

```bash
echo "CORRIDOR_HOOK=0x..." >> .env
echo "PRICE_ORACLE=0x..." >> .env
```

### Step 2: Create Pool

Initialize a v4 pool with your hook:

```bash
forge script script/CreatePool.s.sol:CreatePool \
    --rpc-url unichain_sepolia \
    --account deployer \
    --broadcast \
    -vvvv
```

**Save the POOL_ID:**

```
POOL_ID=0x... (bytes32)
```

**Add to both `.env` files:**

```bash
echo "POOL_ID=0x..." >> .env
echo "POOL_ID=0x..." >> price-updater/.env
```

### Step 3: Deploy to Reactive Lasna

Deploys monitoring contract **with REACT funding**:

```bash
forge script script/DeployToReactive.s.sol:DeployToReactive \
    --rpc-url reactive_lasna \
    --account deployer \
    --broadcast \
    -vvvv
```

**Important:** This deploys with `{value: 0.5 ether}` to fund the RSC subscription.

**Check balance before deploying:**

```bash
cast balance YOUR_ADDRESS --rpc-url https://lasna-rpc.rnk.dev
```

### Step 4: Connect Hook to Callback Proxy

Authorizes the Callback Proxy to call your hook:

```bash
forge script script/ConnectContracts.s.sol:ConnectContracts \
    --rpc-url unichain_sepolia \
    --account deployer \
    --broadcast \
    -vvvv
```

This sets `reactiveCallbackProxy = 0x9299472A6399Fd1027ebF067571Eb3e3D7837FC4`

### Step 5: Fund Callback Proxy (CRITICAL)

The Callback Proxy needs ETH on Unichain to pay gas for callbacks.

**Follow Reactive docs to deposit:**

- Use `depositTo` or `reserveFunds` on the Callback Proxy
- Check current docs: https://dev.reactive.network/docs

Without this, callbacks will emit on Lasna but never execute on Unichain.

### Step 6: Setup Price Updater

```bash
cd price-updater
cp .env.example .env
```

**Edit `price-updater/.env`:**

```bash
UNICHAIN_SEPOLIA_RPC=https://sepolia.unichain.org
MOCK_ORACLE_ADDRESS=0x... (from Step 1)
CORRIDOR_HOOK_ADDRESS=0x... (from Step 1)
POOL_ID=0x... (from Step 2)
PRIVATE_KEY=0x... (updater wallet - must be oracle owner)
UPDATE_INTERVAL=60000
```

**Start updater:**

```bash
npm install
npm run dev
```

## Verification Checklist

- [ ] Hook deployed to mined address (check on Uniscan)
- [ ] Oracle deployed
- [ ] Pool created with `DYNAMIC_FEE_FLAG`
- [ ] RSC deployed to Lasna with 0.5+ REACT balance
- [ ] Hook's `reactiveCallbackProxy` set to `0x9299...7FC4`
- [ ] Callback Proxy funded on Unichain
- [ ] Price updater running

## End-to-End Test

1. **Price updater emits PriceUpdated** on Unichain
2. **RSC on Lasna sees event** (check Lasna explorer: https://lasna.reactscan.net)
3. **RSC emits Callback event**
4. **Callback Proxy executes on Unichain** (check Uniscan)
5. **Hook emits PoolPausedByVolatility** (if volatility > 5%)

**Test volatility trigger:**

```bash
# On Unichain, as oracle owner:
cast send $PRICE_ORACLE "simulateVolatility(bytes32,uint256,bool)" \
    $POOL_ID 600 false \
    --rpc-url unichain_sepolia \
    --account deployer
```

This simulates 6% volatility → should trigger pause.

## Troubleshooting

**"HookAddressNotValid" during pool init:**

- Hook address doesn't have correct permission bits
- Redeploy with CREATE2 mining (Step 1)

**RSC deployment reverts in constructor:**

- You don't have 0.5 REACT on Lasna
- Get from faucet first

**Callbacks not executing on Unichain:**

1. Check RSC has REACT balance on Lasna
2. Check Callback Proxy funded on Unichain
3. Verify hook authorized proxy address (not RSC address)
4. Check event appears on Lasna explorer first

**"Unauthorized" when callbacks execute:**

- Hook's `reactiveCallbackProxy` must be `0x9299...7FC4`
- Run Step 4 again

## Network Information

**Unichain Sepolia**

- Chain ID: 1301
- RPC: https://sepolia.unichain.org
- Explorer: https://sepolia.uniscan.xyz
- PoolManager: `0x00B036B58a818B1BC34d502D3fE730Db729e62AC`

**Reactive Lasna**

- Chain ID: 5318007
- RPC: https://lasna-rpc.rnk.dev
- Explorer: https://lasna.reactscan.net
- System Contract: `0x0000000000000000000000000000000000fffFfF`
- Callback Proxy (on Unichain): `0x9299472A6399Fd1027ebF067571Eb3e3D7837FC4`

## What Changed

### CorridorReactive.sol

- ✅ Inherits `AbstractReactive` from `reactive-lib`
- ✅ `react(LogRecord calldata log)` signature
- ✅ Subscribes in constructor with `if (!vm)` guard
- ✅ Constructor is `payable` for REACT funding
- ✅ Decodes `poolId` from `topic_1` (indexed parameter)
- ✅ Emits `Callback` events (not calling proxy)
- ✅ Includes `rvm_id` placeholder in payloads
- ✅ Gas limit = 500,000

### CorridorHook.sol

- ✅ Callback functions accept `address rvm_id` as first parameter
- ✅ `reactiveContract` renamed to `reactiveCallbackProxy`
- ✅ Authorizes Callback Proxy address, not RSC address

### Deployment Scripts

- ✅ `DeployToUnichain.s.sol` mines CREATE2 address with `HookMiner`
- ✅ `DeployToReactive.s.sol` funds RSC with 0.5 REACT
- ✅ `ConnectContracts.s.sol` sets Callback Proxy address
- ✅ New `CreatePool.s.sol` initializes pool with `DYNAMIC_FEE_FLAG`

## Support

- Reactive Network Docs: https://dev.reactive.network/docs
- Uniswap v4 Docs: https://docs.uniswap.org/contracts/v4/overview
