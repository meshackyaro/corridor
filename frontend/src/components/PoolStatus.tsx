"use client";

import { useState, useEffect } from "react";
import { motion } from "framer-motion";
import { Activity, Shield, TrendingUp, AlertCircle } from "lucide-react";
import { LineChart, Line, XAxis, YAxis, CartesianGrid, Tooltip, ResponsiveContainer } from "recharts";

export function PoolStatus() {
  const [poolData, setPoolData] = useState({
    isPaused: false,
    currentFee: 0.3,
    volatility: 2.1,
    tvl: 847200,
    volume24h: 123400,
  });

  // Mock price history data
  const priceHistory = [
    { time: "00:00", price: 1650, volatility: 1.2 },
    { time: "04:00", price: 1655, volatility: 1.8 },
    { time: "08:00", price: 1642, volatility: 2.1 },
    { time: "12:00", price: 1658, volatility: 1.5 },
    { time: "16:00", price: 1651, volatility: 1.9 },
    { time: "20:00", price: 1649, volatility: 2.1 },
  ];

  return (
    <section className="py-20 px-4 sm:px-6 lg:px-8 bg-white/50">
      <div className="max-w-7xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-12"
        >
          <h2 className="text-3xl sm:text-4xl font-display font-bold text-corridor-dark mb-4">
            Live Pool Status
          </h2>
          <p className="text-lg text-corridor-dark/70">
            Real-time monitoring powered by Reactive Network
          </p>
        </motion.div>

        <div className="grid grid-cols-1 lg:grid-cols-3 gap-6">
          {/* Status Cards */}
          <div className="lg:col-span-1 space-y-6">
            {/* Pool Status */}
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              className="glass-effect rounded-2xl p-6 border border-corridor-green/20"
            >
              <div className="flex items-center space-x-3 mb-4">
                <div className={`w-10 h-10 rounded-xl flex items-center justify-center ${
                  poolData.isPaused ? "bg-red-100" : "bg-green-100"
                }`}>
                  {poolData.isPaused ? (
                    <AlertCircle className="w-5 h-5 text-red-600" />
                  ) : (
                    <Activity className="w-5 h-5 text-green-600" />
                  )}
                </div>
                <div>
                  <div className="text-sm text-corridor-dark/60">Pool Status</div>
                  <div className="text-xl font-bold text-corridor-dark">
                    {poolData.isPaused ? "Paused" : "Active"}
                  </div>
                </div>
              </div>
              {!poolData.isPaused && (
                <div className="flex items-center space-x-2 text-sm text-green-600">
                  <div className="w-2 h-2 bg-green-600 rounded-full animate-pulse" />
                  <span>Swaps operational</span>
                </div>
              )}
            </motion.div>

            {/* Current Fee */}
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.1 }}
              className="glass-effect rounded-2xl p-6 border border-corridor-green/20"
            >
              <div className="flex items-center space-x-3 mb-4">
                <div className="w-10 h-10 bg-corridor-gold/10 rounded-xl flex items-center justify-center">
                  <TrendingUp className="w-5 h-5 text-corridor-gold" />
                </div>
                <div>
                  <div className="text-sm text-corridor-dark/60">Current Fee</div>
                  <div className="text-xl font-bold text-corridor-dark">
                    {poolData.currentFee}%
                  </div>
                </div>
              </div>
              <div className="text-xs text-corridor-dark/60">
                Base: 0.3% • Max: 1.0%
              </div>
            </motion.div>

            {/* Volatility */}
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.2 }}
              className="glass-effect rounded-2xl p-6 border border-corridor-green/20"
            >
              <div className="flex items-center space-x-3 mb-4">
                <div className="w-10 h-10 bg-corridor-orange/10 rounded-xl flex items-center justify-center">
                  <Shield className="w-5 h-5 text-corridor-orange" />
                </div>
                <div>
                  <div className="text-sm text-corridor-dark/60">Volatility</div>
                  <div className="text-xl font-bold text-corridor-dark">
                    {poolData.volatility}%
                  </div>
                </div>
              </div>
              <div className="w-full bg-gray-200 rounded-full h-2">
                <div
                  className="bg-corridor-orange h-2 rounded-full transition-all"
                  style={{ width: `${(poolData.volatility / 5) * 100}%` }}
                />
              </div>
              <div className="text-xs text-corridor-dark/60 mt-2">
                Threshold: 5% • Status: Normal
              </div>
            </motion.div>

            {/* TVL & Volume */}
            <motion.div
              initial={{ opacity: 0, x: -20 }}
              whileInView={{ opacity: 1, x: 0 }}
              viewport={{ once: true }}
              transition={{ delay: 0.3 }}
              className="glass-effect rounded-2xl p-6 border border-corridor-green/20"
            >
              <div className="space-y-4">
                <div>
                  <div className="text-sm text-corridor-dark/60 mb-1">Total Value Locked</div>
                  <div className="text-2xl font-bold text-corridor-dark">
                    ${(poolData.tvl / 1000).toFixed(1)}K
                  </div>
                </div>
                <div>
                  <div className="text-sm text-corridor-dark/60 mb-1">24h Volume</div>
                  <div className="text-2xl font-bold text-corridor-dark">
                    ${(poolData.volume24h / 1000).toFixed(1)}K
                  </div>
                </div>
              </div>
            </motion.div>
          </div>

          {/* Price Chart */}
          <motion.div
            initial={{ opacity: 0, x: 20 }}
            whileInView={{ opacity: 1, x: 0 }}
            viewport={{ once: true }}
            className="lg:col-span-2 glass-effect rounded-2xl p-6 border border-corridor-green/20"
          >
            <h3 className="text-xl font-display font-bold text-corridor-dark mb-6">
              NGN/USD Price & Volatility (24h)
            </h3>
            <ResponsiveContainer width="100%" height={300}>
              <LineChart data={priceHistory}>
                <CartesianGrid strokeDasharray="3 3" stroke="#2D6A4F20" />
                <XAxis
                  dataKey="time"
                  stroke="#1B263B"
                  style={{ fontSize: "12px" }}
                />
                <YAxis
                  stroke="#1B263B"
                  style={{ fontSize: "12px" }}
                  domain={[1640, 1660]}
                />
                <Tooltip
                  contentStyle={{
                    backgroundColor: "rgba(255, 255, 255, 0.9)",
                    border: "1px solid #2D6A4F",
                    borderRadius: "8px",
                  }}
                />
                <Line
                  type="monotone"
                  dataKey="price"
                  stroke="#2D6A4F"
                  strokeWidth={2}
                  dot={{ fill: "#2D6A4F", r: 4 }}
                />
              </LineChart>
            </ResponsiveContainer>

            <div className="mt-6 p-4 bg-corridor-green/5 rounded-xl border border-corridor-green/20">
              <div className="flex items-start space-x-3">
                <Shield className="w-5 h-5 text-corridor-green mt-0.5" />
                <div className="flex-1">
                  <div className="font-semibold text-corridor-dark mb-1">
                    IL Protection Active
                  </div>
                  <div className="text-sm text-corridor-dark/70">
                    Reactive Network monitors price movements every block. If volatility exceeds 5%,
                    the pool automatically pauses to protect community LPs from impermanent loss.
                  </div>
                </div>
              </div>
            </div>
          </motion.div>
        </div>
      </div>
    </section>
  );
}
