
/// 🚀 Babel Binance Complete Showcase
/// 
/// This example demonstrates the full power and versatility of the Babel Binance
/// package, showcasing everything from basic market data to advanced trading
/// simulations and real-time WebSocket streams.
/// 
/// Perfect for developers who want to see what's possible with this package!

import 'dart:io';
import 'package:babel_binance/babel_binance.dart';

void main() async {
  print('🌟 Welcome to Babel Binance - Complete Showcase');
  print('=' * 60);
  
  final binance = Binance();
  
  // 📊 Section 1: Market Data Excellence
  await demonstrateMarketData(binance);
  
  // 🎯 Section 2: Simulated Trading Power
  await demonstrateSimulatedTrading(binance);
  
  // 💱 Section 3: Currency Conversion Magic
  await demonstrateCurrencyConversion(binance);
  
  // ⚡ Section 4: Real-time WebSocket Streams
  await demonstrateWebSocketPower(binance);
  
  // 📈 Section 5: Performance Analysis
  await demonstratePerformanceAnalysis(binance);
  
  print('\n🎉 Showcase Complete! Ready to build something amazing?');
  print('📚 Check out more examples at: https://pub.dev/packages/babel_binance');
}

/// 📊 Demonstrate comprehensive market data capabilities
Future<void> demonstrateMarketData(Binance binance) async {
  print('\n📊 SECTION 1: Market Data Excellence');
  print('-' * 40);
  
  try {
    // Get server time for perfect synchronization
    final serverTime = await binance.spot.market.getServerTime();
    final serverDateTime = DateTime.fromMillisecondsSinceEpoch(serverTime['serverTime']);
    print('🕐 Binance Server Time: ${serverDateTime.toUtc()}');
    
    // Fetch comprehensive exchange information
    final exchangeInfo = await binance.spot.market.getExchangeInfo();
    final symbolCount = exchangeInfo['symbols'].length;
    print('💰 Available Trading Pairs: $symbolCount');
    
    // Get top cryptocurrencies by volume
    final top5Symbols = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'ADAUSDT', 'SOLUSDT'];
    print('\n🔥 Top Cryptocurrency Prices:');
    
    for (final symbol in top5Symbols) {
      final ticker = await binance.spot.market.get24HrTicker(symbol);
      final price = double.parse(ticker['lastPrice']);
      final change = double.parse(ticker['priceChangePercent']);
      final emoji = change >= 0 ? '📈' : '📉';
      
      print('   $emoji ${symbol.replaceAll('USDT', '')}: \$${price.toStringAsFixed(2)} '
            '(${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%)');
      
      // Add small delay to avoid rate limiting
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    // Demonstrate order book depth
    final orderBook = await binance.spot.market.getOrderBook('BTCUSDT', limit: 5);
    final bestBid = double.parse(orderBook['bids'][0][0]);
    final bestAsk = double.parse(orderBook['asks'][0][0]);
    final spread = ((bestAsk - bestBid) / bestBid * 100);
    
    print('\n📖 BTC/USDT Order Book Analysis:');
    print('   💵 Best Bid: \$${bestBid.toStringAsFixed(2)}');
    print('   💶 Best Ask: \$${bestAsk.toStringAsFixed(2)}');
    print('   📏 Spread: ${spread.toStringAsFixed(4)}%');
    
  } catch (e) {
    print('❌ Market data error: $e');
  }
}

