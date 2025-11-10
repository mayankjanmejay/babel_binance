import '../models/trade_signal.dart';
import '../utils/technical_indicators.dart';
import 'trading_algorithm.dart';

/// RSI (Relative Strength Index) Strategy
/// Generates BUY signal when RSI < oversold threshold (e.g., 30)
/// Generates SELL signal when RSI > overbought threshold (e.g., 70)
class RSIStrategy extends TradingAlgorithm {
  RSIStrategy({
    int period = 14,
    double oversold = 30,
    double overbought = 70,
    double quantity = 0.001,
  }) : super(
          name: 'RSI Strategy',
          params: {
            'period': period,
            'oversold': oversold,
            'overbought': overbought,
            'quantity': quantity,
          },
        );

  @override
  Future<TradeSignal?> analyze(String symbol, double currentPrice) async {
    addPrice(symbol, currentPrice);

    final prices = getPriceHistory(symbol);
    final period = params['period'] as int;

    // Need at least period + 1 prices for RSI
    if (prices.length < period + 1) {
      return null;
    }

    final rsi = TechnicalIndicators.rsi(prices, period);
    final oversold = params['oversold'] as double;
    final overbought = params['overbought'] as double;

    // Oversold condition - potential BUY
    if (rsi < oversold) {
      return TradeSignal(
        side: 'BUY',
        type: 'MARKET',
        quantity: params['quantity'] as double,
        reason: 'RSI oversold (${rsi.toStringAsFixed(2)} < $oversold)',
        algorithmName: name,
        confidence: _calculateConfidence(rsi, oversold, true),
      );
    }

    // Overbought condition - potential SELL
    if (rsi > overbought) {
      return TradeSignal(
        side: 'SELL',
        type: 'MARKET',
        quantity: params['quantity'] as double,
        reason: 'RSI overbought (${rsi.toStringAsFixed(2)} > $overbought)',
        algorithmName: name,
        confidence: _calculateConfidence(rsi, overbought, false),
      );
    }

    return null;
  }

  double _calculateConfidence(double rsi, double threshold, bool isBuy) {
    // More extreme RSI = higher confidence
    if (isBuy) {
      // Lower RSI = higher confidence for BUY
      final distance = threshold - rsi;
      return (distance / threshold).clamp(0.3, 0.9);
    } else {
      // Higher RSI = higher confidence for SELL
      final distance = rsi - threshold;
      return (distance / (100 - threshold)).clamp(0.3, 0.9);
    }
  }
}
