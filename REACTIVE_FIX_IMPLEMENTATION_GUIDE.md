# Corridor — Reactive (Lasna) ↔ Unichain Live Deployment: Implementation Guide

> **Audience:** an LLM/engineer implementing the fixes that make Corridor's cross-chain
> automation actually fire on **Unichain Sepolia (1301)** and **Reactive Lasna (5318007)**.
>
> **Source of truth:** A *working* reference project exists locally at
> `/Users/admin/scratchin/contract`. It uses the **real** `reactive-lib`, deploys a v4 hook,
> and runs the exact same Lasna ↔ Unichain loop. **When in doubt, copy its patterns
> verbatim.** Key reference files:
> - `/Users/admin/scratchin/contract/src/ReactiveReveal.sol` — the RSC (reactive contract)
> - `/Users/admin/scratchin/contract/src/ScratchHook.sol` — the v4 hook
> - `/Users/admin/scratchin/contract/src/ScratchCard.sol` — destination callback auth pattern
> - `/Users/admin/scratchin/contract/script/Deploy.s.sol` & `DeployReactive.s.sol`
> - `/Users/admin/scratchin/contract/foundry.toml` — remappings
> - `/Users/admin/scratchin/contract/lib/reactive-lib/src/...` — the real interfaces

---

## 0. Why the current Corridor code does NOT work (read this first)

The current Corridor cross-chain layer is written against an **invented** Reactive API. It
compiles and unit-tests pass *only because the tests mock the parts that are wrong*. On a real
network nothing fires. There are **three hard blockers** plus several secondary issues. Every
one of them is already solved in the `scratchin` reference — this guide maps each fix to that
reference.

| # | Blocker | Current (broken) | Real pattern (from scratchin) |
|---|---------|------------------|-------------------------------|
| 1 | Invented Reactive SDK | hand-rolled `src/interfaces/IReactive.sol` with 9-arg `react(...)`, local `IReactiveSystem`, `CALLBACK_PROXY.call("sendCallback(...)")` | inherit `AbstractReactive`; `react(LogRecord calldata log)`; `emit Callback(chainId, target, gasLimit, payload)`; `service.subscribe(...)` in constructor |
| 2 | Hook address not mined | `new CorridorHook(...)` → random address → `PoolManager.initialize` reverts `HookAddressNotValid` | mine CREATE2 salt with `HookMiner` so address low bits == permission flags |
| 3 | Event decode wrong | `abi.decode(data,(PoolId,uint256))` but `poolId` is an **indexed** topic, not in `data` | read `poolId` from `log.topic_1`, `newPrice` from `log.data` |

Secondary (all real, fix them): callback `rvm_id` first-arg, destination must authorize the
**Callback Proxy** (not the RSC), RSC must be **funded with REACT**, callback **gas limit** must
be generous, lossy `PoolId→address` casts, LP "shares" counter is fake, no `CreatePool` script,
wrong Lasna RPC in docs.

---

## 1. Canonical network constants (USE THESE EXACTLY)

> ⚠️ The current `README.md`/`DEPLOYMENT_GUIDE.md` use `https://lasna-omni-rpc.rnk.dev/`.
> The reference uses **`https://lasna-rpc.rnk.dev`**. Use the reference value.

```
Unichain Sepolia
  chainId           : 1301
  RPC               : https://sepolia.unichain.org
  Explorer          : https://unichain-sepolia.blockscout.com   (or https://sepolia.uniscan.xyz)
  v4 PoolManager    : 0x00B036B58a818B1BC34d502D3fE730Db729e62AC   (verify on explorer before deploy)

Reactive Lasna
  chainId           : 5318007
  RPC               : https://lasna-rpc.rnk.dev
  System contract   : 0x0000000000000000000000000000000000fffFfF   (provided by AbstractReactive as SERVICE_ADDR)
  Faucet            : https://dev.reactive.network/docs/faucet

Callback Proxy on Unichain Sepolia (destination chain)
  0x9299472A6399Fd1027ebF067571Eb3e3D7837FC4
```

**Critical distinction:** the Callback Proxy address above lives **on Unichain** and is the
`msg.sender` when the RSC's callback executes on the hook. The hook must authorize THIS proxy
address — **not** the RSC's Lasna address. (Current Corridor wrongly expects the RSC address.)

