
/// 🚀 Babel Binance - Quick Start Guide
/// 
/// New to Babel Binance? This is your perfect starting point!
/// 
/// This example covers everything you need to know to get started,
/// from your first API call to building your first trading strategy.
/// 
/// 📚 Learn Step by Step:
/// ✅ Installation & Setup
/// ✅ Your First API Call  
/// ✅ Getting Market Data
/// ✅ Simulated Trading
/// ✅ Building a Simple Strategy
/// ✅ Next Steps

import 'package:babel_binance/babel_binance.dart';

void main() async {
  print('🚀 Welcome to Babel Binance - Quick Start Guide!');
  print('=' * 55);
  print('📚 Learning Binance API integration has never been easier!');
  print('');
  
  // Step 1: Setup
  await step1_Setup();
  
  // Step 2: First API Call
  await step2_FirstApiCall();
  
  // Step 3: Getting Market Data
  await step3_MarketData();
  
  // Step 4: Simulated Trading
  await step4_SimulatedTrading();
  
  // Step 5: Simple Strategy
  await step5_SimpleStrategy();
  
  // Step 6: Next Steps
  step6_NextSteps();
}

/// 📦 Step 1: Setup & Installation
Future<void> step1_Setup() async {
  print('📦 STEP 1: Setup & Installation');
  print('-' * 30);
  print('');
  print('✅ You\'ve already completed the setup since this example is running!');
  print('');
  print('📝 For future projects, just add to pubspec.yaml:');
  print('');
  print('dependencies:');
  print('  babel_binance: ^0.6.0');
  print('');
  print('Then run: dart pub get');
  print('');
  print('💡 Import in your code:');
  print('import \'package:babel_binance/babel_binance.dart\';');
  print('');
  await _pause();
}

/// 🔌 Step 2: Your First API Call
Future<void> step2_FirstApiCall() async {
  print('🔌 STEP 2: Your First API Call');
  print('-' * 30);
  print('');
  print('Let\'s start with something simple - getting the current time from Binance!');
  print('(No API key required for this)');
  print('');
  
  try {
    // Create Binance instance
    final binance = Binance();
    
    // Get server time
    print('📡 Calling Binance API...');
    final serverTime = await binance.spot.market.getServerTime();
    
    // Convert to readable format
    final dateTime = DateTime.fromMillisecondsSinceEpoch(serverTime['serverTime']);
    
    print('✅ Success! Binance server time: ${dateTime.toUtc()}');
    print('');
    print('🎉 Congratulations! You just made your first Binance API call!');
    
  } catch (e) {
    print('❌ Error: $e');
    print('💡 This might be a network issue. Check your internet connection.');
  }
  
  print('');
  await _pause();
}

/// 📊 Step 3: Getting Market Data
Future<void> step3_MarketData() async {
  print('📊 STEP 3: Getting Market Data');
  print('-' * 30);
  print('');
  print('Now let\'s get some real market data - Bitcoin\'s current price!');
  print('');
  
  try {
    final binance = Binance();
    
    // Get Bitcoin price
    print('💰 Fetching Bitcoin (BTC) price...');
    final ticker = await binance.spot.market.get24HrTicker('BTCUSDT');
    
    // Extract useful information
    final price = double.parse(ticker['lastPrice']);
    final change = double.parse(ticker['priceChangePercent']);
    final volume = double.parse(ticker['volume']);
    final high = double.parse(ticker['highPrice']);
    final low = double.parse(ticker['lowPrice']);
    
    // Display results
    print('📈 Bitcoin (BTC/USDT) Market Data:');
    print('   💵 Current Price: \$${price.toStringAsFixed(2)}');
    print('   📊 24h Change: ${change >= 0 ? '+' : ''}${change.toStringAsFixed(2)}%');
    print('   📈 24h High: \$${high.toStringAsFixed(2)}');
    print('   📉 24h Low: \$${low.toStringAsFixed(2)}');
    print('   📦 24h Volume: ${volume.toStringAsFixed(0)} BTC');
    
    // Fun fact
    if (change > 5) {
      print('   🚀 Bitcoin is having a great day! (+${change.toStringAsFixed(1)}%)');
    } else if (change < -5) {
      print('   📉 Bitcoin is down today (${change.toStringAsFixed(1)}%)');
    } else {
      print('   😐 Bitcoin is relatively stable today');
    }
    
  } catch (e) {
    print('❌ Error fetching market data: $e');
  }
  
  print('');
  print('💡 You can get market data for any trading pair: ETHUSDT, BNBUSDT, etc.');
  print('');
  await _pause();
}

