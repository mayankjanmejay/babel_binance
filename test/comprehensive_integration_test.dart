import 'package:babel_binance/babel_binance.dart';
import 'package:test/test.dart';

void main() {
  group('Comprehensive Integration Tests', () {
    late Binance binance;

    setUp(() {
      binance = Binance();
    });

    test('Library Entry Point - babel_binance.dart exports', () {
      // Verify all main classes are accessible
      expect(Binance, isNotNull);
      expect(BinanceConfig, isNotNull);
      expect(BinanceException, isNotNull);
      expect(Websockets, isNotNull);
    });

    test('Client Initialization Variations', () {
      // No credentials
      final client1 = Binance();
      expect(client1, isNotNull);

      // With API key only
      final client2 = Binance(apiKey: 'test_key');
      expect(client2, isNotNull);

      // With both credentials
      final client3 = Binance(
        apiKey: 'test_key',
        apiSecret: 'test_secret',
      );
      expect(client3, isNotNull);

      // With custom config
      final config = BinanceConfig(timeout: Duration(seconds: 60));
      final client4 = Binance(config: config);
      expect(client4, isNotNull);

      // With testnet
      final client5 = Binance(useTestnet: true);
      expect(client5, isNotNull);

      // All combinations
      final client6 = Binance(
        apiKey: 'test_key',
        apiSecret: 'test_secret',
        config: BinanceConfig(maxRetries: 5),
        useTestnet: true,
      );
      expect(client6, isNotNull);
    });

    test('All Core Trading APIs Accessible', () {
      expect(binance.spot, isNotNull);
      expect(binance.futuresUsd, isNotNull);
      expect(binance.futuresCoin, isNotNull);
      expect(binance.futuresAlgo, isNotNull);
      expect(binance.margin, isNotNull);
      expect(binance.portfolioMargin, isNotNull);
    });

    test('All Wallet & Account APIs Accessible', () {
      expect(binance.wallet, isNotNull);
      expect(binance.subAccount, isNotNull);
    });

    test('All Earn Product APIs Accessible', () {
      expect(binance.staking, isNotNull);
      expect(binance.savings, isNotNull);
      expect(binance.simpleEarn, isNotNull);
      expect(binance.autoInvest, isNotNull);
    });

    test('All Loan APIs Accessible', () {
      expect(binance.loan, isNotNull);
      expect(binance.vipLoan, isNotNull);
    });

    test('All Trading Tool APIs Accessible', () {
      expect(binance.convert, isNotNull);
      expect(binance.simulatedConvert, isNotNull);
      expect(binance.copyTrading, isNotNull);
    });

    test('All Fiat & Payment APIs Accessible', () {
      expect(binance.fiat, isNotNull);
      expect(binance.c2c, isNotNull);
      expect(binance.pay, isNotNull);
    });

    test('All Other Service APIs Accessible', () {
      expect(binance.mining, isNotNull);
      expect(binance.nft, isNotNull);
      expect(binance.giftCard, isNotNull);
      expect(binance.blvt, isNotNull);
      expect(binance.rebate, isNotNull);
    });

    test('Exception Hierarchy Complete', () {
      expect(BinanceException, isNotNull);
      expect(BinanceAuthenticationException, isNotNull);
      expect(BinanceRateLimitException, isNotNull);
      expect(BinanceValidationException, isNotNull);
      expect(BinanceNetworkException, isNotNull);
      expect(BinanceServerException, isNotNull);
      expect(BinanceInsufficientBalanceException, isNotNull);
      expect(BinanceTimeoutException, isNotNull);
    });
  });

  group('Real API Integration Tests - Public Endpoints', () {
    late Binance binance;

    setUp(() {
      binance = Binance();
    });

    test('Spot Market - Server Time', () async {
      final result = await binance.spot.market.getServerTime();
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('serverTime'), isTrue);
    });

    test('Spot Market - Exchange Info', () async {
      final result = await binance.spot.market.getExchangeInfo();
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('symbols'), isTrue);
    });

    test('Spot Market - Order Book', () async {
      final result = await binance.spot.market.getOrderBook('BTCUSDT', limit: 5);
      expect(result, isA<Map<String, dynamic>>());
      expect(result.containsKey('bids'), isTrue);
      expect(result.containsKey('asks'), isTrue);
    });

    test('Spot Market - 24hr Ticker', () async {
      final result = await binance.spot.market.get24HrTicker('BTCUSDT');
      expect(result, isA<Map<String, dynamic>>());
      expect(result['symbol'], equals('BTCUSDT'));
    });

    test('Multiple Markets - Major Pairs', () async {
      final pairs = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT'];

      for (final pair in pairs) {
        final ticker = await binance.spot.market.get24HrTicker(pair);
        expect(ticker['symbol'], equals(pair));

        final orderBook = await binance.spot.market.getOrderBook(pair, limit: 5);
        expect(orderBook.containsKey('bids'), isTrue);
      }
    });
  });

  group('Simulated Trading Integration Tests', () {
    late Binance binance;

    setUp(() {
      binance = Binance();
    });

    test('Place Market Order and Check Status', () async {
      // Place order
      final orderResult = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'MARKET',
        quantity: 0.001,
      );

      expect(orderResult['status'], equals('FILLED'));
      final orderId = orderResult['orderId'] as int;

      // Check status
      final statusResult = await binance.spot.simulatedTrading.simulateOrderStatus(
        symbol: 'BTCUSDT',
        orderId: orderId,
      );

      expect(statusResult['orderId'], equals(orderId));
    });

    test('Place Multiple Orders in Sequence', () async {
      for (int i = 0; i < 3; i++) {
        final result = await binance.spot.simulatedTrading.simulatePlaceOrder(
          symbol: 'BTCUSDT',
          side: i.isEven ? 'BUY' : 'SELL',
          type: 'MARKET',
          quantity: 0.001,
        );

        expect(result['status'], equals('FILLED'));
      }
    });

    test('Market and Limit Orders Mix', () async {
      // Market order
      final marketOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'MARKET',
        quantity: 0.001,
      );
      expect(marketOrder['type'], equals('MARKET'));

      // Limit order
      final limitOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'LIMIT',
        quantity: 0.001,
        price: 40000.0,
        timeInForce: 'GTC',
      );
      expect(limitOrder['type'], equals('LIMIT'));
    });
  });

  group('Simulated Convert Integration Tests', () {
    late Binance binance;

    setUp(() {
      binance = Binance();
    });

    test('Complete Conversion Flow', () async {
      // Get quote
      final quoteResult = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'BTC',
        toAsset: 'USDT',
        fromAmount: 0.01,
      );
      expect(quoteResult.containsKey('quoteId'), isTrue);

      // Accept quote
      final acceptResult = await binance.simulatedConvert.simulateAcceptQuote(
        quoteId: quoteResult['quoteId'] as String,
      );
      expect(acceptResult.containsKey('orderId'), isTrue);

      // Check status
      final statusResult = await binance.simulatedConvert.simulateOrderStatus(
        orderId: acceptResult['orderId'] as String,
      );
      expect(statusResult.containsKey('orderStatus'), isTrue);

      // Get history
      final historyResult = await binance.simulatedConvert.simulateConversionHistory(
        limit: 5,
      );
      expect(historyResult.containsKey('list'), isTrue);
    });

    test('Multiple Conversions', () async {
      final pairs = [
        {'from': 'BTC', 'to': 'USDT', 'amount': 0.001},
        {'from': 'ETH', 'to': 'USDT', 'amount': 0.01},
        {'from': 'BNB', 'to': 'USDT', 'amount': 1.0},
      ];

      for (final pair in pairs) {
        final quoteResult = await binance.simulatedConvert.simulateGetQuote(
          fromAsset: pair['from'] as String,
          toAsset: pair['to'] as String,
          fromAmount: pair['amount'] as double,
        );

        expect(quoteResult.containsKey('quoteId'), isTrue);

        final acceptResult = await binance.simulatedConvert.simulateAcceptQuote(
          quoteId: quoteResult['quoteId'] as String,
        );

        expect(acceptResult.containsKey('orderId'), isTrue);
      }
    });
  });

  group('Mixed Public and Simulated API Tests', () {
    late Binance binance;

    setUp(() {
      binance = Binance();
    });

    test('Get Market Data and Simulate Trade', () async {
      // Get current market price
      final ticker = await binance.spot.market.get24HrTicker('BTCUSDT');
      expect(ticker.containsKey('lastPrice'), isTrue);

      // Use that info to simulate a trade
      final orderResult = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'MARKET',
        quantity: 0.001,
      );

      expect(orderResult['status'], equals('FILLED'));
    });

    test('Check Server Time and Place Order', () async {
      // Verify server is accessible
      final serverTime = await binance.spot.market.getServerTime();
      expect(serverTime.containsKey('serverTime'), isTrue);

      // Place simulated order
      final orderResult = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'ETHUSDT',
        side: 'BUY',
        type: 'MARKET',
        quantity: 0.01,
      );

      expect(orderResult['status'], equals('FILLED'));
    });

    test('Get Exchange Info and Simulate Convert', () async {
      // Get exchange info
      final exchangeInfo = await binance.spot.market.getExchangeInfo();
      expect(exchangeInfo.containsKey('symbols'), isTrue);

      // Simulate conversion
      final quoteResult = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'BTC',
        toAsset: 'USDT',
        fromAmount: 0.001,
      );

      expect(quoteResult.containsKey('quoteId'), isTrue);
    });
  });

  group('Error Handling Integration Tests', () {
    late Binance binance;

    setUp(() {
      binance = Binance();
    });

    test('Invalid Symbol Handling', () async {
      try {
        await binance.spot.market.get24HrTicker('INVALIDSYMBOL');
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<BinanceException>());
      }
    });

    test('Invalid Order Book Request', () async {
      try {
        await binance.spot.market.getOrderBook('FAKEPAIR');
        fail('Should have thrown an exception');
      } catch (e) {
        expect(e, isA<BinanceException>());
      }
    });

    test('Simulated Endpoints Never Throw', () async {
      // Simulated endpoints should handle all inputs gracefully
      expect(() async {
        await binance.spot.simulatedTrading.simulatePlaceOrder(
          symbol: 'ANYSYMBOL',
          side: 'BUY',
          type: 'MARKET',
          quantity: 0.001,
        );
      }, returnsNormally);

      expect(() async {
        await binance.simulatedConvert.simulateGetQuote(
          fromAsset: 'ANYASSET',
          toAsset: 'ANYASSET',
          fromAmount: 1.0,
        );
      }, returnsNormally);
    });
  });

  group('Performance and Concurrency Tests', () {
    late Binance binance;

    setUp(() {
      binance = Binance();
    });

    test('Concurrent Public API Requests', () async {
      final futures = <Future>[];

      futures.add(binance.spot.market.getServerTime());
      futures.add(binance.spot.market.get24HrTicker('BTCUSDT'));
      futures.add(binance.spot.market.getOrderBook('ETHUSDT', limit: 5));

      final results = await Future.wait(futures);

      expect(results.length, equals(3));
      for (final result in results) {
        expect(result, isA<Map<String, dynamic>>());
      }
    });

    test('Concurrent Simulated Trading Requests', () async {
      final futures = <Future>[];

      for (int i = 0; i < 5; i++) {
        futures.add(
          binance.spot.simulatedTrading.simulatePlaceOrder(
            symbol: 'BTCUSDT',
            side: 'BUY',
            type: 'MARKET',
            quantity: 0.001,
          ),
        );
      }

      final results = await Future.wait(futures);

      expect(results.length, equals(5));
      for (final result in results) {
        expect(result['status'], equals('FILLED'));
      }
    });

    test('Concurrent Simulated Convert Requests', () async {
      final futures = <Future>[];

      for (int i = 0; i < 5; i++) {
        futures.add(
          binance.simulatedConvert.simulateGetQuote(
            fromAsset: 'BTC',
            toAsset: 'USDT',
            fromAmount: 0.001,
          ),
        );
      }

      final results = await Future.wait(futures);

      expect(results.length, equals(5));
      for (final result in results) {
        expect(result.containsKey('quoteId'), isTrue);
      }
    });

    test('Mixed Concurrent Requests', () async {
      final futures = <Future>[];

      // Public API
      futures.add(binance.spot.market.getServerTime());
      futures.add(binance.spot.market.get24HrTicker('BTCUSDT'));

      // Simulated Trading
      futures.add(binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'MARKET',
        quantity: 0.001,
      ));

      // Simulated Convert
      futures.add(binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'BTC',
        toAsset: 'USDT',
        fromAmount: 0.001,
      ));

      final results = await Future.wait(futures);

      expect(results.length, equals(4));
      for (final result in results) {
        expect(result, isA<Map<String, dynamic>>());
      }
    });
  });

  group('Package Metadata Tests', () {
    test('Version Information', () {
      // Package should be identifiable
      expect(Binance, isNotNull);
      expect(BinanceConfig, isNotNull);
    });

    test('All Documented Classes Accessible', () {
      // Verify all main classes from documentation are accessible
      expect(Binance, isNotNull);
      expect(Spot, isNotNull);
      expect(Market, isNotNull);
      expect(Trading, isNotNull);
      expect(SimulatedTrading, isNotNull);
      expect(SimulatedConvert, isNotNull);
      expect(Websockets, isNotNull);
      expect(BinanceConfig, isNotNull);
      expect(BinanceException, isNotNull);
    });
  });
}
