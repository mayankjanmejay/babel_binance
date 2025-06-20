import 'dart:math';
import 'binance_base.dart';

// Auto Invest Plan Models
class AutoInvestPlan {
  final int planId;
  final String planName;
  final String status;
  final String targetAsset;
  final String sourceAsset;
  final double sourceWalletBalance;
  final double subscriptionAmount;
  final String subscriptionCycle;
  final DateTime nextExecutionDateTime;
  final DateTime createDateTime;
  final List<AutoInvestPlanDetail> details;

  AutoInvestPlan({
    required this.planId,
    required this.planName,
    required this.status,
    required this.targetAsset,
    required this.sourceAsset,
    required this.sourceWalletBalance,
    required this.subscriptionAmount,
    required this.subscriptionCycle,
    required this.nextExecutionDateTime,
    required this.createDateTime,
    required this.details,
  });

  Map<String, dynamic> toJson() => {
        'planId': planId,
        'planName': planName,
        'status': status,
        'targetAsset': targetAsset,
        'sourceAsset': sourceAsset,
        'sourceWalletBalance': sourceWalletBalance.toString(),
        'subscriptionAmount': subscriptionAmount.toString(),
        'subscriptionCycle': subscriptionCycle,
        'nextExecutionDateTime': nextExecutionDateTime.millisecondsSinceEpoch,
        'createDateTime': createDateTime.millisecondsSinceEpoch,
        'details': details.map((d) => d.toJson()).toList(),
      };
}

class AutoInvestPlanDetail {
  final String targetAsset;
  final double percentage;

  AutoInvestPlanDetail({
    required this.targetAsset,
    required this.percentage,
  });

  Map<String, dynamic> toJson() => {
        'targetAsset': targetAsset,
        'percentage': percentage,
      };
}

class AutoInvestSubscription {
  final int transactionId;
  final int planId;
  final String planName;
  final String targetAsset;
  final double executionAmount;
  final double executionPrice;
  final double executionQuantity;
  final DateTime executionDateTime;
  final String status;

  AutoInvestSubscription({
    required this.transactionId,
    required this.planId,
    required this.planName,
    required this.targetAsset,
    required this.executionAmount,
    required this.executionPrice,
    required this.executionQuantity,
    required this.executionDateTime,
    required this.status,
  });

  Map<String, dynamic> toJson() => {
        'transactionId': transactionId,
        'planId': planId,
        'planName': planName,
        'targetAsset': targetAsset,
        'executionAmount': executionAmount.toString(),
        'executionPrice': executionPrice.toString(),
        'executionQuantity': executionQuantity.toString(),
        'executionDateTime': executionDateTime.millisecondsSinceEpoch,
        'status': status,
      };
}

class AutoInvestAsset {
  final String asset;
  final double minAmount;
  final double maxAmount;

  AutoInvestAsset({
    required this.asset,
    required this.minAmount,
    required this.maxAmount,
  });

  Map<String, dynamic> toJson() => {
        'asset': asset,
        'minAmount': minAmount.toString(),
        'maxAmount': maxAmount.toString(),
      };
}

// Auto Invest Assets Management
class AutoInvestAssets {
  static final List<AutoInvestAsset> _sourceAssets = [
    AutoInvestAsset(asset: 'USDT', minAmount: 1.0, maxAmount: 100000.0),
    AutoInvestAsset(asset: 'BUSD', minAmount: 1.0, maxAmount: 100000.0),
    AutoInvestAsset(asset: 'BTC', minAmount: 0.0001, maxAmount: 10.0),
    AutoInvestAsset(asset: 'BNB', minAmount: 0.01, maxAmount: 1000.0),
  ];

