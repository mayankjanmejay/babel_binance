import 'binance_base.dart';

class C2C extends BinanceBase {
  C2C({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getC2CTradeHistory({
    required String tradeType,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'tradeType': tradeType};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/c2c/orderMatch/listUserOrderHistory', params: params);
  }
}