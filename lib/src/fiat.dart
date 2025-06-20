import 'dart:math';
import 'binance_base.dart';

// Fiat Transaction Models
class FiatOrder {
  final String orderNo;
  final String fiatCurrency;
  final String indicatedAmount;
  final String amount;
  final String totalFee;
  final String method;
  final String status;
  final DateTime createTime;
  final DateTime updateTime;
  final String transactionType; // "0" for deposit, "1" for withdraw

  FiatOrder({
    required this.orderNo,
    required this.fiatCurrency,
    required this.indicatedAmount,
    required this.amount,
    required this.totalFee,
    required this.method,
    required this.status,
    required this.createTime,
    required this.updateTime,
    required this.transactionType,
  });

  Map<String, dynamic> toJson() => {
        'orderNo': orderNo,
        'fiatCurrency': fiatCurrency,
        'indicatedAmount': indicatedAmount,
        'amount': amount,
        'totalFee': totalFee,
        'method': method,
        'status': status,
        'createTime': createTime.millisecondsSinceEpoch,
        'updateTime': updateTime.millisecondsSinceEpoch,
        'transactionType': transactionType,
      };
}

class FiatPayment {
  final String orderNo;
  final String sourceAmount;
  final String fiatCurrency;
  final String obtainAmount;
  final String cryptoCurrency;
  final double totalFee;
  final double price;
  final String status;
  final DateTime createTime;
  final DateTime updateTime;

  FiatPayment({
    required this.orderNo,
    required this.sourceAmount,
    required this.fiatCurrency,
    required this.obtainAmount,
    required this.cryptoCurrency,
    required this.totalFee,
    required this.price,
    required this.status,
    required this.createTime,
    required this.updateTime,
  });

  Map<String, dynamic> toJson() => {
        'orderNo': orderNo,
        'sourceAmount': sourceAmount,
        'fiatCurrency': fiatCurrency,
        'obtainAmount': obtainAmount,
        'cryptoCurrency': cryptoCurrency,
        'totalFee': totalFee.toString(),
        'price': price.toString(),
        'status': status,
        'createTime': createTime.millisecondsSinceEpoch,
        'updateTime': updateTime.millisecondsSinceEpoch,
      };
}

class FiatCurrency {
  final String currency;
  final String name;
  final bool depositEnabled;
  final bool withdrawEnabled;
  final double minDeposit;
  final double maxDeposit;
  final double minWithdraw;
  final double maxWithdraw;
  final double depositFee;
  final double withdrawFee;

  FiatCurrency({
    required this.currency,
    required this.name,
    required this.depositEnabled,
    required this.withdrawEnabled,
    required this.minDeposit,
    required this.maxDeposit,
    required this.minWithdraw,
    required this.maxWithdraw,
    required this.depositFee,
    required this.withdrawFee,
  });

  Map<String, dynamic> toJson() => {
        'currency': currency,
        'name': name,
        'depositEnabled': depositEnabled,
        'withdrawEnabled': withdrawEnabled,
        'minDeposit': minDeposit.toString(),
        'maxDeposit': maxDeposit.toString(),
        'minWithdraw': minWithdraw.toString(),
        'maxWithdraw': maxWithdraw.toString(),
        'depositFee': depositFee.toString(),
        'withdrawFee': withdrawFee.toString(),
      };
}

