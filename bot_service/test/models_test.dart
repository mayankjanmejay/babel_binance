import 'package:test/test.dart';
import '../lib/models/watchlist_item.dart';
import '../lib/models/trade_signal.dart';
import '../lib/models/trade_record.dart';

void main() {
  group('WatchlistItem Model', () {
    test('creates from JSON correctly', () {
      final json = {
        '\$id': '123',
        'user_id': 'user1',
        'symbol': 'BTCUSDT',
        'target_buy': 90000.0,
        'target_sell': 100000.0,
        'active': true,
        'created_at': '2025-01-01T00:00:00Z',
      };

      final item = WatchlistItem.fromJson(json);

      expect(item.id, equals('123'));
      expect(item.userId, equals('user1'));
      expect(item.symbol, equals('BTCUSDT'));
      expect(item.targetBuy, equals(90000.0));
      expect(item.targetSell, equals(100000.0));
      expect(item.active, isTrue);
    });

    test('converts to JSON correctly', () {
      final item = WatchlistItem(
        id: '123',
        userId: 'user1',
        symbol: 'BTCUSDT',
        targetBuy: 90000.0,
        targetSell: 100000.0,
        active: true,
        createdAt: DateTime.parse('2025-01-01'),
      );

      final json = item.toJson();

      expect(json['user_id'], equals('user1'));
      expect(json['symbol'], equals('BTCUSDT'));
      expect(json['target_buy'], equals(90000.0));
      expect(json['target_sell'], equals(100000.0));
      expect(json['active'], isTrue);
    });

    test('handles optional target prices', () {
      final json = {
        '\$id': '123',
        'user_id': 'user1',
        'symbol': 'ETHUSDT',
        'active': true,
        'created_at': '2025-01-01T00:00:00Z',
      };

      final item = WatchlistItem.fromJson(json);

      expect(item.targetBuy, isNull);
      expect(item.targetSell, isNull);
    });
  });

  group('TradeSignal Model', () {
    test('creates buy signal correctly', () {
      final signal = TradeSignal(
        side: 'BUY',
        type: 'MARKET',
        quantity: 0.001,
        reason: 'Test reason',
        algorithmName: 'Test Algorithm',
        confidence: 0.8,
      );

      expect(signal.side, equals('BUY'));
      expect(signal.type, equals('MARKET'));
      expect(signal.quantity, equals(0.001));
      expect(signal.price, isNull);
      expect(signal.reason, equals('Test reason'));
      expect(signal.confidence, equals(0.8));
    });

    test('creates limit order signal with price', () {
      final signal = TradeSignal(
        side: 'SELL',
        type: 'LIMIT',
        quantity: 0.001,
        price: 95000.0,
        timeInForce: 'GTC',
        reason: 'Limit order',
        algorithmName: 'Grid Trading',
      );

      expect(signal.type, equals('LIMIT'));
      expect(signal.price, equals(95000.0));
      expect(signal.timeInForce, equals('GTC'));
    });

    test('toString provides readable format', () {
      final signal = TradeSignal(
        side: 'BUY',
        type: 'MARKET',
        quantity: 0.001,
        reason: 'Test',
        algorithmName: 'SMA',
      );

      final str = signal.toString();
      expect(str, contains('BUY'));
      expect(str, contains('0.001'));
      expect(str, contains('MARKET'));
    });
  });

  group('TradeRecord Model', () {
    test('creates from JSON correctly', () {
      final json = {
        '\$id': 'trade123',
        'user_id': 'user1',
        'symbol': 'BTCUSDT',
        'side': 'BUY',
        'quantity': 0.001,
        'price': 95000.0,
        'total_value': 95.0,
        'timestamp': '2025-01-01T12:00:00Z',
        'algorithm_name': 'SMA Crossover',
        'order_id': 'order123',
        'status': 'FILLED',
      };

      final trade = TradeRecord.fromJson(json);

      expect(trade.id, equals('trade123'));
      expect(trade.userId, equals('user1'));
      expect(trade.symbol, equals('BTCUSDT'));
      expect(trade.side, equals('BUY'));
      expect(trade.quantity, equals(0.001));
      expect(trade.price, equals(95000.0));
      expect(trade.totalValue, equals(95.0));
      expect(trade.algorithmName, equals('SMA Crossover'));
      expect(trade.orderId, equals('order123'));
      expect(trade.status, equals('FILLED'));
    });

    test('converts to JSON correctly', () {
      final trade = TradeRecord(
        userId: 'user1',
        symbol: 'ETHUSDT',
        side: 'SELL',
        quantity: 0.01,
        price: 3500.0,
        totalValue: 35.0,
        timestamp: DateTime.parse('2025-01-01'),
        algorithmName: 'RSI Strategy',
        orderId: 'order456',
        status: 'SUCCESS',
      );

      final json = trade.toJson();

      expect(json['user_id'], equals('user1'));
      expect(json['symbol'], equals('ETHUSDT'));
      expect(json['side'], equals('SELL'));
      expect(json['quantity'], equals(0.01));
      expect(json['price'], equals(3500.0));
      expect(json['total_value'], equals(35.0));
      expect(json['algorithm_name'], equals('RSI Strategy'));
      expect(json['status'], equals('SUCCESS'));
    });

    test('handles optional order_id', () {
      final trade = TradeRecord(
        userId: 'user1',
        symbol: 'BTCUSDT',
        side: 'BUY',
        quantity: 0.001,
        price: 95000.0,
        totalValue: 95.0,
        timestamp: DateTime.now(),
        algorithmName: 'Test',
      );

      expect(trade.orderId, isNull);
    });
  });
}
