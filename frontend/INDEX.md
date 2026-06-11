# Corridor Frontend Documentation Index

Complete guide to the Corridor frontend—navigate to the right documentation for your needs.

## 🚀 Quick Links

| I want to...               | Go to...                                                 |
| -------------------------- | -------------------------------------------------------- |
| **Get started quickly**    | [README.md](./README.md)                                 |
| **See what was built**     | [SUMMARY.md](./SUMMARY.md)                               |
| **Learn all features**     | [FEATURES.md](./FEATURES.md)                             |
| **Deploy to production**   | [DEPLOYMENT.md](./DEPLOYMENT.md)                         |
| **See visual design**      | [SCREENSHOTS.md](./SCREENSHOTS.md)                       |
| **Understand integration** | [../FRONTEND_INTEGRATION.md](../FRONTEND_INTEGRATION.md) |

## 📚 Documentation Files

### 1. README.md

**Purpose:** Quick start guide  
**Best for:** Developers setting up for first time  
**Contents:**

- Installation instructions
- Environment setup
- Running locally
- Project structure overview
- Tech stack summary

[→ Go to README.md](./README.md)

---

### 2. SUMMARY.md

**Purpose:** High-level overview  
**Best for:** Project managers, stakeholders, quick review  
**Contents:**

- What was built
- Key features checklist
- File structure
- Tech highlights
- Design philosophy

[→ Go to SUMMARY.md](./SUMMARY.md)

---

### 3. FEATURES.md

**Purpose:** Comprehensive feature documentation  
**Best for:** Developers, designers, product managers  
**Contents:**

- Design features and philosophy
- Component breakdown
- Web3 integration details
- Performance optimizations
- Future roadmap

[→ Go to FEATURES.md](./FEATURES.md)

---

### 4. DEPLOYMENT.md

**Purpose:** Production deployment guide  
**Best for:** DevOps, developers deploying to production  
**Contents:**

- Local development setup
- Vercel deployment (step-by-step)
- Netlify deployment
- Self-hosted (VPS) deployment
- Docker deployment
- Environment configuration
- Post-deployment checklist
- Troubleshooting

[→ Go to DEPLOYMENT.md](./DEPLOYMENT.md)

---

### 5. SCREENSHOTS.md

**Purpose:** Visual design guide  
**Best for:** Designers, visual learners, stakeholders  
**Contents:**

- Color palette
- ASCII mockups of all sections
- Component styles
- Responsive breakpoints
- Animation descriptions
- User flows

[→ Go to SCREENSHOTS.md](./SCREENSHOTS.md)

---

### 6. FRONTEND_INTEGRATION.md (in root)

**Purpose:** Smart contract integration guide  
**Best for:** Developers integrating with contracts  
**Contents:**

- Architecture overview
- Contract ABIs and functions
- Data flow examples
- Custom hooks usage
- Price updater service
- Testing integration
- Common issues

[→ Go to FRONTEND_INTEGRATION.md](../FRONTEND_INTEGRATION.md)

---

## 🎯 Use Case Guides

### I'm a developer starting fresh

1. Read [README.md](./README.md) - Get setup
2. Skim [FEATURES.md](./FEATURES.md) - Understand what exists
3. Check [SCREENSHOTS.md](./SCREENSHOTS.md) - See the design
4. Refer to [FRONTEND_INTEGRATION.md](../FRONTEND_INTEGRATION.md) - Understand contracts

### I need to deploy to production

1. Read [DEPLOYMENT.md](./DEPLOYMENT.md) - Comprehensive guide
2. Check [README.md](./README.md) - Environment setup
3. Review [FRONTEND_INTEGRATION.md](../FRONTEND_INTEGRATION.md) - Verify contract addresses

### I'm presenting to stakeholders

1. Start with [SUMMARY.md](./SUMMARY.md) - High-level overview
2. Show [SCREENSHOTS.md](./SCREENSHOTS.md) - Visual walkthrough
3. Highlight from [FEATURES.md](./FEATURES.md) - Key capabilities

### I'm a designer joining the project

1. Read [SCREENSHOTS.md](./SCREENSHOTS.md) - Design system
2. Check [FEATURES.md](./FEATURES.md) - Design philosophy section
3. Review [SUMMARY.md](./SUMMARY.md) - Context and goals

### I need to understand Web3 integration

1. Read [FRONTEND_INTEGRATION.md](../FRONTEND_INTEGRATION.md) - Complete guide
2. Check [FEATURES.md](./FEATURES.md) - Web3 integration section
3. Refer to `src/hooks/usePoolData.ts` - Code examples

### I'm troubleshooting an issue

1. Check [DEPLOYMENT.md](./DEPLOYMENT.md) - Troubleshooting section
2. Review [FRONTEND_INTEGRATION.md](../FRONTEND_INTEGRATION.md) - Common integration issues
3. See [README.md](./README.md) - Environment checklist

## 📁 Code Reference

### Key Files by Purpose

**Configuration**

- `package.json` - Dependencies and scripts
- `tsconfig.json` - TypeScript configuration
- `tailwind.config.ts` - Design system tokens
- `next.config.mjs` - Next.js configuration
- `.env.example` - Environment template

**Core App**

- `src/app/layout.tsx` - Root layout with providers
- `src/app/page.tsx` - Main page composition
- `src/app/globals.css` - Global styles

**Components**

