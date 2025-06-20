import 'dart:math';
import 'binance_base.dart';

// Simple Earn Product Models
class SimpleEarnProduct {
  final String asset;
  final String productId;
  final String productName;
  final double avgAnnualPercentageRate;
  final double minPurchaseAmount;
  final double maxPurchaseAmount;
  final bool canPurchase;
  final bool canRedeem;
  final String status;
  final int? duration; // null for flexible, days for locked

  SimpleEarnProduct({
    required this.asset,
    required this.productId,
    required this.productName,
    required this.avgAnnualPercentageRate,
    required this.minPurchaseAmount,
    required this.maxPurchaseAmount,
    required this.canPurchase,
    required this.canRedeem,
    required this.status,
    this.duration,
  });

  Map<String, dynamic> toJson() => {
        'asset': asset,
        'productId': productId,
        'productName': productName,
        'avgAnnualPercentageRate': avgAnnualPercentageRate.toString(),
        'minPurchaseAmount': minPurchaseAmount.toString(),
        'maxPurchaseAmount': maxPurchaseAmount.toString(),
        'canPurchase': canPurchase,
        'canRedeem': canRedeem,
        'status': status,
        if (duration != null) 'duration': duration,
      };
}

class SimpleEarnPosition {
  final String productId;
  final String asset;
  final double amount;
  final double rewardAmount;
  final DateTime createTime;
  final String status;
  final bool canRedeem;
  final DateTime? lockedUntil;

  SimpleEarnPosition({
    required this.productId,
    required this.asset,
    required this.amount,
    required this.rewardAmount,
    required this.createTime,
    required this.status,
    required this.canRedeem,
    this.lockedUntil,
  });

  Map<String, dynamic> toJson() => {
        'productId': productId,
        'asset': asset,
        'amount': amount.toString(),
        'rewardAmount': rewardAmount.toString(),
        'createTime': createTime.millisecondsSinceEpoch,
        'status': status,
        'canRedeem': canRedeem,
        if (lockedUntil != null)
          'lockedUntil': lockedUntil!.millisecondsSinceEpoch,
      };
}

class SimpleEarnReward {
  final String asset;
  final double amount;
  final DateTime time;
  final String type;

  SimpleEarnReward({
    required this.asset,
    required this.amount,
    required this.time,
    required this.type,
  });

  Map<String, dynamic> toJson() => {
        'asset': asset,
        'amount': amount.toString(),
        'time': time.millisecondsSinceEpoch,
        'type': type,
      };
}

// Simple Earn Product Management
class SimpleEarnProducts {
  static final List<SimpleEarnProduct> _flexibleProducts = [
    SimpleEarnProduct(
      asset: 'USDT',
      productId: 'USDT001',
      productName: 'USDT Flexible Product',
      avgAnnualPercentageRate: 3.5,
      minPurchaseAmount: 1.0,
      maxPurchaseAmount: 100000.0,
      canPurchase: true,
      canRedeem: true,
      status: 'PURCHASING',
    ),
    SimpleEarnProduct(
      asset: 'BUSD',
      productId: 'BUSD001',
      productName: 'BUSD Flexible Product',
      avgAnnualPercentageRate: 3.2,
      minPurchaseAmount: 1.0,
      maxPurchaseAmount: 100000.0,
      canPurchase: true,
      canRedeem: true,
      status: 'PURCHASING',
    ),
    SimpleEarnProduct(
      asset: 'BTC',
      productId: 'BTC001',
      productName: 'BTC Flexible Product',
      avgAnnualPercentageRate: 1.8,
      minPurchaseAmount: 0.001,
      maxPurchaseAmount: 100.0,
      canPurchase: true,
      canRedeem: true,
      status: 'PURCHASING',
    ),
    SimpleEarnProduct(
      asset: 'ETH',
      productId: 'ETH001',
      productName: 'ETH Flexible Product',
      avgAnnualPercentageRate: 2.1,
      minPurchaseAmount: 0.01,
      maxPurchaseAmount: 1000.0,
      canPurchase: true,
      canRedeem: true,
      status: 'PURCHASING',
    ),
  ];