  static final List<AutoInvestAsset> _targetAssets = [
    AutoInvestAsset(asset: 'BTC', minAmount: 0.0001, maxAmount: 10.0),
    AutoInvestAsset(asset: 'ETH', minAmount: 0.001, maxAmount: 100.0),
    AutoInvestAsset(asset: 'BNB', minAmount: 0.01, maxAmount: 1000.0),
    AutoInvestAsset(asset: 'ADA', minAmount: 1.0, maxAmount: 100000.0),
    AutoInvestAsset(asset: 'DOT', minAmount: 0.1, maxAmount: 10000.0),
    AutoInvestAsset(asset: 'SOL', minAmount: 0.01, maxAmount: 1000.0),
    AutoInvestAsset(asset: 'MATIC', minAmount: 1.0, maxAmount: 100000.0),
    AutoInvestAsset(asset: 'AVAX', minAmount: 0.01, maxAmount: 1000.0),
  ];

  static List<AutoInvestAsset> getSourceAssets() => List.from(_sourceAssets);
  static List<AutoInvestAsset> getTargetAssets() => List.from(_targetAssets);

  static AutoInvestAsset? getSourceAsset(String asset) {
    try {
      return _sourceAssets.firstWhere((a) => a.asset == asset);
    } catch (e) {
      return null;
    }
  }

  static AutoInvestAsset? getTargetAsset(String asset) {
    try {
      return _targetAssets.firstWhere((a) => a.asset == asset);
    } catch (e) {
      return null;
    }
  }
}

// Auto Invest Plan Management
class AutoInvestPlanManager {
  static final List<AutoInvestPlan> _plans = [];
  static final List<AutoInvestSubscription> _subscriptions = [];
  static int _nextPlanId = 1000;
  static int _nextTransactionId = 100000;
  static final Random _random = Random();

