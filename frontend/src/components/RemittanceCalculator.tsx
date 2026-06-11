"use client";

import { useState } from "react";
import { motion } from "framer-motion";
import { Calculator, ArrowRight } from "lucide-react";

export function RemittanceCalculator() {
  const [amount, setAmount] = useState(200);

  const westernUnion = amount * 0.0837;
  const bank = amount * 0.065;
  const corridor = amount * 0.003;

  const westernUnionReceives = amount - westernUnion;
  const bankReceives = amount - bank;
  const corridorReceives = amount - corridor;

  const annualSavings = (westernUnion - corridor) * 12;

  return (
    <section className="py-20 px-4 sm:px-6 lg:px-8">
      <div className="max-w-5xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="glass-effect rounded-3xl p-8 sm:p-12 border border-corridor-green/30"
        >
          <div className="flex items-center space-x-3 mb-8">
            <div className="w-12 h-12 bg-corridor-green/10 rounded-xl flex items-center justify-center">
              <Calculator className="w-6 h-6 text-corridor-green" />
            </div>
            <div>
              <h2 className="text-3xl font-display font-bold text-corridor-dark">
                See Your Savings
              </h2>
              <p className="text-corridor-dark/60">
                Compare remittance costs
              </p>
            </div>
          </div>

          {/* Amount Input */}
          <div className="mb-8">
            <label className="block text-sm font-semibold text-corridor-dark mb-2">
              How much are you sending? (USD)
            </label>
            <input
              type="number"
              value={amount}
              onChange={(e) => setAmount(Number(e.target.value))}
              className="w-full px-6 py-4 bg-white border-2 border-corridor-green/30 rounded-xl text-2xl font-bold text-corridor-dark focus:outline-none focus:border-corridor-green"
              min="10"
              step="10"
            />
            <input
              type="range"
              value={amount}
              onChange={(e) => setAmount(Number(e.target.value))}
              min="10"
              max="1000"
              step="10"
              className="w-full mt-4"
            />
          </div>

          {/* Comparison Table */}
          <div className="space-y-4">
            {/* Western Union */}
            <div className="bg-red-50 border-2 border-red-200 rounded-xl p-6">
              <div className="flex items-center justify-between mb-3">
                <div>
                  <div className="font-semibold text-corridor-dark">Western Union</div>
                  <div className="text-sm text-corridor-dark/60">Traditional method</div>
                </div>
                <div className="text-right">
                  <div className="text-2xl font-bold text-red-600">
                    -${westernUnion.toFixed(2)}
                  </div>
                  <div className="text-sm text-corridor-dark/60">8.37% fee</div>
                </div>
              </div>
              <div className="flex items-center justify-between pt-3 border-t border-red-200">
                <span className="text-sm text-corridor-dark/70">Family receives:</span>
                <span className="text-xl font-bold text-corridor-dark">
                  ${westernUnionReceives.toFixed(2)}
                </span>
              </div>
            </div>

            {/* Bank Transfer */}
            <div className="bg-orange-50 border-2 border-orange-200 rounded-xl p-6">
              <div className="flex items-center justify-between mb-3">
                <div>
                  <div className="font-semibold text-corridor-dark">Bank Transfer</div>
                  <div className="text-sm text-corridor-dark/60">Traditional bank</div>
                </div>
                <div className="text-right">
                  <div className="text-2xl font-bold text-orange-600">
                    -${bank.toFixed(2)}
                  </div>
                  <div className="text-sm text-corridor-dark/60">6.5% fee</div>
                </div>
              </div>
              <div className="flex items-center justify-between pt-3 border-t border-orange-200">
                <span className="text-sm text-corridor-dark/70">Family receives:</span>
                <span className="text-xl font-bold text-corridor-dark">
                  ${bankReceives.toFixed(2)}
                </span>
              </div>
            </div>

            {/* Corridor */}
            <div className="bg-green-50 border-2 border-corridor-green rounded-xl p-6 relative overflow-hidden">
              <div className="absolute top-2 right-2 bg-corridor-green text-white text-xs font-bold px-3 py-1 rounded-full">
                BEST VALUE
              </div>
              <div className="flex items-center justify-between mb-3">
                <div>
                  <div className="font-semibold text-corridor-dark">Corridor</div>
                  <div className="text-sm text-corridor-dark/60">Community-powered</div>
                </div>
                <div className="text-right">
                  <div className="text-2xl font-bold text-corridor-green">
                    -${corridor.toFixed(2)}
                  </div>
                  <div className="text-sm text-corridor-dark/60">0.3% fee</div>
                </div>
              </div>
              <div className="flex items-center justify-between pt-3 border-t border-corridor-green">
                <span className="text-sm text-corridor-dark/70">Family receives:</span>
                <span className="text-xl font-bold text-corridor-green">
                  ${corridorReceives.toFixed(2)}
                </span>
              </div>
            </div>
          </div>

          {/* Annual Savings */}
          <motion.div
            initial={{ opacity: 0, scale: 0.95 }}
            whileInView={{ opacity: 1, scale: 1 }}
            viewport={{ once: true }}
            className="mt-8 p-6 bg-gradient-to-br from-corridor-green to-corridor-gold rounded-xl text-white"
          >
            <div className="flex items-center justify-between">
              <div>
                <div className="text-sm opacity-90">Annual Savings vs Western Union</div>
                <div className="text-3xl font-display font-bold">
                  ${annualSavings.toFixed(2)}/year
                </div>
                <div className="text-sm opacity-90 mt-1">
                  Based on monthly ${amount} remittance
                </div>
              </div>
              <ArrowRight className="w-8 h-8" />
            </div>
          </motion.div>

          {/* CTA */}
          <button className="w-full mt-6 bg-corridor-green hover:bg-corridor-green/90 text-white px-8 py-4 rounded-xl font-semibold transition-all transform hover:scale-105">
            Start Sending with Corridor
          </button>
        </motion.div>
      </div>
    </section>
  );
}
