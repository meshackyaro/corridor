# Corridor Demo: How It Works

This document walks through real-world scenarios showing how Corridor protects community LPs and reduces remittance costs.

## Scenario 1: Normal Remittance Flow

### Setup

- **User**: Chioma in London wants to send £200 to her family in Lagos
- **Pool**: USD/NGN liquidity pool with $100K TVL
- **Market**: Stable conditions, NGN trading at ₦1,650/$1
- **Fee**: 0.3% (base fee)

### Flow

```
1. Chioma converts £200 → $250 USD

2. Chioma initiates swap: $250 USD → NGN
   ↓
3. Transaction hits Uniswap v4 PoolManager
   ↓
4. PoolManager calls Hook.beforeSwap()
   ├─ Check: Is pool paused? ✓ No
   ├─ Check: Current volatility? ✓ Low (2%)
   └─ Return: Dynamic fee = 0.3%
   ↓
5. Swap executes
   ├─ Input: $250 USD
   ├─ Fee: $0.75 (0.3%)
   ├─ Output: ₦411,562.50
   └─ Family receives: ₦411,562.50
   ↓
6. Hook.afterSwap() logs activity
   ↓
7. Community LPs earn $0.75 in fees
```

### Result

- **Traditional cost**: £200 × 8.37% = £16.74 ($20.93)
- **Corridor cost**: $0.75
- **Savings**: $20.18 (96% reduction)
- **Family receives**: 99.7% of value

---

## Scenario 2: High Volatility Protection

### Setup

- **Event**: Central Bank of Nigeria announces policy change
- **Impact**: NGN drops 8% in 30 minutes
- **Pool**: USD/NGN with active swaps
- **Reactive**: Monitoring price oracle

### Flow

```
1. CBN announces policy at 10:00 AM
   ↓
2. NGN/USD price drops from ₦1,650 to ₦1,782 (-8%)
   ↓
3. Price Oracle emits PriceUpdated event
   ↓
4. Reactive Network detects event
   ├─ Current price: ₦1,782/$1
   ├─ Last price: ₦1,650/$1
   ├─ Change: 8% (800 basis points)
   └─ Threshold: 5% (500 basis points)
   ↓
5. Volatility exceeds threshold!
   ↓
6. CorridorReactive.react() executes
   ├─ Calculate: 8% > 5% threshold
   ├─ Decision: PAUSE POOL
   └─ Trigger callback to Base
   ↓
7. Callback executes on Base
   ├─ CorridorHook.pausePool(poolId, 800)
   ├─ poolPaused[poolId] = true
   └─ Emit PoolPausedByVolatility
   ↓
8. User tries to swap
   ├─ Hook.beforeSwap() called
   ├─ Check: poolPaused[poolId]? ✓ Yes
   └─ Revert: "PoolPaused"
   ↓
9. 2 hours later: Market stabilizes at ₦1,700
   ├─ Price change: 3% from original
   ├─ Below threshold: 3% < 5%
   └─ Reactive triggers resumePool()
   ↓
10. Pool resumes normal operations
```

### Result

- **LP Protection**: No swaps during extreme volatility
- **IL Avoided**: ~$8,000 in potential IL for $100K pool
- **Community Safe**: Automated protection without manual intervention
- **Resume**: Automatic when conditions normalize

---

## Scenario 3: Dynamic Fee Adjustment

### Setup

- **Market**: Moderate volatility (3.5%)
- **Pool**: USD/NGN active
- **Fee Range**: 0.3% - 1%

### Flow

```
1. Morning (Low Volatility - 1.5%)
   ├─ Reactive monitors: 1.5% < 5% threshold
   ├─ Fee calculation: 30 + (150 × 70 / 500) = 51 bps
   └─ Dynamic fee: 0.51%

2. Afternoon (Moderate Volatility - 3.5%)
   ├─ Reactive monitors: 3.5% < 5% threshold
   ├─ Fee calculation: 30 + (350 × 70 / 500) = 79 bps
   └─ Dynamic fee: 0.79%

3. Evening (High Volatility - 6%)
   ├─ Reactive monitors: 6% > 5% threshold
   ├─ Fee calculation: Max fee
   └─ Dynamic fee: 1%

4. Night (Stabilized - 2%)
   ├─ Reactive monitors: 2% < 5% threshold
   ├─ Fee calculation: 30 + (200 × 70 / 500) = 58 bps
   └─ Dynamic fee: 0.58%
```

### Result

- **Risk-Adjusted Pricing**: Higher fees during risky periods
- **LP Protection**: Compensated for increased risk
- **User Transparency**: Predictable fee structure
- **Automated**: No manual intervention needed

---

## Scenario 4: Community LP Journey

### Setup

- **LP**: Adebayo in Abuja with $1,000 to invest
- **Goal**: Earn yield while supporting remittances
- **Pool**: USD/NGN corridor

### Flow

```
1. Adebayo adds liquidity
   ├─ Deposit: $500 USD + ₦825,000 NGN
   ├─ Hook.beforeAddLiquidity() called
   ├─ communityLPShares[Adebayo] += 1
   ├─ totalCommunityShares += 1
   └─ Emit CommunityLPAdded

2. Week 1: Normal operations
   ├─ Swap volume: $50,000
   ├─ Average fee: 0.4%
   ├─ Total fees: $200
   ├─ Adebayo's share: $200 × (1/100) = $2
   └─ APR: ~20%

3. Week 2: High volatility event
   ├─ Pool paused for 4 hours
   ├─ IL avoided: ~$80 for Adebayo's position
   ├─ Fees during volatility: 1%
   ├─ Extra earnings: $50 × (1/100) = $0.50
   └─ Protected + Earned

4. Month 1: Results
   ├─ Total fees earned: $8.50
   ├─ IL avoided: $80
   ├─ Net benefit: $88.50 vs $8.50 unprotected
   └─ APR: 102% (with IL protection value)

5. Adebayo removes liquidity
   ├─ Hook.beforeRemoveLiquidity() called
   ├─ communityLPShares[Adebayo] -= 1
   ├─ Receives: Original + fees + yield
   └─ Emit CommunityLPRemoved
```

