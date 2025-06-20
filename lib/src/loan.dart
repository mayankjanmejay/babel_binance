import 'dart:math';
import 'binance_base.dart';

class Loan extends BinanceBase {
  final LoanBorrow borrow;
  final LoanRepay repay;
  final LoanHistory history;
  final SimulatedLoan simulatedLoan;

  Loan({String? apiKey, String? apiSecret})
      : borrow = LoanBorrow(apiKey: apiKey, apiSecret: apiSecret),
        repay = LoanRepay(apiKey: apiKey, apiSecret: apiSecret),
        history = LoanHistory(apiKey: apiKey, apiSecret: apiSecret),
        simulatedLoan = SimulatedLoan(apiKey: apiKey, apiSecret: apiSecret),
        super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getLoanIncomeHistory({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/loan/income', params: params);
  }
}

class LoanBorrow extends BinanceBase {
  LoanBorrow({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> borrowCrypto({
    required String loanCoin,
    required String collateralCoin,
    required double loanAmount,
    int? loanTerm,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'loanCoin': loanCoin,
      'collateralCoin': collateralCoin,
      'loanAmount': loanAmount,
    };
    if (loanTerm != null) params['loanTerm'] = loanTerm;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/loan/borrow', params: params);
  }

  Future<Map<String, dynamic>> getBorrowHistory({
    String? orderId,
    String? loanCoin,
    String? collateralCoin,
    int? startTime,
    int? endTime,
    int? current,
    int? limit,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{};
    if (orderId != null) params['orderId'] = orderId;
    if (loanCoin != null) params['loanCoin'] = loanCoin;
    if (collateralCoin != null) params['collateralCoin'] = collateralCoin;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (current != null) params['current'] = current;
    if (limit != null) params['limit'] = limit;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/loan/borrow/history', params: params);
  }

  Future<Map<String, dynamic>> getOngoingOrders({
    String? orderId,
    String? loanCoin,
    String? collateralCoin,
    int? current,
    int? limit,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{};
    if (orderId != null) params['orderId'] = orderId;
    if (loanCoin != null) params['loanCoin'] = loanCoin;
    if (collateralCoin != null) params['collateralCoin'] = collateralCoin;
    if (current != null) params['current'] = current;
    if (limit != null) params['limit'] = limit;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/loan/ongoing/orders', params: params);
  }
}

class LoanRepay extends BinanceBase {
  LoanRepay({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> repayCrypto({
    required String orderId,
    required double amount,
    int? type, // 1: repay with borrowed coin, 2: repay with collateral
    bool? collateralReturn,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'orderId': orderId,
      'amount': amount,
    };
    if (type != null) params['type'] = type;
    if (collateralReturn != null) params['collateralReturn'] = collateralReturn;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/loan/repay', params: params);
  }

  Future<Map<String, dynamic>> getRepayHistory({
    String? orderId,
    String? loanCoin,
    String? collateralCoin,
    int? startTime,
    int? endTime,
    int? current,
    int? limit,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{};
    if (orderId != null) params['orderId'] = orderId;
    if (loanCoin != null) params['loanCoin'] = loanCoin;
    if (collateralCoin != null) params['collateralCoin'] = collateralCoin;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (current != null) params['current'] = current;
    if (limit != null) params['limit'] = limit;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/loan/repay/history', params: params);
  }

  Future<Map<String, dynamic>> adjustLtv({
    required String orderId,
    required double amount,
    required bool addOrRmv, // true: add collateral, false: remove collateral
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'orderId': orderId,
      'amount': amount,
      'addOrRmv': addOrRmv,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/loan/adjust/ltv', params: params);
  }
}

class LoanHistory extends BinanceBase {
  LoanHistory({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getLoanIncomeHistory({
    String? asset,
    String? type,
    int? startTime,
    int? endTime,
    int? limit,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{};
    if (asset != null) params['asset'] = asset;
    if (type != null) params['type'] = type;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (limit != null) params['limit'] = limit;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/loan/income', params: params);
  }

  Future<Map<String, dynamic>> getLtvAdjustHistory({
    String? orderId,
    String? loanCoin,
    String? collateralCoin,
    int? startTime,
    int? endTime,
    int? current,
    int? limit,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{};
    if (orderId != null) params['orderId'] = orderId;
    if (loanCoin != null) params['loanCoin'] = loanCoin;
    if (collateralCoin != null) params['collateralCoin'] = collateralCoin;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (current != null) params['current'] = current;
    if (limit != null) params['limit'] = limit;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/loan/ltv/adjustment/history',
        params: params);
  }
}

class SimulatedLoan {
  final String? apiKey;
  final String? apiSecret;
  final Random _random = Random();

  // Supported loan pairs with rates and terms
  final Map<String, Map<String, dynamic>> _loanProducts = {
    'BTC_USDT': {
      'loanCoin': 'USDT',
      'collateralCoin': 'BTC',
      'maxLoanableAmount': 1000000.0,
      'loanToValueRatio': 0.65, // 65% LTV
      'interestRate': 0.08, // 8% annual
      'maxLoanTerm': 90, // days
      'liquidationThreshold': 0.75,
      'marginCallThreshold': 0.70,
    },
    'ETH_USDT': {
      'loanCoin': 'USDT',
      'collateralCoin': 'ETH',
      'maxLoanableAmount': 500000.0,
      'loanToValueRatio': 0.60,
      'interestRate': 0.09,
      'maxLoanTerm': 90,
      'liquidationThreshold': 0.75,
      'marginCallThreshold': 0.70,
    },
    'BNB_BUSD': {
      'loanCoin': 'BUSD',
      'collateralCoin': 'BNB',
      'maxLoanableAmount': 200000.0,
      'loanToValueRatio': 0.55,
      'interestRate': 0.07,
      'maxLoanTerm': 60,
      'liquidationThreshold': 0.75,
      'marginCallThreshold': 0.70,
    },
    'ADA_USDT': {
      'loanCoin': 'USDT',
      'collateralCoin': 'ADA',
      'maxLoanableAmount': 100000.0,
      'loanToValueRatio': 0.50,
      'interestRate': 0.12,
      'maxLoanTerm': 30,
      'liquidationThreshold': 0.75,
      'marginCallThreshold': 0.70,
    },
  };

  // Active loans
  final Map<String, Map<String, dynamic>> _activeLoans = {};

  // Transaction history
  final List<Map<String, dynamic>> _borrowHistory = [];
  final List<Map<String, dynamic>> _repayHistory = [];
  final List<Map<String, dynamic>> _ltvAdjustHistory = [];
  final List<Map<String, dynamic>> _incomeHistory = [];

  SimulatedLoan({this.apiKey, this.apiSecret});

  Future<Map<String, dynamic>> simulateBorrowCrypto({
    required String loanCoin,
    required String collateralCoin,
    required double loanAmount,
    int? loanTerm,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    final productKey = '${collateralCoin}_$loanCoin';
    final product = _loanProducts[productKey];

    if (product == null) {
      throw Exception('Loan product not available: $productKey');
    }

    // Validate loan amount
    if (loanAmount > product['maxLoanableAmount']) {
      throw Exception(
          'Loan amount exceeds maximum: ${product['maxLoanableAmount']}');
    }

    // Calculate required collateral
    final ltvRatio = product['loanToValueRatio'] as double;
    final requiredCollateral = loanAmount / ltvRatio;

    // Simulate collateral price (using mock prices)
    final collateralPrice = _getMockPrice(collateralCoin);
    final requiredCollateralAmount = requiredCollateral / collateralPrice;

    final orderId = _generateOrderId();
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final term = loanTerm ?? product['maxLoanTerm'] as int;
    final interestRate = product['interestRate'] as double;

    // 95% success rate for loan applications
    final success = _random.nextDouble() < 0.95;

    if (success) {
      // Create active loan
      _activeLoans[orderId] = {
        'orderId': orderId,
        'loanCoin': loanCoin,
        'collateralCoin': collateralCoin,
        'loanAmount': loanAmount,
        'collateralAmount': requiredCollateralAmount,
        'collateralValue': requiredCollateral,
        'currentLtv': ltvRatio,
        'interestRate': interestRate,
        'loanTerm': term,
        'borrowTime': currentTime,
        'dueTime': currentTime + (term * 24 * 60 * 60 * 1000),
        'status': 'ONGOING',
        'accruedInterest': 0.0,
        'totalDebt': loanAmount,
        'liquidationThreshold': product['liquidationThreshold'],
        'marginCallThreshold': product['marginCallThreshold'],
      };

      // Add to borrow history
      _borrowHistory.insert(0, {
        'orderId': orderId,
        'loanCoin': loanCoin,
        'collateralCoin': collateralCoin,
        'loanAmount': loanAmount.toString(),
        'collateralAmount': requiredCollateralAmount.toStringAsFixed(8),
        'borrowTime': currentTime,
        'status': 'CONFIRMED',
        'loanTerm': term,
        'interestRate': interestRate.toString(),
      });
    }

    return {
      'orderId': success ? orderId : null,
      'loanCoin': loanCoin,
      'collateralCoin': collateralCoin,
      'loanAmount': success ? loanAmount.toString() : null,
      'collateralAmount':
          success ? requiredCollateralAmount.toStringAsFixed(8) : null,
      'status': success ? 'CONFIRMED' : 'FAILED',
      'errorMsg': success ? null : 'Loan application failed',
    };
  }

  Future<Map<String, dynamic>> simulateRepayCrypto({
    required String orderId,
    required double amount,
    int? type,
    bool? collateralReturn,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    final loan = _activeLoans[orderId];
    if (loan == null) {
      throw Exception('Loan not found: $orderId');
    }

    if (loan['status'] != 'ONGOING') {
      throw Exception('Loan is not active');
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final borrowTime = loan['borrowTime'] as int;
    final interestRate = loan['interestRate'] as double;
    final loanAmount = loan['loanAmount'] as double;

    // Calculate accrued interest
    final daysPassed = (currentTime - borrowTime) / (24 * 60 * 60 * 1000);
    final accruedInterest = loanAmount * interestRate * (daysPassed / 365);
    final totalDebt = loanAmount + accruedInterest;

    loan['accruedInterest'] = accruedInterest;
    loan['totalDebt'] = totalDebt;

    final repayType =
        type ?? 1; // 1: repay with borrowed coin, 2: repay with collateral
    final returnCollateral = collateralReturn ?? true;

    double actualRepayAmount = amount;
    String repayStatus = 'PARTIAL';

    if (amount >= totalDebt) {
      // Full repayment
      actualRepayAmount = totalDebt;
      repayStatus = 'COMPLETED';
      loan['status'] = 'COMPLETED';
      loan['completedTime'] = currentTime;

      if (returnCollateral) {
        loan['collateralReturned'] = true;
      }
    } else {
      // Partial repayment
      loan['totalDebt'] = totalDebt - amount;
      loan['loanAmount'] = loan['loanAmount'] - amount;
    }

    final repayId = _generateTransactionId();

    // Add to repay history
    _repayHistory.insert(0, {
      'repayId': repayId,
      'orderId': orderId,
      'loanCoin': loan['loanCoin'],
      'collateralCoin': loan['collateralCoin'],
      'repayAmount': actualRepayAmount.toString(),
      'repayType': repayType,
      'repayTime': currentTime,
      'status': repayStatus,
      'collateralReturned': returnCollateral && repayStatus == 'COMPLETED',
      'interestPaid':
          (accruedInterest * (amount / totalDebt)).toStringAsFixed(8),
    });

    return {
      'repayId': repayId,
      'orderId': orderId,
      'repayAmount': actualRepayAmount.toString(),
      'repayStatus': repayStatus,
      'remainingDebt': (loan['totalDebt'] as double).toStringAsFixed(8),
      'collateralReturned': returnCollateral && repayStatus == 'COMPLETED',
    };
  }

  Future<Map<String, dynamic>> simulateAdjustLtv({
    required String orderId,
    required double amount,
    required bool addOrRmv,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    final loan = _activeLoans[orderId];
    if (loan == null) {
      throw Exception('Loan not found: $orderId');
    }

    if (loan['status'] != 'ONGOING') {
      throw Exception('Loan is not active');
    }

    final collateralCoin = loan['collateralCoin'] as String;
    final collateralPrice = _getMockPrice(collateralCoin);
    final currentCollateralAmount = loan['collateralAmount'] as double;
    final totalDebt = loan['totalDebt'] as double;

    double newCollateralAmount;
    double newCollateralValue;

    if (addOrRmv) {
      // Add collateral
      newCollateralAmount = currentCollateralAmount + amount;
      newCollateralValue = newCollateralAmount * collateralPrice;
    } else {
      // Remove collateral
      if (amount > currentCollateralAmount) {
        throw Exception('Cannot remove more collateral than available');
      }

      newCollateralAmount = currentCollateralAmount - amount;
      newCollateralValue = newCollateralAmount * collateralPrice;

      // Check if new LTV is safe
      final newLtv = totalDebt / newCollateralValue;
      final marginCallThreshold = loan['marginCallThreshold'] as double;

      if (newLtv > marginCallThreshold) {
        throw Exception('LTV would exceed margin call threshold');
      }
    }

    final newLtv = totalDebt / newCollateralValue;

    // Update loan
    loan['collateralAmount'] = newCollateralAmount;
    loan['collateralValue'] = newCollateralValue;
    loan['currentLtv'] = newLtv;

    final adjustId = _generateTransactionId();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Add to LTV adjustment history
    _ltvAdjustHistory.insert(0, {
      'adjustId': adjustId,
      'orderId': orderId,
      'loanCoin': loan['loanCoin'],
      'collateralCoin': collateralCoin,
      'adjustAmount': amount.toString(),
      'adjustType': addOrRmv ? 'ADD' : 'REMOVE',
      'adjustTime': currentTime,
      'status': 'CONFIRMED',
      'newLtv': newLtv.toString(),
      'newCollateralAmount': newCollateralAmount.toStringAsFixed(8),
    });

    return {
      'adjustId': adjustId,
      'orderId': orderId,
      'adjustAmount': amount.toString(),
      'adjustType': addOrRmv ? 'ADD' : 'REMOVE',
      'newLtv': newLtv.toStringAsFixed(4),
      'newCollateralAmount': newCollateralAmount.toStringAsFixed(8),
      'status': 'CONFIRMED',
    };
  }

  Future<Map<String, dynamic>> simulateGetBorrowHistory({
    String? orderId,
    String? loanCoin,
    String? collateralCoin,
    int? startTime,
    int? endTime,
    int? current,
    int? limit,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    // Generate mock history if empty
    if (_borrowHistory.isEmpty) {
      _generateMockBorrowHistory();
    }

    var filteredHistory = _borrowHistory.where((borrow) {
      if (orderId != null && borrow['orderId'] != orderId) return false;
      if (loanCoin != null && borrow['loanCoin'] != loanCoin) return false;
      if (collateralCoin != null && borrow['collateralCoin'] != collateralCoin)
        return false;
      if (startTime != null && borrow['borrowTime'] < startTime) return false;
      if (endTime != null && borrow['borrowTime'] > endTime) return false;
      return true;
    }).toList();

    final resultLimit = limit ?? 10;
    final page = current ?? 1;
    final offset = (page - 1) * resultLimit;

    final paginatedHistory =
        filteredHistory.skip(offset).take(resultLimit).toList();

    return {
      'rows': paginatedHistory,
      'total': filteredHistory.length,
    };
  }

  Future<Map<String, dynamic>> simulateGetOngoingOrders({
    String? orderId,
    String? loanCoin,
    String? collateralCoin,
    int? current,
    int? limit,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    var ongoingLoans = _activeLoans.values.where((loan) {
      if (loan['status'] != 'ONGOING') return false;
      if (orderId != null && loan['orderId'] != orderId) return false;
      if (loanCoin != null && loan['loanCoin'] != loanCoin) return false;
      if (collateralCoin != null && loan['collateralCoin'] != collateralCoin)
        return false;
      return true;
    }).toList();

    // Update accrued interest for ongoing loans
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    for (final loan in ongoingLoans) {
      final borrowTime = loan['borrowTime'] as int;
      final interestRate = loan['interestRate'] as double;
      final loanAmount = loan['loanAmount'] as double;

      final daysPassed = (currentTime - borrowTime) / (24 * 60 * 60 * 1000);
      final accruedInterest = loanAmount * interestRate * (daysPassed / 365);
      loan['accruedInterest'] = accruedInterest;
      loan['totalDebt'] = loanAmount + accruedInterest;

      // Update current LTV based on market prices
      final collateralCoin = loan['collateralCoin'] as String;
      final collateralAmount = loan['collateralAmount'] as double;
      final collateralPrice = _getMockPrice(collateralCoin);
      final currentCollateralValue = collateralAmount * collateralPrice;
      loan['collateralValue'] = currentCollateralValue;
      loan['currentLtv'] = loan['totalDebt'] / currentCollateralValue;
    }

    final resultLimit = limit ?? 10;
    final page = current ?? 1;
    final offset = (page - 1) * resultLimit;

    final paginatedLoans = ongoingLoans.skip(offset).take(resultLimit).toList();

    return {
      'rows': paginatedLoans,
      'total': ongoingLoans.length,
    };
  }

  Future<Map<String, dynamic>> simulateGetRepayHistory({
    String? orderId,
    String? loanCoin,
    String? collateralCoin,
    int? startTime,
    int? endTime,
    int? current,
    int? limit,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    var filteredHistory = _repayHistory.where((repay) {
      if (orderId != null && repay['orderId'] != orderId) return false;
      if (loanCoin != null && repay['loanCoin'] != loanCoin) return false;
      if (collateralCoin != null && repay['collateralCoin'] != collateralCoin)
        return false;
      if (startTime != null && repay['repayTime'] < startTime) return false;
      if (endTime != null && repay['repayTime'] > endTime) return false;
      return true;
    }).toList();

    final resultLimit = limit ?? 10;
    final page = current ?? 1;
    final offset = (page - 1) * resultLimit;

    final paginatedHistory =
        filteredHistory.skip(offset).take(resultLimit).toList();

    return {
      'rows': paginatedHistory,
      'total': filteredHistory.length,
    };
  }

  Future<Map<String, dynamic>> simulateGetLoanIncomeHistory({
    String? asset,
    String? type,
    int? startTime,
    int? endTime,
    int? limit,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    // Generate mock income history if empty
    if (_incomeHistory.isEmpty) {
      _generateMockIncomeHistory();
    }

    var filteredHistory = _incomeHistory.where((income) {
      if (asset != null && income['asset'] != asset) return false;
      if (type != null && income['type'] != type) return false;
      if (startTime != null && income['time'] < startTime) return false;
      if (endTime != null && income['time'] > endTime) return false;
      return true;
    }).toList();

    final resultLimit = limit ?? 20;
    final paginatedHistory = filteredHistory.take(resultLimit).toList();

    return {
      'rows': paginatedHistory,
      'total': filteredHistory.length,
    };
  }

  Future<Map<String, dynamic>> simulateGetLtvAdjustHistory({
    String? orderId,
    String? loanCoin,
    String? collateralCoin,
    int? startTime,
    int? endTime,
    int? current,
    int? limit,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    var filteredHistory = _ltvAdjustHistory.where((adjust) {
      if (orderId != null && adjust['orderId'] != orderId) return false;
      if (loanCoin != null && adjust['loanCoin'] != loanCoin) return false;
      if (collateralCoin != null && adjust['collateralCoin'] != collateralCoin)
        return false;
      if (startTime != null && adjust['adjustTime'] < startTime) return false;
      if (endTime != null && adjust['adjustTime'] > endTime) return false;
      return true;
    }).toList();

    final resultLimit = limit ?? 10;
    final page = current ?? 1;
    final offset = (page - 1) * resultLimit;

    final paginatedHistory =
        filteredHistory.skip(offset).take(resultLimit).toList();

    return {
      'rows': paginatedHistory,
      'total': filteredHistory.length,
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

  String _generateOrderId() {
    return 'loan_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(999999)}';
  }

  String _generateTransactionId() {
    return 'txn_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(999999)}';
  }

  double _getMockPrice(String asset) {
    final prices = {
      'BTC': 95000.0,
      'ETH': 3200.0,
      'BNB': 650.0,
      'ADA': 0.45,
      'SOL': 180.0,
      'USDT': 1.0,
      'BUSD': 1.0,
    };
    return prices[asset] ?? 1.0;
  }

  void _generateMockBorrowHistory() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final loanPairs = _loanProducts.keys.toList();

    for (int i = 0; i < 5; i++) {
      final pair = loanPairs[_random.nextInt(loanPairs.length)];
      final product = _loanProducts[pair]!;
      final time =
          currentTime - (i * 7 * 24 * 60 * 60 * 1000); // Weekly intervals
      final loanAmount = _random.nextDouble() * 10000 + 1000;

      _borrowHistory.add({
        'orderId': _generateOrderId(),
        'loanCoin': product['loanCoin'],
        'collateralCoin': product['collateralCoin'],
        'loanAmount': loanAmount.toStringAsFixed(2),
        'collateralAmount': (loanAmount /
                (product['loanToValueRatio'] as double) /
                _getMockPrice(product['collateralCoin']))
            .toStringAsFixed(8),
        'borrowTime': time,
        'status': 'CONFIRMED',
        'loanTerm': product['maxLoanTerm'],
        'interestRate': (product['interestRate'] as double).toString(),
      });
    }
  }

  void _generateMockIncomeHistory() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final assets = ['USDT', 'BUSD', 'BTC', 'ETH'];

    for (int i = 0; i < 30; i++) {
      final asset = assets[_random.nextInt(assets.length)];
      final time = currentTime - (i * 24 * 60 * 60 * 1000); // Daily intervals
      final income = _random.nextDouble() * 50 + 5;

      _incomeHistory.add({
        'asset': asset,
        'type': 'borrowIn',
        'amount': income.toStringAsFixed(8),
        'time': time,
        'tranId': _generateTransactionId(),
        'status': 'CONFIRMED',
      });
    }
  }
}
