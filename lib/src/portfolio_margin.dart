import 'binance_base.dart';

class PortfolioMargin extends BinanceBase {
  PortfolioMargin({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getPortfolioMarginAccountInfo({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/portfolio/account', params: params);
  }
}