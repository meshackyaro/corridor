# Corridor Frontend Integration Guide

This guide explains how the Corridor frontend integrates with the smart contracts and backend services.

## Architecture Overview

```
┌─────────────────────────────────────────────────────────────┐
│                     Frontend (Next.js)                      │
│  ┌────────────┐  ┌──────────────┐  ┌──────────────────┐   │
│  │  User UI   │→ │ Web3 Hooks   │→ │ Smart Contracts  │   │
│  └────────────┘  └──────────────┘  └──────────────────┘   │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  Unichain Sepolia Testnet                   │
│  ┌──────────────┐  ┌──────────────┐  ┌─────────────────┐  │
│  │CorridorHook  │  │ PriceOracle  │  │ Pool Manager    │  │
│  │(Uniswap v4)  │  │(NGN/USD)     │  │(Uniswap v4 Core)│  │
│  └──────────────┘  └──────────────┘  └─────────────────┘  │
└─────────────────────────────────────────────────────────────┘
                            ↓
┌─────────────────────────────────────────────────────────────┐
│                  Reactive Network (Lasna)                   │
│  ┌──────────────────────────────────────────────────────┐  │
│  │  CorridorReactive (Volatility Monitoring)            │  │
│  │  - Subscribes to PriceOracle events                  │  │
│  │  - Triggers callbacks to CorridorHook                │  │
│  └──────────────────────────────────────────────────────┘  │
└─────────────────────────────────────────────────────────────┘
```

## Frontend Technology Stack

### Core Framework

- **Next.js 14** (App Router) - React framework
- **TypeScript** - Type safety
- **Tailwind CSS** - Styling

### Web3 Integration

- **Wagmi v2** - React hooks for Ethereum
- **Viem** - TypeScript Ethereum library
- **RainbowKit** - Wallet connection UI
- **TanStack Query** - Data fetching & caching

### UI & Animations

- **Framer Motion** - Smooth animations
- **Recharts** - Data visualization
- **Lucide React** - Icon system

## Smart Contract Integration

### 1. CorridorHook Contract

**Location:** `src/CorridorHook.sol`  
**Deployed on:** Unichain Sepolia (Chain ID: 1301)

**Frontend Integration:**

```typescript
// src/lib/contracts.ts
export const CORRIDOR_HOOK_ABI = [
  // ABI definitions for read/write functions
];

// src/hooks/usePoolData.ts
export function usePoolData() {
  const { data: isPaused } = useReadContract({
    address: CORRIDOR_HOOK_ADDRESS,
    abi: CORRIDOR_HOOK_ABI,
    functionName: "poolPaused",
    args: [poolId],
  });
  // ... more contract reads
}
```

**Read Functions Used:**

- `poolPaused(PoolId)` - Check if pool is paused
- `poolDynamicFee(PoolId)` - Get current fee (0.3% - 1%)
- `volatilityThreshold()` - Get pause threshold (5%)
- `communityLPShares(address)` - Get LP shares for user
- `totalCommunityShares()` - Get total community LPs

**Write Functions (Future Implementation):**

- `setReactiveContract(address)` - Set Reactive contract
- `updatePoolFee(PoolId, volatility)` - Update fee (Reactive only)
- `pausePool(PoolId, priceChange)` - Pause pool (Reactive only)
- `resumePool(PoolId)` - Resume pool (Reactive only)

### 2. PriceOracle Contract

**Location:** `src/mocks/MockPriceOracle.sol`  
**Purpose:** Provides NGN/USD price feed

**Frontend Integration:**

```typescript
export const PRICE_ORACLE_ABI = [
  {
    inputs: [{ internalType: "PoolId", name: "poolId", type: "bytes32" }],
    name: "getPrice",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function",
  },
];
```

**Read Functions:**

- `getPrice(PoolId)` - Get current NGN/USD price

### 3. CorridorReactive Contract

**Location:** `src/CorridorReactive.sol`  
**Deployed on:** Reactive Network (Lasna Testnet)

**Purpose:**

- Monitors price oracle events
- Calculates volatility
- Triggers callbacks to CorridorHook
- Pauses/resumes pool automatically

