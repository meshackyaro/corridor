# Corridor Price Updater

Real-time NGN/USD price oracle updater for the Corridor remittance system. Fetches live exchange rates from forex APIs and updates the on-chain MockPriceOracle contract.

## 🎯 Purpose

For the Uniswap v4 Hookathon demo, this service:

- ✅ Fetches **real NGN/USD exchange rates** from free forex APIs
- ✅ Updates your MockPriceOracle on Unichain Sepolia every 5 minutes
- ✅ Triggers Reactive Network callbacks when volatility thresholds are exceeded
- ✅ Provides realistic demo experience with live African currency data

## 📋 Prerequisites

- Node.js 18+ and npm
- Deployed `MockPriceOracle` contract on Unichain Sepolia
- Wallet with testnet ETH for gas (get from [Unichain Bridge](https://bridge.unichain.org/))

## 🚀 Quick Start

### 1. Install Dependencies

```bash
cd price-updater
npm install
```

### 2. Configure Environment

```bash
# Copy example env file
cp .env.example .env

# Edit .env with your values
nano .env
```

**Required variables:**

```bash
PRIVATE_KEY=0x...                                    # Your wallet private key
UNICHAIN_SEPOLIA_RPC=https://sepolia.unichain.org
MOCK_ORACLE_ADDRESS=0x...                            # Deployed MockPriceOracle address
POOL_ID=0x...                                        # Your pool ID (bytes32)
```

### 3. Run the Price Updater

**Development mode (with auto-reload):**

```bash
npm run dev
```

**Production mode:**

```bash
npm run build
npm start
```

## 📊 How It Works

```
┌─────────────────┐
│  Forex API      │  Every 5 minutes
│  (NGN/USD)      │ ────────────────┐
└─────────────────┘                 │
                                    ▼
                         ┌──────────────────────┐
                         │  Price Updater       │
                         │  (This Service)      │
                         └──────────────────────┘
                                    │
                                    ▼
                         ┌──────────────────────┐
                         │  MockPriceOracle     │
                         │  (Unichain Sepolia)  │
                         └──────────────────────┘
                                    │
                                    ▼ PriceUpdated event
                         ┌──────────────────────┐
                         │  Reactive Network    │
                         │  (Monitors events)   │
                         └──────────────────────┘
                                    │
                                    ▼ Callback if volatility > 5%
                         ┌──────────────────────┐
                         │  CorridorHook        │
                         │  (Pauses pool)       │
                         └──────────────────────┘
```

## 🔧 Configuration Options

### Update Interval

```bash
# Update every 5 minutes (default)
UPDATE_INTERVAL=300000

# Update every 1 minute (for faster demo)
UPDATE_INTERVAL=60000

# Update every 30 seconds (very frequent, higher gas costs)
UPDATE_INTERVAL=30000
```

### Price API Options

**Option 1: ExchangeRate-API (Default - No API Key)**

```bash
PRICE_API_URL=https://api.exchangerate-api.com/v4/latest/USD
# No API key needed, free tier: 1500 requests/month
```

**Option 2: Fixer.io (Requires Free Account)**

```bash
PRICE_API_URL=https://data.fixer.io/api/latest
PRICE_API_KEY=your_fixer_api_key
# Free tier: 100 requests/month
```

**Option 3: CurrencyAPI (Requires Free Account)**

```bash
PRICE_API_URL=https://api.currencyapi.com/v3/latest
PRICE_API_KEY=your_currencyapi_key
# Free tier: 300 requests/month
```

### Gas Configuration

```bash
# Increase gas price for faster confirmation (default: 1.2 = 20% higher)
GAS_PRICE_MULTIPLIER=1.5

# Maximum transaction retries on failure
MAX_RETRIES=3
```

### Debug Mode

```bash
# Enable detailed logging
DEBUG=true
```

## 📱 Usage with Frontend

Your frontend can read the updated prices from the oracle:

```typescript
// In your React/Next.js app
import { ethers } from "ethers";

const MOCK_ORACLE_ABI = [
  "function getPrice(bytes32 poolId) external view returns (uint256)",
  "event PriceUpdated(bytes32 indexed poolId, uint256 newPrice)",
];

// Read current price
const oracle = new ethers.Contract(ORACLE_ADDRESS, MOCK_ORACLE_ABI, provider);
const price = await oracle.getPrice(POOL_ID);
const usdPerNgn = Number(price) / 1e8; // Convert from 8 decimals

// Listen for updates
oracle.on("PriceUpdated", (poolId, newPrice) => {
  console.log("Price updated:", Number(newPrice) / 1e8);
});
```

## 🔍 Monitoring

The service logs all activities:

```
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━
🔄 Update #5 - 6/6/2026, 2:30:00 PM
━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━

1️⃣  Fetching NGN/USD price...
   Rate: 1 USD = 1565.00 NGN
   Price: 1 NGN = 0.000638 USD
   Oracle format: 63800 (8 decimals)

2️⃣  Updating on-chain oracle...
📤 Sending price update transaction...
⏳ Transaction sent: 0xabc123...
   Waiting for confirmation...
✅ Price updated successfully!
   Block: 1234567
   Gas used: 45000

✨ Successfully updated price on Unichain Sepolia
   Total updates: 5
   Next update in 300s
```

## 🛑 Stopping the Service

Press `Ctrl+C` to stop gracefully. The service will display final statistics:

```
👋 Shutting down gracefully...
   Total updates completed: 24
   Total failures: 0

✅ Price updater stopped
```

## ⚠️ Troubleshooting

### "Insufficient funds for gas"

- Get testnet ETH: https://bridge.unichain.org/
- Check balance: The service shows your balance on startup

### "Transaction failed" or high gas costs

- Increase `GAS_PRICE_MULTIPLIER` in .env
- Check Unichain Sepolia is not congested

### "Failed to fetch price"

- Check your internet connection
- Try a different `PRICE_API_URL`
- Check API rate limits

### "Large price change detected"

- The service rejects >20% changes to prevent oracle manipulation
- This is a safety feature - check if the API data is correct

## 🎬 Demo Tips

1. **Start the updater before your demo** - let it run for 10-15 minutes to build history

2. **Monitor the logs** - show judges the real-time updates

3. **Point out key features:**
   - Real NGN/USD data from forex markets
   - Automatic on-chain updates every 5 minutes
   - Reactive Network monitoring the events
   - Actual volatility-based IL protection

4. **Have a backup plan** - if the service fails, your MockPriceOracle still works with manual `simulateVolatility()` calls

## 📄 License

MIT - Same as the main Corridor project
