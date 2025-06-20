import 'binance_base.dart';

class Spot {
  final Market market;
  final UserDataStream userDataStream;

  Spot({String? apiKey, String? apiSecret})
      : market = Market(apiKey: apiKey, apiSecret: apiSecret),
        userDataStream = UserDataStream(apiKey: apiKey, apiSecret: apiSecret);
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

class UserDataStream extends BinanceBase {
  UserDataStream({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> createListenKey() {
    return sendRequest('POST', '/api/v3/userDataStream');
  }

  Future<Map<String, dynamic>> keepAliveListenKey(String listenKey) {
    return sendRequest('PUT', '/api/v3/userDataStream',
        params: {'listenKey': listenKey});
  }

  Future<Map<String, dynamic>> closeListenKey(String listenKey) {
    return sendRequest('DELETE', '/api/v3/userDataStream',
        params: {'listenKey': listenKey});
  }
}