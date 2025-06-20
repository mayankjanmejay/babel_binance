import 'package:babel_binance/babel_binance.dart';

void main() async {
  print('🚀 Babel Binance - Comprehensive API Simulation Demo');
  print('=' * 60);
  print('🎯 Demonstrating simulation capabilities across available APIs');
  print('💡 Safe testing environment - No real funds at risk!');
  print('');

  final binance = Binance();

  // SECTION 1: Spot Trading Simulation
  print('📊 SECTION 1: Spot Trading Simulation');
  print('-' * 40);
  await _demonstrateSpotTradingSimulation(binance);
  print('');

  // SECTION 2: Currency Conversion Simulation
  print('💱 SECTION 2: Currency Conversion Simulation');
  print('-' * 40);
  await _demonstrateConversionSimulation(binance);
  print('');

  // SECTION 3: Futures Trading Simulation
  print('🚀 SECTION 3: Futures Trading Simulation');
  print('-' * 40);
  await _demonstrateFuturesSimulation(binance);
  print('');

  // SECTION 4: Margin Trading Simulation
  print('⚡ SECTION 4: Margin Trading Simulation');
  print('-' * 40);
  await _demonstrateMarginSimulation(binance);
  print('');

  // SECTION 5: Portfolio Performance Summary
  print('📈 SECTION 5: Portfolio Performance Summary');
  print('-' * 40);
  await _demonstratePortfolioSummary(binance);
  print('');

  print('✅ Comprehensive API Simulation Demo Complete!');
  print('');
  print('💡 Key Benefits Demonstrated:');
  print('   🛡️  Risk-free testing environment');
  print('   ⚡ Realistic timing and behavior simulation');
  print('   📚 Learn APIs without rate limits');
  print('   🔧 Perfect for bot development & testing');
  print('   🎓 Educational trading strategy exploration');
  print('');
  print('⚠️  Remember: This is simulation only!');
  print('   📖 Study each API thoroughly before live trading');
  print('   🛡️  Always understand risks in real markets');
  print('   💰 Never risk more than you can afford to lose');
}

Future<void> _demonstrateSpotTradingSimulation(Binance binance) async {
  try {
    print('🎯 Spot Trading Strategy Simulation');
    
    // Market buy order
    print('💰 Executing Market Buy Order for BTC');
    final buyOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
      symbol: 'BTCUSDT',
      side: 'BUY',
      type: 'MARKET',
      quantity: 0.5, // Buy 0.5 BTC
    );
    
    print('✅ Market Buy Order Executed:');
    print('   Order ID: ${buyOrder['orderId']}');
    print('   💰 Amount: ${buyOrder['executedQty']} BTC');
    print('   💵 Cost: \$${buyOrder['cummulativeQuoteQty']}');
    print('   📊 Status: ${buyOrder['status']}');
    print('');

    // Limit sell order
    print('📈 Placing Limit Sell Order for ETH');
    final sellOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
      symbol: 'ETHUSDT',
      side: 'SELL',
      type: 'LIMIT',
      quantity: 2.0, // Sell 2 ETH
      price: 3300.0, // Target price
      timeInForce: 'GTC',
    );
    
    print('✅ Limit Sell Order Placed:');
    print('   Order ID: ${sellOrder['orderId']}');
    print('   💰 Target Amount: ${sellOrder['origQty']} ETH');
    print('   💵 Target Price: \$${sellOrder['price']}');
    print('   📊 Status: ${sellOrder['status']}');
    print('');

    // Check order status
    print('🔍 Checking Order Status');
    final orderStatus = await binance.spot.simulatedTrading.simulateOrderStatus(
      symbol: 'BTCUSDT',
      orderId: int.parse(buyOrder['orderId'].toString()),
    );
    
    print('📊 BTC Order Status Update:');
    print('   Status: ${orderStatus['status']}');
    print('   Executed: ${orderStatus['executedQty']} / ${orderStatus['origQty']} BTC');
    print('   Value: \$${orderStatus['cummulativeQuoteQty']}');
    
    // Multiple asset strategy
    print('');
    print('🎯 Multi-Asset Trading Strategy');
    final assets = ['BNBUSDT', 'ADAUSDT', 'SOLUSDT'];
    
    for (final symbol in assets) {
      final order = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: symbol,
        side: 'BUY',
        type: 'MARKET',
        quantity: symbol == 'BNBUSDT' ? 10.0 : (symbol == 'ADAUSDT' ? 1000.0 : 5.0),
      );
      
      print('   ✅ ${symbol.replaceAll('USDT', '')}: ${order['executedQty']} @ \$${order['cummulativeQuoteQty']}');
    }

  } catch (e) {
    print('❌ Spot trading simulation error: $e');
  }
}

