import 'dart:math';
import 'binance_base.dart';

// VIP Loan Models
class VipLoanableAsset {
  final String loanCoin;
  final double _30dDailyInterestRate;
  final double _7dDailyInterestRate;
  final double minLimit;
  final double maxLimit;
  final bool vipLevel;

  VipLoanableAsset({
    required this.loanCoin,
    required double dailyInterestRate30d,
    required double dailyInterestRate7d,
    required this.minLimit,
    required this.maxLimit,
    required this.vipLevel,
  })  : _30dDailyInterestRate = dailyInterestRate30d,
        _7dDailyInterestRate = dailyInterestRate7d;

  double get dailyInterestRate30d => _30dDailyInterestRate;
  double get dailyInterestRate7d => _7dDailyInterestRate;

  Map<String, dynamic> toJson() => {
        'loanCoin': loanCoin,
        '30dDailyInterestRate': _30dDailyInterestRate.toString(),
        '7dDailyInterestRate': _7dDailyInterestRate.toString(),
        'minLimit': minLimit.toString(),
        'maxLimit': maxLimit.toString(),
        'vipLevel': vipLevel,
      };
}

class VipCollateralAsset {
  final String collateralCoin;
  final double initialLTV;
  final double marginCallLTV;
  final double liquidationLTV;
  final double maxLimit;
  final bool vipLevel;

  VipCollateralAsset({
    required this.collateralCoin,
    required this.initialLTV,
    required this.marginCallLTV,
    required this.liquidationLTV,
    required this.maxLimit,
    required this.vipLevel,
  });

  Map<String, dynamic> toJson() => {
        'collateralCoin': collateralCoin,
        'initialLTV': initialLTV.toString(),
        'marginCallLTV': marginCallLTV.toString(),
        'liquidationLTV': liquidationLTV.toString(),
        'maxLimit': maxLimit.toString(),
        'vipLevel': vipLevel,
      };
}

class VipLoanOrder {
  final int orderId;
  final String loanCoin;
  final String collateralCoin;
  final double loanAmount;
  final double collateralAmount;
  final double initialLTV;
  final double currentLTV;
  final double hourlyInterestRate;
  final String status;
  final DateTime loanDate;
  final int loanTerm;

  VipLoanOrder({
    required this.orderId,
    required this.loanCoin,
    required this.collateralCoin,
    required this.loanAmount,
    required this.collateralAmount,
    required this.initialLTV,
    required this.currentLTV,
    required this.hourlyInterestRate,
    required this.status,
    required this.loanDate,
    required this.loanTerm,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'loanCoin': loanCoin,
        'collateralCoin': collateralCoin,
        'loanAmount': loanAmount.toString(),
        'collateralAmount': collateralAmount.toString(),
        'initialLTV': initialLTV.toString(),
        'currentLTV': currentLTV.toString(),
        'hourlyInterestRate': hourlyInterestRate.toString(),
        'status': status,
        'loanDate': loanDate.millisecondsSinceEpoch,
        'loanTerm': loanTerm,
      };
}

class VipLoanRepayment {
  final int orderId;
  final double repayAmount;
  final String repayType;
  final double remainingPrincipal;
  final double remainingInterest;
  final double currentLTV;
  final DateTime repayTime;

  VipLoanRepayment({
    required this.orderId,
    required this.repayAmount,
    required this.repayType,
    required this.remainingPrincipal,
    required this.remainingInterest,
    required this.currentLTV,
    required this.repayTime,
  });

  Map<String, dynamic> toJson() => {
        'orderId': orderId,
        'repayAmount': repayAmount.toString(),
        'repayType': repayType,
        'remainingPrincipal': remainingPrincipal.toString(),
        'remainingInterest': remainingInterest.toString(),
        'currentLTV': currentLTV.toString(),
        'repayTime': repayTime.millisecondsSinceEpoch,
      };
}

class VipLoanAccount {
  final String totalCollateralValueInBTC;
  final String totalCollateralValueInUSDT;
  final String totalLoanValueInBTC;
  final String totalLoanValueInUSDT;
  final String totalFreeCollateralValueInBTC;
  final String totalFreeCollateralValueInUSDT;
  final String currentLTV;

