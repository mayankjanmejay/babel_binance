/// Price Alert Model
/// Represents a price alert for monitoring cryptocurrency prices

class PriceAlert {
  final String id;
  final String userId;
  final String symbol;
  final AlertCondition condition;
  final double targetPrice;
  final bool active;
  final bool triggered;
  final DateTime? triggeredAt;
  final DateTime createdAt;
  final String? message;

  PriceAlert({
    required this.id,
    required this.userId,
    required this.symbol,
    required this.condition,
    required this.targetPrice,
    this.active = true,
    this.triggered = false,
    this.triggeredAt,
    required this.createdAt,
    this.message,
  });

  /// Check if this alert should trigger based on current price
  bool shouldTrigger(double currentPrice) {
    if (!active || triggered) return false;

    switch (condition) {
      case AlertCondition.above:
        return currentPrice >= targetPrice;
      case AlertCondition.below:
        return currentPrice <= targetPrice;
      case AlertCondition.crosses:
        // For crosses, we need historical price data
        // This is a simplified version - just treat as "equals"
        return (currentPrice - targetPrice).abs() < (targetPrice * 0.001);
    }
  }

  /// Convert to JSON for Appwrite
  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'symbol': symbol,
      'condition': condition.toString().split('.').last,
      'targetPrice': targetPrice,
      'active': active,
      'triggered': triggered,
      'triggeredAt': triggeredAt?.toIso8601String(),
      'createdAt': createdAt.toIso8601String(),
      'message': message,
    };
  }

  /// Create from JSON (Appwrite document)
  factory PriceAlert.fromJson(String id, Map<String, dynamic> json) {
    return PriceAlert(
      id: id,
      userId: json['userId'] ?? json['user_id'] ?? '',
      symbol: json['symbol'] ?? '',
      condition: AlertCondition.values.firstWhere(
        (c) => c.toString().split('.').last == (json['condition'] ?? 'above'),
        orElse: () => AlertCondition.above,
      ),
      targetPrice: (json['targetPrice'] ?? json['target_price'] ?? 0.0).toDouble(),
      active: json['active'] ?? true,
      triggered: json['triggered'] ?? false,
      triggeredAt: json['triggeredAt'] != null || json['triggered_at'] != null
          ? DateTime.parse(json['triggeredAt'] ?? json['triggered_at'])
          : null,
      createdAt: json['createdAt'] != null || json['created_at'] != null
          ? DateTime.parse(json['createdAt'] ?? json['created_at'])
          : DateTime.now(),
      message: json['message'],
    );
  }

  /// Create a copy with updated fields
  PriceAlert copyWith({
    String? id,
    String? userId,
    String? symbol,
    AlertCondition? condition,
    double? targetPrice,
    bool? active,
    bool? triggered,
    DateTime? triggeredAt,
    DateTime? createdAt,
    String? message,
  }) {
    return PriceAlert(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      symbol: symbol ?? this.symbol,
      condition: condition ?? this.condition,
      targetPrice: targetPrice ?? this.targetPrice,
      active: active ?? this.active,
      triggered: triggered ?? this.triggered,
      triggeredAt: triggeredAt ?? this.triggeredAt,
      createdAt: createdAt ?? this.createdAt,
      message: message ?? this.message,
    );
  }

  @override
  String toString() {
    return 'PriceAlert($symbol ${condition.toString().split('.').last} \$${targetPrice.toStringAsFixed(2)})';
  }
}

/// Alert condition types
enum AlertCondition {
  above,   // Price goes above target
  below,   // Price goes below target
  crosses, // Price crosses target (either direction)
}
