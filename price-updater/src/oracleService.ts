import { ethers } from 'ethers';
import { config } from './config';

// MockPriceOracle ABI (only the functions we need)
const MOCK_ORACLE_ABI = [
  'function updatePrice(bytes32 poolId, uint256 newPrice) external',
  'function getPrice(bytes32 poolId) external view returns (uint256)',
  'event PriceUpdated(bytes32 indexed poolId, uint256 newPrice)',
];

export class OracleService {
  private provider: ethers.JsonRpcProvider;
  private wallet: ethers.Wallet;
  private oracle: ethers.Contract;

  constructor() {
    this.provider = new ethers.JsonRpcProvider(config.rpcUrl);
    this.wallet = new ethers.Wallet(config.privateKey, this.provider);
    this.oracle = new ethers.Contract(
      config.oracleAddress,
      MOCK_ORACLE_ABI,
      this.wallet
    );

    console.log(`🔗 Connected to Unichain Sepolia`);
    console.log(`📍 Oracle: ${config.oracleAddress}`);
    console.log(`👛 Wallet: ${this.wallet.address}`);
  }

  /**
   * Gets the current price from the oracle
   */
  async getCurrentPrice(): Promise<bigint> {
    try {
      const price = await this.oracle.getPrice(config.poolId);
      return price;
    } catch (error) {
      console.error('Failed to get current price:', error);
      return 0n;
    }
  }

  /**
   * Updates the price on the oracle contract
   */
  async updatePrice(newPrice: string): Promise<boolean> {
    let retries = 0;
    
    while (retries < config.maxRetries) {
      try {
        console.log(`📤 Sending price update transaction...`);

        // Get current gas price and apply multiplier
        const feeData = await this.provider.getFeeData();
        const gasPrice = feeData.gasPrice 
          ? (feeData.gasPrice * BigInt(Math.floor(config.gasPriceMultiplier * 100))) / 100n
          : undefined;

        // Send transaction
        const tx = await this.oracle.updatePrice(config.poolId, newPrice, {
          gasPrice,
          gasLimit: 150000, // Set reasonable gas limit
        });

        console.log(`⏳ Transaction sent: ${tx.hash}`);
        console.log(`   Waiting for confirmation...`);

        // Wait for confirmation
        const receipt = await tx.wait();

        if (receipt.status === 1) {
          console.log(`✅ Price updated successfully!`);
          console.log(`   Block: ${receipt.blockNumber}`);
          console.log(`   Gas used: ${receipt.gasUsed.toString()}`);
          return true;
        } else {
          throw new Error('Transaction failed');
        }
      } catch (error: any) {
        retries++;
        console.error(`❌ Update failed (attempt ${retries}/${config.maxRetries}):`, error.message);

        if (retries < config.maxRetries) {
          console.log(`   Retrying in 10 seconds...`);
          await this.sleep(10000);
        }
      }
    }

    return false;
  }

  /**
   * Checks wallet balance
   */
  async checkBalance(): Promise<void> {
    const balance = await this.provider.getBalance(this.wallet.address);
    const ethBalance = ethers.formatEther(balance);
    
    console.log(`💰 Wallet balance: ${parseFloat(ethBalance).toFixed(6)} ETH`);
    
    if (parseFloat(ethBalance) < 0.001) {
      console.warn('⚠️  Low balance! Get testnet ETH from https://bridge.unichain.org/');
    }
  }

  private sleep(ms: number): Promise<void> {
    return new Promise(resolve => setTimeout(resolve, ms));
  }
}
