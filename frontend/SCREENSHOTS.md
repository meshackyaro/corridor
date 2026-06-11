# Corridor Frontend Screenshots & Visual Guide

Visual tour of the Corridor frontend interface.

## 🎨 Color Palette

```
Corridor Green:  #2D6A4F  ████████  Primary, Trust
Corridor Gold:   #D4AF37  ████████  Success, Prosperity
Corridor Orange: #E76F51  ████████  Energy, Community
Corridor Brown:  #8B4513  ████████  Earth, Stability
Corridor Cream:  #F4E9D7  ████████  Background, Warmth
Corridor Dark:   #1B263B  ████████  Text, Contrast
```

## 📱 Page Sections

### 1. Header & Navigation

```
┌─────────────────────────────────────────────────────────┐
│ [🔷 Corridor]              [Connect Wallet Button]     │
│  Community Remittance                                   │
└─────────────────────────────────────────────────────────┘
```

**Features:**

- Fixed glass-effect header
- Corridor logo with TrendingUp icon
- RainbowKit wallet connection
- Mobile responsive

---

### 2. Hero Section

```
┌─────────────────────────────────────────────────────────┐
│         [🌍 Powered by Uniswap v4 & Reactive]          │
│                                                         │
│           Send Money Home, Keep the Change             │
│                                                         │
│    Reducing African remittance costs from 8.37%        │
│              to <1% through community                  │
│                                                         │
│    [Send Remittance]  [Become Community LP]           │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │ Automated│  │  1,247   │  │  $2.4M   │            │
│  │IL Protect│  │Community │  │  Total   │            │
│  │   🛡️     │  │   LPs    │  │ Volume   │            │
│  └──────────┘  └──────────┘  └──────────┘            │
└─────────────────────────────────────────────────────────┘
```

**Elements:**

- Large gradient heading text
- Cost reduction visualization: ~~8.37%~~ → <1%
- Dual CTAs (Send / Provide)
- 3 trust indicator cards
- Pattern dot background
- Smooth animations on scroll

---

### 3. Impact Stats

```
┌─────────────────────────────────────────────────────────┐
│                   Impact at Scale                       │
│    Building infrastructure for African communities      │
│                                                         │
│ ┌───────┐ ┌───────┐ ┌───────┐ ┌───────┐              │
│ │  96%  │ │ $54B  │ │ 22M+  │ │   3   │              │
│ │  Cost │ │Market │ │Potential│ │Corridors│           │
│ │ Reduc │ │ Size  │ │ Users │ │ Active │              │
│ └───────┘ └───────┘ └───────┘ └───────┘              │
└─────────────────────────────────────────────────────────┘
```

**Visual Style:**

- 4-column grid (responsive)
- Icon-driven cards
- Color-coded by metric type
- Glass-effect backgrounds
- Hover animations

---

### 4. Remittance Calculator

```
┌─────────────────────────────────────────────────────────┐
│  🧮 See Your Savings                                    │
│     Compare remittance costs                            │
│                                                         │
│  How much are you sending? (USD)                        │
│  ┌─────────────────────────────────────────────────┐   │
│  │              $200                                │   │
│  └─────────────────────────────────────────────────┘   │
│  [────────●────────────────] $10 - $1000              │
│                                                         │
│  ┌──────────────────────── Western Union ─────────┐   │
│  │ Traditional method          -$16.74 (8.37%)    │   │
│  │ Family receives: $183.26                        │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌──────────────────────── Bank Transfer ────────┐    │
│  │ Traditional bank           -$13.00 (6.5%)      │    │
│  │ Family receives: $187.00                        │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌──────────────────── Corridor [BEST VALUE] ────┐    │
│  │ Community-powered          -$0.60 (0.3%)       │    │
│  │ Family receives: $199.40                        │   │
│  └─────────────────────────────────────────────────┘   │
│                                                         │
│  ┌────────────────────────────────────────────────┐   │
│  │ Annual Savings: $193.68/year                   │   │
│  │ Based on monthly $200 remittance               │   │
│  └────────────────────────────────────────────────┘   │
│                                                         │
│  [      Start Sending with Corridor      ]            │
└─────────────────────────────────────────────────────────┘
```

**Interactive Elements:**

- Number input + range slider
- Real-time calculation
- Color-coded comparison (red → orange → green)
- "Best Value" badge
- Gradient savings banner
- Clear CTA button

---