/// 🎯 Step 4: Simulated Trading
Future<void> step4_SimulatedTrading() async {
  print('🎯 STEP 4: Simulated Trading (Risk-Free!)');
  print('-' * 30);
  print('');
  print('Let\'s practice trading without risking real money!');
  print('We\'ll simulate buying some Ethereum...');
  print('');
  
  try {
    final binance = Binance();
    
    // Simulate buying Ethereum
    print('🛒 Simulating: Buy 0.1 ETH with market order...');
    final buyOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
      symbol: 'ETHUSDT',
      side: 'BUY',
      type: 'MARKET',
      quantity: 0.1, // Buy 0.1 ETH
    );
    
    // Show results
    final ethBought = double.parse(buyOrder['executedQty']);
    final usdSpent = double.parse(buyOrder['cummulativeQuoteQty']);
    final avgPrice = usdSpent / ethBought;
    
    print('✅ Trade Executed Successfully!');
    print('   📦 Order ID: ${buyOrder['orderId']}');
    print('   💰 Bought: ${ethBought.toStringAsFixed(4)} ETH');
    print('   💵 Cost: \$${usdSpent.toStringAsFixed(2)} USDT');
    print('   📊 Average Price: \$${avgPrice.toStringAsFixed(2)} per ETH');
    print('   ⏱️  Status: ${buyOrder['status']}');
    
    print('');
    print('🎉 Great! You just simulated your first trade!');
    print('💡 This was completely risk-free - no real money was used.');
    
  } catch (e) {
    print('❌ Error in simulated trading: $e');
  }
  
  print('');
  await _pause();
}

/// 🧠 Step 5: Simple Trading Strategy
Future<void> step5_SimpleStrategy() async {
  print('🧠 STEP 5: Simple Trading Strategy');
  print('-' * 30);
  print('');
  print('Let\'s build a simple strategy: Buy low, sell high!');
  print('We\'ll check if Bitcoin is down >3% and simulate buying the dip.');
  print('');
  
  try {
    final binance = Binance();
    
    // Get current market data
    print('📊 Analyzing market conditions...');
    final ticker = await binance.spot.market.get24HrTicker('BTCUSDT');
    final priceChange = double.parse(ticker['priceChangePercent']);
    final currentPrice = double.parse(ticker['lastPrice']);
    
    print('📈 Bitcoin 24h change: ${priceChange.toStringAsFixed(2)}%');
    
    // Strategy logic
    if (priceChange < -3.0) {
      print('🎯 Strategy Signal: BUY THE DIP!');
      print('   📉 Bitcoin is down ${priceChange.abs().toStringAsFixed(1)}% today');
      print('   💡 This could be a good buying opportunity');
      
      // Simulate the strategy trade
      print('');
      print('🛒 Executing strategy: Buy \$1000 worth of Bitcoin...');
      final buyOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'MARKET',
        quoteOrderQty: 1000.0, // Buy $1000 worth
      );
      
      final btcBought = double.parse(buyOrder['executedQty']);
      print('✅ Strategy executed: Bought ${btcBought.toStringAsFixed(6)} BTC');
      
    } else if (priceChange > 5.0) {
      print('💰 Strategy Signal: TAKE PROFITS!');
      print('   📈 Bitcoin is up ${priceChange.toStringAsFixed(1)}% today');
      print('   💡 Good time to take some profits');
      
      // Simulate selling
      print('');
      print('💸 Executing strategy: Sell 0.01 BTC...');
      final sellOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'SELL',
        type: 'MARKET',
        quantity: 0.01,
      );
      
      final usdReceived = double.parse(sellOrder['cummulativeQuoteQty']);
      print('✅ Strategy executed: Sold for \$${usdReceived.toStringAsFixed(2)}');
      
    } else {
      print('😐 Strategy Signal: HOLD');
      print('   📊 No clear signal - Bitcoin change is ${priceChange.toStringAsFixed(1)}%');
      print('   💡 Waiting for better opportunities (< -3% or > +5%)');
    }
    
    print('');
    print('🎓 You just implemented a basic trading strategy!');
    
  } catch (e) {
    print('❌ Error in strategy execution: $e');
  }
  
  print('');
  await _pause();
}

/// 🚀 Step 6: Next Steps
void step6_NextSteps() {
  print('🚀 STEP 6: What\'s Next?');
  print('-' * 30);
  print('');
  print('🎉 Congratulations! You\'ve completed the Quick Start Guide!');
  print('');
  print('🎯 Here\'s what you\'ve learned:');
  print('   ✅ How to make API calls');
  print('   ✅ Getting real market data');
  print('   ✅ Simulated trading (risk-free)');
  print('   ✅ Building simple strategies');
  print('');
  print('🚀 Ready for more advanced features?');
  print('');
  print('📚 Check out these examples:');
  print('   🔥 complete_showcase_example.dart - See everything Babel Binance can do');
  print('   🌍 real_world_scenarios_example.dart - Practical applications');
  print('   🤖 trading_bot_example.dart - Build your own trading bot');
  print('   📈 performance_analysis_example.dart - Measure and optimize');
  print('');
  print('🔐 When you\'re ready for live trading:');
  print('   1. Get API keys from Binance');
  print('   2. Set environment variables: BINANCE_API_KEY & BINANCE_SECRET_KEY');
  print('   3. Use real trading methods instead of simulated ones');
  print('');
  print('⚠️  Important Safety Tips:');
  print('   🛡️  Always test with simulated trading first');
  print('   💰 Start with small amounts');
  print('   📊 Understand the risks involved');
  print('   🧠 Never invest more than you can afford to lose');
  print('');
  print('📖 Documentation & Resources:');
  print('   🌐 Package: https://pub.dev/packages/babel_binance');
  print('   📚 Binance API Docs: https://binance-docs.github.io/apidocs/');
  print('   💬 Questions? Check the package documentation!');
  print('');
  print('🎯 Happy trading! 🚀');
}

// Helper function to pause between steps
Future<void> _pause() async {
  print('⏳ (Pausing for 3 seconds...)');
  await Future.delayed(Duration(seconds: 3));
  print('');
}