  static final List<SimpleEarnProduct> _lockedProducts = [
    SimpleEarnProduct(
      asset: 'USDT',
      productId: 'USDT_30D',
      productName: 'USDT 30-Day Locked Product',
      avgAnnualPercentageRate: 5.5,
      minPurchaseAmount: 100.0,
      maxPurchaseAmount: 50000.0,
      canPurchase: true,
      canRedeem: false,
      status: 'PURCHASING',
      duration: 30,
    ),
    SimpleEarnProduct(
      asset: 'USDT',
      productId: 'USDT_90D',
      productName: 'USDT 90-Day Locked Product',
      avgAnnualPercentageRate: 6.8,
      minPurchaseAmount: 100.0,
      maxPurchaseAmount: 50000.0,
      canPurchase: true,
      canRedeem: false,
      status: 'PURCHASING',
      duration: 90,
    ),
    SimpleEarnProduct(
      asset: 'BTC',
      productId: 'BTC_60D',
      productName: 'BTC 60-Day Locked Product',
      avgAnnualPercentageRate: 3.5,
      minPurchaseAmount: 0.01,
      maxPurchaseAmount: 10.0,
      canPurchase: true,
      canRedeem: false,
      status: 'PURCHASING',
      duration: 60,
    ),
    SimpleEarnProduct(
      asset: 'ETH',
      productId: 'ETH_120D',
      productName: 'ETH 120-Day Locked Product',
      avgAnnualPercentageRate: 4.2,
      minPurchaseAmount: 0.1,
      maxPurchaseAmount: 100.0,
      canPurchase: true,
      canRedeem: false,
      status: 'PURCHASING',
      duration: 120,
    ),
  ];

  static List<SimpleEarnProduct> getFlexibleProducts({String? asset}) {
    if (asset != null) {
      return _flexibleProducts.where((p) => p.asset == asset).toList();
    }
    return List.from(_flexibleProducts);
  }

  static List<SimpleEarnProduct> getLockedProducts({String? asset}) {
    if (asset != null) {
      return _lockedProducts.where((p) => p.asset == asset).toList();
    }
    return List.from(_lockedProducts);
  }

  static SimpleEarnProduct? getProductById(String productId) {
    try {
      return _flexibleProducts.firstWhere((p) => p.productId == productId);
    } catch (e) {
      try {
        return _lockedProducts.firstWhere((p) => p.productId == productId);
      } catch (e) {
        return null;
      }
    }
  }
}

// Simple Earn Operations
class SimpleEarnOperations {
  static final List<SimpleEarnPosition> _positions = [];
  static final List<SimpleEarnReward> _rewards = [];
  static final Random _random = Random();

  static Future<Map<String, dynamic>> subscribe({
    required String productId,
    required double amount,
    bool autoSubscribe = true,
  }) async {
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    final product = SimpleEarnProducts.getProductById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    if (amount < product.minPurchaseAmount ||
        amount > product.maxPurchaseAmount) {
      throw Exception('Amount outside allowed range');
    }

    if (!product.canPurchase) {
      throw Exception('Product not available for purchase');
    }

    // Simulate success rate
    if (_random.nextDouble() < 0.95) {
      final purchaseId = DateTime.now().millisecondsSinceEpoch.toString();

      final position = SimpleEarnPosition(
        productId: productId,
        asset: product.asset,
        amount: amount,
        rewardAmount: 0.0,
        createTime: DateTime.now(),
        status: 'SUCCESS',
        canRedeem: product.canRedeem,
        lockedUntil: product.duration != null
            ? DateTime.now().add(Duration(days: product.duration!))
            : null,
      );

      _positions.add(position);

      return {
        'purchaseId': purchaseId,
        'success': true,
      };
    } else {
      throw Exception('Subscription failed');
    }
  }

