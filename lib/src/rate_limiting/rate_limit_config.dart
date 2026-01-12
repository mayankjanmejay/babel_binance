/// Configuration for Binance API rate limiting
class RateLimitConfig {
  /// Request weight limit per minute (Spot API default: 1200)
  final int requestWeightPerMinute;

  /// Order limit per second (Spot API default: 10)
  final int ordersPerSecond;

  /// Order limit per day (Spot API default: 100000)
  final int ordersPerDay;

  /// Raw requests limit per minute (Spot API default: 6100)
  final int rawRequestsPerMinute;

  /// Safety margin (don't use 100% of limit, default: 0.8 = 80%)
  final double safetyMargin;

  /// Whether to throw exception or wait when limit reached
  final bool throwOnLimit;

  const RateLimitConfig({
    this.requestWeightPerMinute = 1200,
    this.ordersPerSecond = 10,
    this.ordersPerDay = 100000,
    this.rawRequestsPerMinute = 6100,
    this.safetyMargin = 0.8,
    this.throwOnLimit = false,
  });

  /// Create from JSON map
  factory RateLimitConfig.fromJson(Map<String, dynamic> json) {
    return RateLimitConfig(
      requestWeightPerMinute: json['requestWeightPerMinute'] as int? ?? 1200,
      ordersPerSecond: json['ordersPerSecond'] as int? ?? 10,
      ordersPerDay: json['ordersPerDay'] as int? ?? 100000,
      rawRequestsPerMinute: json['rawRequestsPerMinute'] as int? ?? 6100,
      safetyMargin: (json['safetyMargin'] as num?)?.toDouble() ?? 0.8,
      throwOnLimit: json['throwOnLimit'] as bool? ?? false,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        'requestWeightPerMinute': requestWeightPerMinute,
        'ordersPerSecond': ordersPerSecond,
        'ordersPerDay': ordersPerDay,
        'rawRequestsPerMinute': rawRequestsPerMinute,
        'safetyMargin': safetyMargin,
        'throwOnLimit': throwOnLimit,
      };

  /// Config for Binance Spot API
  static const spot = RateLimitConfig();

  /// Config for Binance Futures USD-M
  static const futuresUsd = RateLimitConfig(
    requestWeightPerMinute: 2400,
    ordersPerSecond: 20,
    ordersPerDay: 200000,
  );

  /// Config for conservative/safe mode
  static const conservative = RateLimitConfig(
    safetyMargin: 0.5,
  );

  int get effectiveWeightPerMinute =>
      (requestWeightPerMinute * safetyMargin).floor();

  int get effectiveOrdersPerSecond =>
      (ordersPerSecond * safetyMargin).floor();

  int get effectiveRawRequestsPerMinute =>
      (rawRequestsPerMinute * safetyMargin).floor();

  @override
  String toString() =>
      'RateLimitConfig(weight: $requestWeightPerMinute/min, orders: $ordersPerSecond/s)';
}
