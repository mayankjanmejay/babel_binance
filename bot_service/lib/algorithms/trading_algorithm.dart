import '../models/trade_signal.dart';
import '../utils/technical_indicators.dart';

/// Base class for all trading algorithms
abstract class TradingAlgorithm {
  final String name;
  final Map<String, dynamic> params;
  bool active;

  // Price history cache (symbol -> prices)
  final Map<String, List<double>> _priceHistory = {};

  TradingAlgorithm({
    required this.name,
    required this.params,
    this.active = true,
  });

  /// Main method to analyze market and generate trading signals
  Future<TradeSignal?> analyze(String symbol, double currentPrice);

  /// Add price to history
  void addPrice(String symbol, double price) {
    if (!_priceHistory.containsKey(symbol)) {
      _priceHistory[symbol] = [];
    }
    _priceHistory[symbol]!.add(price);

    // Keep only last 200 prices to avoid memory issues
    if (_priceHistory[symbol]!.length > 200) {
      _priceHistory[symbol]!.removeAt(0);
    }
  }

  /// Get price history for a symbol
  List<double> getPriceHistory(String symbol) {
    return _priceHistory[symbol] ?? [];
  }

  /// Clear price history
  void clearHistory() {
    _priceHistory.clear();
  }

  @override
  String toString() => name;
}