  static Future<Map<String, dynamic>> redeem({
    required String productId,
    required double amount,
    String? redeemType,
  }) async {
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    final position = _positions
        .where((p) => p.productId == productId && p.amount >= amount)
        .firstOrNull;

    if (position == null) {
      throw Exception('Insufficient position or product not found');
    }

    if (!position.canRedeem) {
      throw Exception('Position cannot be redeemed yet');
    }

    if (position.lockedUntil != null &&
        DateTime.now().isBefore(position.lockedUntil!)) {
      throw Exception('Position is still locked');
    }

    // Simulate success rate
    if (_random.nextDouble() < 0.95) {
      final redeemId = DateTime.now().millisecondsSinceEpoch.toString();

      // Update position
      final updatedPosition = SimpleEarnPosition(
        productId: position.productId,
        asset: position.asset,
        amount: position.amount - amount,
        rewardAmount: position.rewardAmount,
        createTime: position.createTime,
        status: position.status,
        canRedeem: position.canRedeem,
        lockedUntil: position.lockedUntil,
      );

      _positions.remove(position);
      if (updatedPosition.amount > 0) {
        _positions.add(updatedPosition);
      }

      return {
        'redeemId': redeemId,
        'success': true,
      };
    } else {
      throw Exception('Redemption failed');
    }
  }

  static Future<void> simulateRewardAccrual() async {
    final now = DateTime.now();

    for (final position in _positions) {
      final product = SimpleEarnProducts.getProductById(position.productId);
      if (product == null) continue;

      // Calculate daily reward
      final dailyRate = product.avgAnnualPercentageRate / 365 / 100;
      final reward = position.amount * dailyRate;

      if (reward > 0) {
        _rewards.add(SimpleEarnReward(
          asset: position.asset,
          amount: reward,
          time: now,
          type: 'BONUS',
        ));

        // Update position reward amount
        final index = _positions.indexOf(position);
        _positions[index] = SimpleEarnPosition(
          productId: position.productId,
          asset: position.asset,
          amount: position.amount,
          rewardAmount: position.rewardAmount + reward,
          createTime: position.createTime,
          status: position.status,
          canRedeem: position.canRedeem,
          lockedUntil: position.lockedUntil,
        );
      }
    }
  }

  static List<SimpleEarnPosition> getPositions(
      {String? asset, String? productId}) {
    var positions = List<SimpleEarnPosition>.from(_positions);

    if (asset != null) {
      positions = positions.where((p) => p.asset == asset).toList();
    }

    if (productId != null) {
      positions = positions.where((p) => p.productId == productId).toList();
    }

    return positions;
  }

  static List<SimpleEarnReward> getRewards({
    String? asset,
    String? type,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    var rewards = List<SimpleEarnReward>.from(_rewards);

    if (asset != null) {
      rewards = rewards.where((r) => r.asset == asset).toList();
    }

    if (type != null) {
      rewards = rewards.where((r) => r.type == type).toList();
    }

    if (startTime != null) {
      rewards = rewards.where((r) => r.time.isAfter(startTime)).toList();
    }

    if (endTime != null) {
      rewards = rewards.where((r) => r.time.isBefore(endTime)).toList();
    }

    return rewards;
  }
}

// Simulated Simple Earn API
class SimulatedSimpleEarn {
  static bool _simulationMode = false;

  static void enableSimulation() {
    _simulationMode = true;
  }

  static void disableSimulation() {
    _simulationMode = false;
  }

  static bool get isSimulationEnabled => _simulationMode;

  // Flexible Products
  static Future<Map<String, dynamic>> getFlexibleProductList({
    String? asset,
    int? current,
    int? size,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 150 + Random().nextInt(100)));

    final products = SimpleEarnProducts.getFlexibleProducts(asset: asset);
    final total = products.length;
    final page = current ?? 1;
    final pageSize = size ?? 10;
    final startIndex = (page - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, total);

    final pageProducts = products.sublist(
      startIndex.clamp(0, total),
      endIndex,
    );

    return {
      'rows': pageProducts.map((p) => p.toJson()).toList(),
      'total': total,
    };
  }

  // Locked Products
  static Future<Map<String, dynamic>> getLockedProductList({
    String? asset,
    int? current,
    int? size,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 150 + Random().nextInt(100)));

    final products = SimpleEarnProducts.getLockedProducts(asset: asset);
    final total = products.length;
    final page = current ?? 1;
    final pageSize = size ?? 10;
    final startIndex = (page - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, total);

    final pageProducts = products.sublist(
      startIndex.clamp(0, total),
      endIndex,
    );

