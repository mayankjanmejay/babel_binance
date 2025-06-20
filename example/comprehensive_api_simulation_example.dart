import 'package:babel_binance/babel_binance.dart';

void main() async {
  print('🚀 Babel Binance - Comprehensive API Simulation Demo');
  print('=' * 60);
  print('🎯 Demonstrating available simulation capabilities');
  print('💡 Safe testing environment - No real funds at risk!');
  print('');

  final binance = Binance();

  // SECTION 1: Spot Trading Simulation
  print('📊 SECTION 1: Spot Trading Simulation');
  print('-' * 40);
  await _demonstrateSpotTrading(binance);
  print('');

  // SECTION 2: Currency Conversion Simulation
  print('💱 SECTION 2: Currency Conversion Simulation');
  print('-' * 40);
  await _demonstrateConversionSimulation(binance);
  print('');

  // SECTION 3: Futures Trading Simulation
  print('🔮 SECTION 3: Futures Trading Simulation');
  print('-' * 40);
  await _demonstrateFuturesTrading(binance);
  print('');

  // SECTION 4: Margin Trading Simulation
  print('📈 SECTION 4: Margin Trading Simulation');
  print('-' * 40);
  await _demonstrateMarginTrading(binance);
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

Future<void> _demonstrateSpotTrading(Binance binance) async {
  try {
    print('🎯 Simulating Spot Trading Strategies');
    
    // Market Buy Order
    print('💰 Executing Market Buy Order');
    final buyOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
      symbol: 'BTCUSDT',
      side: 'BUY',
      type: 'MARKET',
      quantity: 0.01, // Buy 0.01 BTC
    );
    
    print('   ✅ Market Buy Executed: ${buyOrder['orderId']}');
    print('   💰 Amount: ${buyOrder['executedQty']} BTC');
    print('   💵 Cost: \$${buyOrder['cummulativeQuoteQty']}');
    print('   📊 Status: ${buyOrder['status']}');
    print('');

    // Limit Sell Order
    print('💎 Placing Limit Sell Order');
    final sellOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
      symbol: 'ETHUSDT',
      side: 'SELL',
      type: 'LIMIT',
      quantity: 0.5, // Sell 0.5 ETH
      price: 3500.0, // Target price $3500
      timeInForce: 'GTC',
    );
    
    print('   ✅ Limit Sell Placed: ${sellOrder['orderId']}');
    print('   💰 Target Amount: ${sellOrder['origQty']} ETH');
    print('   💵 Target Price: \$${sellOrder['price']}');
    print('   📊 Status: ${sellOrder['status']}');
    print('');

    // Check Order Status
    print('📊 Checking Order Status');
    final btcStatus = await binance.spot.simulatedTrading.simulateOrderStatus(
      symbol: 'BTCUSDT',
      orderId: int.parse(buyOrder['orderId'].toString()),
    );
    
    print('   🔍 BTC Order Status: ${btcStatus['status']}');
    print('   📈 Executed: ${btcStatus['executedQty']} / ${btcStatus['origQty']}');
    if (btcStatus['fills'] != null && btcStatus['fills'].isNotEmpty) {
      final fill = btcStatus['fills'][0];
      print('   💰 Average Price: \$${fill['price']}');
      print('   🏷️  Commission: ${fill['commission']} ${fill['commissionAsset']}');
    }
    print('');

    // Portfolio-style trading
    print('🎯 Portfolio Diversification Strategy');
    final symbols = ['BNBUSDT', 'ADAUSDT', 'SOLUSDT'];
    final amounts = [0.5, 1000.0, 2.0];
    
    for (int i = 0; i < symbols.length; i++) {
      final order = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: symbols[i],
        side: 'BUY',
        type: 'MARKET',
        quantity: amounts[i],
      );
      
      final asset = symbols[i].replaceAll('USDT', '');
      print('   ✅ ${asset} Position: ${order['executedQty']} (Cost: \$${order['cummulativeQuoteQty']})');
    }

  } catch (e) {
    print('❌ Spot trading simulation error: $e');
  }
}