  VipLoanAccount({
    required this.totalCollateralValueInBTC,
    required this.totalCollateralValueInUSDT,
    required this.totalLoanValueInBTC,
    required this.totalLoanValueInUSDT,
    required this.totalFreeCollateralValueInBTC,
    required this.totalFreeCollateralValueInUSDT,
    required this.currentLTV,
  });

  Map<String, dynamic> toJson() => {
        'totalCollateralValueInBTC': totalCollateralValueInBTC,
        'totalCollateralValueInUSDT': totalCollateralValueInUSDT,
        'totalLoanValueInBTC': totalLoanValueInBTC,
        'totalLoanValueInUSDT': totalLoanValueInUSDT,
        'totalFreeCollateralValueInBTC': totalFreeCollateralValueInBTC,
        'totalFreeCollateralValueInUSDT': totalFreeCollateralValueInUSDT,
        'currentLTV': currentLTV,
      };
}

// VIP Loan Assets Management
class VipLoanAssets {
  static final List<VipLoanableAsset> _loanableAssets = [
    VipLoanableAsset(
      loanCoin: 'USDT',
      dailyInterestRate30d: 0.0002,
      dailyInterestRate7d: 0.00025,
      minLimit: 100.0,
      maxLimit: 2000000.0,
      vipLevel: true,
    ),
    VipLoanableAsset(
      loanCoin: 'USDC',
      dailyInterestRate30d: 0.0002,
      dailyInterestRate7d: 0.00025,
      minLimit: 100.0,
      maxLimit: 2000000.0,
      vipLevel: true,
    ),
    VipLoanableAsset(
      loanCoin: 'BUSD',
      dailyInterestRate30d: 0.00018,
      dailyInterestRate7d: 0.00023,
      minLimit: 100.0,
      maxLimit: 1000000.0,
      vipLevel: true,
    ),
    VipLoanableAsset(
      loanCoin: 'BTC',
      dailyInterestRate30d: 0.00015,
      dailyInterestRate7d: 0.0002,
      minLimit: 0.001,
      maxLimit: 50.0,
      vipLevel: true,
    ),
    VipLoanableAsset(
      loanCoin: 'ETH',
      dailyInterestRate30d: 0.00018,
      dailyInterestRate7d: 0.00022,
      minLimit: 0.01,
      maxLimit: 500.0,
      vipLevel: true,
    ),
  ];

  static final List<VipCollateralAsset> _collateralAssets = [
    VipCollateralAsset(
      collateralCoin: 'BTC',
      initialLTV: 0.65,
      marginCallLTV: 0.75,
      liquidationLTV: 0.85,
      maxLimit: 1000.0,
      vipLevel: true,
    ),
    VipCollateralAsset(
      collateralCoin: 'ETH',
      initialLTV: 0.65,
      marginCallLTV: 0.75,
      liquidationLTV: 0.85,
      maxLimit: 5000.0,
      vipLevel: true,
    ),
    VipCollateralAsset(
      collateralCoin: 'BNB',
      initialLTV: 0.60,
      marginCallLTV: 0.70,
      liquidationLTV: 0.80,
      maxLimit: 50000.0,
      vipLevel: true,
    ),
    VipCollateralAsset(
      collateralCoin: 'ADA',
      initialLTV: 0.55,
      marginCallLTV: 0.65,
      liquidationLTV: 0.75,
      maxLimit: 500000.0,
      vipLevel: true,
    ),
    VipCollateralAsset(
      collateralCoin: 'DOT',
      initialLTV: 0.55,
      marginCallLTV: 0.65,
      liquidationLTV: 0.75,
      maxLimit: 100000.0,
      vipLevel: true,
    ),
  ];

  static List<VipLoanableAsset> getLoanableAssets({String? loanCoin}) {
    if (loanCoin != null) {
      return _loanableAssets.where((a) => a.loanCoin == loanCoin).toList();
    }
    return List.from(_loanableAssets);
  }

  static List<VipCollateralAsset> getCollateralAssets(
      {String? collateralCoin}) {
    if (collateralCoin != null) {
      return _collateralAssets
          .where((a) => a.collateralCoin == collateralCoin)
          .toList();
    }
    return List.from(_collateralAssets);
  }

  static VipLoanableAsset? getLoanableAsset(String loanCoin) {
    try {
      return _loanableAssets.firstWhere((a) => a.loanCoin == loanCoin);
    } catch (e) {
      return null;
    }
  }

