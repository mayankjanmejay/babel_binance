import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'exceptions.dart';

/// Configuration for Binance API requests.
class BinanceConfig {
  /// Request timeout duration (default: 30 seconds)
  final Duration timeout;

  /// Maximum number of retry attempts for failed requests (default: 3)
  final int maxRetries;

  /// Delay between retry attempts (default: 1 second)
  final Duration retryDelay;

  /// Enable automatic rate limiting (default: true)
  final bool enableRateLimiting;

  /// Maximum requests per second (default: 10)
  final int maxRequestsPerSecond;

  const BinanceConfig({
    this.timeout = const Duration(seconds: 30),
    this.maxRetries = 3,
    this.retryDelay = const Duration(seconds: 1),
    this.enableRateLimiting = true,
    this.maxRequestsPerSecond = 10,
  });
}

/// Base class for all Binance API endpoints with advanced features.
class BinanceBase {
  final String? apiKey;
  final String? apiSecret;
  final String baseUrl;
  final BinanceConfig config;

  // Rate limiting
  static final List<DateTime> _requestTimes = [];
  static final _rateLimitLock = Object();

  BinanceBase({
    this.apiKey,
    this.apiSecret,
    required this.baseUrl,
    BinanceConfig? config,
  }) : config = config ?? const BinanceConfig();

  /// Sends an HTTP request to the Binance API with retry logic and rate limiting.
  Future<Map<String, dynamic>> sendRequest(
    String method,
    String path, {
    Map<String, dynamic>? params,
  }) async {
    int attempt = 0;
    Exception? lastException;

    while (attempt < config.maxRetries) {
      try {
        // Apply rate limiting
        if (config.enableRateLimiting) {
          await _applyRateLimit();
        }

        // Execute request with timeout
        final response = await _executeRequest(method, path, params: params)
            .timeout(config.timeout, onTimeout: () {
          throw BinanceTimeoutException(
            'Request timed out after ${config.timeout.inSeconds}s',
            config.timeout,
          );
        });

        return _handleResponse(response);
      } on BinanceTimeoutException {
        rethrow; // Don't retry on timeout
      } on BinanceRateLimitException {
        rethrow; // Don't retry on rate limit
      } on BinanceAuthenticationException {
        rethrow; // Don't retry on auth errors
      } on BinanceNetworkException catch (e) {
        lastException = e;
        attempt++;
        if (attempt < config.maxRetries) {
          await Future.delayed(config.retryDelay * attempt);
        }
      } catch (e) {
        throw BinanceException('Unexpected error: $e');
      }
    }

    throw lastException ??
        BinanceException('Request failed after ${config.maxRetries} attempts');
  }

  /// Applies rate limiting to prevent exceeding API limits.
  Future<void> _applyRateLimit() async {
    synchronized(_rateLimitLock, () async {
      final now = DateTime.now();
      final oneSecondAgo = now.subtract(const Duration(seconds: 1));

      // Remove old request times
      _requestTimes.removeWhere((time) => time.isBefore(oneSecondAgo));

      // Wait if we've exceeded the rate limit
      if (_requestTimes.length >= config.maxRequestsPerSecond) {
        final oldestRequest = _requestTimes.first;
        final waitTime = oldestRequest
            .add(const Duration(seconds: 1))
            .difference(now);
        if (waitTime.inMilliseconds > 0) {
          await Future.delayed(waitTime);
        }
      }

      _requestTimes.add(now);
    });
  }

  /// Executes the actual HTTP request.
  Future<http.Response> _executeRequest(
    String method,
    String path, {
    Map<String, dynamic>? params,
  }) async {
    params ??= {};

    // Add signature for authenticated requests
    if (apiSecret != null) {
      params['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      final query = Uri(
        queryParameters:
            params.map((key, value) => MapEntry(key, value.toString())),
      ).query;
      final signature = Hmac(sha256, utf8.encode(apiSecret!))
          .convert(utf8.encode(query))
          .toString();
      params['signature'] = signature;
    }

    final uri = Uri.parse('$baseUrl$path').replace(
      queryParameters:
          params.map((key, value) => MapEntry(key, value.toString())),
    );

    final headers = <String, String>{
      'Content-Type': 'application/json',
      if (apiKey != null) 'X-MBX-APIKEY': apiKey!,
    };

    try {
      switch (method.toUpperCase()) {
        case 'GET':
          return await http.get(uri, headers: headers);
        case 'POST':
          return await http.post(uri, headers: headers);
        case 'DELETE':
          return await http.delete(uri, headers: headers);
        case 'PUT':
          return await http.put(uri, headers: headers);
        default:
          throw BinanceException('Unsupported HTTP method: $method');
      }
    } catch (e) {
      throw BinanceNetworkException('Network error: $e');
    }
  }

  /// Handles the HTTP response and throws appropriate exceptions.
  Map<String, dynamic> _handleResponse(http.Response response) {
    final statusCode = response.statusCode;

    if (statusCode >= 200 && statusCode < 300) {
      try {
        return json.decode(response.body);
      } catch (e) {
        throw BinanceException('Failed to parse response: $e',
            responseBody: response.body);
      }
    }

    // Parse error response
    dynamic errorBody;
    try {
      errorBody = json.decode(response.body);
    } catch (e) {
      errorBody = response.body;
    }

    final errorMessage = errorBody is Map
        ? errorBody['msg'] ?? errorBody['message'] ?? 'Unknown error'
        : response.body;

    // Throw specific exceptions based on status code
    switch (statusCode) {
      case 401:
      case 403:
        throw BinanceAuthenticationException(
          errorMessage,
          statusCode: statusCode,
          responseBody: errorBody,
        );
      case 429:
        final retryAfter = int.tryParse(
            response.headers['retry-after'] ?? response.headers['Retry-After'] ?? '');
        throw BinanceRateLimitException(
          'Rate limit exceeded: $errorMessage',
          statusCode: statusCode,
          retryAfter: retryAfter,
          responseBody: errorBody,
        );
      case 400:
        if (errorMessage.toLowerCase().contains('insufficient')) {
          throw BinanceInsufficientBalanceException(
            errorMessage,
            statusCode: statusCode,
            responseBody: errorBody,
          );
        }
        throw BinanceValidationException(
          errorMessage,
          statusCode: statusCode,
          responseBody: errorBody,
        );
      case 500:
      case 502:
      case 503:
      case 504:
        throw BinanceServerException(
          'Server error: $errorMessage',
          statusCode: statusCode,
          responseBody: errorBody,
        );
      default:
        throw BinanceException(
          errorMessage,
          statusCode: statusCode,
          responseBody: errorBody,
        );
    }
  }

  /// Simple synchronization helper.
  static Future<T> synchronized<T>(
      Object lock, Future<T> Function() action) async {
    // Simple implementation - in production, use a proper mutex library
    return await action();
  }
}
