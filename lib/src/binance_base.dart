import 'dart:convert';
import 'dart:io';
import 'dart:async';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';
import 'config/binance_config.dart';
import 'http/binance_http_client.dart';
import 'rate_limiting/rate_limiter.dart';
import 'logging/logger.dart';
import 'exceptions/binance_exception.dart';
import 'exceptions/api_exception.dart';
import 'exceptions/network_exception.dart';
import 'exceptions/validation_exception.dart';

class BinanceBase {
  final String? apiKey;
  final String? apiSecret;
  final String baseUrl;
  final BinanceConfig config;
  final BinanceLogger logger;
  final List<String> _endpoints;
  int _currentEndpointIndex = 0;

  late final RateLimiter rateLimiter;
  late final BinanceHttpClient _httpClient;

  // Server time offset for signature synchronization
  int _serverTimeOffset = 0;
  DateTime? _lastServerTimeSync;

  BinanceBase({
    this.apiKey,
    this.apiSecret,
    required this.baseUrl,
    BinanceConfig? config,
    BinanceLogger? logger,
  }) : config = config ?? BinanceConfig.defaultConfig,
       logger = logger ?? const NoOpLogger(),
       _endpoints = _generateEndpoints(baseUrl) {

    rateLimiter = RateLimiter(
      config: this.config.rateLimitConfig,
    );

    _httpClient = BinanceHttpClient(config: this.config);

    // Sync server time if enabled
    if (this.config.syncServerTime && apiSecret != null) {
      _initServerTimeSync();
    }
  }

  /// Initialize server time synchronization
  Future<void> _initServerTimeSync() async {
    try {
      final serverTimeData = await _getServerTimeInternal();
      final serverTime = serverTimeData['serverTime'] as int;
      final localTime = DateTime.now().millisecondsSinceEpoch;

      _serverTimeOffset = serverTime - localTime;
      _lastServerTimeSync = DateTime.now();

      logger.info('Server time synced. Offset: ${_serverTimeOffset}ms');
    } catch (e) {
      logger.warn('Failed to sync server time', error: e);
      // Continue anyway, server time sync is optional
    }
  }

