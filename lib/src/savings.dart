import 'dart:math';
import 'binance_base.dart';

class Savings extends BinanceBase {
  final SavingsProducts products;
  final SavingsActions actions;
  final SimulatedSavings simulatedSavings;

  Savings({String? apiKey, String? apiSecret})
      : products = SavingsProducts(apiKey: apiKey, apiSecret: apiSecret),
        actions = SavingsActions(apiKey: apiKey, apiSecret: apiSecret),
        simulatedSavings =
            SimulatedSavings(apiKey: apiKey, apiSecret: apiSecret),
        super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getFlexibleProductList({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/lending/daily/product/list',
        params: params);
  }
}

class SavingsProducts extends BinanceBase {
  SavingsProducts({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getFlexibleProductList({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/lending/daily/product/list', params: params);
  }

  Future<Map<String, dynamic>> getFixedAndActivityProjectList({
    required String type,
    String? asset,
    String? status,
    int? current,
    int? size,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'type': type};
    if (asset != null) params['asset'] = asset;
    if (status != null) params['status'] = status;
    if (current != null) params['current'] = current;
    if (size != null) params['size'] = size;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/lending/project/list', params: params);
  }

  Future<Map<String, dynamic>> getLeftDailyRedemptionQuota({
    required String productId,
    required String type,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'productId': productId,
      'type': type,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/lending/daily/userLeftQuota',
        params: params);
  }
}

class SavingsActions extends BinanceBase {
  SavingsActions({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> purchaseFlexibleProduct({
    required String productId,
    required double amount,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'productId': productId,
      'amount': amount,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/lending/daily/purchase',
        params: params);
  }

  Future<Map<String, dynamic>> redeemFlexibleProduct({
    required String productId,
    required double amount,
    required String type,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'productId': productId,
      'amount': amount,
      'type': type,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/lending/daily/redeem', params: params);
  }

  Future<Map<String, dynamic>> purchaseFixedProduct({
    required String projectId,
    required int lot,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'projectId': projectId,
      'lot': lot,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/lending/customizedFixed/purchase',
        params: params);
  }

  Future<Map<String, dynamic>> getFlexibleProductPosition({
    String? asset,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{};
    if (asset != null) params['asset'] = asset;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/lending/daily/token/position',
        params: params);
  }

  Future<Map<String, dynamic>> getFixedAndActivityProjectPosition({
    required String asset,
    String? projectId,
    String? status,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'asset': asset};
    if (projectId != null) params['projectId'] = projectId;
    if (status != null) params['status'] = status;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/lending/project/position/list',
        params: params);
  }
}

class SimulatedSavings {
  final String? apiKey;
  final String? apiSecret;
  final Random _random = Random();

  // Simulated flexible savings products with realistic interest rates
  final Map<String, Map<String, dynamic>> _mockFlexibleProducts = {
    'USDT_FLEXIBLE': {
      'asset': 'USDT',
      'avgAnnualInterestRate': 3.5,
      'canPurchase': true,
      'canRedeem': true,
      'dailyInterestPerThousand': 0.00958904,
      'featured': true,
      'minPurchaseAmount': 0.1,
      'productId': 'USDT001',
      'purchasedAmount': 0.0,
      'status': 'PURCHASING',
      'upLimit': 2000000.0,
      'upLimitPerUser': 1000000.0,
    },
    'BUSD_FLEXIBLE': {
      'asset': 'BUSD',
      'avgAnnualInterestRate': 4.2,
      'canPurchase': true,
      'canRedeem': true,
      'dailyInterestPerThousand': 0.01150685,
      'featured': true,
      'minPurchaseAmount': 0.1,
      'productId': 'BUSD001',
      'purchasedAmount': 0.0,
      'status': 'PURCHASING',
      'upLimit': 2000000.0,
      'upLimitPerUser': 1000000.0,
    },
    'BTC_FLEXIBLE': {
      'asset': 'BTC',
      'avgAnnualInterestRate': 1.8,
      'canPurchase': true,
      'canRedeem': true,
      'dailyInterestPerThousand': 0.00493151,
      'featured': false,
      'minPurchaseAmount': 0.001,
      'productId': 'BTC001',
      'purchasedAmount': 0.0,
      'status': 'PURCHASING',
      'upLimit': 100.0,
      'upLimitPerUser': 50.0,
    },
    'ETH_FLEXIBLE': {
      'asset': 'ETH',
      'avgAnnualInterestRate': 2.3,
      'canPurchase': true,
      'canRedeem': true,
      'dailyInterestPerThousand': 0.00630137,
      'featured': false,
      'minPurchaseAmount': 0.01,
      'productId': 'ETH001',
      'purchasedAmount': 0.0,
      'status': 'PURCHASING',
      'upLimit': 1000.0,
      'upLimitPerUser': 500.0,
    },
  };

  // Simulated fixed/locked savings products
  final Map<String, Map<String, dynamic>> _mockFixedProducts = {
    'USDT_30_DAYS': {
      'asset': 'USDT',
      'displayPriority': 1,
      'duration': 30,
      'interestPerLot': 0.75,
      'interestRate': 9.0,
      'lotSize': 100.0,
      'lotsLowLimit': 1,
      'lotsPurchased': 0,
      'lotsUpLimit': 500,
      'maxLotsPerUser': 100,
      'needKyc': false,
      'projectId': 'USDT30001',
      'projectName': 'USDT 30-Day Fixed',
      'status': 'PURCHASING',
      'type': 'CUSTOMIZED_FIXED',
      'withAreaLimitation': false,
    },
    'BNB_60_DAYS': {
      'asset': 'BNB',
      'displayPriority': 2,
      'duration': 60,
      'interestPerLot': 2.5,
      'interestRate': 15.0,
      'lotSize': 10.0,
      'lotsLowLimit': 1,
      'lotsPurchased': 0,
      'lotsUpLimit': 200,
      'maxLotsPerUser': 50,
      'needKyc': false,
      'projectId': 'BNB60001',
      'projectName': 'BNB 60-Day High Yield',
      'status': 'PURCHASING',
      'type': 'ACTIVITY',
      'withAreaLimitation': false,
    },
  };

  // User savings positions
  final Map<String, Map<String, dynamic>> _flexiblePositions = {};
  final Map<String, Map<String, dynamic>> _fixedPositions = {};

  SimulatedSavings({this.apiKey, this.apiSecret});

  Future<Map<String, dynamic>> simulateGetFlexibleProductList({
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    final products = _mockFlexibleProducts.values.map((product) {
      return Map<String, dynamic>.from(product)
        ..['tierAnnualInterestRate'] =
            _generateTierRates(product['avgAnnualInterestRate']);
    }).toList();

    return {
      'code': '000000',
      'message': 'success',
      'data': products,
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateGetFixedProductList({
    required String type,
    String? asset,
    String? status,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    var products = _mockFixedProducts.values.where((product) {
      if (asset != null && product['asset'] != asset) return false;
      if (status != null && product['status'] != status) return false;
      if (type == 'ACTIVITY' && product['type'] != 'ACTIVITY') return false;
      if (type == 'CUSTOMIZED_FIXED' && product['type'] != 'CUSTOMIZED_FIXED')
        return false;
      return true;
    }).toList();

    return {
      'code': '000000',
      'message': 'success',
      'data': products,
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulatePurchaseFlexibleProduct({
    required String productId,
    required double amount,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    // Find product
    final product = _mockFlexibleProducts.values
        .firstWhere((p) => p['productId'] == productId, orElse: () => {});

    if (product.isEmpty) {
      throw Exception('Product not found: $productId');
    }

    if (!product['canPurchase']) {
      throw Exception('Product not available for purchase');
    }

    if (amount < product['minPurchaseAmount']) {
      throw Exception('Amount below minimum: ${product['minPurchaseAmount']}');
    }

    final purchaseId = _generateTransactionId();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Add to user's flexible positions
    final positionKey = '${productId}_${currentTime}';
    _flexiblePositions[positionKey] = {
      'asset': product['asset'],
      'avgAnnualInterestRate': product['avgAnnualInterestRate'],
      'canRedeem': true,
      'dailyInterestRate': product['dailyInterestPerThousand'] / 1000,
      'freeAmount': amount.toString(),
      'freezeAmount': '0',
      'lockedAmount': '0',
      'productId': productId,
      'productName': '${product['asset']} Flexible',
      'redeemingAmount': '0',
      'todayPurchasedAmount': amount.toString(),
      'totalAmount': amount.toString(),
      'totalInterest': '0',
      'purchaseTime': currentTime,
    };

    return {
      'purchaseId': int.parse(purchaseId),
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateRedeemFlexibleProduct({
    required String productId,
    required double amount,
    required String type,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    // Find positions for this product
    final userPositions = _flexiblePositions.entries
        .where((entry) => entry.value['productId'] == productId)
        .toList();

    if (userPositions.isEmpty) {
      throw Exception('No positions found for product: $productId');
    }

    double totalAvailable = 0;
    for (final position in userPositions) {
      totalAvailable += double.parse(position.value['freeAmount']);
    }

    if (amount > totalAvailable) {
      throw Exception('Insufficient balance. Available: $totalAvailable');
    }

    // Process redemption
    double remainingAmount = amount;
    final redeemId = _generateTransactionId();

    for (final position in userPositions) {
      if (remainingAmount <= 0) break;

      final freeAmount = double.parse(position.value['freeAmount']);
      final redeemFromThis =
          remainingAmount > freeAmount ? freeAmount : remainingAmount;

      // Update position
      position.value['freeAmount'] = (freeAmount - redeemFromThis).toString();
      position.value['totalAmount'] =
          (double.parse(position.value['totalAmount']) - redeemFromThis)
              .toString();

      remainingAmount -= redeemFromThis;

      // Remove position if fully redeemed
      if (double.parse(position.value['totalAmount']) == 0) {
        _flexiblePositions.remove(position.key);
      }
    }

    return {
      'redeemId': int.parse(redeemId),
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulatePurchaseFixedProduct({
    required String projectId,
    required int lot,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    // Find product
    final product = _mockFixedProducts.values
        .firstWhere((p) => p['projectId'] == projectId, orElse: () => {});

    if (product.isEmpty) {
      throw Exception('Project not found: $projectId');
    }

    if (product['status'] != 'PURCHASING') {
      throw Exception('Project not available for purchase');
    }

    if (lot < product['lotsLowLimit']) {
      throw Exception('Lot below minimum: ${product['lotsLowLimit']}');
    }

    if (lot > product['maxLotsPerUser']) {
      throw Exception('Lot exceeds user limit: ${product['maxLotsPerUser']}');
    }

    final purchaseId = _generateTransactionId();
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final amount = lot * product['lotSize'];
    final maturityTime =
        currentTime + (product['duration'] * 24 * 60 * 60 * 1000);

    // Add to user's fixed positions
    final positionKey = '${projectId}_${currentTime}';
    _fixedPositions[positionKey] = {
      'asset': product['asset'],
      'canTransfer': false,
      'createTime': currentTime,
      'duration': product['duration'],
      'endTime': maturityTime,
      'interest': (amount * product['interestRate'] / 100).toString(),
      'interestRate': product['interestRate'],
      'lot': lot,
      'positionId': int.parse(purchaseId),
      'principal': amount.toString(),
      'projectId': projectId,
      'projectName': product['projectName'],
      'purchaseTime': currentTime,
      'redeemDate': maturityTime.toString(),
      'status': 'HOLDING',
      'type': product['type'],
    };

    return {
      'purchaseId': purchaseId,
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateGetFlexibleProductPosition({
    String? asset,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    var positions = _flexiblePositions.values.where((position) {
      if (asset != null && position['asset'] != asset) return false;
      return true;
    }).toList();

    // Calculate accrued interest for each position
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    for (final position in positions) {
      final purchaseTime = position['purchaseTime'] as int;
      final dailyRate = position['dailyInterestRate'] as double;
      final amount = double.parse(position['totalAmount']);
      final daysPassed = (currentTime - purchaseTime) / (24 * 60 * 60 * 1000);
      final accruedInterest = amount * dailyRate * daysPassed;

      position['totalInterest'] = accruedInterest.toStringAsFixed(8);
    }

    return {
      'code': '000000',
      'message': 'success',
      'data': positions,
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateGetFixedProductPosition({
    required String asset,
    String? projectId,
    String? status,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    var positions = _fixedPositions.values.where((position) {
      if (position['asset'] != asset) return false;
      if (projectId != null && position['projectId'] != projectId) return false;
      if (status != null && position['status'] != status) return false;
      return true;
    }).toList();

    return {
      'code': '000000',
      'message': 'success',
      'data': positions,
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateGetLeftDailyRedemptionQuota({
    required String productId,
    required String type,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    final product = _mockFlexibleProducts.values
        .firstWhere((p) => p['productId'] == productId, orElse: () => {});

    if (product.isEmpty) {
      return {
        'asset': 'UNKNOWN',
        'dailyQuota': '0',
        'leftQuota': '0',
        'minRedemptionAmount': '0',
      };
    }

    final dailyQuota = product['upLimitPerUser'] * 0.1; // 10% of max per day
    final used =
        _random.nextDouble() * dailyQuota * 0.3; // Random usage up to 30%
    final leftQuota = dailyQuota - used;

    return {
      'asset': product['asset'],
      'dailyQuota': dailyQuota.toStringAsFixed(8),
      'leftQuota': leftQuota.toStringAsFixed(8),
      'minRedemptionAmount': product['minPurchaseAmount'].toString(),
    };
  }

  // Helper methods
  Future<void> _simulateDataRetrievalDelay() async {
    final delay = 100 + _random.nextInt(300); // 100-400ms
    await Future.delayed(Duration(milliseconds: delay));
  }

  Future<void> _simulateTransactionDelay() async {
    final delay = 200 + _random.nextInt(800); // 200ms-1s
    await Future.delayed(Duration(milliseconds: delay));
  }

  String _generateTransactionId() {
    return '${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(9999)}';
  }

  Map<String, dynamic> _generateTierRates(double baseRate) {
    return {
      '0-5000': (baseRate - 0.5).toStringAsFixed(2),
      '5000-100000': baseRate.toStringAsFixed(2),
      '100000+': (baseRate + 0.3).toStringAsFixed(2),
    };
  }
}