import '../rate_limiting/rate_limit_config.dart';

/// Configuration for Binance API client
class BinanceConfig {
  /// Timeout for HTTP requests
  final Duration requestTimeout;

  /// Timeout for establishing connection
  final Duration connectTimeout;

  /// Whether to enable automatic failover
  final bool enableFailover;

  /// Custom User-Agent header
  final String? userAgent;

  /// Additional custom headers
  final Map<String, String> customHeaders;

  /// Proxy URL (if using proxy)
  final String? proxyUrl;

  /// Receive window for signed requests (milliseconds)
  final int recvWindow;

  /// Whether to sync with server time
  final bool syncServerTime;

  /// Rate limit configuration
  final RateLimitConfig? rateLimitConfig;

  const BinanceConfig({
    this.requestTimeout = const Duration(seconds: 30),
    this.connectTimeout = const Duration(seconds: 10),
    this.enableFailover = true,
    this.userAgent,
    this.customHeaders = const {},
    this.proxyUrl,
    this.recvWindow = 5000,
    this.syncServerTime = true,
    this.rateLimitConfig,
  });

  /// Default configuration
  static const defaultConfig = BinanceConfig();

  /// Configuration for slow/unstable networks
  static const slowNetwork = BinanceConfig(
    requestTimeout: Duration(seconds: 60),
    connectTimeout: Duration(seconds: 20),
    recvWindow: 10000,
  );

  /// Configuration for high-frequency trading
  static const highFrequency = BinanceConfig(
    requestTimeout: Duration(seconds: 10),
    connectTimeout: Duration(seconds: 5),
    recvWindow: 3000,
  );

  /// Copy with modifications
  BinanceConfig copyWith({
    Duration? requestTimeout,
    Duration? connectTimeout,
    bool? enableFailover,
    String? userAgent,
    Map<String, String>? customHeaders,
    String? proxyUrl,
    int? recvWindow,
    bool? syncServerTime,
    RateLimitConfig? rateLimitConfig,
  }) {
    return BinanceConfig(
      requestTimeout: requestTimeout ?? this.requestTimeout,
      connectTimeout: connectTimeout ?? this.connectTimeout,
      enableFailover: enableFailover ?? this.enableFailover,
      userAgent: userAgent ?? this.userAgent,
      customHeaders: customHeaders ?? this.customHeaders,
      proxyUrl: proxyUrl ?? this.proxyUrl,
      recvWindow: recvWindow ?? this.recvWindow,
      syncServerTime: syncServerTime ?? this.syncServerTime,
      rateLimitConfig: rateLimitConfig ?? this.rateLimitConfig,
    );
  }
}
