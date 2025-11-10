import 'package:babel_binance/babel_binance.dart';
import 'package:test/test.dart';

void main() {
  group('Spot Market Extended Tests', () {
    final binance = Binance();

    test('Get Server Time - Validate Response Structure', () async {
      final serverTime = await binance.spot.market.getServerTime();

      expect(serverTime, isA<Map<String, dynamic>>());
      expect(serverTime.containsKey('serverTime'), isTrue);
      expect(serverTime['serverTime'], isA<int>());

      // Verify timestamp is reasonable (within last hour and not in future)
      final timestamp = serverTime['serverTime'] as int;
      final now = DateTime.now().millisecondsSinceEpoch;
      expect(timestamp, lessThanOrEqualTo(now + 60000)); // Allow 1 min clock skew
      expect(timestamp, greaterThan(now - 3600000)); // Within last hour
    });

    test('Get Exchange Info - Validate Response Structure', () async {
      final exchangeInfo = await binance.spot.market.getExchangeInfo();

      expect(exchangeInfo, isA<Map<String, dynamic>>());
      expect(exchangeInfo.containsKey('timezone'), isTrue);
      expect(exchangeInfo.containsKey('serverTime'), isTrue);
      expect(exchangeInfo.containsKey('symbols'), isTrue);
      expect(exchangeInfo['symbols'], isA<List>());

      final symbols = exchangeInfo['symbols'] as List;
      expect(symbols.isNotEmpty, isTrue);

      // Verify first symbol has expected structure
      final firstSymbol = symbols.first;
      expect(firstSymbol, isA<Map>());
      expect(firstSymbol['symbol'], isNotNull);
      expect(firstSymbol['status'], isNotNull);
    });

    test('Get Order Book - BTCUSDT with default limit', () async {
      final orderBook = await binance.spot.market.getOrderBook('BTCUSDT');

      expect(orderBook, isA<Map<String, dynamic>>());
      expect(orderBook.containsKey('lastUpdateId'), isTrue);
      expect(orderBook.containsKey('bids'), isTrue);
      expect(orderBook.containsKey('asks'), isTrue);

      final bids = orderBook['bids'] as List;
      final asks = orderBook['asks'] as List;

      expect(bids.isNotEmpty, isTrue);
      expect(asks.isNotEmpty, isTrue);

      // Verify bid/ask structure
      expect(bids.first, isA<List>());
      expect(asks.first, isA<List>());
      expect((bids.first as List).length, equals(2)); // [price, quantity]
      expect((asks.first as List).length, equals(2)); // [price, quantity]
    });

    test('Get Order Book - Custom limit of 5', () async {
      final orderBook = await binance.spot.market.getOrderBook('ETHUSDT', limit: 5);

      expect(orderBook, isA<Map<String, dynamic>>());
      final bids = orderBook['bids'] as List;
      final asks = orderBook['asks'] as List;

      expect(bids.length, lessThanOrEqualTo(5));
      expect(asks.length, lessThanOrEqualTo(5));
    });

    test('Get Order Book - Large limit of 1000', () async {
      final orderBook = await binance.spot.market.getOrderBook('BTCUSDT', limit: 1000);

      expect(orderBook, isA<Map<String, dynamic>>());
      final bids = orderBook['bids'] as List;
      final asks = orderBook['asks'] as List;

      expect(bids.isNotEmpty, isTrue);
      expect(asks.isNotEmpty, isTrue);
      // Binance may return less than requested, but should be > 100
      expect(bids.length, greaterThan(100));
      expect(asks.length, greaterThan(100));
    });

    test('Get 24hr Ticker - BTCUSDT', () async {
      final ticker = await binance.spot.market.get24HrTicker('BTCUSDT');

      expect(ticker, isA<Map<String, dynamic>>());
      expect(ticker['symbol'], equals('BTCUSDT'));
      expect(ticker.containsKey('priceChange'), isTrue);
      expect(ticker.containsKey('priceChangePercent'), isTrue);
      expect(ticker.containsKey('lastPrice'), isTrue);
      expect(ticker.containsKey('volume'), isTrue);
      expect(ticker.containsKey('openTime'), isTrue);
      expect(ticker.containsKey('closeTime'), isTrue);
    });

    test('Get 24hr Ticker - ETHUSDT', () async {
      final ticker = await binance.spot.market.get24HrTicker('ETHUSDT');

      expect(ticker, isA<Map<String, dynamic>>());
      expect(ticker['symbol'], equals('ETHUSDT'));
      expect(ticker.containsKey('lastPrice'), isTrue);

      // Verify price is a valid number string
      final lastPrice = ticker['lastPrice'];
      expect(lastPrice, isA<String>());
      expect(double.tryParse(lastPrice), isNotNull);
    });

    test('Multiple Symbols - BTCUSDT, ETHUSDT, BNBUSDT', () async {
      final symbols = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT'];

      for (final symbol in symbols) {
        final orderBook = await binance.spot.market.getOrderBook(symbol, limit: 5);
        expect(orderBook, isA<Map<String, dynamic>>());
        expect(orderBook.containsKey('bids'), isTrue);
        expect(orderBook.containsKey('asks'), isTrue);
      }
    });

    test('Order Book Price Validation - Bids descending, Asks ascending', () async {
      final orderBook = await binance.spot.market.getOrderBook('BTCUSDT', limit: 10);

      final bids = orderBook['bids'] as List;
      final asks = orderBook['asks'] as List;

      // Verify bids are in descending order (highest first)
      for (int i = 0; i < bids.length - 1; i++) {
        final currentPrice = double.parse((bids[i] as List)[0]);
        final nextPrice = double.parse((bids[i + 1] as List)[0]);
        expect(currentPrice, greaterThan(nextPrice));
      }

      // Verify asks are in ascending order (lowest first)
      for (int i = 0; i < asks.length - 1; i++) {
        final currentPrice = double.parse((asks[i] as List)[0]);
        final nextPrice = double.parse((asks[i + 1] as List)[0]);
        expect(currentPrice, lessThan(nextPrice));
      }

      // Verify spread: lowest ask should be higher than highest bid
      final highestBid = double.parse((bids.first as List)[0]);
      final lowestAsk = double.parse((asks.first as List)[0]);
      expect(lowestAsk, greaterThan(highestBid));
    });

    test('Concurrent Requests - Rate Limiting Test', () async {
      // Make multiple concurrent requests to test rate limiting
      final futures = <Future>[];

      for (int i = 0; i < 5; i++) {
        futures.add(binance.spot.market.getServerTime());
      }

      final results = await Future.wait(futures);

      expect(results.length, equals(5));
      for (final result in results) {
        expect(result, isA<Map<String, dynamic>>());
        expect(result.containsKey('serverTime'), isTrue);
      }
    });

    test('Sequential Requests - Consistency Test', () async {
      final result1 = await binance.spot.market.getServerTime();
      await Future.delayed(Duration(milliseconds: 100));
      final result2 = await binance.spot.market.getServerTime();

      final time1 = result1['serverTime'] as int;
      final time2 = result2['serverTime'] as int;

      // Second timestamp should be greater than first
      expect(time2, greaterThan(time1));
      // But not too far apart (should be within 1 second)
      expect(time2 - time1, lessThan(1000));
    });
  });

  group('Spot Module Structure Tests', () {
    test('Spot class has all required submodules', () {
      final spot = Spot();

      expect(spot.market, isNotNull);
      expect(spot.market, isA<Market>());

      expect(spot.userDataStream, isNotNull);
      expect(spot.userDataStream, isA<UserDataStream>());

      expect(spot.trading, isNotNull);
      expect(spot.trading, isA<Trading>());

      expect(spot.simulatedTrading, isNotNull);
      expect(spot.simulatedTrading, isA<SimulatedTrading>());
    });

    test('Spot class with API credentials', () {
      final spot = Spot(apiKey: 'test_key', apiSecret: 'test_secret');

      expect(spot.market, isNotNull);
      expect(spot.userDataStream, isNotNull);
      expect(spot.trading, isNotNull);
      expect(spot.simulatedTrading, isNotNull);
    });

    test('Multiple Spot instances are independent', () {
      final spot1 = Spot();
      final spot2 = Spot();

      expect(spot1, isNot(same(spot2)));
      expect(spot1.market, isNot(same(spot2.market)));
    });
  });

  group('Spot Integration Performance Tests', () {
    final binance = Binance();

    test('Server Time Response Time', () async {
      final stopwatch = Stopwatch()..start();
      await binance.spot.market.getServerTime();
      stopwatch.stop();

      print('Server Time request took: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Should complete within 5s
    });

    test('Order Book Response Time', () async {
      final stopwatch = Stopwatch()..start();
      await binance.spot.market.getOrderBook('BTCUSDT', limit: 5);
      stopwatch.stop();

      print('Order Book request took: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('24hr Ticker Response Time', () async {
      final stopwatch = Stopwatch()..start();
      await binance.spot.market.get24HrTicker('BTCUSDT');
      stopwatch.stop();

      print('24hr Ticker request took: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(5000));
    });

    test('Exchange Info Response Time', () async {
      final stopwatch = Stopwatch()..start();
      await binance.spot.market.getExchangeInfo();
      stopwatch.stop();

      print('Exchange Info request took: ${stopwatch.elapsedMilliseconds}ms');
      expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // Larger response, allow 10s
    });
  });

  group('Spot Error Handling Tests', () {
    final binance = Binance();

    test('Invalid Symbol - Should handle error gracefully', () async {
      try {
        await binance.spot.market.getOrderBook('INVALIDSYMBOL');
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<BinanceException>());
        print('Caught expected exception: $e');
      }
    });

    test('Invalid Limit - Too large', () async {
      try {
        await binance.spot.market.getOrderBook('BTCUSDT', limit: 10000);
        // May succeed or fail depending on API limits
      } catch (e) {
        expect(e, isA<BinanceException>());
        print('Caught expected exception for invalid limit: $e');
      }
    });
  });
}