### 5. Live Pool Status

```
┌─────────────────────────────────────────────────────────┐
│               Live Pool Status                          │
│     Real-time monitoring powered by Reactive            │
│                                                         │
│  ┌──────────┐  ┌──────────────────────────────────┐   │
│  │ ⚡Active │  │   NGN/USD Price & Volatility     │   │
│  │ Swaps OK │  │                                   │   │
│  └──────────┘  │     1660 ┐                       │   │
│  ┌──────────┐  │          │   ╱╲                  │   │
│  │ 0.3% Fee │  │     1650 ┤  ╱  ╲╱╲              │   │
│  │ Base Fee │  │          │ ╱       ╲            │   │
│  └──────────┘  │     1640 └─────────╲╱           │   │
│  ┌──────────┐  │          00:00 08:00 16:00       │   │
│  │ 2.1%     │  │                                   │   │
│  │Volatility│  │  🛡️ IL Protection Active          │   │
│  │[████░░░] │  │  Reactive Network monitors...    │   │
│  └──────────┘  └──────────────────────────────────┘   │
│  ┌──────────┐                                         │
│  │ $847K    │                                         │
│  │ TVL      │                                         │
│  │ $123K    │                                         │
│  │24h Volume│                                         │
│  └──────────┘                                         │
└─────────────────────────────────────────────────────────┘
```

**Components:**

- Status cards (Active/Paused)
- Fee display with range
- Volatility with progress bar
- Line chart (Recharts)
- TVL & Volume metrics
- IL protection explainer

---

### 6. Community LP Section

```
┌─────────────────────────────────────────────────────────┐
│              Join the Community                         │
│  Modern infrastructure built on esusu, ajo, chama      │
│                                                         │
│  ┌─────────────────────┐  ┌──────────────────────┐    │
│  │ 💰 Why Provide      │  │ 🛡️ IL Protection     │    │
│  │    Liquidity?       │  │                       │    │
│  │                     │  │ How It Works:         │    │
│  │ ✓ Earn Sustainable  │  │ 1. Reactive monitors  │    │
│  │   Yield (0.3%-1%)   │  │ 2. Volatility > 5%    │    │
│  │                     │  │ 3. Pool pauses        │    │
│  │ ✓ Serve Community   │  │ 4. Resumes when safe  │    │
│  │   Help diaspora     │  │                       │    │
│  │                     │  │ Real-World Example:   │    │
│  │ ✓ Collective        │  │ 2024 CBN policy → 8%  │    │
│  │   Ownership         │  │ Corridor would've     │    │
│  │   Governance        │  │ protected $8K loss    │    │
│  │                     │  │                       │    │
│  │ [Add Liquidity]     │  │ Status: Active ✓      │    │
│  └─────────────────────┘  └──────────────────────┘    │
│                                                         │
│  ┌──────────┐  ┌──────────┐  ┌──────────┐            │
│  │  1,247   │  │  $847K   │  │  18.3%   │            │
│  │Active LPs│  │  Total   │  │ Avg APY  │            │
│  │+12% week │  │+$45K week│  │Fees+Yield│            │
│  └──────────┘  └──────────┘  └──────────┘            │
└─────────────────────────────────────────────────────────┘
```

**Layout:**

- 2-column grid
- Benefit cards with icons
- IL protection education
- Real-world example
- Community stats row

---

### 7. How It Works

```
┌─────────────────────────────────────────────────────────┐
│                  How It Works                           │
│      Simple, secure, community-powered remittances      │
│                                                         │
│  ┌──────┐ → ┌──────┐ → ┌──────┐ → ┌──────┐            │
│  │ 👛   │   │ 🔄   │   │ 🛡️   │   │ ⚡   │            │
│  │Connect│   │ Swap │   │Protected│   │ Earn │          │
│  │Wallet │   │  or  │   │   by   │   │  &   │          │
│  │      │   │Provide│   │Reactive│   │Serve │          │
│  └──────┘   └──────┘   └──────┘   └──────┘            │
│                                                         │
│            Built on Leading Infrastructure              │
│                                                         │
│    ┌──────┐      ┌──────┐      ┌──────┐               │
│    │ v4   │      │  ⚡  │      │ 🛡️   │               │
│    │Uniswap│      │React │      │Unichain│             │
│    │  v4  │      │ -ive │      │       │               │
│    └──────┘      └──────┘      └──────┘               │
└─────────────────────────────────────────────────────────┘
```