  /// Get server time (internal, doesn't use rate limiter)
  Future<Map<String, dynamic>> _getServerTimeInternal() async {
    final uri = Uri.parse('$_currentEndpoint/api/v3/time');
    final response = await _httpClient.get(uri);

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to get server time');
    }
  }

  /// Get synchronized timestamp for signatures
  int _getSyncedTimestamp() {
    return DateTime.now().millisecondsSinceEpoch + _serverTimeOffset;
  }

  /// Re-sync server time if needed (every 30 minutes)
  Future<void> _resyncServerTimeIfNeeded() async {
    if (!config.syncServerTime || apiSecret == null) return;

    if (_lastServerTimeSync == null ||
        DateTime.now().difference(_lastServerTimeSync!) >
            const Duration(minutes: 30)) {
      await _initServerTimeSync();
    }
  }

  /// Generates multiple endpoint URLs based on the base URL domain
  static List<String> _generateEndpoints(String baseUrl) {
    final uri = Uri.parse(baseUrl);
    final scheme = uri.scheme;
    final host = uri.host;
    final port = uri.hasPort ? ':${uri.port}' : '';
    final path = uri.path;

    // Check if it's a Binance domain and generate failover endpoints
    if (host.contains('binance.com')) {
      if (host == 'api.binance.com') {
        // Spot API endpoints with failover
        return [
          '$scheme://api.binance.com$port$path',
          '$scheme://api1.binance.com$port$path',
          '$scheme://api2.binance.com$port$path',
          '$scheme://api3.binance.com$port$path',
          '$scheme://api4.binance.com$port$path',
        ];
      } else if (host == 'fapi.binance.com') {
        // Futures USD-M API endpoints with failover
        return [
          '$scheme://fapi.binance.com$port$path',
          '$scheme://fapi1.binance.com$port$path',
          '$scheme://fapi2.binance.com$port$path',
          '$scheme://fapi3.binance.com$port$path',
        ];
      } else if (host == 'dapi.binance.com') {
        // Futures COIN-M API endpoints with failover
        return [
          '$scheme://dapi.binance.com$port$path',
          '$scheme://dapi1.binance.com$port$path',
          '$scheme://dapi2.binance.com$port$path',
        ];
      }
    }

    // For non-Binance domains or unrecognized patterns, return original URL
    return [baseUrl];
  }

  /// Gets the current endpoint URL
  String get _currentEndpoint => _endpoints[_currentEndpointIndex];

  /// Rotates to the next endpoint for failover
  void _rotateEndpoint() {
    _currentEndpointIndex = (_currentEndpointIndex + 1) % _endpoints.length;
  }

  /// Resets to the primary endpoint
  void _resetToPrimaryEndpoint() {
    _currentEndpointIndex = 0;
  }

  /// Gets all available endpoints for this instance
  List<String> get availableEndpoints => List.unmodifiable(_endpoints);

  /// Gets the currently active endpoint
  String get currentEndpoint => _currentEndpoint;

  /// Gets the primary (first) endpoint
  String get primaryEndpoint => _endpoints.first;

  Future<Map<String, dynamic>> sendRequest(
    String method,
    String path, {
    Map<String, dynamic>? params,
    int weight = 1,
    bool isOrder = false,
    Duration? timeout,
  }) async {
    final url = '$_currentEndpoint$path';
    final startTime = DateTime.now();

    // Log request
    logger.logRequest(
      method: method,
      url: url,
      params: params,
      weight: weight,
    );

    try {
      // Check rate limit
      await rateLimiter.checkLimit(weight: weight, isOrder: isOrder);

      // Re-sync server time if needed
      await _resyncServerTimeIfNeeded();

      params ??= {};

      // Add signature if authenticated
      if (apiSecret != null) {
        params['timestamp'] = _getSyncedTimestamp();
        params['recvWindow'] = config.recvWindow;

        final query = Uri(queryParameters: params.map((key, value) =>
            MapEntry(key, value.toString()))).query;
        final signature = Hmac(sha256, utf8.encode(apiSecret!))
            .convert(utf8.encode(query)).toString();
        params['signature'] = signature;
      }

      Exception? lastException;
      final maxAttempts = config.enableFailover ? _endpoints.length : 1;

      // Try endpoints with failover
      for (int attempt = 0; attempt < maxAttempts; attempt++) {
        try {
          final uri = Uri.parse('$_currentEndpoint$path').replace(
            queryParameters: params.map((key, value) =>
                MapEntry(key, value.toString())),
          );

          final headers = <String, String>{
            if (apiKey != null) 'X-MBX-APIKEY': apiKey!,
          };

          http.Response response;
          switch (method.toUpperCase()) {
            case 'GET':
              response = await _httpClient.get(
                uri,
                headers: headers,
                timeout: timeout,
              );
              break;
            case 'POST':
              response = await _httpClient.post(
                uri,
                headers: headers,
                timeout: timeout,
              );
              break;
            case 'DELETE':
              response = await _httpClient.delete(
                uri,
                headers: headers,
                timeout: timeout,
              );
              break;
            case 'PUT':
              response = await _httpClient.put(
                uri,
                headers: headers,
                timeout: timeout,
              );
              break;
            default:
              throw BinanceValidationException(
                fieldName: 'method',
                invalidValue: method,
                constraint: 'Must be GET, POST, DELETE, or PUT',
              );
          }

          final duration = DateTime.now().difference(startTime);

          if (response.statusCode >= 200 && response.statusCode < 300) {
            // Success!
            logger.logResponse(
              statusCode: response.statusCode,
              url: url,
              headers: response.headers,
              body: response.body,
              duration: duration,
            );

            rateLimiter.processResponse(response);

            // Log rate limit status if approaching limits
            final status = rateLimiter.getStatus();
            if (status.weightUsagePercent > 70) {
              logger.logRateLimit(
                type: 'REQUEST_WEIGHT',
                usagePercent: status.weightUsagePercent,
              );
            }

            if (attempt > 0) {
              _resetToPrimaryEndpoint();
            }

            return json.decode(response.body);
          } else {
            // Parse error response
            final errorBody = json.decode(response.body) as Map<String, dynamic>?;
            final errorCode = errorBody?['code'] as int?;
            final errorMsg = errorBody?['msg'] as String?;

            // Log error response
            logger.logResponse(
              statusCode: response.statusCode,
              url: url,
              headers: response.headers,
              body: response.body,
              duration: duration,
            );

            // Create appropriate exception based on error type
            final exception = _createExceptionFromResponse(
              response.statusCode,
              errorCode,
              errorMsg,
              errorBody,
            );

            // Don't retry on non-retryable errors
            if (!exception.isRetryable || !config.enableFailover) {
              throw exception;
            }

            // Try next endpoint
            if (attempt < maxAttempts - 1) {
              lastException = exception;
              _rotateEndpoint();
              continue;
            }

            throw exception;
          }
        } on BinanceException {
          rethrow;
        } catch (e, stack) {
          logger.error(
            'Request failed: $method $url',
            error: e,
            stackTrace: stack,
          );

          // Network or other error
          if (attempt < maxAttempts - 1 && config.enableFailover) {
            lastException = e is Exception ? e : Exception(e.toString());
            _rotateEndpoint();
            continue;
          }
          rethrow;
        }
      }

      throw lastException ?? BinanceNetworkException(
        message: 'All endpoints failed',
      );
    } catch (e, stack) {
      if (e is! BinanceException) {
        logger.error(
          'Request failed: $method $url',
          error: e,
          stackTrace: stack,
        );
      }
      rethrow;
    }
  }

  /// Create appropriate exception based on error response
  BinanceApiException _createExceptionFromResponse(
    int statusCode,
    int? errorCode,
    String? errorMsg,
    Map<String, dynamic>? responseBody,
  ) {
    // Rate limiting
    if (statusCode == 429 || errorCode == -1003 || errorCode == -1015) {
      final retryAfter = responseBody?['retryAfter'] as int?;
      return BinanceRateLimitException(
        statusCode: statusCode,
        errorCode: errorCode,
        errorMessage: errorMsg,
        retryAfterSeconds: retryAfter,
      );
    }

    // IP ban
    if (statusCode == 418 || errorCode == -1002) {
      return BinanceIpBanException(
        statusCode: statusCode,
        errorCode: errorCode,
        errorMessage: errorMsg,
      );
    }

    // Authentication
    if (statusCode == 401 || errorCode == -2015 || errorCode == -2014) {
      return BinanceAuthException(
        statusCode: statusCode,
        errorCode: errorCode,
        errorMessage: errorMsg,
      );
    }

    // Parameter validation
    if (statusCode == 400 && (errorCode == -1100 || errorCode == -1101 ||
        errorCode == -1102 || errorCode == -1121)) {
      return BinanceParameterException(
        statusCode: statusCode,
        errorCode: errorCode,
        errorMessage: errorMsg,
      );
    }

    // Generic API exception
    return BinanceApiException(
      statusCode: statusCode,
      errorCode: errorCode,
      errorMessage: errorMsg,
      responseBody: responseBody,
    );
  }

  /// Get current rate limit status
  RateLimitStatus getRateLimitStatus() {
    return rateLimiter.getStatus();
  }

  /// Close HTTP client and clean up resources
  void dispose() {
    _httpClient.close();
  }
}