    return {
      'rows': pageProducts.map((p) => p.toJson()).toList(),
      'total': total,
    };
  }

  // Subscribe to product
  static Future<Map<String, dynamic>> subscribe({
    required String productId,
    required double amount,
    bool? autoSubscribe,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    return await SimpleEarnOperations.subscribe(
      productId: productId,
      amount: amount,
      autoSubscribe: autoSubscribe ?? true,
    );
  }

  // Redeem from product
  static Future<Map<String, dynamic>> redeem({
    required String productId,
    required double amount,
    String? redeemType,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    return await SimpleEarnOperations.redeem(
      productId: productId,
      amount: amount,
      redeemType: redeemType,
    );
  }

  // Get positions
  static Future<Map<String, dynamic>> getFlexiblePersonalLeftQuota({
    required String productId,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 100 + Random().nextInt(50)));

    final product = SimpleEarnProducts.getProductById(productId);
    if (product == null) {
      throw Exception('Product not found');
    }

    return {
      'leftPersonalQuota': product.maxPurchaseAmount.toString(),
    };
  }

  // Get subscription record
  static Future<Map<String, dynamic>> getFlexibleSubscriptionRecord({
    String? productId,
    String? asset,
    DateTime? startTime,
    DateTime? endTime,
    int? current,
    int? size,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 200 + Random().nextInt(150)));

    final positions = SimpleEarnOperations.getPositions(
      asset: asset,
      productId: productId,
    );

    final total = positions.length;
    final page = current ?? 1;
    final pageSize = size ?? 10;
    final startIndex = (page - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, total);

    final pagePositions = positions.sublist(
      startIndex.clamp(0, total),
      endIndex,
    );

    return {
      'rows': pagePositions.map((p) => p.toJson()).toList(),
      'total': total,
    };
  }

  // Get reward history
  static Future<Map<String, dynamic>> getRewardHistory({
    String? type,
    String? asset,
    DateTime? startTime,
    DateTime? endTime,
    int? current,
    int? size,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 200 + Random().nextInt(150)));

    final rewards = SimpleEarnOperations.getRewards(
      type: type,
      asset: asset,
      startTime: startTime,
      endTime: endTime,
    );

    final total = rewards.length;
    final page = current ?? 1;
    final pageSize = size ?? 10;
    final startIndex = (page - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, total);

    final pageRewards = rewards.sublist(
      startIndex.clamp(0, total),
      endIndex,
    );

    return {
      'rows': pageRewards.map((r) => r.toJson()).toList(),
      'total': total,
    };
  }
}

class SimpleEarn extends BinanceBase {
  SimpleEarn({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  // Enable simulation mode
  void enableSimulation() {
    SimulatedSimpleEarn.enableSimulation();
  }

  // Disable simulation mode
  void disableSimulation() {
    SimulatedSimpleEarn.disableSimulation();
  }

  // Check if simulation is enabled
  bool get isSimulationEnabled => SimulatedSimpleEarn.isSimulationEnabled;

  // Flexible Products
  Future<Map<String, dynamic>> getFlexibleProductList({
    String? asset,
    int? current,
    int? size,
    int? recvWindow,
  }) {
    if (SimulatedSimpleEarn.isSimulationEnabled) {
      return SimulatedSimpleEarn.getFlexibleProductList(
        asset: asset,
        current: current,
        size: size,
      );
    }

    final params = <String, dynamic>{};
    if (asset != null) params['asset'] = asset;
    if (current != null) params['current'] = current;
    if (size != null) params['size'] = size;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/simple-earn/flexible/list', params: params);
  }

  // Locked Products
  Future<Map<String, dynamic>> getLockedProductList({
    String? asset,
    int? current,
    int? size,
    int? recvWindow,
  }) {
    if (SimulatedSimpleEarn.isSimulationEnabled) {
      return SimulatedSimpleEarn.getLockedProductList(
        asset: asset,
        current: current,
        size: size,
      );
    }

    final params = <String, dynamic>{};
    if (asset != null) params['asset'] = asset;
    if (current != null) params['current'] = current;
    if (size != null) params['size'] = size;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/simple-earn/locked/list',
        params: params);
  }

  // Subscribe to flexible product
  Future<Map<String, dynamic>> subscribeFlexibleProduct({
    required String productId,
    required double amount,
    bool? autoSubscribe,
    int? recvWindow,
  }) {
    if (SimulatedSimpleEarn.isSimulationEnabled) {
      return SimulatedSimpleEarn.subscribe(
        productId: productId,
        amount: amount,
        autoSubscribe: autoSubscribe,
      );
    }

    final params = <String, dynamic>{
      'productId': productId,
      'amount': amount.toString(),
    };
    if (autoSubscribe != null) params['autoSubscribe'] = autoSubscribe;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/simple-earn/flexible/subscribe',
        params: params);
  }

