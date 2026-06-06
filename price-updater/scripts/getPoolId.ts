/**
 * Helper script to calculate Pool ID from pool parameters
 * 
 * Usage: ts-node scripts/getPoolId.ts <currency0> <currency1> <fee> <tickSpacing> <hooks>
 * 
 * Example:
 * ts-node scripts/getPoolId.ts \
 *   0x1234... \
 *   0x5678... \
 *   3000 \
 *   60 \
 *   0xabcd...
 */

import { ethers } from 'ethers';

interface PoolKey {
  currency0: string;
  currency1: string;
  fee: number;
  tickSpacing: number;
  hooks: string;
}

function calculatePoolId(poolKey: PoolKey): string {
  // Uniswap v4 PoolId calculation: keccak256(abi.encode(poolKey))
  const encoded = ethers.AbiCoder.defaultAbiCoder().encode(
    ['address', 'address', 'uint24', 'int24', 'address'],
    [
      poolKey.currency0,
      poolKey.currency1,
      poolKey.fee,
      poolKey.tickSpacing,
      poolKey.hooks,
    ]
  );

  const poolId = ethers.keccak256(encoded);
  return poolId;
}

// Main execution
if (require.main === module) {
  const args = process.argv.slice(2);

  if (args.length !== 5) {
    console.error('Usage: ts-node getPoolId.ts <currency0> <currency1> <fee> <tickSpacing> <hooks>');
    console.error('\nExample:');
    console.error('ts-node getPoolId.ts \\');
    console.error('  0x1234567890123456789012345678901234567890 \\');
    console.error('  0x5678901234567890123456789012345678901234 \\');
    console.error('  3000 \\');
    console.error('  60 \\');
    console.error('  0xabcdef0123456789abcdef0123456789abcdef01');
    process.exit(1);
  }

  const poolKey: PoolKey = {
    currency0: args[0],
    currency1: args[1],
    fee: parseInt(args[2]),
    tickSpacing: parseInt(args[3]),
    hooks: args[4],
  };

  console.log('\n🔑 Pool Key:');
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
  console.log(`Currency 0:   ${poolKey.currency0}`);
  console.log(`Currency 1:   ${poolKey.currency1}`);
  console.log(`Fee:          ${poolKey.fee} (${poolKey.fee / 10000}%)`);
  console.log(`Tick Spacing: ${poolKey.tickSpacing}`);
  console.log(`Hooks:        ${poolKey.hooks}`);
  console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

  const poolId = calculatePoolId(poolKey);

  console.log('✅ Pool ID (bytes32):');
  console.log(poolId);
  console.log('\n💡 Add this to your price-updater .env file:');
  console.log(`POOL_ID=${poolId}\n`);
}

export { calculatePoolId, PoolKey };