Future<void> _demonstrateConversionSimulation(Binance binance) async {
  try {
    print('💱 Currency Conversion Strategy');
    
    // Get conversion quote
    print('📋 Getting Conversion Quote: BTC → USDT');
    final quote = await binance.simulatedConvert.simulateGetQuote(
      fromAsset: 'BTC',
      toAsset: 'USDT',
      fromAmount: 0.1, // Convert 0.1 BTC
    );
    
    print('💰 Conversion Quote Details:');
    print('   Quote ID: ${quote['quoteId']}');
    print('   From: 0.1 BTC');
    print('   To: ${quote['toAmount']} USDT');
    print('   Rate: 1 BTC = ${quote['ratio']} USDT');
    print('   Valid for: ${quote['validTime']} seconds');
    print('');

    // Accept conversion
    print('✅ Accepting Conversion Quote');
    final conversion = await binance.simulatedConvert.simulateAcceptQuote(
      quoteId: quote['quoteId'],
    );
    
    if (conversion['orderStatus'] == 'SUCCESS') {
      print('🎉 Conversion Successful:');
      print('   Order ID: ${conversion['orderId']}');
      print('   Status: ${conversion['orderStatus']}');
      print('');

      // Check conversion status
      print('🔍 Checking Conversion Details');
      final status = await binance.simulatedConvert.simulateOrderStatus(
        orderId: conversion['orderId'],
      );
      
      print('📊 Conversion Results:');
      print('   From: ${status['fromAmount']} ${status['fromAsset']}');
      print('   To: ${status['toAmount']} ${status['toAsset']}');
      print('   Fee: ${status['fee']} ${status['feeAsset']}');
      print('   Final Rate: ${(double.parse(status['toAmount']) / double.parse(status['fromAmount'])).toStringAsFixed(2)}');
    } else {
      print('❌ Conversion Failed: ${conversion['errorMsg']}');
    }
    
    // Multi-currency conversion strategy
    print('');
    print('🔄 Multi-Currency Conversion Portfolio');
    final conversions = [
      {'from': 'ETH', 'to': 'BTC', 'amount': 1.0},
      {'from': 'BNB', 'to': 'USDT', 'amount': 5.0},
      {'from': 'USDT', 'to': 'ETH', 'amount': 1000.0},
    ];
    
    for (final conv in conversions) {
      final convQuote = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: conv['from']! as String,
        toAsset: conv['to']! as String,
        fromAmount: conv['amount']! as double,
      );
      
      print('   💱 ${conv['from']} → ${conv['to']}: ${convQuote['toAmount']} (Rate: ${convQuote['ratio']})');
    }
    
    // Conversion history
    print('');
    print('📜 Recent Conversion History');
    final history = await binance.simulatedConvert.simulateConversionHistory(limit: 3);
    
    print('🕐 Last ${history['list'].length} Conversions:');
    for (final conv in history['list']) {
      print('   ${conv['fromAmount']} ${conv['fromAsset']} → ${conv['toAmount']} ${conv['toAsset']}');
      print('   Time: ${DateTime.fromMillisecondsSinceEpoch(conv['createTime']).toIso8601String().substring(0, 16)}');
    }

  } catch (e) {
    print('❌ Conversion simulation error: $e');
  }
}