  static Future<Map<String, dynamic>> createPlan({
    required String sourceType,
    required String planName,
    required String sourceAsset,
    required double subscriptionAmount,
    required String subscriptionCycle,
    required List<AutoInvestPlanDetail> details,
  }) async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(500)));

    // Validate source asset
    final sourceAssetInfo = AutoInvestAssets.getSourceAsset(sourceAsset);
    if (sourceAssetInfo == null) {
      throw Exception('Unsupported source asset');
    }

    if (subscriptionAmount < sourceAssetInfo.minAmount ||
        subscriptionAmount > sourceAssetInfo.maxAmount) {
      throw Exception('Subscription amount outside allowed range');
    }

    // Validate target assets and percentages
    double totalPercentage = 0;
    for (final detail in details) {
      final targetAssetInfo =
          AutoInvestAssets.getTargetAsset(detail.targetAsset);
      if (targetAssetInfo == null) {
        throw Exception('Unsupported target asset: ${detail.targetAsset}');
      }
      totalPercentage += detail.percentage;
    }

    if ((totalPercentage - 100.0).abs() > 0.01) {
      throw Exception('Total percentage must equal 100%');
    }

    // Simulate success rate
    if (_random.nextDouble() < 0.95) {
      final planId = _nextPlanId++;
      final now = DateTime.now();

      Duration cycleDuration;
      switch (subscriptionCycle.toUpperCase()) {
        case 'DAILY':
          cycleDuration = Duration(days: 1);
          break;
        case 'WEEKLY':
          cycleDuration = Duration(days: 7);
          break;
        case 'MONTHLY':
          cycleDuration = Duration(days: 30);
          break;
        default:
          throw Exception('Invalid subscription cycle');
      }

      final plan = AutoInvestPlan(
        planId: planId,
        planName: planName,
        status: 'ONGOING',
        targetAsset: details.first.targetAsset,
        sourceAsset: sourceAsset,
        sourceWalletBalance: 1000.0 + _random.nextDouble() * 10000.0,
        subscriptionAmount: subscriptionAmount,
        subscriptionCycle: subscriptionCycle,
        nextExecutionDateTime: now.add(cycleDuration),
        createDateTime: now,
        details: details,
      );

      _plans.add(plan);

      return {
        'planId': planId,
        'success': true,
      };
    } else {
      throw Exception('Plan creation failed');
    }
  }

  static Future<Map<String, dynamic>> editPlan({
    required int planId,
    String? planName,
    double? subscriptionAmount,
    String? subscriptionCycle,
    List<AutoInvestPlanDetail>? details,
  }) async {
    await Future.delayed(Duration(milliseconds: 200 + _random.nextInt(300)));

    final planIndex = _plans.indexWhere((p) => p.planId == planId);
    if (planIndex == -1) {
      throw Exception('Plan not found');
    }

    final currentPlan = _plans[planIndex];
    if (currentPlan.status != 'ONGOING') {
      throw Exception('Can only edit ongoing plans');
    }

    // Simulate success rate
    if (_random.nextDouble() < 0.95) {
      Duration? cycleDuration;
      if (subscriptionCycle != null) {
        switch (subscriptionCycle.toUpperCase()) {
          case 'DAILY':
            cycleDuration = Duration(days: 1);
            break;
          case 'WEEKLY':
            cycleDuration = Duration(days: 7);
            break;
          case 'MONTHLY':
            cycleDuration = Duration(days: 30);
            break;
          default:
            throw Exception('Invalid subscription cycle');
        }
      }

      final updatedPlan = AutoInvestPlan(
        planId: currentPlan.planId,
        planName: planName ?? currentPlan.planName,
        status: currentPlan.status,
        targetAsset: currentPlan.targetAsset,
        sourceAsset: currentPlan.sourceAsset,
        sourceWalletBalance: currentPlan.sourceWalletBalance,
        subscriptionAmount:
            subscriptionAmount ?? currentPlan.subscriptionAmount,
        subscriptionCycle: subscriptionCycle ?? currentPlan.subscriptionCycle,
        nextExecutionDateTime: cycleDuration != null
            ? DateTime.now().add(cycleDuration)
            : currentPlan.nextExecutionDateTime,
        createDateTime: currentPlan.createDateTime,
        details: details ?? currentPlan.details,
      );

      _plans[planIndex] = updatedPlan;

      return {
        'planId': planId,
        'success': true,
      };
    } else {
      throw Exception('Plan edit failed');
    }
  }

  static Future<Map<String, dynamic>> changePlanStatus({
    required int planId,
    required String status,
  }) async {
    await Future.delayed(Duration(milliseconds: 150 + _random.nextInt(200)));

    final planIndex = _plans.indexWhere((p) => p.planId == planId);
    if (planIndex == -1) {
      throw Exception('Plan not found');
    }

    final validStatuses = ['ONGOING', 'PAUSED', 'REMOVED'];
    if (!validStatuses.contains(status)) {
      throw Exception('Invalid status');
    }

    // Simulate success rate
    if (_random.nextDouble() < 0.98) {
      final currentPlan = _plans[planIndex];
      final updatedPlan = AutoInvestPlan(
        planId: currentPlan.planId,
        planName: currentPlan.planName,
        status: status,
        targetAsset: currentPlan.targetAsset,
        sourceAsset: currentPlan.sourceAsset,
        sourceWalletBalance: currentPlan.sourceWalletBalance,
        subscriptionAmount: currentPlan.subscriptionAmount,
        subscriptionCycle: currentPlan.subscriptionCycle,
        nextExecutionDateTime: currentPlan.nextExecutionDateTime,
        createDateTime: currentPlan.createDateTime,
        details: currentPlan.details,
      );

      _plans[planIndex] = updatedPlan;

      return {
        'planId': planId,
        'success': true,
      };
    } else {
      throw Exception('Status change failed');
    }
  }

  static List<AutoInvestPlan> getPlans({String? planType}) {
    return List.from(_plans);
  }

  static AutoInvestPlan? getPlan(int planId) {
    try {
      return _plans.firstWhere((p) => p.planId == planId);
    } catch (e) {
      return null;
    }
  }

  static Future<void> simulateExecution() async {
    final now = DateTime.now();

    for (final plan in _plans.where((p) => p.status == 'ONGOING')) {
      if (now.isAfter(plan.nextExecutionDateTime)) {
        // Execute plan
        for (final detail in plan.details) {
          final amount = plan.subscriptionAmount * (detail.percentage / 100);
          final price =
              50000.0 + _random.nextDouble() * 10000.0; // Simulated price
          final quantity = amount / price;

          final subscription = AutoInvestSubscription(
            transactionId: _nextTransactionId++,
            planId: plan.planId,
            planName: plan.planName,
            targetAsset: detail.targetAsset,
            executionAmount: amount,
            executionPrice: price,
            executionQuantity: quantity,
            executionDateTime: now,
            status: 'SUCCESS',
          );

          _subscriptions.add(subscription);
        }

        // Update next execution time
        Duration cycleDuration;
        switch (plan.subscriptionCycle.toUpperCase()) {
          case 'DAILY':
            cycleDuration = Duration(days: 1);
            break;
          case 'WEEKLY':
            cycleDuration = Duration(days: 7);
            break;
          case 'MONTHLY':
            cycleDuration = Duration(days: 30);
            break;
          default:
            cycleDuration = Duration(days: 1);
        }

        final planIndex = _plans.indexOf(plan);
        _plans[planIndex] = AutoInvestPlan(
          planId: plan.planId,
          planName: plan.planName,
          status: plan.status,
          targetAsset: plan.targetAsset,
          sourceAsset: plan.sourceAsset,
          sourceWalletBalance:
              plan.sourceWalletBalance - plan.subscriptionAmount,
          subscriptionAmount: plan.subscriptionAmount,
          subscriptionCycle: plan.subscriptionCycle,
          nextExecutionDateTime: plan.nextExecutionDateTime.add(cycleDuration),
          createDateTime: plan.createDateTime,
          details: plan.details,
        );
      }
    }
  }

  static List<AutoInvestSubscription> getSubscriptions({
    int? planId,
    String? targetAsset,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    var subscriptions = List<AutoInvestSubscription>.from(_subscriptions);

    if (planId != null) {
      subscriptions = subscriptions.where((s) => s.planId == planId).toList();
    }

    if (targetAsset != null) {
      subscriptions =
          subscriptions.where((s) => s.targetAsset == targetAsset).toList();
    }

    if (startTime != null) {
      subscriptions = subscriptions
          .where((s) => s.executionDateTime.isAfter(startTime))
          .toList();
    }

    if (endTime != null) {
      subscriptions = subscriptions
          .where((s) => s.executionDateTime.isBefore(endTime))
          .toList();
    }

    return subscriptions;
  }
}