// Fiat Currency Management
class FiatCurrencies {
  static final List<FiatCurrency> _currencies = [
    FiatCurrency(
      currency: 'USD',
      name: 'US Dollar',
      depositEnabled: true,
      withdrawEnabled: true,
      minDeposit: 10.0,
      maxDeposit: 50000.0,
      minWithdraw: 10.0,
      maxWithdraw: 50000.0,
      depositFee: 0.0,
      withdrawFee: 15.0,
    ),
    FiatCurrency(
      currency: 'EUR',
      name: 'Euro',
      depositEnabled: true,
      withdrawEnabled: true,
      minDeposit: 10.0,
      maxDeposit: 45000.0,
      minWithdraw: 10.0,
      maxWithdraw: 45000.0,
      depositFee: 0.0,
      withdrawFee: 1.5,
    ),
    FiatCurrency(
      currency: 'GBP',
      name: 'British Pound',
      depositEnabled: true,
      withdrawEnabled: true,
      minDeposit: 10.0,
      maxDeposit: 40000.0,
      minWithdraw: 10.0,
      maxWithdraw: 40000.0,
      depositFee: 0.0,
      withdrawFee: 1.5,
    ),
    FiatCurrency(
      currency: 'JPY',
      name: 'Japanese Yen',
      depositEnabled: true,
      withdrawEnabled: true,
      minDeposit: 1000.0,
      maxDeposit: 5000000.0,
      minWithdraw: 1000.0,
      maxWithdraw: 5000000.0,
      depositFee: 0.0,
      withdrawFee: 350.0,
    ),
    FiatCurrency(
      currency: 'AUD',
      name: 'Australian Dollar',
      depositEnabled: true,
      withdrawEnabled: true,
      minDeposit: 15.0,
      maxDeposit: 60000.0,
      minWithdraw: 15.0,
      maxWithdraw: 60000.0,
      depositFee: 0.0,
      withdrawFee: 2.0,
    ),
    FiatCurrency(
      currency: 'CAD',
      name: 'Canadian Dollar',
      depositEnabled: true,
      withdrawEnabled: true,
      minDeposit: 15.0,
      maxDeposit: 55000.0,
      minWithdraw: 15.0,
      maxWithdraw: 55000.0,
      depositFee: 0.0,
      withdrawFee: 2.0,
    ),
  ];

  static List<FiatCurrency> getCurrencies() => List.from(_currencies);

  static FiatCurrency? getCurrency(String currency) {
    try {
      return _currencies.firstWhere((c) => c.currency == currency);
    } catch (e) {
      return null;
    }
  }
}

// Fiat Operations
class FiatOperations {
  static final List<FiatOrder> _orders = [];
  static final List<FiatPayment> _payments = [];
  static final Random _random = Random();

  static String _generateOrderNo() {
    return 'FIAT_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(10000)}';
  }

