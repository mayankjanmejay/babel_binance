import 'binance_base.dart';
import 'websocket/websocket_client.dart';
import 'websocket/websocket_config.dart';
import 'websocket/stream_types.dart';

/// Binance Testnet integration for realistic testing without real money
///
/// The testnet provides:
/// - Real API endpoints with test data
/// - WebSocket connections for market streams
/// - All trading functionalities
/// - No real money involved
///
/// Available Base URLs:
/// - REST API: https://testnet.binance.vision/api
/// - REST API (Failover): https://api1.testnet.binance.vision/api
/// - WebSocket API: wss://ws-api.testnet.binance.vision/ws-api/v3
/// - Market Streams: wss://stream.testnet.binance.vision/stream
///
/// Get testnet API keys from: https://testnet.binance.vision/
class TestnetSpot {
  final TestnetMarket market;
  final TestnetTrading trading;
  final TestnetUserDataStream userDataStream;
  final TestnetWebSocket webSocket;

  TestnetSpot({String? apiKey, String? apiSecret})
      : market = TestnetMarket(apiKey: apiKey, apiSecret: apiSecret),
        trading = TestnetTrading(apiKey: apiKey, apiSecret: apiSecret),
        userDataStream =
            TestnetUserDataStream(apiKey: apiKey, apiSecret: apiSecret),
        webSocket = TestnetWebSocket();

  /// Dispose and clean up resources
  Future<void> dispose() async {
    market.dispose();
    trading.dispose();
    userDataStream.dispose();
    await webSocket.dispose();
  }
}

/// WebSocket client for Binance Testnet market streams
///
/// Base URLs:
/// - Market Streams: wss://stream.testnet.binance.vision:9443
/// - WebSocket API: wss://ws-api.testnet.binance.vision:9443/ws-api/v3
class TestnetWebSocket extends BinanceWebSocket {
  TestnetWebSocket({WebSocketConfig? config})
      : super(
          baseUrl: 'wss://stream.testnet.binance.vision:9443',
          config: config,
        );

  /// Alternative constructor using port 443 (for restricted networks)
  factory TestnetWebSocket.port443({WebSocketConfig? config}) {
    return TestnetWebSocket._(
      baseUrl: 'wss://stream.testnet.binance.vision:443',
      config: config,
    );
  }

  TestnetWebSocket._({required String baseUrl, WebSocketConfig? config})
      : super(baseUrl: baseUrl, config: config);
}

/// Market data endpoints for Binance Testnet
///
/// All market data endpoints from the Binance Spot API are available on testnet.
/// Base URL: https://testnet.binance.vision/api
class TestnetMarket extends BinanceBase {
  TestnetMarket({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://testnet.binance.vision',
        );

  // ==================== General Endpoints ====================

  /// Test connectivity to the Rest API (Weight: 1)
  Future<Map<String, dynamic>> ping() {
    return sendRequest('GET', '/api/v3/ping', weight: 1);
  }

  /// Get server time from testnet (Weight: 1)
  Future<Map<String, dynamic>> getServerTime() {
    return sendRequest('GET', '/api/v3/time', weight: 1);
  }

  /// Get exchange information from testnet (Weight: 20)
  ///
  /// Returns current trading rules and symbol information
  Future<Map<String, dynamic>> getExchangeInfo({
    String? symbol,
    List<String>? symbols,
    List<String>? permissions,
  }) {
    final params = <String, dynamic>{};
    if (symbol != null) params['symbol'] = symbol;
    if (symbols != null) params['symbols'] = symbols;
    if (permissions != null) params['permissions'] = permissions;

    return sendRequest('GET', '/api/v3/exchangeInfo', params: params, weight: 20);
  }

  // ==================== Market Data Endpoints ====================

  /// Get order book depth from testnet (Weight: 5-50 depending on limit)
  ///
  /// [limit] Valid limits: 5, 10, 20, 50, 100, 500, 1000, 5000
  Future<Map<String, dynamic>> getOrderBook(String symbol, {int limit = 100}) {
    final weight = limit <= 100 ? 5 : (limit <= 500 ? 10 : (limit <= 1000 ? 20 : 50));
    return sendRequest('GET', '/api/v3/depth',
        params: {'symbol': symbol, 'limit': limit}, weight: weight);
  }

  /// Get recent trades list from testnet (Weight: 10)
  Future<List<dynamic>> getRecentTrades(String symbol, {int limit = 500}) async {
    final response = await sendRequest('GET', '/api/v3/trades',
        params: {'symbol': symbol, 'limit': limit}, weight: 10);
    return response as List<dynamic>;
  }

  /// Get historical trades from testnet (Weight: 10)
  ///
  /// Requires API key. Market trades from a more distant past.
  Future<List<dynamic>> getHistoricalTrades(String symbol,
      {int limit = 500, int? fromId}) async {
    final params = <String, dynamic>{'symbol': symbol, 'limit': limit};
    if (fromId != null) params['fromId'] = fromId;

    final response = await sendRequest('GET', '/api/v3/historicalTrades',
        params: params, weight: 10);
    return response as List<dynamic>;
  }

  /// Get compressed/aggregate trades from testnet (Weight: 2)
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
        await sendRequest('GET', '/api/v3/aggTrades', params: params, weight: 2);
    return response as List<dynamic>;
  }

