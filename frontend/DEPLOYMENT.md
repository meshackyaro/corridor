# Frontend Deployment Guide

Complete guide for deploying the Corridor frontend.

## Prerequisites

1. **Node.js 18+** installed
2. **WalletConnect Project ID** from [cloud.walletconnect.com](https://cloud.walletconnect.com)
3. **Deployed Contracts** on Unichain Sepolia (Hook, Oracle, Reactive)
4. **Git** for version control

## Local Development Setup

### Step 1: Install Dependencies

```bash
cd frontend
npm install
```

### Step 2: Configure Environment

Create `.env.local`:

```bash
cp .env.example .env.local
```

Edit `.env.local` with your values:

```env
# Required: Get from https://cloud.walletconnect.com
NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_project_id_here

# Contract Addresses (from your deployment)
NEXT_PUBLIC_CORRIDOR_HOOK_ADDRESS=0xYourHookAddress
NEXT_PUBLIC_PRICE_ORACLE_ADDRESS=0xYourOracleAddress
NEXT_PUBLIC_REACTIVE_CONTRACT_ADDRESS=0xYourReactiveAddress

# Network (Unichain Sepolia Testnet)
NEXT_PUBLIC_CHAIN_ID=1301
NEXT_PUBLIC_RPC_URL=https://sepolia.unichain.org
```

### Step 3: Start Development Server

```bash
npm run dev
```

Visit [http://localhost:3000](http://localhost:3000)

## Production Deployment

### Option 1: Vercel (Recommended)

Vercel is the easiest way to deploy Next.js applications.

#### Prerequisites

- GitHub account
- Vercel account (free tier available)

#### Steps

1. **Push to GitHub**

   ```bash
   git init
   git add .
   git commit -m "Initial commit"
   git remote add origin https://github.com/yourusername/corridor-frontend.git
   git push -u origin main
   ```

2. **Import to Vercel**
   - Go to [vercel.com](https://vercel.com)
   - Click "New Project"
   - Import your GitHub repository
   - Select the `frontend` directory as root

3. **Configure Environment Variables**

   In Vercel dashboard → Settings → Environment Variables, add:

   ```
   NEXT_PUBLIC_WALLET_CONNECT_PROJECT_ID=your_project_id
   NEXT_PUBLIC_CORRIDOR_HOOK_ADDRESS=0xYourHookAddress
   NEXT_PUBLIC_PRICE_ORACLE_ADDRESS=0xYourOracleAddress
   NEXT_PUBLIC_REACTIVE_CONTRACT_ADDRESS=0xYourReactiveAddress
   NEXT_PUBLIC_CHAIN_ID=1301
   NEXT_PUBLIC_RPC_URL=https://sepolia.unichain.org
   ```

4. **Deploy**
   - Click "Deploy"
   - Wait 2-3 minutes
   - Visit your live URL!

#### Custom Domain (Optional)

1. Go to Project Settings → Domains
2. Add your custom domain
3. Follow DNS configuration instructions

### Option 2: Netlify

1. **Build the Project**

   ```bash
   npm run build
   ```

2. **Deploy to Netlify**
   - Sign in to [netlify.com](https://netlify.com)
   - Drag & drop the `.next` folder
   - Or connect your GitHub repo

3. **Configure Environment Variables**
   - Go to Site Settings → Environment Variables
   - Add all `NEXT_PUBLIC_*` variables

### Option 3: Self-Hosted (VPS/Cloud)

#### Using PM2 (Production Process Manager)

1. **Prepare Server**

   ```bash
   # On your VPS (Ubuntu/Debian)
   sudo apt update
   sudo apt install -y nodejs npm nginx
   npm install -g pm2
   ```

2. **Clone & Build**

   ```bash
   git clone https://github.com/yourusername/corridor.git
   cd corridor/frontend
   npm install
   npm run build
   ```

3. **Create Environment File**

   ```bash
   nano .env.local
   # Add all environment variables
   ```

4. **Start with PM2**

   ```bash
   pm2 start npm --name "corridor-frontend" -- start
   pm2 save
   pm2 startup
   ```

5. **Configure Nginx**

   ```nginx
   # /etc/nginx/sites-available/corridor
   server {
       listen 80;
       server_name your-domain.com;

       location / {
           proxy_pass http://localhost:3000;
           proxy_http_version 1.1;
           proxy_set_header Upgrade $http_upgrade;
           proxy_set_header Connection 'upgrade';
           proxy_set_header Host $host;
           proxy_cache_bypass $http_upgrade;
       }
   }
   ```

   ```bash
   sudo ln -s /etc/nginx/sites-available/corridor /etc/nginx/sites-enabled/
   sudo nginx -t
   sudo systemctl reload nginx
   ```

6. **SSL Certificate (Let's Encrypt)**
   ```bash
   sudo apt install certbot python3-certbot-nginx
   sudo certbot --nginx -d your-domain.com
   ```

### Option 4: Docker

1. **Create Dockerfile**

   ```dockerfile
   FROM node:18-alpine AS builder
   WORKDIR /app
   COPY package*.json ./
   RUN npm ci
   COPY . .
   RUN npm run build

   FROM node:18-alpine
   WORKDIR /app
   COPY --from=builder /app/package*.json ./
   COPY --from=builder /app/.next ./.next
   COPY --from=builder /app/public ./public
   RUN npm ci --only=production
   EXPOSE 3000
   CMD ["npm", "start"]
   ```

2. **Build & Run**
   ```bash
   docker build -t corridor-frontend .
   docker run -p 3000:3000 --env-file .env.local corridor-frontend
   ```

## Post-Deployment Checklist

- [ ] Test wallet connection on Unichain Sepolia
- [ ] Verify contract data loads correctly
- [ ] Check all links and navigation
- [ ] Test on mobile devices
- [ ] Verify analytics/monitoring setup
- [ ] Test remittance calculator
- [ ] Confirm pool status updates
- [ ] Check responsive design

## Monitoring & Analytics

### Add Google Analytics (Optional)

1. Install package:

   ```bash
   npm install @next/third-parties
   ```

2. Add to `layout.tsx`:

   ```tsx
   import { GoogleAnalytics } from "@next/third-parties/google";

   export default function RootLayout({ children }) {
     return (
       <html>
         <body>
           {children}
           <GoogleAnalytics gaId="G-XXXXXXXXXX" />
         </body>
       </html>
     );
   }
   ```

### Error Monitoring with Sentry (Optional)

1. Install:

   ```bash
   npm install @sentry/nextjs
   ```

2. Initialize:
   ```bash
   npx @sentry/wizard@latest -i nextjs
   ```

## Troubleshooting

### Build Fails

**Error: "Module not found"**

```bash
rm -rf node_modules package-lock.json
npm install
```

**TypeScript errors**

```bash
npm run lint
# Fix reported issues
```

### Wallet Connection Issues

- Verify WalletConnect Project ID is correct
- Check network configuration matches Unichain Sepolia
- Ensure RPC URL is accessible

### Contract Data Not Loading

- Verify contract addresses in `.env.local`
- Check contracts are deployed on correct network
- Confirm ABI matches deployed contracts

### Performance Issues

- Enable Next.js Image Optimization
- Use CDN for static assets
- Enable compression in Nginx/server

## Updating the Frontend

1. **Pull Latest Changes**

   ```bash
   git pull origin main
   ```

2. **Update Dependencies**

   ```bash
   npm install
   ```

3. **Rebuild**

   ```bash
   npm run build
   ```

4. **Deploy**
   - Vercel: Automatic on git push
   - PM2: `pm2 restart corridor-frontend`
   - Docker: Rebuild and restart container

## Environment-Specific Configs

### Mainnet Deployment

When deploying to Unichain mainnet, update `.env.local`:

```env
NEXT_PUBLIC_CHAIN_ID=130
NEXT_PUBLIC_RPC_URL=https://mainnet.unichain.org
# Update contract addresses to mainnet deployments
```

## Security Best Practices

1. **Never commit `.env.local`** to version control
2. **Rotate WalletConnect Project ID** periodically
3. **Use environment variables** for all sensitive data
4. **Enable HTTPS** in production
5. **Set proper CORS headers**
6. **Regular dependency updates**
   ```bash
   npm audit
   npm update
   ```

## Support

- **Issues**: [GitHub Issues](https://github.com/meshackyaro/corridor/issues)
- **Documentation**: See main project README
- **Community**: Join our Discord/Telegram

---

Built with ❤️ for African communities
