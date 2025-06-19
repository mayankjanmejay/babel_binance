import 'binance_base.dart';

class FuturesCoin extends BinanceBase {
  FuturesCoin({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://dapi.binance.com',
        );

  Future<Map<String, dynamic>> getAccountInformation({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/dapi/v1/account', params: params);
  }
}