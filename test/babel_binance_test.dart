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
}
