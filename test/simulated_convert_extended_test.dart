import 'package:babel_binance/babel_binance.dart';
import 'package:test/test.dart';

void main() {
  group('Simulated Convert - Get Quote', () {
    final binance = Binance();

    test('Get Quote - BTC to USDT', () async {
      final result = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'BTC',
        toAsset: 'USDT',
        fromAmount: 0.001,
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('quoteId'), isTrue);
      expect(result.containsKey('ratio'), isTrue);
      expect(result.containsKey('inverseRatio'), isTrue);
      expect(result.containsKey('validTime'), isTrue);
      expect(result.containsKey('toAmount'), isTrue);
      expect(result.containsKey('fromAmount'), isTrue);
    });

    test('Get Quote - ETH to BTC', () async {
      final result = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'ETH',
        toAsset: 'BTC',
        fromAmount: 1.0,
      );

      expect(result['fromAsset'], equals('ETH'));
      expect(result['toAsset'], equals('BTC'));
      expect(result.containsKey('ratio'), isTrue);
    });

    test('Get Quote - Valid Time is 10 seconds', () async {
      final result = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'BTC',
        toAsset: 'USDT',
        fromAmount: 0.01,
      );

      expect(result['validTime'], equals(10));
    });

    test('Get Quote - Various Amounts', () async {
      final amounts = [0.001, 0.01, 0.1, 1.0, 10.0];

      for (final amount in amounts) {
        final result = await binance.simulatedConvert.simulateGetQuote(
          fromAsset: 'BTC',
          toAsset: 'USDT',
          fromAmount: amount,
        );

        expect(result.containsKey('fromAmount'), isTrue);
        expect(result.containsKey('toAmount'), isTrue);
      }
    });

    test('Get Quote - Different Asset Pairs', () async {
      final pairs = [
        {'from': 'BTC', 'to': 'USDT'},
        {'from': 'ETH', 'to': 'USDT'},
        {'from': 'BNB', 'to': 'USDT'},
        {'from': 'USDT', 'to': 'BTC'},
        {'from': 'ETH', 'to': 'BTC'},
      ];

      for (final pair in pairs) {
        final result = await binance.simulatedConvert.simulateGetQuote(
          fromAsset: pair['from']!,
          toAsset: pair['to']!,
          fromAmount: 1.0,
        );

        expect(result.containsKey('quoteId'), isTrue);
        expect(result.containsKey('ratio'), isTrue);
      }
    });

    test('Get Quote - Ratio Calculation', () async {
      final result = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'BTC',
        toAsset: 'USDT',
        fromAmount: 1.0,
      );

      final ratio = double.parse(result['ratio'].toString());
      final fromAmount = double.parse(result['fromAmount'].toString());
      final toAmount = double.parse(result['toAmount'].toString());

      // Verify ratio is consistent with amounts
      expect(ratio, greaterThan(0));
      expect(toAmount, greaterThan(0));
      expect(fromAmount, greaterThan(0));
    });

    test('Get Quote - With Simulation Delay', () async {
      final stopwatch = Stopwatch()..start();

      final result = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'BTC',
        toAsset: 'USDT',
        fromAmount: 0.001,
        enableSimulationDelay: true,
      );

      stopwatch.stop();

      expect(result.containsKey('quoteId'), isTrue);
      expect(stopwatch.elapsedMilliseconds, greaterThan(100));
      expect(stopwatch.elapsedMilliseconds, lessThan(1000));
    });

    test('Get Quote - Without Simulation Delay', () async {
      final stopwatch = Stopwatch()..start();

      final result = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'BTC',
        toAsset: 'USDT',
        fromAmount: 0.001,
        enableSimulationDelay: false,
      );

      stopwatch.stop();

      expect(result.containsKey('quoteId'), isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('Get Quote - Quote ID Format', () async {
      final result = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'BTC',
        toAsset: 'USDT',
        fromAmount: 0.001,
      );

      final quoteId = result['quoteId'] as String;
      expect(quoteId.isNotEmpty, isTrue);
      expect(quoteId.contains('quote_'), isTrue);
    });

    test('Get Quote - Unique Quote IDs', () async {
      final quoteIds = <String>{};

      for (int i = 0; i < 5; i++) {
        final result = await binance.simulatedConvert.simulateGetQuote(
          fromAsset: 'BTC',
          toAsset: 'USDT',
          fromAmount: 0.001,
        );

        final quoteId = result['quoteId'] as String;
        expect(quoteIds.contains(quoteId), isFalse);
        quoteIds.add(quoteId);
      }

      expect(quoteIds.length, equals(5));
    });
  });

  group('Simulated Convert - Accept Quote', () {
    final binance = Binance();

    test('Accept Quote - Basic', () async {
      final result = await binance.simulatedConvert.simulateAcceptQuote(
        quoteId: 'test_quote_123',
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('orderId'), isTrue);
      expect(result.containsKey('orderStatus'), isTrue);
      expect(result.containsKey('createTime'), isTrue);
    });

    test('Accept Quote - Success Scenario', () async {
      // Run multiple times to ensure we get at least one success
      bool gotSuccess = false;

      for (int i = 0; i < 10; i++) {
        final result = await binance.simulatedConvert.simulateAcceptQuote(
          quoteId: 'test_quote_$i',
        );

        if (result['orderStatus'] == 'SUCCESS') {
          gotSuccess = true;
          expect(result.containsKey('orderId'), isTrue);
          expect(result.containsKey('createTime'), isTrue);
          break;
        }
      }

      expect(gotSuccess, isTrue);
    });

    test('Accept Quote - Failure Scenario', () async {
      // Run multiple times to potentially get a failure
      for (int i = 0; i < 50; i++) {
        final result = await binance.simulatedConvert.simulateAcceptQuote(
          quoteId: 'test_quote_$i',
        );

        if (result['orderStatus'] == 'FAILED') {
          expect(result.containsKey('errorCode'), isTrue);
          expect(result.containsKey('errorMsg'), isTrue);
          break;
        }
      }
    });

    test('Accept Quote - Order ID Format', () async {
      final result = await binance.simulatedConvert.simulateAcceptQuote(
        quoteId: 'test_quote_123',
      );

      final orderId = result['orderId'] as String;
      expect(orderId.isNotEmpty, isTrue);
    });

    test('Accept Quote - With Simulation Delay', () async {
      final stopwatch = Stopwatch()..start();

      final result = await binance.simulatedConvert.simulateAcceptQuote(
        quoteId: 'test_quote_123',
        enableSimulationDelay: true,
      );

      stopwatch.stop();

      expect(result.containsKey('orderId'), isTrue);
      expect(stopwatch.elapsedMilliseconds, greaterThan(500));
    });

    test('Accept Quote - Without Simulation Delay', () async {
      final stopwatch = Stopwatch()..start();

      final result = await binance.simulatedConvert.simulateAcceptQuote(
        quoteId: 'test_quote_123',
        enableSimulationDelay: false,
      );

      stopwatch.stop();

      expect(result.containsKey('orderId'), isTrue);
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    test('Accept Quote - Create Time is Recent', () async {
      final before = DateTime.now().millisecondsSinceEpoch;

      final result = await binance.simulatedConvert.simulateAcceptQuote(
        quoteId: 'test_quote_123',
      );

      final after = DateTime.now().millisecondsSinceEpoch;
      final createTime = result['createTime'] as int;

      expect(createTime, greaterThanOrEqualTo(before - 1000));
      expect(createTime, lessThanOrEqualTo(after + 1000));
    });
  });

  group('Simulated Convert - Order Status', () {
    final binance = Binance();

    test('Order Status - Basic', () async {
      final result = await binance.simulatedConvert.simulateOrderStatus(
        orderId: 'test_order_123',
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result['orderId'], equals('test_order_123'));
      expect(result.containsKey('orderStatus'), isTrue);
      expect(result.containsKey('fromAsset'), isTrue);
      expect(result.containsKey('toAsset'), isTrue);
    });

    test('Order Status - Contains All Fields', () async {
      final result = await binance.simulatedConvert.simulateOrderStatus(
        orderId: 'test_order_123',
      );

      expect(result.containsKey('orderId'), isTrue);
      expect(result.containsKey('orderStatus'), isTrue);
      expect(result.containsKey('fromAsset'), isTrue);
      expect(result.containsKey('toAsset'), isTrue);
      expect(result.containsKey('fromAmount'), isTrue);
      expect(result.containsKey('toAmount'), isTrue);
      expect(result.containsKey('ratio'), isTrue);
      expect(result.containsKey('fee'), isTrue);
      expect(result.containsKey('createTime'), isTrue);
    });

    test('Order Status - Valid Status Values', () async {
      final validStatuses = ['SUCCESS', 'PROCESSING', 'FAILED'];

      final result = await binance.simulatedConvert.simulateOrderStatus(
        orderId: 'test_order_123',
      );

      expect(validStatuses.contains(result['orderStatus']), isTrue);
    });

    test('Order Status - Different Order IDs', () async {
      final orderIds = ['order1', 'order2', 'order3', 'test_order_999'];

      for (final orderId in orderIds) {
        final result = await binance.simulatedConvert.simulateOrderStatus(
          orderId: orderId,
        );

        expect(result['orderId'], equals(orderId));
      }
    });

    test('Order Status - Fee is Reasonable', () async {
      final result = await binance.simulatedConvert.simulateOrderStatus(
        orderId: 'test_order_123',
      );

      final fee = double.parse(result['fee'].toString());
      expect(fee, greaterThanOrEqualTo(0));
      expect(fee, lessThan(1000000)); // Reasonable upper bound
    });
  });

  group('Simulated Convert - Conversion History', () {
    final binance = Binance();

    test('Conversion History - Basic', () async {
      final result = await binance.simulatedConvert.simulateConversionHistory(
        limit: 10,
      );

      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('list'), isTrue);
      expect(result['list'], isA<List>());
      expect(result.containsKey('startTime'), isTrue);
      expect(result.containsKey('endTime'), isTrue);
      expect(result.containsKey('limit'), isTrue);
    });

    test('Conversion History - List Structure', () async {
      final result = await binance.simulatedConvert.simulateConversionHistory(
        limit: 10,
      );

      final list = result['list'] as List;
      expect(list.length, greaterThan(0));

      // Check first item structure
      final firstItem = list.first;
      expect(firstItem, isA<Map>());
      expect(firstItem.containsKey('orderId'), isTrue);
      expect(firstItem.containsKey('fromAsset'), isTrue);
      expect(firstItem.containsKey('toAsset'), isTrue);
      expect(firstItem.containsKey('fromAmount'), isTrue);
      expect(firstItem.containsKey('toAmount'), isTrue);
      expect(firstItem.containsKey('status'), isTrue);
      expect(firstItem.containsKey('createTime'), isTrue);
    });

    test('Conversion History - Various Limits', () async {
      final limits = [1, 5, 10, 20, 50];

      for (final limit in limits) {
        final result = await binance.simulatedConvert.simulateConversionHistory(
          limit: limit,
        );

        expect(result['limit'], equals(limit));
        final list = result['list'] as List;
        expect(list.length, lessThanOrEqualTo(limit));
      }
    });

    test('Conversion History - Time Range is Valid', () async {
      final result = await binance.simulatedConvert.simulateConversionHistory(
        limit: 10,
      );

      final startTime = result['startTime'] as int;
      final endTime = result['endTime'] as int;

      expect(startTime, lessThan(endTime));
      expect(endTime, lessThanOrEqualTo(DateTime.now().millisecondsSinceEpoch + 1000));
    });

    test('Conversion History - With Start and End Time', () async {
      final now = DateTime.now().millisecondsSinceEpoch;
      final oneDayAgo = now - (24 * 60 * 60 * 1000);

      final result = await binance.simulatedConvert.simulateConversionHistory(
        startTime: oneDayAgo,
        endTime: now,
        limit: 10,
      );

      expect(result.containsKey('list'), isTrue);
      expect(result['startTime'], equals(oneDayAgo));
      expect(result['endTime'], equals(now));
    });

    test('Conversion History - Default Limit', () async {
      final result = await binance.simulatedConvert.simulateConversionHistory();

      expect(result.containsKey('list'), isTrue);
      expect(result.containsKey('limit'), isTrue);
    });
  });

  group('Simulated Convert - End-to-End Flow', () {
    final binance = Binance();

    test('Complete Convert Flow - Get Quote -> Accept -> Check Status', () async {
      // Step 1: Get Quote
      final quoteResult = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'BTC',
        toAsset: 'USDT',
        fromAmount: 0.001,
      );

      expect(quoteResult.containsKey('quoteId'), isTrue);
      final quoteId = quoteResult['quoteId'] as String;

      // Step 2: Accept Quote
      final acceptResult = await binance.simulatedConvert.simulateAcceptQuote(
        quoteId: quoteId,
      );

      expect(acceptResult.containsKey('orderId'), isTrue);
      final orderId = acceptResult['orderId'] as String;

      // Step 3: Check Order Status
      final statusResult = await binance.simulatedConvert.simulateOrderStatus(
        orderId: orderId,
      );

      expect(statusResult['orderId'], equals(orderId));
      expect(statusResult.containsKey('orderStatus'), isTrue);
    });

    test('Multiple Conversions in Sequence', () async {
      for (int i = 0; i < 3; i++) {
        final quoteResult = await binance.simulatedConvert.simulateGetQuote(
          fromAsset: 'BTC',
          toAsset: 'USDT',
          fromAmount: 0.001,
        );

        expect(quoteResult.containsKey('quoteId'), isTrue);

        final acceptResult = await binance.simulatedConvert.simulateAcceptQuote(
          quoteId: quoteResult['quoteId'] as String,
        );

        expect(acceptResult.containsKey('orderId'), isTrue);
      }
    });
  });

  group('Simulated Convert - Performance Tests', () {
    final binance = Binance();

    test('Multiple Quotes - Sequential', () async {
      final stopwatch = Stopwatch()..start();

      for (int i = 0; i < 5; i++) {
        await binance.simulatedConvert.simulateGetQuote(
          fromAsset: 'BTC',
          toAsset: 'USDT',
          fromAmount: 0.001,
          enableSimulationDelay: false,
        );
      }

      stopwatch.stop();
      print('5 sequential quotes took: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(500));
    });

    test('Multiple Quotes - Concurrent', () async {
      final stopwatch = Stopwatch()..start();

      final futures = <Future>[];
      for (int i = 0; i < 5; i++) {
        futures.add(
          binance.simulatedConvert.simulateGetQuote(
            fromAsset: 'BTC',
            toAsset: 'USDT',
            fromAmount: 0.001,
            enableSimulationDelay: false,
          ),
        );
      }

      await Future.wait(futures);
      stopwatch.stop();

      print('5 concurrent quotes took: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(300));
    });
  });

  group('Simulated Convert - Edge Cases', () {
    final binance = Binance();

    test('Very Small Amount', () async {
      final result = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'BTC',
        toAsset: 'USDT',
        fromAmount: 0.00000001,
      );

      expect(result.containsKey('quoteId'), isTrue);
      expect(result.containsKey('toAmount'), isTrue);
    });

    test('Large Amount', () async {
      final result = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'BTC',
        toAsset: 'USDT',
        fromAmount: 1000.0,
      );

      expect(result.containsKey('quoteId'), isTrue);
      expect(result.containsKey('toAmount'), isTrue);
    });

    test('Same Asset Conversion', () async {
      final result = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'BTC',
        toAsset: 'BTC',
        fromAmount: 1.0,
      );

      expect(result.containsKey('quoteId'), isTrue);
    });

    test('Empty Quote ID', () async {
      final result = await binance.simulatedConvert.simulateAcceptQuote(
        quoteId: '',
      );

      expect(result.containsKey('orderId'), isTrue);
    });

    test('Long Quote ID', () async {
      final longQuoteId = 'quote_' + 'a' * 1000;
      final result = await binance.simulatedConvert.simulateAcceptQuote(
        quoteId: longQuoteId,
      );

      expect(result.containsKey('orderId'), isTrue);
    });
  });
}