// Simulated Auto Invest API
class SimulatedAutoInvest {
  static bool _simulationMode = false;

  static void enableSimulation() {
    _simulationMode = true;
  }

  static void disableSimulation() {
    _simulationMode = false;
  }

  static bool get isSimulationEnabled => _simulationMode;

  static Future<Map<String, dynamic>> getTargetAssetList() async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 100 + Random().nextInt(50)));

    return {
      'data':
          AutoInvestAssets.getTargetAssets().map((a) => a.toJson()).toList(),
    };
  }

  static Future<Map<String, dynamic>> getSourceAssetList(
      {String? targetAsset}) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 100 + Random().nextInt(50)));

    return {
      'data':
          AutoInvestAssets.getSourceAssets().map((a) => a.toJson()).toList(),
    };
  }

  static Future<Map<String, dynamic>> submitPlan({
    required String sourceType,
    required String requestId,
    required String planName,
    required String sourceAsset,
    required double subscriptionAmount,
    required String subscriptionCycle,
    required List<Map<String, dynamic>> details,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    final planDetails = details
        .map((d) => AutoInvestPlanDetail(
              targetAsset: d['targetAsset'],
              percentage: d['percentage'].toDouble(),
            ))
        .toList();

    return await AutoInvestPlanManager.createPlan(
      sourceType: sourceType,
      planName: planName,
      sourceAsset: sourceAsset,
      subscriptionAmount: subscriptionAmount,
      subscriptionCycle: subscriptionCycle,
      details: planDetails,
    );
  }

  static Future<Map<String, dynamic>> editPlan({
    required int planId,
    String? planName,
    double? subscriptionAmount,
    String? subscriptionCycle,
    List<Map<String, dynamic>>? details,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    List<AutoInvestPlanDetail>? planDetails;
    if (details != null) {
      planDetails = details
          .map((d) => AutoInvestPlanDetail(
                targetAsset: d['targetAsset'],
                percentage: d['percentage'].toDouble(),
              ))
          .toList();
    }

    return await AutoInvestPlanManager.editPlan(
      planId: planId,
      planName: planName,
      subscriptionAmount: subscriptionAmount,
      subscriptionCycle: subscriptionCycle,
      details: planDetails,
    );
  }

  static Future<Map<String, dynamic>> changePlanStatus({
    required int planId,
    required String status,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    return await AutoInvestPlanManager.changePlanStatus(
      planId: planId,
      status: status,
    );
  }

  static Future<Map<String, dynamic>> getList({String? planType}) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 150 + Random().nextInt(100)));

    final plans = AutoInvestPlanManager.getPlans(planType: planType);

    return {
      'plans': plans.map((p) => p.toJson()).toList(),
    };
  }

  static Future<Map<String, dynamic>> getSubscriptionTransactionHistory({
    int? planId,
    String? targetAsset,
    DateTime? startTime,
    DateTime? endTime,
    int? current,
    int? size,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 200 + Random().nextInt(150)));

    final subscriptions = AutoInvestPlanManager.getSubscriptions(
      planId: planId,
      targetAsset: targetAsset,
      startTime: startTime,
      endTime: endTime,
    );

    final total = subscriptions.length;
    final page = current ?? 1;
    final pageSize = size ?? 10;
    final startIndex = (page - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, total);

    final pageSubscriptions = subscriptions.sublist(
      startIndex.clamp(0, total),
      endIndex,
    );

    return {
      'total': total,
      'plans': pageSubscriptions.map((s) => s.toJson()).toList(),
    };
  }

  static Future<Map<String, dynamic>> getOneTimeTransactionStatus({
    required int transactionId,
    String? requestId,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 100 + Random().nextInt(50)));

    final subscription = AutoInvestPlanManager.getSubscriptions()
        .where((s) => s.transactionId == transactionId)
        .firstOrNull;

    if (subscription == null) {
      throw Exception('Transaction not found');
    }

    return subscription.toJson();
  }
}

