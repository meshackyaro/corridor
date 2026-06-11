"use client";

import { motion } from "framer-motion";
import { ArrowRight, Globe, Users, Shield } from "lucide-react";

export function Hero() {
  return (
    <section className="pt-32 pb-20 px-4 sm:px-6 lg:px-8 pattern-dots">
      <div className="max-w-7xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          animate={{ opacity: 1, y: 0 }}
          transition={{ duration: 0.8 }}
          className="text-center"
        >
          {/* Badge */}
          <motion.div
            initial={{ opacity: 0, scale: 0.9 }}
            animate={{ opacity: 1, scale: 1 }}
            transition={{ delay: 0.2 }}
            className="inline-flex items-center space-x-2 bg-corridor-green/10 border border-corridor-green/30 rounded-full px-4 py-2 mb-6"
          >
            <Globe className="w-4 h-4 text-corridor-green" />
            <span className="text-sm font-medium text-corridor-green">
              Powered by Uniswap v4 & Reactive Network
            </span>
          </motion.div>

          {/* Main Heading */}
          <h1 className="text-5xl sm:text-6xl lg:text-7xl font-display font-bold text-corridor-dark mb-6">
            Send Money Home,
            <br />
            <span className="gradient-text">Keep the Change</span>
          </h1>

          {/* Subheading */}
          <p className="text-xl sm:text-2xl text-corridor-dark/70 max-w-3xl mx-auto mb-8">
            Reducing African remittance costs from{" "}
            <span className="font-bold text-corridor-orange line-through">8.37%</span> to{" "}
            <span className="font-bold text-corridor-green">{"<"}1%</span> through
            community-powered liquidity
          </p>

          {/* CTA Buttons */}
          <motion.div
            initial={{ opacity: 0, y: 20 }}
            animate={{ opacity: 1, y: 0 }}
            transition={{ delay: 0.4 }}
            className="flex flex-col sm:flex-row items-center justify-center gap-4"
          >
            <button className="group bg-corridor-green hover:bg-corridor-green/90 text-white px-8 py-4 rounded-xl font-semibold flex items-center space-x-2 transition-all transform hover:scale-105">
              <span>Send Remittance</span>
              <ArrowRight className="w-5 h-5 group-hover:translate-x-1 transition-transform" />
            </button>
            <button className="glass-effect border border-corridor-green/30 text-corridor-dark px-8 py-4 rounded-xl font-semibold hover:border-corridor-green/60 transition-all">
              Become a Community LP
            </button>
          </motion.div>

          {/* Trust Indicators */}
          <motion.div
            initial={{ opacity: 0 }}
            animate={{ opacity: 1 }}
            transition={{ delay: 0.6 }}
            className="mt-16 grid grid-cols-1 sm:grid-cols-3 gap-6 max-w-4xl mx-auto"
          >
            {[
              {
                icon: Shield,
                label: "IL Protected",
                value: "Automated",
              },
              {
                icon: Users,
                label: "Community LPs",
                value: "1,247",
              },
              {
                icon: Globe,
                label: "Total Volume",
                value: "$2.4M",
              },
            ].map((item, i) => (
              <div
                key={i}
                className="glass-effect rounded-xl p-6 border border-corridor-green/20"
              >
                <item.icon className="w-8 h-8 text-corridor-green mx-auto mb-2" />
                <div className="text-2xl font-display font-bold text-corridor-dark">
                  {item.value}
                </div>
                <div className="text-sm text-corridor-dark/60">{item.label}</div>
              </div>
            ))}
          </motion.div>
        </motion.div>
      </div>
    </section>
  );
}
