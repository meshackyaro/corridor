#!/bin/bash

# Corridor Frontend Setup Script
# This script helps you set up the frontend quickly

echo "🌍 Corridor Frontend Setup"
echo "=========================="
echo ""

# Check Node.js version
NODE_VERSION=$(node -v 2>/dev/null)
if [ $? -ne 0 ]; then
    echo "❌ Node.js is not installed"
    echo "Please install Node.js 18+ from https://nodejs.org"
    exit 1
fi

echo "✅ Node.js version: $NODE_VERSION"

# Check if we're in the frontend directory
if [ ! -f "package.json" ]; then
    echo "❌ Please run this script from the frontend directory"
    exit 1
fi

# Install dependencies
echo ""
echo "📦 Installing dependencies..."
npm install

if [ $? -ne 0 ]; then
    echo "❌ Failed to install dependencies"
    exit 1
fi

echo "✅ Dependencies installed"

# Check for .env.local
if [ ! -f ".env.local" ]; then
    echo ""
    echo "📝 Creating .env.local from template..."
    cp .env.example .env.local
    echo "✅ .env.local created"
    echo ""
    echo "⚠️  IMPORTANT: Edit .env.local with your values:"
    echo "   - WalletConnect Project ID (from cloud.walletconnect.com)"
    echo "   - Contract addresses from your deployment"
    echo ""
    echo "Open .env.local in your editor to configure."
else
    echo "✅ .env.local already exists"
fi

echo ""
echo "🎉 Setup complete!"
echo ""
echo "Next steps:"
echo "1. Edit .env.local with your configuration"
echo "2. Run 'npm run dev' to start development server"
echo "3. Visit http://localhost:3000"
echo ""
echo "For deployment instructions, see DEPLOYMENT.md"
echo ""
