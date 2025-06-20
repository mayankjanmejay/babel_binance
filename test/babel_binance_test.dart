import 'dart:async';
import 'dart:io';

import 'package:babel_binance/babel_binance.dart';
import 'package:test/test.dart';

void main() {
  group('Spot Market Tests', () {
    final binance = Binance();

    test('Get Server Time', () async {
      final serverTime = await binance.spot.market.getServerTime();
      print('Server Time: $serverTime');
      expect(serverTime, isA<Map<String, dynamic>>());
      expect(serverTime.containsKey('serverTime'), isTrue);
    });

    test('Get Exchange Info', () async {
      final exchangeInfo = await binance.spot.market.getExchangeInfo();
      print('Exchange Info: $exchangeInfo');
      expect(exchangeInfo, isA<Map<String, dynamic>>());
      expect(exchangeInfo.containsKey('symbols'), isTrue);
    });

    test('Get Order Book', () async {
      final orderBook =
          await binance.spot.market.getOrderBook('BTCUSDT', limit: 5);
      print('Order Book: $orderBook');
      expect(orderBook, isA<Map<String, dynamic>>());
      expect(orderBook.containsKey('bids'), isTrue);
      expect(orderBook.containsKey('asks'), isTrue);
    });
  });

  group('Authenticated Websocket Tests', () {
    // To run these tests, you need to set the BINANCE_API_KEY environment variable.
    // For example, in your shell:
    // export BINANCE_API_KEY='your_api_key'
    final apiKey = Platform.environment['BINANCE_API_KEY'];

    if (apiKey != null) {
      final binance = Binance(apiKey: apiKey);
      final websockets = Websockets();

      test('Connect to User Data Stream', () async {
        // 1. Create a listen key
        final listenKeyData =
            await binance.spot.userDataStream.createListenKey();
        print('Listen Key Data: $listenKeyData');
        expect(listenKeyData, isA<Map<String, dynamic>>());
        expect(listenKeyData.containsKey('listenKey'), isTrue);
        final listenKey = listenKeyData['listenKey'];

        // 2. Connect to the websocket stream
        final stream = websockets.connectToStream(listenKey);
        StreamSubscription? subscription;

        try {
          subscription = stream.listen(
            (message) {
              // We don't expect a message in this test, but it's good to log if one appears.
              print('Received unexpected message: $message');
            },
            onError: (error) {
              fail('Received an error from the websocket: $error');
            },
          );

          // 3. Wait for a moment to ensure the connection is stable
          await Future.delayed(const Duration(seconds: 5));
        } finally {
          // 4. Clean up resources
          await subscription?.cancel();
          await binance.spot.userDataStream.closeListenKey(listenKey);
        }
      }, timeout: const Timeout(Duration(seconds: 15)));
    } else {
      test('Authenticated tests are skipped', () {
        print(
            'Skipping authenticated tests: BINANCE_API_KEY environment variable not set.');
      });
    }
  });

  group('Simulated Trading Tests', () {
    final binance = Binance();

    test('Simulate Place Order - Market Order', () async {
      final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'MARKET',
        quantity: 0.001,
      );

      print('Simulated Market Order: $result');
      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], equals('FILLED'));
      expect(result['symbol'], equals('BTCUSDT'));
      expect(result['side'], equals('BUY'));
      expect(result['type'], equals('MARKET'));
      expect(result.containsKey('orderId'), isTrue);
      expect(result.containsKey('fills'), isTrue);
    });

    test('Simulate Place Order - Limit Order', () async {
      final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'ETHUSDT',
        side: 'SELL',
        type: 'LIMIT',
        quantity: 0.1,
        price: 3200.0,
        timeInForce: 'GTC',
      );

      print('Simulated Limit Order: $result');
      expect(result, isA<Map<String, dynamic>>());
      expect(result['symbol'], equals('ETHUSDT'));
      expect(result['side'], equals('SELL'));
      expect(result['type'], equals('LIMIT'));
      expect(result['price'], equals('3200.0'));
      expect(result.containsKey('orderId'), isTrue);
    });

    test('Simulate Order Status Check', () async {
      final result = await binance.spot.simulatedTrading.simulateOrderStatus(
        symbol: 'BTCUSDT',
        orderId: 123456789,
      );

      print('Simulated Order Status: $result');
      expect(result, isA<Map<String, dynamic>>());
      expect(result['orderId'], equals(123456789));
      expect(result['symbol'], equals('BTCUSDT'));
      expect(result.containsKey('status'), isTrue);
    });

    test('Timing Test - Order Processing Delay', () async {
      final stopwatch = Stopwatch()..start();

      await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BNBUSDT',
        side: 'BUY',
        type: 'MARKET',
        quantity: 1.0,
        enableSimulationDelay: true,
      );

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      print('Order processing took: ${elapsedMs}ms');
      expect(elapsedMs, greaterThan(50)); // Should take at least 50ms
      expect(elapsedMs, lessThan(4000)); // Should not take more than 4 seconds
    });
  });

  group('Simulated Convert Tests', () {
    final binance = Binance();

    test('Simulate Get Quote', () async {
      final result = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'BTC',
        toAsset: 'USDT',
        fromAmount: 0.001,
      );

      print('Simulated Quote: $result');
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('quoteId'), isTrue);
      expect(result.containsKey('ratio'), isTrue);
      expect(result.containsKey('validTime'), isTrue);
      expect(result['validTime'], equals(10));
      expect(result.containsKey('toAmount'), isTrue);
    });

    test('Simulate Accept Quote', () async {
      final result = await binance.simulatedConvert.simulateAcceptQuote(
        quoteId: 'quote_test_123',
      );

      print('Simulated Accept Quote: $result');
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('orderId'), isTrue);
      expect(result.containsKey('orderStatus'), isTrue);
      expect(result.containsKey('createTime'), isTrue);

      // Should mostly be successful (98% success rate)
      if (result['orderStatus'] == 'FAILED') {
        expect(result.containsKey('errorCode'), isTrue);
        expect(result.containsKey('errorMsg'), isTrue);
      }
    });

    test('Simulate Conversion Order Status', () async {
      final result = await binance.simulatedConvert.simulateOrderStatus(
        orderId: 'test_order_123',
      );

      print('Simulated Conversion Status: $result');
      expect(result, isA<Map<String, dynamic>>());
      expect(result['orderId'], equals('test_order_123'));
      expect(result.containsKey('orderStatus'), isTrue);
      expect(result.containsKey('fromAsset'), isTrue);
      expect(result.containsKey('toAsset'), isTrue);
      expect(result.containsKey('fee'), isTrue);
    });

    test('Simulate Conversion History', () async {
      final result = await binance.simulatedConvert.simulateConversionHistory(
        limit: 10,
      );

      print('Simulated Conversion History: $result');
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('list'), isTrue);
      expect(result['list'], isA<List>());
      expect(result.containsKey('startTime'), isTrue);
      expect(result.containsKey('endTime'), isTrue);
      expect(result.containsKey('limit'), isTrue);
    });

    test('Timing Test - Convert Processing Delay', () async {
      final stopwatch = Stopwatch()..start();

      await binance.simulatedConvert.simulateAcceptQuote(
        quoteId: 'timing_test_quote',
        enableSimulationDelay: true,
      );

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      print('Convert processing took: ${elapsedMs}ms');
      expect(elapsedMs, greaterThan(500)); // Should take at least 500ms
      expect(
          elapsedMs, lessThan(11000)); // Should not take more than 11 seconds
    });

    test('Timing Test - Quote Delay', () async {
      final stopwatch = Stopwatch()..start();

      await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'ETH',
        toAsset: 'BNB',
        fromAmount: 1.0,
        enableSimulationDelay: true,
      );

      stopwatch.stop();
      final elapsedMs = stopwatch.elapsedMilliseconds;

      print('Quote request took: ${elapsedMs}ms');
      expect(elapsedMs, greaterThan(100)); // Should take at least 100ms
      expect(elapsedMs, lessThan(1000)); // Should not take more than 1 second
    });
  });
}
