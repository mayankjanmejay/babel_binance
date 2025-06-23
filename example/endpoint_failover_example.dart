/// 🔗 Babel Binance - API Endpoint Failover Example
/// 
/// This example demonstrates the new multiple API endpoint functionality
/// with automatic failover support. The system automatically switches
/// between different Binance API servers when one becomes unavailable.
/// 
/// 🌐 Supported Endpoint Types:
/// ✅ Spot API (api.binance.com → api1-4.binance.com)
/// ✅ Futures USD-M (fapi.binance.com → fapi1-3.binance.com) 
/// ✅ Futures COIN-M (dapi.binance.com → dapi1-2.binance.com)
/// ✅ Automatic failover on network errors
/// ✅ Automatic reset to primary endpoint on success

import 'package:babel_binance/babel_binance.dart';

void main() async {
  print('🔗 Babel Binance - API Endpoint Failover Demo');
  print('=' * 50);
  print('');
  
  await demonstrateEndpointInfo();
  await demonstrateSpotEndpoints();
  await demonstrateFuturesEndpoints();
  
  print('');
  print('✅ Endpoint failover demonstration complete!');
  print('');
  print('📋 Key Benefits:');
  print('   🚀 Automatic failover on server issues');
  print('   🌐 Multiple geographic endpoints');
  print('   🔄 Smart endpoint rotation');
  print('   📊 Improved reliability and uptime');
  print('   🛡️ Built-in error handling');
}

Future<void> demonstrateEndpointInfo() async {
  print('📡 ENDPOINT CONFIGURATION');
  print('-' * 25);
  
  final binance = Binance();
  
  // Show Spot API endpoints
  print('🟢 Spot API Endpoints:');
  final spotEndpoints = binance.spot.market.availableEndpoints;
  for (int i = 0; i < spotEndpoints.length; i++) {
    final marker = i == 0 ? '🎯 PRIMARY' : '🔄 FAILOVER';
    print('   $marker: ${spotEndpoints[i]}');
  }
  
  print('');
  print('🟡 Futures USD-M Endpoints:');
  final futuresEndpoints = binance.futuresUsd.market.availableEndpoints;
  for (int i = 0; i < futuresEndpoints.length; i++) {
    final marker = i == 0 ? '🎯 PRIMARY' : '🔄 FAILOVER';
    print('   $marker: ${futuresEndpoints[i]}');
  }
  
  print('');
  print('🔵 Current Active Endpoints:');
  print('   Spot: ${binance.spot.market.currentEndpoint}');
  print('   Futures: ${binance.futuresUsd.market.currentEndpoint}');
  
  print('');
}

Future<void> demonstrateSpotEndpoints() async {
  print('🟢 SPOT API FAILOVER TEST');
  print('-' * 25);
  
  final binance = Binance();
  
  try {
    print('📡 Testing Spot API connectivity...');
    
    // This will automatically use failover if primary endpoint fails
    final serverTime = await binance.spot.market.getServerTime();
    final readableTime = DateTime.fromMillisecondsSinceEpoch(serverTime['serverTime']);
    
    print('✅ Connection successful!');
    print('   Active endpoint: ${binance.spot.market.currentEndpoint}');
    print('   Server time: ${readableTime.toUtc()}');
    
    // Test market data
    print('');
    print('📊 Fetching market data...');
    final ticker = await binance.spot.market.get24HrTicker('BTCUSDT');
    print('   BTC/USDT: \$${ticker['lastPrice']}');
    print('   24h Change: ${ticker['priceChangePercent']}%');
    
  } catch (e) {
    print('❌ All endpoints failed: $e');
  }
  
  print('');
}

Future<void> demonstrateFuturesEndpoints() async {
  print('🟡 FUTURES API FAILOVER TEST');
  print('-' * 27);
  
  final binance = Binance();
  
  try {
    print('📡 Testing Futures API connectivity...');
    
    // This will automatically use failover if primary endpoint fails
    final exchangeInfo = await binance.futuresUsd.market.getExchangeInfo();
    final symbolCount = exchangeInfo['symbols'].length;
    
    print('✅ Connection successful!');
    print('   Active endpoint: ${binance.futuresUsd.market.currentEndpoint}');
    print('   Available symbols: $symbolCount');
    
    // Test futures market data
    print('');
    print('📊 Fetching futures data...');
    final ticker = await binance.futuresUsd.market.get24HrTicker('BTCUSDT');
    print('   BTC/USDT Futures: \$${ticker['lastPrice']}');
    print('   24h Change: ${ticker['priceChangePercent']}%');
    
  } catch (e) {
    print('❌ All endpoints failed: $e');
  }
  
  print('');
}
