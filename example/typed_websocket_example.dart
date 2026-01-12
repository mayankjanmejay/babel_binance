// Example demonstrating typed WebSocket streams with multi-symbol support
//
// This example shows how to:
// - Subscribe to real-time price updates for multiple symbols
// - Use typed event classes for type-safe access to market data
// - Handle candlestick/kline data with closed candle detection
// - Receive aggregate trade data for tick-level analysis
//
// Run with: dart run example/typed_websocket_example.dart

import 'dart:async';
import 'package:babel_binance/babel_binance.dart';

void main() async {
  print('═══════════════════════════════════════════════════════════════');
  print('  Typed WebSocket Streams Demo');
  print('═══════════════════════════════════════════════════════════════\n');

  // Create Binance instance (no API keys needed for public WebSocket streams)
  final binance = Binance();

  // Subscriptions to cancel later
  final subscriptions = <StreamSubscription>[];

  try {
    // ════════════════════════════════════════════════════════════════════════
    // DEMO 1: Multi-symbol price stream
    // ════════════════════════════════════════════════════════════════════════
    print('📊 Starting multi-symbol price stream...');
    print('   Watching: BTCUSDT, ETHUSDT, SOLUSDT\n');

    int priceUpdateCount = 0;
    final priceSubscription =
        binance.priceStream(['BTCUSDT', 'ETHUSDT', 'SOLUSDT']).listen((event) {
      priceUpdateCount++;
      print(
          '  [Price] ${event.symbol}: \$${event.close.toStringAsFixed(2)} '
          '(Vol: ${_formatVolume(event.baseVolume)})');

      // Show summary after 5 updates
      if (priceUpdateCount >= 5) {
        print('\n  ✅ Received $priceUpdateCount price updates\n');
      }
    });
    subscriptions.add(priceSubscription);

    // Wait for some price updates
    await Future.delayed(const Duration(seconds: 8));

    // ════════════════════════════════════════════════════════════════════════
    // DEMO 2: Candlestick/Kline stream
    // ════════════════════════════════════════════════════════════════════════
    print('🕯️  Starting candlestick stream (1m interval)...');
    print('   Watching: BTCUSDT\n');

    int klineCount = 0;
    final klineSubscription =
        binance.candleStream(['BTCUSDT'], '1m').listen((event) {
      klineCount++;
      final status = event.isClosed ? '✓ CLOSED' : '  updating';
      print('  [Kline] ${event.symbol} $status: '
          'O=${event.open.toStringAsFixed(2)} '
          'H=${event.high.toStringAsFixed(2)} '
          'L=${event.low.toStringAsFixed(2)} '
          'C=${event.close.toStringAsFixed(2)}');

      if (klineCount >= 3) {
        print('\n  ✅ Received $klineCount kline updates\n');
      }
    });
    subscriptions.add(klineSubscription);

    // Wait for some kline updates
    await Future.delayed(const Duration(seconds: 5));

    // ════════════════════════════════════════════════════════════════════════
    // DEMO 3: Aggregate trade stream
    // ════════════════════════════════════════════════════════════════════════
    print('💹 Starting aggregate trade stream...');
    print('   Watching: BTCUSDT\n');

    int tradeCount = 0;
    final tradeSubscription = binance.tradeStream(['BTCUSDT']).listen((event) {
      tradeCount++;
      final side = event.isBuyerMaker ? 'SELL' : 'BUY ';
      print('  [Trade] ${event.symbol} $side: '
          '${event.quantity.toStringAsFixed(5)} @ \$${event.price.toStringAsFixed(2)}');

      if (tradeCount >= 10) {
        print('\n  ✅ Received $tradeCount trade updates\n');
      }
    });
    subscriptions.add(tradeSubscription);

    // Wait for some trades
    await Future.delayed(const Duration(seconds: 5));

    // ════════════════════════════════════════════════════════════════════════
    // DEMO 4: Book ticker stream (best bid/ask)
    // ════════════════════════════════════════════════════════════════════════
    print('📖 Starting book ticker stream...');
    print('   Watching: BTCUSDT, ETHUSDT\n');

    int bookCount = 0;
    final bookSubscription =
        binance.bookTickerStream(['BTCUSDT', 'ETHUSDT']).listen((event) {
      bookCount++;
      final spread = event.bestAskPrice - event.bestBidPrice;
      print('  [Book] ${event.symbol}: '
          'Bid=\$${event.bestBidPrice.toStringAsFixed(2)} '
          'Ask=\$${event.bestAskPrice.toStringAsFixed(2)} '
          'Spread=\$${spread.toStringAsFixed(2)}');

      if (bookCount >= 6) {
        print('\n  ✅ Received $bookCount book ticker updates\n');
      }
    });
    subscriptions.add(bookSubscription);

    // Wait for book updates
    await Future.delayed(const Duration(seconds: 5));

    // ════════════════════════════════════════════════════════════════════════
    // Summary
    // ════════════════════════════════════════════════════════════════════════
    print('═══════════════════════════════════════════════════════════════');
    print('  Demo Complete!');
    print('═══════════════════════════════════════════════════════════════');
    print('  Total updates received:');
    print('    - Price updates: $priceUpdateCount');
    print('    - Kline updates: $klineCount');
    print('    - Trade updates: $tradeCount');
    print('    - Book updates: $bookCount');
    print('═══════════════════════════════════════════════════════════════\n');
  } catch (e, stack) {
    print('❌ Error: $e');
    print(stack);
  } finally {
    // Cancel all subscriptions
    print('Cleaning up subscriptions...');
    for (final sub in subscriptions) {
      await sub.cancel();
    }

    // Dispose binance client
    await binance.dispose();
    print('Done!');
  }
}

/// Format volume for display
String _formatVolume(double volume) {
  if (volume >= 1000000) {
    return '${(volume / 1000000).toStringAsFixed(2)}M';
  } else if (volume >= 1000) {
    return '${(volume / 1000).toStringAsFixed(2)}K';
  }
  return volume.toStringAsFixed(2);
}
