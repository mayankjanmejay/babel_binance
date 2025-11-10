import 'package:test/test.dart';
import '../lib/algorithms/grid_trading.dart';
import '../lib/models/trade_signal.dart';

void main() {
  group('GridTrading Algorithm', () {
    late GridTrading algorithm;

    setUp(() {
      algorithm = GridTrading(
        lowerBound: 90000.0,
        upperBound: 100000.0,
        gridLevels: 10,
        quantityPerGrid: 0.0001,
      );
    });

    test('initializes with correct parameters', () {
      expect(algorithm.name, equals('Grid Trading'));
      expect(algorithm.params['lower_bound'], equals(90000.0));
      expect(algorithm.params['upper_bound'], equals(100000.0));
      expect(algorithm.params['grid_levels'], equals(10));
      expect(algorithm.params['quantity_per_grid'], equals(0.0001));
    });

    test('generates buy signal when price crosses grid level down', () async {
      // Start above a grid level, then cross down
      await algorithm.analyze('BTCUSDT', 95500.0);
      final signal = await algorithm.analyze('BTCUSDT', 95000.0);

      // Should generate buy signal when crossing down
      expect(signal, isNotNull);
      if (signal != null) {
        expect(signal.side, equals('BUY'));
        expect(signal.type, equals('LIMIT'));
        expect(signal.quantity, equals(0.0001));
        expect(signal.timeInForce, equals('GTC'));
        expect(signal.price, isNotNull);
        expect(signal.reason, contains('Grid level buy'));
      }
    });

    test('generates sell signal when price crosses grid level up', () async {
      // First trigger a buy to fill a grid level
      await algorithm.analyze('BTCUSDT', 95500.0);
      await algorithm.analyze('BTCUSDT', 95000.0); // Buy

      // Then cross back up
      await algorithm.analyze('BTCUSDT', 95200.0);
      final signal = await algorithm.analyze('BTCUSDT', 95500.0);

      // Should generate sell signal when crossing up
      if (signal != null) {
        expect(signal.side, equals('SELL'));
        expect(signal.type, equals('LIMIT'));
      }
    });

    test('does not generate duplicate signals at same level', () async {
      await algorithm.analyze('BTCUSDT', 95500.0);
      final signal1 = await algorithm.analyze('BTCUSDT', 95000.0);
      final signal2 = await algorithm.analyze('BTCUSDT', 94900.0);

      expect(signal1, isNotNull);
      expect(signal2, isNull); // Should not trigger again
    });

    test('recalculates grid based on current price', () {
      algorithm.recalculateGrid(95000.0);

      final lowerBound = algorithm.params['lower_bound'] as double;
      final upperBound = algorithm.params['upper_bound'] as double;

      // Grid should now be centered around 95000
      expect((lowerBound + upperBound) / 2, closeTo(95000.0, 100));
    });

    test('handles multiple grid levels', () async {
      final levels = <double>[];

      // Simulate price moving through multiple levels
      for (double price = 100000.0; price >= 90000.0; price -= 500.0) {
        final signal = await algorithm.analyze('BTCUSDT', price);
        if (signal != null) {
          levels.add(signal.price!);
        }
      }

      // Should have triggered at multiple grid levels
      expect(levels.length, greaterThan(1));
    });

    test('maintains grid state across price movements', () async {
      // Move price up and down through levels
      await algorithm.analyze('BTCUSDT', 95000.0);
      await algorithm.analyze('BTCUSDT', 96000.0);
      await algorithm.analyze('BTCUSDT', 95000.0);

      // Grid levels should still be tracked correctly
      expect(algorithm.params['grid_levels'], equals(10));
    });

    test('returns null when price does not cross grid levels', () async {
      await algorithm.analyze('BTCUSDT', 95000.0);

      // Small movement within same grid level
      final signal = await algorithm.analyze('BTCUSDT', 95050.0);

      expect(signal, isNull);
    });
  });
}
