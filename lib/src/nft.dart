import 'binance_base.dart';

class Nft extends BinanceBase {
  Nft({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getNftTransactionHistory({
    required int orderType,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'orderType': orderType};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/nft/history/transactions', params: params);
  }
}