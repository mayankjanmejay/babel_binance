class RateLimitConfig {
  // Spot API limits (from Binance documentation)
  final int requestWeightPerMinute;
  final int ordersPerSecond;
  final int ordersPerDay;
  final int rawRequestsPerMinute;

  // Safety margin (don't use 100% of limit)
  final double safetyMargin;

  // Whether to throw exception or wait when limit reached
  final bool throwOnLimit;

  const RateLimitConfig({
    this.requestWeightPerMinute = 1200,
    this.ordersPerSecond = 10,
    this.ordersPerDay = 100000,
    this.rawRequestsPerMinute = 6100,
    this.safetyMargin = 0.8, // Use 80% of limit
    this.throwOnLimit = false, // Wait by default
  });

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
    safetyMargin: 0.5, // Only use 50% of limit
  );

  int get effectiveWeightPerMinute =>
      (requestWeightPerMinute * safetyMargin).floor();

  int get effectiveOrdersPerSecond =>
      (ordersPerSecond * safetyMargin).floor();

  int get effectiveRawRequestsPerMinute =>
      (rawRequestsPerMinute * safetyMargin).floor();
}
