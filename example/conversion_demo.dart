import 'package:babel_binance/babel_binance.dart';
import 'dart:async';

/// Comprehensive example demonstrating currency conversion features
/// using the Babel Binance simulation system.
class ConversionDemo {
  final Binance binance;
  
  ConversionDemo(this.binance);
  
  /// Run the complete conversion demonstration
  Future<void> runDemo() async {
    print('💱 Babel Binance Conversion Demo');
    print('================================');
    print('This demo shows how to use the conversion features safely');
    print('with realistic simulation and timing.');
    print('');
    
    await _demoBasicConversion();
    await _demoMultipleConversions();
    await _demoConversionHistory();
    await _demoErrorHandling();
    await _demoTimingAnalysis();
  }
  
  /// Demonstrate basic conversion workflow
  Future<void> _demoBasicConversion() async {
    print('🔄 Basic Conversion Workflow');
    print('----------------------------');
    
    const fromAsset = 'BTC';
    const toAsset = 'USDT';
    const amount = 0.001;
    
    print('💰 Converting $amount $fromAsset to $toAsset');
    print('');
    
    try {
      // Step 1: Get conversion quote
      print('📋 Step 1: Getting conversion quote...');
      final quote = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: fromAsset,
        toAsset: toAsset,
        fromAmount: amount,
      );
      
      print('   ✅ Quote received:');
      print('      Quote ID: ${quote['quoteId']}');
      print('      Rate: ${double.parse(quote['ratio']).toStringAsFixed(2)} $toAsset per $fromAsset');
      print('      You will receive: ${quote['toAmount']} $toAsset');
      print('      Valid for: ${quote['validTime']} seconds');
      print('');
      
      // Step 2: Simulate user thinking time
      print('⏳ Step 2: Reviewing quote (simulating 3 second delay)...');
      await Future.delayed(Duration(seconds: 3));
      
      // Step 3: Accept the quote
      print('✅ Step 3: Accepting quote...');
      final conversion = await binance.simulatedConvert.simulateAcceptQuote(
        quoteId: quote['quoteId'],
      );
      
      if (conversion['orderStatus'] == 'SUCCESS') {
        print('   🎉 Conversion successful!');
        print('      Conversion ID: ${conversion['orderId']}');
        print('      Created at: ${DateTime.fromMillisecondsSinceEpoch(conversion['createTime']).toIso8601String()}');
        
        // Step 4: Get detailed conversion info
        print('');
        print('📊 Step 4: Getting conversion details...');
        final details = await binance.simulatedConvert.simulateOrderStatus(
          orderId: conversion['orderId'],
        );
        
        print('   💰 Conversion Details:');
        print('      From: ${details['fromAmount']} ${details['fromAsset']}');
        print('      To: ${details['toAmount']} ${details['toAsset']}');
        print('      Rate: ${details['ratio']}');
        print('      Fee: ${details['fee']} ${details['feeAsset']}');
        print('      Status: ${details['orderStatus']}');
        
      } else {
        print('   ❌ Conversion failed: ${conversion['errorMsg']}');
      }
      
    } catch (e) {
      print('   ❌ Error during conversion: $e');
    }
    
