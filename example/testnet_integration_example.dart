/// Babel Binance - Testnet Integration Example
///
/// This example demonstrates how to use Binance's official testnet
/// for realistic testing without using real money.
///
/// Available Testnet Environments:
/// - Spot Testnet: https://testnet.binance.vision/
/// - Demo Trading: https://demo-api.binance.com (alternative)
/// - Futures USD-M Testnet: https://testnet.binancefuture.com/fapi
/// - Futures COIN-M Testnet: https://testnet.binancefuture.com/dapi
///
/// Features covered:
/// - Testnet API key setup
/// - Market data from testnet
/// - Real trading on testnet (no real money)
/// - OCO, OTO, OTOCO advanced orders
/// - WebSocket streaming on testnet
/// - Futures trading on testnet
/// - Demo Trading API (alternative testnet)
/// - Best practices for testing strategies

import 'package:babel_binance/babel_binance.dart';

void main() async {
  print('Binance Testnet Integration Demo');
  print('=' * 50);
  print('Testing with real API endpoints but fake money!');
  print('');

  // Step 1: Setup (Important!)
  await step1_TestnetSetup();

  // Step 2: Basic testnet usage
  await step2_BasicTestnetUsage();

  // Step 3: Trading comparison
  await step3_TradingComparison();

  // Step 4: Advanced testnet features
  await step4_AdvancedTestnetFeatures();

  // Step 5: Demo Trading API
  await step5_DemoTradingApi();

  // Step 6: Best practices
  step6_BestPractices();
}

/// Step 1: Testnet Setup and API Keys
Future<void> step1_TestnetSetup() async {
  print('STEP 1: Testnet Setup');
  print('-' * 30);
  print('');
  print('To use the testnet, you need to:');
  print('');
  print('1. Visit: https://testnet.binance.vision/');
  print('2. Create a testnet account (separate from main Binance)');
  print('3. Generate API keys in the testnet interface');
  print('4. Get free test funds (automatically provided)');
  print('');
  print('IMPORTANT: Testnet API keys are different from live keys!');
  print('   - Never use live API keys with testnet endpoints');
  print('   - Never use testnet API keys with live endpoints');
  print('');
  print('For this demo, we\'ll show how it works without real keys...');
  print('');
  await _pause();
}

/// Step 2: Basic Testnet Usage
Future<void> step2_BasicTestnetUsage() async {
  print('STEP 2: Basic Testnet Usage');
  print('-' * 30);
  print('');
  print('Let\'s compare regular API calls vs testnet calls...');
  print('');

  try {
    final binance = Binance();

    // Regular production API call
    print('Getting market data from PRODUCTION API...');
    final prodTicker = await binance.spot.market.get24HrTicker('BTCUSDT');
    final prodPrice = double.parse(prodTicker['lastPrice']);
    final prodChange = double.parse(prodTicker['priceChangePercent']);

    print('   Production BTC Price: \$${prodPrice.toStringAsFixed(2)}');
    print('   Production 24h Change: ${prodChange.toStringAsFixed(2)}%');
    print('');

    // Note: For actual testnet usage, you would do this:
    /*
    // Testnet API call (requires testnet API keys)
    final testnetBinance = Binance.testnet(
      apiKey: 'your_testnet_api_key',
      apiSecret: 'your_testnet_secret',
    );

    print('Getting market data from TESTNET API...');
    final testTicker = await testnetBinance.testnetSpot.market.get24HrTicker('BTCUSDT');
    final testPrice = double.parse(testTicker['lastPrice']);
    final testChange = double.parse(testTicker['priceChangePercent']);

    print('   Testnet BTC Price: \$${testPrice.toStringAsFixed(2)}');
    print('   Testnet 24h Change: ${testChange.toStringAsFixed(2)}%');
    */

    print('TESTNET DEMO (simulated data):');
    print(
        '   Testnet BTC Price: \$${(prodPrice * 0.98).toStringAsFixed(2)} (test data)');
    print(
        '   Testnet 24h Change: ${(prodChange * 1.1).toStringAsFixed(2)}% (test data)');
    print('');
    print('Key Differences:');
    print(
        '   - Different endpoints: testnet.binance.vision vs api.binance.com');
    print('   - Test data vs real market data');
    print('   - Separate API keys required');
    print('   - No real money involved');
  } catch (e) {
    print('Error: $e');
    print('This might be a network issue or rate limiting.');
  }

  print('');
  await _pause();
}

