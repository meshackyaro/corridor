export const CORRIDOR_HOOK_ADDRESS = process.env.NEXT_PUBLIC_CORRIDOR_HOOK_ADDRESS as `0x${string}`;
export const PRICE_ORACLE_ADDRESS = process.env.NEXT_PUBLIC_PRICE_ORACLE_ADDRESS as `0x${string}`;
export const REACTIVE_CONTRACT_ADDRESS = process.env.NEXT_PUBLIC_REACTIVE_CONTRACT_ADDRESS as `0x${string}`;

export const CORRIDOR_HOOK_ABI = [
  {
    inputs: [
      { internalType: "contract IPoolManager", name: "_poolManager", type: "address" },
      { internalType: "address", name: "_communityGovernance", type: "address" },
      { internalType: "uint256", name: "_volatilityThreshold", type: "uint256" }
    ],
    stateMutability: "nonpayable",
    type: "constructor"
  },
  {
    inputs: [{ internalType: "PoolId", name: "poolId", type: "bytes32" }],
    name: "poolPaused",
    outputs: [{ internalType: "bool", name: "", type: "bool" }],
    stateMutability: "view",
    type: "function"
  },
  {
    inputs: [{ internalType: "PoolId", name: "poolId", type: "bytes32" }],
    name: "poolDynamicFee",
    outputs: [{ internalType: "uint24", name: "", type: "uint24" }],
    stateMutability: "view",
    type: "function"
  },
  {
    inputs: [],
    name: "volatilityThreshold",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function"
  },
  {
    inputs: [{ internalType: "address", name: "lp", type: "address" }],
    name: "communityLPShares",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function"
  },
  {
    inputs: [],
    name: "totalCommunityShares",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function"
  }
] as const;

export const PRICE_ORACLE_ABI = [
  {
    inputs: [{ internalType: "PoolId", name: "poolId", type: "bytes32" }],
    name: "getPrice",
    outputs: [{ internalType: "uint256", name: "", type: "uint256" }],
    stateMutability: "view",
    type: "function"
  }
] as const;
