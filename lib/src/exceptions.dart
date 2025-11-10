/// Custom exceptions for Binance API errors.

/// Base exception class for all Binance API errors.
class BinanceException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic responseBody;

  BinanceException(this.message, {this.statusCode, this.responseBody});

  @override
  String toString() => 'BinanceException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

/// Thrown when the API request fails due to authentication issues.
class BinanceAuthenticationException extends BinanceException {
  BinanceAuthenticationException(String message, {int? statusCode, dynamic responseBody})
      : super(message, statusCode: statusCode, responseBody: responseBody);

  @override
  String toString() => 'BinanceAuthenticationException: $message';
}

/// Thrown when the API rate limit is exceeded.
class BinanceRateLimitException extends BinanceException {
  final int? retryAfter;

  BinanceRateLimitException(String message, {int? statusCode, this.retryAfter, dynamic responseBody})
      : super(message, statusCode: statusCode, responseBody: responseBody);

  @override
  String toString() => 'BinanceRateLimitException: $message${retryAfter != null ? ' (Retry after: ${retryAfter}s)' : ''}';
}

/// Thrown when the API request contains invalid parameters.
class BinanceValidationException extends BinanceException {
  BinanceValidationException(String message, {int? statusCode, dynamic responseBody})
      : super(message, statusCode: statusCode, responseBody: responseBody);

  @override
  String toString() => 'BinanceValidationException: $message';
}

/// Thrown when a network error occurs.
class BinanceNetworkException extends BinanceException {
  BinanceNetworkException(String message, {dynamic responseBody})
      : super(message, responseBody: responseBody);

  @override
  String toString() => 'BinanceNetworkException: $message';
}

/// Thrown when the API server returns an internal error.
class BinanceServerException extends BinanceException {
  BinanceServerException(String message, {int? statusCode, dynamic responseBody})
      : super(message, statusCode: statusCode, responseBody: responseBody);

  @override
  String toString() => 'BinanceServerException: $message';
}

/// Thrown when insufficient balance for the operation.
class BinanceInsufficientBalanceException extends BinanceException {
  BinanceInsufficientBalanceException(String message, {int? statusCode, dynamic responseBody})
      : super(message, statusCode: statusCode, responseBody: responseBody);

  @override
  String toString() => 'BinanceInsufficientBalanceException: $message';
}

/// Thrown when the requested operation times out.
class BinanceTimeoutException extends BinanceException {
  final Duration timeout;

  BinanceTimeoutException(String message, this.timeout, {dynamic responseBody})
      : super(message, responseBody: responseBody);

  @override
  String toString() => 'BinanceTimeoutException: $message (Timeout: ${timeout.inSeconds}s)';
}