Future<void> _demonstrateConversionSimulation(Binance binance) async {
  try {
    print('💱 Advanced Currency Conversion Strategies');
    
    // Get conversion quote
    print('📋 Getting BTC to ETH Conversion Quote');
    final quote = await binance.simulatedConvert.simulateGetQuote(
      fromAsset: 'BTC',
      toAsset: 'ETH',
      fromAmount: 0.1, // Convert 0.1 BTC to ETH
    );
    
    print('   📊 Quote ID: ${quote['quoteId']}');
    print('   💱 Exchange Rate: ${quote['ratio']}');
    print('   📈 Converting: 0.1 BTC → ${quote['toAmount']} ETH');
    print('   ⏰ Valid for: ${quote['validTime']} seconds');
    print('');

    // Accept the quote
    print('✅ Accepting Conversion Quote');
    final conversion = await binance.simulatedConvert.simulateAcceptQuote(
      quoteId: quote['quoteId'],
    );
    
    if (conversion['orderStatus'] == 'SUCCESS') {
      print('   ✅ Conversion Successful!');
      print('   🆔 Order ID: ${conversion['orderId']}');
      print('   📅 Execution Time: ${DateTime.fromMillisecondsSinceEpoch(conversion['createTime'])}');
    } else {
      print('   ❌ Conversion Failed: ${conversion['failCode']}');
    }
    print('');

    // Check conversion status
    print('🔍 Checking Conversion Status');
    final status = await binance.simulatedConvert.simulateOrderStatus(
      orderId: conversion['orderId'],
    );
    
    print('   📊 Status: ${status['orderStatus']}');
    print('   💰 From: ${status['fromAmount']} ${status['fromAsset']}');
    print('   💎 To: ${status['toAmount']} ${status['toAsset']}');
    print('   🏷️  Fee: ${status['fee']} ${status['feeAsset']}');
    print('');

    // Multiple conversions for portfolio rebalancing
    print('🔄 Portfolio Rebalancing Conversions');
    final conversions = [
      {'from': 'ETH', 'to': 'BNB', 'amount': 1.0},
      {'from': 'BNB', 'to': 'ADA', 'amount': 2.0},
      {'from': 'ADA', 'to': 'SOL', 'amount': 500.0},
    ];

    for (final conv in conversions) {
      final rebalanceQuote = await binance.simulatedConvert.simulateGetQuote(
        fromAsset: conv['from'] as String,
        toAsset: conv['to'] as String,
        fromAmount: conv['amount'] as double,
      );
      
      print('   💱 ${conv['from']} → ${conv['to']}: ${rebalanceQuote['toAmount']} (Rate: ${rebalanceQuote['ratio']})');
    }
    print('');

    // Get conversion history
    print('📜 Recent Conversion History');
    final history = await binance.simulatedConvert.simulateConversionHistory(limit: 5);
    
    print('   📊 Recent Conversions: ${history['list'].length}');
    for (final conversion in history['list']) {
      final time = DateTime.fromMillisecondsSinceEpoch(conversion['createTime']);
      print('   💱 ${conversion['fromAmount']} ${conversion['fromAsset']} → ${conversion['toAmount']} ${conversion['toAsset']}');
      print('      📅 ${time.toIso8601String().substring(0, 16)} | Status: ${conversion['orderStatus']}');
    }

  } catch (e) {
    print('❌ Conversion simulation error: $e');
  }
}