class AutoInvest extends BinanceBase {
  AutoInvest({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  // Enable simulation mode
  void enableSimulation() {
    SimulatedAutoInvest.enableSimulation();
  }

  // Disable simulation mode
  void disableSimulation() {
    SimulatedAutoInvest.disableSimulation();
  }

  // Check if simulation is enabled
  bool get isSimulationEnabled => SimulatedAutoInvest.isSimulationEnabled;

  // Get target asset list
  Future<Map<String, dynamic>> getTargetAssetList({int? recvWindow}) {
    if (SimulatedAutoInvest.isSimulationEnabled) {
      return SimulatedAutoInvest.getTargetAssetList();
    }

    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/lending/auto-invest/target-asset/list',
        params: params);
  }

  // Get source asset list
  Future<Map<String, dynamic>> getSourceAssetList({
    String? targetAsset,
    int? recvWindow,
  }) {
    if (SimulatedAutoInvest.isSimulationEnabled) {
      return SimulatedAutoInvest.getSourceAssetList(targetAsset: targetAsset);
    }

    final params = <String, dynamic>{};
    if (targetAsset != null) params['targetAsset'] = targetAsset;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/lending/auto-invest/source-asset/list',
        params: params);
  }

  // Submit auto-invest plan
  Future<Map<String, dynamic>> submitPlan({
    required String sourceType,
    required String requestId,
    required String planName,
    required String sourceAsset,
    required double subscriptionAmount,
    required String subscriptionCycle,
    required List<Map<String, dynamic>> details,
    int? recvWindow,
  }) {
    if (SimulatedAutoInvest.isSimulationEnabled) {
      return SimulatedAutoInvest.submitPlan(
        sourceType: sourceType,
        requestId: requestId,
        planName: planName,
        sourceAsset: sourceAsset,
        subscriptionAmount: subscriptionAmount,
        subscriptionCycle: subscriptionCycle,
        details: details,
      );
    }

    final params = <String, dynamic>{
      'sourceType': sourceType,
      'requestId': requestId,
      'planName': planName,
      'sourceAsset': sourceAsset,
      'subscriptionAmount': subscriptionAmount.toString(),
      'subscriptionCycle': subscriptionCycle,
      'details': details,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/lending/auto-invest/plan/add',
        params: params);
  }

