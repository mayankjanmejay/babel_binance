import 'package:babel_binance/babel_binance.dart';

void main() async {
  final binance = Binance(
    apiKey: 'YOUR_API_KEY',
    apiSecret: 'YOUR_API_SECRET',
  );

  print('=== Binance Dart API Example ===\n');

  // Example 1: Get server time
  try {
    final serverTime = await binance.spot.market.getServerTime();
    print('Server Time: ${serverTime['serverTime']}');
  } catch (e) {
    print('Error getting server time: $e');
  }

  // Example 2: Get exchange info
  try {
    final exchangeInfo = await binance.spot.market.getExchangeInfo();
    print('Exchange has ${exchangeInfo['symbols'].length} trading pairs');
  } catch (e) {
    print('Error getting exchange info: $e');
  }

  // Example 3: Get order book
  try {
    final orderBook =
        await binance.spot.market.getOrderBook('BTCUSDT', limit: 10);
    print('BTC/USDT Order Book - Best bid: ${orderBook['bids'][0][0]}');
  } catch (e) {
    print('Error getting order book: $e');
  }

  print('\n=== Simulated Trading Examples ===\n');

  // Example 4: Simulate a market buy order
  print('Simulating market buy order...');
  final marketOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
    symbol: 'BTCUSDT',
    side: 'BUY',
    type: 'MARKET',
    quantity: 0.001,
  );
  print(
      'Market Order Result: ${marketOrder['status']} - Order ID: ${marketOrder['orderId']}');
  print('Executed Quantity: ${marketOrder['executedQty']} BTC');
  print('Total Cost: ${marketOrder['cummulativeQuoteQty']} USDT\n');

  // Example 5: Simulate a limit sell order
  print('Simulating limit sell order...');
  final limitOrder = await binance.spot.simulatedTrading.simulatePlaceOrder(
    symbol: 'ETHUSDT',
    side: 'SELL',
    type: 'LIMIT',
    quantity: 0.1,
    price: 3250.0,
    timeInForce: 'GTC',
  );
  print(
      'Limit Order Result: ${limitOrder['status']} - Order ID: ${limitOrder['orderId']}');
  print('Order Price: ${limitOrder['price']} USDT');
  print('Order Quantity: ${limitOrder['origQty']} ETH\n');

  // Example 6: Check order status
  print('Checking order status...');
  final orderStatus = await binance.spot.simulatedTrading.simulateOrderStatus(
    symbol: 'BTCUSDT',
    orderId: int.parse(marketOrder['orderId'].toString()),
  );
  print('Order Status: ${orderStatus['status']}');
  print(
      'Executed: ${orderStatus['executedQty']} / ${orderStatus['origQty']}\n');

  print('=== Simulated Convert Examples ===\n');

  // Example 7: Get conversion quote
  print('Getting conversion quote...');
  final quote = await binance.simulatedConvert.simulateGetQuote(
    fromAsset: 'BTC',
    toAsset: 'USDT',
    fromAmount: 0.001,
  );
  print('Quote ID: ${quote['quoteId']}');
  print('Converting 0.001 BTC to ${quote['toAmount']} USDT');
  print('Exchange Rate: ${quote['ratio']}');
  print('Quote valid for: ${quote['validTime']} seconds\n');

  // Example 8: Accept conversion quote
  print('Accepting conversion quote...');
  final conversion = await binance.simulatedConvert.simulateAcceptQuote(
    quoteId: quote['quoteId'],
  );
  print('Conversion Result: ${conversion['orderStatus']}');
  print('Conversion Order ID: ${conversion['orderId']}\n');

  // Example 9: Check conversion status
  if (conversion['orderStatus'] == 'SUCCESS') {
    print('Checking conversion status...');
    final conversionStatus = await binance.simulatedConvert.simulateOrderStatus(
      orderId: conversion['orderId'],
    );
    print('Conversion Status: ${conversionStatus['orderStatus']}');
    print(
        'From: ${conversionStatus['fromAmount']} ${conversionStatus['fromAsset']}');
    print('To: ${conversionStatus['toAmount']} ${conversionStatus['toAsset']}');
    print('Fee: ${conversionStatus['fee']} ${conversionStatus['feeAsset']}\n');
  }

  // Example 10: Get conversion history
  print('Getting conversion history...');
  final history =
      await binance.simulatedConvert.simulateConversionHistory(limit: 5);
  print('Recent conversions: ${history['list'].length}');
  for (var conversion in history['list']) {
    print(
        '  ${conversion['fromAmount']} ${conversion['fromAsset']} → ${conversion['toAmount']} ${conversion['toAsset']}');
  }

  print('\n=== Timing Analysis ===\n');

  // Example 11: Measure processing times
  final stopwatch = Stopwatch();

  // Measure order processing time
  stopwatch.start();
  await binance.spot.simulatedTrading.simulatePlaceOrder(
    symbol: 'BNBUSDT',
    side: 'BUY',
    type: 'MARKET',
    quantity: 1.0,
  );
  stopwatch.stop();
  print('Order processing time: ${stopwatch.elapsedMilliseconds}ms');

  // Measure quote processing time
  stopwatch.reset();
  stopwatch.start();
  await binance.simulatedConvert.simulateGetQuote(
    fromAsset: 'ETH',
    toAsset: 'BNB',
    fromAmount: 1.0,
  );
  stopwatch.stop();
  print('Quote processing time: ${stopwatch.elapsedMilliseconds}ms');

  // Measure conversion processing time
  stopwatch.reset();
  stopwatch.start();
  await binance.simulatedConvert.simulateAcceptQuote(quoteId: 'test_quote');
  stopwatch.stop();
  print('Conversion processing time: ${stopwatch.elapsedMilliseconds}ms');

  print('\n=== Example Complete ===');
}
