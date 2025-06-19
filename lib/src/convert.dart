import 'binance_base.dart';

class Convert extends BinanceBase {
  Convert({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getConvertTradeHistory({
    required int startTime,
    required int endTime,
    int? recvWindow,
  }) {
    final params = {'startTime': startTime, 'endTime': endTime};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/convert/tradeFlow', params: params.cast<String, dynamic>());
  }
}