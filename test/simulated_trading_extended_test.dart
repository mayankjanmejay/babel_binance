import 'package:babel_binance/babel_binance.dart';
import 'package:test/test.dart';

void main() {
  group('Simulated Trading - Market Orders', () {
    final binance = Binance();

    test('Market Order BUY - Basic', () async {
      final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'MARKET',
        quantity: 0.001,
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['status'], equals('FILLED'));
      expect(result['symbol'], equals('BTCUSDT'));
      expect(result['side'], equals('BUY'));
      expect(result['type'], equals('MARKET'));
      expect(result.containsKey('orderId'), isTrue);
      expect(result['orderId'], isA<int>());
      expect(result.containsKey('fills'), isTrue);
    });

    test('Market Order SELL - Basic', () async {
      final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'ETHUSDT',
        side: 'SELL',
        type: 'MARKET',
        quantity: 0.1,
      );

      expect(result['status'], equals('FILLED'));
      expect(result['side'], equals('SELL'));
      expect(result['symbol'], equals('ETHUSDT'));
    });

    test('Market Order - Different Symbols', () async {
      final symbols = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'SOLUSDT'];

      for (final symbol in symbols) {
        final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
          symbol: symbol,
          side: 'BUY',
          type: 'MARKET',
          quantity: 0.001,
        );

        expect(result['symbol'], equals(symbol));
        expect(result['status'], equals('FILLED'));
      }
    });

    test('Market Order - Various Quantities', () async {
      final quantities = [0.001, 0.01, 0.1, 1.0, 10.0];

      for (final quantity in quantities) {
        final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
          symbol: 'BTCUSDT',
          side: 'BUY',
          type: 'MARKET',
          quantity: quantity,
        );

        expect(result['status'], equals('FILLED'));
        expect(result.containsKey('fills'), isTrue);
      }
    });

    test('Market Order - Fills Structure', () async {
      final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'MARKET',
        quantity: 0.001,
      );

      final fills = result['fills'];
      expect(fills, isA<List>());
      expect((fills as List).isNotEmpty, isTrue);

      // Check first fill structure
      final firstFill = fills.first;
      expect(firstFill, isA<Map>());
      expect(firstFill.containsKey('price'), isTrue);
      expect(firstFill.containsKey('qty'), isTrue);
      expect(firstFill.containsKey('commission'), isTrue);
      expect(firstFill.containsKey('commissionAsset'), isTrue);
    });

    test('Market Order - With Simulation Delay', () async {
      final stopwatch = Stopwatch()..start();

      final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'MARKET',
        quantity: 0.001,
        enableSimulationDelay: true,
      );

      stopwatch.stop();

      expect(result['status'], equals('FILLED'));
      expect(stopwatch.elapsedMilliseconds, greaterThan(50));
    });

    test('Market Order - Without Simulation Delay', () async {
      final stopwatch = Stopwatch()..start();

      final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'MARKET',
        quantity: 0.001,
        enableSimulationDelay: false,
      );

      stopwatch.stop();

      expect(result['status'], equals('FILLED'));
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });
  });

  group('Simulated Trading - Limit Orders', () {
    final binance = Binance();

    test('Limit Order BUY - Basic', () async {
      final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'LIMIT',
        quantity: 0.001,
        price: 40000.0,
        timeInForce: 'GTC',
      );

      expect(result['type'], equals('LIMIT'));
      expect(result['side'], equals('BUY'));
      expect(result['price'], equals('40000.0'));
      expect(result['timeInForce'], equals('GTC'));
    });

    test('Limit Order SELL - Basic', () async {
      final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'ETHUSDT',
        side: 'SELL',
        type: 'LIMIT',
        quantity: 0.1,
        price: 3000.0,
        timeInForce: 'GTC',
      );

      expect(result['type'], equals('LIMIT'));
      expect(result['side'], equals('SELL'));
      expect(result['price'], equals('3000.0'));
    });

    test('Limit Order - Various Time In Force', () async {
      final timeInForceOptions = ['GTC', 'IOC', 'FOK'];

      for (final tif in timeInForceOptions) {
        final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
          symbol: 'BTCUSDT',
          side: 'BUY',
          type: 'LIMIT',
          quantity: 0.001,
          price: 40000.0,
          timeInForce: tif,
        );

        expect(result['timeInForce'], equals(tif));
      }
    });

    test('Limit Order - Various Prices', () async {
      final prices = [30000.0, 40000.0, 50000.0, 60000.0];

      for (final price in prices) {
        final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
          symbol: 'BTCUSDT',
          side: 'BUY',
          type: 'LIMIT',
          quantity: 0.001,
          price: price,
          timeInForce: 'GTC',
        );

        expect(result['price'], equals(price.toString()));
      }
    });

    test('Limit Order - High Precision Price', () async {
      final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'LIMIT',
        quantity: 0.001,
        price: 42567.89,
        timeInForce: 'GTC',
      );

      expect(result['price'], equals('42567.89'));
    });
  });

  group('Simulated Trading - Order Status', () {
    final binance = Binance();

    test('Order Status - Basic', () async {
      final result = await binance.spot.simulatedTrading.simulateOrderStatus(
        symbol: 'BTCUSDT',
        orderId: 123456,
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['orderId'], equals(123456));
      expect(result['symbol'], equals('BTCUSDT'));
      expect(result.containsKey('status'), isTrue);
    });

    test('Order Status - Various Order IDs', () async {
      final orderIds = [1, 123, 456789, 999999999];

      for (final orderId in orderIds) {
        final result = await binance.spot.simulatedTrading.simulateOrderStatus(
          symbol: 'BTCUSDT',
          orderId: orderId,
        );

        expect(result['orderId'], equals(orderId));
      }
    });

    test('Order Status - Different Symbols', () async {
      final symbols = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT'];

      for (final symbol in symbols) {
        final result = await binance.spot.simulatedTrading.simulateOrderStatus(
          symbol: symbol,
          orderId: 12345,
        );

        expect(result['symbol'], equals(symbol));
      }
    });

    test('Order Status - Contains Required Fields', () async {
      final result = await binance.spot.simulatedTrading.simulateOrderStatus(
        symbol: 'BTCUSDT',
        orderId: 123456,
      );

      expect(result.containsKey('orderId'), isTrue);
      expect(result.containsKey('symbol'), isTrue);
      expect(result.containsKey('status'), isTrue);
      expect(result.containsKey('side'), isTrue);
      expect(result.containsKey('type'), isTrue);
      expect(result.containsKey('price'), isTrue);
      expect(result.containsKey('origQty'), isTrue);
      expect(result.containsKey('executedQty'), isTrue);
    });

    test('Order Status - Valid Status Values', () async {
      final validStatuses = ['NEW', 'FILLED', 'PARTIALLY_FILLED', 'CANCELED'];

      final result = await binance.spot.simulatedTrading.simulateOrderStatus(
        symbol: 'BTCUSDT',
        orderId: 123456,
      );

      expect(validStatuses.contains(result['status']), isTrue);
    });
  });

  group('Simulated Trading - Performance Tests', () {
    final binance = Binance();

    test('Multiple Orders - Sequential', () async {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 5; i++) {
        await binance.spot.simulatedTrading.simulatePlaceOrder(
          symbol: 'BTCUSDT',
          side: 'BUY',
          type: 'MARKET',
          quantity: 0.001,
          enableSimulationDelay: false,
        );
      }

      stopwatch.stop();
      print('5 sequential orders took: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('Multiple Orders - Concurrent', () async {
      final stopwatch = Stopwatch()..start();

      final futures = <Future>[];
      for (int i = 0; i < 5; i++) {
        futures.add(
          binance.spot.simulatedTrading.simulatePlaceOrder(
            symbol: 'BTCUSDT',
            side: 'BUY',
            type: 'MARKET',
            quantity: 0.001,
            enableSimulationDelay: false,
          ),
        );
      }

      await Future.wait(futures);
      stopwatch.stop();

      print('5 concurrent orders took: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('Order Status Check - Performance', () async {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 10; i++) {
        await binance.spot.simulatedTrading.simulateOrderStatus(
          symbol: 'BTCUSDT',
          orderId: i,
        );
      }

      stopwatch.stop();
      print('10 status checks took: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });
  });

  group('Simulated Trading - Edge Cases', () {
    final binance = Binance();

    test('Very Small Quantity', () async {
      final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'MARKET',
        quantity: 0.00000001,
      );

      expect(result['status'], equals('FILLED'));
    });

    test('Large Quantity', () async {
      final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'MARKET',
        quantity: 1000.0,
      );

      expect(result['status'], equals('FILLED'));
    });

    test('Very High Price Limit Order', () async {
      final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'LIMIT',
        quantity: 0.001,
        price: 1000000.0,
        timeInForce: 'GTC',
      );

      expect(result['price'], equals('1000000.0'));
    });

    test('Very Low Price Limit Order', () async {
      final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'LIMIT',
        quantity: 0.001,
        price: 0.01,
        timeInForce: 'GTC',
      );

      expect(result['price'], equals('0.01'));
    });

    test('Order ID Edge Cases', () async {
      final edgeCaseIds = [0, 1, 2147483647]; // Max int32

      for (final orderId in edgeCaseIds) {
        final result = await binance.spot.simulatedTrading.simulateOrderStatus(
          symbol: 'BTCUSDT',
          orderId: orderId,
        );

        expect(result['orderId'], equals(orderId));
      }
    });

    test('Symbol Case Sensitivity', () async {
      final symbols = ['BTCUSDT', 'btcusdt', 'BtcUsdt'];

      for (final symbol in symbols) {
        final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
          symbol: symbol,
          side: 'BUY',
          type: 'MARKET',
          quantity: 0.001,
        );

        expect(result['symbol'], equals(symbol));
      }
    });
  });

  group('Simulated Trading - Consistency Tests', () {
    final binance = Binance();

    test('Order IDs are Unique', () async {
      final orderIds = <int>{};

      for (int i = 0; i < 10; i++) {
        final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
          symbol: 'BTCUSDT',
          side: 'BUY',
          type: 'MARKET',
          quantity: 0.001,
        );

        final orderId = result['orderId'] as int;
        expect(orderIds.contains(orderId), isFalse);
        orderIds.add(orderId);
      }

      expect(orderIds.length, equals(10));
    });

    test('Commission is Applied', () async {
      final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'MARKET',
        quantity: 0.001,
      );

      final fills = result['fills'] as List;
      final firstFill = fills.first;

      expect(firstFill.containsKey('commission'), isTrue);
      expect(firstFill['commission'], isNotNull);

      final commission = double.parse(firstFill['commission'].toString());
      expect(commission, greaterThanOrEqualTo(0));
    });

    test('Timestamps are Reasonable', () async {
      final before = DateTime.now().millisecondsSinceEpoch;

      final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'MARKET',
        quantity: 0.001,
      );

      final after = DateTime.now().millisecondsSinceEpoch;

      if (result.containsKey('transactTime')) {
        final transactTime = result['transactTime'] as int;
        expect(transactTime, greaterThanOrEqualTo(before - 1000));
        expect(transactTime, lessThanOrEqualTo(after + 1000));
      }
    });
  });
}
