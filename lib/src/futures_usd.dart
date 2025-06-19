import 'binance_base.dart';

class FuturesUsd extends BinanceBase {
  FuturesUsd({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://fapi.binance.com',
        );

  Future<Map<String, dynamic>> getAccountInformation({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/fapi/v2/account', params: params);
  }
}