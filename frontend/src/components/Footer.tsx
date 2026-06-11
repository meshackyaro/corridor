"use client";

import { TrendingUp, Github, Twitter, Heart } from "lucide-react";

export function Footer() {
  return (
    <footer className="bg-corridor-dark text-white py-12 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto">
        <div className="grid grid-cols-1 md:grid-cols-4 gap-8 mb-8">
          {/* Brand */}
          <div className="md:col-span-2">
            <div className="flex items-center space-x-3 mb-4">
              <div className="w-10 h-10 bg-gradient-to-br from-corridor-green to-corridor-gold rounded-lg flex items-center justify-center">
                <TrendingUp className="w-6 h-6 text-white" />
              </div>
              <div>
                <h3 className="text-xl font-display font-bold">Corridor</h3>
                <p className="text-sm text-white/60">Community Remittance</p>
              </div>
            </div>
            <p className="text-white/70 text-sm max-w-md">
              Reducing African remittance costs from 8.37% to {"<"}1% through
              community-powered liquidity, built on Uniswap v4 and Reactive Network.
            </p>
          </div>

          {/* Links */}
          <div>
            <h4 className="font-semibold mb-4">Product</h4>
            <ul className="space-y-2 text-sm text-white/70">
              <li>
                <a href="#" className="hover:text-white transition-colors">
                  Send Remittance
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-white transition-colors">
                  Provide Liquidity
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-white transition-colors">
                  Pool Status
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-white transition-colors">
                  Documentation
                </a>
              </li>
            </ul>
          </div>

          {/* Community */}
          <div>
            <h4 className="font-semibold mb-4">Community</h4>
            <ul className="space-y-2 text-sm text-white/70">
              <li>
                <a href="#" className="hover:text-white transition-colors">
                  About
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-white transition-colors">
                  Governance
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-white transition-colors">
                  Forum
                </a>
              </li>
              <li>
                <a href="#" className="hover:text-white transition-colors">
                  Support
                </a>
              </li>
            </ul>
          </div>
        </div>

        {/* Bottom */}
        <div className="pt-8 border-t border-white/10 flex flex-col sm:flex-row items-center justify-between">
          <div className="flex items-center space-x-4 mb-4 sm:mb-0">
            <a
              href="https://github.com"
              target="_blank"
              rel="noopener noreferrer"
              className="w-10 h-10 bg-white/10 rounded-lg flex items-center justify-center hover:bg-white/20 transition-colors"
            >
              <Github className="w-5 h-5" />
            </a>
            <a
              href="https://twitter.com"
              target="_blank"
              rel="noopener noreferrer"
              className="w-10 h-10 bg-white/10 rounded-lg flex items-center justify-center hover:bg-white/20 transition-colors"
            >
              <Twitter className="w-5 h-5" />
            </a>
          </div>

          <div className="flex items-center space-x-2 text-sm text-white/60">
            <span>Built with</span>
            <Heart className="w-4 h-4 text-corridor-orange fill-corridor-orange" />
            <span>for African communities</span>
          </div>
        </div>

        <div className="mt-4 text-center text-xs text-white/40">
          © 2026 Corridor. Open-source infrastructure for community remittances.
        </div>
      </div>
    </footer>
  );
}
