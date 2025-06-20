import 'dart:math';
import 'binance_base.dart';

class Staking extends BinanceBase {
  final StakingProducts products;
  final StakingActions actions;
  final SimulatedStaking simulatedStaking;

  Staking({String? apiKey, String? apiSecret})
      : products = StakingProducts(apiKey: apiKey, apiSecret: apiSecret),
        actions = StakingActions(apiKey: apiKey, apiSecret: apiSecret),
        simulatedStaking =
            SimulatedStaking(apiKey: apiKey, apiSecret: apiSecret),
        super(
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

class StakingProducts extends BinanceBase {
  StakingProducts({String? apiKey, String? apiSecret})
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

  Future<Map<String, dynamic>> getStakingHistory({
    required String product,
    required String txnType,
    String? asset,
    int? startTime,
    int? endTime,
    int? current,
    int? size,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'product': product,
      'txnType': txnType,
    };
    if (asset != null) params['asset'] = asset;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (current != null) params['current'] = current;
    if (size != null) params['size'] = size;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/staking/stakingRecord', params: params);
  }
}

class StakingActions extends BinanceBase {
  StakingActions({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> purchaseStakingProduct({
    required String product,
    required String productId,
    required double amount,
    String? renewable,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'product': product,
      'productId': productId,
      'amount': amount,
    };
    if (renewable != null) params['renewable'] = renewable;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/staking/purchase', params: params);
  }

  Future<Map<String, dynamic>> redeemStakingProduct({
    required String product,
    required String productId,
    required String positionId,
    required double amount,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'product': product,
      'productId': productId,
      'positionId': positionId,
      'amount': amount,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/staking/redeem', params: params);
  }

  Future<Map<String, dynamic>> getStakingPosition({
    required String product,
    String? productId,
    String? asset,
    int? current,
    int? size,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'product': product};
    if (productId != null) params['productId'] = productId;
    if (asset != null) params['asset'] = asset;
    if (current != null) params['current'] = current;
    if (size != null) params['size'] = size;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/staking/position', params: params);
  }
}

class SimulatedStaking {
  final String? apiKey;
  final String? apiSecret;
  final Random _random = Random();

  // Simulated staking products with realistic APY rates
  final Map<String, Map<String, dynamic>> _mockStakingProducts = {
    'ETH2': {
      'asset': 'ETH',
      'apy': 5.2,
      'duration': 'Flexible',
      'minAmount': 0.1,
      'maxAmount': 10000.0,
      'risk': 'Low',
      'productId': 'ETH2_001',
      'status': 'PURCHASING',
    },
    'DOT': {
      'asset': 'DOT',
      'apy': 12.5,
      'duration': '90',
      'minAmount': 10.0,
      'maxAmount': 50000.0,
      'risk': 'Medium',
      'productId': 'DOT_001',
      'status': 'PURCHASING',
    },
    'ADA': {
      'asset': 'ADA',
      'apy': 7.8,
      'duration': '30',
      'minAmount': 100.0,
      'maxAmount': 100000.0,
      'risk': 'Low',
      'productId': 'ADA_001',
      'status': 'PURCHASING',
    },
    'SOL': {
      'asset': 'SOL',
      'apy': 8.9,
      'duration': '60',
      'minAmount': 5.0,
      'maxAmount': 25000.0,
      'risk': 'Medium',
      'productId': 'SOL_001',
      'status': 'PURCHASING',
    },
    'ATOM': {
      'asset': 'ATOM',
      'apy': 15.3,
      'duration': '120',
      'minAmount': 10.0,
      'maxAmount': 30000.0,
      'risk': 'High',
      'productId': 'ATOM_001',
      'status': 'PURCHASING',
    },
  };

  // Simulated staking positions
  final Map<String, Map<String, dynamic>> _stakingPositions = {};

  SimulatedStaking({this.apiKey, this.apiSecret});

  Future<Map<String, dynamic>> simulateGetStakingProductList({
    required String product,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    final productList = <Map<String, dynamic>>[];

    if (product == 'STAKING' || product == 'ALL') {
      _mockStakingProducts.forEach((key, value) {
        productList.add({
          'projectId': value['productId'],
          'detail': {
            'asset': value['asset'],
            'rewardAsset': value['asset'],
            'duration': value['duration'],
            'renewable': value['duration'] == 'Flexible',
            'apy': value['apy'].toString(),
            'minPurchaseAmount': value['minAmount'].toString(),
            'maxPurchaseAmount': value['maxAmount'].toString(),
            'status': value['status'],
            'interestCalculationDate': '1',
            'upLimit': value['maxAmount'].toString(),
            'upLimitPerUser': value['maxAmount'].toString(),
          }
        });
      });
    }

    return {
      'code': '000000',
      'message': 'success',
      'data': productList,
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulatePurchaseStakingProduct({
    required String product,
    required String productId,
    required double amount,
    String? renewable,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    // Find the product
    final productData = _mockStakingProducts.values
        .firstWhere((p) => p['productId'] == productId, orElse: () => {});

    if (productData.isEmpty) {
      throw Exception('Product not found: $productId');
    }

    // Validate amount
    if (amount < productData['minAmount']) {
      throw Exception('Amount below minimum: ${productData['minAmount']}');
    }
    if (amount > productData['maxAmount']) {
      throw Exception('Amount above maximum: ${productData['maxAmount']}');
    }

    final positionId = _generatePositionId();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Create staking position
    _stakingPositions[positionId] = {
      'positionId': positionId,
      'productId': productId,
      'asset': productData['asset'],
      'amount': amount,
      'purchaseTime': currentTime,
      'status': 'HOLDING',
      'apy': productData['apy'],
      'duration': productData['duration'],
      'renewable': renewable == 'true' || productData['duration'] == 'Flexible',
      'accruedRewards': 0.0,
      'maturityTime': productData['duration'] == 'Flexible'
          ? null
          : currentTime +
              (int.parse(productData['duration']) * 24 * 60 * 60 * 1000),
    };

    return {
      'code': '000000',
      'message': 'success',
      'data': {
        'positionId': positionId,
        'purchaseId': _generateTransactionId(),
      },
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateRedeemStakingProduct({
    required String product,
    required String productId,
    required String positionId,
    required double amount,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    final position = _stakingPositions[positionId];
    if (position == null) {
      throw Exception('Position not found: $positionId');
    }

    final stakedAmount = position['amount'] as double;
    if (amount > stakedAmount) {
      throw Exception('Redeem amount exceeds staked amount');
    }

    // Check if locked period has passed (if applicable)
    final maturityTime = position['maturityTime'] as int?;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    if (maturityTime != null && currentTime < maturityTime) {
      // Early redemption may have penalties
      final penaltyRate = _random.nextDouble() * 0.05; // 0-5% penalty
      final penalty = amount * penaltyRate;
      amount = amount - penalty;
    }

    // Calculate accrued rewards
    final apy = position['apy'] as double;
    final purchaseTime = position['purchaseTime'] as int;
    final stakingDurationMs = currentTime - purchaseTime;
    final stakingDurationYears =
        stakingDurationMs / (365.25 * 24 * 60 * 60 * 1000);
    final rewards = amount * (apy / 100) * stakingDurationYears;

    // Update or remove position
    if (amount == stakedAmount) {
      _stakingPositions.remove(positionId);
    } else {
      position['amount'] = stakedAmount - amount;
    }

    final redeemId = _generateTransactionId();

    return {
      'code': '000000',
      'message': 'success',
      'data': {
        'redeemId': redeemId,
        'amount': amount.toString(),
        'rewards': rewards.toString(),
        'asset': position['asset'],
        'status': 'SUCCESS',
      },
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateGetStakingPosition({
    required String product,
    String? productId,
    String? asset,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    final positions = <Map<String, dynamic>>[];
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    _stakingPositions.forEach((posId, position) {
      // Filter by asset if specified
      if (asset != null && position['asset'] != asset) return;

      // Filter by productId if specified
      if (productId != null && position['productId'] != productId) return;

      // Calculate current rewards
      final apy = position['apy'] as double;
      final purchaseTime = position['purchaseTime'] as int;
      final amount = position['amount'] as double;
      final stakingDurationMs = currentTime - purchaseTime;
      final stakingDurationYears =
          stakingDurationMs / (365.25 * 24 * 60 * 60 * 1000);
      final accruedRewards = amount * (apy / 100) * stakingDurationYears;

      positions.add({
        'positionId': posId,
        'projectId': position['productId'],
        'asset': position['asset'],
        'amount': position['amount'].toString(),
        'purchaseTime': position['purchaseTime'].toString(),
        'duration': position['duration'],
        'accrualDays': (stakingDurationMs / (24 * 60 * 60 * 1000)).floor(),
        'rewardAsset': position['asset'],
        'apy': position['apy'].toString(),
        'rewardAmt': accruedRewards.toStringAsFixed(8),
        'extraRewardAsset': '',
        'extraRewardAPY': '0',
        'estExtraRewardAmt': '0',
        'nextInterestPay': accruedRewards.toStringAsFixed(8),
        'nextInterestPayDate': (currentTime + 24 * 60 * 60 * 1000).toString(),
        'payInterestPeriod': '1',
        'redeemAmountEarly': position['amount'].toString(),
        'interestEndDate': position['maturityTime']?.toString() ?? '',
        'deliverDate': position['maturityTime']?.toString() ?? '',
        'redeemPeriod': '1',
        'redeemingAmt': '0',
        'partialAmtDeliverDate': '',
        'canRedeemEarly': position['duration'] == 'Flexible',
        'renewable': position['renewable'],
        'type': position['duration'] == 'Flexible'
            ? 'ACTIVITY'
            : 'CUSTOMIZED_FIXED',
        'status': position['status'],
      });
    });

    return {
      'code': '000000',
      'message': 'success',
      'data': positions,
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateGetStakingHistory({
    required String product,
    required String txnType,
    String? asset,
    int? startTime,
    int? endTime,
    int? current,
    int? size,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    final history = <Map<String, dynamic>>[];
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final limit = size ?? 10;

    // Generate mock history based on txnType
    for (int i = 0; i < limit; i++) {
      final time = currentTime - (i * 24 * 60 * 60 * 1000); // Daily intervals

      if (startTime != null && time < startTime) break;
      if (endTime != null && time > endTime) continue;

      final assetName = asset ?? _getRandomAsset();

      history.add({
        'positionId': _generatePositionId(),
        'time': time.toString(),
        'asset': assetName,
        'project': '${assetName}_STAKING',
        'amount': (_random.nextDouble() * 1000 + 100).toStringAsFixed(8),
        'lockPeriod': _random.nextInt(120) + 30, // 30-150 days
        'deliverDate': (time + (90 * 24 * 60 * 60 * 1000)).toString(),
        'type': txnType,
        'status': _random.nextDouble() > 0.1 ? 'SUCCESS' : 'PENDING',
        'txnId': _generateTransactionId(),
      });
    }

    return {
      'code': '000000',
      'message': 'success',
      'data': history,
      'success': true,
    };
  }

  // Helper methods
  Future<void> _simulateDataRetrievalDelay() async {
    final delay = 150 + _random.nextInt(350); // 150-500ms
    await Future.delayed(Duration(milliseconds: delay));
  }

  Future<void> _simulateTransactionDelay() async {
    final delay = 300 + _random.nextInt(1200); // 300ms-1.5s
    await Future.delayed(Duration(milliseconds: delay));
  }

  String _generatePositionId() {
    return 'pos_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}';
  }

  String _generateTransactionId() {
    return 'txn_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}';
  }

  String _getRandomAsset() {
    final assets = [
      'ETH',
      'DOT',
      'ADA',
      'SOL',
      'ATOM',
      'MATIC',
      'AVAX',
      'NEAR'
    ];
    return assets[_random.nextInt(assets.length)];
  }
}