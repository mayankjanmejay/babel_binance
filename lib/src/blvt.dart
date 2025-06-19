import 'binance_base.dart';

class Blvt extends BinanceBase {
  Blvt({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getBlvtInfo({String? tokenName, int? recvWindow}) {
    final params = <String, dynamic>{};
    if (tokenName != null) params['tokenName'] = tokenName;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/blvt/tokenInfo', params: params);
  }
}