Future<void> _demonstrateFuturesTrading(Binance binance) async {
  try {
    print('🔮 Advanced Futures Trading Simulation');
    
    // Long position
    print('📈 Opening Long BTC Futures Position');
    final longOrder = await binance.futuresUsd.simulatedTrading.simulatePlaceOrder(
      symbol: 'BTCUSDT',
      side: 'BUY',
      type: 'MARKET',
      quantity: 0.1, // 0.1 BTC contract
      leverage: 10, // 10x leverage
    );
    
    print('   ✅ Long Position Opened: ${longOrder['orderId']}');
    print('   💰 Quantity: ${longOrder['origQty']} BTC');
    print('   📊 Entry Price: \$${longOrder['price']}');
    print('   ⚡ Leverage: ${longOrder['leverage']}x');
    print('   💵 Notional Value: \$${longOrder['notionalValue']}');
    print('   📈 Unrealized PnL: \$${longOrder['unrealizedPnl']}');
    print('');

    // Short position with stop loss
    print('📉 Opening Short ETH Futures Position');
    final shortOrder = await binance.futuresUsd.simulatedTrading.simulatePlaceOrder(
      symbol: 'ETHUSDT',
      side: 'SELL',
      type: 'LIMIT',
      quantity: 1.0, // 1 ETH contract
      price: 3300.0, // Entry at $3300
      leverage: 5, // 5x leverage
      stopPrice: 3400.0, // Stop loss at $3400
    );
    
    print('   ✅ Short Position Pending: ${shortOrder['orderId']}');
    print('   💰 Quantity: ${shortOrder['origQty']} ETH');
    print('   📊 Target Price: \$${shortOrder['price']}');
    print('   🛡️  Stop Price: \$${shortOrder['stopPrice']}');
    print('   ⚡ Leverage: ${shortOrder['leverage']}x');
    print('');

    // Check position
    print('📊 Checking Futures Position');
    final position = await binance.futuresUsd.simulatedTrading.simulateGetPosition(
      symbol: 'BTCUSDT',
    );
    
    print('   🔍 BTC Position Details:');
    print('   💰 Position Size: ${position['positionAmt']} BTC');
    print('   📊 Entry Price: \$${position['entryPrice']}');
    print('   📈 Mark Price: \$${position['markPrice']}');
    print('   💵 Unrealized PnL: \$${position['unRealizedProfit']}');
    print('   📉 ROE: ${position['percentage']}%');
    print('');

    // Margin management
    print('💼 Futures Margin Management');
    final marginChange = await binance.futuresUsd.simulatedTrading.simulateChangeMargin(
      symbol: 'BTCUSDT',
      type: '1', // Add margin
      amount: 100.0, // Add $100 margin
    );
    
    print('   ✅ Margin Added: \$${marginChange['amount']}');
    print('   📊 Type: ${marginChange['type']}');
    print('   🕐 Time: ${DateTime.fromMillisecondsSinceEpoch(marginChange['time'])}');
    print('');

    // Funding rate analysis
    print('💰 Funding Rate Analysis');
    final fundingRates = await binance.futuresUsd.simulatedTrading.simulateGetFundingRate(
      symbol: 'BTCUSDT',
      limit: 3,
    );
    
    print('   📊 Recent Funding Rates for ${fundingRates['symbol']}:');
    for (final rate in fundingRates['fundingRates']) {
      final time = DateTime.fromMillisecondsSinceEpoch(rate['fundingTime']);
      final ratePercent = (double.parse(rate['fundingRate']) * 100).toStringAsFixed(4);
      print('   💱 ${time.toIso8601String().substring(0, 16)}: ${ratePercent}%');
    }

  } catch (e) {
    print('❌ Futures trading simulation error: $e');
  }
}

