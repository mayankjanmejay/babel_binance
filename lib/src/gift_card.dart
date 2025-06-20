import 'dart:math';
import 'binance_base.dart';

// Gift Card Models
class GiftCardToken {
  final String token;
  final String referenceNo;
  final String status;
  final double amount;
  final String asset;
  final DateTime createTime;
  final DateTime? expireTime;
  final bool isRedeemed;
  final String? redeemedBy;
  final DateTime? redeemedTime;

  GiftCardToken({
    required this.token,
    required this.referenceNo,
    required this.status,
    required this.amount,
    required this.asset,
    required this.createTime,
    this.expireTime,
    required this.isRedeemed,
    this.redeemedBy,
    this.redeemedTime,
  });

  Map<String, dynamic> toJson() => {
        'token': token,
        'referenceNo': referenceNo,
        'status': status,
        'amount': amount.toString(),
        'asset': asset,
        'createTime': createTime.millisecondsSinceEpoch,
        if (expireTime != null)
          'expireTime': expireTime!.millisecondsSinceEpoch,
        'isRedeemed': isRedeemed,
        if (redeemedBy != null) 'redeemedBy': redeemedBy,
        if (redeemedTime != null)
          'redeemedTime': redeemedTime!.millisecondsSinceEpoch,
      };
}

class GiftCardRedemption {
  final String referenceNo;
  final String identityNo;
  final double amount;
  final String asset;
  final DateTime redemptionTime;
  final String status;

  GiftCardRedemption({
    required this.referenceNo,
    required this.identityNo,
    required this.amount,
    required this.asset,
    required this.redemptionTime,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'referenceNo': referenceNo,
        'identityNo': identityNo,
        'amount': amount.toString(),
        'asset': asset,
        'redemptionTime': redemptionTime.millisecondsSinceEpoch,
        'status': status,
      };
}

class BuyCryptoBuyInfo {
  final String referenceNo;
  final String orderNo;
  final double createTime;
  final double amount;
  final String asset;
  final String status;

  BuyCryptoBuyInfo({
    required this.referenceNo,
    required this.orderNo,
    required this.createTime,
    required this.amount,
    required this.asset,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'referenceNo': referenceNo,
        'orderNo': orderNo,
        'createTime': createTime,
        'amount': amount.toString(),
        'asset': asset,
        'status': status,
      };
}

// Gift Card Management
class GiftCardManager {
  static final List<GiftCardToken> _tokens = [];
  static final List<GiftCardRedemption> _redemptions = [];
  static final List<BuyCryptoBuyInfo> _buyOrders = [];
  static final Random _random = Random();

  static String _generateReferenceNo() {
    return DateTime.now().millisecondsSinceEpoch.toString() +
        _random.nextInt(1000).toString().padLeft(3, '0');
  }

  static Future<Map<String, dynamic>> createToken({
    required String token,
    required double amount,
    required String asset,
  }) async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(500)));

    // Validate amount
    if (amount <= 0) {
      throw Exception('Amount must be positive');
    }

    // Validate supported assets
    final supportedAssets = ['BTC', 'ETH', 'BNB', 'USDT', 'BUSD'];
    if (!supportedAssets.contains(asset)) {
      throw Exception('Unsupported asset');
    }

