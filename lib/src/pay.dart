import 'dart:math';
import 'binance_base.dart';

class Pay extends BinanceBase {
  final PayTransactions transactions;
  final PayMerchant merchant;
  final SimulatedPay simulatedPay;

  Pay({String? apiKey, String? apiSecret})
      : transactions = PayTransactions(apiKey: apiKey, apiSecret: apiSecret),
        merchant = PayMerchant(apiKey: apiKey, apiSecret: apiSecret),
        simulatedPay = SimulatedPay(apiKey: apiKey, apiSecret: apiSecret),
        super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getPayHistory({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/pay/transactions', params: params);
  }
}

class PayTransactions extends BinanceBase {
  PayTransactions({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getPayHistory({
    int? startTime,
    int? endTime,
    int? limit,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{};
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (limit != null) params['limit'] = limit;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/pay/transactions', params: params);
  }
}

class PayMerchant extends BinanceBase {
  PayMerchant({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> createOrder({
    required String env,
    required String merchantId,
    required String prepayId,
    required String merchantTradeNo,
    required String tradeType,
    required String totalFee,
    required String currency,
    required String productType,
    required String productName,
    required String productDetail,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'env': env,
      'merchantId': merchantId,
      'prepayId': prepayId,
      'merchantTradeNo': merchantTradeNo,
      'tradeType': tradeType,
      'totalFee': totalFee,
      'currency': currency,
      'productType': productType,
      'productName': productName,
      'productDetail': productDetail,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/pay/transactions', params: params);
  }

  Future<Map<String, dynamic>> queryOrder({
    required String merchantId,
    String? merchantTradeNo,
    String? prepayId,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'merchantId': merchantId};
    if (merchantTradeNo != null) params['merchantTradeNo'] = merchantTradeNo;
    if (prepayId != null) params['prepayId'] = prepayId;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/pay/transactions', params: params);
  }

  Future<Map<String, dynamic>> closeOrder({
    required String merchantId,
    required String merchantTradeNo,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'merchantId': merchantId,
      'merchantTradeNo': merchantTradeNo,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/pay/transactions/close',
        params: params);
  }
}

class SimulatedPay {
  final String? apiKey;
  final String? apiSecret;
  final Random _random = Random();

  // Simulated payment history
  final List<Map<String, dynamic>> _paymentHistory = [];

  // Simulated merchant orders
  final Map<String, Map<String, dynamic>> _merchantOrders = {};

  // Supported currencies for Binance Pay
  final List<String> _supportedCurrencies = [
    'BTC',
    'ETH',
    'BNB',
    'USDT',
    'BUSD',
    'ADA',
    'DOT',
    'SOL',
    'MATIC',
    'AVAX',
    'SHIB',
    'DOGE',
    'LTC',
    'BCH',
    'XRP',
    'LINK',
    'UNI',
    'VET',
    'TRX',
    'FIL'
  ];

  SimulatedPay({this.apiKey, this.apiSecret});

  Future<Map<String, dynamic>> simulateGetPayHistory({
    int? startTime,
    int? endTime,
    int? limit,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    // Generate mock payment history if empty
    if (_paymentHistory.isEmpty) {
      _generateMockPaymentHistory();
    }

    final resultLimit = limit ?? 10;
    var filteredHistory = _paymentHistory.where((payment) {
      final transactionTime = payment['transactionTime'] as int;
      if (startTime != null && transactionTime < startTime) return false;
      if (endTime != null && transactionTime > endTime) return false;
      return true;
    }).toList();

    // Sort by transaction time (newest first)
    filteredHistory.sort((a, b) =>
        (b['transactionTime'] as int).compareTo(a['transactionTime'] as int));

    final paginatedHistory = filteredHistory.take(resultLimit).toList();

    return {
      'code': 'SUCCESS',
      'data': paginatedHistory,
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateCreateOrder({
    required String env,
    required String merchantId,
    required String prepayId,
    required String merchantTradeNo,
    required String tradeType,
    required String totalFee,
    required String currency,
    required String productType,
    required String productName,
    required String productDetail,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    // Validate currency
    if (!_supportedCurrencies.contains(currency)) {
      throw Exception('Currency not supported: $currency');
    }

    // Validate amount
    final feeAmount = double.tryParse(totalFee);
    if (feeAmount == null || feeAmount <= 0) {
      throw Exception('Invalid totalFee amount: $totalFee');
    }

    // Check for duplicate merchant trade number
    if (_merchantOrders.containsKey(merchantTradeNo)) {
      throw Exception('Duplicate merchantTradeNo: $merchantTradeNo');
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // 95% success rate for order creation
    final status = _random.nextDouble() < 0.95 ? 'SUCCESS' : 'FAILED';
    final transactionId = status == 'SUCCESS' ? _generateTransactionId() : null;

    final orderData = {
      'prepayId': prepayId,
      'merchantTradeNo': merchantTradeNo,
      'status': status,
      'pspTransactionId': transactionId,
      'pspPaymentId': transactionId != null ? 'pay_$transactionId' : null,
      'payerInfo': status == 'SUCCESS'
          ? {
              'payerType': 'USER',
              'payerId': 'user_${_random.nextInt(999999)}',
              'payerName': 'Anonymous User',
            }
          : null,
      'amount': totalFee,
      'currency': currency,
      'paymentMethod': 'BALANCE',
      'createTime': currentTime,
      'expireTime': currentTime + (15 * 60 * 1000), // 15 minutes
      'merchantId': merchantId,
      'subMerchantId': '',
      'transactionTime': status == 'SUCCESS' ? currentTime : null,
      'transactionId': transactionId,
      'productType': productType,
      'productName': productName,
      'productDetail': productDetail,
      'tradeType': tradeType,
      'env': env,
    };

    _merchantOrders[merchantTradeNo] = orderData;

    // Add to payment history if successful
    if (status == 'SUCCESS') {
      _paymentHistory.insert(0, {
        'orderType': 'C2B', // Customer to Business
        'transactionId': transactionId,
        'transactionTime': currentTime,
        'amount': totalFee,
        'currency': currency,
        'walletType': 1, // Funding wallet
        'fundsDetail': [
          {
            'currency': currency,
            'amount': totalFee,
          }
        ],
        'productDetail': productDetail,
        'productName': productName,
        'status': 'SUCCESS',
      });
    }

    return {
      'code': status == 'SUCCESS' ? 'SUCCESS' : 'FAILED',
      'data': {
        'prepayId': prepayId,
        'status': status,
        'qrcodeLink':
            status == 'SUCCESS' ? 'https://qr.binance.com/pay/$prepayId' : null,
        'deeplink':
            status == 'SUCCESS' ? 'binance://pay?prepayId=$prepayId' : null,
        'checkoutUrl': status == 'SUCCESS'
            ? 'https://pay.binance.com/checkout/$prepayId'
            : null,
        'terminalType': 'WEB',
        'expireTime': currentTime + (15 * 60 * 1000),
        'merchantTradeNo': merchantTradeNo,
      },
      'success': status == 'SUCCESS',
      'errorMessage': status == 'FAILED' ? 'Payment processing failed' : null,
    };
  }

  Future<Map<String, dynamic>> simulateQueryOrder({
    required String merchantId,
    String? merchantTradeNo,
    String? prepayId,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    Map<String, dynamic>? orderData;

    if (merchantTradeNo != null) {
      orderData = _merchantOrders[merchantTradeNo];
    } else if (prepayId != null) {
      // Find by prepayId
      for (final order in _merchantOrders.values) {
        if (order['prepayId'] == prepayId) {
          orderData = order;
          break;
        }
      }
    }

    if (orderData == null) {
      return {
        'code': 'FAILED',
        'data': null,
        'success': false,
        'errorMessage': 'Order not found',
      };
    }

    // Simulate order status progression over time
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final expireTime = orderData['expireTime'] as int;

    String currentStatus = orderData['status'] as String;

    if (currentStatus == 'SUCCESS') {
      // Order already completed
    } else if (currentTime > expireTime) {
      // Order expired
      currentStatus = 'EXPIRED';
      orderData['status'] = currentStatus;
    } else if (currentStatus != 'FAILED') {
      // Simulate payment completion (20% chance per query)
      if (_random.nextDouble() < 0.2) {
        currentStatus = 'SUCCESS';
        orderData['status'] = currentStatus;
        orderData['transactionTime'] = currentTime;
        orderData['transactionId'] = _generateTransactionId();
        orderData['pspTransactionId'] = orderData['transactionId'];
        orderData['pspPaymentId'] = 'pay_${orderData['transactionId']}';
        orderData['payerInfo'] = {
          'payerType': 'USER',
          'payerId': 'user_${_random.nextInt(999999)}',
          'payerName': 'Anonymous User',
        };

        // Add to payment history
        _paymentHistory.insert(0, {
          'orderType': 'C2B',
          'transactionId': orderData['transactionId'],
          'transactionTime': currentTime,
          'amount': orderData['amount'],
          'currency': orderData['currency'],
          'walletType': 1,
          'fundsDetail': [
            {
              'currency': orderData['currency'],
              'amount': orderData['amount'],
            }
          ],
          'productDetail': orderData['productDetail'],
          'productName': orderData['productName'],
          'status': 'SUCCESS',
        });
      }
    }

    return {
      'code': 'SUCCESS',
      'data': orderData,
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateCloseOrder({
    required String merchantId,
    required String merchantTradeNo,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    final orderData = _merchantOrders[merchantTradeNo];
    if (orderData == null) {
      return {
        'code': 'FAILED',
        'data': null,
        'success': false,
        'errorMessage': 'Order not found',
      };
    }

    final currentStatus = orderData['status'] as String;
    if (currentStatus == 'SUCCESS') {
      return {
        'code': 'FAILED',
        'data': null,
        'success': false,
        'errorMessage': 'Cannot close completed order',
      };
    }

    // Close the order
    orderData['status'] = 'CANCELLED';
    orderData['closeTime'] = DateTime.now().millisecondsSinceEpoch;

    return {
      'code': 'SUCCESS',
      'data': {
        'prepayId': orderData['prepayId'],
        'status': 'CANCELLED',
        'merchantTradeNo': merchantTradeNo,
      },
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateSendPayment({
    required String toUserId,
    required String amount,
    required String currency,
    String? description,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    // Validate currency
    if (!_supportedCurrencies.contains(currency)) {
      throw Exception('Currency not supported: $currency');
    }

    // Validate amount
    final payAmount = double.tryParse(amount);
    if (payAmount == null || payAmount <= 0) {
      throw Exception('Invalid amount: $amount');
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final transactionId = _generateTransactionId();

    // 90% success rate for peer-to-peer payments
    final status = _random.nextDouble() < 0.9 ? 'SUCCESS' : 'FAILED';

    if (status == 'SUCCESS') {
      // Add to payment history
      _paymentHistory.insert(0, {
        'orderType': 'C2C', // Customer to Customer
        'transactionId': transactionId,
        'transactionTime': currentTime,
        'amount': amount,
        'currency': currency,
        'walletType': 1, // Funding wallet
        'fundsDetail': [
          {
            'currency': currency,
            'amount': amount,
          }
        ],
        'productDetail': description ?? 'Peer-to-peer payment',
        'productName': 'P2P Transfer',
        'status': status,
        'payeeInfo': {
          'payeeId': toUserId,
          'payeeType': 'USER',
        },
      });
    }

    return {
      'code': status,
      'data': status == 'SUCCESS'
          ? {
              'transactionId': transactionId,
              'status': status,
              'amount': amount,
              'currency': currency,
              'transactionTime': currentTime,
              'payeeId': toUserId,
            }
          : null,
      'success': status == 'SUCCESS',
      'errorMessage': status == 'FAILED' ? 'Payment processing failed' : null,
    };
  }

  Future<Map<String, dynamic>> simulateRequestPayment({
    required String fromUserId,
    required String amount,
    required String currency,
    String? description,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    // Validate currency
    if (!_supportedCurrencies.contains(currency)) {
      throw Exception('Currency not supported: $currency');
    }

    // Validate amount
    final requestAmount = double.tryParse(amount);
    if (requestAmount == null || requestAmount <= 0) {
      throw Exception('Invalid amount: $amount');
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final requestId = _generateRequestId();

    return {
      'code': 'SUCCESS',
      'data': {
        'requestId': requestId,
        'status': 'PENDING',
        'amount': amount,
        'currency': currency,
        'createTime': currentTime,
        'expireTime': currentTime + (24 * 60 * 60 * 1000), // 24 hours
        'fromUserId': fromUserId,
        'description': description ?? 'Payment request',
        'requestUrl': 'https://pay.binance.com/request/$requestId',
      },
      'success': true,
    };
  }

  // Helper methods
  Future<void> _simulateDataRetrievalDelay() async {
    final delay = 120 + _random.nextInt(280); // 120-400ms
    await Future.delayed(Duration(milliseconds: delay));
  }

  Future<void> _simulateTransactionDelay() async {
    final delay = 300 + _random.nextInt(1200); // 300ms-1.5s
    await Future.delayed(Duration(milliseconds: delay));
  }

  String _generateTransactionId() {
    return 'txn_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(999999)}';
  }

  String _generateRequestId() {
    return 'req_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(999999)}';
  }

  void _generateMockPaymentHistory() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Generate 10 mock transactions
    for (int i = 0; i < 10; i++) {
      final currency =
          _supportedCurrencies[_random.nextInt(_supportedCurrencies.length)];
      final amount = (_random.nextDouble() * 1000 + 10).toStringAsFixed(8);
      final time = currentTime - (i * 6 * 60 * 60 * 1000); // 6-hour intervals
      final orderType = _random.nextBool() ? 'C2C' : 'C2B';

      _paymentHistory.add({
        'orderType': orderType,
        'transactionId': _generateTransactionId(),
        'transactionTime': time,
        'amount': amount,
        'currency': currency,
        'walletType': 1,
        'fundsDetail': [
          {
            'currency': currency,
            'amount': amount,
          }
        ],
        'productDetail':
            orderType == 'C2C' ? 'Peer-to-peer payment' : 'Merchant payment',
        'productName': orderType == 'C2C' ? 'P2P Transfer' : 'Online Purchase',
        'status': _random.nextDouble() < 0.95 ? 'SUCCESS' : 'FAILED',
        'payeeInfo': orderType == 'C2C'
            ? {
                'payeeId': 'user_${_random.nextInt(999999)}',
                'payeeType': 'USER',
              }
            : null,
      });
    }
  }
}