Future<void> _demonstrateMarginTrading(Binance binance) async {
  try {
    print('📈 Advanced Margin Trading Simulation');
    
    // Borrow USDT for trading
    print('💰 Borrowing USDT for Margin Trading');
    final borrowResult = await binance.margin.simulatedTrading.simulateBorrow(
      asset: 'USDT',
      amount: 5000.0, // Borrow $5000 USDT
    );
    
    print('   ✅ Borrow Successful: ${borrowResult['tranId']}');
    print('   💰 Borrowed: ${borrowResult['amount']} ${borrowResult['asset']}');
    print('   📅 Time: ${DateTime.fromMillisecondsSinceEpoch(borrowResult['timestamp'])}');
    print('   📊 Status: ${borrowResult['status']}');
    print('');

    // Use borrowed funds for margin trading
    print('📊 Executing Margin Trade with Borrowed Funds');
    final marginOrder = await binance.margin.simulatedTrading.simulatePlaceOrder(
      symbol: 'BTCUSDT',
      side: 'BUY',
      type: 'MARKET',
      quantity: 0.05, // Buy 0.05 BTC on margin
    );
    
    print('   ✅ Margin Order Executed: ${marginOrder['orderId']}');
    print('   💰 Quantity: ${marginOrder['origQty']} BTC');
    print('   📊 Price: \$${marginOrder['price']}');
    print('   💵 Total Value: \$${marginOrder['cummulativeQuoteQty']}');
    print('');

    // Check margin account status
    print('🏦 Checking Margin Account Status');
    final marginAccount = await binance.margin.simulatedTrading.simulateGetMarginAccount();
    
    print('   📊 Account Overview:');
    print('   💰 Total Asset (BTC): ${marginAccount['totalAssetOfBtc']}');
    print('   🔴 Total Liability (BTC): ${marginAccount['totalLiabilityOfBtc']}');
    print('   📈 Margin Level: ${marginAccount['marginLevel']}');
    print('   🔄 Borrow Enabled: ${marginAccount['borrowEnabled']}');
    print('   💸 Transfer Enabled: ${marginAccount['transferEnabled']}');
    print('');

    print('   💎 Asset Breakdown:');
    for (final asset in marginAccount['userAssets']) {
      final borrowed = double.tryParse(asset['borrowed']) ?? 0.0;
      final free = double.tryParse(asset['free']) ?? 0.0;
      if (borrowed > 0 || free > 0) {
        print('   ${asset['asset']}: Free: ${asset['free']}, Borrowed: ${asset['borrowed']}');
        print('      Interest: ${asset['interest']}, Net: ${asset['netAsset']}');
      }
    }
    print('');

    // Repay borrowed amount
    print('💸 Repaying Borrowed USDT');
    final repayResult = await binance.margin.simulatedTrading.simulateRepay(
      asset: 'USDT',
      amount: 1000.0, // Repay $1000 USDT
    );
    
    print('   ✅ Repayment Successful: ${repayResult['tranId']}');
    print('   💰 Repaid: ${repayResult['amount']} ${repayResult['asset']}');
    print('   📅 Time: ${DateTime.fromMillisecondsSinceEpoch(repayResult['timestamp'])}');
    print('   📊 Status: ${repayResult['status']}');

  } catch (e) {
    print('❌ Margin trading simulation error: $e');
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
      {'asset': 'Futures Positions', 'percentage': 28.2, 'value': 31689.11},
      {'asset': 'Margin Trading', 'percentage': 18.8, 'value': 23641.08},
      {'asset': 'Conversion History', 'percentage': 7.5, 'value': 9431.28},
    ];

    for (final allocation in allocations) {
      final bar = '█' * ((allocation['percentage']! as double) / 5).round();
      print('   ${allocation['asset'].toString().padRight(18)}: ${allocation['percentage'].toString().padLeft(5)}% $bar');
      print('   ${' ' * 20} \$${(allocation['value']! as double).toStringAsFixed(2)}');
    }
    print('');

    print('🎖️  Trading Activity Summary:');
    print('   🏆 Completed 28 spot trades');
    print('   🔮 Executed 15 futures positions');
    print('   📈 Managed 8 margin trades');
    print('   💱 Processed 12 conversions');
    print('   ⚡ Average execution time: 234ms');
    print('   📊 Success rate: 96.7%');
    print('');

    print('📊 Performance Analytics:');
    print('   🎯 Sharpe Ratio: 1.84');
    print('   📉 Max Drawdown: -3.2%');
    print('   🔄 Win Rate: 68.5%');
    print('   💰 Average Trade Size: \$1,247');
    print('   ⏱️  Average Hold Time: 2.3 days');
    print('   📈 Best Trade: +12.4% (\$387 profit)');
    print('   📉 Worst Trade: -2.1% (\$67 loss)');
    print('');

    print('🎯 Recommended Next Steps:');
    print('   📚 Review API documentation for live trading');
    print('   🛡️  Set up proper risk management strategies');
    print('   🔐 Configure secure API keys for production');
    print('   📊 Implement portfolio tracking and alerts');
    print('   ⚙️  Develop automated trading algorithms');
    print('   📈 Backtest strategies with historical data');
    print('   🔄 Consider implementing stop-loss mechanisms');
    print('   💼 Diversify across multiple trading strategies');

  } catch (e) {
    print('❌ Portfolio summary error: $e');
  }
}