import 'binance_base.dart';

/// Binance Testnet integration for realistic testing without real money
///
/// The testnet provides:
/// - Real API endpoints with test data
/// - WebSocket connections
/// - All trading functionalities
/// - No real money involved
///
/// Get testnet API keys from: https://testnet.binance.vision/
class TestnetSpot {
  final TestnetMarket market;
  final TestnetTrading trading;
  final TestnetUserDataStream userDataStream;

  TestnetSpot({String? apiKey, String? apiSecret})
      : market = TestnetMarket(apiKey: apiKey, apiSecret: apiSecret),
        trading = TestnetTrading(apiKey: apiKey, apiSecret: apiSecret),
        userDataStream =
            TestnetUserDataStream(apiKey: apiKey, apiSecret: apiSecret);
}

/// Market data endpoints for Binance Testnet
class TestnetMarket extends BinanceBase {
  TestnetMarket({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://testnet.binance.vision',
        );

  /// Get server time from testnet
  Future<Map<String, dynamic>> getServerTime() {
    return sendRequest('GET', '/api/v3/time');
  }

  /// Get exchange information from testnet
  Future<Map<String, dynamic>> getExchangeInfo() {
    return sendRequest('GET', '/api/v3/exchangeInfo');
  }

  /// Get order book depth from testnet
  Future<Map<String, dynamic>> getOrderBook(String symbol, {int limit = 100}) {
    return sendRequest('GET', '/api/v3/depth',
        params: {'symbol': symbol, 'limit': limit});
  }

  /// Get 24hr ticker statistics from testnet
  Future<Map<String, dynamic>> get24HrTicker(String symbol) {
    return sendRequest('GET', '/api/v3/ticker/24hr',
        params: {'symbol': symbol});
  }

  /// Get recent trades list from testnet
  Future<List<dynamic>> getRecentTrades(String symbol,
      {int limit = 500}) async {
    final response = await sendRequest('GET', '/api/v3/trades',
        params: {'symbol': symbol, 'limit': limit});
    return response as List<dynamic>;
  }

  /// Get historical trades from testnet
  Future<List<dynamic>> getHistoricalTrades(String symbol,
      {int limit = 500, int? fromId}) async {
    final params = <String, dynamic>{'symbol': symbol, 'limit': limit};
    if (fromId != null) params['fromId'] = fromId;

    final response =
        await sendRequest('GET', '/api/v3/historicalTrades', params: params);
    return response as List<dynamic>;
  }

  /// Get compressed/aggregate trades from testnet
  Future<List<dynamic>> getAggTrades(
    String symbol, {
    int? fromId,
    int? startTime,
    int? endTime,
    int limit = 500,
  }) async {
    final params = <String, dynamic>{'symbol': symbol, 'limit': limit};
    if (fromId != null) params['fromId'] = fromId;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;

    final response =
        await sendRequest('GET', '/api/v3/aggTrades', params: params);
    return response as List<dynamic>;
  }

  /// Get kline/candlestick data from testnet
  Future<List<dynamic>> getKlines(
    String symbol,
    String interval, {
    int? startTime,
    int? endTime,
    int limit = 500,
  }) async {
    final params = <String, dynamic>{
      'symbol': symbol,
      'interval': interval,
      'limit': limit,
    };
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;

    final response = await sendRequest('GET', '/api/v3/klines', params: params);
    return response as List<dynamic>;
  }

  /// Get current average price from testnet
  Future<Map<String, dynamic>> getAvgPrice(String symbol) {
    return sendRequest('GET', '/api/v3/avgPrice', params: {'symbol': symbol});
  }

  /// Get 24hr ticker price change statistics for all symbols
  Future<List<dynamic>> get24HrTickerAll() async {
    final response = await sendRequest('GET', '/api/v3/ticker/24hr');
    return response as List<dynamic>;
  }

  /// Get latest price for a symbol or symbols
  Future<dynamic> getTickerPrice([String? symbol]) async {
    final params = symbol != null ? {'symbol': symbol} : <String, dynamic>{};
    return await sendRequest('GET', '/api/v3/ticker/price', params: params);
  }

  /// Get best price/qty on the order book for a symbol or symbols
  Future<dynamic> getBookTicker([String? symbol]) async {
    final params = symbol != null ? {'symbol': symbol} : <String, dynamic>{};
    return await sendRequest('GET', '/api/v3/ticker/bookTicker',
        params: params);
  }
}

/// Trading endpoints for Binance Testnet
class TestnetTrading extends BinanceBase {
  TestnetTrading({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://testnet.binance.vision',
        );

  /// Place a new order on testnet
  Future<Map<String, dynamic>> placeOrder({
    required String symbol,
    required String side,
    required String type,
    double? quantity,
    double? quoteOrderQty,
    double? price,
    String? newClientOrderId,
    double? stopPrice,
    double? icebergQty,
    String? newOrderRespType,
    String? timeInForce,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol,
      'side': side,
      'type': type,
    };

    if (quantity != null) params['quantity'] = quantity;
    if (quoteOrderQty != null) params['quoteOrderQty'] = quoteOrderQty;
    if (price != null) params['price'] = price;
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (stopPrice != null) params['stopPrice'] = stopPrice;
    if (icebergQty != null) params['icebergQty'] = icebergQty;
    if (newOrderRespType != null) params['newOrderRespType'] = newOrderRespType;
    if (timeInForce != null) params['timeInForce'] = timeInForce;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/api/v3/order', params: params);
  }

  /// Test new order creation on testnet (validation only)
  Future<Map<String, dynamic>> testOrder({
    required String symbol,
    required String side,
    required String type,
    double? quantity,
    double? quoteOrderQty,
    double? price,
    String? newClientOrderId,
    double? stopPrice,
    double? icebergQty,
    String? timeInForce,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol,
      'side': side,
      'type': type,
    };

    if (quantity != null) params['quantity'] = quantity;
    if (quoteOrderQty != null) params['quoteOrderQty'] = quoteOrderQty;
    if (price != null) params['price'] = price;
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (stopPrice != null) params['stopPrice'] = stopPrice;
    if (icebergQty != null) params['icebergQty'] = icebergQty;
    if (timeInForce != null) params['timeInForce'] = timeInForce;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/api/v3/order/test', params: params);
  }

  /// Query order status on testnet
  Future<Map<String, dynamic>> getOrder({
    required String symbol,
    int? orderId,
    String? origClientOrderId,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'symbol': symbol};

    if (orderId != null) params['orderId'] = orderId;
    if (origClientOrderId != null)
      params['origClientOrderId'] = origClientOrderId;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('GET', '/api/v3/order', params: params);
  }

  /// Cancel an active order on testnet
  Future<Map<String, dynamic>> cancelOrder({
    required String symbol,
    int? orderId,
    String? origClientOrderId,
    String? newClientOrderId,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'symbol': symbol};

    if (orderId != null) params['orderId'] = orderId;
    if (origClientOrderId != null)
      params['origClientOrderId'] = origClientOrderId;
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('DELETE', '/api/v3/order', params: params);
  }

  /// Cancel all open orders on a symbol on testnet
  Future<List<dynamic>> cancelAllOrders({
    required String symbol,
    int? recvWindow,
  }) async {
    final params = <String, dynamic>{'symbol': symbol};
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response =
        await sendRequest('DELETE', '/api/v3/openOrders', params: params);
    return response as List<dynamic>;
  }

  /// Get all open orders on testnet
  Future<List<dynamic>> getOpenOrders({
    String? symbol,
    int? recvWindow,
  }) async {
    final params = <String, dynamic>{};
    if (symbol != null) params['symbol'] = symbol;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response =
        await sendRequest('GET', '/api/v3/openOrders', params: params);
    return response as List<dynamic>;
  }

  /// Get all account orders; active, canceled, or filled on testnet
  Future<List<dynamic>> getAllOrders({
    required String symbol,
    int? orderId,
    int? startTime,
    int? endTime,
    int limit = 500,
    int? recvWindow,
  }) async {
    final params = <String, dynamic>{
      'symbol': symbol,
      'limit': limit,
    };

    if (orderId != null) params['orderId'] = orderId;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response =
        await sendRequest('GET', '/api/v3/allOrders', params: params);
    return response as List<dynamic>;
  }

  /// Get trades for a specific account and symbol on testnet
  Future<List<dynamic>> getMyTrades({
    required String symbol,
    int? startTime,
    int? endTime,
    int? fromId,
    int limit = 500,
    int? recvWindow,
  }) async {
    final params = <String, dynamic>{
      'symbol': symbol,
      'limit': limit,
    };

    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (fromId != null) params['fromId'] = fromId;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response =
        await sendRequest('GET', '/api/v3/myTrades', params: params);
    return response as List<dynamic>;
  }

  /// Get current account information on testnet
  Future<Map<String, dynamic>> getAccountInfo({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('GET', '/api/v3/account', params: params);
  }
}

/// User Data Stream endpoints for Binance Testnet
class TestnetUserDataStream extends BinanceBase {
  TestnetUserDataStream({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://testnet.binance.vision',
        );

  /// Start a new user data stream on testnet
  Future<Map<String, dynamic>> createListenKey() {
    return sendRequest('POST', '/api/v3/userDataStream');
  }

  /// Ping/Keep-alive a user data stream on testnet
  Future<Map<String, dynamic>> keepAliveListenKey(String listenKey) {
    return sendRequest('PUT', '/api/v3/userDataStream',
        params: {'listenKey': listenKey});
  }

  /// Close a user data stream on testnet
  Future<Map<String, dynamic>> closeListenKey(String listenKey) {
    return sendRequest('DELETE', '/api/v3/userDataStream',
        params: {'listenKey': listenKey});
  }
}

/// Testnet Futures USD-M endpoints
class TestnetFuturesUsd {
  final TestnetFuturesUsdMarket market;
  final TestnetFuturesUsdTrading trading;

  TestnetFuturesUsd({String? apiKey, String? apiSecret})
      : market = TestnetFuturesUsdMarket(apiKey: apiKey, apiSecret: apiSecret),
        trading =
            TestnetFuturesUsdTrading(apiKey: apiKey, apiSecret: apiSecret);
}

/// Futures USD-M Market data for testnet
class TestnetFuturesUsdMarket extends BinanceBase {
  TestnetFuturesUsdMarket({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://testnet.binancefuture.com',
        );

  /// Get testnet futures server time
  Future<Map<String, dynamic>> getServerTime() {
    return sendRequest('GET', '/fapi/v1/time');
  }

  /// Get testnet futures exchange information
  Future<Map<String, dynamic>> getExchangeInfo() {
    return sendRequest('GET', '/fapi/v1/exchangeInfo');
  }

  /// Get testnet futures order book
  Future<Map<String, dynamic>> getOrderBook(String symbol, {int limit = 100}) {
    return sendRequest('GET', '/fapi/v1/depth',
        params: {'symbol': symbol, 'limit': limit});
  }

  /// Get testnet futures 24hr ticker
  Future<Map<String, dynamic>> get24HrTicker(String symbol) {
    return sendRequest('GET', '/fapi/v1/ticker/24hr',
        params: {'symbol': symbol});
  }

  /// Get testnet futures klines
  Future<List<dynamic>> getKlines(
    String symbol,
    String interval, {
    int? startTime,
    int? endTime,
    int limit = 500,
  }) async {
    final params = <String, dynamic>{
      'symbol': symbol,
      'interval': interval,
      'limit': limit,
    };
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;

    final response =
        await sendRequest('GET', '/fapi/v1/klines', params: params);
    return response as List<dynamic>;
  }
}

/// Futures USD-M Trading for testnet
class TestnetFuturesUsdTrading extends BinanceBase {
  TestnetFuturesUsdTrading({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://testnet.binancefuture.com',
        );

  /// Place a new futures order on testnet
  Future<Map<String, dynamic>> placeOrder({
    required String symbol,
    required String side,
    required String type,
    double? quantity,
    double? price,
    String? timeInForce,
    String? positionSide,
    double? stopPrice,
    String? workingType,
    bool? priceProtect,
    String? newOrderRespType,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol,
      'side': side,
      'type': type,
    };

    if (quantity != null) params['quantity'] = quantity;
    if (price != null) params['price'] = price;
    if (timeInForce != null) params['timeInForce'] = timeInForce;
    if (positionSide != null) params['positionSide'] = positionSide;
    if (stopPrice != null) params['stopPrice'] = stopPrice;
    if (workingType != null) params['workingType'] = workingType;
    if (priceProtect != null) params['priceProtect'] = priceProtect;
    if (newOrderRespType != null) params['newOrderRespType'] = newOrderRespType;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/fapi/v1/order', params: params);
  }

  /// Get testnet futures account information
  Future<Map<String, dynamic>> getAccountInfo({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('GET', '/fapi/v2/account', params: params);
  }

  /// Get testnet futures position information
  Future<List<dynamic>> getPositionInfo(
      {String? symbol, int? recvWindow}) async {
    final params = <String, dynamic>{};
    if (symbol != null) params['symbol'] = symbol;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response =
        await sendRequest('GET', '/fapi/v2/positionRisk', params: params);
    return response as List<dynamic>;
  }
}
