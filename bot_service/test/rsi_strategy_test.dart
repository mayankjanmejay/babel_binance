import 'package:test/test.dart';
import '../lib/algorithms/rsi_strategy.dart';
import '../lib/models/trade_signal.dart';

void main() {
  group('RSIStrategy Algorithm', () {
    late RSIStrategy algorithm;

    setUp(() {
      algorithm = RSIStrategy(
        period: 14,
        oversold: 30.0,
        overbought: 70.0,
        quantity: 0.001,
      );
    });

    test('initializes with correct parameters', () {
      expect(algorithm.name, equals('RSI Strategy'));
      expect(algorithm.params['period'], equals(14));
      expect(algorithm.params['oversold'], equals(30.0));
      expect(algorithm.params['overbought'], equals(70.0));
      expect(algorithm.params['quantity'], equals(0.001));
    });

    test('returns null for insufficient data', () async {
      // Need at least period + 1 prices
      for (int i = 0; i < 10; i++) {
        final signal = await algorithm.analyze('BTCUSDT', 100.0);
        expect(signal, isNull);
      }
    });

    test('generates buy signal when oversold', () async {
      // Create strong downtrend (RSI will be low)
      final prices = [
        100.0, 98.0, 96.0, 94.0, 92.0,
        90.0, 88.0, 86.0, 84.0, 82.0,
        80.0, 78.0, 76.0, 74.0, 72.0,
        70.0,
      ];

      TradeSignal? signal;
      for (final price in prices) {
        signal = await algorithm.analyze('BTCUSDT', price);
      }

      expect(signal, isNotNull);
      if (signal != null) {
        expect(signal.side, equals('BUY'));
        expect(signal.type, equals('MARKET'));
        expect(signal.quantity, equals(0.001));
        expect(signal.reason, contains('oversold'));
        expect(signal.confidence, greaterThan(0));
      }
    });

    test('generates sell signal when overbought', () async {
      // Create strong uptrend (RSI will be high)
      final prices = [
        70.0, 72.0, 74.0, 76.0, 78.0,
        80.0, 82.0, 84.0, 86.0, 88.0,
        90.0, 92.0, 94.0, 96.0, 98.0,
        100.0,
      ];

      TradeSignal? signal;
      for (final price in prices) {
        signal = await algorithm.analyze('BTCUSDT', price);
      }

      expect(signal, isNotNull);
      if (signal != null) {
        expect(signal.side, equals('SELL'));
        expect(signal.reason, contains('overbought'));
      }
    });

    test('returns null when RSI is in neutral zone', () async {
      // Stable prices should give RSI around 50
      final prices = List.generate(20, (_) => 100.0);

      TradeSignal? signal;
      for (final price in prices) {
        signal = await algorithm.analyze('BTCUSDT', price);
      }

      expect(signal, isNull);
    });

    test('calculates confidence based on RSI extremity', () async {
      // Extreme oversold
      final extremePrices = [
        100.0, 90.0, 80.0, 70.0, 60.0,
        50.0, 40.0, 30.0, 20.0, 10.0,
        5.0, 4.0, 3.0, 2.0, 1.0, 0.5,
      ];

      TradeSignal? signal;
      for (final price in extremePrices) {
        signal = await algorithm.analyze('BTCUSDT', price);
      }

      expect(signal, isNotNull);
      if (signal != null) {
        expect(signal.confidence, greaterThan(0.3));
        expect(signal.confidence, lessThanOrEqualTo(0.9));
      }
    });

    test('works with different oversold/overbought levels', () {
      final aggressive = RSIStrategy(
        oversold: 20.0,  // More aggressive
        overbought: 80.0,
      );

      expect(aggressive.params['oversold'], equals(20.0));
      expect(aggressive.params['overbought'], equals(80.0));
    });
  });
}