/// 🎯 Demonstrate advanced simulated trading capabilities
Future<void> demonstrateSimulatedTrading(Binance binance) async {
  print('\n🎯 SECTION 2: Simulated Trading Power');
  print('-' * 40);
  
  try {
    print('🚀 Launching Trading Strategy Simulation...');
    
    // Simulate a sophisticated trading strategy
    final portfolio = <String, double>{
      'USDT': 10000.0, // Starting with $10,000
      'BTC': 0.0,
      'ETH': 0.0,
    };
    
    print('💰 Initial Portfolio: \$${portfolio['USDT']!.toStringAsFixed(2)} USDT');
    
    // Strategy 1: Dollar Cost Averaging into Bitcoin
    print('\n📊 Strategy 1: Dollar Cost Averaging (DCA)');
    final dcaAmount = 1000.0;
    
    for (int i = 1; i <= 3; i++) {
      final buyOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'MARKET',
        quoteOrderQty: dcaAmount,
      );
      
      final btcBought = double.parse(buyOrder['executedQty']);
      final usdtSpent = double.parse(buyOrder['cummulativeQuoteQty']);
      
      portfolio['USDT'] = portfolio['USDT']! - usdtSpent;
      portfolio['BTC'] = portfolio['BTC']! + btcBought;
      
      print('   📅 DCA Round $i: Bought ${btcBought.toStringAsFixed(6)} BTC for \$${usdtSpent.toStringAsFixed(2)}');
      
      await Future.delayed(Duration(seconds: 1));
    }
    
    // Strategy 2: Limit Order Ladder
    print('\n🎯 Strategy 2: Limit Order Ladder');
    final currentPrice = 95000.0; // Simulate current BTC price
    
    for (int i = 1; i <= 3; i++) {
      final orderPrice = currentPrice * (1 - (i * 0.02)); // 2% intervals below market
      final limitOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'LIMIT',
        quantity: 0.01,
        price: orderPrice,
        timeInForce: 'GTC',
      );
      
      print('   📋 Limit Order $i: ${limitOrder['side']} ${limitOrder['origQty']} BTC @ \$${orderPrice.toStringAsFixed(2)}');
    }
    
    // Portfolio summary
    print('\n💼 Portfolio Summary:');
    print('   💵 USDT: \$${portfolio['USDT']!.toStringAsFixed(2)}');
    print('   ₿  BTC: ${portfolio['BTC']!.toStringAsFixed(6)}');
    print('   📈 Total Value: ~\$${(portfolio['USDT']! + (portfolio['BTC']! * currentPrice)).toStringAsFixed(2)}');
    
  } catch (e) {
    print('❌ Trading simulation error: $e');
  }
}

/// 💱 Demonstrate currency conversion capabilities
Future<void> demonstrateCurrencyConversion(Binance binance) async {
  print('\n💱 SECTION 3: Currency Conversion Magic');
  print('-' * 40);
  
  try {
    print('🔄 Demonstrating Multi-Asset Conversion Flow...');
    
    // Conversion scenario: ETH → BTC → USDT
    final conversions = [
      {'from': 'ETH', 'to': 'BTC', 'amount': 2.0},
      {'from': 'BTC', 'to': 'USDT', 'amount': 0.05},
      {'from': 'USDT', 'to': 'BNB', 'amount': 1000.0},
    ];
    
    for (final conversion in conversions) {
      print('\n🎯 Converting ${conversion['amount']} ${conversion['from']} → ${conversion['to']}');
        // Get quote
      final quote = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: conversion['from']! as String,
        toAsset: conversion['to']! as String,
        fromAmount: conversion['amount'] as double,
      );
      
      print('   📋 Quote ID: ${quote['quoteId']}');
      print('   💹 Exchange Rate: ${quote['ratio']}');
      print('   💰 You will receive: ${quote['toAmount']} ${conversion['to']}');
      
      // Execute conversion
      await Future.delayed(Duration(milliseconds: 500));
      
      final result = await binance.simulatedConvert.simulateAcceptQuote(
        quoteId: quote['quoteId'],
      );
      
      if (result['status'] == 'SUCCESS') {
        print('   ✅ Conversion completed successfully!');
        print('   📦 Transaction ID: ${result['tranId']}');
      } else {
        print('   ⚠️  Conversion failed: ${result['status']}');
      }
      
      await Future.delayed(Duration(seconds: 1));
    }
      // Conversion history simulation
    print('\n📊 Recent Conversion History:');
    final historyResponse = await binance.simulatedConvert.simulateConversionHistory(
      limit: 1,
    );
    final history = historyResponse['list'].isNotEmpty ? historyResponse['list'][0] : null;
    
    if (history != null) {
      print('   📅 Date: ${DateTime.fromMillisecondsSinceEpoch(history['createTime'])}');
      print('   🔄 ${history['fromAsset']} → ${history['toAsset']}');
      print('   💰 Amount: ${history['fromAmount']} → ${history['toAmount']}');
      print('   ✅ Status: ${history['orderStatus']}');
    } else {
      print('   📭 No conversion history available');
    }
    
  } catch (e) {
    print('❌ Conversion error: $e');
  }
}