**Frontend Visibility:**

- Contract address displayed in UI
- No direct frontend interaction (automation contract)
- Effects visible through Hook contract state changes

## Data Flow Examples

### Example 1: Displaying Pool Status

**User Journey:**

1. User visits Corridor frontend
2. Frontend loads → React renders PoolStatus component
3. `usePoolData()` hook executes
4. Wagmi queries CorridorHook contract
5. Contract returns: `isPaused = false`, `dynamicFee = 30` (0.3%)
6. UI displays "Pool Active" with green indicator

**Code Flow:**

```typescript
// Component
<PoolStatus />
  ↓
// Hook
usePoolData()
  ↓
// Wagmi
useReadContract({
  address: CORRIDOR_HOOK_ADDRESS,
  functionName: "poolPaused",
})
  ↓
// RPC Call to Unichain Sepolia
eth_call(CorridorHook.poolPaused)
  ↓
// Contract Response
false
  ↓
// UI Update
"Pool Status: Active"
```

### Example 2: Remittance Cost Calculation

**User Journey:**

1. User adjusts amount slider to $200
2. Calculator component updates state
3. JavaScript calculates fees:
   - Western Union: $200 × 8.37% = $16.74
   - Corridor: $200 × 0.3% = $0.60
4. UI shows savings: $16.14 (96% reduction)

**Code:**

```typescript
const [amount, setAmount] = useState(200);
const corridorFee = amount * 0.003; // 0.3%
const westernUnionFee = amount * 0.0837; // 8.37%
const savings = westernUnionFee - corridorFee;
```

### Example 3: IL Protection Visualization

**Automated Flow (No User Action):**

1. Price updater service updates oracle: NGN/USD changes 6%
2. PriceOracle emits `PriceUpdated` event
3. Reactive Network detects event
4. CorridorReactive calculates volatility: 6% > 5% threshold
5. CorridorReactive calls `pausePool()` on CorridorHook
6. Pool pauses
7. Next user visiting frontend sees "Pool Paused" indicator
8. Frontend shows: "Volatility: 6% (Threshold: 5%)"

## Price Update Service Integration

**Location:** `price-updater/`  
**Purpose:** Simulates real NGN/USD price updates for testing

**How It Works:**

1. Service fetches real NGN/USD rates from API
2. Calls `MockPriceOracle.updatePrice(poolId, newPrice)`
3. Oracle emits `PriceUpdated` event
4. Reactive Network monitoring triggers
5. Frontend reflects updated data

**Frontend Impact:**

- Real-time price chart updates
- Volatility calculations change
- Pool status may change (pause/resume)
- Dynamic fee adjustments visible

**Starting the Service:**

```bash
cd price-updater
npm install
cp .env.example .env
# Configure with contract addresses
npm run dev
```

## Environment Configuration

### Required Variables

```env
# Frontend (.env.local)
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=<from cloud.walletconnect.com>
NEXT_PUBLIC_CORRIDOR_HOOK_ADDRESS=<from deployment>
NEXT_PUBLIC_PRICE_ORACLE_ADDRESS=<from deployment>
NEXT_PUBLIC_REACTIVE_CONTRACT_ADDRESS=<from deployment>
NEXT_PUBLIC_CHAIN_ID=1301
NEXT_PUBLIC_RPC_URL=https://sepolia.unichain.org
```

### Contract Address Sources

After running deployment scripts:

```bash
# Deploy to Unichain
forge script script/DeployToUnichain.s.sol --broadcast
# → Outputs: Hook Address, Oracle Address

# Deploy to Reactive
forge script script/DeployToReactive.s.sol --broadcast
# → Outputs: Reactive Contract Address

# Update frontend/.env.local with these addresses
```

## Testing Frontend Locally

### Prerequisites

1. Deployed contracts on Unichain Sepolia
2. WalletConnect Project ID
3. Test wallet with Unichain Sepolia ETH

### Steps

1. **Install Dependencies**

   ```bash
   cd frontend
   npm install
   ```

2. **Configure Environment**

   ```bash
   cp .env.example .env.local
   # Edit .env.local with your values
   ```

