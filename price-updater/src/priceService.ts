import axios from 'axios';
import { config } from './config';

export interface PriceData {
  rate: number;          // NGN per USD (e.g., 1565)
  usdNgn: number;        // USD per NGN (e.g., 0.000638)
  price8Decimals: string; // Price in 8 decimals (e.g., "63800")
  timestamp: number;
}

/**
 * Fetches the latest NGN/USD exchange rate from the configured API
 */
export async function fetchNGNPrice(): Promise<PriceData> {
  try {
    const response = await axios.get(config.priceApiUrl, {
      timeout: 10000,
      headers: config.priceApiKey ? { 'apikey': config.priceApiKey } : {},
    });

    // Extract NGN rate (different APIs have different structures)
    let ngnRate: number;
    
    if (response.data.rates && response.data.rates.NGN) {
      // exchangerate-api.com format
      ngnRate = response.data.rates.NGN;
    } else if (response.data.data && response.data.data.NGN) {
      // currencyapi.com format
      ngnRate = response.data.data.NGN.value;
    } else {
      throw new Error('Unexpected API response format');
    }

    // Calculate USD/NGN (inverse)
    const usdNgn = 1 / ngnRate;

    // Convert to 8 decimals (Chainlink format)
    // e.g., 0.000638 USD/NGN = 63800 (with 8 decimals)
    const price8Decimals = Math.floor(usdNgn * 1e8).toString();

    const priceData: PriceData = {
      rate: ngnRate,
      usdNgn,
      price8Decimals,
      timestamp: Date.now(),
    };

    if (config.debug) {
      console.log('📊 Price Data:', {
        ngnPerUsd: ngnRate.toFixed(2),
        usdPerNgn: usdNgn.toFixed(6),
        price8Dec: price8Decimals,
      });
    }

    return priceData;
  } catch (error) {
    if (axios.isAxiosError(error)) {
      throw new Error(`Failed to fetch price: ${error.message}`);
    }
    throw error;
  }
}

/**
 * Validates that the price change is reasonable (prevents oracle manipulation)
 */
export function validatePriceChange(
  oldPrice: number,
  newPrice: number,
  maxChangePercent: number = 20
): boolean {
  if (oldPrice === 0) return true; // First price update
  
  const changePercent = Math.abs((newPrice - oldPrice) / oldPrice) * 100;
  
  if (changePercent > maxChangePercent) {
    console.warn(`⚠️  Large price change detected: ${changePercent.toFixed(2)}%`);
    return false;
  }
  
  return true;
}