/// ⚡ Demonstrate real-time WebSocket capabilities
Future<void> demonstrateWebSocketPower(Binance binance) async {
  print('\n⚡ SECTION 4: Real-time WebSocket Streams');
  print('-' * 40);
  
  print('🔌 WebSocket capabilities available:');
  print('   📊 Real-time price streams');
  print('   📖 Order book updates');
  print('   📈 Kline/Candlestick data');
  print('   👤 User data streams (with API key)');
  print('   🎯 Trade execution updates');
  
  // Note: In a real application, you would set up WebSocket listeners here
  print('\n💡 To use WebSocket features:');
  print('   1. Set your API keys: export BINANCE_API_KEY=your_key');
  print('   2. Call: binance.webSocket.subscribeTo...()');
  print('   3. Handle real-time data in your callbacks');
  
  print('\n📱 Example WebSocket Usage:');
  print('''
// Real-time price updates
binance.webSocket.subscribeToTicker('btcusdt', (data) {
  print('BTC Price Update: \$\${data['c']}');
});

// Order book depth updates  
binance.webSocket.subscribeToDepth('btcusdt', (data) {
  print('Order book updated with \${data['b'].length} bids');
});
  ''');
}

/// 📈 Demonstrate performance analysis capabilities
Future<void> demonstratePerformanceAnalysis(Binance binance) async {
  print('\n📈 SECTION 5: Performance Analysis');
  print('-' * 40);
  
  try {
    print('⏱️  Measuring API Performance...');
    
    final stopwatch = Stopwatch()..start();
    final operations = <String, int>{};
    
    // Test market data performance
    final marketStart = stopwatch.elapsedMilliseconds;
    await binance.spot.market.get24HrTicker('BTCUSDT');
    operations['Market Data'] = stopwatch.elapsedMilliseconds - marketStart;
    
    // Test simulated trading performance
    final tradingStart = stopwatch.elapsedMilliseconds;
    await binance.spot.simulatedTrading.simulatePlaceOrder(
      symbol: 'BTCUSDT',
      side: 'BUY',
      type: 'MARKET',
      quantity: 0.001,
    );
    operations['Simulated Trading'] = stopwatch.elapsedMilliseconds - tradingStart;
    
    // Test conversion performance
    final conversionStart = stopwatch.elapsedMilliseconds;
    await binance.simulatedConvert.simulateGetQuote(
      fromAsset: 'ETH',
      toAsset: 'BTC',
      fromAmount: 1.0,
    );
    operations['Currency Conversion'] = stopwatch.elapsedMilliseconds - conversionStart;
    
    stopwatch.stop();
    
    print('\n📊 Performance Results:');
    operations.forEach((operation, time) {
      final emoji = time < 100 ? '🚀' : time < 500 ? '⚡' : '🔄';
      print('   $emoji $operation: ${time}ms');
    });
    
    print('\n🎯 Performance Summary:');
    final avgTime = operations.values.reduce((a, b) => a + b) / operations.length;
    print('   📊 Average response time: ${avgTime.toStringAsFixed(1)}ms');
    print('   🔥 Operations per second: ~${(1000 / avgTime).toStringAsFixed(1)}');
    
    // System information
    print('\n💻 System Information:');
    print('   🖥️  Platform: ${Platform.operatingSystem}');
    print('   📦 Dart Version: ${Platform.version}');
    print('   🌐 Timezone: ${DateTime.now().timeZoneName}');
    
  } catch (e) {
    print('❌ Performance analysis error: $e');
  }
}
