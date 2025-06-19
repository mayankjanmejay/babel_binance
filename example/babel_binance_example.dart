import 'package:babel_binance/babel_binance.dart';

void main() async {
  final binance = Binance(
    apiKey: 'YOUR_API_KEY',
    apiSecret: 'YOUR_API_SECRET',
  );

  // Get server time
  try {
    final serverTime = await binance.spot.market.getServerTime();
    print('Server Time: $serverTime');
  } catch (e) {
    print('Error getting server time: $e');
  }

  // Get exchange info
  try {
    final exchangeInfo = await binance.spot.market.getExchangeInfo();
    print('Exchange Info: $exchangeInfo');
  } catch (e) {
    print('Error getting exchange info: $e');
  }

  // Get order book
  try {
    final orderBook =
        await binance.spot.market.getOrderBook('BTCUSDT', limit: 10);
    print('Order Book: $orderBook');
  } catch (e) {
    print('Error getting order book: $e');
  }
}
