import 'package:test/test.dart';
import '../lib/utils/technical_indicators.dart';

void main() {
  group('TechnicalIndicators - SMA', () {
    test('calculates simple moving average correctly', () {
      final prices = [10.0, 20.0, 30.0, 40.0, 50.0];
      final sma = TechnicalIndicators.sma(prices, 3);

      expect(sma, equals(40.0)); // (30 + 40 + 50) / 3
    });

    test('returns 0 for insufficient data', () {
      final prices = [10.0, 20.0];
      final sma = TechnicalIndicators.sma(prices, 5);

      expect(sma, equals(0.0));
    });

    test('handles empty list', () {
      final prices = <double>[];
      final sma = TechnicalIndicators.sma(prices, 5);

      expect(sma, equals(0.0));
    });

    test('calculates with period of 1', () {
      final prices = [100.0];
      final sma = TechnicalIndicators.sma(prices, 1);

      expect(sma, equals(100.0));
    });
  });

  group('TechnicalIndicators - EMA', () {
    test('calculates exponential moving average', () {
      final prices = [10.0, 20.0, 30.0, 40.0, 50.0];
      final ema = TechnicalIndicators.ema(prices, 3);

      expect(ema, greaterThan(0));
      expect(ema, lessThanOrEqualTo(50.0));
    });

    test('returns last price for insufficient data', () {
      final prices = [10.0, 20.0];
      final ema = TechnicalIndicators.ema(prices, 5);

      expect(ema, equals(20.0));
    });

    test('handles single value', () {
      final prices = [100.0];
      final ema = TechnicalIndicators.ema(prices, 10);

      expect(ema, equals(100.0));
    });
  });

  group('TechnicalIndicators - RSI', () {
    test('calculates RSI for trending up prices', () {
      final prices = [10.0, 12.0, 14.0, 16.0, 18.0, 20.0, 22.0, 24.0, 26.0, 28.0, 30.0];
      final rsi = TechnicalIndicators.rsi(prices, 10);

      expect(rsi, greaterThan(50.0)); // Uptrend should have RSI > 50
      expect(rsi, lessThanOrEqualTo(100.0));
    });

    test('calculates RSI for trending down prices', () {
      final prices = [30.0, 28.0, 26.0, 24.0, 22.0, 20.0, 18.0, 16.0, 14.0, 12.0, 10.0];
      final rsi = TechnicalIndicators.rsi(prices, 10);

      expect(rsi, lessThan(50.0)); // Downtrend should have RSI < 50
      expect(rsi, greaterThanOrEqualTo(0.0));
    });

    test('returns 50 for insufficient data', () {
      final prices = [10.0, 20.0];
      final rsi = TechnicalIndicators.rsi(prices, 14);

      expect(rsi, equals(50.0));
    });

    test('returns 100 for all gains', () {
      final prices = List.generate(20, (i) => (i + 1).toDouble());
      final rsi = TechnicalIndicators.rsi(prices, 14);

      expect(rsi, equals(100.0));
    });
  });

  group('TechnicalIndicators - Bollinger Bands', () {
    test('calculates Bollinger Bands correctly', () {
      final prices = [10.0, 12.0, 11.0, 13.0, 12.0, 14.0, 13.0, 15.0, 14.0, 16.0];
      final bands = TechnicalIndicators.bollingerBands(prices, 5, 2.0);

      expect(bands['upper'], greaterThan(bands['middle']!));
      expect(bands['middle'], greaterThan(bands['lower']!));
      expect(bands['middle'], greaterThan(0));
    });

    test('handles insufficient data', () {
      final prices = [10.0, 20.0];
      final bands = TechnicalIndicators.bollingerBands(prices, 5, 2.0);

      expect(bands['upper'], equals(0));
      expect(bands['middle'], equals(0));
      expect(bands['lower'], equals(0));
    });

    test('bands widen with higher volatility', () {
      final lowVolPrices = [10.0, 10.1, 10.0, 10.1, 10.0];
      final highVolPrices = [10.0, 15.0, 10.0, 15.0, 10.0];

      final lowVolBands = TechnicalIndicators.bollingerBands(lowVolPrices, 5, 2.0);
      final highVolBands = TechnicalIndicators.bollingerBands(highVolPrices, 5, 2.0);

      final lowVolWidth = lowVolBands['upper']! - lowVolBands['lower']!;
      final highVolWidth = highVolBands['upper']! - highVolBands['lower']!;

      expect(highVolWidth, greaterThan(lowVolWidth));
    });
  });

  group('TechnicalIndicators - MACD', () {
    test('calculates MACD components', () {
      final prices = List.generate(30, (i) => 100.0 + i);
      final macd = TechnicalIndicators.macd(prices);

      expect(macd.containsKey('macd'), isTrue);
      expect(macd.containsKey('signal'), isTrue);
      expect(macd.containsKey('histogram'), isTrue);
    });

    test('returns zeros for insufficient data', () {
      final prices = [10.0, 20.0];
      final macd = TechnicalIndicators.macd(prices);

      expect(macd['macd'], equals(0));
      expect(macd['signal'], equals(0));
      expect(macd['histogram'], equals(0));
    });

    test('MACD is positive for uptrend', () {
      final prices = List.generate(30, (i) => 100.0 + i);
      final macd = TechnicalIndicators.macd(prices);

      expect(macd['macd'], greaterThan(0));
    });
  });

  group('TechnicalIndicators - Volatility', () {
    test('calculates volatility correctly', () {
      final prices = [10.0, 12.0, 11.0, 13.0, 12.0];
      final vol = TechnicalIndicators.volatility(prices, 5);

      expect(vol, greaterThan(0));
    });

    test('returns 0 for insufficient data', () {
      final prices = [10.0];
      final vol = TechnicalIndicators.volatility(prices, 5);

      expect(vol, equals(0));
    });

    test('higher volatility for wider price swings', () {
      final lowVol = [10.0, 10.1, 10.0, 10.1, 10.0];
      final highVol = [10.0, 15.0, 10.0, 15.0, 10.0];

      final lowVolValue = TechnicalIndicators.volatility(lowVol, 5);
      final highVolValue = TechnicalIndicators.volatility(highVol, 5);

      expect(highVolValue, greaterThan(lowVolValue));
    });
  });

  group('TechnicalIndicators - Support/Resistance', () {
    test('identifies support and resistance levels', () {
      final prices = [10.0, 15.0, 12.0, 18.0, 14.0];
      final levels = TechnicalIndicators.supportResistance(prices, 5);

      expect(levels['support'], equals(10.0));
      expect(levels['resistance'], equals(18.0));
    });

    test('handles insufficient data', () {
      final prices = [10.0];
      final levels = TechnicalIndicators.supportResistance(prices, 5);

      expect(levels['support'], equals(0));
      expect(levels['resistance'], equals(0));
    });
  });
}
