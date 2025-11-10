import 'package:babel_binance/babel_binance.dart';
import 'package:test/test.dart';

void main() {
  group('BinanceException Tests', () {
    test('BinanceException - Basic Creation', () {
      final exception = BinanceException('Test error');
      expect(exception.message, equals('Test error'));
      expect(exception.statusCode, isNull);
      expect(exception.responseBody, isNull);
      expect(exception.toString(), contains('BinanceException: Test error'));
    });

    test('BinanceException - With Status Code', () {
      final exception = BinanceException('Test error', statusCode: 400);
      expect(exception.message, equals('Test error'));
      expect(exception.statusCode, equals(400));
      expect(exception.toString(), contains('Status: 400'));
    });

    test('BinanceException - With Response Body', () {
      final exception = BinanceException(
        'Test error',
        statusCode: 400,
        responseBody: {'msg': 'Invalid request'},
      );
      expect(exception.message, equals('Test error'));
      expect(exception.statusCode, equals(400));
      expect(exception.responseBody, isA<Map>());
      expect((exception.responseBody as Map)['msg'], equals('Invalid request'));
    });
  });

  group('BinanceAuthenticationException Tests', () {
    test('Authentication Exception - Basic', () {
      final exception = BinanceAuthenticationException('Invalid API key');
      expect(exception.message, equals('Invalid API key'));
      expect(exception.toString(), contains('BinanceAuthenticationException'));
    });

    test('Authentication Exception - With Status Code', () {
      final exception = BinanceAuthenticationException(
        'Invalid API key',
        statusCode: 401,
      );
      expect(exception.statusCode, equals(401));
      expect(exception.message, equals('Invalid API key'));
    });

    test('Authentication Exception - Forbidden', () {
      final exception = BinanceAuthenticationException(
        'Access denied',
        statusCode: 403,
        responseBody: {'msg': 'Forbidden'},
      );
      expect(exception.statusCode, equals(403));
      expect(exception.message, equals('Access denied'));
    });
  });

  group('BinanceRateLimitException Tests', () {
    test('Rate Limit Exception - Basic', () {
      final exception = BinanceRateLimitException('Rate limit exceeded');
      expect(exception.message, equals('Rate limit exceeded'));
      expect(exception.retryAfter, isNull);
      expect(exception.toString(), contains('BinanceRateLimitException'));
    });

    test('Rate Limit Exception - With Retry After', () {
      final exception = BinanceRateLimitException(
        'Rate limit exceeded',
        statusCode: 429,
        retryAfter: 60,
      );
      expect(exception.statusCode, equals(429));
      expect(exception.retryAfter, equals(60));
      expect(exception.toString(), contains('Retry after: 60s'));
    });

    test('Rate Limit Exception - With Response Body', () {
      final exception = BinanceRateLimitException(
        'Rate limit exceeded',
        statusCode: 429,
        retryAfter: 120,
        responseBody: {'msg': 'Too many requests'},
      );
      expect(exception.retryAfter, equals(120));
      expect(exception.responseBody, isA<Map>());
    });
  });

  group('BinanceValidationException Tests', () {
    test('Validation Exception - Basic', () {
      final exception = BinanceValidationException('Invalid parameter');
      expect(exception.message, equals('Invalid parameter'));
      expect(exception.toString(), contains('BinanceValidationException'));
    });

    test('Validation Exception - With Details', () {
      final exception = BinanceValidationException(
        'Invalid quantity',
        statusCode: 400,
        responseBody: {'msg': 'Quantity must be positive'},
      );
      expect(exception.statusCode, equals(400));
      expect(exception.message, equals('Invalid quantity'));
    });

    test('Validation Exception - Multiple Validation Errors', () {
      final exception = BinanceValidationException(
        'Multiple validation errors',
        statusCode: 400,
        responseBody: {
          'errors': ['Price too low', 'Quantity too small']
        },
      );
      expect(exception.responseBody, isA<Map>());
      expect((exception.responseBody as Map)['errors'], isA<List>());
    });
  });

  group('BinanceNetworkException Tests', () {
    test('Network Exception - Basic', () {
      final exception = BinanceNetworkException('Connection failed');
      expect(exception.message, equals('Connection failed'));
      expect(exception.statusCode, isNull);
      expect(exception.toString(), contains('BinanceNetworkException'));
    });

    test('Network Exception - With Details', () {
      final exception = BinanceNetworkException(
        'Connection timeout',
        responseBody: 'Network unreachable',
      );
      expect(exception.message, equals('Connection timeout'));
      expect(exception.responseBody, equals('Network unreachable'));
    });

    test('Network Exception - DNS Error', () {
      final exception = BinanceNetworkException(
        'DNS resolution failed',
        responseBody: {'error': 'Host not found'},
      );
      expect(exception.message, equals('DNS resolution failed'));
      expect(exception.responseBody, isA<Map>());
    });
  });

  group('BinanceServerException Tests', () {
    test('Server Exception - Basic', () {
      final exception = BinanceServerException('Internal server error');
      expect(exception.message, equals('Internal server error'));
      expect(exception.toString(), contains('BinanceServerException'));
    });

    test('Server Exception - 500 Error', () {
      final exception = BinanceServerException(
        'Server error',
        statusCode: 500,
        responseBody: {'msg': 'Internal error'},
      );
      expect(exception.statusCode, equals(500));
      expect(exception.message, equals('Server error'));
    });

    test('Server Exception - 503 Service Unavailable', () {
      final exception = BinanceServerException(
        'Service unavailable',
        statusCode: 503,
        responseBody: {'msg': 'Maintenance mode'},
      );
      expect(exception.statusCode, equals(503));
      expect(exception.message, equals('Service unavailable'));
    });
  });

  group('BinanceInsufficientBalanceException Tests', () {
    test('Insufficient Balance Exception - Basic', () {
      final exception = BinanceInsufficientBalanceException('Insufficient balance');
      expect(exception.message, equals('Insufficient balance'));
      expect(exception.toString(), contains('BinanceInsufficientBalanceException'));
    });

    test('Insufficient Balance Exception - With Details', () {
      final exception = BinanceInsufficientBalanceException(
        'Insufficient USDT balance',
        statusCode: 400,
        responseBody: {'available': 10.0, 'required': 100.0},
      );
      expect(exception.statusCode, equals(400));
      expect(exception.message, equals('Insufficient USDT balance'));
      expect(exception.responseBody, isA<Map>());
    });

    test('Insufficient Balance Exception - Trading', () {
      final exception = BinanceInsufficientBalanceException(
        'Not enough funds to complete trade',
        statusCode: 400,
        responseBody: {
          'asset': 'BTC',
          'available': '0.001',
          'required': '0.01'
        },
      );
      expect(exception.message, contains('Not enough funds'));
      final body = exception.responseBody as Map;
      expect(body['asset'], equals('BTC'));
    });
  });

  group('BinanceTimeoutException Tests', () {
    test('Timeout Exception - Basic', () {
      final timeout = Duration(seconds: 30);
      final exception = BinanceTimeoutException('Request timeout', timeout);
      expect(exception.message, equals('Request timeout'));
      expect(exception.timeout, equals(timeout));
      expect(exception.toString(), contains('Timeout: 30s'));
    });

    test('Timeout Exception - Short Timeout', () {
      final timeout = Duration(seconds: 5);
      final exception = BinanceTimeoutException('Quick timeout', timeout);
      expect(exception.timeout.inSeconds, equals(5));
      expect(exception.toString(), contains('5s'));
    });

    test('Timeout Exception - Long Timeout', () {
      final timeout = Duration(minutes: 2);
      final exception = BinanceTimeoutException('Long operation timeout', timeout);
      expect(exception.timeout.inSeconds, equals(120));
      expect(exception.toString(), contains('120s'));
    });

    test('Timeout Exception - With Response Body', () {
      final timeout = Duration(seconds: 30);
      final exception = BinanceTimeoutException(
        'Request timeout',
        timeout,
        responseBody: 'Partial response received',
      );
      expect(exception.responseBody, equals('Partial response received'));
    });
  });

  group('Exception Hierarchy Tests', () {
    test('All exceptions extend BinanceException', () {
      expect(BinanceAuthenticationException('test'), isA<BinanceException>());
      expect(BinanceRateLimitException('test'), isA<BinanceException>());
      expect(BinanceValidationException('test'), isA<BinanceException>());
      expect(BinanceNetworkException('test'), isA<BinanceException>());
      expect(BinanceServerException('test'), isA<BinanceException>());
      expect(BinanceInsufficientBalanceException('test'), isA<BinanceException>());
      expect(BinanceTimeoutException('test', Duration(seconds: 1)), isA<BinanceException>());
    });

    test('All exceptions implement Exception', () {
      expect(BinanceException('test'), isA<Exception>());
      expect(BinanceAuthenticationException('test'), isA<Exception>());
      expect(BinanceRateLimitException('test'), isA<Exception>());
      expect(BinanceValidationException('test'), isA<Exception>());
      expect(BinanceNetworkException('test'), isA<Exception>());
      expect(BinanceServerException('test'), isA<Exception>());
      expect(BinanceInsufficientBalanceException('test'), isA<Exception>());
      expect(BinanceTimeoutException('test', Duration(seconds: 1)), isA<Exception>());
    });

    test('Exception toString provides useful debugging info', () {
      final exceptions = [
        BinanceException('msg'),
        BinanceAuthenticationException('msg'),
        BinanceRateLimitException('msg'),
        BinanceValidationException('msg'),
        BinanceNetworkException('msg'),
        BinanceServerException('msg'),
        BinanceInsufficientBalanceException('msg'),
        BinanceTimeoutException('msg', Duration(seconds: 1)),
      ];

      for (final exception in exceptions) {
        final str = exception.toString();
        expect(str, contains('Exception'));
        expect(str, contains('msg'));
      }
    });
  });
}