  // Edit auto-invest plan
  Future<Map<String, dynamic>> editPlan({
    required int planId,
    String? planName,
    double? subscriptionAmount,
    String? subscriptionCycle,
    List<Map<String, dynamic>>? details,
    int? recvWindow,
  }) {
    if (SimulatedAutoInvest.isSimulationEnabled) {
      return SimulatedAutoInvest.editPlan(
        planId: planId,
        planName: planName,
        subscriptionAmount: subscriptionAmount,
        subscriptionCycle: subscriptionCycle,
        details: details,
      );
    }

    final params = <String, dynamic>{'planId': planId};
    if (planName != null) params['planName'] = planName;
    if (subscriptionAmount != null)
      params['subscriptionAmount'] = subscriptionAmount.toString();
    if (subscriptionCycle != null)
      params['subscriptionCycle'] = subscriptionCycle;
    if (details != null) params['details'] = details;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/lending/auto-invest/plan/edit',
        params: params);
  }

  // Change plan status
  Future<Map<String, dynamic>> changePlanStatus({
    required int planId,
    required String status,
    int? recvWindow,
  }) {
    if (SimulatedAutoInvest.isSimulationEnabled) {
      return SimulatedAutoInvest.changePlanStatus(
        planId: planId,
        status: status,
      );
    }

    final params = <String, dynamic>{
      'planId': planId,
      'status': status,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/lending/auto-invest/plan/edit-status',
        params: params);
  }

  // Get auto-invest plan list
  Future<Map<String, dynamic>> getList({
    String? planType,
    int? recvWindow,
  }) {
    if (SimulatedAutoInvest.isSimulationEnabled) {
      return SimulatedAutoInvest.getList(planType: planType);
    }

    final params = <String, dynamic>{};
    if (planType != null) params['planType'] = planType;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/lending/auto-invest/plan/list',
        params: params);
  }

  // Get subscription transaction history
  Future<Map<String, dynamic>> getSubscriptionTransactionHistory({
    int? planId,
    String? targetAsset,
    DateTime? startTime,
    DateTime? endTime,
    int? current,
    int? size,
    int? recvWindow,
  }) {
    if (SimulatedAutoInvest.isSimulationEnabled) {
      return SimulatedAutoInvest.getSubscriptionTransactionHistory(
        planId: planId,
        targetAsset: targetAsset,
        startTime: startTime,
        endTime: endTime,
        current: current,
        size: size,
      );
    }

    final params = <String, dynamic>{};
    if (planId != null) params['planId'] = planId;
    if (targetAsset != null) params['targetAsset'] = targetAsset;
    if (startTime != null)
      params['startTime'] = startTime.millisecondsSinceEpoch;
    if (endTime != null) params['endTime'] = endTime.millisecondsSinceEpoch;
    if (current != null) params['current'] = current;
    if (size != null) params['size'] = size;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/lending/auto-invest/history/list',
        params: params);
  }

  // Get one-time transaction status
  Future<Map<String, dynamic>> getOneTimeTransactionStatus({
    required int transactionId,
    String? requestId,
    int? recvWindow,
  }) {
    if (SimulatedAutoInvest.isSimulationEnabled) {
      return SimulatedAutoInvest.getOneTimeTransactionStatus(
        transactionId: transactionId,
        requestId: requestId,
      );
    }

    final params = <String, dynamic>{'transactionId': transactionId};
    if (requestId != null) params['requestId'] = requestId;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/lending/auto-invest/one-off/status',
        params: params);
  }
}