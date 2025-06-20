
/// 🌍 Real-World Scenarios with Babel Binance
/// 
/// This example showcases practical, real-world use cases that developers
/// commonly implement with the Binance API. Perfect for understanding how
/// to apply Babel Binance in production applications.

import 'dart:math';
import 'package:babel_binance/babel_binance.dart';

void main() async {
  print('🌍 Real-World Scenarios with Babel Binance');
  print('=' * 50);
  
  final binance = Binance();
  
  // Scenario 1: Cryptocurrency Portfolio Tracker
  await portfolioTrackerScenario(binance);
  
  // Scenario 2: DCA (Dollar Cost Averaging) Bot
  await dcaBotScenario(binance);
  
  // Scenario 3: Market Sentiment Analysis
  await marketSentimentScenario(binance);
  
  // Scenario 4: Arbitrage Opportunity Detection
  await arbitrageDetectionScenario(binance);
  
  // Scenario 5: Risk Management System
  await riskManagementScenario(binance);
  
  print('\n🎯 Ready to build your own crypto application?');
  print('📖 Visit: https://pub.dev/packages/babel_binance');
}

/// 💼 Scenario 1: Cryptocurrency Portfolio Tracker
/// Track multiple assets, calculate portfolio value, and monitor performance
Future<void> portfolioTrackerScenario(Binance binance) async {
  print('\n💼 SCENARIO 1: Portfolio Tracker');
  print('-' * 30);
  
  // Define a sample portfolio
  final portfolio = {
    'BTC': 0.5,      // 0.5 Bitcoin
    'ETH': 2.0,      // 2 Ethereum
    'BNB': 10.0,     // 10 Binance Coin
    'ADA': 1000.0,   // 1000 Cardano
    'SOL': 25.0,     // 25 Solana
  };
  
  print('📊 Analyzing Portfolio Performance...');
  
  double totalValue = 0;
  final performance = <String, Map<String, dynamic>>{};
  
  for (final asset in portfolio.keys) {
    try {
      final symbol = '${asset}USDT';
      final ticker = await binance.spot.market.get24HrTicker(symbol);
      
      final currentPrice = double.parse(ticker['lastPrice']);
      final priceChange24h = double.parse(ticker['priceChangePercent']);
      final volume24h = double.parse(ticker['volume']);
      final holding = portfolio[asset]!;
      final value = currentPrice * holding;
      
      totalValue += value;
      
      performance[asset] = {
        'price': currentPrice,
        'change24h': priceChange24h,
        'holding': holding,
        'value': value,
        'volume24h': volume24h,
      };
      
      final emoji = priceChange24h >= 0 ? '📈' : '📉';
      print('$emoji $asset: \$${currentPrice.toStringAsFixed(2)} '
            '(${priceChange24h >= 0 ? '+' : ''}${priceChange24h.toStringAsFixed(2)}%) '
            '→ \$${value.toStringAsFixed(2)}');
      
      await Future.delayed(Duration(milliseconds: 200));
    } catch (e) {
      print('❌ Error fetching $asset data: $e');
    }
  }
  
  print('\n💰 Portfolio Summary:');
  print('   Total Value: \$${totalValue.toStringAsFixed(2)}');
  
  // Find best and worst performers
  final sortedByChange = performance.entries.toList()
    ..sort((a, b) => b.value['change24h'].compareTo(a.value['change24h']));
  
  print('   🏆 Best Performer: ${sortedByChange.first.key} '
        '(+${sortedByChange.first.value['change24h'].toStringAsFixed(2)}%)');
  print('   📉 Worst Performer: ${sortedByChange.last.key} '
        '(${sortedByChange.last.value['change24h'].toStringAsFixed(2)}%)');
}