---

## 2. Toolchain & dependency setup

### 2.1 Add the real submodules (`.gitmodules`)

Corridor currently has only `forge-std` + `v4-core`. Add `reactive-lib`, `v4-periphery`,
and `openzeppelin-contracts`:

```bash
forge install Reactive-Network/reactive-lib
forge install Uniswap/v4-periphery
forge install OpenZeppelin/openzeppelin-contracts
```

### 2.2 `foundry.toml` — copy the reference remappings

Replace Corridor's bare `foundry.toml` with (mirrors `scratchin/contract/foundry.toml`):

```toml
[profile.default]
src = "src"
out = "out"
libs = ["lib"]
solc_version = "0.8.26"           # bump from 0.8.24 — reactive-lib needs >=0.8.0, ref uses 0.8.26
optimizer = true
optimizer_runs = 200
via_ir = false
remappings = [
  "@openzeppelin/=lib/openzeppelin-contracts/",
  "v4-core/=lib/v4-core/",
  "v4-periphery/=lib/v4-periphery/",
  "forge-std/=lib/forge-std/src/",
  "reactive-lib/=lib/reactive-lib/src/"
]

[rpc_endpoints]
unichain_sepolia = "${UNICHAIN_SEPOLIA_RPC}"
reactive_lasna   = "${REACTIVE_LASNA_RPC}"

[etherscan]
unichain_sepolia = { key = "${ETHERSCAN_API_KEY}", url = "https://unichain-sepolia.blockscout.com/api" }
reactive_lasna   = { key = "${ETHERSCAN_API_KEY}", url = "https://lasna.reactscan.net/api" }
```

> **KEYNOTE:** bumping to `0.8.26` means every `pragma solidity ^0.8.24;` in `src/` and
> `script/` should become `^0.8.26` (or leave `^0.8.24` — it's compatible, but match the
> reference to avoid surprises). Do a repo-wide check.

### 2.3 DELETE the invented interface

Delete `src/interfaces/IReactive.sol` entirely and the `IReactiveSystem` interface at the
bottom of `src/CorridorReactive.sol`. They are the root cause of Blocker 1. Import the real
ones from `reactive-lib` instead.

---

## 3. Blocker 1 — Rewrite `CorridorReactive` on the real `reactive-lib`

Model this **directly** on `scratchin/contract/src/ReactiveReveal.sol`. Key rules baked into
that file's comments (do not re-discover them the hard way):

- Inherit `AbstractReactive`. It gives you: `service` (the system contract), `vm` (am I inside
  a ReactVM?), `REACTIVE_IGNORE`, modifiers `rnOnly`/`vmOnly`, and `emit Callback(...)`.
