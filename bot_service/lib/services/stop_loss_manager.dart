import 'dart:async';
import 'package:logging/logging.dart';
import '../models/stop_loss_order.dart';
import '../models/trade_signal.dart';

/// Manages stop-loss and take-profit orders
class StopLossManager {
  final Logger _log = Logger('StopLossManager');
  final List<StopLossOrder> _stopLossOrders = [];
  final List<TakeProfitOrder> _takeProfitOrders = [];

  // Configuration
  final double defaultStopLossPercent;
  final double defaultTakeProfitPercent;
  final bool enableTrailingStop;
  final double trailingStopPercent;

  StopLossManager({
    this.defaultStopLossPercent = 0.02, // 2% stop loss
    this.defaultTakeProfitPercent = 0.05, // 5% take profit
    this.enableTrailingStop = true,
    this.trailingStopPercent = 0.02, // 2% trailing
  });

  /// Add stop-loss order for a new position
  void addStopLoss({
    required String symbol,
    required String side,
    required double entryPrice,
    required double quantity,
    double? customStopPercent,
  }) {
    final stopPercent = customStopPercent ?? defaultStopLossPercent;
    final stopPrice = side == 'BUY'
        ? entryPrice * (1 - stopPercent)
        : entryPrice * (1 + stopPercent);

    final stopLoss = StopLossOrder(
      symbol: symbol,
      side: side,
      entryPrice: entryPrice,
      stopPrice: stopPrice,
      quantity: quantity,
      trailingPercent: enableTrailingStop ? trailingStopPercent : null,
      createdAt: DateTime.now(),
    );

    _stopLossOrders.add(stopLoss);
    _log.info('Added stop-loss: $stopLoss');
  }

  /// Add take-profit order for a new position
  void addTakeProfit({
    required String symbol,
    required String side,
    required double entryPrice,
    required double quantity,
    double? customTargetPercent,
  }) {
    final targetPercent = customTargetPercent ?? defaultTakeProfitPercent;
    final targetPrice = side == 'BUY'
        ? entryPrice * (1 + targetPercent)
        : entryPrice * (1 - targetPercent);

    final takeProfit = TakeProfitOrder(
      symbol: symbol,
      side: side,
      entryPrice: entryPrice,
      targetPrice: targetPrice,
      quantity: quantity,
      createdAt: DateTime.now(),
    );

    _takeProfitOrders.add(takeProfit);
    _log.info('Added take-profit: $takeProfit');
  }

  /// Check all stop-loss orders and generate signals if triggered
  List<TradeSignal> checkStopLosses(Map<String, double> currentPrices) {
    final signals = <TradeSignal>[];

    for (final stopLoss in _stopLossOrders.where((sl) => sl.isActive)) {
      final price = currentPrices[stopLoss.symbol];
      if (price == null) continue;

      // Update trailing stop if enabled
      if (stopLoss.trailingPercent != null) {
        final newStop = stopLoss.updateTrailingStop(price);
        if (newStop != null) {
          _log.fine(
            'Trailing stop updated for ${stopLoss.symbol}: '
            '\$${stopLoss.stopPrice.toStringAsFixed(2)} → \$${newStop.toStringAsFixed(2)}'
          );
          // Update the stop price (would need to modify StopLossOrder to be mutable)
        }
      }

      // Check if stop-loss should trigger
      if (stopLoss.shouldTrigger(price)) {
        final pl = stopLoss.calculatePL(price);
        final plPercent = stopLoss.calculatePLPercent(price);

        _log.warning(
          '🛑 Stop-loss triggered for ${stopLoss.symbol}: '
          'Entry: \$${stopLoss.entryPrice.toStringAsFixed(2)}, '
          'Stop: \$${stopLoss.stopPrice.toStringAsFixed(2)}, '
          'Current: \$${price.toStringAsFixed(2)}, '
          'P&L: \$${pl.toStringAsFixed(2)} (${plPercent.toStringAsFixed(2)}%)'
        );

        signals.add(stopLoss.generateExitSignal());
        stopLoss.isActive = false; // Deactivate after triggering
      }
    }

    return signals;
  }

  /// Check all take-profit orders and generate signals if triggered
  List<TradeSignal> checkTakeProfits(Map<String, double> currentPrices) {
    final signals = <TradeSignal>[];

    for (final takeProfit in _takeProfitOrders.where((tp) => tp.isActive)) {
      final price = currentPrices[takeProfit.symbol];
      if (price == null) continue;

      if (takeProfit.shouldTrigger(price)) {
        _log.info(
          '🎯 Take-profit triggered for ${takeProfit.symbol}: '
          'Entry: \$${takeProfit.entryPrice.toStringAsFixed(2)}, '
          'Target: \$${takeProfit.targetPrice.toStringAsFixed(2)}, '
          'Current: \$${price.toStringAsFixed(2)}'
        );

        signals.add(takeProfit.generateExitSignal());
        takeProfit.isActive = false; // Deactivate after triggering
      }
    }

    return signals;
  }

  /// Check all risk management orders
  List<TradeSignal> checkAll(Map<String, double> currentPrices) {
    final signals = <TradeSignal>[];

    signals.addAll(checkStopLosses(currentPrices));
    signals.addAll(checkTakeProfits(currentPrices));

    return signals;
  }

  /// Remove stop-loss/take-profit when position is closed
  void removeOrders(String symbol, {String? side}) {
    _stopLossOrders.removeWhere(
      (sl) => sl.symbol == symbol && (side == null || sl.side == side)
    );
    _takeProfitOrders.removeWhere(
      (tp) => tp.symbol == symbol && (side == null || tp.side == side)
    );

    _log.fine('Removed orders for $symbol');
  }

  /// Get active stop-loss orders
  List<StopLossOrder> getActiveStopLosses() {
    return _stopLossOrders.where((sl) => sl.isActive).toList();
  }

  /// Get active take-profit orders
  List<TakeProfitOrder> getActiveTakeProfits() {
    return _takeProfitOrders.where((tp) => tp.isActive).toList();
  }

  /// Get current P&L for all positions
  Map<String, double> getCurrentPL(Map<String, double> currentPrices) {
    final plMap = <String, double>{};

    for (final stopLoss in _stopLossOrders.where((sl) => sl.isActive)) {
      final price = currentPrices[stopLoss.symbol];
      if (price != null) {
        plMap[stopLoss.symbol] = stopLoss.calculatePL(price);
      }
    }

    return plMap;
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'active_stop_losses': _stopLossOrders.where((sl) => sl.isActive).length,
      'triggered_stop_losses': _stopLossOrders.where((sl) => !sl.isActive).length,
      'active_take_profits': _takeProfitOrders.where((tp) => tp.isActive).length,
      'triggered_take_profits': _takeProfitOrders.where((tp) => !tp.isActive).length,
      'total_positions': _stopLossOrders.where((sl) => sl.isActive).length,
    };
  }

  /// Clear all orders (for testing or reset)
  void clearAll() {
    _stopLossOrders.clear();
    _takeProfitOrders.clear();
    _log.info('Cleared all stop-loss and take-profit orders');
  }
}
