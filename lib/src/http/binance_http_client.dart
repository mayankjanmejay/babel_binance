import 'dart:async';
import 'dart:io';
import 'package:http/http.dart' as http;
import '../config/binance_config.dart';
import '../exceptions/network_exception.dart';

/// HTTP client wrapper with timeout and configuration support
class BinanceHttpClient {
  final BinanceConfig config;
  final http.Client _client;

  BinanceHttpClient({
    required this.config,
    http.Client? client,
  }) : _client = client ?? http.Client();

  /// Make GET request with timeout
  Future<http.Response> get(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final effectiveTimeout = timeout ?? config.requestTimeout;

    try {
      return await _client
          .get(uri, headers: _buildHeaders(headers))
          .timeout(effectiveTimeout);
    } on TimeoutException {
      throw BinanceTimeoutException(
        timeout: effectiveTimeout,
        url: uri.toString(),
      );
    } on SocketException catch (e) {
      throw BinanceNetworkException(
        message: 'Connection failed: ${e.message}',
        originalError: e,
        url: uri.toString(),
      );
    }
  }

  /// Make POST request with timeout
  Future<http.Response> post(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) async {
    final effectiveTimeout = timeout ?? config.requestTimeout;

    try {
      return await _client
          .post(uri, headers: _buildHeaders(headers), body: body)
          .timeout(effectiveTimeout);
    } on TimeoutException {
      throw BinanceTimeoutException(
        timeout: effectiveTimeout,
        url: uri.toString(),
      );
    } on SocketException catch (e) {
      throw BinanceNetworkException(
        message: 'Connection failed: ${e.message}',
        originalError: e,
        url: uri.toString(),
      );
    }
  }

  /// Make DELETE request with timeout
  Future<http.Response> delete(
    Uri uri, {
    Map<String, String>? headers,
    Duration? timeout,
  }) async {
    final effectiveTimeout = timeout ?? config.requestTimeout;

    try {
      return await _client
          .delete(uri, headers: _buildHeaders(headers))
          .timeout(effectiveTimeout);
    } on TimeoutException {
      throw BinanceTimeoutException(
        timeout: effectiveTimeout,
        url: uri.toString(),
      );
    } on SocketException catch (e) {
      throw BinanceNetworkException(
        message: 'Connection failed: ${e.message}',
        originalError: e,
        url: uri.toString(),
      );
    }
  }

  /// Make PUT request with timeout
  Future<http.Response> put(
    Uri uri, {
    Map<String, String>? headers,
    Object? body,
    Duration? timeout,
  }) async {
    final effectiveTimeout = timeout ?? config.requestTimeout;

    try {
      return await _client
          .put(uri, headers: _buildHeaders(headers), body: body)
          .timeout(effectiveTimeout);
    } on TimeoutException {
      throw BinanceTimeoutException(
        timeout: effectiveTimeout,
        url: uri.toString(),
      );
    } on SocketException catch (e) {
      throw BinanceNetworkException(
        message: 'Connection failed: ${e.message}',
        originalError: e,
        url: uri.toString(),
      );
    }
  }

  /// Build headers with custom configuration
  Map<String, String> _buildHeaders(Map<String, String>? headers) {
    return {
      'Content-Type': 'application/json',
      if (config.userAgent != null) 'User-Agent': config.userAgent!,
      ...config.customHeaders,
      if (headers != null) ...headers,
    };
  }

  /// Close the HTTP client
  void close() {
    _client.close();
  }
}
