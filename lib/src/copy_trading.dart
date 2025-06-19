import 'binance_base.dart';

class CopyTrading extends BinanceBase {
  CopyTrading({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://fapi.binance.com',
        );

  Future<Map<String, dynamic>> getCopyTradingCurrentOpenOrders({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/fapi/v1/copyTrading/openOrders', params: params);
  }
}