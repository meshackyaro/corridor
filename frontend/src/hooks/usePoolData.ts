"use client";

import { useReadContract } from "wagmi";
import { CORRIDOR_HOOK_ADDRESS, CORRIDOR_HOOK_ABI } from "@/lib/contracts";

// Mock pool ID - replace with actual pool ID from your deployment
const MOCK_POOL_ID = "0x0000000000000000000000000000000000000000000000000000000000000000" as `0x${string}`;

export function usePoolData() {
  const { data: isPaused } = useReadContract({
    address: CORRIDOR_HOOK_ADDRESS,
    abi: CORRIDOR_HOOK_ABI,
    functionName: "poolPaused",
    args: [MOCK_POOL_ID],
  });

  const { data: dynamicFee } = useReadContract({
    address: CORRIDOR_HOOK_ADDRESS,
    abi: CORRIDOR_HOOK_ABI,
    functionName: "poolDynamicFee",
    args: [MOCK_POOL_ID],
  });

  const { data: volatilityThreshold } = useReadContract({
    address: CORRIDOR_HOOK_ADDRESS,
    abi: CORRIDOR_HOOK_ABI,
    functionName: "volatilityThreshold",
  });

  const { data: totalShares } = useReadContract({
    address: CORRIDOR_HOOK_ADDRESS,
    abi: CORRIDOR_HOOK_ABI,
    functionName: "totalCommunityShares",
  });

  return {
    isPaused: isPaused ?? false,
    dynamicFee: dynamicFee ? Number(dynamicFee) / 10000 : 0.3, // Convert from bps to percentage
    volatilityThreshold: volatilityThreshold ? Number(volatilityThreshold) / 100 : 5,
    totalShares: totalShares ? Number(totalShares) : 0,
  };
}

export function useLPData(address?: `0x${string}`) {
  const { data: shares } = useReadContract({
    address: CORRIDOR_HOOK_ADDRESS,
    abi: CORRIDOR_HOOK_ABI,
    functionName: "communityLPShares",
    args: address ? [address] : undefined,
  });

  return {
    shares: shares ? Number(shares) : 0,
  };
}