/// Step 3: Trading Methods Comparison
Future<void> step3_TradingComparison() async {
  print('STEP 3: Trading Methods Comparison');
  print('-' * 30);
  print('');
  print('Let\'s compare the three trading methods available:');
  print('');

  final binance = Binance();

  try {
    // Method 1: Simulated Trading (built-in simulation)
    print('Method 1: SIMULATED TRADING');
    print('   Description: Built-in simulation with mock data');
    print('   Cost: Free');
    print('   API Keys: Not required');
    print('   Network: Local simulation');
    print('');

    print('   Simulating buy order...');
    final simOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
      symbol: 'BTCUSDT',
      side: 'BUY',
      type: 'MARKET',
      quantity: 0.001,
    );

    final simQty = double.parse(simOrder['executedQty']);
    final simCost = double.parse(simOrder['cummulativeQuoteQty']);
    print(
        '   Simulated: Bought ${simQty} BTC for \$${simCost.toStringAsFixed(2)}');
    print('');

    // Method 2: Testnet Trading (real API with test money)
    print('Method 2: TESTNET TRADING');
    print('   Description: Real Binance API with test money');
    print('   Cost: Free (test funds provided)');
    print('   API Keys: Testnet keys required');
    print('   Network: Real API calls to testnet.binance.vision');
    print('');

    // Note: This would require real testnet API keys
    print('   Would place real order on testnet...');
    print('   Example: Buy 0.001 BTC with real testnet API');
    print('   Real order status tracking');
    print('   Real market data (but test environment)');
    print('');

    // Method 3: Live Trading (real money - not demonstrated)
    print('Method 3: LIVE TRADING');
    print('   Description: Real Binance API with real money');
    print('   Cost: Real money at risk');
    print('   API Keys: Live production keys required');
    print('   Network: Real API calls to api.binance.com');
    print('   [NOT demonstrated in this example!]');
    print('');

    // Comparison table
    print('COMPARISON TABLE:');
    print('   +------------------+-------------+-------------+-------------+');
    print('   | Feature          | Simulated   | Testnet     | Live        |');
    print('   +------------------+-------------+-------------+-------------+');
    print('   | Real API calls   | No          | Yes         | Yes         |');
    print('   | Real money       | No          | No          | Yes         |');
    print('   | API keys needed  | No          | Yes         | Yes         |');
    print('   | Order matching   | Simulated   | Real        | Real        |');
    print('   | Market data      | Mock        | Real        | Real        |');
    print('   | Network latency  | None        | Real        | Real        |');
    print('   | Rate limits      | None        | Real        | Real        |');
    print('   | Best for         | Learning    | Testing     | Trading     |');
    print('   +------------------+-------------+-------------+-------------+');
  } catch (e) {
    print('Error in trading comparison: $e');
  }

  print('');
  await _pause();
}