  /// Get kline/candlestick data from testnet (Weight: 2)
  ///
  /// [interval] Valid intervals: 1s, 1m, 3m, 5m, 15m, 30m, 1h, 2h, 4h, 6h, 8h, 12h, 1d, 3d, 1w, 1M
  Future<List<dynamic>> getKlines(
    String symbol,
    String interval, {
    int? startTime,
    int? endTime,
    String? timeZone,
    int limit = 500,
  }) async {
    final params = <String, dynamic>{
      'symbol': symbol,
      'interval': interval,
      'limit': limit,
    };
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (timeZone != null) params['timeZone'] = timeZone;

    final response = await sendRequest('GET', '/api/v3/klines', params: params, weight: 2);
    return response as List<dynamic>;
  }

  /// Get UIKlines (klines optimized for UI) from testnet (Weight: 2)
  ///
  /// Modification of the Klines endpoint that is optimized for presentation on UI.
  Future<List<dynamic>> getUIKlines(
    String symbol,
    String interval, {
    int? startTime,
    int? endTime,
    String? timeZone,
    int limit = 500,
  }) async {
    final params = <String, dynamic>{
      'symbol': symbol,
      'interval': interval,
      'limit': limit,
    };
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (timeZone != null) params['timeZone'] = timeZone;

    final response = await sendRequest('GET', '/api/v3/uiKlines', params: params, weight: 2);
    return response as List<dynamic>;
  }

  /// Get current average price from testnet (Weight: 2)
  Future<Map<String, dynamic>> getAvgPrice(String symbol) {
    return sendRequest('GET', '/api/v3/avgPrice', params: {'symbol': symbol}, weight: 2);
  }

  /// Get 24hr ticker statistics from testnet (Weight: 2-80)
  Future<Map<String, dynamic>> get24HrTicker(String symbol) {
    return sendRequest('GET', '/api/v3/ticker/24hr',
        params: {'symbol': symbol}, weight: 2);
  }

  /// Get 24hr ticker price change statistics for all symbols (Weight: 80)
  Future<List<dynamic>> get24HrTickerAll({String? type}) async {
    final params = <String, dynamic>{};
    if (type != null) params['type'] = type;

    final response = await sendRequest('GET', '/api/v3/ticker/24hr',
        params: params, weight: 80);
    return response as List<dynamic>;
  }

  /// Get trading day ticker (Weight: 4 per symbol)
  ///
  /// Price change statistics for the trading day.
  Future<dynamic> getTradingDayTicker({
    String? symbol,
    List<String>? symbols,
    String? timeZone,
    String? type,
  }) async {
    final params = <String, dynamic>{};
    if (symbol != null) params['symbol'] = symbol;
    if (symbols != null) params['symbols'] = symbols;
    if (timeZone != null) params['timeZone'] = timeZone;
    if (type != null) params['type'] = type;

    return sendRequest('GET', '/api/v3/ticker/tradingDay', params: params, weight: 4);
  }

  /// Get latest price for a symbol or symbols (Weight: 2-4)
  Future<dynamic> getTickerPrice([String? symbol]) async {
    final params = symbol != null ? {'symbol': symbol} : <String, dynamic>{};
    return await sendRequest('GET', '/api/v3/ticker/price',
        params: params, weight: symbol != null ? 2 : 4);
  }

  /// Get best price/qty on the order book for a symbol or symbols (Weight: 2-4)
  Future<dynamic> getBookTicker([String? symbol]) async {
    final params = symbol != null ? {'symbol': symbol} : <String, dynamic>{};
    return await sendRequest('GET', '/api/v3/ticker/bookTicker',
        params: params, weight: symbol != null ? 2 : 4);
  }

  /// Get rolling window price change statistics (Weight: 4 per symbol)
  ///
  /// [windowSize] Supported values: 1m, 2m, ..., 59m, 1h, 2h, ..., 23h, 1d, ..., 7d
  Future<dynamic> getRollingWindowTicker({
    String? symbol,
    List<String>? symbols,
    String windowSize = '1d',
    String? type,
  }) async {
    final params = <String, dynamic>{'windowSize': windowSize};
    if (symbol != null) params['symbol'] = symbol;
    if (symbols != null) params['symbols'] = symbols;
    if (type != null) params['type'] = type;

    return sendRequest('GET', '/api/v3/ticker', params: params, weight: 4);
  }
}

