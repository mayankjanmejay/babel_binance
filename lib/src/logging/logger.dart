import 'log_level.dart';

/// Abstract logger interface
abstract class BinanceLogger {
  /// Minimum log level to output
  LogLevel get minLevel;

  /// Log debug message
  void debug(String message, {Map<String, dynamic>? context});

  /// Log info message
  void info(String message, {Map<String, dynamic>? context});

  /// Log warning message
  void warn(String message, {Map<String, dynamic>? context, Object? error});

  /// Log error message
  void error(String message, {Map<String, dynamic>? context, Object? error, StackTrace? stackTrace});

  /// Log fatal error message
  void fatal(String message, {Map<String, dynamic>? context, Object? error, StackTrace? stackTrace});

  /// Log HTTP request
  void logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    int? weight,
  });

  /// Log HTTP response
  void logResponse({
    required int statusCode,
    required String url,
    Map<String, String>? headers,
    String? body,
    Duration? duration,
  });

  /// Log WebSocket event
  void logWebSocket({
    required String event,
    required String url,
    String? message,
  });

  /// Log rate limit status
  void logRateLimit({
    required String type,
    required double usagePercent,
    int? remaining,
  });

  /// Flush any buffered logs
  Future<void> flush();

  /// Close logger and clean up
  Future<void> close();
}

/// No-op logger that does nothing
class NoOpLogger implements BinanceLogger {
  const NoOpLogger();

  @override
  LogLevel get minLevel => LogLevel.none;

  @override
  void debug(String message, {Map<String, dynamic>? context}) {}

  @override
  void info(String message, {Map<String, dynamic>? context}) {}

  @override
  void warn(String message, {Map<String, dynamic>? context, Object? error}) {}

  @override
  void error(String message, {Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {}

  @override
  void fatal(String message, {Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {}

  @override
  void logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    int? weight,
  }) {}

  @override
  void logResponse({
    required int statusCode,
    required String url,
    Map<String, String>? headers,
    String? body,
    Duration? duration,
  }) {}

  @override
  void logWebSocket({
    required String event,
    required String url,
    String? message,
  }) {}

  @override
  void logRateLimit({
    required String type,
    required double usagePercent,
    int? remaining,
  }) {}

  @override
  Future<void> flush() async {}

  @override
  Future<void> close() async {}
}
