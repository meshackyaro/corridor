# Quick Setup Guide for Price Updater

## Step-by-Step Instructions

### 1. Deploy Your Contracts First

```bash
# From the main project directory
forge script script/Deploy.s.sol:DeployCorridorHook \
    --rpc-url $UNICHAIN_SEPOLIA_RPC \
    --account corridor-deployer \
    --broadcast
```

**Note the deployed addresses from the output:**

- CorridorHook: `0x...`
- MockPriceOracle: `0x...` ← You need this!
- CorridorReactive: `0x...`

### 2. Get Your Pool ID

After you initialize a pool (or if you already have one), calculate the Pool ID:

```bash
cd price-updater

# Install dependencies first
npm install

# Calculate Pool ID
npx ts-node scripts/getPoolId.ts \
  <CURRENCY0_ADDRESS> \
  <CURRENCY1_ADDRESS> \
  <FEE> \
  <TICK_SPACING> \
  <HOOK_ADDRESS>
```

**Example:**

```bash
npx ts-node scripts/getPoolId.ts \
  0x4200000000000000000000000000000000000006 \
  0x31d0220469e10c4e71834a79b1f276d740d3768f \
  3000 \
  60 \
  0xYourCorridorHookAddress
```

This will output your Pool ID (bytes32).

### 3. Configure Environment

```bash
# Copy example file
cp .env.example .env

# Edit with your values
nano .env
```

**Fill in these required values:**

```bash
PRIVATE_KEY=0x...                                    # Your wallet private key
UNICHAIN_SEPOLIA_RPC=https://sepolia.unichain.org
MOCK_ORACLE_ADDRESS=0x...                            # From step 1
POOL_ID=0x...                                        # From step 2
```

### 4. Test the Service

```bash
# Run in development mode (with live reload)
npm run dev
```

You should see:

```
╔═══════════════════════════════════════════════╗
║                                               ║
║     🌍  CORRIDOR PRICE UPDATER SERVICE       ║
║                                               ║
║     Real-time NGN/USD Oracle for Unichain    ║
║                                               ║
╚═══════════════════════════════════════════════╝

🔗 Connected to Unichain Sepolia
📍 Oracle: 0x...
👛 Wallet: 0x...
💰 Wallet balance: 0.5 ETH

━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Update #1 - 6/6/2026, 3:00:00 PM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1️⃣  Fetching NGN/USD price...
   Rate: 1 USD = 1565.00 NGN
   Price: 1 NGN = 0.000638 USD
   Oracle format: 63800 (8 decimals)

2️⃣  Updating on-chain oracle...
📤 Sending price update transaction...
⏳ Transaction sent: 0xabc123...
✅ Price updated successfully!
```

### 5. Run in Production Mode

Once you verify it's working:

```bash
# Build TypeScript
npm run build

# Run compiled version
npm start
```

Or use a process manager:

```bash
# Install PM2
npm install -g pm2

# Start with PM2
pm2 start dist/index.js --name corridor-price-updater

# View logs
pm2 logs corridor-price-updater

# Stop
pm2 stop corridor-price-updater
```

## Common Issues

### "Insufficient funds for gas"

**Solution:** Get testnet ETH from https://bridge.unichain.org/

### "Failed to fetch price"

**Solution:**

1. Check your internet connection
2. Try a different API:
   ```bash
   # In .env, change to:
   PRICE_API_URL=https://api.exchangerate-api.com/v4/latest/USD
   ```

### "Transaction keeps failing"

**Solution:**

1. Increase gas price multiplier:
   ```bash
   # In .env
   GAS_PRICE_MULTIPLIER=1.5
   ```
2. Check you're using the correct MockPriceOracle address
3. Verify your wallet owns the oracle contract

### "Pool ID not found"

**Solution:** Make sure you've initialized your pool first in Uniswap v4

## For Your Demo

### Before the Demo

1. Start the price updater 15-30 minutes before
2. Verify it's updating successfully (check logs)
3. Have your frontend connected and reading the oracle

### During the Demo

1. Show judges the live logs updating
2. Point out real NGN/USD prices
3. Demonstrate the Reactive Network callbacks
4. Optional: Use `simulateVolatility()` for dramatic scenarios

### Backup Plan

If the service has issues during demo:

```solidity
// Manually trigger volatility in your frontend
await mockOracle.simulateVolatility(poolId, 800, false); // -8% crash
```

## Next Steps

- ✅ Service is running
- ✅ Prices updating every 5 minutes
- ✅ Reactive Network monitoring events
- ✅ Ready to build your frontend!

Your frontend can now read from MockPriceOracle and show real NGN/USD data to judges!
