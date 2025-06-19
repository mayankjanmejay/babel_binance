import 'binance_base.dart';

class Fiat extends BinanceBase {
  Fiat({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getFiatDepositWithdrawHistory({
    required String transactionType, // "0" for deposit, "1" for withdraw
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'transactionType': transactionType};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/fiat/orders', params: params);
  }
}