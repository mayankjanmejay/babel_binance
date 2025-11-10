import '../models/trade_signal.dart';
import 'trading_algorithm.dart';

/// Grid Trading Strategy
/// Places buy orders at regular price intervals below current price
/// Places sell orders at regular price intervals above current price
class GridTrading extends TradingAlgorithm {
  final Map<double, bool> _gridLevels = {}; // price -> isFilled
  double? _lastPrice;

  GridTrading({
    double lowerBound = 90000,
    double upperBound = 100000,
    int gridLevels = 10,
    double quantityPerGrid = 0.0001,
  }) : super(
          name: 'Grid Trading',
          params: {
            'lower_bound': lowerBound,
            'upper_bound': upperBound,
            'grid_levels': gridLevels,
            'quantity_per_grid': quantityPerGrid,
          },
        ) {
    _initializeGrid();
  }

  void _initializeGrid() {
    final lowerBound = params['lower_bound'] as double;
    final upperBound = params['upper_bound'] as double;
    final gridLevels = params['grid_levels'] as int;

    final gridStep = (upperBound - lowerBound) / gridLevels;

    for (int i = 0; i <= gridLevels; i++) {
      final price = lowerBound + (gridStep * i);
      _gridLevels[price] = false;
    }
  }

  @override
  Future<TradeSignal?> analyze(String symbol, double currentPrice) async {
    addPrice(symbol, currentPrice);

    // Find nearest grid level
    final sortedLevels = _gridLevels.keys.toList()..sort();

    // Check if price crossed a grid level
    if (_lastPrice != null) {
      // Price moving down - check for buy signals
      if (currentPrice < _lastPrice!) {
        for (final level in sortedLevels) {
          if (_lastPrice! > level && currentPrice <= level && !_gridLevels[level]!) {
            _gridLevels[level] = true;

            return TradeSignal(
              side: 'BUY',
              type: 'LIMIT',
              quantity: params['quantity_per_grid'] as double,
              price: level,
              timeInForce: 'GTC',
              reason: 'Grid level buy at \$${level.toStringAsFixed(2)}',
              algorithmName: name,
              confidence: 0.7,
            );
          }
        }
      }
      // Price moving up - check for sell signals
      else if (currentPrice > _lastPrice!) {
        for (final level in sortedLevels.reversed) {
          if (_lastPrice! < level && currentPrice >= level && _gridLevels[level]!) {
            _gridLevels[level] = false;

            return TradeSignal(
              side: 'SELL',
              type: 'LIMIT',
              quantity: params['quantity_per_grid'] as double,
              price: level,
              timeInForce: 'GTC',
              reason: 'Grid level sell at \$${level.toStringAsFixed(2)}',
              algorithmName: name,
              confidence: 0.7,
            );
          }
        }
      }
    }

    _lastPrice = currentPrice;
    return null;
  }

  /// Recalculate grid based on current market conditions
  void recalculateGrid(double currentPrice) {
    final gridLevels = params['grid_levels'] as int;
    final range = (params['upper_bound'] as double) - (params['lower_bound'] as double);

    // Center grid around current price
    final newLower = currentPrice - (range / 2);
    final newUpper = currentPrice + (range / 2);

    params['lower_bound'] = newLower;
    params['upper_bound'] = newUpper;

    _gridLevels.clear();
    _initializeGrid();
  }
}