  static Future<Map<String, dynamic>> deposit({
    required String fiatCurrency,
    required double amount,
    required String method,
  }) async {
    await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(600)));

    final currency = FiatCurrencies.getCurrency(fiatCurrency);
    if (currency == null) {
      throw Exception('Unsupported fiat currency');
    }

    if (!currency.depositEnabled) {
      throw Exception('Deposits not enabled for this currency');
    }

    if (amount < currency.minDeposit || amount > currency.maxDeposit) {
      throw Exception('Amount outside allowed range');
    }

    // Simulate success rate
    if (_random.nextDouble() < 0.90) {
      final orderNo = _generateOrderNo();
      final now = DateTime.now();
      final totalFee = currency.depositFee;
      final netAmount = amount - totalFee;

      final order = FiatOrder(
        orderNo: orderNo,
        fiatCurrency: fiatCurrency,
        indicatedAmount: amount.toString(),
        amount: netAmount.toString(),
        totalFee: totalFee.toString(),
        method: method,
        status: 'Processing',
        createTime: now,
        updateTime: now,
        transactionType: '0', // deposit
      );

      _orders.add(order);

      // Simulate processing delay
      Future.delayed(Duration(seconds: 30 + _random.nextInt(60)), () {
        final index = _orders.indexOf(order);
        if (index != -1) {
          _orders[index] = FiatOrder(
            orderNo: order.orderNo,
            fiatCurrency: order.fiatCurrency,
            indicatedAmount: order.indicatedAmount,
            amount: order.amount,
            totalFee: order.totalFee,
            method: order.method,
            status: 'Successful',
            createTime: order.createTime,
            updateTime: DateTime.now(),
            transactionType: order.transactionType,
          );
        }
      });

      return {
        'orderNo': orderNo,
        'code': '000000',
        'message': 'success',
        'data': true,
      };
    } else {
      throw Exception('Deposit failed');
    }
  }

  static Future<Map<String, dynamic>> withdraw({
    required String fiatCurrency,
    required double amount,
    required String method,
    Map<String, dynamic>? bankInfo,
  }) async {
    await Future.delayed(Duration(milliseconds: 400 + _random.nextInt(600)));

    final currency = FiatCurrencies.getCurrency(fiatCurrency);
    if (currency == null) {
      throw Exception('Unsupported fiat currency');
    }

    if (!currency.withdrawEnabled) {
      throw Exception('Withdrawals not enabled for this currency');
    }

    if (amount < currency.minWithdraw || amount > currency.maxWithdraw) {
      throw Exception('Amount outside allowed range');
    }

    // Simulate success rate
    if (_random.nextDouble() < 0.88) {
      final orderNo = _generateOrderNo();
      final now = DateTime.now();
      final totalFee = currency.withdrawFee;
      final netAmount = amount - totalFee;

      final order = FiatOrder(
        orderNo: orderNo,
        fiatCurrency: fiatCurrency,
        indicatedAmount: amount.toString(),
        amount: netAmount.toString(),
        totalFee: totalFee.toString(),
        method: method,
        status: 'Processing',
        createTime: now,
        updateTime: now,
        transactionType: '1', // withdraw
      );

      _orders.add(order);

      // Simulate processing delay
      Future.delayed(Duration(minutes: 5 + _random.nextInt(30)), () {
        final index = _orders.indexOf(order);
        if (index != -1) {
          _orders[index] = FiatOrder(
            orderNo: order.orderNo,
            fiatCurrency: order.fiatCurrency,
            indicatedAmount: order.indicatedAmount,
            amount: order.amount,
            totalFee: order.totalFee,
            method: order.method,
            status: 'Successful',
            createTime: order.createTime,
            updateTime: DateTime.now(),
            transactionType: order.transactionType,
          );
        }
      });

      return {
        'orderNo': orderNo,
        'code': '000000',
        'message': 'success',
        'data': true,
      };
    } else {
      throw Exception('Withdrawal failed');
    }
  }

  static Future<Map<String, dynamic>> buyCrypto({
    required String fiatCurrency,
    required String cryptoCurrency,
    required double amount,
  }) async {
    await Future.delayed(Duration(milliseconds: 500 + _random.nextInt(700)));

    // Simulate cryptocurrency prices
    final Map<String, double> cryptoPrices = {
      'BTC': 45000.0 + _random.nextDouble() * 10000.0,
      'ETH': 3000.0 + _random.nextDouble() * 1000.0,
      'BNB': 400.0 + _random.nextDouble() * 100.0,
      'ADA': 0.5 + _random.nextDouble() * 0.5,
      'SOL': 100.0 + _random.nextDouble() * 50.0,
    };

    final price = cryptoPrices[cryptoCurrency] ?? 1.0;
    final obtainAmount = amount / price;
    final fee = amount * 0.005; // 0.5% fee

    // Simulate success rate
    if (_random.nextDouble() < 0.92) {
      final orderNo = _generateOrderNo();
      final now = DateTime.now();

      final payment = FiatPayment(
        orderNo: orderNo,
        sourceAmount: amount.toString(),
        fiatCurrency: fiatCurrency,
        obtainAmount: obtainAmount.toString(),
        cryptoCurrency: cryptoCurrency,
        totalFee: fee,
        price: price,
        status: 'Successful',
        createTime: now,
        updateTime: now,
      );

      _payments.add(payment);

      return {
        'orderNo': orderNo,
        'price': price.toString(),
        'obtainAmount': obtainAmount.toString(),
        'totalFee': fee.toString(),
        'status': 'Successful',
      };
    } else {
      throw Exception('Purchase failed');
    }
  }

  static List<FiatOrder> getOrders({
    String? transactionType,
    String? fiatCurrency,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    var orders = List<FiatOrder>.from(_orders);

    if (transactionType != null) {
      orders =
          orders.where((o) => o.transactionType == transactionType).toList();
    }

    if (fiatCurrency != null) {
      orders = orders.where((o) => o.fiatCurrency == fiatCurrency).toList();
    }

    if (startTime != null) {
      orders = orders.where((o) => o.createTime.isAfter(startTime)).toList();
    }

    if (endTime != null) {
      orders = orders.where((o) => o.createTime.isBefore(endTime)).toList();
    }

    return orders..sort((a, b) => b.createTime.compareTo(a.createTime));
  }

  static List<FiatPayment> getPayments({
    String? fiatCurrency,
    String? cryptoCurrency,
    DateTime? startTime,
    DateTime? endTime,
  }) {
    var payments = List<FiatPayment>.from(_payments);

    if (fiatCurrency != null) {
      payments = payments.where((p) => p.fiatCurrency == fiatCurrency).toList();
    }

    if (cryptoCurrency != null) {
      payments =
          payments.where((p) => p.cryptoCurrency == cryptoCurrency).toList();
    }

    if (startTime != null) {
      payments =
          payments.where((p) => p.createTime.isAfter(startTime)).toList();
    }

    if (endTime != null) {
      payments = payments.where((p) => p.createTime.isBefore(endTime)).toList();
    }

    return payments..sort((a, b) => b.createTime.compareTo(a.createTime));
  }
}

