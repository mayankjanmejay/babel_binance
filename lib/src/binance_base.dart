import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:crypto/crypto.dart';

class BinanceBase {
  final String? apiKey;
  final String? apiSecret;
  final String baseUrl;
  final List<String> _endpoints;
  int _currentEndpointIndex = 0;

  BinanceBase({this.apiKey, this.apiSecret, required this.baseUrl})
      : _endpoints = _generateEndpoints(baseUrl);

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
  }) async {
    params ??= {};
    if (apiSecret != null) {
      params['timestamp'] = DateTime.now().millisecondsSinceEpoch;
      final query = Uri(queryParameters: params.map((key, value) => MapEntry(key, value.toString()))).query;
      final signature = Hmac(sha256, utf8.encode(apiSecret!)).convert(utf8.encode(query)).toString();
      params['signature'] = signature;
    }

    // Try all endpoints with failover
    for (int attempt = 0; attempt < _endpoints.length; attempt++) {
      try {
        final uri = Uri.parse('$_currentEndpoint$path').replace(
          queryParameters:
              params.map((key, value) => MapEntry(key, value.toString())),
        );

        final headers = <String, String>{
          'Content-Type': 'application/json',
          if (apiKey != null) 'X-MBX-APIKEY': apiKey!,
        };

        http.Response response;
        switch (method.toUpperCase()) {
          case 'GET':
            response = await http.get(uri, headers: headers);
            break;
          case 'POST':
            response = await http.post(uri, headers: headers);
            break;
          case 'DELETE':
            response = await http.delete(uri, headers: headers);
            break;
          case 'PUT':
            response = await http.put(uri, headers: headers);
            break;
          default:
            throw Exception('Unsupported HTTP method: $method');
        }

        if (response.statusCode >= 200 && response.statusCode < 300) {
          // Success! Reset to primary endpoint for next time
          if (attempt > 0) {
            _resetToPrimaryEndpoint();
          }
          return json.decode(response.body);
        } else {
          // If this is not the last attempt, try the next endpoint
          if (attempt < _endpoints.length - 1) {
            _rotateEndpoint();
            continue;
          }
          // Last attempt failed, throw exception
          throw Exception(
              'Failed to load data: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        // Network or other error, try next endpoint if available
        if (attempt < _endpoints.length - 1) {
          _rotateEndpoint();
          continue;
        }
        // Last attempt failed, rethrow the exception
        rethrow;
      }
    }

    // This should never be reached, but added for completeness
    throw Exception('All endpoints failed');
  }
}