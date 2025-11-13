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
    this.pingInterval = const Duration(minutes: 3), // Binance closes after 10 min idle
    this.pongTimeout = const Duration(seconds: 10),
    this.connectionTimeout = const Duration(seconds: 10),
    this.debugMode = false,
  });

  static const defaultConfig = WebSocketConfig();

  static const aggressiveReconnect = WebSocketConfig(
    autoReconnect: true,
    initialReconnectDelay: Duration(milliseconds: 500),
    maxReconnectDelay: Duration(seconds: 10),
    pingInterval: Duration(minutes: 1),
  );
}