/// Trading endpoints for Binance Testnet
///
/// Supports all order types including:
/// - Standard orders (LIMIT, MARKET, STOP_LOSS, etc.)
/// - OCO (One-Cancels-the-Other) orders
/// - OTO (One-Triggers-the-Other) orders
/// - OTOCO (One-Triggers-OCO) orders
/// - Cancel-Replace operations
class TestnetTrading extends BinanceBase {
  TestnetTrading({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://testnet.binance.vision',
        );

  // ==================== Standard Order Endpoints ====================

  /// Place a new order on testnet (Weight: 1)
  ///
  /// [type] Order types: LIMIT, MARKET, STOP_LOSS, STOP_LOSS_LIMIT,
  ///        TAKE_PROFIT, TAKE_PROFIT_LIMIT, LIMIT_MAKER
  /// [side] BUY or SELL
  /// [timeInForce] GTC, IOC, FOK (required for LIMIT orders)
  Future<Map<String, dynamic>> placeOrder({
    required String symbol,
    required String side,
    required String type,
    double? quantity,
    double? quoteOrderQty,
    double? price,
    String? newClientOrderId,
    double? stopPrice,
    double? trailingDelta,
    double? icebergQty,
    String? newOrderRespType,
    String? timeInForce,
    String? selfTradePreventionMode,
    int? strategyId,
    int? strategyType,
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
    if (trailingDelta != null) params['trailingDelta'] = trailingDelta;
    if (icebergQty != null) params['icebergQty'] = icebergQty;
    if (newOrderRespType != null) params['newOrderRespType'] = newOrderRespType;
    if (timeInForce != null) params['timeInForce'] = timeInForce;
    if (selfTradePreventionMode != null) {
      params['selfTradePreventionMode'] = selfTradePreventionMode;
    }
    if (strategyId != null) params['strategyId'] = strategyId;
    if (strategyType != null) params['strategyType'] = strategyType;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/api/v3/order', params: params, isOrder: true);
  }

  /// Test new order creation on testnet (validation only) (Weight: 1)
  ///
  /// Tests a new order without actually placing it.
  Future<Map<String, dynamic>> testOrder({
    required String symbol,
    required String side,
    required String type,
    double? quantity,
    double? quoteOrderQty,
    double? price,
    String? newClientOrderId,
    double? stopPrice,
    double? trailingDelta,
    double? icebergQty,
    String? timeInForce,
    String? selfTradePreventionMode,
    bool? computeCommissionRates,
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
    if (trailingDelta != null) params['trailingDelta'] = trailingDelta;
    if (icebergQty != null) params['icebergQty'] = icebergQty;
    if (timeInForce != null) params['timeInForce'] = timeInForce;
    if (selfTradePreventionMode != null) {
      params['selfTradePreventionMode'] = selfTradePreventionMode;
    }
    if (computeCommissionRates != null) {
      params['computeCommissionRates'] = computeCommissionRates;
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/api/v3/order/test', params: params);
  }

  /// Query order status on testnet (Weight: 4)
  Future<Map<String, dynamic>> getOrder({
    required String symbol,
    int? orderId,
    String? origClientOrderId,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'symbol': symbol};

    if (orderId != null) params['orderId'] = orderId;
    if (origClientOrderId != null) {
      params['origClientOrderId'] = origClientOrderId;
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('GET', '/api/v3/order', params: params, weight: 4);
  }

  /// Cancel an active order on testnet (Weight: 1)
  Future<Map<String, dynamic>> cancelOrder({
    required String symbol,
    int? orderId,
    String? origClientOrderId,
    String? newClientOrderId,
    String? cancelRestrictions,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'symbol': symbol};

    if (orderId != null) params['orderId'] = orderId;
    if (origClientOrderId != null) {
      params['origClientOrderId'] = origClientOrderId;
    }
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (cancelRestrictions != null) {
      params['cancelRestrictions'] = cancelRestrictions;
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('DELETE', '/api/v3/order', params: params);
  }

  /// Cancel all open orders on a symbol on testnet (Weight: 1)
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

  // ==================== Cancel-Replace Order ====================

  /// Cancel an existing order and send a new order on testnet (Weight: 1)
  ///
  /// Cancels an existing order and places a new order on the same symbol.
  /// [cancelReplaceMode] STOP_ON_FAILURE or ALLOW_FAILURE
  Future<Map<String, dynamic>> cancelReplace({
    required String symbol,
    required String side,
    required String type,
    required String cancelReplaceMode,
    String? timeInForce,
    double? quantity,
    double? quoteOrderQty,
    double? price,
    String? cancelNewClientOrderId,
    String? cancelOrigClientOrderId,
    int? cancelOrderId,
    String? newClientOrderId,
    int? strategyId,
    int? strategyType,
    double? stopPrice,
    double? trailingDelta,
    double? icebergQty,
    String? newOrderRespType,
    String? selfTradePreventionMode,
    String? cancelRestrictions,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol,
      'side': side,
      'type': type,
      'cancelReplaceMode': cancelReplaceMode,
    };

    if (timeInForce != null) params['timeInForce'] = timeInForce;
    if (quantity != null) params['quantity'] = quantity;
    if (quoteOrderQty != null) params['quoteOrderQty'] = quoteOrderQty;
    if (price != null) params['price'] = price;
    if (cancelNewClientOrderId != null) {
      params['cancelNewClientOrderId'] = cancelNewClientOrderId;
    }
    if (cancelOrigClientOrderId != null) {
      params['cancelOrigClientOrderId'] = cancelOrigClientOrderId;
    }
    if (cancelOrderId != null) params['cancelOrderId'] = cancelOrderId;
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (strategyId != null) params['strategyId'] = strategyId;
    if (strategyType != null) params['strategyType'] = strategyType;
    if (stopPrice != null) params['stopPrice'] = stopPrice;
    if (trailingDelta != null) params['trailingDelta'] = trailingDelta;
    if (icebergQty != null) params['icebergQty'] = icebergQty;
    if (newOrderRespType != null) params['newOrderRespType'] = newOrderRespType;
    if (selfTradePreventionMode != null) {
      params['selfTradePreventionMode'] = selfTradePreventionMode;
    }
    if (cancelRestrictions != null) {
      params['cancelRestrictions'] = cancelRestrictions;
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/api/v3/order/cancelReplace',
        params: params, isOrder: true);
  }

  // ==================== OCO Orders ====================

  /// Place a new OCO order on testnet (Weight: 1)
  ///
  /// OCO (One-Cancels-the-Other) places a limit order and a stop-limit order.
  /// When either order executes, the other is automatically canceled.
  Future<Map<String, dynamic>> placeOcoOrder({
    required String symbol,
    required String side,
    required double quantity,
    required double price,
    required double stopPrice,
    String? listClientOrderId,
    String? limitClientOrderId,
    double? limitIcebergQty,
    double? limitStrategyId,
    int? limitStrategyType,
    double? stopLimitPrice,
    String? stopClientOrderId,
    double? stopIcebergQty,
    double? stopStrategyId,
    int? stopStrategyType,
    String? stopLimitTimeInForce,
    String? newOrderRespType,
    String? selfTradePreventionMode,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol,
      'side': side,
      'quantity': quantity,
      'price': price,
      'stopPrice': stopPrice,
    };

    if (listClientOrderId != null) {
      params['listClientOrderId'] = listClientOrderId;
    }
    if (limitClientOrderId != null) {
      params['limitClientOrderId'] = limitClientOrderId;
    }
    if (limitIcebergQty != null) params['limitIcebergQty'] = limitIcebergQty;
    if (limitStrategyId != null) params['limitStrategyId'] = limitStrategyId;
    if (limitStrategyType != null) {
      params['limitStrategyType'] = limitStrategyType;
    }
    if (stopLimitPrice != null) params['stopLimitPrice'] = stopLimitPrice;
    if (stopClientOrderId != null) {
      params['stopClientOrderId'] = stopClientOrderId;
    }
    if (stopIcebergQty != null) params['stopIcebergQty'] = stopIcebergQty;
    if (stopStrategyId != null) params['stopStrategyId'] = stopStrategyId;
    if (stopStrategyType != null) params['stopStrategyType'] = stopStrategyType;
    if (stopLimitTimeInForce != null) {
      params['stopLimitTimeInForce'] = stopLimitTimeInForce;
    }
    if (newOrderRespType != null) params['newOrderRespType'] = newOrderRespType;
    if (selfTradePreventionMode != null) {
      params['selfTradePreventionMode'] = selfTradePreventionMode;
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/api/v3/order/oco', params: params, isOrder: true);
  }

  /// Cancel an OCO order on testnet (Weight: 1)
  Future<Map<String, dynamic>> cancelOcoOrder({
    required String symbol,
    int? orderListId,
    String? listClientOrderId,
    String? newClientOrderId,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'symbol': symbol};

    if (orderListId != null) params['orderListId'] = orderListId;
    if (listClientOrderId != null) {
      params['listClientOrderId'] = listClientOrderId;
    }
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('DELETE', '/api/v3/orderList', params: params);
  }

  /// Query OCO order status on testnet (Weight: 4)
  Future<Map<String, dynamic>> getOcoOrder({
    int? orderListId,
    String? origClientOrderId,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{};

    if (orderListId != null) params['orderListId'] = orderListId;
    if (origClientOrderId != null) {
      params['origClientOrderId'] = origClientOrderId;
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('GET', '/api/v3/orderList', params: params, weight: 4);
  }

  /// Get all OCO orders on testnet (Weight: 20)
  Future<List<dynamic>> getAllOcoOrders({
    int? fromId,
    int? startTime,
    int? endTime,
    int limit = 500,
    int? recvWindow,
  }) async {
    final params = <String, dynamic>{'limit': limit};

    if (fromId != null) params['fromId'] = fromId;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response = await sendRequest('GET', '/api/v3/allOrderList',
        params: params, weight: 20);
    return response as List<dynamic>;
  }

  /// Get all open OCO orders on testnet (Weight: 6)
  Future<List<dynamic>> getOpenOcoOrders({int? recvWindow}) async {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response = await sendRequest('GET', '/api/v3/openOrderList',
        params: params, weight: 6);
    return response as List<dynamic>;
  }

  // ==================== OTO Orders ====================

  /// Place a new OTO order on testnet (Weight: 1)
  ///
  /// OTO (One-Triggers-the-Other) places a working order that triggers
  /// a pending order when the working order is filled.
  Future<Map<String, dynamic>> placeOtoOrder({
    required String symbol,
    required String workingType,
    required String workingSide,
    required double workingPrice,
    required double workingQuantity,
    required String pendingType,
    required String pendingSide,
    required double pendingQuantity,
    String? listClientOrderId,
    String? workingClientOrderId,
    double? workingIcebergQty,
    String? workingTimeInForce,
    int? workingStrategyId,
    int? workingStrategyType,
    String? pendingClientOrderId,
    double? pendingPrice,
    double? pendingStopPrice,
    double? pendingTrailingDelta,
    double? pendingIcebergQty,
    String? pendingTimeInForce,
    int? pendingStrategyId,
    int? pendingStrategyType,
    String? newOrderRespType,
    String? selfTradePreventionMode,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol,
      'workingType': workingType,
      'workingSide': workingSide,
      'workingPrice': workingPrice,
      'workingQuantity': workingQuantity,
      'pendingType': pendingType,
      'pendingSide': pendingSide,
      'pendingQuantity': pendingQuantity,
    };

    if (listClientOrderId != null) {
      params['listClientOrderId'] = listClientOrderId;
    }
    if (workingClientOrderId != null) {
      params['workingClientOrderId'] = workingClientOrderId;
    }
    if (workingIcebergQty != null) {
      params['workingIcebergQty'] = workingIcebergQty;
    }
    if (workingTimeInForce != null) {
      params['workingTimeInForce'] = workingTimeInForce;
    }
    if (workingStrategyId != null) {
      params['workingStrategyId'] = workingStrategyId;
    }
    if (workingStrategyType != null) {
      params['workingStrategyType'] = workingStrategyType;
    }
    if (pendingClientOrderId != null) {
      params['pendingClientOrderId'] = pendingClientOrderId;
    }
    if (pendingPrice != null) params['pendingPrice'] = pendingPrice;
    if (pendingStopPrice != null) params['pendingStopPrice'] = pendingStopPrice;
    if (pendingTrailingDelta != null) {
      params['pendingTrailingDelta'] = pendingTrailingDelta;
    }
    if (pendingIcebergQty != null) {
      params['pendingIcebergQty'] = pendingIcebergQty;
    }
    if (pendingTimeInForce != null) {
      params['pendingTimeInForce'] = pendingTimeInForce;
    }
    if (pendingStrategyId != null) {
      params['pendingStrategyId'] = pendingStrategyId;
    }
    if (pendingStrategyType != null) {
      params['pendingStrategyType'] = pendingStrategyType;
    }
    if (newOrderRespType != null) params['newOrderRespType'] = newOrderRespType;
    if (selfTradePreventionMode != null) {
      params['selfTradePreventionMode'] = selfTradePreventionMode;
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/api/v3/orderList/oto',
        params: params, isOrder: true);
  }

  // ==================== OTOCO Orders ====================

  /// Place a new OTOCO order on testnet (Weight: 1)
  ///
  /// OTOCO (One-Triggers-One-Cancels-the-Other) places a working order
  /// that triggers an OCO order when filled.
  Future<Map<String, dynamic>> placeOtocoOrder({
    required String symbol,
    required String workingType,
    required String workingSide,
    required double workingPrice,
    required double workingQuantity,
    required String pendingSide,
    required double pendingQuantity,
    required double pendingAbovePrice,
    required double pendingBelowPrice,
    String? listClientOrderId,
    String? workingClientOrderId,
    double? workingIcebergQty,
    String? workingTimeInForce,
    int? workingStrategyId,
    int? workingStrategyType,
    String? pendingAboveType,
    String? pendingAboveClientOrderId,
    double? pendingAboveStopPrice,
    double? pendingAboveTrailingDelta,
    double? pendingAboveIcebergQty,
    String? pendingAboveTimeInForce,
    int? pendingAboveStrategyId,
    int? pendingAboveStrategyType,
    String? pendingBelowType,
    String? pendingBelowClientOrderId,
    double? pendingBelowStopPrice,
    double? pendingBelowTrailingDelta,
    double? pendingBelowIcebergQty,
    String? pendingBelowTimeInForce,
    int? pendingBelowStrategyId,
    int? pendingBelowStrategyType,
    String? newOrderRespType,
    String? selfTradePreventionMode,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol,
      'workingType': workingType,
      'workingSide': workingSide,
      'workingPrice': workingPrice,
      'workingQuantity': workingQuantity,
      'pendingSide': pendingSide,
      'pendingQuantity': pendingQuantity,
      'pendingAbovePrice': pendingAbovePrice,
      'pendingBelowPrice': pendingBelowPrice,
    };

    if (listClientOrderId != null) {
      params['listClientOrderId'] = listClientOrderId;
    }
    if (workingClientOrderId != null) {
      params['workingClientOrderId'] = workingClientOrderId;
    }
    if (workingIcebergQty != null) {
      params['workingIcebergQty'] = workingIcebergQty;
    }
    if (workingTimeInForce != null) {
      params['workingTimeInForce'] = workingTimeInForce;
    }
    if (workingStrategyId != null) {
      params['workingStrategyId'] = workingStrategyId;
    }
    if (workingStrategyType != null) {
      params['workingStrategyType'] = workingStrategyType;
    }
    if (pendingAboveType != null) params['pendingAboveType'] = pendingAboveType;
    if (pendingAboveClientOrderId != null) {
      params['pendingAboveClientOrderId'] = pendingAboveClientOrderId;
    }
    if (pendingAboveStopPrice != null) {
      params['pendingAboveStopPrice'] = pendingAboveStopPrice;
    }
    if (pendingAboveTrailingDelta != null) {
      params['pendingAboveTrailingDelta'] = pendingAboveTrailingDelta;
    }
    if (pendingAboveIcebergQty != null) {
      params['pendingAboveIcebergQty'] = pendingAboveIcebergQty;
    }
    if (pendingAboveTimeInForce != null) {
      params['pendingAboveTimeInForce'] = pendingAboveTimeInForce;
    }
    if (pendingAboveStrategyId != null) {
      params['pendingAboveStrategyId'] = pendingAboveStrategyId;
    }
    if (pendingAboveStrategyType != null) {
      params['pendingAboveStrategyType'] = pendingAboveStrategyType;
    }
    if (pendingBelowType != null) params['pendingBelowType'] = pendingBelowType;
    if (pendingBelowClientOrderId != null) {
      params['pendingBelowClientOrderId'] = pendingBelowClientOrderId;
    }
    if (pendingBelowStopPrice != null) {
      params['pendingBelowStopPrice'] = pendingBelowStopPrice;
    }
    if (pendingBelowTrailingDelta != null) {
      params['pendingBelowTrailingDelta'] = pendingBelowTrailingDelta;
    }
    if (pendingBelowIcebergQty != null) {
      params['pendingBelowIcebergQty'] = pendingBelowIcebergQty;
    }
    if (pendingBelowTimeInForce != null) {
      params['pendingBelowTimeInForce'] = pendingBelowTimeInForce;
    }
    if (pendingBelowStrategyId != null) {
      params['pendingBelowStrategyId'] = pendingBelowStrategyId;
    }
    if (pendingBelowStrategyType != null) {
      params['pendingBelowStrategyType'] = pendingBelowStrategyType;
    }
    if (newOrderRespType != null) params['newOrderRespType'] = newOrderRespType;
    if (selfTradePreventionMode != null) {
      params['selfTradePreventionMode'] = selfTradePreventionMode;
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/api/v3/orderList/otoco',
        params: params, isOrder: true);
  }

  // ==================== Query Endpoints ====================

  /// Get all open orders on testnet (Weight: 6 for single symbol, 80 for all)
  Future<List<dynamic>> getOpenOrders({
    String? symbol,
    int? recvWindow,
  }) async {
    final params = <String, dynamic>{};
    if (symbol != null) params['symbol'] = symbol;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final weight = symbol != null ? 6 : 80;
    final response = await sendRequest('GET', '/api/v3/openOrders',
        params: params, weight: weight);
    return response as List<dynamic>;
  }

  /// Get all account orders; active, canceled, or filled on testnet (Weight: 20)
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

    final response = await sendRequest('GET', '/api/v3/allOrders',
        params: params, weight: 20);
    return response as List<dynamic>;
  }

  /// Get trades for a specific account and symbol on testnet (Weight: 20)
  Future<List<dynamic>> getMyTrades({
    required String symbol,
    int? orderId,
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

    if (orderId != null) params['orderId'] = orderId;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (fromId != null) params['fromId'] = fromId;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response = await sendRequest('GET', '/api/v3/myTrades',
        params: params, weight: 20);
    return response as List<dynamic>;
  }

  /// Get current account information on testnet (Weight: 20)
  Future<Map<String, dynamic>> getAccountInfo({
    bool? omitZeroBalances,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{};
    if (omitZeroBalances != null) params['omitZeroBalances'] = omitZeroBalances;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('GET', '/api/v3/account', params: params, weight: 20);
  }

  /// Query unfilled order count (Weight: 40)
  Future<List<dynamic>> getRateLimitOrder({int? recvWindow}) async {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response = await sendRequest('GET', '/api/v3/rateLimit/order',
        params: params, weight: 40);
    return response as List<dynamic>;
  }

  /// Query prevented matches (Weight: 20)
  Future<List<dynamic>> getPreventedMatches({
    required String symbol,
    int? preventedMatchId,
    int? orderId,
    int? fromPreventedMatchId,
    int limit = 500,
    int? recvWindow,
  }) async {
    final params = <String, dynamic>{
      'symbol': symbol,
      'limit': limit,
    };

    if (preventedMatchId != null) params['preventedMatchId'] = preventedMatchId;
    if (orderId != null) params['orderId'] = orderId;
    if (fromPreventedMatchId != null) {
      params['fromPreventedMatchId'] = fromPreventedMatchId;
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response = await sendRequest('GET', '/api/v3/myPreventedMatches',
        params: params, weight: 20);
    return response as List<dynamic>;
  }

  /// Query allocations (Weight: 20)
  Future<List<dynamic>> getAllocations({
    required String symbol,
    int? startTime,
    int? endTime,
    int? fromAllocationId,
    int limit = 500,
    int? orderId,
    int? recvWindow,
  }) async {
    final params = <String, dynamic>{
      'symbol': symbol,
      'limit': limit,
    };

    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (fromAllocationId != null) params['fromAllocationId'] = fromAllocationId;
    if (orderId != null) params['orderId'] = orderId;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response = await sendRequest('GET', '/api/v3/myAllocations',
        params: params, weight: 20);
    return response as List<dynamic>;
  }

  /// Get commission rates (Weight: 20)
  Future<Map<String, dynamic>> getCommissionRates({
    required String symbol,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'symbol': symbol};
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('GET', '/api/v3/account/commission',
        params: params, weight: 20);
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

// ============================================================================
// Demo Trading API (Alternative to testnet.binance.vision)
// ============================================================================

/// Binance Demo Trading API - Alternative testnet for regions where
/// testnet.binance.vision is not accessible.
///
/// Base URLs:
/// - REST API: https://demo-api.binance.com
/// - WebSocket Trade: wss://demo-ws-api.binance.com
/// - WebSocket Market: wss://demo-stream.binance.com
///
/// Get demo API keys from your Binance account settings.
class DemoSpot {
  final DemoMarket market;
  final DemoTrading trading;
  final DemoUserDataStream userDataStream;
  final DemoWebSocket webSocket;

  DemoSpot({String? apiKey, String? apiSecret})
      : market = DemoMarket(apiKey: apiKey, apiSecret: apiSecret),
        trading = DemoTrading(apiKey: apiKey, apiSecret: apiSecret),
        userDataStream =
            DemoUserDataStream(apiKey: apiKey, apiSecret: apiSecret),
        webSocket = DemoWebSocket();

  /// Dispose and clean up resources
  Future<void> dispose() async {
    market.dispose();
    trading.dispose();
    userDataStream.dispose();
    await webSocket.dispose();
  }
}

/// WebSocket client for Binance Demo Trading
class DemoWebSocket extends BinanceWebSocket {
  DemoWebSocket({WebSocketConfig? config})
      : super(
          baseUrl: 'wss://demo-stream.binance.com',
          config: config,
        );
}

/// Market data endpoints for Binance Demo Trading
class DemoMarket extends BinanceBase {
  DemoMarket({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://demo-api.binance.com',
        );

  /// Test connectivity
  Future<Map<String, dynamic>> ping() {
    return sendRequest('GET', '/api/v3/ping', weight: 1);
  }

  /// Get server time
  Future<Map<String, dynamic>> getServerTime() {
    return sendRequest('GET', '/api/v3/time', weight: 1);
  }

  /// Get exchange information
  Future<Map<String, dynamic>> getExchangeInfo({
    String? symbol,
    List<String>? symbols,
  }) {
    final params = <String, dynamic>{};
    if (symbol != null) params['symbol'] = symbol;
    if (symbols != null) params['symbols'] = symbols;

    return sendRequest('GET', '/api/v3/exchangeInfo', params: params, weight: 20);
  }

  /// Get order book depth
  Future<Map<String, dynamic>> getOrderBook(String symbol, {int limit = 100}) {
    return sendRequest('GET', '/api/v3/depth',
        params: {'symbol': symbol, 'limit': limit});
  }

  /// Get recent trades
  Future<List<dynamic>> getRecentTrades(String symbol, {int limit = 500}) async {
    final response = await sendRequest('GET', '/api/v3/trades',
        params: {'symbol': symbol, 'limit': limit});
    return response as List<dynamic>;
  }

  /// Get klines/candlestick data
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

  /// Get 24hr ticker statistics
  Future<Map<String, dynamic>> get24HrTicker(String symbol) {
    return sendRequest('GET', '/api/v3/ticker/24hr',
        params: {'symbol': symbol});
  }

  /// Get latest price
  Future<dynamic> getTickerPrice([String? symbol]) async {
    final params = symbol != null ? {'symbol': symbol} : <String, dynamic>{};
    return sendRequest('GET', '/api/v3/ticker/price', params: params);
  }

  /// Get best book ticker
  Future<dynamic> getBookTicker([String? symbol]) async {
    final params = symbol != null ? {'symbol': symbol} : <String, dynamic>{};
    return sendRequest('GET', '/api/v3/ticker/bookTicker', params: params);
  }
}

/// Trading endpoints for Binance Demo Trading
class DemoTrading extends BinanceBase {
  DemoTrading({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://demo-api.binance.com',
        );

  /// Place a new order
  Future<Map<String, dynamic>> placeOrder({
    required String symbol,
    required String side,
    required String type,
    double? quantity,
    double? quoteOrderQty,
    double? price,
    String? newClientOrderId,
    double? stopPrice,
    String? timeInForce,
    String? newOrderRespType,
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
    if (timeInForce != null) params['timeInForce'] = timeInForce;
    if (newOrderRespType != null) params['newOrderRespType'] = newOrderRespType;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/api/v3/order', params: params, isOrder: true);
  }

  /// Test order creation (validation only)
  Future<Map<String, dynamic>> testOrder({
    required String symbol,
    required String side,
    required String type,
    double? quantity,
    double? price,
    String? timeInForce,
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
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/api/v3/order/test', params: params);
  }

  /// Query order status
  Future<Map<String, dynamic>> getOrder({
    required String symbol,
    int? orderId,
    String? origClientOrderId,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'symbol': symbol};

    if (orderId != null) params['orderId'] = orderId;
    if (origClientOrderId != null) {
      params['origClientOrderId'] = origClientOrderId;
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('GET', '/api/v3/order', params: params);
  }

  /// Cancel an order
  Future<Map<String, dynamic>> cancelOrder({
    required String symbol,
    int? orderId,
    String? origClientOrderId,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'symbol': symbol};

    if (orderId != null) params['orderId'] = orderId;
    if (origClientOrderId != null) {
      params['origClientOrderId'] = origClientOrderId;
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('DELETE', '/api/v3/order', params: params);
  }

  /// Cancel all open orders on a symbol
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

  /// Get all open orders
  Future<List<dynamic>> getOpenOrders({String? symbol, int? recvWindow}) async {
    final params = <String, dynamic>{};
    if (symbol != null) params['symbol'] = symbol;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response =
        await sendRequest('GET', '/api/v3/openOrders', params: params);
    return response as List<dynamic>;
  }

  /// Get all orders
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

  /// Get account information
  Future<Map<String, dynamic>> getAccountInfo({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('GET', '/api/v3/account', params: params);
  }

  /// Get account trades
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
}

/// User Data Stream endpoints for Binance Demo Trading
class DemoUserDataStream extends BinanceBase {
  DemoUserDataStream({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://demo-api.binance.com',
        );

  /// Start a new user data stream
  Future<Map<String, dynamic>> createListenKey() {
    return sendRequest('POST', '/api/v3/userDataStream');
  }

  /// Keep alive a user data stream
  Future<Map<String, dynamic>> keepAliveListenKey(String listenKey) {
    return sendRequest('PUT', '/api/v3/userDataStream',
        params: {'listenKey': listenKey});
  }

  /// Close a user data stream
  Future<Map<String, dynamic>> closeListenKey(String listenKey) {
    return sendRequest('DELETE', '/api/v3/userDataStream',
        params: {'listenKey': listenKey});
  }
}

/// Demo Futures USD-M endpoints (https://demo-fapi.binance.com)
class DemoFuturesUsd {
  final DemoFuturesUsdMarket market;
  final DemoFuturesUsdTrading trading;

  DemoFuturesUsd({String? apiKey, String? apiSecret})
      : market = DemoFuturesUsdMarket(apiKey: apiKey, apiSecret: apiSecret),
        trading = DemoFuturesUsdTrading(apiKey: apiKey, apiSecret: apiSecret);
}

/// Demo Futures USD-M Market data
class DemoFuturesUsdMarket extends BinanceBase {
  DemoFuturesUsdMarket({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://demo-fapi.binance.com',
        );

  /// Get server time
  Future<Map<String, dynamic>> getServerTime() {
    return sendRequest('GET', '/fapi/v1/time');
  }

  /// Get exchange information
  Future<Map<String, dynamic>> getExchangeInfo() {
    return sendRequest('GET', '/fapi/v1/exchangeInfo');
  }

  /// Get order book
  Future<Map<String, dynamic>> getOrderBook(String symbol, {int limit = 100}) {
    return sendRequest('GET', '/fapi/v1/depth',
        params: {'symbol': symbol, 'limit': limit});
  }

  /// Get 24hr ticker
  Future<Map<String, dynamic>> get24HrTicker(String symbol) {
    return sendRequest('GET', '/fapi/v1/ticker/24hr',
        params: {'symbol': symbol});
  }

  /// Get klines
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

/// Demo Futures USD-M Trading
class DemoFuturesUsdTrading extends BinanceBase {
  DemoFuturesUsdTrading({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://demo-fapi.binance.com',
        );

  /// Place a new futures order
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
    if (newOrderRespType != null) params['newOrderRespType'] = newOrderRespType;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/fapi/v1/order', params: params, isOrder: true);
  }

  /// Get account information
  Future<Map<String, dynamic>> getAccountInfo({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('GET', '/fapi/v2/account', params: params);
  }

  /// Get position information
  Future<List<dynamic>> getPositionInfo({String? symbol, int? recvWindow}) async {
    final params = <String, dynamic>{};
    if (symbol != null) params['symbol'] = symbol;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response =
        await sendRequest('GET', '/fapi/v2/positionRisk', params: params);
    return response as List<dynamic>;
  }
}
