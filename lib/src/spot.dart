import 'dart:math';
import 'binance_base.dart';

class Spot {
  final Market market;
  final UserDataStream userDataStream;
  final Trading trading;
  final SimulatedTrading simulatedTrading;

  Spot({String? apiKey, String? apiSecret})
      : market = Market(apiKey: apiKey, apiSecret: apiSecret),
        userDataStream = UserDataStream(apiKey: apiKey, apiSecret: apiSecret),
        trading = Trading(apiKey: apiKey, apiSecret: apiSecret),
        simulatedTrading =
            SimulatedTrading(apiKey: apiKey, apiSecret: apiSecret);
}

class Market extends BinanceBase {
  Market({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getServerTime() {
    return sendRequest('GET', '/api/v3/time');
  }

  Future<Map<String, dynamic>> getExchangeInfo() {
    return sendRequest('GET', '/api/v3/exchangeInfo');
  }

  Future<Map<String, dynamic>> getOrderBook(String symbol, {int limit = 100}) {
    return sendRequest('GET', '/api/v3/depth',
        params: {'symbol': symbol, 'limit': limit});
  }

  Future<Map<String, dynamic>> get24HrTicker(String symbol) {
    return sendRequest('GET', '/api/v3/ticker/24hr',
        params: {'symbol': symbol});
  }
}

class UserDataStream extends BinanceBase {
  UserDataStream({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> createListenKey() {
    return sendRequest('POST', '/api/v3/userDataStream');
  }

  Future<Map<String, dynamic>> keepAliveListenKey(String listenKey) {
    return sendRequest('PUT', '/api/v3/userDataStream',
        params: {'listenKey': listenKey});
  }

  Future<Map<String, dynamic>> closeListenKey(String listenKey) {
    return sendRequest('DELETE', '/api/v3/userDataStream',
        params: {'listenKey': listenKey});
  }
}

class Trading extends BinanceBase {
  Trading({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> placeOrder({
    required String symbol,
    required String side,
    required String type,
    required double quantity,
    double? price,
    String? timeInForce,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol,
      'side': side,
      'type': type,
      'quantity': quantity,
    };

    if (price != null) params['price'] = price;
    if (timeInForce != null) params['timeInForce'] = timeInForce;

    return sendRequest('POST', '/api/v3/order', params: params);
  }

  Future<Map<String, dynamic>> cancelOrder({
    required String symbol,
    required int orderId,
  }) {
    return sendRequest('DELETE', '/api/v3/order', params: {
      'symbol': symbol,
      'orderId': orderId,
    });
  }

  Future<Map<String, dynamic>> getOrderStatus({
    required String symbol,
    required int orderId,
  }) {
    return sendRequest('GET', '/api/v3/order', params: {
      'symbol': symbol,
      'orderId': orderId,
    });
  }
}

class SimulatedTrading {
  final String? apiKey;
  final String? apiSecret;
  final Random _random = Random();

  // Simulated order book for realistic pricing
  final Map<String, Map<String, double>> _mockPrices = {
    'BTCUSDT': {'bid': 95000.0, 'ask': 95050.0},
    'ETHUSDT': {'bid': 3200.0, 'ask': 3205.0},
    'BNBUSDT': {'bid': 650.0, 'ask': 652.0},
    'ADAUSDT': {'bid': 0.45, 'ask': 0.451},
    'SOLUSDT': {'bid': 180.0, 'ask': 181.0},
  };

  SimulatedTrading({this.apiKey, this.apiSecret});

  Future<Map<String, dynamic>> simulatePlaceOrder({
    required String symbol,
    required String side,
    required String type,
    double? quantity,
    double? quoteOrderQty,
    double? price,
    String? timeInForce,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateOrderProcessingDelay();
    }

    // Validate parameters
    if (quantity == null && quoteOrderQty == null) {
      throw ArgumentError('Either quantity or quoteOrderQty must be provided');
    }
    if (quantity != null && quoteOrderQty != null) {
      throw ArgumentError('Cannot specify both quantity and quoteOrderQty');
    }

    final orderId = _generateOrderId();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Get market price for the symbol
    final marketPrice = _getMarketPrice(symbol, side);
    final executionPrice = price ?? marketPrice;

    // Calculate actual quantity and quote quantity
    double actualQuantity;
    double actualQuoteQty;

    if (quantity != null) {
      actualQuantity = quantity;
      actualQuoteQty = quantity * executionPrice;
    } else {
      actualQuoteQty = quoteOrderQty!;
      actualQuantity = quoteOrderQty / executionPrice;
    }

    // Simulate order status based on order type and market conditions
    final orderStatus = _determineOrderStatus(type, price, marketPrice);

    return {
      'symbol': symbol,
      'orderId': orderId,
      'orderListId': -1,
      'clientOrderId': 'sim_${DateTime.now().millisecondsSinceEpoch}',
      'transactTime': currentTime,
      'price': executionPrice.toString(),
      'origQty': actualQuantity.toString(),
      'executedQty':
          orderStatus == 'FILLED' ? actualQuantity.toString() : '0.00000000',
      'cummulativeQuoteQty':
          orderStatus == 'FILLED' ? actualQuoteQty.toString() : '0.00000000',
      'status': orderStatus,
      'timeInForce': timeInForce ?? 'GTC',
      'type': type,
      'side': side,
      'workingTime': currentTime,
      'selfTradePreventionMode': 'NONE',
      'fills': orderStatus == 'FILLED'
          ? [
              {
                'price': executionPrice.toString(),
                'qty': actualQuantity.toString(),
                'commission': (actualQuantity * executionPrice * 0.001)
                    .toString(), // 0.1% commission
                'commissionAsset':
                    side == 'BUY' ? symbol.replaceAll('USDT', '') : 'USDT',
                'tradeId': _generateTradeId(),
              }
            ]
          : [],
    };
  }

  Future<Map<String, dynamic>> simulateConvert({
    required String fromAsset,
    required String toAsset,
    required double fromAmount,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateConvertProcessingDelay();
    }

    final conversionId = _generateConversionId();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Simulate conversion rate with slight spread
    final baseRate = _getConversionRate(fromAsset, toAsset);
    final spreadRate =
        baseRate * (1 - _random.nextDouble() * 0.002); // 0-0.2% spread
    final toAmount = fromAmount * spreadRate;

    return {
      'tranId': conversionId,
      'status': 'SUCCESS',
      'fromAsset': fromAsset,
      'fromAmount': fromAmount.toString(),
      'toAsset': toAsset,
      'toAmount': toAmount.toString(),
      'ratio': spreadRate.toString(),
      'inverseRatio': (1 / spreadRate).toString(),
      'createTime': currentTime,
    };
  }

  Future<Map<String, dynamic>> simulateOrderStatus({
    required String symbol,
    required int orderId,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateStatusCheckDelay();
    }

    // Simulate order progression over time
    final orderAge = _random.nextInt(300000); // 0-5 minutes old
    final status = _getOrderStatusByAge(orderAge);

    return {
      'symbol': symbol,
      'orderId': orderId,
      'orderListId': -1,
      'clientOrderId': 'sim_$orderId',
      'price': '95000.00000000',
      'origQty': '0.00100000',
      'executedQty': status == 'FILLED' ? '0.00100000' : '0.00000000',
      'cummulativeQuoteQty': status == 'FILLED' ? '95.00000000' : '0.00000000',
      'status': status,
      'timeInForce': 'GTC',
      'type': 'LIMIT',
      'side': 'BUY',
      'stopPrice': '0.00000000',
      'icebergQty': '0.00000000',
      'time': DateTime.now().millisecondsSinceEpoch - orderAge,
      'updateTime': DateTime.now().millisecondsSinceEpoch,
      'isWorking': status == 'NEW',
      'workingTime': DateTime.now().millisecondsSinceEpoch - orderAge,
      'origQuoteOrderQty': '0.00000000',
      'selfTradePreventionMode': 'NONE',
    };
  }

  // Simulate realistic processing delays based on Binance's actual performance
  Future<void> _simulateOrderProcessingDelay() async {
    // Binance spot orders typically take 50-500ms to process
    final baseDelay = 50 + _random.nextInt(450); // 50-500ms

    // Add occasional network spikes (5% chance of 1-3 second delay)
    final networkSpike =
        _random.nextDouble() < 0.05 ? 1000 + _random.nextInt(2000) : 0;

    await Future.delayed(Duration(milliseconds: baseDelay + networkSpike));
  }

  Future<void> _simulateConvertProcessingDelay() async {
    // Convert operations typically take 100ms to 2 seconds
    final delay = 100 + _random.nextInt(1900); // 100ms-2s
    await Future.delayed(Duration(milliseconds: delay));
  }

  Future<void> _simulateStatusCheckDelay() async {
    // Status checks are usually very fast: 20-100ms
    final delay = 20 + _random.nextInt(80); // 20-100ms
    await Future.delayed(Duration(milliseconds: delay));
  }

  int _generateOrderId() {
    return 1000000000 + _random.nextInt(999999999);
  }

  int _generateTradeId() {
    return 500000000 + _random.nextInt(499999999);
  }

  int _generateConversionId() {
    return 2000000000 + _random.nextInt(999999999);
  }

  double _getMarketPrice(String symbol, String side) {
    final prices = _mockPrices[symbol];
    if (prices == null) {
      // Default fallback for unknown symbols
      return side == 'BUY' ? 1.001 : 0.999;
    }

    // Add some price volatility (±0.1%)
    final basePrice = side == 'BUY' ? prices['ask']! : prices['bid']!;
    final volatility = 1 + ((_random.nextDouble() - 0.5) * 0.002); // ±0.1%
    return basePrice * volatility;
  }

  String _determineOrderStatus(String type, double? price, double marketPrice) {
    if (type == 'MARKET') {
      return 'FILLED'; // Market orders fill immediately
    }

    if (price == null) return 'NEW';

    // Simulate order matching based on price vs market
    final priceDistance = (price - marketPrice).abs() / marketPrice;

    if (priceDistance < 0.001) {
      // Within 0.1% of market price
      return _random.nextDouble() < 0.8 ? 'FILLED' : 'NEW';
    } else if (priceDistance < 0.01) {
      // Within 1% of market price
      return _random.nextDouble() < 0.3 ? 'FILLED' : 'NEW';
    } else {
      return 'NEW'; // Far from market price, unlikely to fill immediately
    }
  }

  double _getConversionRate(String fromAsset, String toAsset) {
    // Simplified conversion rate simulation
    final rates = {
      'BTC': 95000.0,
      'ETH': 3200.0,
      'BNB': 650.0,
      'ADA': 0.45,
      'SOL': 180.0,
      'USDT': 1.0,
      'BUSD': 1.0,
    };

    final fromRate = rates[fromAsset] ?? 1.0;
    final toRate = rates[toAsset] ?? 1.0;

    return fromRate / toRate;
  }

  String _getOrderStatusByAge(int ageMs) {
    if (ageMs < 5000) return 'NEW'; // First 5 seconds
    if (ageMs < 30000)
      return _random.nextDouble() < 0.6 ? 'PARTIALLY_FILLED' : 'NEW';
    if (ageMs < 120000)
      return _random.nextDouble() < 0.8 ? 'FILLED' : 'PARTIALLY_FILLED';
    return 'FILLED'; // After 2 minutes, assume filled
  }
}
