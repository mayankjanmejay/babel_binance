import 'dart:async';
import 'binance_exception.dart';

/// Exception for network-level errors
class BinanceNetworkException extends BinanceException {
  final Object? originalError;
  final String? url;

  BinanceNetworkException({
    required super.message,
    this.originalError,
    this.url,
    super.stackTrace,
  });

  bool get isTimeout =>
      originalError is TimeoutException ||
      message.toLowerCase().contains('timeout');

  bool get isConnectionError =>
      message.toLowerCase().contains('connection') ||
      message.toLowerCase().contains('socket');

  @override
  String toString() => 'BinanceNetworkException: $message'
      '${url != null ? ' (URL: $url)' : ''}';
}

/// Specific exception for timeout errors
class BinanceTimeoutException extends BinanceNetworkException {
  final Duration timeout;

  BinanceTimeoutException({
    required this.timeout,
    String? url,
  }) : super(
    message: 'Request timeout after ${timeout.inSeconds}s',
    url: url,
  );
}
