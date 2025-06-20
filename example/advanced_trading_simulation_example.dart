
/// 🚀 Advanced Trading Simulation with Futures & Margin
/// 
/// This example demonstrates the advanced trading simulation capabilities
/// of Babel Binance, including Futures trading with leverage and Margin
/// trading with borrowing - all completely risk-free!

import 'package:babel_binance/babel_binance.dart';

void main() async {
  print('🚀 Advanced Trading Simulation Example');
  print('=' * 50);
  print('🛡️  100% Safe - No real money involved!');
  print('📚 Perfect for learning advanced trading concepts');
  print('');
  
  final binance = Binance();
  
  // Section 1: Futures Trading Simulation
  await demonstrateFuturesTrading(binance);
  
  // Section 2: Margin Trading Simulation
  await demonstrateMarginTrading(binance);
  
  // Section 3: Advanced Strategies
  await demonstrateAdvancedStrategies(binance);
  
  print('\n🎉 Advanced Trading Simulation Complete!');
  print('💡 Key Takeaways:');
  print('   📈 Futures offer leverage but higher risk');
  print('   💰 Margin trading requires careful collateral management');
  print('   🎯 Both require advanced risk management');
  print('   🛡️  Always practice with simulation first!');
}

/// 📈 Demonstrate Futures Trading with Leverage
Future<void> demonstrateFuturesTrading(Binance binance) async {
  print('📈 SECTION 1: Futures Trading Simulation');
  print('-' * 40);
  print('⚡ Exploring leveraged trading with futures contracts');
  print('');
  
  try {
    // Get current futures market data
    print('🔍 Analyzing Futures Market...');
    
    // Simulate getting position information
    final position = await binance.futuresUsd.simulatedTrading.simulateGetPosition(
      symbol: 'BTCUSDT',
    );
    
    print('📊 Current BTC/USDT Futures Position:');
    print('   Position Size: ${position['positionAmt']} BTC');
    print('   Entry Price: \$${position['entryPrice']}');
    print('   Mark Price: \$${position['markPrice']}');
    print('   Unrealized PnL: \$${position['unRealizedProfit']}');
    print('   Leverage: ${position['leverage']}x');
    print('   Liquidation Price: \$${position['liquidationPrice']}');
    print('');
    
    // Strategy 1: Long Position with 20x Leverage
    print('🎯 Strategy 1: Opening Long Position (20x Leverage)');
    print('💡 Bullish on Bitcoin - expecting price increase');
    
    final longOrder = await binance.futuresUsd.simulatedTrading.simulatePlaceOrder(
      symbol: 'BTCUSDT',
      side: 'BUY',
      type: 'MARKET',
      quantity: 0.01, // 0.01 BTC
      leverage: 20,
    );
    
    print('✅ Long Position Opened:');
    print('   Order ID: ${longOrder['orderId']}');
    print('   Quantity: ${longOrder['origQty']} BTC');
    print('   Entry Price: \$${longOrder['price']}');
    print('   Leverage: ${longOrder['leverage']}x');
    print('   Margin Required: \$${longOrder['marginRequired']}');
    print('   Notional Value: \$${longOrder['notionalValue']}');
    print('');
    
    // Strategy 2: Hedge with Short Position
    print('🛡️  Strategy 2: Hedging with Short Position');
    print('💡 Protecting against downside risk');
    
    final shortOrder = await binance.futuresUsd.simulatedTrading.simulatePlaceOrder(
      symbol: 'ETHUSDT',
      side: 'SELL',
      type: 'LIMIT',
      quantity: 0.1, // 0.1 ETH
      price: 3250.0, // Limit price
      leverage: 10,
    );
    
    print('✅ Short Position Placed:');
    print('   Order ID: ${shortOrder['orderId']}');
    print('   Type: ${shortOrder['type']} ${shortOrder['side']}');
    print('   Quantity: ${shortOrder['origQty']} ETH');
    print('   Limit Price: \$${shortOrder['price']}');
    print('   Status: ${shortOrder['status']}');
    print('');
    
    // Demonstrate funding rate analysis
    print('💰 Funding Rate Analysis:');
    final fundingData = await binance.futuresUsd.simulatedTrading.simulateGetFundingRate(
      symbol: 'BTCUSDT',
      limit: 3,
    );
    
    print('   📊 Recent Funding Rates for BTC/USDT:');
    for (final rate in fundingData['fundingRates']) {
      final fundingRate = double.parse(rate['fundingRate']) * 100;
      final time = DateTime.fromMillisecondsSinceEpoch(rate['fundingTime']);
      print('   ${time.toIso8601String().substring(0, 16)}: ${fundingRate >= 0 ? '+' : ''}${fundingRate.toStringAsFixed(4)}%');
    }
    print('');
    
    // Demonstrate margin management
    print('⚙️  Margin Management:');
    final marginChange = await binance.futuresUsd.simulatedTrading.simulateChangeMargin(
      symbol: 'BTCUSDT',
      type: '1', // Add margin
      amount: 100.0, // Add $100 margin
    );
    
    print('   ✅ ${marginChange['type']}: \$${marginChange['amount']}');
    print('   📋 Status: ${marginChange['msg']}');
    
  } catch (e) {
    print('❌ Futures trading error: $e');
  }
  
  print('');
}

