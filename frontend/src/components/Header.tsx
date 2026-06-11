"use client";

import { ConnectButton } from "@rainbow-me/rainbowkit";
import { TrendingUp } from "lucide-react";

export function Header() {
  return (
    <header className="fixed top-0 left-0 right-0 z-50 glass-effect border-b border-corridor-green/20">
      <div className="max-w-7xl mx-auto px-4 sm:px-6 lg:px-8">
        <div className="flex items-center justify-between h-16">
          {/* Logo */}
          <div className="flex items-center space-x-3">
            <div className="w-10 h-10 bg-gradient-to-br from-corridor-green to-corridor-gold rounded-lg flex items-center justify-center">
              <TrendingUp className="w-6 h-6 text-white" />
            </div>
            <div>
              <h1 className="text-xl font-display font-bold text-corridor-dark">
                Corridor
              </h1>
              <p className="text-xs text-corridor-dark/60">Community Remittance</p>
            </div>
          </div>

          {/* Connect Button */}
          <ConnectButton />
        </div>
      </div>
    </header>
  );
}