/// 📅 Scenario 2: Dollar Cost Averaging (DCA) Bot
/// Simulate automated recurring purchases to reduce volatility impact
Future<void> dcaBotScenario(Binance binance) async {
  print('\n📅 SCENARIO 2: DCA Bot Strategy');
  print('-' * 30);
  
  print('🤖 Simulating 6-Month DCA Strategy...');
    final dcaConfig = {
    'symbol': 'BTCUSDT',
    'monthlyAmount': 500.0,  // $500 per month
    'frequency': 'weekly',   // Weekly purchases
  };
  
  final weeklyAmount = (dcaConfig['monthlyAmount']! as double) / 4; // ~$125 per week
  final weeks = 24; // 6 months
  
  double totalInvested = 0;
  double totalBtc = 0;
  final purchases = <Map<String, dynamic>>[];
  
  print('💰 Investment Plan: \$${weeklyAmount.toStringAsFixed(2)} weekly for $weeks weeks');
  print('🎯 Target: \$${(weeklyAmount * weeks).toStringAsFixed(2)} total investment');
  
  for (int week = 1; week <= weeks; week++) {
    try {
      // Simulate varying Bitcoin prices over time (in real app, this would be current price)
      final simulatedPrice = 50000 + (Random().nextDouble() * 30000); // $50k-$80k range
        final buyOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
        symbol: dcaConfig['symbol']! as String,
        side: 'BUY',
        type: 'MARKET',
        quoteOrderQty: weeklyAmount,
      );
      
      final btcPurchased = double.parse(buyOrder['executedQty']);
      final actualSpent = double.parse(buyOrder['cummulativeQuoteQty']);
      
      totalInvested += actualSpent;
      totalBtc += btcPurchased;
      
      purchases.add({
        'week': week,
        'price': simulatedPrice,
        'amount': actualSpent,
        'btc': btcPurchased,
      });
      
      if (week % 4 == 0) { // Monthly summary
        final month = week ~/ 4;
        print('📊 Month $month Complete: '
              '${btcPurchased.toStringAsFixed(6)} BTC @ \$${simulatedPrice.toStringAsFixed(0)}');
      }
      
      await Future.delayed(Duration(milliseconds: 100));
    } catch (e) {
      print('❌ Week $week purchase failed: $e');
    }
  }
  
  // Calculate final results
  final avgPurchasePrice = totalInvested / totalBtc;
  final currentPrice = 65000.0; // Simulate current price
  final currentValue = totalBtc * currentPrice;
  final profitLoss = currentValue - totalInvested;
  final roi = (profitLoss / totalInvested) * 100;
  
  print('\n📈 DCA Strategy Results:');
  print('   💵 Total Invested: \$${totalInvested.toStringAsFixed(2)}');
  print('   ₿  Total BTC Acquired: ${totalBtc.toStringAsFixed(6)}');
  print('   📊 Average Purchase Price: \$${avgPurchasePrice.toStringAsFixed(2)}');
  print('   💰 Current Value: \$${currentValue.toStringAsFixed(2)}');
  print('   ${roi >= 0 ? '📈' : '📉'} P&L: ${roi >= 0 ? '+' : ''}\$${profitLoss.toStringAsFixed(2)} '
        '(${roi >= 0 ? '+' : ''}${roi.toStringAsFixed(2)}%)');
}

/// 📊 Scenario 3: Market Sentiment Analysis
/// Analyze market trends and sentiment across multiple timeframes
Future<void> marketSentimentScenario(Binance binance) async {
  print('\n📊 SCENARIO 3: Market Sentiment Analysis');
  print('-' * 30);
  
  print('🔍 Analyzing Market Sentiment Across Major Cryptocurrencies...');
  
  final majorCoins = ['BTC', 'ETH', 'BNB', 'ADA', 'SOL', 'DOT', 'AVAX', 'MATIC'];
  final sentimentData = <String, Map<String, dynamic>>{};
  
  for (final coin in majorCoins) {
    try {
      final symbol = '${coin}USDT';
      final ticker = await binance.spot.market.get24HrTicker(symbol);
      
      final priceChange = double.parse(ticker['priceChangePercent']);
      final volume = double.parse(ticker['volume']);
      final trades = int.parse(ticker['tradeCount']);
      
      // Calculate sentiment score (simplified)
      final sentimentScore = _calculateSentimentScore(priceChange, volume, trades);
      
      sentimentData[coin] = {
        'priceChange': priceChange,
        'volume': volume,
        'trades': trades,
        'sentiment': sentimentScore,
      };
      
      await Future.delayed(Duration(milliseconds: 150));
    } catch (e) {
      print('❌ Error analyzing $coin: $e');
    }
  }
  
  // Market overview
  final positiveCoins = sentimentData.values.where((data) => data['sentiment'] > 60).length;
  final negativeCoins = sentimentData.values.where((data) => data['sentiment'] < 40).length;
  final neutralCoins = majorCoins.length - positiveCoins - negativeCoins;
  
  print('\n🌡️  Market Sentiment Overview:');
  print('   🟢 Bullish: $positiveCoins coins');
  print('   🔴 Bearish: $negativeCoins coins');
  print('   ⚪ Neutral: $neutralCoins coins');
  
  // Top performers by sentiment
  final sortedBySentiment = sentimentData.entries.toList()
    ..sort((a, b) => b.value['sentiment'].compareTo(a.value['sentiment']));
  
  print('\n🏆 Sentiment Leaders:');
  for (int i = 0; i < 3 && i < sortedBySentiment.length; i++) {
    final entry = sortedBySentiment[i];
    final sentiment = entry.value['sentiment'].toStringAsFixed(1);
    final change = entry.value['priceChange'].toStringAsFixed(2);
    print('   ${i + 1}. ${entry.key}: ${sentiment}/100 (${change}% change)');
  }
  
  // Market fear & greed index simulation
  final avgSentiment = sentimentData.values
      .map((data) => data['sentiment'] as double)
      .reduce((a, b) => a + b) / sentimentData.length;
  
  final fearGreedLevel = _getFearGreedLevel(avgSentiment);
  print('\n😱 Market Fear & Greed Index: ${avgSentiment.toStringAsFixed(1)}/100 ($fearGreedLevel)');
}

