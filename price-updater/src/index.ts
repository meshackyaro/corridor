import { config } from './config';
import { fetchNGNPrice, validatePriceChange, PriceData } from './priceService';
import { OracleService } from './oracleService';

let lastPrice = 0;
let updateCount = 0;
let failureCount = 0;

/**
 * Main price update function
 */
async function updatePriceOnChain(oracleService: OracleService): Promise<void> {
  try {
    console.log('\n━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━');
    console.log(`🔄 Update #${updateCount + 1} - ${new Date().toLocaleString()}`);
    console.log('━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━\n');

    // Fetch latest NGN/USD price
    console.log('1️⃣  Fetching NGN/USD price...');
    const priceData: PriceData = await fetchNGNPrice();
    
    console.log(`   Rate: 1 USD = ${priceData.rate.toFixed(2)} NGN`);
    console.log(`   Price: 1 NGN = ${priceData.usdNgn.toFixed(6)} USD`);
    console.log(`   Oracle format: ${priceData.price8Decimals} (8 decimals)\n`);

    // Validate price change
    const newPriceNum = parseFloat(priceData.price8Decimals);
    if (!validatePriceChange(lastPrice, newPriceNum)) {
      console.error('❌ Price change too large, skipping update for safety\n');
      failureCount++;
      return;
    }

    // Update on-chain
    console.log('2️⃣  Updating on-chain oracle...');
    const success = await oracleService.updatePrice(priceData.price8Decimals);

    if (success) {
      lastPrice = newPriceNum;
      updateCount++;
      failureCount = 0; // Reset failure count on success
      
      console.log(`\n✨ Successfully updated price on Unichain Sepolia`);
      console.log(`   Total updates: ${updateCount}`);
      console.log(`   Next update in ${config.updateInterval / 1000}s\n`);
    } else {
      failureCount++;
      console.error(`\n❌ Failed to update price`);
      console.error(`   Consecutive failures: ${failureCount}\n`);
      
      if (failureCount >= 3) {
        console.error('🚨 Too many consecutive failures. Check your configuration!');
        await oracleService.checkBalance();
      }
    }
  } catch (error: any) {
    failureCount++;
    console.error(`\n❌ Error during update:`, error.message);
    console.error(`   Consecutive failures: ${failureCount}\n`);
  }
}

/**
 * Main function - initializes services and starts update loop
 */
async function main() {
  console.log('\n');
  console.log('╔═══════════════════════════════════════════════╗');
  console.log('║                                               ║');
  console.log('║     🌍  CORRIDOR PRICE UPDATER SERVICE       ║');
  console.log('║                                               ║');
  console.log('║     Real-time NGN/USD Oracle for Unichain    ║');
  console.log('║                                               ║');
  console.log('╚═══════════════════════════════════════════════╝');
  console.log('\n');

  try {
    // Initialize oracle service
    const oracleService = new OracleService();
    
    // Check wallet balance
    await oracleService.checkBalance();
    
    // Get current on-chain price
    const currentPrice = await oracleService.getCurrentPrice();
    if (currentPrice > 0n) {
      console.log(`📊 Current on-chain price: ${currentPrice.toString()} (8 decimals)`);
      lastPrice = Number(currentPrice);
    }
    
    console.log(`\n⏰ Starting automatic updates every ${config.updateInterval / 1000}s\n`);
    
    // Perform initial update immediately
    await updatePriceOnChain(oracleService);
    
    // Start periodic updates
    setInterval(() => {
      updatePriceOnChain(oracleService);
    }, config.updateInterval);

    // Handle graceful shutdown
    process.on('SIGINT', () => {
      console.log('\n\n👋 Shutting down gracefully...');
      console.log(`   Total updates completed: ${updateCount}`);
      console.log(`   Total failures: ${failureCount}`);
      console.log('\n✅ Price updater stopped\n');
      process.exit(0);
    });

  } catch (error: any) {
    console.error('\n❌ Failed to initialize price updater:', error.message);
    console.error('\nPlease check your configuration and try again.\n');
    process.exit(1);
  }
}

// Start the price updater
main().catch((error) => {
  console.error('Fatal error:', error);
  process.exit(1);
});