3. **Start Development Server**

   ```bash
   npm run dev
   ```

4. **Test Features**
   - Visit http://localhost:3000
   - Connect wallet (use Unichain Sepolia network)
   - Check pool status loads correctly
   - Test calculator calculations
   - Verify contract data displays

## Common Integration Issues

### Issue: Contract Data Not Loading

**Symptoms:**

- Pool status shows default values
- "Loading..." states persist

**Solutions:**

1. Check contract addresses in `.env.local`
2. Verify RPC URL is correct
3. Confirm contracts deployed on Unichain Sepolia (chain 1301)
4. Check browser console for errors
5. Verify wallet is on correct network

### Issue: Wallet Won't Connect

**Symptoms:**

- RainbowKit modal won't open
- "Wrong network" error

**Solutions:**

1. Check WalletConnect Project ID is valid
2. Add Unichain Sepolia to wallet manually
3. Clear browser cache
4. Try different wallet

### Issue: Prices/Fees Not Updating

**Symptoms:**

- Static price chart
- Fee stays at 0.3%

**Solutions:**

1. Ensure price-updater service is running
2. Check oracle has recent price updates
3. Verify Reactive contract is monitoring
4. Check frontend polling interval

## Advanced Integration Topics

### Adding Write Functions (Future)

When ready to enable swaps/liquidity:

1. **Add Write Functions to ABI**

   ```typescript
   {
     name: "addLiquidity",
     inputs: [...],
     stateMutability: "nonpayable",
   }
   ```

2. **Create Write Hook**

   ```typescript
   export function useAddLiquidity() {
     const { writeContract } = useWriteContract();

     return async (amount: bigint) => {
       await writeContract({
         address: CORRIDOR_HOOK_ADDRESS,
         abi: CORRIDOR_HOOK_ABI,
         functionName: "beforeAddLiquidity",
         args: [amount],
       });
     };
   }
   ```

3. **Add UI Components**
   - Transaction modals
   - Confirmation dialogs
   - Success/error states
   - Gas estimation

### Real-Time Updates

For production, implement:

1. **WebSocket Connections**
   - Listen for blockchain events
   - Update UI in real-time

2. **Polling Strategy**

   ```typescript
   useReadContract({
     // ... config
     query: {
       refetchInterval: 12000, // Every block (12s)
     },
   });
   ```

3. **Event Subscriptions**
   ```typescript
   useWatchContractEvent({
     address: PRICE_ORACLE_ADDRESS,
     abi: PRICE_ORACLE_ABI,
     eventName: "PriceUpdated",
     onLogs: (logs) => {
       // Update UI
     },
   });
   ```

## Performance Optimization

### Caching Strategy

- Contract reads cached by TanStack Query
- 12-second refetch interval (1 block)
- Background refetch on window focus
- Stale-while-revalidate pattern

### Bundle Optimization

- Code splitting by route
- Dynamic imports for heavy components
- Image optimization with next/image
- Font optimization with next/font

## Security Considerations

### Frontend Security

1. **Never expose private keys**
2. **Validate all contract addresses**
3. **Use environment variables**
4. **Sanitize user inputs**
5. **Implement rate limiting**

### Transaction Safety

1. **Preview before signing**
2. **Show gas estimates**
3. **Validate network before tx**
4. **Clear error messages**
5. **Transaction status tracking**

## Monitoring & Analytics

### Recommended Tools

- **Sentry** - Error tracking
- **Google Analytics** - User metrics
- **Vercel Analytics** - Performance
- **WalletConnect Analytics** - Wallet connections

### Key Metrics to Track

1. Wallet connection rate
2. Contract interaction success rate
3. Page load times
4. Error rates by type
5. User flow drop-off points

## Support & Resources

- **Frontend Code:** `/frontend` directory
- **Contract Code:** `/src` directory
- **Documentation:** `README.md`, `HOOKATHON_SUBMISSION.md`
- **Deployment:** `DEPLOYMENT_GUIDE.md`
- **Issues:** GitHub Issues

---

Built with ❤️ for African communities
