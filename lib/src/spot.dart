import 'binance_base.dart';

class Spot extends BinanceBase {
  Spot({String? apiKey, String? apiSecret})
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
}