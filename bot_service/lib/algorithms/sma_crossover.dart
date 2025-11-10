import '../models/trade_signal.dart';
import '../utils/technical_indicators.dart';
import 'trading_algorithm.dart';

/// Simple Moving Average Crossover Strategy
/// Generates BUY signal when short SMA crosses above long SMA
/// Generates SELL signal when short SMA crosses below long SMA
class SMACrossover extends TradingAlgorithm {
  double? _previousShortSMA;
  double? _previousLongSMA;

  SMACrossover({
    int shortPeriod = 20,
    int longPeriod = 50,
    double quantity = 0.001,
  }) : super(
          name: 'SMA Crossover',
          params: {
            'short_period': shortPeriod,
            'long_period': longPeriod,
            'quantity': quantity,
          },
        );

  @override
  Future<TradeSignal?> analyze(String symbol, double currentPrice) async {
    addPrice(symbol, currentPrice);

    final prices = getPriceHistory(symbol);
    final longPeriod = params['long_period'] as int;

    // Need enough data for long period
    if (prices.length < longPeriod) {
      return null;
    }

    final shortSMA = TechnicalIndicators.sma(prices, params['short_period'] as int);
    final longSMA = TechnicalIndicators.sma(prices, longPeriod);

    TradeSignal? signal;

    // Check for crossover
    if (_previousShortSMA != null && _previousLongSMA != null) {
      // Bullish crossover: short crosses above long
      if (_previousShortSMA! < _previousLongSMA! && shortSMA > longSMA) {
        signal = TradeSignal(
          side: 'BUY',
          type: 'MARKET',
          quantity: params['quantity'] as double,
          reason: 'SMA bullish crossover (${params['short_period']}/${params['long_period']})',
          algorithmName: name,
          confidence: _calculateConfidence(shortSMA, longSMA),
        );
      }
      // Bearish crossover: short crosses below long
      else if (_previousShortSMA! > _previousLongSMA! && shortSMA < longSMA) {
        signal = TradeSignal(
          side: 'SELL',
          type: 'MARKET',
          quantity: params['quantity'] as double,
          reason: 'SMA bearish crossover (${params['short_period']}/${params['long_period']})',
          algorithmName: name,
          confidence: _calculateConfidence(longSMA, shortSMA),
        );
      }
    }

    // Store current values for next iteration
    _previousShortSMA = shortSMA;
    _previousLongSMA = longSMA;

    return signal;
  }

  double _calculateConfidence(double higher, double lower) {
    // Calculate confidence based on the gap between SMAs
    final gap = (higher - lower).abs() / lower;
    return (gap * 100).clamp(0.3, 0.9);
  }
}