- **Subscribe in the constructor**, guarded by `if (!vm)`. Subscriptions only register when
  called from the RSC's own constructor on the Reactive Network side. A later external
  `subscribe()` tx (what current Corridor's deploy implies) does NOT reliably register — and
  the ReactVM never starts delivering events.
- Make the constructor `payable` so REACT can be sent **with** the deploy tx (subscription
  must be funded from birth).
- `react(LogRecord calldata log)` must be gated with `vmOnly` — **not** an ACL/`onlySystem`
  check. Inside the ReactVM the caller is the VM, not `SERVICE_ADDR`; an ACL check reverts and
  silently swallows every event.
- Emit the callback via `emit Callback(chainId, targetContract, gasLimit, payload)`. Do **not**
  call a proxy method.
- The Reactive Callback Proxy **injects the RVM id as the FIRST argument** of the callback.
  So the destination function signature must start with `address rvm_id`. Encode `address(0)`
  as a placeholder in that first slot — the proxy overwrites it.

### 3.1 Reference `react()` decode — fix Blocker 3 here too

`MockPriceOracle` emits `event PriceUpdated(bytes32 indexed poolId, uint256 newPrice)`.
Because `poolId` is **indexed**, it lands in `topic_1`; only `newPrice` is in `data`.

```solidity
function react(LogRecord calldata log) external override vmOnly {
    // defensive filtering (subscription already scopes these)
    if (log.chain_id != DESTINATION_CHAIN_ID) return;
    if (log._contract != priceOracle)         return;
    if (log.topic_0 != PRICE_UPDATED_TOPIC0)  return;

    PoolId poolId   = PoolId.wrap(bytes32(log.topic_1));   // indexed → topic_1
    uint256 newPrice = abi.decode(log.data, (uint256));    // non-indexed → data

    _checkVolatility(poolId, newPrice);                     // existing logic is fine
}
```

`PRICE_UPDATED_TOPIC0 = uint256(keccak256("PriceUpdated(bytes32,uint256)"))`.

### 3.2 Callback emission — replace `_sendCallback`

Delete `_sendCallback` and its `CALLBACK_PROXY.call(...)`. In `_pausePool` / `_resumePool` /
`_updateFee`, emit `Callback` with a generous gas limit and the **`rvm_id`-first** payload:

```solidity
uint64 private constant CALLBACK_GAS_LIMIT = 500_000;  // see KEYNOTE on gas below

// pause:
bytes memory payload = abi.encodeWithSignature(
    "pausePool(address,bytes32,uint256)", address(0), PoolId.unwrap(poolId), priceChange);
emit Callback(DESTINATION_CHAIN_ID, corridorHook, CALLBACK_GAS_LIMIT, payload);
```

> **KEYNOTE — GAS (the user specifically flagged this):** The reference learned the hard way
> that a 200k callback gas limit caused the destination callback to run **out of gas and revert
> with panic 0x11**, leaving state stuck. It raised the limit to **500_000**. For Corridor's
> `pausePool`/`resumePool`/`updatePoolFee` (cheap storage writes + event) 500k is *very* safe;
> do **not** go below ~150k. Pick **500_000** to match the reference and avoid the exact failure
> the user is worried about. Also remember: the gas for the destination tx is paid in the
> **destination chain's gas token by the funded Callback Proxy**, while the RSC's own
> subscription/callback *debt* is settled in **REACT on Lasna** — so BOTH must be funded
> (§6, §7).

### 3.3 Other cleanups in `CorridorReactive`

- Remove `SYSTEM_CONTRACT`/`CALLBACK_PROXY` immutables and the `onlySystem` modifier — they
  come from `AbstractReactive` now (`SERVICE_ADDR`, proxy is implicit via `emit Callback`).
- Keep `corridorHook`, `priceOracle`, `volatilityThreshold`, `lastPrices`, `poolPaused`,
  `_checkVolatility`, and the volatility math — **that logic is correct**, only its plumbing
  was wrong.
- Add an owner-only `subscribe()`/`unsubscribe()` re-arm path guarded with `rnOnly` (see ref
  `subscribe()` / `setScratchCard()`), in case a subscription goes inactive.
- Fix the **lossy casts**: stop doing `address(uint160(uint256(PoolId.unwrap(poolId))))` in
  events. Either change event params to `bytes32`/`PoolId`, or index the real `PoolId`. Truncating
  a bytes32 pool id into an address produces meaningless values.

---

## 4. Blocker 2 — Mine the hook address (CREATE2) so v4 will accept it

In Uniswap v4 the **enabled hook callbacks are encoded in the low bits of the hook's address**.
A plain `new CorridorHook(...)` yields a random address; `PoolManager.initialize` then reverts
`HookAddressNotValid`. The reference documents this in `ScratchHook.sol` ("hook address must be
mined… Use a CREATE2 deployer / HookMiner") with the flag comment `bit 0x0080 set (afterSwap)`.

### 4.1 Determine Corridor's flags

The README claims 9 permissions, but the **implementation only does meaningful work in**:
`beforeSwap` (pause check + dynamic fee). `beforeAddLiquidity`/`beforeRemoveLiquidity` only bump
a fake counter (see §8 — recommend removing). **Minimize the flag set** — every enabled flag is
an address bit you must mine and a callback v4 will invoke.

Recommended minimal permission set:
- `BEFORE_INITIALIZE_FLAG` (sets base dynamic fee) — optional, can move to pool init args
- `BEFORE_SWAP_FLAG` (required: pause check + returns dynamic fee)

If you keep LP tracking, add `BEFORE_ADD_LIQUIDITY_FLAG` / `BEFORE_REMOVE_LIQUIDITY_FLAG`, but
prefer to **make the tracking real or drop it** (§8).

### 4.2 Use `HookMiner` in the deploy script

```solidity
import {HookMiner} from "v4-periphery/src/utils/HookMiner.sol";
import {Hooks} from "v4-core/src/libraries/Hooks.sol";

uint160 flags = uint160(Hooks.BEFORE_SWAP_FLAG | Hooks.BEFORE_INITIALIZE_FLAG);
bytes memory args = abi.encode(IPoolManager(POOL_MANAGER), governance, VOLATILITY_THRESHOLD);
(address hookAddr, bytes32 salt) =
    HookMiner.find(CREATE2_DEPLOYER, flags, type(CorridorHook).creationCode, args);

vm.startBroadcast();
CorridorHook hook = new CorridorHook{salt: salt}(IPoolManager(POOL_MANAGER), governance, VOLATILITY_THRESHOLD);
require(address(hook) == hookAddr, "hook address mismatch");
```

`CREATE2_DEPLOYER` is the canonical deterministic deployer
`0x4e59b44847b379578588920cA78FbF26c0B4956C` (present on Unichain Sepolia).

> **KEYNOTE:** `CorridorHook`'s declared `IHooks` functions must **exactly match** the mined
> flags. If the address says "beforeSwap only" but the contract also expects PoolManager to call
> `beforeAddLiquidity`, those calls simply won't happen. Align the three: (a) flags in miner,
> (b) which `IHooks` methods contain real logic, (c) what the README advertises.

### 4.3 Dynamic fee flag (so the returned fee is actually honored)

`beforeSwap` returns `poolDynamicFee[poolId]`, but v4 ignores a hook-returned fee unless:
1. the pool is initialized with `key.fee = LPFeeLibrary.DYNAMIC_FEE_FLAG` (`0x800000`), and
2. `beforeSwap` returns the fee **OR'd with** `LPFeeLibrary.OVERRIDE_FEE_FLAG`.

Set both, or the "dynamic fee" feature is dead even after the address is fixed. The pool's
`key.fee` is decided in the `CreatePool` script (§5).

---

## 5. NEW: `CreatePool` script (the loop has nothing to protect without a pool)

There is currently **no script that initializes a v4 pool**. Add `script/CreatePool.s.sol`:

1. Choose two tokens (e.g. test USDC + test NGN ERC20s; deploy mocks if needed).
2. Build `PoolKey{ currency0, currency1, fee: DYNAMIC_FEE_FLAG, tickSpacing, hooks: hookAddr }`.
3. Call `PoolManager.initialize(key, sqrtPriceX96)`.
4. Compute `poolId = key.toId()` and **log it** — this exact `bytes32` must be fed to:
   - the price-updater `.env` (`POOL_ID`), and
   - whatever seeds `lastPrices` in the RSC.
5. (Optional) add liquidity via the v4 position manager / a router so swaps can execute.

> **KEYNOTE — pool-id consistency is the #1 silent failure:** the same `bytes32 poolId` must
> flow oracle.updatePrice(poolId,…) → `PriceUpdated` topic_1 → RSC `_checkVolatility` →
> callback `pausePool(poolId)` → hook `poolPaused[poolId]`. If the updater uses a different
> poolId than the pool's real `key.toId()`, everything "runs" but nothing ever pauses. There's
> already a helper at `price-updater/scripts/getPoolId.ts` — wire it to the deployed key.

---

## 6. Destination-side authorization — hook must trust the Callback Proxy

The RSC's callback executes on Unichain via the **Callback Proxy**
(`0x9299472A6399Fd1027ebF067571Eb3e3D7837FC4`). That proxy is the `msg.sender` on the hook.

The hook's `pausePool`/`resumePool`/`updatePoolFee` currently require
`msg.sender == reactiveContract`. **That's wrong** — `reactiveContract` is the RSC's *Lasna*
address, which never calls Unichain directly. Mirror the reference's `ScratchCard`:

1. Change the callback signatures to take the injected `rvm_id` first:
   ```solidity
   function pausePool(address /* rvm_id */, PoolId poolId, uint256 priceChange) external { ... }
   function resumePool(address /* rvm_id */, PoolId poolId) external { ... }
   function updatePoolFee(address /* rvm_id */, PoolId poolId, uint256 volatilityBps) external { ... }
   ```
2. Authorize the **proxy** (rename `reactiveContract` → `reactiveCallbackProxy` for clarity):
   ```solidity
   if (msg.sender != reactiveCallbackProxy && msg.sender != communityGovernance) revert Unauthorized();
   ```
3. `ConnectContracts.s.sol` (or a `cast send`) sets it to the **proxy address**, not the RSC:
   ```
   hook.setReactiveContract(0x9299472A6399Fd1027ebF067571Eb3e3D7837FC4)
   ```
   (Reference does: `setReactiveRevealer(<CALLBACK_PROXY>)`.)

> **KEYNOTE:** The `rvm_id` first arg is non-negotiable — if the destination function omits it,
> the ABI won't match what the proxy calls and the callback reverts. Keep the param even though
> it's unused.

---

## 7. Deployment runbook (end to end, in order)

> Prereq: one deployer wallet funded on **both** chains — Unichain Sepolia ETH (bridge/faucet)
> **and** Lasna REACT (faucet). The reference's `.env.example` stresses "this wallet needs
> testnet funds on BOTH chains."

```bash
# ── .env ─────────────────────────────────────────────────────────────────────
PRIVATE_KEY=0x...
UNICHAIN_SEPOLIA_RPC=https://sepolia.unichain.org
REACTIVE_LASNA_RPC=https://lasna-rpc.rnk.dev
GOVERNANCE_ADDRESS=0x...            # optional, defaults to deployer
ETHERSCAN_API_KEY=...               # for --verify (blockscout)
```

**Step 1 — Unichain: deploy Oracle + Hook (mined) + Pool**
```bash
forge script script/DeployToUnichain.s.sol --rpc-url unichain_sepolia --broadcast --verify -vvvv
# logs: MockPriceOracle, CorridorHook (mined addr)
forge script script/CreatePool.s.sol      --rpc-url unichain_sepolia --broadcast -vvvv
# logs: POOL_ID (bytes32)  ← save it
```
Save `CORRIDOR_HOOK`, `PRICE_ORACLE`, `POOL_ID` to `.env`.

**Step 2 — Lasna: deploy RSC, funded with REACT in the SAME tx**
```bash
forge script script/DeployToReactive.s.sol --rpc-url reactive_lasna --broadcast -vvvv
```
The script must `new CorridorReactive{value: 0.5 ether}(...)` (or send REACT immediately after)
exactly like the reference's `RSC_REACT_FUND = 0.5 ether`. The constructor subscribes; funding
keeps the subscription active.

**Step 3 — Unichain: authorize the Callback Proxy on the hook**
```bash
cast send $CORRIDOR_HOOK "setReactiveContract(address)" \
  0x9299472A6399Fd1027ebF067571Eb3e3D7837FC4 \
  --rpc-url unichain_sepolia --private-key $PRIVATE_KEY
```

**Step 4 — Fund the Callback Proxy on Unichain** so it can pay destination gas (per Reactive
docs `depositTo`/`reserveFunds` flow). Without this, callbacks are emitted on Lasna but never
land on Unichain.

**Step 5 — seed `lastPrices`** so the first real update computes a delta (the RSC treats the
first price as a baseline and returns early). Either call `manualCheckVolatility(poolId, p0)`
(owner-only, on Lasna) or just accept that the *second* oracle update is the first that can
trigger a pause.

**Step 6 — start the price-updater** (§9) pointed at the deployed oracle + real `POOL_ID`.

---

## 8. Secondary fixes (do these too — they affect "real users")

1. **Fake LP accounting.** `communityLPShares[sender] += 1` counts *calls*, not capital, so
   "fair yield distribution" is impossible and there is **no yield mechanism at all** (the
   Aave/Compound "sustainable yield" in the README is entirely unimplemented). Either:
   - (a) implement real share tracking from the `ModifyLiquidityParams.liquidityDelta`, or
   - (b) **remove** the LP-tracking hooks and the matching README claims to avoid misleading
     users. Recommended for a first live deploy: (b), then add real accounting later.
2. **Remove unimplemented marketing** from README/`HOOKATHON_SUBMISSION.md` (idle-capital
   lending, gas batching) or clearly mark "planned, not deployed."
3. **Fix docs RPC** everywhere: `lasna-omni-rpc.rnk.dev` → `lasna-rpc.rnk.dev`. Update
   chainId references: the RSC's `DESTINATION_CHAIN_ID = 1301` is correct; Lasna itself is
   `5318007` (only needed where you reference the network chain id, not the destination).
4. **`PoolId`/`address` lossy casts** in `CorridorReactive` events (§3.3).
5. **Verify the v4 `PoolManager` address** `0x00B036B58a818B1BC34d502D3fE730Db729e62AC` on the
   explorer before deploy — testnet addresses move.

---

## 9. price-updater changes

The service itself is solid (retries, gas multiplier, balance checks). Required wiring only:

- `POOL_ID` in `.env` **must equal** `key.toId()` from the `CreatePool` script (§5).
- `MOCK_ORACLE_ADDRESS` = deployed oracle.
- The updater's wallet must be the oracle **owner** (`updatePrice` is `onlyOwner`) — either
  deploy the oracle from the same key, or `transferOwnership` to the updater wallet.
- `UPDATE_INTERVAL`: keep ≥ 60s on testnet; each update is an on-chain tx that triggers the
  whole Lasna→Unichain loop. For a **demo of pausing**, call
  `MockPriceOracle.simulateVolatility(poolId, 600, false)` (6% > 5% threshold) once and watch
  the pool pause, then a smaller move (<2.5%) to resume.

---

## 10. End-to-end verification (don't claim "real-time" until you see this trace)

1. Oracle update tx on Unichain → emits `PriceUpdated(poolId, price)`.
2. On Lasna explorer (`https://lasna.reactscan.net`), the RSC shows an inbound event and an
   emitted `Callback`.
3. Callback Proxy lands a tx on Unichain calling `hook.pausePool(rvm_id, poolId, change)`.
4. Hook emits `PoolPausedByVolatility(poolId, change)`; `poolPaused[poolId] == true`.
5. A swap on that pool now **reverts with `PoolPaused`**.
6. A normalizing price update → `resumePool` → swaps succeed again.

If step 3 never happens: check (a) RSC funded with REACT, (b) subscription active on Lasna,
(c) Callback Proxy funded on Unichain, (d) callback gas limit ≥ 150k (use 500k), (e) hook
authorizes the **proxy** address. These five are the entire failure surface.

---

## 11. Common mistakes checklist (paste into PR description)

- [ ] Did NOT hand-roll the Reactive interface — inherited `AbstractReactive`, imported real `IReactive`.
- [ ] `react(LogRecord)` is `vmOnly`, **not** ACL-gated.
- [ ] `subscribe()` called in the **constructor** under `if (!vm)`; constructor is `payable`.
- [ ] RSC **funded with REACT** in/right after the deploy tx (~0.5 REACT).
- [ ] `poolId` read from `topic_1`, `newPrice` from `data` (not both from `data`).
- [ ] Callback payload puts `address rvm_id` **first** (placeholder `address(0)`).
- [ ] Callback **gas limit = 500_000** (avoids the out-of-gas panic the reference hit at 200k).
- [ ] Hook deployed via **CREATE2 + HookMiner**; `address(hook) == minedAddr` asserted.
- [ ] Mined flags == the `IHooks` methods that actually do work == README claims.
- [ ] Pool initialized with `DYNAMIC_FEE_FLAG`; `beforeSwap` returns fee `| OVERRIDE_FEE_FLAG`.
- [ ] Hook authorizes the **Callback Proxy** (`0x9299...7FC4`), not the RSC's Lasna address.
- [ ] Destination callback fns take `address rvm_id` first arg.
- [ ] Callback **Proxy funded on Unichain** to pay destination gas.
- [ ] Same `bytes32 poolId` used by pool / oracle / updater / RSC.
- [ ] Lasna RPC is `lasna-rpc.rnk.dev` (not `lasna-omni-rpc`).
- [ ] Removed or implemented (not faked) LP tracking + yield claims.
- [ ] Deployer funded on BOTH Unichain Sepolia (ETH) and Lasna (REACT).
- [ ] Verified full trace in §10 on real testnets before claiming "live / real-time".
```