import 'binance_base.dart';

class Spot {
  final Market market;

  Spot({String? apiKey, String? apiSecret})
      : market = Market(apiKey: apiKey, apiSecret: apiSecret);
}

class Market extends BinanceBase {
  Market({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getServerTime() {
    return sendRequest('GET', '/api/v3/time');
  }

  Future<Map<String, dynamic>> getExchangeInfo() {
    return sendRequest('GET', '/api/v3/exchangeInfo');
  }

  Future<Map<String, dynamic>> getOrderBook(String symbol, {int limit = 100}) {
    return sendRequest('GET', '/api/v3/depth',
        params: {'symbol': symbol, 'limit': limit});
  }
}