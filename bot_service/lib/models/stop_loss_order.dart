import 'trade_signal.dart';

/// Stop-loss order that automatically exits a position at a loss threshold
class StopLossOrder {
  final String symbol;
  final String side; // 'BUY' or 'SELL'
  final double entryPrice;
  final double stopPrice;
  final double quantity;
  final double? trailingPercent; // Optional trailing stop
  final DateTime createdAt;
  bool isActive;

  StopLossOrder({
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.stopPrice,
    required this.quantity,
    this.trailingPercent,
    required this.createdAt,
    this.isActive = true,
  });

  /// Check if stop-loss should be triggered
  bool shouldTrigger(double currentPrice) {
    if (!isActive) return false;

    if (side == 'BUY') {
      // For long positions, trigger if price drops below stop
      return currentPrice <= stopPrice;
    } else {
      // For short positions, trigger if price rises above stop
      return currentPrice >= stopPrice;
    }
  }

  /// Update trailing stop price if applicable
  double? updateTrailingStop(double currentPrice) {
    if (trailingPercent == null) return null;

    if (side == 'BUY') {
      // For long positions, trail stop up as price increases
      final newStop = currentPrice * (1 - trailingPercent!);
      if (newStop > stopPrice) {
        return newStop;
      }
    } else {
      // For short positions, trail stop down as price decreases
      final newStop = currentPrice * (1 + trailingPercent!);
      if (newStop < stopPrice) {
        return newStop;
      }
    }

    return null;
  }

  /// Generate exit signal when stop-loss is hit
  TradeSignal generateExitSignal() {
    return TradeSignal(
      side: side == 'BUY' ? 'SELL' : 'BUY', // Close position
      type: 'MARKET',
      quantity: quantity,
      reason: 'Stop-loss triggered at \$${stopPrice.toStringAsFixed(2)}',
      algorithmName: 'Risk Management',
      confidence: 1.0, // High confidence - risk management
    );
  }

  /// Calculate current profit/loss
  double calculatePL(double currentPrice) {
    if (side == 'BUY') {
      return (currentPrice - entryPrice) * quantity;
    } else {
      return (entryPrice - currentPrice) * quantity;
    }
  }

  /// Calculate profit/loss percentage
  double calculatePLPercent(double currentPrice) {
    if (side == 'BUY') {
      return ((currentPrice - entryPrice) / entryPrice) * 100;
    } else {
      return ((entryPrice - currentPrice) / entryPrice) * 100;
    }
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'side': side,
      'entry_price': entryPrice,
      'stop_price': stopPrice,
      'quantity': quantity,
      'trailing_percent': trailingPercent,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  factory StopLossOrder.fromJson(Map<String, dynamic> json) {
    return StopLossOrder(
      symbol: json['symbol'],
      side: json['side'],
      entryPrice: json['entry_price'].toDouble(),
      stopPrice: json['stop_price'].toDouble(),
      quantity: json['quantity'].toDouble(),
      trailingPercent: json['trailing_percent']?.toDouble(),
      createdAt: DateTime.parse(json['created_at']),
      isActive: json['is_active'] ?? true,
    );
  }

  @override
  String toString() {
    return 'StopLoss($symbol $side @ \$${stopPrice.toStringAsFixed(2)})';
  }
}

/// Take-profit order that automatically exits at a profit target
class TakeProfitOrder {
  final String symbol;
  final String side;
  final double entryPrice;
  final double targetPrice;
  final double quantity;
  final DateTime createdAt;
  bool isActive;

  TakeProfitOrder({
    required this.symbol,
    required this.side,
    required this.entryPrice,
    required this.targetPrice,
    required this.quantity,
    required this.createdAt,
    this.isActive = true,
  });

  /// Check if take-profit should be triggered
  bool shouldTrigger(double currentPrice) {
    if (!isActive) return false;

    if (side == 'BUY') {
      // For long positions, trigger if price rises above target
      return currentPrice >= targetPrice;
    } else {
      // For short positions, trigger if price drops below target
      return currentPrice <= targetPrice;
    }
  }

  /// Generate exit signal when take-profit is hit
  TradeSignal generateExitSignal() {
    return TradeSignal(
      side: side == 'BUY' ? 'SELL' : 'BUY',
      type: 'MARKET',
      quantity: quantity,
      reason: 'Take-profit triggered at \$${targetPrice.toStringAsFixed(2)}',
      algorithmName: 'Risk Management',
      confidence: 1.0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'symbol': symbol,
      'side': side,
      'entry_price': entryPrice,
      'target_price': targetPrice,
      'quantity': quantity,
      'created_at': createdAt.toIso8601String(),
      'is_active': isActive,
    };
  }

  @override
  String toString() {
    return 'TakeProfit($symbol $side @ \$${targetPrice.toStringAsFixed(2)})';
  }
}
