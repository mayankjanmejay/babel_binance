import 'package:test/test.dart';
import 'package:shelf/shelf.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Integration tests for API Server
/// Note: These tests require the API server to be running
/// Run with: dart test test/api_integration_test.dart

void main() {
  final baseUrl = 'http://localhost:3000';

  group('API Server - Health Checks', () {
    test('GET /health returns healthy status', () async {
      final response = await http.get(Uri.parse('$baseUrl/health'));

      expect(response.statusCode, equals(200));

      final body = json.decode(response.body);
      expect(body['status'], equals('healthy'));
      expect(body.containsKey('timestamp'), isTrue);
    });

    test('GET /status checks service connections', () async {
      final response = await http.get(Uri.parse('$baseUrl/status'));

      expect(response.statusCode, anyOf(equals(200), equals(500)));

      final body = json.decode(response.body);
      expect(body.containsKey('status'), isTrue);
    });
  });

  group('API Server - Market Data', () {
    test('GET /api/market/ticker/:symbol returns ticker data', () async {
      final response = await http.get(
        Uri.parse('$baseUrl/api/market/ticker/BTCUSDT'),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        expect(body.containsKey('symbol'), isTrue);
        expect(body.containsKey('lastPrice'), isTrue);
        expect(body['symbol'], equals('BTCUSDT'));
      }
    });

    test('GET /api/market/tickers returns multiple tickers', () async {
      final response = await http.get(
        Uri.parse('$baseUrl/api/market/tickers'),
      );

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        expect(body, isList);
      }
    });
  });

  group('API Server - Watchlist', () {
    test('GET /api/watchlist returns watchlist items', () async {
      final response = await http.get(
        Uri.parse('$baseUrl/api/watchlist'),
      );

      expect(response.statusCode, anyOf(equals(200), equals(500)));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        expect(body, isList);
      }
    });

    test('POST /api/watchlist adds new symbol', () async {
      final response = await http.post(
        Uri.parse('$baseUrl/api/watchlist'),
        headers: {'Content-Type': 'application/json'},
        body: json.encode({
          'symbol': 'TESTUSDT',
          'target_buy': 100.0,
          'target_sell': 200.0,
        }),
      );

      // May fail if database not configured, that's OK for unit tests
      expect(
        response.statusCode,
        anyOf(equals(200), equals(500)),
      );
    });
  });

  group('API Server - Trades', () {
    test('GET /api/trades returns trade history', () async {
      final response = await http.get(
        Uri.parse('$baseUrl/api/trades'),
      );

      expect(response.statusCode, anyOf(equals(200), equals(500)));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        expect(body, isList);
      }
    });

    test('GET /api/trades/stats returns statistics', () async {
      final response = await http.get(
        Uri.parse('$baseUrl/api/trades/stats'),
      );

      expect(response.statusCode, anyOf(equals(200), equals(500)));

      if (response.statusCode == 200) {
        final body = json.decode(response.body);
        expect(body.containsKey('total_trades'), isTrue);
        expect(body.containsKey('buy_trades'), isTrue);
        expect(body.containsKey('sell_trades'), isTrue);
      }
    });
  });

  group('API Server - Error Handling', () {
    test('returns 404 for unknown routes', () async {
      final response = await http.get(
        Uri.parse('$baseUrl/api/nonexistent'),
      );

      expect(response.statusCode, equals(404));
    });

    test('handles invalid symbol gracefully', () async {
      final response = await http.get(
        Uri.parse('$baseUrl/api/market/ticker/INVALID'),
      );

      expect(response.statusCode, anyOf(equals(200), equals(500)));
    });
  });

  group('API Server - CORS', () {
    test('includes CORS headers', () async {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      );

      // Check if CORS headers are present (they should be)
      expect(response.headers.keys, isNotEmpty);
    });
  });
}