  static VipCollateralAsset? getCollateralAsset(String collateralCoin) {
    try {
      return _collateralAssets
          .firstWhere((a) => a.collateralCoin == collateralCoin);
    } catch (e) {
      return null;
    }
  }
}

// VIP Loan Operations
class VipLoanOperations {
  static final List<VipLoanOrder> _orders = [];
  static final List<VipLoanRepayment> _repayments = [];
  static int _nextOrderId = 10000;
  static final Random _random = Random();

  static Future<Map<String, dynamic>> borrow({
    required String loanCoin,
    required String collateralCoin,
    required double loanAmount,
    required int loanTerm,
  }) async {
    await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(600)));

    final loanAsset = VipLoanAssets.getLoanableAsset(loanCoin);
    final collateralAsset = VipLoanAssets.getCollateralAsset(collateralCoin);

    if (loanAsset == null) {
      throw Exception('Unsupported loan asset');
    }

    if (collateralAsset == null) {
      throw Exception('Unsupported collateral asset');
    }

    if (loanAmount < loanAsset.minLimit || loanAmount > loanAsset.maxLimit) {
      throw Exception('Loan amount outside allowed range');
    }

    if (![7, 30].contains(loanTerm)) {
      throw Exception('Invalid loan term. Must be 7 or 30 days');
    }

    // Calculate required collateral based on initial LTV
    final loanValueUSDT =
        loanCoin == 'USDT' ? loanAmount : loanAmount * 50000; // Simulated price
    final collateralPriceUSDT =
        collateralCoin == 'USDT' ? 1.0 : 50000.0; // Simulated price
    final requiredCollateralAmount =
        loanValueUSDT / (collateralAsset.initialLTV * collateralPriceUSDT);