    print('');
  }
  
  /// Demonstrate multiple conversions
  Future<void> _demoMultipleConversions() async {
    print('🔄 Multiple Conversions Demo');
    print('----------------------------');
    
    final conversions = [
      {'from': 'ETH', 'to': 'BTC', 'amount': 1.0},
      {'from': 'BNB', 'to': 'USDT', 'amount': 5.0},
      {'from': 'ADA', 'to': 'ETH', 'amount': 1000.0},
      {'from': 'SOL', 'to': 'BNB', 'amount': 10.0},
    ];
    
    print('🔄 Processing ${conversions.length} conversions...');
    print('');
    
    final results = <Map<String, dynamic>>[];
    
    for (int i = 0; i < conversions.length; i++) {
      final conversion = conversions[i];
      print('💱 Conversion ${i + 1}/${conversions.length}: ${conversion['amount']} ${conversion['from']} → ${conversion['to']}');
      
      try {
        // Get quote
        final stopwatch = Stopwatch()..start();
        final quote = await binance.simulatedConvert.simulateGetQuote(
          fromAsset: conversion['from'] as String,
          toAsset: conversion['to'] as String,
          fromAmount: conversion['amount'] as double,
        );
        
        // Accept quote
        final result = await binance.simulatedConvert.simulateAcceptQuote(
          quoteId: quote['quoteId'],
        );
        
        stopwatch.stop();
        
        results.add({
          'from': conversion['from'],
          'to': conversion['to'],
          'amount': conversion['amount'],
          'result': result,
          'quote': quote,
          'processingTime': stopwatch.elapsedMilliseconds,
        });
        
        if (result['orderStatus'] == 'SUCCESS') {
          print('   ✅ Success - ${quote['toAmount']} ${conversion['to']} (${stopwatch.elapsedMilliseconds}ms)');
        } else {
          print('   ❌ Failed - ${result['errorMsg']} (${stopwatch.elapsedMilliseconds}ms)');
        }
        
      } catch (e) {
        print('   ❌ Error - $e');
      }
      
      // Small delay between conversions
      await Future.delayed(Duration(milliseconds: 500));
    }
    
    // Summary
    print('');
    print('📊 Conversion Summary:');
    final successful = results.where((r) => r['result']['orderStatus'] == 'SUCCESS').length;
    final avgTime = results.isNotEmpty 
        ? results.map((r) => r['processingTime'] as int).reduce((a, b) => a + b) / results.length
        : 0;
    
    print('   ✅ Successful: $successful/${results.length}');
    print('   ⏱️  Average time: ${avgTime.toStringAsFixed(1)}ms');
    print('');
  }
  
  /// Demonstrate conversion history
  Future<void> _demoConversionHistory() async {
    print('📚 Conversion History Demo');
    print('--------------------------');
    
    try {
      final history = await binance.simulatedConvert.simulateConversionHistory(
        limit: 10,
      );
      
      print('📋 Recent conversion history (${history['list'].length} entries):');
      print('');
      
      for (int i = 0; i < history['list'].length; i++) {
        final conversion = history['list'][i];
        final date = DateTime.fromMillisecondsSinceEpoch(conversion['createTime']);
        final dateStr = '${date.month}/${date.day} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
        
        print('   ${i + 1}. [$dateStr] ${conversion['fromAmount']} ${conversion['fromAsset']} → ${conversion['toAmount']} ${conversion['toAsset']}');
        print('      Status: ${conversion['orderStatus']}, Fee: ${conversion['fee']} ${conversion['feeAsset']}');
      }
      
      print('');
      print('📊 History Stats:');
      print('   Period: ${DateTime.fromMillisecondsSinceEpoch(history['startTime']).toIso8601String().substring(0, 10)} to ${DateTime.fromMillisecondsSinceEpoch(history['endTime']).toIso8601String().substring(0, 10)}');
      print('   Total entries: ${history['list'].length}');
      print('   More data available: ${history['moreData']}');
      
    } catch (e) {
      print('❌ Error fetching history: $e');
    }
    
    print('');
  }
  
  /// Demonstrate error handling
  Future<void> _demoErrorHandling() async {
    print('⚠️  Error Handling Demo');
    print('-----------------------');
    
    print('Testing various error scenarios...');
    print('');
    
    // Test 1: Invalid quote ID
    print('🧪 Test 1: Invalid quote acceptance');
    try {
      final result = await binance.simulatedConvert.simulateAcceptQuote(
        quoteId: 'invalid_quote_id_12345',
      );
      
      if (result['orderStatus'] == 'FAILED') {
        print('   ✅ Properly handled invalid quote');
        print('   Error: ${result['errorCode']} - ${result['errorMsg']}');
      } else {
        print('   ✅ Quote accepted (2% chance of success)');
      }
    } catch (e) {
      print('   ✅ Exception properly caught: $e');
    }
    
    print('');
    
    // Test 2: Network timeout simulation
    print('🧪 Test 2: Timeout handling');
    try {
      final stopwatch = Stopwatch()..start();
      
      // This should complete normally, but we can measure timing
      await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'BTC',
        toAsset: 'USDT',
        fromAmount: 0.001,
      );
      
      stopwatch.stop();
      
      if (stopwatch.elapsedMilliseconds > 5000) {
        print('   ⚠️  Slow response detected (${stopwatch.elapsedMilliseconds}ms)');
        print('   Consider implementing timeout handling in production');
      } else {
        print('   ✅ Normal response time (${stopwatch.elapsedMilliseconds}ms)');
      }
      
    } catch (e) {
      print('   ✅ Timeout properly handled: $e');
    }
    
    print('');
  }
  
  /// Demonstrate timing analysis for conversions
  Future<void> _demoTimingAnalysis() async {
    print('⏱️  Timing Analysis Demo');
    print('------------------------');
    
    print('Measuring conversion performance across different scenarios...');
    print('');
    
    final measurements = <String, List<int>>{
      'Quote Generation': [],
      'Quote Acceptance': [],
      'Status Check': [],
    };
    
    // Measure quote generation
    for (int i = 0; i < 5; i++) {
      final stopwatch = Stopwatch()..start();
      
      await binance.simulatedConvert.simulateGetQuote(
        fromAsset: 'BTC',
        toAsset: 'USDT',
        fromAmount: 0.001,
      );
      
      stopwatch.stop();
      measurements['Quote Generation']!.add(stopwatch.elapsedMilliseconds);
      
      await Future.delayed(Duration(milliseconds: 100));
    }
    
    // Measure quote acceptance
    for (int i = 0; i < 5; i++) {
      final stopwatch = Stopwatch()..start();
      
      await binance.simulatedConvert.simulateAcceptQuote(
        quoteId: 'test_quote_$i',
      );
      
      stopwatch.stop();
      measurements['Quote Acceptance']!.add(stopwatch.elapsedMilliseconds);
      
      await Future.delayed(Duration(milliseconds: 200));
    }
    
    // Measure status checks
    for (int i = 0; i < 5; i++) {
      final stopwatch = Stopwatch()..start();
      
      await binance.simulatedConvert.simulateOrderStatus(
        orderId: 'test_order_$i',
      );
      
      stopwatch.stop();
      measurements['Status Check']!.add(stopwatch.elapsedMilliseconds);
      
      await Future.delayed(Duration(milliseconds: 50));
    }
    
    // Print results
    measurements.forEach((operation, times) {
      if (times.isNotEmpty) {
        final avg = times.reduce((a, b) => a + b) / times.length;
        final min = times.reduce((a, b) => a < b ? a : b);
        final max = times.reduce((a, b) => a > b ? a : b);
        
        print('📊 $operation:');
        print('   Average: ${avg.toStringAsFixed(1)}ms');
        print('   Range: ${min}ms - ${max}ms');
        print('');
      }
    });
    
    print('💡 Performance Tips:');
    print('   • Quote generation: 100-800ms is normal');
    print('   • Quote acceptance: 500ms-3s is expected');
    print('   • Status checks: 50-200ms is typical');
    print('   • Always implement timeout handling');
    print('   • Consider retry logic for failed operations');
  }
}

void main() async {
  final binance = Binance();
  final demo = ConversionDemo(binance);
  
  try {
    await demo.runDemo();
    
    print('');
    print('🎉 Conversion demo completed successfully!');
    print('');
    print('🚀 Next Steps:');
    print('   • Explore other Babel Binance features');
    print('   • Check out the trading bot example');
    print('   • Run performance analysis');
    print('   • Try WebSocket connections with real API keys');
    
  } catch (e) {
    print('❌ Demo failed: $e');
  }
}
