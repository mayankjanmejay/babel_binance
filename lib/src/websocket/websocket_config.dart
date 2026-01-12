/// Configuration for WebSocket connections
class WebSocketConfig {
  /// Enable automatic reconnection
  final bool autoReconnect;

  /// Maximum reconnection attempts (null = infinite)
  final int? maxReconnectAttempts;

  /// Initial reconnection delay
  final Duration initialReconnectDelay;

  /// Maximum reconnection delay (for exponential backoff)
  final Duration maxReconnectDelay;

  /// Ping interval for keepalive
  final Duration pingInterval;

  /// Pong timeout (how long to wait for pong response)
  final Duration pongTimeout;

  /// Connection timeout
  final Duration connectionTimeout;

  /// Whether to log debug information
  final bool debugMode;

  const WebSocketConfig({
    this.autoReconnect = true,
    this.maxReconnectAttempts,
    this.initialReconnectDelay = const Duration(seconds: 1),
    this.maxReconnectDelay = const Duration(seconds: 30),
    this.pingInterval = const Duration(minutes: 3),
    this.pongTimeout = const Duration(seconds: 10),
    this.connectionTimeout = const Duration(seconds: 10),
    this.debugMode = false,
  });

  /// Create from JSON map
  factory WebSocketConfig.fromJson(Map<String, dynamic> json) {
    return WebSocketConfig(
      autoReconnect: json['autoReconnect'] as bool? ?? true,
      maxReconnectAttempts: json['maxReconnectAttempts'] as int?,
      initialReconnectDelay: Duration(
          milliseconds: json['initialReconnectDelayMs'] as int? ?? 1000),
      maxReconnectDelay:
          Duration(milliseconds: json['maxReconnectDelayMs'] as int? ?? 30000),
      pingInterval:
          Duration(milliseconds: json['pingIntervalMs'] as int? ?? 180000),
      pongTimeout:
          Duration(milliseconds: json['pongTimeoutMs'] as int? ?? 10000),
      connectionTimeout:
          Duration(milliseconds: json['connectionTimeoutMs'] as int? ?? 10000),
      debugMode: json['debugMode'] as bool? ?? false,
    );
  }

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        'autoReconnect': autoReconnect,
        if (maxReconnectAttempts != null)
          'maxReconnectAttempts': maxReconnectAttempts,
        'initialReconnectDelayMs': initialReconnectDelay.inMilliseconds,
        'maxReconnectDelayMs': maxReconnectDelay.inMilliseconds,
        'pingIntervalMs': pingInterval.inMilliseconds,
        'pongTimeoutMs': pongTimeout.inMilliseconds,
        'connectionTimeoutMs': connectionTimeout.inMilliseconds,
        'debugMode': debugMode,
      };

  static const defaultConfig = WebSocketConfig();

  static const aggressiveReconnect = WebSocketConfig(
    autoReconnect: true,
    initialReconnectDelay: Duration(milliseconds: 500),
    maxReconnectDelay: Duration(seconds: 10),
    pingInterval: Duration(minutes: 1),
  );

  @override
  String toString() =>
      'WebSocketConfig(autoReconnect: $autoReconnect, ping: ${pingInterval.inSeconds}s)';
}
