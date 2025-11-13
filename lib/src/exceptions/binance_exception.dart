/// Base exception for all Binance API errors
abstract class BinanceException implements Exception {
  final String message;
  final StackTrace? stackTrace;
  final DateTime timestamp;

  BinanceException({
    required this.message,
    this.stackTrace,
  }) : timestamp = DateTime.now();

  @override
  String toString() => 'BinanceException: $message';
}