    // Simulate success rate
    if (_random.nextDouble() < 0.95) {
      final orderId = _nextOrderId++;
      final hourlyRate = loanTerm == 7
          ? loanAsset.dailyInterestRate7d / 24
          : loanAsset.dailyInterestRate30d / 24;

      final order = VipLoanOrder(
        orderId: orderId,
        loanCoin: loanCoin,
        collateralCoin: collateralCoin,
        loanAmount: loanAmount,
        collateralAmount: requiredCollateralAmount,
        initialLTV: collateralAsset.initialLTV,
        currentLTV: collateralAsset.initialLTV,
        hourlyInterestRate: hourlyRate,
        status: 'ACCRUING',
        loanDate: DateTime.now(),
        loanTerm: loanTerm,
      );

      _orders.add(order);

      return {
        'orderId': orderId,
        'loanCoin': loanCoin,
        'loanAmount': loanAmount.toString(),
        'collateralCoin': collateralCoin,
        'collateralAmount': requiredCollateralAmount.toString(),
      };
    } else {
      throw Exception('Loan application failed');
    }
  }

  static Future<Map<String, dynamic>> repay({
    required int orderId,
    required double amount,
    String? type,
  }) async {
    await Future.delayed(Duration(milliseconds: 300 + _random.nextInt(400)));

    final orderIndex = _orders.indexWhere((o) => o.orderId == orderId);
    if (orderIndex == -1) {
      throw Exception('Order not found');
    }

    final order = _orders[orderIndex];
    if (order.status != 'ACCRUING') {
      throw Exception('Order not active');
    }

    // Calculate accrued interest
    final hoursElapsed = DateTime.now().difference(order.loanDate).inHours;
    final accruedInterest =
        order.loanAmount * order.hourlyInterestRate * hoursElapsed;
    final totalOwed = order.loanAmount + accruedInterest;

    if (amount > totalOwed) {
      throw Exception('Repayment amount exceeds total owed');
    }

    // Simulate success rate
    if (_random.nextDouble() < 0.98) {
      final repayType = type ?? (amount >= totalOwed ? 'Full' : 'Partial');
      final remainingPrincipal = (order.loanAmount - amount + accruedInterest)
          .clamp(0.0, order.loanAmount);
      final remainingInterest =
          accruedInterest - (amount - (order.loanAmount - remainingPrincipal));

      final repayment = VipLoanRepayment(
        orderId: orderId,
        repayAmount: amount,
        repayType: repayType,
        remainingPrincipal: remainingPrincipal,
        remainingInterest: remainingInterest.clamp(0.0, double.infinity),
        currentLTV: order.currentLTV,
        repayTime: DateTime.now(),
      );

      _repayments.add(repayment);

      // Update order status
      final newStatus = remainingPrincipal <= 0 ? 'PAID' : 'ACCRUING';
      final updatedOrder = VipLoanOrder(
        orderId: order.orderId,
        loanCoin: order.loanCoin,
        collateralCoin: order.collateralCoin,
        loanAmount: remainingPrincipal,
        collateralAmount: order.collateralAmount,
        initialLTV: order.initialLTV,
        currentLTV: order.currentLTV,
        hourlyInterestRate: order.hourlyInterestRate,
        status: newStatus,
        loanDate: order.loanDate,
        loanTerm: order.loanTerm,
      );

      _orders[orderIndex] = updatedOrder;

      return {
        'orderId': orderId,
        'repayAmount': amount.toString(),
        'remainingPrincipal': remainingPrincipal.toString(),
        'remainingInterest': remainingInterest.toString(),
      };
    } else {
      throw Exception('Repayment failed');
    }
  }

  static List<VipLoanOrder> getOrders({
    int? orderId,
    String? loanCoin,
    String? collateralCoin,
    String? status,
  }) {
    var orders = List<VipLoanOrder>.from(_orders);

    if (orderId != null) {
      orders = orders.where((o) => o.orderId == orderId).toList();
    }

    if (loanCoin != null) {
      orders = orders.where((o) => o.loanCoin == loanCoin).toList();
    }

    if (collateralCoin != null) {
      orders = orders.where((o) => o.collateralCoin == collateralCoin).toList();
    }

    if (status != null) {
      orders = orders.where((o) => o.status == status).toList();
    }

    return orders..sort((a, b) => b.loanDate.compareTo(a.loanDate));
  }

  static List<VipLoanRepayment> getRepayments({
    int? orderId,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    var repayments = List<VipLoanRepayment>.from(_repayments);

    if (orderId != null) {
      repayments = repayments.where((r) => r.orderId == orderId).toList();
    }

    if (startTime != null) {
      repayments =
          repayments.where((r) => r.repayTime.isAfter(startTime)).toList();
    }

    if (endTime != null) {
      repayments =
          repayments.where((r) => r.repayTime.isBefore(endTime)).toList();
    }

    return repayments..sort((a, b) => b.repayTime.compareTo(a.repayTime));
  }

  static VipLoanAccount getAccountSummary() {
    final activeOrders = _orders.where((o) => o.status == 'ACCRUING').toList();

    double totalCollateralBTC = 0.0;
    double totalLoanBTC = 0.0;

    for (final order in activeOrders) {
      // Simulate conversion to BTC values
      final collateralBTC = order.collateralCoin == 'BTC'
          ? order.collateralAmount
          : order.collateralAmount / 50000;
      final loanBTC =
          order.loanCoin == 'BTC' ? order.loanAmount : order.loanAmount / 50000;

      totalCollateralBTC += collateralBTC;
      totalLoanBTC += loanBTC;
    }

    final totalCollateralUSDT = totalCollateralBTC * 50000;
    final totalLoanUSDT = totalLoanBTC * 50000;
    final freeCollateralBTC = totalCollateralBTC * 0.3; // Assume 30% free
    final freeCollateralUSDT = freeCollateralBTC * 50000;
    final currentLTV = totalLoanUSDT > 0
        ? (totalLoanUSDT / totalCollateralUSDT).clamp(0.0, 1.0)
        : 0.0;

    return VipLoanAccount(
      totalCollateralValueInBTC: totalCollateralBTC.toStringAsFixed(8),
      totalCollateralValueInUSDT: totalCollateralUSDT.toStringAsFixed(2),
      totalLoanValueInBTC: totalLoanBTC.toStringAsFixed(8),
      totalLoanValueInUSDT: totalLoanUSDT.toStringAsFixed(2),
      totalFreeCollateralValueInBTC: freeCollateralBTC.toStringAsFixed(8),
      totalFreeCollateralValueInUSDT: freeCollateralUSDT.toStringAsFixed(2),
      currentLTV: currentLTV.toStringAsFixed(4),
    );
  }
}

// Simulated VIP Loan API
class SimulatedVipLoan {
  static bool _simulationMode = false;

  static void enableSimulation() {
    _simulationMode = true;
  }

