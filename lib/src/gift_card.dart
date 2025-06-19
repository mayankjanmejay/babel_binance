import 'binance_base.dart';

class GiftCard extends BinanceBase {
  GiftCard({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> verifyGiftCardCode({
    required String referenceNo,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'referenceNo': referenceNo};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/giftcard/verify', params: params);
  }
}