import 'dart:math';
import 'binance_base.dart';

class FuturesUsd extends BinanceBase {
  final FuturesMarket market;
  final FuturesTrading trading;
  final SimulatedFuturesTrading simulatedTrading;

  FuturesUsd({String? apiKey, String? apiSecret})
      : market = FuturesMarket(apiKey: apiKey, apiSecret: apiSecret),
        trading = FuturesTrading(apiKey: apiKey, apiSecret: apiSecret),
        simulatedTrading =
            SimulatedFuturesTrading(apiKey: apiKey, apiSecret: apiSecret),
        super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://fapi.binance.com',
        );

  Future<Map<String, dynamic>> getAccountInformation({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/fapi/v2/account', params: params);
  }
}

class FuturesMarket extends BinanceBase {
  FuturesMarket({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://fapi.binance.com',
        );

  Future<Map<String, dynamic>> getExchangeInfo() {
    return sendRequest('GET', '/fapi/v1/exchangeInfo');
  }

  Future<Map<String, dynamic>> get24HrTicker(String symbol) {
    return sendRequest('GET', '/fapi/v1/ticker/24hr',
        params: {'symbol': symbol});
  }

  Future<Map<String, dynamic>> getOrderBook(String symbol, {int limit = 100}) {
    return sendRequest('GET', '/fapi/v1/depth',
        params: {'symbol': symbol, 'limit': limit});
  }

  Future<Map<String, dynamic>> getMarkPrice(String symbol) {
    return sendRequest('GET', '/fapi/v1/premiumIndex',
        params: {'symbol': symbol});
  }
}

class FuturesTrading extends BinanceBase {
  FuturesTrading({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://fapi.binance.com',
        );

  Future<Map<String, dynamic>> placeOrder({
    required String symbol,
    required String side,
    required String type,
    required double quantity,
    double? price,
    String? timeInForce,
    String? positionSide,
    double? stopPrice,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol,
      'side': side,
      'type': type,
      'quantity': quantity,
    };

    if (price != null) params['price'] = price;
    if (timeInForce != null) params['timeInForce'] = timeInForce;
    if (positionSide != null) params['positionSide'] = positionSide;
    if (stopPrice != null) params['stopPrice'] = stopPrice;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/fapi/v1/order', params: params);
  }

  Future<Map<String, dynamic>> getOrderStatus({
    required String symbol,
    required int orderId,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol,
      'orderId': orderId,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/fapi/v1/order', params: params);
  }

  Future<Map<String, dynamic>> changePositionMargin({
    required String symbol,
    required String type, // 1: Add position margin, 2: Reduce position margin
    required double amount,
    String? positionSide,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol,
      'type': type,
      'amount': amount,
    };
    if (positionSide != null) params['positionSide'] = positionSide;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/fapi/v1/positionMargin', params: params);
  }
}

class SimulatedFuturesTrading {
  final String? apiKey;
  final String? apiSecret;
  final Random _random = Random();

  // Simulated futures prices with leverage considerations
  final Map<String, Map<String, double>> _mockFuturesPrices = {
    'BTCUSDT': {'mark': 95000.0, 'index': 94950.0, 'funding': 0.0001},
    'ETHUSDT': {'mark': 3200.0, 'index': 3195.0, 'funding': 0.0002},
    'BNBUSDT': {'mark': 650.0, 'index': 648.0, 'funding': -0.0001},
    'ADAUSDT': {'mark': 0.45, 'index': 0.449, 'funding': 0.0003},
    'SOLUSDT': {'mark': 180.0, 'index': 179.5, 'funding': 0.0001},
  };

  // Simulated positions for demonstration
  final Map<String, Map<String, dynamic>> _mockPositions = {};

  SimulatedFuturesTrading({this.apiKey, this.apiSecret});

  Future<Map<String, dynamic>> simulatePlaceOrder({
    required String symbol,
    required String side,
    required String type,
    required double quantity,
    double? price,
    String? timeInForce,
    String? positionSide,
    double? stopPrice,
    int? leverage,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateFuturesOrderDelay();
    }

    final orderId = _generateOrderId();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Get futures mark price
    final markPrice = _getFuturesMarkPrice(symbol);
    final executionPrice = price ?? markPrice;

    // Simulate leverage effect
    final actualLeverage = leverage ?? 10; // Default 10x leverage
    final notionalValue = quantity * executionPrice;
    final marginRequired = notionalValue / actualLeverage;

    // Simulate order status based on futures market conditions
    final orderStatus = _determineFuturesOrderStatus(type, price, markPrice);

    // Calculate PnL for position simulation
    final unrealizedPnl =
        _calculateUnrealizedPnl(symbol, side, quantity, executionPrice);

    return {
      'orderId': orderId,
      'symbol': symbol,
      'status': orderStatus,
      'clientOrderId': 'futures_sim_${DateTime.now().millisecondsSinceEpoch}',
      'price': executionPrice.toString(),
      'avgPrice': orderStatus == 'FILLED' ? executionPrice.toString() : '0',
      'origQty': quantity.toString(),
      'executedQty': orderStatus == 'FILLED' ? quantity.toString() : '0',
      'cumQty': orderStatus == 'FILLED' ? quantity.toString() : '0',
      'cumQuote': orderStatus == 'FILLED' ? notionalValue.toString() : '0',
      'timeInForce': timeInForce ?? 'GTC',
      'type': type,
      'reduceOnly': false,
      'closePosition': false,
      'side': side,
      'positionSide': positionSide ?? 'BOTH',
      'stopPrice': stopPrice?.toString() ?? '0',
      'workingType': 'CONTRACT_PRICE',
      'priceProtect': false,
      'origType': type,
      'time': currentTime,
      'updateTime': currentTime,
      'leverage': actualLeverage.toString(),
      'marginRequired': marginRequired.toStringAsFixed(8),
      'notionalValue': notionalValue.toStringAsFixed(8),
      'unrealizedPnl': unrealizedPnl.toStringAsFixed(8),
    };
  }

  Future<Map<String, dynamic>> simulateGetPosition({
    required String symbol,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateStatusCheckDelay();
    }

    final markPrice = _getFuturesMarkPrice(symbol);
    final entryPrice =
        markPrice * (0.98 + (_random.nextDouble() * 0.04)); // ±2% from mark
    final positionAmt =
        (_random.nextDouble() * 2 - 1) * 0.1; // -0.1 to +0.1 BTC
    final unrealizedPnl = (markPrice - entryPrice) * positionAmt;

    return {
      'symbol': symbol,
      'positionAmt': positionAmt.toStringAsFixed(8),
      'entryPrice': entryPrice.toStringAsFixed(2),
      'markPrice': markPrice.toStringAsFixed(2),
      'unRealizedProfit': unrealizedPnl.toStringAsFixed(8),
      'liquidationPrice':
          (entryPrice * 0.8).toStringAsFixed(2), // 20% liquidation threshold
      'leverage': '10',
      'maxNotionalValue': '1000000',
      'marginType': 'isolated',
      'isolatedMargin':
          (entryPrice * positionAmt.abs() / 10).toStringAsFixed(8),
      'isAutoAddMargin': 'false',
      'positionSide': 'BOTH',
      'notional': (markPrice * positionAmt.abs()).toStringAsFixed(8),
      'isolatedWallet':
          (entryPrice * positionAmt.abs() / 10 * 1.1).toStringAsFixed(8),
      'updateTime': DateTime.now().millisecondsSinceEpoch,
    };
  }

  Future<Map<String, dynamic>> simulateChangeMargin({
    required String symbol,
    required String type,
    required double amount,
    String? positionSide,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateMarginChangeDelay();
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final isAdd = type == '1';

    return {
      'code': 200,
      'msg': 'Successfully modified position margin.',
      'amount': amount.toString(),
      'type': isAdd ? 'ADD_MARGIN' : 'REDUCE_MARGIN',
      'symbol': symbol,
      'positionSide': positionSide ?? 'BOTH',
      'time': currentTime,
    };
  }

  Future<Map<String, dynamic>> simulateGetFundingRate({
    required String symbol,
    int? limit,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateStatusCheckDelay();
    }

    final actualLimit = limit ?? 10;
    final fundingRates = <Map<String, dynamic>>[];
    final now = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < actualLimit; i++) {
      final fundingTime = now - (i * 8 * 60 * 60 * 1000); // 8 hours apart
      final fundingRate = (_random.nextDouble() - 0.5) * 0.001; // ±0.05%

      fundingRates.add({
        'symbol': symbol,
        'fundingRate': fundingRate.toStringAsFixed(8),
        'fundingTime': fundingTime,
      });
    }

    return {
      'symbol': symbol,
      'fundingRates': fundingRates,
    };
  }

  // Helper methods for futures simulation
  Future<void> _simulateFuturesOrderDelay() async {
    // Futures orders typically take 30-300ms
    final delay = 30 + _random.nextInt(270);
    await Future.delayed(Duration(milliseconds: delay));
  }

  Future<void> _simulateStatusCheckDelay() async {
    final delay = 20 + _random.nextInt(80);
    await Future.delayed(Duration(milliseconds: delay));
  }

  Future<void> _simulateMarginChangeDelay() async {
    // Margin changes take 100-500ms
    final delay = 100 + _random.nextInt(400);
    await Future.delayed(Duration(milliseconds: delay));
  }

  double _getFuturesMarkPrice(String symbol) {
    final prices = _mockFuturesPrices[symbol];
    if (prices == null) return 1.0;

    final basePrice = prices['mark']!;
    // Add some volatility (±0.2%)
    final volatility = 1 + ((_random.nextDouble() - 0.5) * 0.004);
    return basePrice * volatility;
  }

  String _determineFuturesOrderStatus(
      String type, double? price, double markPrice) {
    if (type == 'MARKET') {
      return 'FILLED'; // Market orders fill immediately
    }

    if (price == null) return 'NEW';

    // Simulate order matching with tighter spreads for futures
    final priceDistance = (price - markPrice).abs() / markPrice;

    if (priceDistance < 0.0005) {
      return _random.nextDouble() < 0.9 ? 'FILLED' : 'NEW';
    } else if (priceDistance < 0.002) {
      return _random.nextDouble() < 0.4 ? 'FILLED' : 'NEW';
    } else {
      return 'NEW';
    }
  }

  double _calculateUnrealizedPnl(
      String symbol, String side, double quantity, double executionPrice) {
    final markPrice = _getFuturesMarkPrice(symbol);
    final isLong = side == 'BUY';

    if (isLong) {
      return (markPrice - executionPrice) * quantity;
    } else {
      return (executionPrice - markPrice) * quantity;
    }
  }

  int _generateOrderId() {
    return 2000000000 + _random.nextInt(999999999);
  }
}