/// Step 4: Advanced Testnet Features
Future<void> step4_AdvancedTestnetFeatures() async {
  print('STEP 4: Advanced Testnet Features');
  print('-' * 30);
  print('');
  print('The testnet supports almost all features of the live API:');
  print('');

  print('SPOT TRADING FEATURES:');
  print('   - Market orders (immediate execution)');
  print('   - Limit orders (pending until price reached)');
  print('   - Stop-loss orders');
  print('   - OCO (One-Cancels-Other) orders');
  print('   - OTO (One-Triggers-Other) orders');
  print('   - OTOCO (One-Triggers-OCO) orders');
  print('   - Cancel-Replace operations');
  print('   - Account balance tracking');
  print('   - Trade history');
  print('');

  print('USD-M FUTURES TRADING FEATURES:');
  print('   - Long and short positions');
  print('   - Leverage up to 125x');
  print('   - Margin management (USDT-margined)');
  print('   - Position sizing');
  print('   - Liquidation simulation');
  print('   - Funding rates');
  print('   - Endpoint: /fapi/v1/*');
  print('');

  print('COIN-M FUTURES TRADING FEATURES:');
  print('   - Inverse contracts (settled in crypto)');
  print('   - BTC, ETH margined positions');
  print('   - Quarterly delivery contracts');
  print('   - Perpetual contracts');
  print('   - Leverage and margin management');
  print('   - Endpoint: /dapi/v1/*');
  print('');

  print('WEBSOCKET FEATURES:');
  print('   - Real-time price updates');
  print('   - Order book streams');
  print('   - User data streams');
  print('   - Trade streams');
  print('   - Kline/candlestick streams');
  print('   - Testnet WebSocket: wss://stream.testnet.binance.vision:9443');
  print('');

  print('MARKET DATA ENDPOINTS:');
  print('   - getServerTime(), ping()');
  print('   - getExchangeInfo()');
  print('   - getOrderBook(), getRecentTrades()');
  print('   - getKlines(), getUIKlines()');
  print('   - get24HrTicker(), getTickerPrice()');
  print('   - getRollingWindowTicker()');
  print('   - getTradingDayTicker()');
  print('');

  // Code example for advanced orders
  print('EXAMPLE: OCO ORDER ON TESTNET');
  print('```dart');
  print('// Initialize testnet');
  print('final binance = Binance.testnet(');
  print('  apiKey: \'testnet_key\',');
  print('  apiSecret: \'testnet_secret\',');
  print(');');
  print('');
  print('// Place OCO order (profit target + stop loss)');
  print('final ocoOrder = await binance.testnetSpot.trading.placeOcoOrder(');
  print('  symbol: \'BTCUSDT\',');
  print('  side: \'SELL\',');
  print('  quantity: 0.001,');
  print('  price: 100000.0,      // Take profit price');
  print('  stopPrice: 90000.0,   // Stop loss trigger');
  print('  stopLimitPrice: 89900.0,');
  print(');');
  print('```');
  print('');

  print('EXAMPLE: WEBSOCKET STREAMING ON TESTNET');
  print('```dart');
  print('// Connect to testnet WebSocket');
  print('final binance = Binance.testnet(...);');
  print('');
  print('// Create user data stream');
  print('final listenKey = await binance.testnetSpot.userDataStream.createListenKey();');
  print('');
  print('// Connect to WebSocket');
  print('final stream = binance.testnetSpot.webSocket.connectUserDataStream(');
  print('  listenKey[\'listenKey\'],');
  print(');');
  print('');
  print('stream.listen((data) {');
  print('  print(\'Account update: \$data\');');
  print('});');
  print('```');
  print('');

  print('EXAMPLE: COIN-M FUTURES ON TESTNET');
  print('```dart');
  print('// Initialize testnet');
  print('final binance = Binance.testnet(');
  print('  apiKey: \'testnet_key\',');
  print('  apiSecret: \'testnet_secret\',');
  print(');');
  print('');
  print('// Get COIN-M futures market data');
  print('final info = await binance.testnetFuturesCoinM.market.getExchangeInfo();');
  print('final ticker = await binance.testnetFuturesCoinM.market.get24HrTicker(\'BTCUSD_PERP\');');
  print('');
  print('// Place a COIN-M futures order');
  print('final order = await binance.testnetFuturesCoinM.trading.placeOrder(');
  print('  symbol: \'BTCUSD_PERP\',');
  print('  side: \'BUY\',');
  print('  type: \'MARKET\',');
  print('  quantity: 1,  // 1 contract = 100 USD');
  print(');');
  print('');
  print('// Get position info');
  print('final positions = await binance.testnetFuturesCoinM.trading.getPositionRisk();');
  print('```');
  print('');
  await _pause();
}

