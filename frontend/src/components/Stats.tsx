"use client";

import { motion } from "framer-motion";
import { TrendingDown, DollarSign, Users, Globe } from "lucide-react";

export function Stats() {
  const stats = [
    {
      icon: TrendingDown,
      label: "Cost Reduction",
      value: "96%",
      subtext: "From 8.37% to <1%",
      color: "text-corridor-green",
      bgColor: "bg-corridor-green/10",
    },
    {
      icon: DollarSign,
      label: "Market Size",
      value: "$54B",
      subtext: "Annual African remittances",
      color: "text-corridor-gold",
      bgColor: "bg-corridor-gold/10",
    },
    {
      icon: Users,
      label: "Potential Users",
      value: "22M+",
      subtext: "Nigerian crypto users",
      color: "text-corridor-orange",
      bgColor: "bg-corridor-orange/10",
    },
    {
      icon: Globe,
      label: "Corridors Active",
      value: "3",
      subtext: "USD/NGN, GBP/NGN, EUR/NGN",
      color: "text-corridor-green",
      bgColor: "bg-corridor-green/10",
    },
  ];

  return (
    <section className="py-16 px-4 sm:px-6 lg:px-8 bg-white/50">
      <div className="max-w-7xl mx-auto">
        <motion.div
          initial={{ opacity: 0, y: 20 }}
          whileInView={{ opacity: 1, y: 0 }}
          viewport={{ once: true }}
          transition={{ duration: 0.6 }}
          className="text-center mb-12"
        >
          <h2 className="text-3xl sm:text-4xl font-display font-bold text-corridor-dark mb-4">
            Impact at Scale
          </h2>
          <p className="text-lg text-corridor-dark/70">
            Building infrastructure that serves African communities worldwide
          </p>
        </motion.div>

        <div className="grid grid-cols-1 sm:grid-cols-2 lg:grid-cols-4 gap-6">
          {stats.map((stat, i) => (
            <motion.div
              key={i}
              initial={{ opacity: 0, y: 20 }}
              whileInView={{ opacity: 1, y: 0 }}
              viewport={{ once: true }}
              transition={{ duration: 0.6, delay: i * 0.1 }}
              className="glass-effect rounded-2xl p-6 border border-corridor-green/20 hover:border-corridor-green/40 transition-all"
            >
              <div className={`${stat.bgColor} w-12 h-12 rounded-xl flex items-center justify-center mb-4`}>
                <stat.icon className={`w-6 h-6 ${stat.color}`} />
              </div>
              <div className="text-3xl font-display font-bold text-corridor-dark mb-1">
                {stat.value}
              </div>
              <div className="text-sm font-semibold text-corridor-dark/80 mb-1">
                {stat.label}
              </div>
              <div className="text-xs text-corridor-dark/60">{stat.subtext}</div>
            </motion.div>
          ))}
        </div>
      </div>
    </section>
  );
}
