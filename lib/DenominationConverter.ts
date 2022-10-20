const decimals = 100000000;
const mdecimals = 1000000;

/**
 * Convert whole coins to satoshis
 */
export const coinsToSatoshis = (coins: number): number => {
  return coins * decimals;
};

/**
 * Convert satoshis to whole coins and remove trailing zeros
 */
export const satoshisToCoins = (satoshis: number): number => {
  return roundToDecimals(satoshis / decimals, 8);
};

/**
 * Round a number to a specific amount of decimals
 */
const roundToDecimals = (number: number, decimals: number): number => {
  return Number(number.toFixed(decimals));
};

/**
 * Convert mstx to stx = divide by 10**6
 */
 export const mstxToSTX = (millistx: number): number => {
  return roundToDecimals(millistx / mdecimals, 8);
};
