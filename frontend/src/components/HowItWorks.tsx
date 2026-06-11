"use client";

import { motion } from "framer-motion";
import { Wallet, ArrowRightLeft, Shield, Zap } from "lucide-react";

export function HowItWorks() {
  const steps = [
    {
      icon: Wallet,
      title: "Connect Wallet",
      description: "Link your wallet to access Corridor's remittance infrastructure",
      color: "from-corridor-green to-corridor-gold",
    },
    {
      icon: ArrowRightLeft,
      title: "Swap or Provide",
      description: "Send remittances at <1% cost, or provide liquidity to earn yield",
      color: "from-corridor-gold to-corridor-orange",
    },
    {
      icon: Shield,
      title: "Protected by Reactive",
      description: "Real-time volatility monitoring protects your assets automatically",
      color: "from-corridor-orange to-corridor-green",
    },
    {
      icon: Zap,
      title: "Earn & Serve",
      description: "LPs earn sustainable yield while serving the community",
      color: "from-corridor-green to-corridor-gold",
    },
  ];

  return (
    <section className="py-20 px-4 sm:px-6 lg:px-8 bg-white/50">
      <div className="max-w-7xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-16"
        >
          <h2 className="text-3xl sm:text-4xl font-display font-bold text-corridor-dark mb-4">
            How It Works
          </h2>
          <p className="text-lg text-corridor-dark/70">
            Simple, secure, community-powered remittances
          </p>
        </motion.div>

        <div className="grid grid-cols-1 md:grid-cols-2 lg:grid-cols-4 gap-6">
          {steps.map((step, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: i * 0.1 }}
              className="relative"
            >
              <div className="glass-effect rounded-2xl p-6 border border-corridor-green/20 h-full hover:border-corridor-green/40 transition-all">
                <div className={`w-14 h-14 bg-gradient-to-br ${step.color} rounded-xl flex items-center justify-center mb-4`}>
                  <step.icon className="w-7 h-7 text-white" />
                </div>
                <div className="text-xl font-display font-bold text-corridor-dark mb-2">
                  {step.title}
                </div>
                <div className="text-sm text-corridor-dark/70">
                  {step.description}
                </div>
              </div>
              {i < steps.length - 1 && (
                <div className="hidden lg:block absolute top-1/2 -right-3 w-6 h-0.5 bg-gradient-to-r from-corridor-green to-corridor-gold" />
              )}
            </motion.div>
          ))}
        </div>

        {/* Technical Stack */}
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          className="mt-16 glass-effect rounded-2xl p-8 border border-corridor-green/20"
        >
          <h3 className="text-2xl font-display font-bold text-corridor-dark mb-8 text-center">
            Built on Leading Infrastructure
          </h3>
          <div className="grid grid-cols-1 md:grid-cols-3 gap-8">
            <div className="text-center">
              <div className="w-16 h-16 bg-gradient-to-br from-pink-500 to-purple-600 rounded-2xl mx-auto mb-4 flex items-center justify-center">
                <span className="text-white text-2xl font-bold">v4</span>
              </div>
              <div className="font-semibold text-corridor-dark mb-2">Uniswap v4</div>
              <div className="text-sm text-corridor-dark/70">
                Custom hooks for dynamic fees and IL protection
              </div>
            </div>
            <div className="text-center">
              <div className="w-16 h-16 bg-gradient-to-br from-blue-500 to-cyan-500 rounded-2xl mx-auto mb-4 flex items-center justify-center">
                <Zap className="w-8 h-8 text-white" />
              </div>
              <div className="font-semibold text-corridor-dark mb-2">Reactive Network</div>
              <div className="text-sm text-corridor-dark/70">
                Automated volatility monitoring and callbacks
              </div>
            </div>
            <div className="text-center">
              <div className="w-16 h-16 bg-gradient-to-br from-corridor-green to-corridor-gold rounded-2xl mx-auto mb-4 flex items-center justify-center">
                <Shield className="w-8 h-8 text-white" />
              </div>
              <div className="font-semibold text-corridor-dark mb-2">Unichain</div>
              <div className="text-sm text-corridor-dark/70">
                Low-cost, high-speed infrastructure on Uniswap's L2
              </div>
            </div>
          </div>
        </motion.div>
      </div>
    </section>
  );
}