// Simulated Fiat API
class SimulatedFiat {
  static bool _simulationMode = false;

  static void enableSimulation() {
    _simulationMode = true;
  }

  static void disableSimulation() {
    _simulationMode = false;
  }

  static bool get isSimulationEnabled => _simulationMode;

  static Future<Map<String, dynamic>> getDepositWithdrawHistory({
    required String transactionType,
    DateTime? beginTime,
    DateTime? endTime,
    int? page,
    int? rows,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 200 + Random().nextInt(150)));

    final orders = FiatOperations.getOrders(
      transactionType: transactionType,
      startTime: beginTime,
      endTime: endTime,
    );

    final total = orders.length;
    final pageNum = page ?? 1;
    final pageSize = rows ?? 10;
    final startIndex = (pageNum - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, total);

    final pageOrders = orders.sublist(
      startIndex.clamp(0, total),
      endIndex,
    );

    return {
      'data': pageOrders.map((o) => o.toJson()).toList(),
      'total': total,
      'success': true,
    };
  }

  static Future<Map<String, dynamic>> getPaymentHistory({
    String? transactionType,
    DateTime? beginTime,
    DateTime? endTime,
    int? page,
    int? rows,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    await Future.delayed(Duration(milliseconds: 200 + Random().nextInt(150)));

    final payments = FiatOperations.getPayments(
      startTime: beginTime,
      endTime: endTime,
    );

    final total = payments.length;
    final pageNum = page ?? 1;
    final pageSize = rows ?? 10;
    final startIndex = (pageNum - 1) * pageSize;
    final endIndex = (startIndex + pageSize).clamp(0, total);

    final pagePayments = payments.sublist(
      startIndex.clamp(0, total),
      endIndex,
    );

    return {
      'data': pagePayments.map((p) => p.toJson()).toList(),
      'total': total,
      'success': true,
    };
  }

  static Future<Map<String, dynamic>> deposit({
    required String fiatCurrency,
    required double amount,
    required String method,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    return await FiatOperations.deposit(
      fiatCurrency: fiatCurrency,
      amount: amount,
      method: method,
    );
  }

  static Future<Map<String, dynamic>> withdraw({
    required String fiatCurrency,
    required double amount,
    required String method,
    Map<String, dynamic>? bankInfo,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    return await FiatOperations.withdraw(
      fiatCurrency: fiatCurrency,
      amount: amount,
      method: method,
      bankInfo: bankInfo,
    );
  }

  static Future<Map<String, dynamic>> buyCrypto({
    required String fiatCurrency,
    required String cryptoCurrency,
    required double amount,
  }) async {
    if (!_simulationMode) {
      throw Exception('Simulation mode not enabled');
    }

    return await FiatOperations.buyCrypto(
      fiatCurrency: fiatCurrency,
      cryptoCurrency: cryptoCurrency,
      amount: amount,
    );
  }
}

class Fiat extends BinanceBase {
  Fiat({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  // Enable simulation mode
  void enableSimulation() {
    SimulatedFiat.enableSimulation();
  }

  // Disable simulation mode
  void disableSimulation() {
    SimulatedFiat.disableSimulation();
  }

  // Check if simulation is enabled
  bool get isSimulationEnabled => SimulatedFiat.isSimulationEnabled;

  // Get fiat deposit/withdraw history
  Future<Map<String, dynamic>> getFiatDepositWithdrawHistory({
    required String transactionType, // "0" for deposit, "1" for withdraw
    DateTime? beginTime,
    DateTime? endTime,
    int? page,
    int? rows,
    int? recvWindow,
  }) {
    if (SimulatedFiat.isSimulationEnabled) {
      return SimulatedFiat.getDepositWithdrawHistory(
        transactionType: transactionType,
        beginTime: beginTime,
        endTime: endTime,
        page: page,
        rows: rows,
      );
    }

    final params = <String, dynamic>{'transactionType': transactionType};
    if (beginTime != null)
      params['beginTime'] = beginTime.millisecondsSinceEpoch;
    if (endTime != null) params['endTime'] = endTime.millisecondsSinceEpoch;
    if (page != null) params['page'] = page;
    if (rows != null) params['rows'] = rows;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/fiat/orders', params: params);
  }

  // Get fiat payment history
  Future<Map<String, dynamic>> getFiatPaymentHistory({
    String? transactionType,
    DateTime? beginTime,
    DateTime? endTime,
    int? page,
    int? rows,
    int? recvWindow,
  }) {
    if (SimulatedFiat.isSimulationEnabled) {
      return SimulatedFiat.getPaymentHistory(
        transactionType: transactionType,
        beginTime: beginTime,
        endTime: endTime,
        page: page,
        rows: rows,
      );
    }

    final params = <String, dynamic>{};
    if (transactionType != null) params['transactionType'] = transactionType;
    if (beginTime != null)
      params['beginTime'] = beginTime.millisecondsSinceEpoch;
    if (endTime != null) params['endTime'] = endTime.millisecondsSinceEpoch;
    if (page != null) params['page'] = page;
    if (rows != null) params['rows'] = rows;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/fiat/payments', params: params);
  }

  // Simulate fiat deposit
  Future<Map<String, dynamic>> simulateDeposit({
    required String fiatCurrency,
    required double amount,
    required String method,
  }) {
    if (SimulatedFiat.isSimulationEnabled) {
      return SimulatedFiat.deposit(
        fiatCurrency: fiatCurrency,
        amount: amount,
        method: method,
      );
    }

    throw Exception('Simulation mode not enabled');
  }

  // Simulate fiat withdrawal
  Future<Map<String, dynamic>> simulateWithdraw({
    required String fiatCurrency,
    required double amount,
    required String method,
    Map<String, dynamic>? bankInfo,
  }) {
    if (SimulatedFiat.isSimulationEnabled) {
      return SimulatedFiat.withdraw(
        fiatCurrency: fiatCurrency,
        amount: amount,
        method: method,
        bankInfo: bankInfo,
      );
    }

    throw Exception('Simulation mode not enabled');
  }

  // Simulate crypto purchase with fiat
  Future<Map<String, dynamic>> simulateBuyCrypto({
    required String fiatCurrency,
    required String cryptoCurrency,
    required double amount,
  }) {
    if (SimulatedFiat.isSimulationEnabled) {
      return SimulatedFiat.buyCrypto(
        fiatCurrency: fiatCurrency,
        cryptoCurrency: cryptoCurrency,
        amount: amount,
      );
    }

    throw Exception('Simulation mode not enabled');
  }
}