    // Simulate success rate
    if (_random.nextDouble() < 0.95) {
      final referenceNo = _generateReferenceNo();
      final now = DateTime.now();

      final giftCardToken = GiftCardToken(
        token: token,
        referenceNo: referenceNo,
        status: 'SUCCESS',
        amount: amount,
        asset: asset,
        createTime: now,
        expireTime: now.add(Duration(days: 365)), // 1 year expiry
        isRedeemed: false,
      );

      _tokens.add(giftCardToken);

      return {
        'referenceNo': referenceNo,
        'code': token,
        'status': 'SUCCESS',
      };
    } else {
      throw Exception('Gift card creation failed');
    }
  }

  static Future<Map<String, dynamic>> verifyToken({
    required String referenceNo,
  }) async {
    await Future.delayed(Duration(milliseconds: 150 + _random.nextInt(200)));

    final token =
        _tokens.where((t) => t.referenceNo == referenceNo).firstOrNull;

    if (token == null) {
      return {
        'valid': false,
        'message': 'Gift card not found',
      };
    }

    if (token.expireTime != null && DateTime.now().isAfter(token.expireTime!)) {
      return {
        'valid': false,
        'message': 'Gift card has expired',
      };
    }

    if (token.isRedeemed) {
      return {
        'valid': false,
        'message': 'Gift card already redeemed',
      };
    }

    return {
      'valid': true,
      'data': token.toJson(),
    };
  }

  static Future<Map<String, dynamic>> redeemToken({
    required String token,
    required String identityNo,
  }) async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(400)));

    final tokenData =
        _tokens.where((t) => t.token == token && !t.isRedeemed).firstOrNull;

    if (tokenData == null) {
      throw Exception('Invalid token or already redeemed');
    }

    if (tokenData.expireTime != null &&
        DateTime.now().isAfter(tokenData.expireTime!)) {
      throw Exception('Gift card has expired');
    }

    // Simulate success rate
    if (_random.nextDouble() < 0.95) {
      final now = DateTime.now();

      // Update token
      final updatedToken = GiftCardToken(
        token: tokenData.token,
        referenceNo: tokenData.referenceNo,
        status: tokenData.status,
        amount: tokenData.amount,
        asset: tokenData.asset,
        createTime: tokenData.createTime,
        expireTime: tokenData.expireTime,
        isRedeemed: true,
        redeemedBy: identityNo,
        redeemedTime: now,
      );

      final index = _tokens.indexOf(tokenData);
      _tokens[index] = updatedToken;

      // Add redemption record
      final redemption = GiftCardRedemption(
        referenceNo: tokenData.referenceNo,
        identityNo: identityNo,
        amount: tokenData.amount,
        asset: tokenData.asset,
        redemptionTime: now,
        status: 'SUCCESS',
      );

      _redemptions.add(redemption);

      return {
        'referenceNo': tokenData.referenceNo,
        'identityNo': identityNo,
        'status': 'SUCCESS',
      };
    } else {
      throw Exception('Redemption failed');
    }
  }

  static Future<Map<String, dynamic>> buyCrypto({
    required String token,
    required double amount,
    required String asset,
  }) async {
    await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(600)));

    // Simulate success rate
    if (_random.nextDouble() < 0.90) {
      final referenceNo = _generateReferenceNo();
      final orderNo = 'ORDER_${DateTime.now().millisecondsSinceEpoch}';

      final buyInfo = BuyCryptoBuyInfo(
        referenceNo: referenceNo,
        orderNo: orderNo,
        createTime: DateTime.now().millisecondsSinceEpoch.toDouble(),
        amount: amount,
        asset: asset,
        status: 'SUCCESS',
      );

      _buyOrders.add(buyInfo);

      return {
        'referenceNo': referenceNo,
        'orderNo': orderNo,
        'status': 'SUCCESS',
      };
    } else {
      throw Exception('Buy crypto order failed');
    }
  }

  static List<GiftCardToken> getTokenHistory({
    String? asset,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    var tokens = List<GiftCardToken>.from(_tokens);

    if (asset != null) {
      tokens = tokens.where((t) => t.asset == asset).toList();
    }

    if (startTime != null) {
      tokens = tokens.where((t) => t.createTime.isAfter(startTime)).toList();
    }

    if (endTime != null) {
      tokens = tokens.where((t) => t.createTime.isBefore(endTime)).toList();
    }

    return tokens..sort((a, b) => b.createTime.compareTo(a.createTime));
  }

  static List<GiftCardRedemption> getRedemptionHistory({
    String? asset,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    var redemptions = List<GiftCardRedemption>.from(_redemptions);

    if (asset != null) {
      redemptions = redemptions.where((r) => r.asset == asset).toList();
    }

    if (startTime != null) {
      redemptions = redemptions
          .where((r) => r.redemptionTime.isAfter(startTime))
          .toList();
    }

    if (endTime != null) {
      redemptions =
          redemptions.where((r) => r.redemptionTime.isBefore(endTime)).toList();
    }

    return redemptions
      ..sort((a, b) => b.redemptionTime.compareTo(a.redemptionTime));
  }

  static List<BuyCryptoBuyInfo> getBuyHistory({
    String? asset,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    var buyOrders = List<BuyCryptoBuyInfo>.from(_buyOrders);

    if (asset != null) {
      buyOrders = buyOrders.where((b) => b.asset == asset).toList();
    }

    if (startTime != null) {
      buyOrders = buyOrders
          .where((b) =>
              DateTime.fromMillisecondsSinceEpoch(b.createTime.toInt())
                  .isAfter(startTime))
          .toList();
    }

    if (endTime != null) {
      buyOrders = buyOrders
          .where((b) =>
              DateTime.fromMillisecondsSinceEpoch(b.createTime.toInt())
                  .isBefore(endTime))
          .toList();
    }

    return buyOrders..sort((a, b) => b.createTime.compareTo(a.createTime));
  }
}

// Simulated Gift Card API
class SimulatedGiftCard {
  static bool _simulationMode = false;

  static void enableSimulation() {
    _simulationMode = true;
  }

  static void disableSimulation() {
    _simulationMode = false;
  }

  static bool get isSimulationEnabled => _simulationMode;

  static Future<Map<String, dynamic>> createCode({
    required String token,
    required double amount,
    required String asset,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    return await GiftCardManager.createToken(
      token: token,
      amount: amount,
      asset: asset,
    );
  }

  static Future<Map<String, dynamic>> verifyCode({
    required String referenceNo,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    return await GiftCardManager.verifyToken(referenceNo: referenceNo);
  }

  static Future<Map<String, dynamic>> redeemCode({
    required String token,
    required String identityNo,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    return await GiftCardManager.redeemToken(
      token: token,
      identityNo: identityNo,
    );
  }

  static Future<Map<String, dynamic>> buyCrypto({
    required String token,
    required double amount,
    required String asset,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    return await GiftCardManager.buyCrypto(
      token: token,
      amount: amount,
      asset: asset,
    );
  }

  static Future<Map<String, dynamic>> getTokenHistory({
    int? page,
    int? rows,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 200 + Random().nextInt(150)));

    final tokens = GiftCardManager.getTokenHistory();
    final total = tokens.length;
    final pageNum = page ?? 1;
    final pageSize = rows ?? 10;
    final startIndex = (pageNum - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, total);

    final pageTokens = tokens.sublist(
      startIndex.clamp(0, total),
      endIndex,
    );

    return {
      'data': pageTokens.map((t) => t.toJson()).toList(),
      'page': pageNum,
      'rows': pageSize,
      'total': total,
    };
  }

  static Future<Map<String, dynamic>> getRsaPublicKey() async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 100 + Random().nextInt(50)));

    return {
      'data': 'MIIBIjANBgkqhkiG9w0BAQEFAAOCAQ8AMIIBCgKCAQEA...',
    };
  }
}

class GiftCard extends BinanceBase {
  GiftCard({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  // Enable simulation mode
  void enableSimulation() {
    SimulatedGiftCard.enableSimulation();
  }

  // Disable simulation mode
  void disableSimulation() {
    SimulatedGiftCard.disableSimulation();
  }

  // Check if simulation is enabled
  bool get isSimulationEnabled => SimulatedGiftCard.isSimulationEnabled;

  // Create gift card
  Future<Map<String, dynamic>> createGiftCard({
    required String token,
    required double amount,
    required String asset,
    int? recvWindow,
  }) {
    if (SimulatedGiftCard.isSimulationEnabled) {
      return SimulatedGiftCard.createCode(
        token: token,
        amount: amount,
        asset: asset,
      );
    }

    final params = <String, dynamic>{
      'token': token,
      'amount': amount.toString(),
      'asset': asset,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/giftcard/createCode', params: params);
  }

  // Verify gift card code
  Future<Map<String, dynamic>> verifyGiftCardCode({
    required String referenceNo,
    int? recvWindow,
  }) {
    if (SimulatedGiftCard.isSimulationEnabled) {
      return SimulatedGiftCard.verifyCode(referenceNo: referenceNo);
    }

    final params = <String, dynamic>{'referenceNo': referenceNo};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/giftcard/verify', params: params);
  }

  // Redeem gift card
  Future<Map<String, dynamic>> redeemGiftCard({
    required String code,
    required String externalUid,
    int? recvWindow,
  }) {
    if (SimulatedGiftCard.isSimulationEnabled) {
      return SimulatedGiftCard.redeemCode(
        token: code,
        identityNo: externalUid,
      );
    }

    final params = <String, dynamic>{
      'code': code,
      'externalUid': externalUid,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/giftcard/redeemCode', params: params);
  }

  // Buy crypto with gift card
  Future<Map<String, dynamic>> buyCrypto({
    required String token,
    required double amount,
    required String asset,
    int? recvWindow,
  }) {
    if (SimulatedGiftCard.isSimulationEnabled) {
      return SimulatedGiftCard.buyCrypto(
        token: token,
        amount: amount,
        asset: asset,
      );
    }

    final params = <String, dynamic>{
      'token': token,
      'amount': amount.toString(),
      'asset': asset,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/giftcard/buyCode', params: params);
  }

  // Get gift card token history
  Future<Map<String, dynamic>> getTokenHistory({
    int? page,
    int? rows,
    int? recvWindow,
  }) {
    if (SimulatedGiftCard.isSimulationEnabled) {
      return SimulatedGiftCard.getTokenHistory(page: page, rows: rows);
    }

    final params = <String, dynamic>{};
    if (page != null) params['page'] = page;
    if (rows != null) params['rows'] = rows;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/giftcard/cryptography/rsa-public-key',
        params: params);
  }

  // Get RSA public key for gift card encryption
  Future<Map<String, dynamic>> getRsaPublicKey({int? recvWindow}) {
    if (SimulatedGiftCard.isSimulationEnabled) {
      return SimulatedGiftCard.getRsaPublicKey();
    }

    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/giftcard/cryptography/rsa-public-key',
        params: params);
  }
}