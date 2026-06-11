"use client";

import { Hero } from "@/components/Hero";
import { Stats } from "@/components/Stats";
import { RemittanceCalculator } from "@/components/RemittanceCalculator";
import { PoolStatus } from "@/components/PoolStatus";
import { CommunityLP } from "@/components/CommunityLP";
import { HowItWorks } from "@/components/HowItWorks";
import { Header } from "@/components/Header";
import { Footer } from "@/components/Footer";

export default function Home() {
  return (
    <div className="min-h-screen">
      <Header />
      
      <main>
        <Hero />
        <Stats />
        <RemittanceCalculator />
        <PoolStatus />
        <CommunityLP />
        <HowItWorks />
      </main>

      <Footer />
    </div>
  );
}
