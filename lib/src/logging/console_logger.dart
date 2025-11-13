import 'dart:convert';
import 'logger.dart';
import 'log_level.dart';

/// Console logger with colored output
class ConsoleLogger implements BinanceLogger {
  @override
  final LogLevel minLevel;

  final bool useColors;
  final bool includeTimestamp;
  final bool prettyPrintJson;
  final int maxBodyLength;

  // ANSI color codes
  static const _reset = '\x1B[0m';
  static const _red = '\x1B[31m';
  static const _yellow = '\x1B[33m';
  static const _blue = '\x1B[34m';
  static const _gray = '\x1B[90m';
  static const _magenta = '\x1B[35m';

  const ConsoleLogger({
    this.minLevel = LogLevel.info,
    this.useColors = true,
    this.includeTimestamp = true,
    this.prettyPrintJson = false,
    this.maxBodyLength = 1000,
  });

  @override
  void debug(String message, {Map<String, dynamic>? context}) {
    _log(LogLevel.debug, message, context: context);
  }

  @override
  void info(String message, {Map<String, dynamic>? context}) {
    _log(LogLevel.info, message, context: context);
  }

  @override
  void warn(String message, {Map<String, dynamic>? context, Object? error}) {
    _log(LogLevel.warn, message, context: context, error: error);
  }

  @override
  void error(String message, {Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.error, message, context: context, error: error, stackTrace: stackTrace);
  }

  @override
  void fatal(String message, {Map<String, dynamic>? context, Object? error, StackTrace? stackTrace}) {
    _log(LogLevel.fatal, message, context: context, error: error, stackTrace: stackTrace);
  }

  @override
  void logRequest({
    required String method,
    required String url,
    Map<String, dynamic>? params,
    Map<String, String>? headers,
    int? weight,
  }) {
    if (minLevel > LogLevel.debug) return;

    final buffer = StringBuffer();
    buffer.writeln('→ $method $url');

    if (weight != null) {
      buffer.writeln('  Weight: $weight');
    }

    if (params != null && params.isNotEmpty) {
      // Remove sensitive data from logs
      final safeParams = Map<String, dynamic>.from(params);
      safeParams.remove('signature');
      safeParams.remove('apiKey');

      buffer.writeln('  Params: ${_formatJson(safeParams)}');
    }

    _print(LogLevel.debug, buffer.toString().trimRight());
  }

  @override
  void logResponse({
    required int statusCode,
    required String url,
    Map<String, String>? headers,
    String? body,
    Duration? duration,
  }) {
    if (minLevel > LogLevel.debug) return;

    final isSuccess = statusCode >= 200 && statusCode < 300;
    final level = isSuccess ? LogLevel.debug : LogLevel.error;

    final buffer = StringBuffer();
    buffer.write('← $statusCode');

    if (duration != null) {
      buffer.write(' (${duration.inMilliseconds}ms)');
    }

    buffer.writeln();

    // Log rate limit headers
    if (headers != null) {
      final usedWeight = headers['x-mbx-used-weight-1m'];
      final orderCount = headers['x-mbx-order-count-10s'];

      if (usedWeight != null) {
        buffer.writeln('  Weight Used: $usedWeight/1200');
      }
      if (orderCount != null) {
        buffer.writeln('  Orders (10s): $orderCount');
      }
    }

    // Log response body (truncated) for errors
    if (body != null && !isSuccess) {
      final truncated = body.length > maxBodyLength
          ? '${body.substring(0, maxBodyLength)}...'
          : body;
      buffer.writeln('  Body: $truncated');
    }

    _print(level, buffer.toString().trimRight());
  }

  @override
  void logWebSocket({
    required String event,
    required String url,
    String? message,
  }) {
    if (minLevel > LogLevel.debug) return;

    final buffer = StringBuffer();
    buffer.write('🔌 WebSocket ');

    switch (event) {
      case 'connecting':
        buffer.write('connecting to $url');
        break;
      case 'connected':
        buffer.write('connected to $url');
        break;
      case 'disconnected':
        buffer.write('disconnected from $url');
        break;
      case 'reconnecting':
        buffer.write('reconnecting to $url');
        break;
      case 'message':
        buffer.write('message: ${message ?? ""}');
        break;
      case 'error':
        buffer.write('error: ${message ?? ""}');
        break;
      default:
        buffer.write('$event: ${message ?? ""}');
    }

    _print(LogLevel.debug, buffer.toString());
  }

  @override
  void logRateLimit({
    required String type,
    required double usagePercent,
    int? remaining,
  }) {
    if (minLevel > LogLevel.info) return;

    final level = usagePercent > 90 ? LogLevel.warn : LogLevel.info;

    final buffer = StringBuffer();
    buffer.write('📊 Rate Limit [$type]: ${usagePercent.toStringAsFixed(1)}%');

    if (remaining != null) {
      buffer.write(' ($remaining remaining)');
    }

    _print(level, buffer.toString());
  }

  void _log(
    LogLevel level,
    String message, {
    Map<String, dynamic>? context,
    Object? error,
    StackTrace? stackTrace,
  }) {
    if (level < minLevel) return;

    final buffer = StringBuffer(message);

    if (context != null && context.isNotEmpty) {
      buffer.write(' ${_formatJson(context)}');
    }

    if (error != null) {
      buffer.write('\n  Error: $error');
    }

    if (stackTrace != null) {
      buffer.write('\n  Stack trace:\n$stackTrace');
    }

    _print(level, buffer.toString());
  }

  void _print(LogLevel level, String message) {
    final timestamp = includeTimestamp
        ? '${DateTime.now().toIso8601String()} '
        : '';

    final levelStr = _formatLevel(level);

    // Split message into lines for proper indentation
    final lines = message.split('\n');
    for (int i = 0; i < lines.length; i++) {
      if (i == 0) {
        print('$timestamp$levelStr ${lines[i]}');
      } else {
        print('$timestamp         ${lines[i]}');
      }
    }
  }

  String _formatLevel(LogLevel level) {
    if (!useColors) {
      return '[${level.name.toUpperCase().padRight(5)}]';
    }

    final color = switch (level) {
      LogLevel.debug => _gray,
      LogLevel.info => _blue,
      LogLevel.warn => _yellow,
      LogLevel.error => _red,
      LogLevel.fatal => _magenta,
      LogLevel.none => _reset,
    };

    return '$color[${level.name.toUpperCase().padRight(5)}]$_reset';
  }

  String _formatJson(Map<String, dynamic> data) {
    if (prettyPrintJson) {
      const encoder = JsonEncoder.withIndent('  ');
      return encoder.convert(data);
    } else {
      return json.encode(data);
    }
  }

  @override
  Future<void> flush() async {
    // Console output is immediate
  }

  @override
  Future<void> close() async {
    // Nothing to close for console
  }
}
