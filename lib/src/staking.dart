import 'binance_base.dart';

class Staking extends BinanceBase {
  Staking({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getStakingProductList({
    required String product,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'product': product};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/staking/productList', params: params);
  }
}