### Result

- **Yield Generated**: $8.50/month on $1,000
- **IL Protected**: $80 saved
- **Community Benefit**: Supporting 200+ remittances
- **Cultural Alignment**: Modern esusu/ajo

---

## Scenario 5: Emergency Governance Action

### Setup

- **Event**: Unexpected oracle failure
- **Risk**: Incorrect price data
- **Action**: Community governance intervenes

### Flow

```
1. Oracle reports incorrect price
   ├─ Shows: ₦2,500/$1 (should be ₦1,650)
   ├─ Reactive would trigger pause
   └─ But data is wrong!

2. Community notices issue
   ├─ Discord alert
   ├─ Governance multisig convenes
   └─ Decision: Manual intervention

3. Governance executes
   ├─ Call: hook.pausePool(poolId, 0)
   ├─ Reason: "Oracle malfunction"
   └─ Pool paused immediately

4. Team investigates
   ├─ Identify: Oracle contract bug
   ├─ Solution: Switch to backup oracle
   └─ Deploy fix

5. Governance updates
   ├─ Call: reactive.setPriceOracle(newOracle)
   ├─ Verify: New oracle working
   └─ Call: hook.resumePool(poolId)

6. Operations resume
   ├─ Correct price data
   ├─ Community protected
   └─ Transparency maintained
```

### Result

- **Community Protected**: No losses from bad data
- **Governance Works**: Quick response
- **Transparency**: All actions on-chain
- **Trust Built**: Community sees protection in action

---

## Scenario 6: Yield Optimization (Future)

### Setup

- **Time**: 2 AM Lagos time (low activity)
- **Pool**: $100K idle liquidity
- **Opportunity**: Aave lending at 5% APY

### Flow (Planned)

```
1. Reactive monitors swap activity
   ├─ Last swap: 3 hours ago
   ├─ Typical idle period: 6 hours
   └─ Decision: Deploy to Aave

2. Automated deployment
   ├─ Amount: $80K (keep $20K for swaps)
   ├─ Protocol: Aave v3
   ├─ Asset: USDC
   └─ Earning: 5% APY

3. Morning: Swap demand returns
   ├─ User initiates $5K swap
   ├─ Available: $20K in pool
   └─ Executes normally

4. Larger swap needed
   ├─ User wants $25K swap
   ├─ Available: $20K
   ├─ Reactive detects
   ├─ Withdraws $10K from Aave
   └─ Swap executes

5. Daily results
   ├─ Swap fees: $50
   ├─ Aave yield: $11 (for 6 hours)
   ├─ Total: $61 vs $50 without optimization
   └─ 22% yield boost
```

### Result

- **Capital Efficiency**: 22% higher yields
- **No User Impact**: Instant liquidity
- **Automated**: No manual management
- **Community Benefit**: More earnings for LPs

---

## Key Metrics Summary

### Cost Comparison

| Method           | Fee     | Amount Received (£200) |
| ---------------- | ------- | ---------------------- |
| Western Union    | 8.37%   | £183.26                |
| Traditional Bank | 6.5%    | £187.00                |
| Corridor         | 0.3%    | £199.40                |
| **Savings**      | **96%** | **+£16.14**            |

### LP Protection

| Scenario        | Without Corridor | With Corridor | Benefit |
| --------------- | ---------------- | ------------- | ------- |
| Normal          | $8/month         | $8.50/month   | +6%     |
| High Volatility | -$80 IL          | $0 IL         | +$80    |
| With Yield Opt  | $8/month         | $9.76/month   | +22%    |

### Community Impact

- **Remittances Served**: 200+/month per $100K pool
- **Savings Generated**: $4,000+/month for families
- **LP Earnings**: $850+/month
- **IL Protected**: $8,000+/month

---

## Try It Yourself

### Testnet Demo

```bash
# 1. Get testnet tokens
# Visit Base Sepolia faucet

# 2. Add liquidity
cast send $POOL_MANAGER "addLiquidity(...)" \
  --rpc-url $BASE_SEPOLIA_RPC

# 3. Perform swap
cast send $POOL_MANAGER "swap(...)" \
  --rpc-url $BASE_SEPOLIA_RPC

# 4. Simulate volatility
cast send $MOCK_ORACLE "simulateVolatility(...)" \
  --rpc-url $BASE_SEPOLIA_RPC

# 5. Watch pool pause
cast call $HOOK "poolPaused(bytes32)" $POOL_ID \
  --rpc-url $BASE_SEPOLIA_RPC
```

### Monitor Events

```bash
# Watch for volatility events
cast logs --address $REACTIVE_CONTRACT \
  --event "VolatilityDetected(address,uint256,uint256)" \
  --rpc-url $REACTIVE_RPC

# Watch for pause events
cast logs --address $HOOK \
  --event "PoolPausedByVolatility(bytes32,uint256)" \
  --rpc-url $BASE_SEPOLIA_RPC
```

---

## Conclusion

Corridor demonstrates how combining Uniswap v4 hooks with Reactive Network automation can:

1. **Reduce Costs**: 96% fee reduction for remittances
2. **Protect LPs**: Automated IL protection during volatility
3. **Generate Yield**: Sustainable returns for community
4. **Empower Communities**: Collective ownership and governance
5. **Scale Impact**: Serve millions across Africa

**Built for the community, powered by the community.**