/// 🔍 Scenario 4: Arbitrage Opportunity Detection
/// Find price differences across trading pairs for potential arbitrage
Future<void> arbitrageDetectionScenario(Binance binance) async {
  print('\n🔍 SCENARIO 4: Arbitrage Detection');
  print('-' * 30);
  
  print('⚡ Scanning for Arbitrage Opportunities...');
  
  // Common arbitrage triangles
  final triangles = [
    ['BTC', 'ETH', 'USDT'],   // BTC → ETH → USDT → BTC
    ['BNB', 'BTC', 'USDT'],   // BNB → BTC → USDT → BNB
    ['ETH', 'BNB', 'USDT'],   // ETH → BNB → USDT → ETH
  ];
  
  for (final triangle in triangles) {
    try {
      final opportunities = await _findTriangleArbitrage(binance, triangle);
      
      if (opportunities.isNotEmpty) {
        print('\n💎 Arbitrage Opportunity Found!');
        print('   🔺 Triangle: ${triangle.join(' → ')} → ${triangle[0]}');
        
        for (final opp in opportunities) {
          final profit = opp['profit'] as double;
          final path = opp['path'] as List<String>;
          
          if (profit > 0.1) { // Show opportunities with >0.1% profit
            print('   💰 Potential Profit: ${profit.toStringAsFixed(3)}%');
            print('   🛤️  Path: ${path.join(' → ')}');
          }
        }
      }
      
      await Future.delayed(Duration(milliseconds: 500));
    } catch (e) {
      print('❌ Error checking ${triangle.join('-')}: $e');
    }
  }
  
  print('\n⚠️  Arbitrage Disclaimer:');
  print('   • These are simulated opportunities for demonstration');
  print('   • Real arbitrage requires considering fees, slippage, and speed');
  print('   • Always test thoroughly before implementing live trading');
}

