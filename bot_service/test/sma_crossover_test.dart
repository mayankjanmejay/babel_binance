import 'package:test/test.dart';
import '../lib/algorithms/sma_crossover.dart';
import '../lib/models/trade_signal.dart';

void main() {
  group('SMACrossover Algorithm', () {
    late SMACrossover algorithm;

    setUp(() {
      algorithm = SMACrossover(
        shortPeriod: 5,
        longPeriod: 10,
        quantity: 0.001,
      );
    });

    test('initializes with correct parameters', () {
      expect(algorithm.name, equals('SMA Crossover'));
      expect(algorithm.params['short_period'], equals(5));
      expect(algorithm.params['long_period'], equals(10));
      expect(algorithm.params['quantity'], equals(0.001));
      expect(algorithm.active, isTrue);
    });

    test('returns null for insufficient data', () async {
      // Not enough prices for long period
      for (int i = 0; i < 5; i++) {
        final signal = await algorithm.analyze('BTCUSDT', 100.0 + i);
        expect(signal, isNull);
      }
    });

    test('detects bullish crossover', () async {
      // Add prices where short MA will cross above long MA
      final prices = [
        90.0, 91.0, 92.0, 93.0, 94.0,  // Trending up slowly
        95.0, 96.0, 97.0, 98.0, 99.0,
        100.0, 105.0, 110.0, 115.0, 120.0,  // Sharp rise
      ];

      TradeSignal? lastSignal;
      for (final price in prices) {
        lastSignal = await algorithm.analyze('BTCUSDT', price);
      }

      // Should generate buy signal on bullish crossover
      expect(lastSignal, isNotNull);
      if (lastSignal != null) {
        expect(lastSignal.side, equals('BUY'));
        expect(lastSignal.type, equals('MARKET'));
        expect(lastSignal.quantity, equals(0.001));
        expect(lastSignal.algorithmName, equals('SMA Crossover'));
        expect(lastSignal.reason, contains('bullish crossover'));
      }
    });

    test('detects bearish crossover', () async {
      // Uptrend first, then downtrend
      final uptrend = List.generate(15, (i) => 100.0 + i);
      for (final price in uptrend) {
        await algorithm.analyze('BTCUSDT', price);
      }

      // Then sharp decline
      final downtrend = [115.0, 110.0, 105.0, 100.0, 95.0, 90.0, 85.0];
      TradeSignal? lastSignal;
      for (final price in downtrend) {
        lastSignal = await algorithm.analyze('BTCUSDT', price);
      }

      // Should generate sell signal on bearish crossover
      expect(lastSignal, isNotNull);
      if (lastSignal != null) {
        expect(lastSignal.side, equals('SELL'));
        expect(lastSignal.reason, contains('bearish crossover'));
      }
    });

    test('maintains separate price history per symbol', () async {
      await algorithm.analyze('BTCUSDT', 100.0);
      await algorithm.analyze('ETHUSDT', 200.0);

      final btcHistory = algorithm.getPriceHistory('BTCUSDT');
      final ethHistory = algorithm.getPriceHistory('ETHUSDT');

      expect(btcHistory, contains(100.0));
      expect(ethHistory, contains(200.0));
      expect(btcHistory, isNot(contains(200.0)));
    });

    test('limits price history to 200 entries', () async {
      for (int i = 0; i < 250; i++) {
        await algorithm.analyze('BTCUSDT', 100.0 + i);
      }

      final history = algorithm.getPriceHistory('BTCUSDT');
      expect(history.length, lessThanOrEqualTo(200));
    });

    test('can be disabled', () {
      algorithm.active = false;
      expect(algorithm.active, isFalse);
    });

    test('clears history', () async {
      await algorithm.analyze('BTCUSDT', 100.0);
      algorithm.clearHistory();

      final history = algorithm.getPriceHistory('BTCUSDT');
      expect(history, isEmpty);
    });
  });
}
