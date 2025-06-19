import 'binance_base.dart';

class Rebate extends BinanceBase {
  Rebate({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getSpotRebateHistoryRecords({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/rebate/taxQuery', params: params);
  }
}