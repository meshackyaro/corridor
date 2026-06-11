# Corridor Frontend 🌍

> A community-focused, culturally authentic frontend for Corridor—reducing African remittance costs from 8.37% to <1% through community-powered liquidity.

**[Live Demo](#) • [Documentation](./FEATURES.md) • [Deployment Guide](./DEPLOYMENT.md) • [Integration Guide](../FRONTEND_INTEGRATION.md)**

## Features

- **Remittance Calculator**: Compare costs between traditional services and Corridor
- **Live Pool Status**: Real-time monitoring of pool health, fees, and volatility
- **Community LP Dashboard**: Track community participation and IL protection
- **African-Inspired Design**: Warm colors and cultural authenticity
- **Web3 Integration**: Connect wallet via RainbowKit for Unichain Sepolia

## Tech Stack

- **Next.js 14** - React framework with App Router
- **TypeScript** - Type safety
- **Tailwind CSS** - Styling with custom Corridor theme
- **Wagmi v2** - Ethereum interactions
- **RainbowKit** - Wallet connection
- **Framer Motion** - Smooth animations
- **Recharts** - Data visualization
- **Lucide React** - Icon system

## Getting Started

### Prerequisites

- Node.js 18+
- npm or yarn
- WalletConnect Project ID ([Get one here](https://cloud.walletconnect.com))

### Installation

1. Install dependencies:

```bash
npm install
```

2. Create `.env.local` file:

```bash
cp .env.example .env.local
```

3. Add your environment variables:

```env
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_project_id

# Contract addresses from deployment
NEXT_PUBLIC_CORRIDOR_HOOK_ADDRESS=0xYourHookAddress
NEXT_PUBLIC_PRICE_ORACLE_ADDRESS=0xYourOracleAddress
NEXT_PUBLIC_REACTIVE_CONTRACT_ADDRESS=0xYourReactiveAddress
```

4. Start development server:

```bash
npm run dev
```

5. Open [http://localhost:3000](http://localhost:3000)

## Design Philosophy

### Color Palette

- **Corridor Green** (#2D6A4F) - Primary, trust, growth
- **Corridor Gold** (#D4AF37) - Success, prosperity
- **Corridor Orange** (#E76F51) - Energy, community
- **Corridor Cream** (#F4E9D7) - Warm backgrounds
- **Corridor Dark** (#1B263B) - Text, contrast

### Cultural Authenticity

The design reflects African communal finance traditions:

- Warm, welcoming color scheme
- Community-first language
- Clear value proposition
- Trust indicators and transparency

## Project Structure

```
frontend/
├── src/
│   ├── app/
│   │   ├── layout.tsx       # Root layout with providers
│   │   ├── page.tsx         # Home page
│   │   └── globals.css      # Global styles
│   ├── components/
│   │   ├── Header.tsx       # Navigation + wallet connect
│   │   ├── Hero.tsx         # Hero section
│   │   ├── Stats.tsx        # Impact metrics
│   │   ├── RemittanceCalculator.tsx  # Cost comparison
│   │   ├── PoolStatus.tsx   # Live pool monitoring
│   │   ├── CommunityLP.tsx  # LP benefits + stats
│   │   ├── HowItWorks.tsx   # Process explanation
│   │   ├── Footer.tsx       # Footer
│   │   └── Providers.tsx    # Web3 providers
│   └── lib/
│       └── contracts.ts     # Contract ABIs and addresses
├── public/                  # Static assets
├── .env.example            # Environment template
└── README.md
```

## Building for Production

```bash
npm run build
npm run start
```

## Deployment

### Vercel (Recommended)

1. Push to GitHub
2. Import project in Vercel
3. Add environment variables
4. Deploy

### Other Platforms

Build outputs to `.next/` directory. Supports any Node.js hosting platform.

## Contract Integration

The frontend connects to three smart contracts:

1. **CorridorHook** - Main Uniswap v4 hook on Unichain Sepolia
2. **PriceOracle** - Price feed for NGN/USD
3. **CorridorReactive** - Reactive Network automation contract

See `src/lib/contracts.ts` for ABIs and integration details.

## Contributing

We welcome contributions! Please:

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Submit a pull request

## License

MIT License - see LICENSE for details

## Links

- **Main Project**: [github.com/meshackyaro/corridor](https://github.com/meshackyaro/corridor)
- **Documentation**: See main repo README
- **Uniswap v4**: https://docs.uniswap.org/contracts/v4/overview
- **Reactive Network**: https://docs.reactive.network

---

Built with ❤️ for African communities