/// 💰 Demonstrate Margin Trading with Borrowing
Future<void> demonstrateMarginTrading(Binance binance) async {
  print('💰 SECTION 2: Margin Trading Simulation');
  print('-' * 40);
  print('🏦 Exploring borrowing and leveraged spot trading');
  print('');
  
  try {
    // Check current margin account status
    print('🔍 Checking Margin Account Status...');
    final marginAccount = await binance.margin.simulatedTrading.simulateGetMarginAccount();
    
    print('📊 Margin Account Overview:');
    print('   💰 Total Asset (BTC): ${marginAccount['totalAssetOfBtc']}');
    print('   💸 Total Liability (BTC): ${marginAccount['totalLiabilityOfBtc']}');
    print('   📈 Margin Level: ${marginAccount['marginLevel']}');
    print('   ✅ Borrow Enabled: ${marginAccount['borrowEnabled']}');
    print('   ✅ Trade Enabled: ${marginAccount['tradeEnabled']}');
    print('');
    
    print('💼 Asset Balances:');
    for (final asset in marginAccount['userAssets']) {
      print('   ${asset['asset']}: Free: ${asset['free']}, Borrowed: ${asset['borrowed']}');
    }
    print('');
    
    // Strategy 1: Borrow USDT to buy more crypto
    print('🎯 Strategy 1: Leveraged Position via Borrowing');
    print('💡 Borrow USDT to buy more Bitcoin');
    
    final borrowAmount = 5000.0; // Borrow $5000 USDT
    print('🏦 Borrowing \$${borrowAmount.toStringAsFixed(0)} USDT...');
    
    final borrowResult = await binance.margin.simulatedTrading.simulateBorrow(
      asset: 'USDT',
      amount: borrowAmount,
    );
    
    print('✅ Borrow Transaction Completed:');
    print('   Transaction ID: ${borrowResult['tranId']}');
    print('   Asset: ${borrowResult['asset']}');
    print('   Amount: \$${borrowResult['amount']}');
    print('   Status: ${borrowResult['status']}');
    print('');
    
    // Use borrowed USDT to buy Bitcoin
    print('💰 Using borrowed USDT to buy Bitcoin...');
    final marginOrder = await binance.margin.simulatedTrading.simulatePlaceOrder(
      symbol: 'BTCUSDT',
      side: 'BUY',
      type: 'MARKET',
      quantity: 0.05, // Buy 0.05 BTC
    );
    
    print('✅ Margin Buy Order Executed:');
    print('   Order ID: ${marginOrder['orderId']}');
    print('   Quantity: ${marginOrder['origQty']} BTC');
    print('   Price: \$${marginOrder['price']}');
    print('   Status: ${marginOrder['status']}');
    print('   Auto-Borrowed: \$${marginOrder['marginBuyBorrowAmount']} ${marginOrder['marginBuyBorrowAsset']}');
    print('');
    
    // Strategy 2: Partial Repayment
    print('🎯 Strategy 2: Partial Loan Repayment');
    print('💡 Repay part of the USDT loan to reduce risk');
    
    final repayAmount = 2000.0; // Repay $2000
    print('💸 Repaying \$${repayAmount.toStringAsFixed(0)} USDT...');
    
    final repayResult = await binance.margin.simulatedTrading.simulateRepay(
      asset: 'USDT',
      amount: repayAmount,
    );
    
    print('✅ Repayment Transaction Completed:');
    print('   Transaction ID: ${repayResult['tranId']}');
    print('   Asset: ${repayResult['asset']}');
    print('   Amount: \$${repayResult['amount']}');
    print('   Status: ${repayResult['status']}');
    print('');
    
    // Check updated margin account
    print('📊 Updated Margin Account Status:');
    final updatedAccount = await binance.margin.simulatedTrading.simulateGetMarginAccount();
    print('   📈 New Margin Level: ${updatedAccount['marginLevel']}');
    print('   💰 Net Asset (BTC): ${updatedAccount['totalNetAssetOfBtc']}');
    
  } catch (e) {
    print('❌ Margin trading error: $e');
  }
  
  print('');
}