**Steps:**

1. Connect Wallet
2. Swap or Provide
3. Protected by Reactive
4. Earn & Serve

**Tech Stack:**

- Uniswap v4 hooks
- Reactive Network
- Unichain L2

---

### 8. Footer

```
┌─────────────────────────────────────────────────────────┐
│ [🔷 Corridor]                                           │
│  Community Remittance                                   │
│                                                         │
│  Reducing African remittance costs from 8.37%          │
│  to <1% through community-powered liquidity            │
│                                                         │
│  Product        Community       [GitHub] [Twitter]     │
│  • Send         • About                                │
│  • Provide      • Governance                           │
│  • Pool Status  • Forum                                │
│  • Docs         • Support                              │
│                                                         │
│  Built with ❤️ for African communities                 │
│  © 2026 Corridor. Open-source infrastructure           │
└─────────────────────────────────────────────────────────┘
```

---

## 🎨 UI Components

### Buttons

**Primary (Green)**

```
┌──────────────────────────┐
│   Send Remittance    →   │
└──────────────────────────┘
Background: #2D6A4F
Hover: Scale up, darker
```

**Secondary (Glass)**

```
┌──────────────────────────┐
│   Become Community LP    │
└──────────────────────────┘
Background: rgba(255,255,255,0.7)
Border: Green
Blur: 10px
```

### Cards

**Glass Effect**

```
┌─────────────────────┐
│                     │  Background: rgba(255,255,255,0.7)
│    Card Content     │  Backdrop-filter: blur(10px)
│                     │  Border: Green/20
└─────────────────────┘
```

**Status Cards**

```
┌─────────────┐
│  ⚡ Icon    │
│             │
│   Value     │
│   Label     │
│  Subtext    │
└─────────────┘
```

### Progress Bars

```
Volatility: 2.1% / 5%
[████████░░░░░░░]
```

### Badges

```
┌────────────┐
│ BEST VALUE │  Background: Green
└────────────┘  Text: White
                Font: Bold
```

## 📐 Responsive Breakpoints

### Mobile (< 640px)

- Single column layouts
- Stacked cards
- Simplified navigation
- Touch-friendly buttons

### Tablet (640px - 1024px)

- 2-column grids
- Balanced spacing
- Side-by-side comparisons

### Desktop (> 1024px)

- 4-column stats
- Wide hero layout
- Full-width charts

## 🎭 Animations

### Scroll Animations (Framer Motion)

```typescript
initial={{ opacity: 0, y: 20 }}
whileInView={{ opacity: 1, y: 0 }}
viewport={{ once: true }}
transition={{ duration: 0.6 }}
```

### Hover Effects

- Scale: 1.05
- Border glow increase
- Background darken/lighten

### Status Indicators

- Pulse animation for "Active"
- Smooth progress bar transitions
- Chart line animations

## 🌈 Visual Hierarchy

1. **Hero Headline** (72px, Bold, Gradient)
2. **Section Titles** (48px, Bold, Dark)
3. **Card Titles** (24px, Semibold, Dark)
4. **Body Text** (16px, Regular, Dark/70)
5. **Labels** (14px, Medium, Dark/60)
6. **Small Text** (12px, Regular, Dark/60)

## 💡 Design Principles

### Community-First

- Warm, welcoming colors
- Family-focused language
- Cultural references (esusu, ajo)
- Trust indicators prominent

### Data-Driven

- Clear cost comparisons
- Real-time metrics
- Visual progress indicators
- Transparent fee structure

### Professional Yet Accessible

- Not overly corporate
- Friendly tone
- Clear value proposition
- Easy to understand

### African Identity

- Earth-tone palette
- Gold accents (prosperity)
- Green (growth, trust)
- Orange (energy, community)

---

## 🎬 User Flows

### Flow 1: New Visitor

1. Land on hero → Sees cost reduction
2. Scroll to calculator → Try with $200
3. See $193/year savings → Convinced
4. Click "Send Remittance" → Connect wallet
5. Proceed to swap

### Flow 2: Potential LP

1. Land on hero → Click "Become LP"
2. Jump to Community LP section
3. Read IL protection details
4. See real-world CBN example
5. Click "Add Liquidity" → Connect wallet

### Flow 3: Explorer

1. Browse all sections
2. Check live pool status
3. Read "How It Works"
4. Join community links in footer

---

Built with ❤️ for African communities
