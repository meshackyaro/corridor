# Corridor Architecture

## System Overview

Corridor is a community-owned remittance infrastructure built on Uniswap v4 and Reactive Network. It combines custom hook logic with automated monitoring to provide IL-protected, yield-generating liquidity for African currency corridors.

## Component Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                         Base Chain                           │
│                                                               │
│  ┌──────────────┐         ┌─────────────────┐              │
│  │   Uniswap    │◄────────│  CorridorHook   │              │
│  │ PoolManager  │         │                 │              │
│  └──────────────┘         │  - Dynamic Fees │              │
│         │                 │  - Pause Logic  │              │
│         │                 │  - LP Tracking  │              │
│         ▼                 └────────▲────────┘              │
│  ┌──────────────┐                 │                        │
│  │  USD/NGN     │                 │ Callbacks              │
│  │  Liquidity   │                 │                        │
│  │  Pool        │                 │                        │
│  └──────────────┘                 │                        │
│                                    │                        │
└────────────────────────────────────┼────────────────────────┘
                                     │
                    Cross-Chain      │
                    Callbacks        │
                                     │
┌────────────────────────────────────┼────────────────────────┐
│                  Reactive Network  │                        │
│                                    │                        │
│  ┌─────────────────────────────────┴──────────────┐        │
│  │          CorridorReactive                      │        │
│  │                                                 │        │
│  │  - Event Subscription                          │        │
│  │  - Volatility Calculation                      │        │
│  │  - Callback Triggering                         │        │
│  └────────────▲────────────────────────────────────┘        │
│               │                                             │
│               │ Event Stream                                │
│               │                                             │
│  ┌────────────┴────────────┐                               │
│  │    Price Oracle         │                               │
│  │  (Chainlink/Pyth)       │                               │
│  │                         │                               │
│  │  - NGN/USD Price        │                               │
│  │  - Update Events        │                               │
│  └─────────────────────────┘                               │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Data Flow

### 1. Normal Swap Flow

```
User → PoolManager.swap()
  ↓
PoolManager → Hook.beforeSwap()
  ↓
Hook checks:
  - Is pool paused? → Revert if yes
  - Return dynamic fee
  ↓
PoolManager executes swap with dynamic fee
  ↓
PoolManager → Hook.afterSwap()
  ↓
Hook logs swap activity
  ↓
Return to user
```

### 2. Volatility Detection Flow

```
Price Oracle emits PriceUpdated(poolId, newPrice)
  ↓
Reactive Network detects event
  ↓
CorridorReactive.react() called
  ↓
Calculate volatility:
  priceChange = |newPrice - lastPrice| / lastPrice * 10000
  ↓
If priceChange > threshold:
  ↓
  Trigger callback to Base:
    CorridorHook.pausePool(poolId, priceChange)
  ↓
  Pool paused, swaps blocked
  ↓
  Wait for volatility to normalize
  ↓
  Trigger callback:
    CorridorHook.resumePool(poolId)
```

### 3. Fee Adjustment Flow

```
Reactive Network monitors price volatility
  ↓
Calculate volatility percentage
  ↓
Trigger callback:
  CorridorHook.updatePoolFee(poolId, volatilityBps)
  ↓
Hook calculates new fee:
  if (volatility > threshold):
    fee = maxVolatilityFee (1%)
  else:
    fee = baseFee + proportional increase
  ↓
Next swap uses updated fee
```

## Smart Contract Details

### CorridorHook

**Purpose**: Uniswap v4 hook providing IL protection and dynamic fees

**Key State Variables**:

```solidity
IPoolManager public immutable poolManager;
address public communityGovernance;
address public reactiveContract;
uint256 public volatilityThreshold;  // 500 = 5%
uint24 public baseFee;               // 30 = 0.3%
uint24 public maxVolatilityFee;      // 100 = 1%
mapping(PoolId => bool) public poolPaused;
mapping(PoolId => uint24) public poolDynamicFee;
mapping(address => uint256) public communityLPShares;
```

**Hook Functions**:

- `beforeInitialize`: Set initial fee for pool
- `beforeSwap`: Check pause status, return dynamic fee
- `afterSwap`: Log swap activity
- `beforeAddLiquidity`: Track community LP
- `beforeRemoveLiquidity`: Update LP tracking

**External Functions**:

- `pausePool`: Emergency pause (called by Reactive)
- `resumePool`: Resume operations (called by Reactive)
- `updatePoolFee`: Adjust fee based on volatility (called by Reactive)
- `setReactiveContract`: Connect to Reactive Network (governance)
- `setVolatilityThreshold`: Update risk parameters (governance)

### CorridorReactive

**Purpose**: Reactive Network contract for automated monitoring

**Key State Variables**:

```solidity
address public immutable SYSTEM_CONTRACT;
address public immutable CALLBACK_PROXY;
address public corridorHook;
address public priceOracle;
uint256 public volatilityThreshold;
mapping(bytes32 => uint256) public lastPrices;
mapping(bytes32 => bool) public poolPaused;
```

**Core Functions**:

- `react`: Called by Reactive Network on events
- `_checkVolatility`: Calculate price changes
- `_pausePool`: Trigger pause callback
- `_resumePool`: Trigger resume callback
- `_sendCallback`: Send cross-chain transaction