  // Subscribe to locked product
  Future<Map<String, dynamic>> subscribeLockedProduct({
    required String projectId,
    required double lot,
    bool? autoSubscribe,
    int? recvWindow,
  }) {
    if (SimulatedSimpleEarn.isSimulationEnabled) {
      return SimulatedSimpleEarn.subscribe(
        productId: projectId,
        amount: lot,
        autoSubscribe: autoSubscribe,
      );
    }

    final params = <String, dynamic>{
      'projectId': projectId,
      'lot': lot.toString(),
    };
    if (autoSubscribe != null) params['autoSubscribe'] = autoSubscribe;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/simple-earn/locked/subscribe',
        params: params);
  }

  // Redeem flexible product
  Future<Map<String, dynamic>> redeemFlexibleProduct({
    required String productId,
    required double amount,
    String? redeemType,
    int? recvWindow,
  }) {
    if (SimulatedSimpleEarn.isSimulationEnabled) {
      return SimulatedSimpleEarn.redeem(
        productId: productId,
        amount: amount,
        redeemType: redeemType,
      );
    }

    final params = <String, dynamic>{
      'productId': productId,
      'amount': amount.toString(),
    };
    if (redeemType != null) params['redeemType'] = redeemType;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/simple-earn/flexible/redeem',
        params: params);
  }

  // Get flexible personal left quota
  Future<Map<String, dynamic>> getFlexiblePersonalLeftQuota({
    required String productId,
    int? recvWindow,
  }) {
    if (SimulatedSimpleEarn.isSimulationEnabled) {
      return SimulatedSimpleEarn.getFlexiblePersonalLeftQuota(
          productId: productId);
    }

    final params = <String, dynamic>{'productId': productId};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/simple-earn/flexible/personalLeftQuota',
        params: params);
  }

  // Get flexible subscription record
  Future<Map<String, dynamic>> getFlexibleSubscriptionRecord({
    String? productId,
    String? purchaseId,
    String? asset,
    DateTime? startTime,
    DateTime? endTime,
    int? current,
    int? size,
    int? recvWindow,
  }) {
    if (SimulatedSimpleEarn.isSimulationEnabled) {
      return SimulatedSimpleEarn.getFlexibleSubscriptionRecord(
        productId: productId,
        asset: asset,
        startTime: startTime,
        endTime: endTime,
        current: current,
        size: size,
      );
    }

    final params = <String, dynamic>{};
    if (productId != null) params['productId'] = productId;
    if (purchaseId != null) params['purchaseId'] = purchaseId;
    if (asset != null) params['asset'] = asset;
    if (startTime != null)
      params['startTime'] = startTime.millisecondsSinceEpoch;
    if (endTime != null) params['endTime'] = endTime.millisecondsSinceEpoch;
    if (current != null) params['current'] = current;
    if (size != null) params['size'] = size;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest(
        'GET', '/sapi/v1/simple-earn/flexible/history/subscriptionRecord',
        params: params);
  }

  // Get reward history
  Future<Map<String, dynamic>> getRewardHistory({
    String? type,
    String? asset,
    DateTime? startTime,
    DateTime? endTime,
    int? current,
    int? size,
    int? recvWindow,
  }) {
    if (SimulatedSimpleEarn.isSimulationEnabled) {
      return SimulatedSimpleEarn.getRewardHistory(
        type: type,
        asset: asset,
        startTime: startTime,
        endTime: endTime,
        current: current,
        size: size,
      );
    }

    final params = <String, dynamic>{};
    if (type != null) params['type'] = type;
    if (asset != null) params['asset'] = asset;
    if (startTime != null)
      params['startTime'] = startTime.millisecondsSinceEpoch;
    if (endTime != null) params['endTime'] = endTime.millisecondsSinceEpoch;
    if (current != null) params['current'] = current;
    if (size != null) params['size'] = size;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest(
        'GET', '/sapi/v1/simple-earn/flexible/history/rewardsRecord',
        params: params);
  }
}