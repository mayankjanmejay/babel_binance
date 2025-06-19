import 'binance_base.dart';

class SimpleEarn extends BinanceBase {
  SimpleEarn({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getSimpleEarnFlexibleProductList({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/simple-earn/flexible/list', params: params);
  }
}