/// Step 5: Demo Trading API
Future<void> step5_DemoTradingApi() async {
  print('STEP 5: Demo Trading API (Alternative Testnet)');
  print('-' * 30);
  print('');
  print('Demo Trading is an alternative to testnet.binance.vision');
  print('Use this if testnet.binance.vision is not accessible in your region.');
  print('');

  print('DEMO TRADING ENDPOINTS:');
  print('   REST API:      https://demo-api.binance.com');
  print('   WebSocket:     wss://demo-stream.binance.com');
  print('   Futures REST:  https://demo-fapi.binance.com');
  print('');

  print('HOW TO GET DEMO API KEYS:');
  print('   1. Log in to your Binance account');
  print('   2. Go to Account Settings > API Management');
  print('   3. Create a Demo Trading API key');
  print('   4. Use these keys with the Demo API endpoints');
  print('');

  print('EXAMPLE: USING DEMO TRADING API');
  print('```dart');
  print('// Initialize with demo trading');
  print('final binance = Binance.demo(');
  print('  apiKey: \'demo_api_key\',');
  print('  apiSecret: \'demo_api_secret\',');
  print(');');
  print('');
  print('// Use demo spot trading');
  print('final ticker = await binance.demoSpot.market.get24HrTicker(\'BTCUSDT\');');
  print('');
  print('// Place order on demo');
  print('final order = await binance.demoSpot.trading.placeOrder(');
  print('  symbol: \'BTCUSDT\',');
  print('  side: \'BUY\',');
  print('  type: \'MARKET\',');
  print('  quantity: 0.001,');
  print(');');
  print('');
  print('// Demo futures trading');
  print('final position = await binance.demoFutures.trading.getPositionInfo();');
  print('```');
  print('');

  print('TESTNET vs DEMO TRADING:');
  print('   +------------------+-------------------------+-------------------------+');
  print('   | Feature          | Testnet                 | Demo Trading            |');
  print('   +------------------+-------------------------+-------------------------+');
  print('   | URL              | testnet.binance.vision  | demo-api.binance.com    |');
  print('   | API Keys         | Separate testnet keys   | From main account       |');
  print('   | Registration     | Separate account        | Use main account        |');
  print('   | Availability     | May be geo-restricted   | More widely available   |');
  print('   | Funds            | Auto-provided           | Auto-provided           |');
  print('   +------------------+-------------------------+-------------------------+');
  print('');
  await _pause();
}

/// Step 6: Best Practices
void step6_BestPractices() {
  print('STEP 6: Best Practices for Testing');
  print('-' * 30);
  print('');
  print('TESTING STRATEGY PROGRESSION:');
  print('');
  print('1. START WITH SIMULATED TRADING');
  print('   - Learn the API structure');
  print('   - Test your logic flow');
  print('   - No network dependencies');
  print('   - Instant feedback');
  print('');
  print('2. MOVE TO TESTNET/DEMO');
  print('   - Test with real API calls');
  print('   - Experience real latency');
  print('   - Handle real error responses');
  print('   - Test rate limiting');
  print('');
  print('3. PAPER TRADING (if available)');
  print('   - Real market data');
  print('   - Real-time execution simulation');
  print('   - Track performance metrics');
  print('');
  print('4. LIVE TRADING (small amounts)');
  print('   - Start with minimal capital');
  print('   - Monitor closely');
  print('   - Scale up gradually');
  print('');
  print('SAFETY GUIDELINES:');
  print('');
  print('DO:');
  print('   - Test thoroughly on testnet first');
  print('   - Use environment variables for API keys');
  print('   - Implement proper error handling');
  print('   - Set up monitoring and alerts');
  print('   - Keep detailed logs');
  print('   - Start with small amounts');
  print('');
  print('DO NOT:');
  print('   - Skip testing phases');
  print('   - Hard-code API keys');
  print('   - Ignore error responses');
  print('   - Trade without stop-losses');
  print('   - Risk more than you can afford');
  print('   - Mix testnet and live credentials');
  print('');
  print('ENVIRONMENT SETUP:');
  print('');
  print('```bash');
  print('# Development environment variables');
  print('export BINANCE_TESTNET_API_KEY="your_testnet_key"');
  print('export BINANCE_TESTNET_SECRET="your_testnet_secret"');
  print('');
  print('# Demo trading environment variables');
  print('export BINANCE_DEMO_API_KEY="your_demo_key"');
  print('export BINANCE_DEMO_SECRET="your_demo_secret"');
  print('');
  print('# Production environment variables (separate!)');
  print('export BINANCE_API_KEY="your_live_key"');
  print('export BINANCE_SECRET_KEY="your_live_secret"');
  print('```');
  print('');
  print('ADDITIONAL RESOURCES:');
  print('');
  print('Spot Testnet:      https://testnet.binance.vision/');
  print('Demo Trading:      https://demo-api.binance.com');
  print('API Docs:          https://developers.binance.com/docs/');
  print('USD-M Testnet:     https://testnet.binancefuture.com/fapi');
  print('COIN-M Testnet:    https://testnet.binancefuture.com/dapi');
  print('');
  print('Happy testing! Remember: Test first, trade smart!');
}

// Helper function to pause between steps
Future<void> _pause() async {
  print('(Pausing for 3 seconds...)');
  await Future.delayed(Duration(seconds: 3));
  print('');
}