  static void disableSimulation() {
    _simulationMode = false;
  }

  static bool get isSimulationEnabled => _simulationMode;

  static Future<Map<String, dynamic>> getLoanableAssetsData({
    String? loanCoin,
    bool? vipLevel,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 150 + Random().nextInt(100)));

    final assets = VipLoanAssets.getLoanableAssets(loanCoin: loanCoin);
    final filteredAssets = vipLevel != null
        ? assets.where((a) => a.vipLevel == vipLevel).toList()
        : assets;

    return {
      'rows': filteredAssets.map((a) => a.toJson()).toList(),
    };
  }

  static Future<Map<String, dynamic>> getCollateralAssetsData({
    String? collateralCoin,
    bool? vipLevel,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 150 + Random().nextInt(100)));

    final assets =
        VipLoanAssets.getCollateralAssets(collateralCoin: collateralCoin);
    final filteredAssets = vipLevel != null
        ? assets.where((a) => a.vipLevel == vipLevel).toList()
        : assets;

    return {
      'rows': filteredAssets.map((a) => a.toJson()).toList(),
    };
  }

  static Future<Map<String, dynamic>> borrow({
    required String loanCoin,
    required String collateralCoin,
    required double loanAmount,
    required int loanTerm,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    return await VipLoanOperations.borrow(
      loanCoin: loanCoin,
      collateralCoin: collateralCoin,
      loanAmount: loanAmount,
      loanTerm: loanTerm,
    );
  }

  static Future<Map<String, dynamic>> repay({
    required int orderId,
    required double amount,
    String? type,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    return await VipLoanOperations.repay(
      orderId: orderId,
      amount: amount,
      type: type,
    );
  }

  static Future<Map<String, dynamic>> getOngoingOrders({
    int? orderId,
    String? loanCoin,
    String? collateralCoin,
    int? current,
    int? limit,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 200 + Random().nextInt(150)));

    final orders = VipLoanOperations.getOrders(
      orderId: orderId,
      loanCoin: loanCoin,
      collateralCoin: collateralCoin,
      status: 'ACCRUING',
    );

    final total = orders.length;
    final page = current ?? 1;
    final pageSize = limit ?? 10;
    final startIndex = (page - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, total);

    final pageOrders = orders.sublist(
      startIndex.clamp(0, total),
      endIndex,
    );

    return {
      'rows': pageOrders.map((o) => o.toJson()).toList(),
      'total': total,
    };
  }

  static Future<Map<String, dynamic>> getRepayHistory({
    int? orderId,
    String? loanCoin,
    DateTime? startTime,
    DateTime? endTime,
    int? current,
    int? limit,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 200 + Random().nextInt(150)));

    final repayments = VipLoanOperations.getRepayments(
      orderId: orderId,
      startTime: startTime,
      endTime: endTime,
    );

    final total = repayments.length;
    final page = current ?? 1;
    final pageSize = limit ?? 10;
    final startIndex = (page - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, total);

    final pageRepayments = repayments.sublist(
      startIndex.clamp(0, total),
      endIndex,
    );

    return {
      'rows': pageRepayments.map((r) => r.toJson()).toList(),
      'total': total,
    };
  }

  static Future<Map<String, dynamic>> getAccount() async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 100 + Random().nextInt(50)));

    return VipLoanOperations.getAccountSummary().toJson();
  }
}

