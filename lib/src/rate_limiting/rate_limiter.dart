import 'dart:async';
import 'package:http/http.dart' as http;
import 'token_bucket.dart';
import 'weight_tracker.dart';
import 'rate_limit_config.dart';
import '../exceptions/api_exception.dart';

/// Main rate limiter for Binance API
class RateLimiter {
  final RateLimitConfig config;

  // Token buckets for different limit types
  late final TokenBucket _weightBucket;
  late final TokenBucket _ordersBucket;
  late final TokenBucket _rawRequestsBucket;

  // Weight tracker from server responses
  final WeightTracker weightTracker;

  // Order count tracking
  int _orderCountToday = 0;

  RateLimiter({
    RateLimitConfig? config,
  }) : config = config ?? RateLimitConfig.spot,
       weightTracker = WeightTracker() {

    // Initialize token buckets
    _weightBucket = TokenBucket(
      capacity: this.config.effectiveWeightPerMinute,
      refillDuration: const Duration(minutes: 1),
    );

    _ordersBucket = TokenBucket(
      capacity: this.config.effectiveOrdersPerSecond,
      refillDuration: const Duration(seconds: 1),
    );

    _rawRequestsBucket = TokenBucket(
      capacity: this.config.effectiveRawRequestsPerMinute,
      refillDuration: const Duration(minutes: 1),
    );
  }

  /// Check and wait for rate limit before making request
  Future<void> checkLimit({
    required int weight,
    bool isOrder = false,
  }) async {
    // Check daily order limit
    if (isOrder && _orderCountToday >= config.ordersPerDay) {
      if (config.throwOnLimit) {
        throw BinanceRateLimitException(
          statusCode: 429,
          errorMessage: 'Daily order limit reached',
          rateLimitType: 'ORDERS',
        );
      }

      // Wait until next day
      final now = DateTime.now();
      final tomorrow = DateTime(now.year, now.month, now.day + 1);
      final waitTime = tomorrow.difference(now);
      await Future.delayed(waitTime);
      _resetDailyOrderCount();
    }

    // Use token buckets to rate limit
    if (config.throwOnLimit) {
      // Throw exception if limit would be exceeded
      if (!_weightBucket.tryConsume(weight)) {
        throw BinanceRateLimitException(
          statusCode: 429,
          errorMessage: 'Request weight limit exceeded',
          rateLimitType: 'REQUEST_WEIGHT',
        );
      }

      if (!_rawRequestsBucket.tryConsume(1)) {
        throw BinanceRateLimitException(
          statusCode: 429,
          errorMessage: 'Raw request limit exceeded',
          rateLimitType: 'RAW_REQUESTS',
        );
      }

      if (isOrder && !_ordersBucket.tryConsume(1)) {
        throw BinanceRateLimitException(
          statusCode: 429,
          errorMessage: 'Order rate limit exceeded',
          rateLimitType: 'ORDERS',
        );
      }
    } else {
      // Wait for tokens to be available
      await _weightBucket.consume(weight);
      await _rawRequestsBucket.consume(1);

      if (isOrder) {
        await _ordersBucket.consume(1);
        _orderCountToday++;
      }
    }
  }

  /// Process response headers to update tracking
  void processResponse(http.Response response) {
    weightTracker.updateFromHeaders(response.headers);

    // If server reports we're close to limit, slow down
    if (weightTracker.isApproachingLimit(threshold: 0.9)) {
      // Reduce our local bucket to match server state
      final serverWeight = weightTracker.currentWeight;
      final ourWeight = config.effectiveWeightPerMinute -
          _weightBucket.availableTokens.toInt();

      if (serverWeight > ourWeight) {
        // Server thinks we used more, sync up
        final difference = serverWeight - ourWeight;
        _weightBucket.tryConsume(difference);
      }
    }
  }

  /// Reset daily order count
  void _resetDailyOrderCount() {
    _orderCountToday = 0;
  }

  /// Get current rate limit status
  RateLimitStatus getStatus() {
    return RateLimitStatus(
      weightUsagePercent: _weightBucket.usagePercent,
      orderUsagePercent: _ordersBucket.usagePercent,
      rawRequestUsagePercent: _rawRequestsBucket.usagePercent,
      dailyOrderCount: _orderCountToday,
      dailyOrderLimit: config.ordersPerDay,
      serverReportedWeight: weightTracker.currentWeight,
      serverReportedWeightPercent: weightTracker.usagePercent,
    );
  }

  /// Reset all rate limiters (useful for testing)
  void reset() {
    _weightBucket.reset();
    _ordersBucket.reset();
    _rawRequestsBucket.reset();
    _resetDailyOrderCount();
  }
}

/// Snapshot of current rate limit status
class RateLimitStatus {
  final double weightUsagePercent;
  final double orderUsagePercent;
  final double rawRequestUsagePercent;
  final int dailyOrderCount;
  final int dailyOrderLimit;
  final int serverReportedWeight;
  final double serverReportedWeightPercent;

  const RateLimitStatus({
    required this.weightUsagePercent,
    required this.orderUsagePercent,
    required this.rawRequestUsagePercent,
    required this.dailyOrderCount,
    required this.dailyOrderLimit,
    required this.serverReportedWeight,
    required this.serverReportedWeightPercent,
  });

  bool get isHealthy =>
      weightUsagePercent < 70 &&
      orderUsagePercent < 70 &&
      rawRequestUsagePercent < 70;

  @override
  String toString() => '''
RateLimitStatus:
  Weight: ${weightUsagePercent.toStringAsFixed(1)}% (Server: ${serverReportedWeightPercent.toStringAsFixed(1)}%)
  Orders: ${orderUsagePercent.toStringAsFixed(1)}% (Daily: $dailyOrderCount/$dailyOrderLimit)
  Raw Requests: ${rawRequestUsagePercent.toStringAsFixed(1)}%
  Healthy: $isHealthy
''';
}