- `src/components/Header.tsx` - Navigation
- `src/components/Hero.tsx` - Hero section
- `src/components/RemittanceCalculator.tsx` - Cost comparison
- `src/components/PoolStatus.tsx` - Live monitoring
- `src/components/CommunityLP.tsx` - LP dashboard
- `src/components/HowItWorks.tsx` - Process explanation
- `src/components/Footer.tsx` - Footer
- `src/components/Providers.tsx` - Web3 setup

**Web3**

- `src/hooks/usePoolData.ts` - Contract data hooks
- `src/lib/contracts.ts` - ABIs and addresses

**Scripts**

- `setup.sh` - Quick setup script

## 🎨 Design System Quick Reference

### Colors

```typescript
corridor: {
  green: "#2D6A4F",   // Primary, trust
  gold: "#D4AF37",    // Success, prosperity
  orange: "#E76F51",  // Energy, community
  brown: "#8B4513",   // Earth, stability
  cream: "#F4E9D7",   // Background, warmth
  dark: "#1B263B",    // Text, contrast
}
```

### Typography

- Body: Inter
- Headings: Space Grotesk

### Breakpoints

- Mobile: `< 640px`
- Tablet: `640px - 1024px`
- Desktop: `> 1024px`

See [SCREENSHOTS.md](./SCREENSHOTS.md) for complete design guide.

## 🔧 Tech Stack Quick Reference

### Frontend Framework

- Next.js 14 (App Router)
- TypeScript
- Tailwind CSS

### Web3

- Wagmi v2
- Viem
- RainbowKit
- TanStack Query

### UI/UX

- Framer Motion (animations)
- Recharts (charts)
- Lucide React (icons)

### Deployment

- Vercel (recommended)
- Netlify
- Self-hosted (VPS)
- Docker

See [README.md](./README.md) for complete tech stack.

## 📊 Project Statistics

- **Total Documentation Files:** 7
- **Total Components:** 8
- **Lines of Documentation:** ~3,000+
- **Deployment Platforms Covered:** 4
- **Tech Stack Items:** 15+

## 🌟 Key Features at a Glance

✅ African-inspired design (not generic)  
✅ Interactive remittance calculator  
✅ Live pool monitoring dashboard  
✅ Community LP section  
✅ Full Web3 integration  
✅ Responsive design  
✅ Production-ready  
✅ Comprehensive documentation

## 📖 Reading Order

**For Complete Understanding:**

1. [README.md](./README.md) - Setup and basics
2. [SUMMARY.md](./SUMMARY.md) - What was built
3. [FEATURES.md](./FEATURES.md) - Deep dive into features
4. [SCREENSHOTS.md](./SCREENSHOTS.md) - Visual guide
5. [FRONTEND_INTEGRATION.md](../FRONTEND_INTEGRATION.md) - Contract integration
6. [DEPLOYMENT.md](./DEPLOYMENT.md) - Going to production

**For Quick Overview:**

1. [SUMMARY.md](./SUMMARY.md) - High-level summary
2. [SCREENSHOTS.md](./SCREENSHOTS.md) - Visual walkthrough

## 🎯 Common Questions

**Q: How do I get started?**  
A: See [README.md](./README.md) → "Getting Started" section

**Q: What makes this different from other DeFi UIs?**  
A: See [SUMMARY.md](./SUMMARY.md) → "What Makes It Special"

**Q: How do I deploy to production?**  
A: See [DEPLOYMENT.md](./DEPLOYMENT.md) → "Production Deployment"

**Q: How does it connect to smart contracts?**  
A: See [FRONTEND_INTEGRATION.md](../FRONTEND_INTEGRATION.md) → "Smart Contract Integration"

**Q: What does the UI look like?**  
A: See [SCREENSHOTS.md](./SCREENSHOTS.md) → Full visual guide

**Q: What features does it have?**  
A: See [FEATURES.md](./FEATURES.md) → "Core Features"

## 🔗 External Resources

### Main Project

- **Repository:** [github.com/meshackyaro/corridor](https://github.com/meshackyaro/corridor)
- **Main README:** [../README.md](../README.md)
- **Hookathon Submission:** [../HOOKATHON_SUBMISSION.md](../HOOKATHON_SUBMISSION.md)

### Contract Documentation

- **CorridorHook:** `src/CorridorHook.sol`
- **CorridorReactive:** `src/CorridorReactive.sol`
- **Deployment Guide:** [../DEPLOYMENT_GUIDE.md](../DEPLOYMENT_GUIDE.md)

### External Docs

- **Uniswap v4:** [docs.uniswap.org/contracts/v4](https://docs.uniswap.org/contracts/v4/overview)
- **Reactive Network:** [docs.reactive.network](https://docs.reactive.network)
- **Next.js:** [nextjs.org/docs](https://nextjs.org/docs)
- **Wagmi:** [wagmi.sh](https://wagmi.sh)
- **RainbowKit:** [rainbowkit.com](https://www.rainbowkit.com)

## 📞 Support

**Need help?**

- GitHub Issues for bugs/features
- Check troubleshooting sections in docs
- Review common issues in DEPLOYMENT.md

**Contributing?**

- Read README.md for setup
- Check FEATURES.md for architecture
- Follow existing code style

---

## Navigation Map

```
Frontend Documentation
│
├── README.md ─────────────── Quick Start & Setup
├── SUMMARY.md ────────────── Project Overview
├── FEATURES.md ───────────── Feature Documentation
├── DEPLOYMENT.md ─────────── Production Deployment
├── SCREENSHOTS.md ────────── Visual Design Guide
├── INDEX.md ──────────────── This File
│
└── ../FRONTEND_INTEGRATION.md ── Smart Contract Integration
```

---

**Choose your path above and start exploring!**

Built with ❤️ for African communities
