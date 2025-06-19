import 'binance_base.dart';

class VipLoan extends BinanceBase {
  VipLoan({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getVipLoanableAssetsData({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/loan/vip/loanable/data', params: params);
  }
}