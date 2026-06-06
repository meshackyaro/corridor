import dotenv from 'dotenv';

dotenv.config();

export interface Config {
  privateKey: string;
  rpcUrl: string;
  oracleAddress: string;
  poolId: string;
  updateInterval: number;
  priceApiUrl: string;
  priceApiKey?: string;
  debug: boolean;
  gasPriceMultiplier: number;
  maxRetries: number;
}

function getEnvVar(key: string, required: boolean = true): string {
  const value = process.env[key];
  if (required && !value) {
    throw new Error(`Missing required environment variable: ${key}`);
  }
  return value || '';
}

export const config: Config = {
  privateKey: getEnvVar('PRIVATE_KEY'),
  rpcUrl: getEnvVar('UNICHAIN_SEPOLIA_RPC'),
  oracleAddress: getEnvVar('MOCK_ORACLE_ADDRESS'),
  poolId: getEnvVar('POOL_ID'),
  updateInterval: parseInt(getEnvVar('UPDATE_INTERVAL', false) || '300000'),
  priceApiUrl: getEnvVar('PRICE_API_URL', false) || 'https://api.exchangerate-api.com/v4/latest/USD',
  priceApiKey: getEnvVar('PRICE_API_KEY', false),
  debug: getEnvVar('DEBUG', false) === 'true',
  gasPriceMultiplier: parseFloat(getEnvVar('GAS_PRICE_MULTIPLIER', false) || '1.2'),
  maxRetries: parseInt(getEnvVar('MAX_RETRIES', false) || '3'),
};

// Validate configuration
if (!config.privateKey.startsWith('0x')) {
  throw new Error('PRIVATE_KEY must start with 0x');
}

if (!config.oracleAddress.startsWith('0x') || config.oracleAddress.length !== 42) {
  throw new Error('MOCK_ORACLE_ADDRESS must be a valid Ethereum address');
}

if (!config.poolId.startsWith('0x') || config.poolId.length !== 66) {
  throw new Error('POOL_ID must be a valid bytes32 value');
}

console.log('✅ Configuration loaded successfully');
if (config.debug) {
  console.log('Debug mode enabled');
  console.log(`Update interval: ${config.updateInterval / 1000}s`);
  console.log(`Oracle address: ${config.oracleAddress}`);
}
