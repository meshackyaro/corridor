# Corridor Frontend Features

A comprehensive overview of all features in the Corridor frontend.

## 🎨 Design Features

### African-Inspired Visual Identity

**Color Palette**

- Warm earth tones reflecting African landscapes
- Corridor Green (#2D6A4F) - Trust and growth
- Corridor Gold (#D4AF37) - Success and prosperity
- Corridor Orange (#E76F51) - Energy and community
- Corridor Cream (#F4E9D7) - Welcoming backgrounds

**Typography**

- Inter for body text (readability)
- Space Grotesk for headings (modern, bold)
- Clear hierarchy for easy scanning

**Visual Elements**

- Dot pattern backgrounds
- Glass-morphism effects
- Smooth gradient transitions
- Animated components with Framer Motion

### Cultural Authenticity

- Language reflecting communal finance (esusu, ajo, chama)
- Community-first messaging
- Family-focused value propositions
- Trust indicators and transparency

## 🚀 Core Features

### 1. Hero Section

**What it does:**

- Immediately communicates value proposition
- Shows cost reduction: 8.37% → <1%
- Dual CTAs for senders and liquidity providers
- Trust indicators (IL protection, community size, volume)

**Technical:**

- Framer Motion animations
- Responsive grid layout
- Gradient text effects

### 2. Impact Stats

**What it does:**

- Displays key metrics at a glance
- 96% cost reduction
- $54B market size
- 22M+ potential users
- 3 active currency corridors

**Technical:**

- Scroll-triggered animations
- Icon-based visual hierarchy
- Staggered entrance effects

### 3. Remittance Calculator

**What it does:**

- Interactive cost comparison tool
- Compare Western Union, banks, and Corridor
- Real-time calculations as user adjusts amount
- Shows annual savings potential
- Range slider for easy amount selection

**Key Insights:**

- Visual comparison with color coding
- "Best Value" badge for Corridor
- Clear fee structure display
- Family-focused language ("Family receives")

**Technical:**

- React state management
- Dynamic calculations
- Responsive design
- Accessible form controls

### 4. Live Pool Status Dashboard

**What it does:**

- Real-time pool monitoring
- Shows if pool is active or paused
- Displays current dynamic fee
- Tracks volatility levels
- Shows TVL and 24h volume
- Price history chart

**Status Indicators:**

- Pool operational status with pulse animation
- Current fee (0.3% - 1.0%)
- Volatility with progress bar
- Visual alerts for pause state

**Chart Features:**

- 24h NGN/USD price history
- Recharts integration
- Responsive container
- Custom styling

**Technical:**

- Real-time data hooks (usePoolData)
- Wagmi contract reads
- Recharts for visualization
- Conditional rendering based on state

### 5. Community LP Section

**What it does:**

- Explains benefits of providing liquidity
- Shows IL protection mechanics
- Displays community statistics
- Clear CTAs for adding liquidity

**LP Benefits:**

- Earn sustainable yield (fees + optimization)
- Serve community while earning
- Collective ownership through governance

**IL Protection Education:**

- Step-by-step explanation
- Real-world example from 2024 CBN policy
- Visual threshold indicators
- Current protection status

**Community Stats:**

- Active LPs count
- Total liquidity provided
- Average APY
- Week-over-week changes

**Technical:**

- Grid layouts for balanced design
- Progress bars for metrics
- Icon-driven benefit cards

### 6. How It Works

**What it does:**

- 4-step process explanation
- Technical stack showcase
- Integration highlights

**Steps:**

1. Connect Wallet
2. Swap or Provide Liquidity
3. Protected by Reactive Network
4. Earn & Serve Community

**Tech Stack Display:**

- Uniswap v4 integration
- Reactive Network automation
- Unichain infrastructure

**Technical:**

- Gradient backgrounds
- Sequential animations
- Connector lines between steps

### 7. Header & Navigation

**What it does:**

- Fixed header with glass effect
- Corridor branding
- Wallet connection via RainbowKit
- Mobile-responsive

**Technical:**

- RainbowKit integration
- Sticky positioning
- Backdrop blur effect

### 8. Footer

**What it does:**

- Site-wide links
- Social media connections
- Community resources
- "Built with ❤️ for African communities"

**Sections:**

- Product links
- Community links
- Social media
- Copyright notice

## 🔌 Web3 Integration

### Wallet Connection

- RainbowKit for beautiful wallet UX
- Supports all major wallets
- Network switching to Unichain Sepolia
- Mobile wallet support (WalletConnect)

### Smart Contract Integration

**Contracts:**

1. CorridorHook (Uniswap v4)
2. PriceOracle (NGN/USD feed)
3. CorridorReactive (automation)

**Read Functions:**

- `poolPaused()` - Check if pool is active
- `poolDynamicFee()` - Current fee
- `volatilityThreshold()` - Pause threshold
- `communityLPShares()` - LP participation
- `totalCommunityShares()` - Total LPs

**Write Functions (Future):**

- Add liquidity
- Remove liquidity
- Execute swaps

### Custom Hooks

**usePoolData()**

- Fetches pool status
- Dynamic fee
- Volatility threshold
- Total community shares

**useLPData(address)**

- Individual LP shares
- Participation tracking

## 📱 Responsive Design

### Breakpoints

- Mobile: < 640px
- Tablet: 640px - 1024px
- Desktop: > 1024px

### Mobile Optimizations

- Touch-friendly buttons
- Simplified layouts
- Readable font sizes
- Vertical stacking
- Hamburger menu (future)

### Tablet Optimizations

- 2-column grids
- Balanced spacing
- Optimized charts

### Desktop Optimizations

- 4-column stats grid
- Side-by-side layouts
- Larger hero elements

## ⚡ Performance Features

### Next.js Optimizations

- App Router for faster navigation
- Automatic code splitting
- Image optimization
- Font optimization (next/font)

### Loading Strategies

- Lazy loading for off-screen content
- Prefetching for instant navigation
- Suspense boundaries for async data

### Caching

- Static page generation where possible
- Contract data caching via React Query
- Client-side state management

## 🎭 Animation & Interactions

### Framer Motion Animations

- Scroll-triggered reveals
- Staggered list animations
- Hover effects
- Scale transitions
- Fade-ins and slide-ups

### Interactive Elements

- Hover states on all buttons
- Active states for navigation
- Pulse animations for status indicators
- Progress bars with transitions
- Chart tooltips

## 🔒 Security Features

### Environment Variables

- All sensitive data in env vars
- No hardcoded addresses
- Separate configs for test/prod

### Contract Safety

- Read-only by default
- Clear transaction previews (future)
- Network validation
- Address validation

## 🌐 SEO & Accessibility

### SEO

- Semantic HTML
- Meta tags in layout
- Descriptive page titles
- Open Graph tags ready

### Accessibility

- ARIA labels
- Keyboard navigation
- Screen reader friendly
- Color contrast compliance
- Focus indicators

## 🔮 Future Features (Roadmap)

### Phase 1 (Next Release)

- [ ] Actual swap functionality
- [ ] Add liquidity interface
- [ ] Remove liquidity interface
- [ ] Transaction history
- [ ] LP dashboard

### Phase 2

- [ ] Mobile app (React Native)
- [ ] Multi-language support (Yoruba, Igbo, Hausa)
- [ ] Fiat on-ramp integration
- [ ] Push notifications for IL protection

### Phase 3

- [ ] Additional corridors (GHS, KES, etc.)
- [ ] Community governance voting
- [ ] LP rewards claiming
- [ ] Referral program

### Phase 4

- [ ] Cross-chain liquidity routing
- [ ] Institutional LP onboarding
- [ ] Advanced analytics
- [ ] API for third-party integrations

## 📊 Analytics (Future)

### User Metrics

- Page views
- Wallet connections
- Swap volumes
- LP additions/removals

### Performance Metrics

- Page load times
- Contract interaction times
- Error rates
- User flows

## 🎯 Conversion Optimization

### Primary Conversions

1. Wallet connections
2. Liquidity additions
3. Swap executions

### Secondary Conversions

1. Social media follows
2. Documentation reads
3. Community joins

### Optimization Strategies

- Clear value propositions
- Trust indicators
- Social proof (community stats)
- Easy onboarding flow
- Educational content

---

Built with ❤️ for African communities
