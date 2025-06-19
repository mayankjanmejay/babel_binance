import 'binance_base.dart';

class FuturesAlgo extends BinanceBase {
  FuturesAlgo({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://fapi.binance.com',
        );

  Future<Map<String, dynamic>> getFuturesAlgoOpenOrders({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/fapi/v1/algo/openOrders', params: params);
  }
}