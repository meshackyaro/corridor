"use client";

import { motion } from "framer-motion";
import { Users, Coins, TrendingUp, Heart } from "lucide-react";

export function CommunityLP() {
  return (
    <section className="py-20 px-4 sm:px-6 lg:px-8">
      <div className="max-w-7xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-12"
        >
          <h2 className="text-3xl sm:text-4xl font-display font-bold text-corridor-dark mb-4">
            Join the Community
          </h2>
          <p className="text-lg text-corridor-dark/70 max-w-2xl mx-auto">
            Modern infrastructure built on African communal finance traditions—esusu, ajo, chama
          </p>
        </motion.div>

        <div className="grid grid-cols-1 lg:grid-cols-2 gap-8">
          {/* LP Benefits */}
          <motion.div
            initial={{ opacity: 0, x: -20 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            className="glass-effect rounded-2xl p-8 border border-corridor-green/20"
          >
            <div className="flex items-center space-x-3 mb-6">
              <div className="w-12 h-12 bg-corridor-green/10 rounded-xl flex items-center justify-center">
                <Coins className="w-6 h-6 text-corridor-green" />
              </div>
              <h3 className="text-2xl font-display font-bold text-corridor-dark">
                Why Provide Liquidity?
              </h3>
            </div>

            <div className="space-y-4">
              {[
                {
                  icon: TrendingUp,
                  title: "Earn Sustainable Yield",
                  description: "0.3%-1% fees on every swap, plus automated yield optimization during idle periods",
                },
                {
                  icon: Heart,
                  title: "Serve Your Community",
                  description: "Help diaspora send money home at fair rates while earning returns",
                },
                {
                  icon: Users,
                  title: "Collective Ownership",
                  description: "Community governance over parameters and profit sharing",
                },
              ].map((benefit, i) => (
                <div key={i} className="flex items-start space-x-4">
                  <div className="w-10 h-10 bg-corridor-green/10 rounded-lg flex items-center justify-center flex-shrink-0">
                    <benefit.icon className="w-5 h-5 text-corridor-green" />
                  </div>
                  <div className="flex-1">
                    <div className="font-semibold text-corridor-dark mb-1">
                      {benefit.title}
                    </div>
                    <div className="text-sm text-corridor-dark/70">
                      {benefit.description}
                    </div>
                  </div>
                </div>
              ))}
            </div>

            <button className="w-full mt-6 bg-corridor-green hover:bg-corridor-green/90 text-white px-8 py-4 rounded-xl font-semibold transition-all">
              Add Liquidity
            </button>
          </motion.div>

          {/* Protection Info */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            className="glass-effect rounded-2xl p-8 border border-corridor-green/20"
          >
            <div className="flex items-center space-x-3 mb-6">
              <div className="w-12 h-12 bg-corridor-orange/10 rounded-xl flex items-center justify-center">
                <Users className="w-6 h-6 text-corridor-orange" />
              </div>
              <h3 className="text-2xl font-display font-bold text-corridor-dark">
                IL Protection
              </h3>
            </div>

            <div className="space-y-6">
              <div>
                <div className="text-sm font-semibold text-corridor-dark mb-2">
                  How It Works
                </div>
                <div className="text-sm text-corridor-dark/70 space-y-2">
                  <p>
                    1. Reactive Network monitors NGN/USD prices in real-time
                  </p>
                  <p>
                    2. When volatility exceeds 5%, pool automatically pauses
                  </p>
                  <p>
                    3. Fees increase dynamically during high volatility periods
                  </p>
                  <p>
                    4. Pool resumes when markets stabilize
                  </p>
                </div>
              </div>

              <div className="p-4 bg-gradient-to-br from-corridor-green/10 to-corridor-gold/10 rounded-xl border border-corridor-green/20">
                <div className="font-semibold text-corridor-dark mb-2">
                  Real-World Example
                </div>
                <div className="text-sm text-corridor-dark/70">
                  During CBN policy changes that caused 8% NGN volatility in 2024, traditional LPs
                  lost ~$8,000 on a $100K pool. Corridor's automated protection would have paused
                  the pool, protecting community funds.
                </div>
              </div>

              <div className="space-y-3">
                <div className="flex items-center justify-between text-sm">
                  <span className="text-corridor-dark/70">Current Volatility</span>
                  <span className="font-semibold text-corridor-dark">2.1%</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-corridor-dark/70">Pause Threshold</span>
                  <span className="font-semibold text-corridor-dark">5.0%</span>
                </div>
                <div className="flex items-center justify-between text-sm">
                  <span className="text-corridor-dark/70">Protection Status</span>
                  <span className="font-semibold text-green-600">Active ✓</span>
                </div>
              </div>
            </div>
          </motion.div>
        </div>

        {/* Community Stats */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="mt-8 grid grid-cols-1 sm:grid-cols-3 gap-6"
        >
          {[
            { label: "Active LPs", value: "1,247", change: "+12% this week" },
            { label: "Total Provided", value: "$847K", change: "+$45K this week" },
            { label: "Avg APY", value: "18.3%", change: "Including fees + yield" },
          ].map((stat, i) => (
            <div
              key={i}
              className="glass-effect rounded-xl p-6 border border-corridor-green/20 text-center"
            >
              <div className="text-3xl font-display font-bold text-corridor-dark mb-1">
                {stat.value}
              </div>
              <div className="text-sm font-semibold text-corridor-dark/80 mb-1">
                {stat.label}
              </div>
              <div className="text-xs text-corridor-dark/60">{stat.change}</div>
            </div>
          ))}
        </motion.div>
      </div>
    </section>
  );
}
