import 'binance_exception.dart';

/// Exception thrown when API returns an error
class BinanceApiException extends BinanceException {
  final int statusCode;
  final int? errorCode;
  final String? errorMessage;
  final Map<String, dynamic>? responseBody;

  BinanceApiException({
    required this.statusCode,
    this.errorCode,
    this.errorMessage,
    this.responseBody,
    String? message,
  }) : super(message: message ?? errorMessage ?? 'API Error');

  /// Check if error is due to rate limiting
  bool get isRateLimitError => errorCode == -1003 || statusCode == 429;

  /// Check if error is authentication related
  bool get isAuthError => statusCode == 401 || errorCode == -2015;

  /// Check if error is IP ban
  bool get isIpBan => statusCode == 418 || errorCode == -1002;

  /// Check if request should be retried
  bool get isRetryable =>
      statusCode >= 500 || // Server errors
      statusCode == 408 || // Request timeout
      statusCode == 429;   // Rate limit (after backoff)

  @override
  String toString() => 'BinanceApiException($statusCode): $message'
      '${errorCode != null ? ' [Code: $errorCode]' : ''}';
}

/// Specific exception for rate limiting
class BinanceRateLimitException extends BinanceApiException {
  final int? retryAfterSeconds;
  final String? rateLimitType; // REQUEST_WEIGHT, ORDERS, RAW_REQUESTS

  BinanceRateLimitException({
    required super.statusCode,
    super.errorCode,
    super.errorMessage,
    this.retryAfterSeconds,
    this.rateLimitType,
  }) : super(message: 'Rate limit exceeded');

  @override
  String toString() => 'BinanceRateLimitException: $message'
      '${retryAfterSeconds != null ? ' (Retry after ${retryAfterSeconds}s)' : ''}';
}

/// Exception for authentication/authorization errors
class BinanceAuthException extends BinanceApiException {
  BinanceAuthException({
    required super.statusCode,
    super.errorCode,
    super.errorMessage,
  }) : super(message: 'Authentication failed');
}

/// Exception for IP bans
class BinanceIpBanException extends BinanceApiException {
  final DateTime? banUntil;

  BinanceIpBanException({
    required super.statusCode,
    super.errorCode,
    super.errorMessage,
    this.banUntil,
  }) : super(message: 'IP has been banned');
}

/// Exception for invalid parameters
class BinanceParameterException extends BinanceApiException {
  final String? parameterName;

  BinanceParameterException({
    required super.statusCode,
    super.errorCode,
    super.errorMessage,
    this.parameterName,
  }) : super(message: 'Invalid parameter');
}
