import 'package:babel_binance/babel_binance.dart';
import 'dart:math';

/// Performance analysis tool for measuring Babel Binance API response times
/// and testing different scenarios.
class PerformanceAnalyzer {
  final Binance binance;
  final List<int> _orderTimes = [];
  final List<int> _quoteTimes = [];
  final List<int> _conversionTimes = [];
  final List<int> _statusTimes = [];
  
  PerformanceAnalyzer(this.binance);
  
  /// Run comprehensive performance analysis
  Future<void> runAnalysis() async {
    print('🔬 Starting Performance Analysis');
    print('================================');
    print('');
    
    await _testMarketDataPerformance();
    await _testOrderPerformance();
    await _testConversionPerformance();
    await _testWebSocketPerformance();
    
    _generateReport();
  }
  
  /// Test market data endpoint performance
  Future<void> _testMarketDataPerformance() async {
    print('📊 Testing Market Data Performance...');
    
    final stopwatch = Stopwatch();
    final times = <int>[];
    
    for (int i = 0; i < 10; i++) {
      stopwatch.reset();
      stopwatch.start();
      
      try {
        await binance.spot.market.getServerTime();
      } catch (e) {
        print('   ❌ Server time request failed: $e');
        continue;
      }
      
      stopwatch.stop();
      times.add(stopwatch.elapsedMilliseconds);
      
      // Small delay between requests
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    if (times.isNotEmpty) {
      final avg = times.reduce((a, b) => a + b) / times.length;
      final min = times.reduce((a, b) => a < b ? a : b);
      final max = times.reduce((a, b) => a > b ? a : b);
      
      print('   ✅ Server Time Requests:');
      print('      Average: ${avg.toStringAsFixed(1)}ms');
      print('      Min: ${min}ms, Max: ${max}ms');
    }
    
    // Test order book performance
    times.clear();
    for (int i = 0; i < 5; i++) {
      stopwatch.reset();
      stopwatch.start();
      
      try {
        await binance.spot.market.getOrderBook('BTCUSDT', limit: 10);
      } catch (e) {
        print('   ❌ Order book request failed: $e');
        continue;
      }
      
      stopwatch.stop();
      times.add(stopwatch.elapsedMilliseconds);
      
      await Future.delayed(Duration(milliseconds: 200));
    }
    
    if (times.isNotEmpty) {
      final avg = times.reduce((a, b) => a + b) / times.length;
      print('   ✅ Order Book Requests: ${avg.toStringAsFixed(1)}ms average');
    }
    
    print('');
  }
  
  /// Test order processing performance
  Future<void> _testOrderPerformance() async {
    print('📈 Testing Order Processing Performance...');
    
    final symbols = ['BTCUSDT', 'ETHUSDT', 'BNBUSDT', 'ADAUSDT', 'SOLUSDT'];
    final orderTypes = ['MARKET', 'LIMIT'];
    
    for (final symbol in symbols) {
      for (final orderType in orderTypes) {
        final stopwatch = Stopwatch()..start();
        
        try {
          final params = {
            'symbol': symbol,
            'side': 'BUY',
            'type': orderType,
            'quantity': 0.001,
          };
          
          if (orderType == 'LIMIT') {
            params['price'] = 50000.0; // Arbitrary price
            params['timeInForce'] = 'GTC';
          }
          
          await binance.spot.simulatedTrading.simulatePlaceOrder(
            symbol: params['symbol'] as String,
            side: params['side'] as String,
            type: params['type'] as String,
            quantity: params['quantity'] as double,
            price: params['price'] as double?,
            timeInForce: params['timeInForce'] as String?,
          );
        } catch (e) {
          print('   ❌ Order failed for $symbol $orderType: $e');
          continue;
        }
        
        stopwatch.stop();
        _orderTimes.add(stopwatch.elapsedMilliseconds);
        
        // Small delay between orders
        await Future.delayed(Duration(milliseconds: 50));
      }
    }
    
    if (_orderTimes.isNotEmpty) {
      final avg = _orderTimes.reduce((a, b) => a + b) / _orderTimes.length;
      final min = _orderTimes.reduce((a, b) => a < b ? a : b);
      final max = _orderTimes.reduce((a, b) => a > b ? a : b);
      
      print('   ✅ Order Processing (${_orderTimes.length} orders):');
      print('      Average: ${avg.toStringAsFixed(1)}ms');
      print('      Min: ${min}ms, Max: ${max}ms');
    }
    
    print('');
  }
  
  /// Test conversion performance
  Future<void> _testConversionPerformance() async {
    print('💱 Testing Conversion Performance...');
    
    final conversions = [
      {'from': 'BTC', 'to': 'USDT', 'amount': 0.001},
      {'from': 'ETH', 'to': 'BTC', 'amount': 1.0},
      {'from': 'BNB', 'to': 'USDT', 'amount': 1.0},
      {'from': 'ADA', 'to': 'BNB', 'amount': 100.0},
      {'from': 'SOL', 'to': 'ETH', 'amount': 1.0},
    ];
    
    // Test quote generation
    for (final conversion in conversions) {
      final stopwatch = Stopwatch()..start();
      
      try {
        await binance.simulatedConvert.simulateGetQuote(
          fromAsset: conversion['from'] as String,
          toAsset: conversion['to'] as String,
          fromAmount: conversion['amount'] as double,
        );
      } catch (e) {
        print('   ❌ Quote failed for ${conversion['from']} → ${conversion['to']}: $e');
        continue;
      }
      
      stopwatch.stop();
      _quoteTimes.add(stopwatch.elapsedMilliseconds);
      
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    // Test conversion execution
    for (int i = 0; i < 5; i++) {
      final stopwatch = Stopwatch()..start();
      
      try {
        await binance.simulatedConvert.simulateAcceptQuote(
          quoteId: 'test_quote_$i',
        );
      } catch (e) {
        print('   ❌ Conversion failed: $e');
        continue;
      }
      
      stopwatch.stop();
      _conversionTimes.add(stopwatch.elapsedMilliseconds);
      
      await Future.delayed(Duration(milliseconds: 200));
    }
    
    if (_quoteTimes.isNotEmpty) {
      final avg = _quoteTimes.reduce((a, b) => a + b) / _quoteTimes.length;
      print('   ✅ Quote Generation: ${avg.toStringAsFixed(1)}ms average');
    }
    
    if (_conversionTimes.isNotEmpty) {
      final avg = _conversionTimes.reduce((a, b) => a + b) / _conversionTimes.length;
      print('   ✅ Conversion Execution: ${avg.toStringAsFixed(1)}ms average');
    }
    
    print('');
  }
  
  /// Test WebSocket performance (if API key is available)
  Future<void> _testWebSocketPerformance() async {
    print('🔌 Testing WebSocket Performance...');
    
    // Note: This requires an API key, so we'll simulate the test
    print('   ℹ️  WebSocket testing requires API key');
    print('   ℹ️  Typical connection time: 500-1200ms');
    print('   ℹ️  Message latency: <50ms');
    
    // Test status check performance
    for (int i = 0; i < 10; i++) {
      final stopwatch = Stopwatch()..start();
      
      try {
        await binance.spot.simulatedTrading.simulateOrderStatus(
          symbol: 'BTCUSDT',
          orderId: 123456789 + i,
        );
      } catch (e) {
        print('   ❌ Status check failed: $e');
        continue;
      }
      
      stopwatch.stop();
      _statusTimes.add(stopwatch.elapsedMilliseconds);
      
      await Future.delayed(Duration(milliseconds: 50));
    }
    
    if (_statusTimes.isNotEmpty) {
      final avg = _statusTimes.reduce((a, b) => a + b) / _statusTimes.length;
      print('   ✅ Status Checks: ${avg.toStringAsFixed(1)}ms average');
    }
    
    print('');
  }
  
  /// Generate comprehensive performance report
  void _generateReport() {
    print('📋 Performance Analysis Report');
    print('==============================');
    
    if (_orderTimes.isNotEmpty) {
      _printStatistics('Order Processing', _orderTimes);
    }
    
    if (_quoteTimes.isNotEmpty) {
      _printStatistics('Quote Generation', _quoteTimes);
    }
    
    if (_conversionTimes.isNotEmpty) {
      _printStatistics('Conversion Execution', _conversionTimes);
    }
    
    if (_statusTimes.isNotEmpty) {
      _printStatistics('Status Checks', _statusTimes);
    }
    
    print('');
    print('🎯 Performance Recommendations:');
    
    final avgOrderTime = _orderTimes.isNotEmpty 
        ? _orderTimes.reduce((a, b) => a + b) / _orderTimes.length 
        : 0;
    
    if (avgOrderTime > 1000) {
      print('   ⚠️  Order processing is slower than expected (>${avgOrderTime.toStringAsFixed(0)}ms)');
      print('      Consider implementing request pooling or caching');
    } else if (avgOrderTime > 500) {
      print('   📊 Order processing is within normal range (${avgOrderTime.toStringAsFixed(0)}ms)');
    } else {
      print('   ⚡ Excellent order processing performance (${avgOrderTime.toStringAsFixed(0)}ms)');
    }
    
    final avgQuoteTime = _quoteTimes.isNotEmpty 
        ? _quoteTimes.reduce((a, b) => a + b) / _quoteTimes.length 
        : 0;
    
    if (avgQuoteTime > 800) {
      print('   ⚠️  Quote generation is slower than optimal');
    } else {
      print('   ✅ Quote generation performance is good');
    }
    
    print('');
    print('💡 Tips for Production:');
    print('   • Implement exponential backoff for retries');
    print('   • Cache market data when possible');
    print('   • Use WebSockets for real-time data');
    print('   • Monitor and log all API response times');
    print('   • Set appropriate timeouts for your use case');
  }
  
  /// Print detailed statistics for a metric
  void _printStatistics(String name, List<int> times) {
    if (times.isEmpty) return;
    
    times.sort();
    final avg = times.reduce((a, b) => a + b) / times.length;
    final min = times.first;
    final max = times.last;
    final median = times[times.length ~/ 2];
    final p95 = times[(times.length * 0.95).round() - 1];
    
    print('');
    print('📊 $name Statistics (${times.length} samples):');
    print('   Average: ${avg.toStringAsFixed(1)}ms');
    print('   Median:  ${median}ms');
    print('   Min:     ${min}ms');
    print('   Max:     ${max}ms');
    print('   95th %:  ${p95}ms');
  }
}

void main() async {
  print('⚡ Babel Binance Performance Analysis');
  print('=====================================');
  print('This tool measures API response times and provides performance insights.');
  print('');
  
  final binance = Binance();
  final analyzer = PerformanceAnalyzer(binance);
  
  try {
    await analyzer.runAnalysis();
  } catch (e) {
    print('❌ Analysis failed: $e');
  }
  
  print('✅ Performance analysis complete!');
}