**Configuration**:

- `setVolatilityThreshold`: Update monitoring threshold
- `setCorridorHook`: Update hook address
- `setPriceOracle`: Change oracle source

## Security Model

### Access Control

```
┌─────────────────────┐
│  Community          │
│  Governance         │
│  (Multisig)         │
└──────┬──────────────┘
       │
       │ Controls:
       │ - Volatility threshold
       │ - Fee parameters
       │ - Reactive contract address
       │ - Emergency pause
       │
       ▼
┌──────────────────────┐
│  CorridorHook        │
└──────┬───────────────┘
       │
       │ Accepts calls from:
       │ - PoolManager (hook functions)
       │ - Reactive Contract (pause/resume/fee updates)
       │ - Governance (configuration)
       │
       ▼
┌──────────────────────┐
│  Reactive Contract   │
└──────────────────────┘
       │
       │ Accepts calls from:
       │ - Reactive System Contract (react function)
       │ - Owner (configuration)
```

### Risk Mitigation

1. **IL Protection**
   - Automated volatility monitoring
   - Threshold-based pool pausing
   - Dynamic fee adjustment
   - Community-defined risk parameters

2. **Access Control**
   - Governance multisig for critical functions
   - Reactive contract authorization
   - PoolManager-only hook calls
   - Parameter validation

3. **Emergency Response**
   - Manual pause by governance
   - Automated pause by Reactive
   - Resume requires stabilization
   - Configurable thresholds

4. **Economic Security**
   - Dynamic fees during volatility
   - LP tracking for fair distribution
   - Community governance
   - Transparent operations

## Gas Optimization

### Hook Efficiency

- Minimal storage reads in hot paths
- Efficient fee calculation
- Batch LP tracking updates
- Optimized event emissions

### Reactive Efficiency

- Event-driven execution (no polling)
- Conditional callback triggering
- Batched price updates
- Optimized cross-chain calls

## Scalability

### Current Implementation

- Single currency pair (USD/NGN)
- Base chain deployment
- Reactive Network monitoring
- Community governance

### Future Expansion

- Multiple currency pairs (GHS, KES, etc.)
- Cross-chain liquidity routing
- Additional yield sources
- Advanced batching logic

## Integration Points

### Uniswap v4

- Hook address must be deployed to specific address
- Pool initialization with hook
- Dynamic fee flag enabled
- Hook permissions configured

### Reactive Network

- Event subscription setup
- Callback proxy configuration
- System contract integration
- Cross-chain messaging

### Price Oracles

- Chainlink for production
- Pyth as alternative
- Custom oracle support
- Event format compatibility

### Lending Protocols (Future)

- Aave integration for yield
- Compound support
- Automated capital deployment
- Instant withdrawal on demand

## Monitoring & Observability

### Events

```solidity
// Hook Events
event PoolPausedByVolatility(PoolId indexed poolId, uint256 priceChange);
event PoolResumed(PoolId indexed poolId);
event DynamicFeeUpdated(PoolId indexed poolId, uint24 newFee);
event CommunityLPAdded(address indexed lp, uint256 amount);
event CommunityLPRemoved(address indexed lp, uint256 amount);

// Reactive Events
event VolatilityDetected(address indexed pool, uint256 priceChange, uint256 timestamp);
event PoolPauseTriggered(address indexed pool, uint256 priceChange);
event PoolResumeTriggered(address indexed pool);
event PriceUpdated(address indexed pool, uint256 newPrice);
```

### Metrics to Track

- Swap volume and frequency
- Fee revenue by volatility level
- Pause/resume frequency
- LP participation
- Price volatility patterns
- Gas costs per operation

## Testing Strategy

### Unit Tests

- Individual function testing
- Edge case coverage
- Access control verification
- Parameter validation

### Integration Tests

- Hook + PoolManager interaction
- Reactive + Hook callbacks
- Oracle + Reactive events
- End-to-end flows

### Scenario Tests

- Normal market conditions
- High volatility events
- Emergency pauses
- LP lifecycle
- Governance actions

### Gas Benchmarking

- Swap costs with hook
- Callback execution costs
- LP operations
- Governance updates

## Deployment Checklist

### Pre-Deployment

- [ ] Audit smart contracts
- [ ] Test on testnet
- [ ] Verify oracle feeds
- [ ] Configure Reactive Network
- [ ] Set up governance multisig
- [ ] Prepare documentation

### Deployment

- [ ] Deploy CorridorHook
- [ ] Deploy CorridorReactive
- [ ] Connect contracts
- [ ] Initialize pool
- [ ] Subscribe to oracle events
- [ ] Test with small amounts

### Post-Deployment

- [ ] Monitor events
- [ ] Track metrics
- [ ] Engage community
- [ ] Iterate based on feedback
- [ ] Scale gradually

## Future Enhancements

### Phase 2

- Additional currency pairs
- Yield optimization integration
- Transaction batching
- Mobile app interface

### Phase 3

- Cross-chain routing
- Advanced IL strategies
- Institutional partnerships
- Regulatory compliance

### Phase 4

- Global expansion
- Additional DeFi integrations
- Governance token
- DAO structure
