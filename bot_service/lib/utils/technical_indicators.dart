import 'dart:math';

/// Technical indicators library for trading analysis
class TechnicalIndicators {
  /// Calculate Simple Moving Average
  static double sma(List<double> prices, int period) {
    if (prices.isEmpty || prices.length < period) return 0;

    final subset = prices.sublist(prices.length - period);
    final sum = subset.reduce((a, b) => a + b);
    return sum / period;
  }

  /// Calculate Exponential Moving Average
  static double ema(List<double> prices, int period) {
    if (prices.isEmpty) return 0;
    if (prices.length < period) return prices.last;

    final multiplier = 2 / (period + 1);
    double ema = prices[0];

    for (int i = 1; i < prices.length; i++) {
      ema = (prices[i] - ema) * multiplier + ema;
    }

    return ema;
  }

  /// Calculate Relative Strength Index (RSI)
  static double rsi(List<double> prices, int period) {
    if (prices.length < period + 1) return 50;

    List<double> gains = [];
    List<double> losses = [];

    for (int i = 1; i < prices.length; i++) {
      final change = prices[i] - prices[i - 1];
      gains.add(change > 0 ? change : 0);
      losses.add(change < 0 ? -change : 0);
    }

    final recentGains = gains.sublist(max(0, gains.length - period));
    final recentLosses = losses.sublist(max(0, losses.length - period));

    final avgGain = recentGains.isEmpty ? 0 : recentGains.reduce((a, b) => a + b) / period;
    final avgLoss = recentLosses.isEmpty ? 0 : recentLosses.reduce((a, b) => a + b) / period;

    if (avgLoss == 0) return 100;

    final rs = avgGain / avgLoss;
    return 100 - (100 / (1 + rs));
  }

  /// Calculate Bollinger Bands
  static Map<String, double> bollingerBands(List<double> prices, int period, double stdDevMultiplier) {
    if (prices.length < period) {
      return {'upper': 0, 'middle': 0, 'lower': 0};
    }

    final smaValue = sma(prices, period);
    final subset = prices.sublist(prices.length - period);

    // Calculate standard deviation
    final variance = subset
        .map((price) => pow(price - smaValue, 2))
        .reduce((a, b) => a + b) / period;
    final standardDeviation = sqrt(variance);

    return {
      'upper': smaValue + (stdDevMultiplier * standardDeviation),
      'middle': smaValue,
      'lower': smaValue - (stdDevMultiplier * standardDeviation),
    };
  }

  /// Calculate MACD (Moving Average Convergence Divergence)
  static Map<String, double> macd(
    List<double> prices, {
    int fastPeriod = 12,
    int slowPeriod = 26,
    int signalPeriod = 9,
  }) {
    if (prices.length < slowPeriod) {
      return {'macd': 0, 'signal': 0, 'histogram': 0};
    }

    final fastEMA = ema(prices, fastPeriod);
    final slowEMA = ema(prices, slowPeriod);
    final macdLine = fastEMA - slowEMA;

    // For proper signal line, we'd need to calculate EMA of MACD values
    // Simplified version for now
    final signalLine = macdLine * 0.9; // Approximation

    return {
      'macd': macdLine,
      'signal': signalLine,
      'histogram': macdLine - signalLine,
    };
  }

  /// Calculate price volatility (standard deviation)
  static double volatility(List<double> prices, int period) {
    if (prices.length < period) return 0;

    final subset = prices.sublist(prices.length - period);
    final mean = subset.reduce((a, b) => a + b) / period;

    final variance = subset
        .map((price) => pow(price - mean, 2))
        .reduce((a, b) => a + b) / period;

    return sqrt(variance);
  }

  /// Detect support and resistance levels
  static Map<String, double> supportResistance(List<double> prices, int period) {
    if (prices.length < period) {
      return {'support': 0, 'resistance': 0};
    }

    final subset = prices.sublist(prices.length - period);

    return {
      'support': subset.reduce(min),
      'resistance': subset.reduce(max),
    };
  }
}
