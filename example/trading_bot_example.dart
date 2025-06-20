import 'package:babel_binance/babel_binance.dart';
import 'dart:async';

/// A simple trading bot that demonstrates automated trading strategies
/// using the simulation features of Babel Binance.
class SimpleTradingBot {
  final Binance binance;
  final String symbol;
  final double buyThreshold;
  final double sellThreshold;
  final double quantity;
  bool _isRunning = false;
  Timer? _timer;
  
  SimpleTradingBot({
    required this.binance,
    required this.symbol,
    required this.buyThreshold,
    required this.sellThreshold,
    this.quantity = 0.001,
  });
  
  /// Start the trading bot
  Future<void> start() async {
    if (_isRunning) {
      print('⚠️  Bot is already running');
      return;
    }
    
    _isRunning = true;
    print('🤖 Starting Trading Bot for $symbol');
    print('   📈 Buy below: \$${buyThreshold.toStringAsFixed(2)}');
    print('   📉 Sell above: \$${sellThreshold.toStringAsFixed(2)}');
    print('   💰 Quantity: $quantity');
    print('   🔄 Check interval: 30 seconds');
    print('');
    
    // Run trading cycle every 30 seconds
    _timer = Timer.periodic(Duration(seconds: 30), (timer) async {
      if (!_isRunning) {
        timer.cancel();
        return;
      }
      await _runTradingCycle();
    });
    
    // Run first cycle immediately
    await _runTradingCycle();
  }
  
  /// Stop the trading bot
  void stop() {
    _isRunning = false;
    _timer?.cancel();
    print('🛑 Trading bot stopped');
  }
  
  /// Main trading logic
  Future<void> _runTradingCycle() async {
    try {
      // Get current market price
      final orderBook = await binance.spot.market.getOrderBook(symbol, limit: 1);
      final currentPrice = double.parse(orderBook['asks'][0][0]);
      final timestamp = DateTime.now().toIso8601String().substring(11, 19);
      
      print('[$timestamp] 📊 Current $symbol price: \$${currentPrice.toStringAsFixed(2)}');
      
      // Apply trading strategy
      if (currentPrice < buyThreshold) {
        await _executeBuySignal(currentPrice);
      } else if (currentPrice > sellThreshold) {
        await _executeSellSignal(currentPrice);
      } else {
        print('[$timestamp] ⏳ Price in neutral zone, waiting...');
      }
      
    } catch (e) {
      final timestamp = DateTime.now().toIso8601String().substring(11, 19);
      print('[$timestamp] ❌ Error in trading cycle: $e');
    }
  }
  
  /// Execute buy signal
  Future<void> _executeBuySignal(double price) async {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    print('[$timestamp] 🟢 BUY Signal triggered at \$${price.toStringAsFixed(2)}');
    
    try {
      final order = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: symbol,
        side: 'BUY',
        type: 'MARKET',
        quantity: quantity,
      );
      
      print('[$timestamp] ✅ Buy order executed');
      print('[$timestamp]    Order ID: ${order['orderId']}');
      print('[$timestamp]    Quantity: ${order['executedQty']} ${symbol.replaceAll('USDT', '')}');
      print('[$timestamp]    Total Cost: \$${order['cummulativeQuoteQty']}');
      
    } catch (e) {
      print('[$timestamp] ❌ Buy order failed: $e');
    }
  }
  
  /// Execute sell signal
  Future<void> _executeSellSignal(double price) async {
    final timestamp = DateTime.now().toIso8601String().substring(11, 19);
    print('[$timestamp] 🔴 SELL Signal triggered at \$${price.toStringAsFixed(2)}');
    
    try {
      final order = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: symbol,
        side: 'SELL',
        type: 'MARKET',
        quantity: quantity,
      );
      
      print('[$timestamp] ✅ Sell order executed');
      print('[$timestamp]    Order ID: ${order['orderId']}');
      print('[$timestamp]    Quantity: ${order['executedQty']} ${symbol.replaceAll('USDT', '')}');
      print('[$timestamp]    Total Value: \$${order['cummulativeQuoteQty']}');
      
    } catch (e) {
      print('[$timestamp] ❌ Sell order failed: $e');
    }
  }
}

void main() async {
  // Initialize Binance client (no API key needed for simulation)
  final binance = Binance();
  
  print('🚀 Babel Binance Trading Bot Example');
  print('=====================================');
  print('This example demonstrates automated trading using simulation mode.');
  print('No real money is involved - this is for educational purposes only.');
  print('');
  
  // Create trading bot with strategy parameters
  final bot = SimpleTradingBot(
    binance: binance,
    symbol: 'BTCUSDT',
    buyThreshold: 94000.0,  // Buy when BTC drops below $94k
    sellThreshold: 96000.0, // Sell when BTC goes above $96k
    quantity: 0.001,        // Trade 0.001 BTC each time
  );
  
  // Start the bot
  await bot.start();
  
  // Let it run for 5 minutes
  print('🕐 Bot will run for 5 minutes...');
  await Future.delayed(Duration(minutes: 5));
  
  // Stop the bot
  bot.stop();
  
  print('');
  print('🎯 Trading bot example completed!');
  print('💡 In a real application, you would:');
  print('   - Use real API credentials for live trading');
  print('   - Implement more sophisticated strategies');
  print('   - Add risk management and position sizing');
  print('   - Include proper error handling and logging');
  print('   - Store trading history in a database');
}