/// 🎯 Demonstrate Advanced Trading Strategies
Future<void> demonstrateAdvancedStrategies(Binance binance) async {
  print('🎯 SECTION 3: Advanced Strategy Simulation');
  print('-' * 40);
  print('🧠 Combining Spot, Margin, and Futures for complex strategies');
  print('');
  
  try {
    // Strategy: Delta Neutral Portfolio
    print('⚖️  Strategy: Delta Neutral Hedging');
    print('💡 Long spot + short futures to capture funding fees');
    print('');
    
    // Step 1: Buy spot Bitcoin
    print('📈 Step 1: Buy Spot Bitcoin');
    final spotOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
      symbol: 'BTCUSDT',
      side: 'BUY',
      type: 'MARKET',
      quantity: 0.1, // 0.1 BTC
    );
    
    print('   ✅ Spot Buy: ${spotOrder['executedQty']} BTC @ \$${spotOrder['price']}');
    
    // Step 2: Short equivalent amount in futures
    print('📉 Step 2: Short Futures (Delta Hedge)');
    final futuresShort = await binance.futuresUsd.simulatedTrading.simulatePlaceOrder(
      symbol: 'BTCUSDT',
      side: 'SELL',
      type: 'MARKET',
      quantity: 0.1, // Same amount
      leverage: 1, // 1x leverage for pure hedge
    );
    
    print('   ✅ Futures Short: ${futuresShort['origQty']} BTC @ \$${futuresShort['price']}');
    print('   📊 Unrealized PnL: \$${futuresShort['unrealizedPnl']}');
    
    // Step 3: Calculate strategy performance
    final spotValue = double.parse(spotOrder['executedQty']) * double.parse(spotOrder['price']);
    final futuresValue = double.parse(futuresShort['origQty']) * double.parse(futuresShort['price']);
    final deltaExposure = spotValue - futuresValue;
    
    print('');
    print('📊 Delta Neutral Strategy Summary:');
    print('   💰 Spot Position Value: \$${spotValue.toStringAsFixed(2)}');
    print('   💰 Futures Position Value: \$${futuresValue.toStringAsFixed(2)}');
    print('   ⚖️  Net Delta Exposure: \$${deltaExposure.toStringAsFixed(2)}');
    print('   🎯 Strategy: ${deltaExposure.abs() < 10 ? '✅ Well Hedged' : '⚠️  Needs Adjustment'}');
    print('');
    
    // Advanced: Grid Trading Simulation
    print('📱 Advanced: Grid Trading Setup');
    print('💡 Multiple limit orders at different price levels');
    
    final basePrice = 95000.0; // Current BTC price
    final gridLevels = 5;
    final gridSpacing = 0.01; // 1% spacing
    
    print('🕸️  Setting up ${gridLevels}x${gridLevels} grid around \$${basePrice.toStringAsFixed(0)}:');
    
    // Buy orders below market
    for (int i = 1; i <= gridLevels; i++) {
      final buyPrice = basePrice * (1 - (i * gridSpacing));
      final gridBuyOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'BUY',
        type: 'LIMIT',
        quantity: 0.01,
        price: buyPrice,
      );
      
      print('   📋 Buy Grid Level $i: \$${buyPrice.toStringAsFixed(0)} - ${gridBuyOrder['status']}');
    }
    
    // Sell orders above market
    for (int i = 1; i <= gridLevels; i++) {
      final sellPrice = basePrice * (1 + (i * gridSpacing));
      final gridSellOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: 'BTCUSDT',
        side: 'SELL',
        type: 'LIMIT',
        quantity: 0.01,
        price: sellPrice,
      );
      
      print('   📋 Sell Grid Level $i: \$${sellPrice.toStringAsFixed(0)} - ${gridSellOrder['status']}');
    }
    
    print('');
    print('🎯 Grid Trading Benefits:');
    print('   📈 Profits from price volatility');
    print('   🔄 Automated buy low, sell high');
    print('   ⚖️  Works in ranging markets');
    print('   🛡️  Risk: Trend following can cause losses');
    
  } catch (e) {
    print('❌ Advanced strategy error: $e');
  }
  
  print('');
  print('⚠️  Important Disclaimers:');
  print('   🎓 This is for educational purposes only');
  print('   💡 Real trading involves significant risks');
  print('   📚 Always understand liquidation risks with leverage');
  print('   🛡️  Never risk more than you can afford to lose');
  print('   📖 Study risk management before live trading');
}