Future<void> _demonstrateFuturesSimulation(Binance binance) async {
  try {
    print('🚀 Futures Trading with Leverage');
    
    // Long position
    print('📈 Opening Long Position on BTC Futures');
    final longOrder = await binance.futuresUsd.simulatedTrading.simulatePlaceOrder(
      symbol: 'BTCUSDT',
      side: 'BUY',
      type: 'MARKET',
      quantity: 2.0, // 2 BTC contracts
      leverage: 10, // 10x leverage
    );
    
    print('✅ Long Position Opened:');
    print('   Order ID: ${longOrder['orderId']}');
    print('   Position: ${longOrder['origQty']} BTC (10x leverage)');
    print('   Entry Price: \$${longOrder['price']}');
    print('   Margin Required: \$${longOrder['marginRequired']}');
    print('   Notional Value: \$${longOrder['notionalValue']}');
    print('');

    // Short position
    print('📉 Opening Short Position on ETH Futures');
    final shortOrder = await binance.futuresUsd.simulatedTrading.simulatePlaceOrder(
      symbol: 'ETHUSDT',
      side: 'SELL',
      type: 'LIMIT',
      quantity: 5.0, // 5 ETH contracts
      price: 3250.0, // Short at $3250
      leverage: 5, // 5x leverage
      timeInForce: 'GTC',
    );
    
    print('✅ Short Position Placed:');
    print('   Order ID: ${shortOrder['orderId']}');
    print('   Position: ${shortOrder['origQty']} ETH (5x leverage)');
    print('   Target Price: \$${shortOrder['price']}');
    print('   Status: ${shortOrder['status']}');
    print('');

    // Check position
    print('🔍 Checking Futures Position');
    final position = await binance.futuresUsd.simulatedTrading.simulateGetPosition(
      symbol: 'BTCUSDT',
    );
    
    print('📊 BTC Futures Position:');
    print('   Size: ${position['positionAmt']} BTC');
    print('   Entry Price: \$${position['entryPrice']}');
    print('   Mark Price: \$${position['markPrice']}');
    print('   Unrealized PnL: \$${position['unRealizedProfit']}');
    print('   Margin Ratio: ${(double.parse(position['marginRatio']) * 100).toStringAsFixed(2)}%');
    
    // Margin adjustment
    print('');
    print('⚖️ Adjusting Position Margin');
    final marginChange = await binance.futuresUsd.simulatedTrading.simulateChangeMargin(
      symbol: 'BTCUSDT',
      type: '1', // Add margin
      amount: 500.0, // Add $500 margin
    );
    
    print('✅ Margin Adjustment:');
    print('   Type: ${marginChange['type']}');
    print('   Amount: \$${marginChange['amount']}');
    print('   Status: Success');
    
    // Funding rate check
    print('');
    print('💰 Funding Rate Analysis');
    final fundingRate = await binance.futuresUsd.simulatedTrading.simulateGetFundingRate(
      symbol: 'BTCUSDT',
      limit: 3,
    );
    
    print('📊 Recent Funding Rates for BTCUSDT:');
    for (final rate in fundingRate['fundingRates'].take(3)) {
      final time = DateTime.fromMillisecondsSinceEpoch(rate['fundingTime']);
      final ratePercent = (double.parse(rate['fundingRate']) * 100).toStringAsFixed(4);
      print('   ${time.toIso8601String().substring(0, 16)}: ${ratePercent}%');
    }

  } catch (e) {
    print('❌ Futures simulation error: $e');
  }
}

Future<void> _demonstrateMarginSimulation(Binance binance) async {
  try {
    print('⚡ Margin Trading Operations');
    
    // Borrow funds
    print('💰 Borrowing USDT for Margin Trading');
    final borrow = await binance.margin.simulatedTrading.simulateBorrow(
      asset: 'USDT',
      amount: 5000.0, // Borrow $5000 USDT
    );
    
    print('✅ Margin Borrow Success:');
    print('   Transaction ID: ${borrow['tranId']}');
    print('   Borrowed: ${borrow['amount']} ${borrow['asset']}');
    print('   Type: ${borrow['type']}');
    print('   Status: ${borrow['status']}');
    print('');

    // Margin buy order
    print('📈 Executing Margin Buy Order');
    final marginOrder = await binance.margin.simulatedTrading.simulatePlaceOrder(
      symbol: 'BTCUSDT',
      side: 'BUY',
      type: 'MARKET',
      quantity: 0.2, // Buy 0.2 BTC with borrowed funds
    );
    
    print('✅ Margin Order Executed:');
    print('   Order ID: ${marginOrder['orderId']}');
    print('   Quantity: ${marginOrder['origQty']} BTC');
    print('   Price: \$${marginOrder['price']}');
    print('   Status: ${marginOrder['status']}');
    print('');

    // Check margin account
    print('🔍 Checking Margin Account Status');
    final marginAccount = await binance.margin.simulatedTrading.simulateGetMarginAccount();
    
    print('📊 Margin Account Summary:');
    print('   Borrow Enabled: ${marginAccount['borrowEnabled']}');
    print('   Trade Enabled: ${marginAccount['tradeEnabled']}');
    print('   Transfer Enabled: ${marginAccount['transferEnabled']}');
    print('   Margin Level: ${marginAccount['marginLevel']}');
    print('   Total Asset (BTC): ${marginAccount['totalAssetOfBtc']}');
    print('   Total Liability (BTC): ${marginAccount['totalLiabilityOfBtc']}');
    print('   Net Asset (BTC): ${marginAccount['totalNetAssetOfBtc']}');
    print('');

    print('💎 Asset Breakdown:');
    for (final asset in marginAccount['userAssets']) {
      final free = double.parse(asset['free']);
      final borrowed = double.parse(asset['borrowed']);
      if (free > 0 || borrowed > 0) {
        print('   ${asset['asset']}:');
        print('     Free: ${asset['free']}');
        print('     Borrowed: ${asset['borrowed']}');
        print('     Interest: ${asset['interest']}');
        print('     Net: ${asset['netAsset']}');
      }
    }
    
    // Repay loan
    print('');
    print('💸 Partial Loan Repayment');
    final repay = await binance.margin.simulatedTrading.simulateRepay(
      asset: 'USDT',
      amount: 2000.0, // Repay $2000
    );
    
    print('✅ Repayment Success:');
    print('   Transaction ID: ${repay['tranId']}');
    print('   Repaid: ${repay['amount']} ${repay['asset']}');
    print('   Type: ${repay['type']}');
    print('   Status: ${repay['status']}');

  } catch (e) {
    print('❌ Margin simulation error: $e');
  }
}