class VipLoan extends BinanceBase {
  VipLoan({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  // Enable simulation mode
  void enableSimulation() {
    SimulatedVipLoan.enableSimulation();
  }

  // Disable simulation mode
  void disableSimulation() {
    SimulatedVipLoan.disableSimulation();
  }

  // Check if simulation is enabled
  bool get isSimulationEnabled => SimulatedVipLoan.isSimulationEnabled;

  // Get VIP loanable assets data
  Future<Map<String, dynamic>> getVipLoanableAssetsData({
    String? loanCoin,
    bool? vipLevel,
    int? recvWindow,
  }) {
    if (SimulatedVipLoan.isSimulationEnabled) {
      return SimulatedVipLoan.getLoanableAssetsData(
        loanCoin: loanCoin,
        vipLevel: vipLevel,
      );
    }

    final params = <String, dynamic>{};
    if (loanCoin != null) params['loanCoin'] = loanCoin;
    if (vipLevel != null) params['vipLevel'] = vipLevel;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/loan/vip/loanable/data', params: params);
  }

  // Get VIP collateral assets data
  Future<Map<String, dynamic>> getVipCollateralAssetsData({
    String? collateralCoin,
    bool? vipLevel,
    int? recvWindow,
  }) {
    if (SimulatedVipLoan.isSimulationEnabled) {
      return SimulatedVipLoan.getCollateralAssetsData(
        collateralCoin: collateralCoin,
        vipLevel: vipLevel,
      );
    }

    final params = <String, dynamic>{};
    if (collateralCoin != null) params['collateralCoin'] = collateralCoin;
    if (vipLevel != null) params['vipLevel'] = vipLevel;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/loan/vip/collateral/data',
        params: params);
  }

  // Borrow VIP loan
  Future<Map<String, dynamic>> vipBorrow({
    required String loanCoin,
    required String collateralCoin,
    required double loanAmount,
    required int loanTerm,
    int? recvWindow,
  }) {
    if (SimulatedVipLoan.isSimulationEnabled) {
      return SimulatedVipLoan.borrow(
        loanCoin: loanCoin,
        collateralCoin: collateralCoin,
        loanAmount: loanAmount,
        loanTerm: loanTerm,
      );
    }

    final params = <String, dynamic>{
      'loanCoin': loanCoin,
      'collateralCoin': collateralCoin,
      'loanAmount': loanAmount.toString(),
      'loanTerm': loanTerm,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/loan/vip/borrow', params: params);
  }

  // Repay VIP loan
  Future<Map<String, dynamic>> vipRepay({
    required int orderId,
    required double amount,
    String? type,
    int? recvWindow,
  }) {
    if (SimulatedVipLoan.isSimulationEnabled) {
      return SimulatedVipLoan.repay(
        orderId: orderId,
        amount: amount,
        type: type,
      );
    }

    final params = <String, dynamic>{
      'orderId': orderId,
      'amount': amount.toString(),
    };
    if (type != null) params['type'] = type;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/loan/vip/repay', params: params);
  }

  // Get ongoing VIP loan orders
  Future<Map<String, dynamic>> getVipOngoingOrders({
    int? orderId,
    String? loanCoin,
    String? collateralCoin,
    int? current,
    int? limit,
    int? recvWindow,
  }) {
    if (SimulatedVipLoan.isSimulationEnabled) {
      return SimulatedVipLoan.getOngoingOrders(
        orderId: orderId,
        loanCoin: loanCoin,
        collateralCoin: collateralCoin,
        current: current,
        limit: limit,
      );
    }

    final params = <String, dynamic>{};
    if (orderId != null) params['orderId'] = orderId;
    if (loanCoin != null) params['loanCoin'] = loanCoin;
    if (collateralCoin != null) params['collateralCoin'] = collateralCoin;
    if (current != null) params['current'] = current;
    if (limit != null) params['limit'] = limit;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/loan/vip/ongoing/orders',
        params: params);
  }

  // Get VIP loan repayment history
  Future<Map<String, dynamic>> getVipRepayHistory({
    int? orderId,
    String? loanCoin,
    DateTime? startTime,
    DateTime? endTime,
    int? current,
    int? limit,
    int? recvWindow,
  }) {
    if (SimulatedVipLoan.isSimulationEnabled) {
      return SimulatedVipLoan.getRepayHistory(
        orderId: orderId,
        loanCoin: loanCoin,
        startTime: startTime,
        endTime: endTime,
        current: current,
        limit: limit,
      );
    }

    final params = <String, dynamic>{};
    if (orderId != null) params['orderId'] = orderId;
    if (loanCoin != null) params['loanCoin'] = loanCoin;
    if (startTime != null)
      params['startTime'] = startTime.millisecondsSinceEpoch;
    if (endTime != null) params['endTime'] = endTime.millisecondsSinceEpoch;
    if (current != null) params['current'] = current;
    if (limit != null) params['limit'] = limit;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/loan/vip/repay/history',
        params: params);
  }

  // Get VIP loan account
  Future<Map<String, dynamic>> getVipLoanAccount({int? recvWindow}) {
    if (SimulatedVipLoan.isSimulationEnabled) {
      return SimulatedVipLoan.getAccount();
    }

    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/loan/vip/account', params: params);
  }
}