/// ⚠️ Scenario 5: Risk Management System
/// Implement position sizing and risk assessment
Future<void> riskManagementScenario(Binance binance) async {
  print('\n⚠️  SCENARIO 5: Risk Management System');
  print('-' * 30);
  
  print('🛡️  Implementing Comprehensive Risk Management...');
  
  // Portfolio configuration
  final riskConfig = {
    'totalCapital': 50000.0,        // $50k total capital
    'maxRiskPerTrade': 0.02,        // 2% max risk per trade
    'maxPortfolioRisk': 0.10,       // 10% max total portfolio risk
    'maxPositionSize': 0.15,        // 15% max position size
  };
  
  final positions = [
    {'symbol': 'BTCUSDT', 'side': 'LONG', 'size': 0.5, 'entryPrice': 45000.0},
    {'symbol': 'ETHUSDT', 'side': 'LONG', 'size': 2.0, 'entryPrice': 3000.0},
    {'symbol': 'BNBUSDT', 'side': 'SHORT', 'size': 10.0, 'entryPrice': 350.0},
  ];
  
  print('📊 Risk Assessment for Current Positions:');
  
  double totalRisk = 0;
  double totalExposure = 0;
  
  for (final position in positions) {
    try {
      final symbol = position['symbol'] as String;
      final ticker = await binance.spot.market.get24HrTicker(symbol);
      final currentPrice = double.parse(ticker['lastPrice']);
      final entryPrice = position['entryPrice'] as double;
      final size = position['size'] as double;
      final side = position['side'] as String;
      
      // Calculate position value and risk
      final positionValue = currentPrice * size;
      final unrealizedPnL = side == 'LONG' 
          ? (currentPrice - entryPrice) * size
          : (entryPrice - currentPrice) * size;
      
      final riskPercent = (positionValue / riskConfig['totalCapital']!) * 100;
      final pnlPercent = (unrealizedPnL / riskConfig['totalCapital']!) * 100;
      
      totalExposure += positionValue;
      totalRisk += positionValue.abs();
      
      final riskLevel = riskPercent > 15 ? '🔴 HIGH' : 
                       riskPercent > 10 ? '🟡 MEDIUM' : '🟢 LOW';
      
      print('\n💼 ${symbol.replaceAll('USDT', '')} Position:');
      print('   📊 Size: ${size} (${side})');
      print('   💰 Value: \$${positionValue.toStringAsFixed(2)}');
      print('   📈 P&L: ${unrealizedPnL >= 0 ? '+' : ''}\$${unrealizedPnL.toStringAsFixed(2)} '
            '(${pnlPercent >= 0 ? '+' : ''}${pnlPercent.toStringAsFixed(2)}%)');
      print('   ⚠️  Risk Level: $riskLevel (${riskPercent.toStringAsFixed(1)}%)');
      
      await Future.delayed(Duration(milliseconds: 300));
    } catch (e) {
      print('❌ Error assessing ${position['symbol']}: $e');
    }
  }
  
  // Portfolio risk summary
  final totalRiskPercent = (totalRisk / riskConfig['totalCapital']!) * 100;
  final maxRiskPercent = riskConfig['maxPortfolioRisk']! * 100;
  
  print('\n🛡️  Portfolio Risk Summary:');
  print('   💰 Total Capital: \$${riskConfig['totalCapital']!.toStringAsFixed(0)}');
  print('   📊 Total Exposure: \$${totalExposure.toStringAsFixed(2)}');
  print('   ⚠️  Current Risk: ${totalRiskPercent.toStringAsFixed(1)}%');
  print('   🎯 Max Allowed Risk: ${maxRiskPercent.toStringAsFixed(1)}%');
  
  if (totalRiskPercent > maxRiskPercent) {
    print('   🚨 WARNING: Portfolio risk exceeds maximum threshold!');
    print('   💡 Consider reducing position sizes or hedging exposure');
  } else {
    print('   ✅ Portfolio risk within acceptable limits');
  }
  
  // Position sizing recommendation for new trade
  print('\n📏 Position Sizing for New Trade:');
  final newTradeRisk = riskConfig['maxRiskPerTrade']! * riskConfig['totalCapital']!;
  final stopLossPercent = 5.0; // 5% stop loss
  final maxPositionSize = newTradeRisk / (stopLossPercent / 100);
  
  print('   💵 Max Risk per Trade: \$${newTradeRisk.toStringAsFixed(2)}');
  print('   📊 With 5% Stop Loss: Max position \$${maxPositionSize.toStringAsFixed(2)}');
}

// Helper function to calculate sentiment score
double _calculateSentimentScore(double priceChange, double volume, int trades) {
  // Simplified sentiment calculation
  double score = 50; // Neutral baseline
  
  // Price change component (40% weight)
  score += (priceChange * 2).clamp(-20, 20);
  
  // Volume component (30% weight) - higher volume = more conviction
  final volumeScore = (volume / 1000000).clamp(0, 15); // Normalize volume
  score += volumeScore;
  
  // Trading activity (30% weight) - more trades = more interest
  final tradesScore = (trades / 100000).clamp(0, 15); // Normalize trades
  score += tradesScore;
  
  return score.clamp(0, 100);
}

// Helper function to determine fear & greed level
String _getFearGreedLevel(double score) {
  if (score >= 75) return 'Extreme Greed';
  if (score >= 60) return 'Greed';
  if (score >= 40) return 'Neutral';
  if (score >= 25) return 'Fear';
  return 'Extreme Fear';
}

// Helper function to find triangle arbitrage opportunities
Future<List<Map<String, dynamic>>> _findTriangleArbitrage(
  Binance binance, 
  List<String> triangle,
) async {
  // Simplified arbitrage detection for demonstration
  // In real implementation, you'd fetch actual order book data
  
  final opportunities = <Map<String, dynamic>>[];
  
  // Simulate finding a small arbitrage opportunity
  final Random random = Random();
  if (random.nextDouble() > 0.7) { // 30% chance of finding opportunity
    opportunities.add({
      'path': triangle + [triangle[0]], // Complete the triangle
      'profit': random.nextDouble() * 0.5, // 0-0.5% profit
    });
  }
  
  return opportunities;
}