Future<void> _demonstratePortfolioSummary(Binance binance) async {
  try {
    print('📈 Portfolio Performance Analysis');
    print('');

    // Simulate portfolio metrics
    final portfolioValue = 125750.45;
    final dailyPnl = 2340.12;
    final weeklyPnl = 8920.55;
    final monthlyPnl = 15425.80;

    print('💰 Total Portfolio Value: \$${portfolioValue.toStringAsFixed(2)}');
    print('📊 Performance Metrics:');
    print('   📅 24h P&L: ${dailyPnl >= 0 ? '+' : ''}\$${dailyPnl.toStringAsFixed(2)} (${((dailyPnl / portfolioValue) * 100).toStringAsFixed(2)}%)');
    print('   📅 7d P&L: ${weeklyPnl >= 0 ? '+' : ''}\$${weeklyPnl.toStringAsFixed(2)} (${((weeklyPnl / portfolioValue) * 100).toStringAsFixed(2)}%)');
    print('   📅 30d P&L: ${monthlyPnl >= 0 ? '+' : ''}\$${monthlyPnl.toStringAsFixed(2)} (${((monthlyPnl / portfolioValue) * 100).toStringAsFixed(2)}%)');
    print('');

    print('🎯 Asset Allocation Breakdown:');
    final allocations = [
      {'asset': 'Spot Trading', 'percentage': 45.5, 'value': 57216.46},
      {'asset': 'Futures Positions', 'percentage': 35.2, 'value': 44264.16},
      {'asset': 'Margin Trading', 'percentage': 19.3, 'value': 24269.84},
    ];

    for (final allocation in allocations) {
      final bar = '█' * ((allocation['percentage']! as double) / 5).round();
      print('   ${allocation['asset'].toString().padRight(18)}: ${allocation['percentage'].toString().padLeft(5)}% $bar');
      print('   ${' ' * 20} \$${(allocation['value']! as double).toStringAsFixed(2)}');
    }
    print('');

    print('🎖️  Trading Achievement Summary:');
    print('   🏆 Completed 47 spot trades');
    print('   🚀 Executed 23 futures positions');
    print('   ⚡ Performed 15 margin trades');
    print('   💱 Processed 31 currency conversions');
    print('   📊 Analyzed 156 market data points');
    print('   ⏱️  Average order execution: 245ms');
    print('');

    print('📈 Strategy Performance Insights:');
    print('   🎯 Spot Trading: +${((57216.46 / portfolioValue) * dailyPnl / 45.5 * 100).toStringAsFixed(2)}% (24h)');
    print('   🚀 Futures Trading: +${((44264.16 / portfolioValue) * dailyPnl / 35.2 * 100).toStringAsFixed(2)}% (24h)');
    print('   ⚡ Margin Trading: +${((24269.84 / portfolioValue) * dailyPnl / 19.3 * 100).toStringAsFixed(2)}% (24h)');
    print('');

    print('🎯 Recommended Next Steps:');
    print('   📚 Review API documentation for live trading');
    print('   🛡️  Set up proper risk management strategies');
    print('   🔐 Configure secure API keys for production');
    print('   📊 Implement portfolio tracking and alerts');
    print('   ⚙️  Develop automated trading algorithms');
    print('   📈 Backtest strategies with historical data');
    print('   🧪 Continue testing in simulation mode');

  } catch (e) {
    print('❌ Portfolio summary error: $e');
  }
}
