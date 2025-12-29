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
    String? quantity,
    String? quoteOrderQty,
    String? price,
    String? newClientOrderId,
    String? stopPrice,
    String? trailingDelta,
    String? icebergQty,
    String? newOrderRespType,
    String? timeInForce,
    String? selfTradePreventionMode,
    int? strategyId,
    int? strategyType,
    int? recvWindow,
  }) {
    // Validate side
    final normalizedSide = side.toUpperCase();
    if (!['BUY', 'SELL'].contains(normalizedSide)) {
      throw ArgumentError('side must be BUY or SELL, got: $side');
    }

    final params = <String, dynamic>{
      'symbol': symbol.toUpperCase(),
      'side': normalizedSide,
      'type': type.toUpperCase(),
    };

    if (quantity != null) params['quantity'] = quantity;
    if (quoteOrderQty != null) params['quoteOrderQty'] = quoteOrderQty;
    if (price != null) params['price'] = price;
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (stopPrice != null) params['stopPrice'] = stopPrice;
    if (trailingDelta != null) params['trailingDelta'] = trailingDelta;
    if (icebergQty != null) params['icebergQty'] = icebergQty;
    if (newOrderRespType != null) params['newOrderRespType'] = newOrderRespType;
    if (timeInForce != null) params['timeInForce'] = timeInForce.toUpperCase();
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
    String? quantity,
    String? quoteOrderQty,
    String? price,
    String? newClientOrderId,
    String? stopPrice,
    String? trailingDelta,
    String? icebergQty,
    String? timeInForce,
    String? selfTradePreventionMode,
    bool? computeCommissionRates,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol.toUpperCase(),
      'side': side.toUpperCase(),
      'type': type.toUpperCase(),
    };

    if (quantity != null) params['quantity'] = quantity;
    if (quoteOrderQty != null) params['quoteOrderQty'] = quoteOrderQty;
    if (price != null) params['price'] = price;
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (stopPrice != null) params['stopPrice'] = stopPrice;
    if (trailingDelta != null) params['trailingDelta'] = trailingDelta;
    if (icebergQty != null) params['icebergQty'] = icebergQty;
    if (timeInForce != null) params['timeInForce'] = timeInForce.toUpperCase();
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
    String? quantity,
    String? quoteOrderQty,
    String? price,
    String? cancelNewClientOrderId,
    String? cancelOrigClientOrderId,
    int? cancelOrderId,
    String? newClientOrderId,
    int? strategyId,
    int? strategyType,
    String? stopPrice,
    String? trailingDelta,
    String? icebergQty,
    String? newOrderRespType,
    String? selfTradePreventionMode,
    String? cancelRestrictions,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol.toUpperCase(),
      'side': side.toUpperCase(),
      'type': type.toUpperCase(),
      'cancelReplaceMode': cancelReplaceMode,
    };

    if (timeInForce != null) params['timeInForce'] = timeInForce.toUpperCase();
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
    required String quantity,
    required String price,
    required String stopPrice,
    String? listClientOrderId,
    String? limitClientOrderId,
    String? limitIcebergQty,
    int? limitStrategyId,
    int? limitStrategyType,
    String? stopLimitPrice,
    String? stopClientOrderId,
    String? stopIcebergQty,
    int? stopStrategyId,
    int? stopStrategyType,
    String? stopLimitTimeInForce,
    String? newOrderRespType,
    String? selfTradePreventionMode,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol.toUpperCase(),
      'side': side.toUpperCase(),
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
      params['stopLimitTimeInForce'] = stopLimitTimeInForce.toUpperCase();
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
    required String workingPrice,
    required String workingQuantity,
    required String pendingType,
    required String pendingSide,
    required String pendingQuantity,
    String? listClientOrderId,
    String? workingClientOrderId,
    String? workingIcebergQty,
    String? workingTimeInForce,
    int? workingStrategyId,
    int? workingStrategyType,
    String? pendingClientOrderId,
    String? pendingPrice,
    String? pendingStopPrice,
    String? pendingTrailingDelta,
    String? pendingIcebergQty,
    String? pendingTimeInForce,
    int? pendingStrategyId,
    int? pendingStrategyType,
    String? newOrderRespType,
    String? selfTradePreventionMode,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol.toUpperCase(),
      'workingType': workingType.toUpperCase(),
      'workingSide': workingSide.toUpperCase(),
      'workingPrice': workingPrice,
      'workingQuantity': workingQuantity,
      'pendingType': pendingType.toUpperCase(),
      'pendingSide': pendingSide.toUpperCase(),
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
      params['workingTimeInForce'] = workingTimeInForce.toUpperCase();
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
      params['pendingTimeInForce'] = pendingTimeInForce.toUpperCase();
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
    required String workingPrice,
    required String workingQuantity,
    required String pendingSide,
    required String pendingQuantity,
    required String pendingAbovePrice,
    required String pendingBelowPrice,
    String? listClientOrderId,
    String? workingClientOrderId,
    String? workingIcebergQty,
    String? workingTimeInForce,
    int? workingStrategyId,
    int? workingStrategyType,
    String? pendingAboveType,
    String? pendingAboveClientOrderId,
    String? pendingAboveStopPrice,
    String? pendingAboveTrailingDelta,
    String? pendingAboveIcebergQty,
    String? pendingAboveTimeInForce,
    int? pendingAboveStrategyId,
    int? pendingAboveStrategyType,
    String? pendingBelowType,
    String? pendingBelowClientOrderId,
    String? pendingBelowStopPrice,
    String? pendingBelowTrailingDelta,
    String? pendingBelowIcebergQty,
    String? pendingBelowTimeInForce,
    int? pendingBelowStrategyId,
    int? pendingBelowStrategyType,
    String? newOrderRespType,
    String? selfTradePreventionMode,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol.toUpperCase(),
      'workingType': workingType.toUpperCase(),
      'workingSide': workingSide.toUpperCase(),
      'workingPrice': workingPrice,
      'workingQuantity': workingQuantity,
      'pendingSide': pendingSide.toUpperCase(),
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
      params['workingTimeInForce'] = workingTimeInForce.toUpperCase();
    }
    if (workingStrategyId != null) {
      params['workingStrategyId'] = workingStrategyId;
    }
    if (workingStrategyType != null) {
      params['workingStrategyType'] = workingStrategyType;
    }
    if (pendingAboveType != null) params['pendingAboveType'] = pendingAboveType.toUpperCase();
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
      params['pendingAboveTimeInForce'] = pendingAboveTimeInForce.toUpperCase();
    }
    if (pendingAboveStrategyId != null) {
      params['pendingAboveStrategyId'] = pendingAboveStrategyId;
    }
    if (pendingAboveStrategyType != null) {
      params['pendingAboveStrategyType'] = pendingAboveStrategyType;
    }
    if (pendingBelowType != null) params['pendingBelowType'] = pendingBelowType.toUpperCase();
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
      params['pendingBelowTimeInForce'] = pendingBelowTimeInForce.toUpperCase();
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
  ///
  /// All financial values use String type for precision
  Future<Map<String, dynamic>> placeOrder({
    required String symbol,
    required String side,
    required String type,
    String? quantity,
    String? price,
    String? timeInForce,
    String? positionSide,
    String? stopPrice,
    String? workingType,
    bool? priceProtect,
    String? newOrderRespType,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol.toUpperCase(),
      'side': side.toUpperCase(),
      'type': type.toUpperCase(),
    };

    if (quantity != null) params['quantity'] = quantity;
    if (price != null) params['price'] = price;
    if (timeInForce != null) params['timeInForce'] = timeInForce.toUpperCase();
    if (positionSide != null) params['positionSide'] = positionSide.toUpperCase();
    if (stopPrice != null) params['stopPrice'] = stopPrice;
    if (workingType != null) params['workingType'] = workingType;
    if (priceProtect != null) params['priceProtect'] = priceProtect;
    if (newOrderRespType != null) params['newOrderRespType'] = newOrderRespType;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/fapi/v1/order', params: params, isOrder: true);
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
  ///
  /// All financial values use String type for precision
  Future<Map<String, dynamic>> placeOrder({
    required String symbol,
    required String side,
    required String type,
    String? quantity,
    String? quoteOrderQty,
    String? price,
    String? newClientOrderId,
    String? stopPrice,
    String? timeInForce,
    String? newOrderRespType,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol.toUpperCase(),
      'side': side.toUpperCase(),
      'type': type.toUpperCase(),
    };

    if (quantity != null) params['quantity'] = quantity;
    if (quoteOrderQty != null) params['quoteOrderQty'] = quoteOrderQty;
    if (price != null) params['price'] = price;
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (stopPrice != null) params['stopPrice'] = stopPrice;
    if (timeInForce != null) params['timeInForce'] = timeInForce.toUpperCase();
    if (newOrderRespType != null) params['newOrderRespType'] = newOrderRespType;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/api/v3/order', params: params, isOrder: true);
  }

  /// Test order creation (validation only)
  Future<Map<String, dynamic>> testOrder({
    required String symbol,
    required String side,
    required String type,
    String? quantity,
    String? price,
    String? timeInForce,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol.toUpperCase(),
      'side': side.toUpperCase(),
      'type': type.toUpperCase(),
    };

    if (quantity != null) params['quantity'] = quantity;
    if (price != null) params['price'] = price;
    if (timeInForce != null) params['timeInForce'] = timeInForce.toUpperCase();
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
  ///
  /// All financial values use String type for precision
  Future<Map<String, dynamic>> placeOrder({
    required String symbol,
    required String side,
    required String type,
    String? quantity,
    String? price,
    String? timeInForce,
    String? positionSide,
    String? stopPrice,
    String? workingType,
    String? newOrderRespType,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol.toUpperCase(),
      'side': side.toUpperCase(),
      'type': type.toUpperCase(),
    };

    if (quantity != null) params['quantity'] = quantity;
    if (price != null) params['price'] = price;
    if (timeInForce != null) params['timeInForce'] = timeInForce.toUpperCase();
    if (positionSide != null) params['positionSide'] = positionSide.toUpperCase();
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

// ============================================================================
// COIN-M Futures Testnet API
// ============================================================================

/// Binance COIN-M Futures Testnet
///
/// COIN-M Futures are margined and settled in cryptocurrency (e.g., BTC, ETH)
/// rather than USDT. This is useful for holders who want exposure without
/// converting to stablecoins.
///
/// Base URL: https://testnet.binancefuture.com (same as USD-M but /dapi/ path)
/// WebSocket: wss://dstream.binancefuture.com
///
/// Key differences from USD-M:
/// - Settled in cryptocurrency (BTC, ETH, etc.)
/// - Uses /dapi/ endpoints instead of /fapi/
/// - Contract sizes are in USD value
/// - Inverse contracts (profit/loss in base currency)
class TestnetFuturesCoinM {
  final TestnetFuturesCoinMMarket market;
  final TestnetFuturesCoinMTrading trading;

  TestnetFuturesCoinM({String? apiKey, String? apiSecret})
      : market = TestnetFuturesCoinMMarket(apiKey: apiKey, apiSecret: apiSecret),
        trading =
            TestnetFuturesCoinMTrading(apiKey: apiKey, apiSecret: apiSecret);
}

/// COIN-M Futures Market data for testnet
///
/// Provides market data endpoints for COIN-margined delivery futures.
class TestnetFuturesCoinMMarket extends BinanceBase {
  TestnetFuturesCoinMMarket({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://testnet.binancefuture.com',
        );

  /// Test connectivity (Weight: 1)
  Future<Map<String, dynamic>> ping() {
    return sendRequest('GET', '/dapi/v1/ping', weight: 1);
  }

  /// Get COIN-M testnet server time (Weight: 1)
  Future<Map<String, dynamic>> getServerTime() {
    return sendRequest('GET', '/dapi/v1/time', weight: 1);
  }

  /// Get COIN-M testnet exchange information (Weight: 1)
  ///
  /// Returns current exchange trading rules and symbol information
  Future<Map<String, dynamic>> getExchangeInfo() {
    return sendRequest('GET', '/dapi/v1/exchangeInfo', weight: 1);
  }

  /// Get COIN-M testnet order book (Weight: 5-20 depending on limit)
  ///
  /// [limit] Valid limits: 5, 10, 20, 50, 100, 500, 1000
  Future<Map<String, dynamic>> getOrderBook(String symbol, {int limit = 100}) {
    final weight = limit <= 50 ? 5 : (limit <= 100 ? 10 : 20);
    return sendRequest('GET', '/dapi/v1/depth',
        params: {'symbol': symbol, 'limit': limit}, weight: weight);
  }

  /// Get COIN-M testnet recent trades (Weight: 5)
  Future<List<dynamic>> getRecentTrades(String symbol, {int limit = 500}) async {
    final response = await sendRequest('GET', '/dapi/v1/trades',
        params: {'symbol': symbol, 'limit': limit}, weight: 5);
    return response as List<dynamic>;
  }

  /// Get COIN-M testnet historical trades (Weight: 20)
  Future<List<dynamic>> getHistoricalTrades(String symbol,
      {int limit = 500, int? fromId}) async {
    final params = <String, dynamic>{'symbol': symbol, 'limit': limit};
    if (fromId != null) params['fromId'] = fromId;

    final response = await sendRequest('GET', '/dapi/v1/historicalTrades',
        params: params, weight: 20);
    return response as List<dynamic>;
  }

  /// Get COIN-M testnet aggregate trades (Weight: 20)
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

    final response = await sendRequest('GET', '/dapi/v1/aggTrades',
        params: params, weight: 20);
    return response as List<dynamic>;
  }

  /// Get COIN-M testnet index price and mark price (Weight: 1)
  Future<dynamic> getPremiumIndex([String? symbol]) async {
    final params = <String, dynamic>{};
    if (symbol != null) params['symbol'] = symbol;

    return sendRequest('GET', '/dapi/v1/premiumIndex', params: params, weight: 1);
  }

  /// Get COIN-M testnet funding rate history (Weight: 1)
  Future<List<dynamic>> getFundingRate({
    String? symbol,
    int? startTime,
    int? endTime,
    int limit = 100,
  }) async {
    final params = <String, dynamic>{'limit': limit};
    if (symbol != null) params['symbol'] = symbol;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;

    final response = await sendRequest('GET', '/dapi/v1/fundingRate',
        params: params, weight: 1);
    return response as List<dynamic>;
  }

  /// Get COIN-M testnet klines/candlestick data (Weight: 5)
  ///
  /// [interval] Valid intervals: 1m, 3m, 5m, 15m, 30m, 1h, 2h, 4h, 6h, 8h, 12h, 1d, 3d, 1w, 1M
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
        await sendRequest('GET', '/dapi/v1/klines', params: params, weight: 5);
    return response as List<dynamic>;
  }

  /// Get COIN-M testnet continuous contract klines (Weight: 5)
  ///
  /// [contractType] PERPETUAL, CURRENT_QUARTER, NEXT_QUARTER
  Future<List<dynamic>> getContinuousKlines(
    String pair,
    String contractType,
    String interval, {
    int? startTime,
    int? endTime,
    int limit = 500,
  }) async {
    final params = <String, dynamic>{
      'pair': pair,
      'contractType': contractType,
      'interval': interval,
      'limit': limit,
    };
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;

    final response = await sendRequest('GET', '/dapi/v1/continuousKlines',
        params: params, weight: 5);
    return response as List<dynamic>;
  }

  /// Get COIN-M testnet index price klines (Weight: 5)
  Future<List<dynamic>> getIndexPriceKlines(
    String pair,
    String interval, {
    int? startTime,
    int? endTime,
    int limit = 500,
  }) async {
    final params = <String, dynamic>{
      'pair': pair,
      'interval': interval,
      'limit': limit,
    };
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;

    final response = await sendRequest('GET', '/dapi/v1/indexPriceKlines',
        params: params, weight: 5);
    return response as List<dynamic>;
  }

  /// Get COIN-M testnet mark price klines (Weight: 5)
  Future<List<dynamic>> getMarkPriceKlines(
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

    final response = await sendRequest('GET', '/dapi/v1/markPriceKlines',
        params: params, weight: 5);
    return response as List<dynamic>;
  }

  /// Get COIN-M testnet 24hr ticker (Weight: 1-40)
  Future<dynamic> get24HrTicker([String? symbol]) async {
    final params = <String, dynamic>{};
    if (symbol != null) params['symbol'] = symbol;

    final weight = symbol != null ? 1 : 40;
    return sendRequest('GET', '/dapi/v1/ticker/24hr',
        params: params, weight: weight);
  }

  /// Get COIN-M testnet price ticker (Weight: 1-2)
  Future<dynamic> getTickerPrice([String? symbol]) async {
    final params = <String, dynamic>{};
    if (symbol != null) params['symbol'] = symbol;

    final weight = symbol != null ? 1 : 2;
    return sendRequest('GET', '/dapi/v1/ticker/price',
        params: params, weight: weight);
  }

  /// Get COIN-M testnet book ticker (Weight: 1-2)
  Future<dynamic> getBookTicker([String? symbol]) async {
    final params = <String, dynamic>{};
    if (symbol != null) params['symbol'] = symbol;

    final weight = symbol != null ? 1 : 2;
    return sendRequest('GET', '/dapi/v1/ticker/bookTicker',
        params: params, weight: weight);
  }

  /// Get COIN-M testnet open interest (Weight: 1)
  Future<Map<String, dynamic>> getOpenInterest(String symbol) {
    return sendRequest('GET', '/dapi/v1/openInterest',
        params: {'symbol': symbol}, weight: 1);
  }

  /// Get COIN-M testnet open interest statistics (Weight: 1)
  Future<List<dynamic>> getOpenInterestHist({
    required String pair,
    required String contractType,
    required String period,
    int? startTime,
    int? endTime,
    int limit = 30,
  }) async {
    final params = <String, dynamic>{
      'pair': pair,
      'contractType': contractType,
      'period': period,
      'limit': limit,
    };
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;

    final response = await sendRequest('GET', '/futures/data/openInterestHist',
        params: params, weight: 1);
    return response as List<dynamic>;
  }
}

/// COIN-M Futures Trading for testnet
///
/// Supports all trading operations for COIN-margined delivery futures.
class TestnetFuturesCoinMTrading extends BinanceBase {
  TestnetFuturesCoinMTrading({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://testnet.binancefuture.com',
        );

  /// Place a new COIN-M futures order on testnet (Weight: 1)
  ///
  /// All financial values use String type for precision
  /// [type] LIMIT, MARKET, STOP, STOP_MARKET, TAKE_PROFIT, TAKE_PROFIT_MARKET,
  ///        TRAILING_STOP_MARKET
  /// [side] BUY or SELL
  /// [positionSide] BOTH, LONG, SHORT (for hedge mode)
  Future<Map<String, dynamic>> placeOrder({
    required String symbol,
    required String side,
    required String type,
    String? positionSide,
    String? timeInForce,
    String? quantity,
    bool? reduceOnly,
    String? price,
    String? newClientOrderId,
    String? stopPrice,
    String? activationPrice,
    String? callbackRate,
    String? workingType,
    bool? priceProtect,
    String? newOrderRespType,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol.toUpperCase(),
      'side': side.toUpperCase(),
      'type': type.toUpperCase(),
    };

    if (positionSide != null) params['positionSide'] = positionSide.toUpperCase();
    if (timeInForce != null) params['timeInForce'] = timeInForce.toUpperCase();
    if (quantity != null) params['quantity'] = quantity;
    if (reduceOnly != null) params['reduceOnly'] = reduceOnly;
    if (price != null) params['price'] = price;
    if (newClientOrderId != null) params['newClientOrderId'] = newClientOrderId;
    if (stopPrice != null) params['stopPrice'] = stopPrice;
    if (activationPrice != null) params['activationPrice'] = activationPrice;
    if (callbackRate != null) params['callbackRate'] = callbackRate;
    if (workingType != null) params['workingType'] = workingType;
    if (priceProtect != null) params['priceProtect'] = priceProtect;
    if (newOrderRespType != null) params['newOrderRespType'] = newOrderRespType;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/dapi/v1/order', params: params, isOrder: true);
  }

  /// Place multiple orders (batch) on testnet (Weight: 5)
  ///
  /// Maximum 5 orders per request
  Future<List<dynamic>> placeBatchOrders({
    required List<Map<String, dynamic>> batchOrders,
    int? recvWindow,
  }) async {
    final params = <String, dynamic>{
      'batchOrders': batchOrders,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response = await sendRequest('POST', '/dapi/v1/batchOrders',
        params: params, weight: 5, isOrder: true);
    return response as List<dynamic>;
  }

  /// Query order status on testnet (Weight: 1)
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

    return sendRequest('GET', '/dapi/v1/order', params: params, weight: 1);
  }

  /// Cancel an order on testnet (Weight: 1)
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

    return sendRequest('DELETE', '/dapi/v1/order', params: params, weight: 1);
  }

  /// Cancel all open orders on a symbol (Weight: 1)
  Future<Map<String, dynamic>> cancelAllOrders({
    required String symbol,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'symbol': symbol};
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('DELETE', '/dapi/v1/allOpenOrders', params: params, weight: 1);
  }

  /// Cancel multiple orders (batch) on testnet (Weight: 1)
  Future<List<dynamic>> cancelBatchOrders({
    required String symbol,
    List<int>? orderIdList,
    List<String>? origClientOrderIdList,
    int? recvWindow,
  }) async {
    final params = <String, dynamic>{'symbol': symbol};
    if (orderIdList != null) params['orderIdList'] = orderIdList;
    if (origClientOrderIdList != null) {
      params['origClientOrderIdList'] = origClientOrderIdList;
    }
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response = await sendRequest('DELETE', '/dapi/v1/batchOrders',
        params: params, weight: 1);
    return response as List<dynamic>;
  }

  /// Auto-cancel all open orders (countdown) (Weight: 10)
  ///
  /// [countdownTime] Countdown time in milliseconds. 0 to cancel the timer.
  Future<Map<String, dynamic>> setAutoCancel({
    required String symbol,
    required int countdownTime,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol,
      'countdownTime': countdownTime,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/dapi/v1/countdownCancelAll',
        params: params, weight: 10);
  }

  /// Get current open order on testnet (Weight: 1)
  Future<Map<String, dynamic>> getCurrentOpenOrder({
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

    return sendRequest('GET', '/dapi/v1/openOrder', params: params, weight: 1);
  }

  /// Get all open orders on testnet (Weight: 1-40)
  Future<List<dynamic>> getOpenOrders({String? symbol, int? recvWindow}) async {
    final params = <String, dynamic>{};
    if (symbol != null) params['symbol'] = symbol;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final weight = symbol != null ? 1 : 40;
    final response = await sendRequest('GET', '/dapi/v1/openOrders',
        params: params, weight: weight);
    return response as List<dynamic>;
  }

  /// Get all orders on testnet (Weight: 20)
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

    final response = await sendRequest('GET', '/dapi/v1/allOrders',
        params: params, weight: 20);
    return response as List<dynamic>;
  }

  /// Get COIN-M testnet account balance (Weight: 1)
  Future<List<dynamic>> getBalance({int? recvWindow}) async {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response =
        await sendRequest('GET', '/dapi/v1/balance', params: params, weight: 1);
    return response as List<dynamic>;
  }

  /// Get COIN-M testnet account information (Weight: 5)
  Future<Map<String, dynamic>> getAccountInfo({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('GET', '/dapi/v1/account', params: params, weight: 5);
  }

  /// Change initial leverage on testnet (Weight: 1)
  Future<Map<String, dynamic>> changeInitialLeverage({
    required String symbol,
    required int leverage,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol,
      'leverage': leverage,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/dapi/v1/leverage', params: params, weight: 1);
  }

  /// Change margin type on testnet (Weight: 1)
  ///
  /// [marginType] ISOLATED or CROSSED
  Future<Map<String, dynamic>> changeMarginType({
    required String symbol,
    required String marginType,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol,
      'marginType': marginType,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/dapi/v1/marginType', params: params, weight: 1);
  }

  /// Modify isolated position margin on testnet (Weight: 1)
  ///
  /// [amount] Amount as string for precision (e.g., '100.0')
  /// [type] 1 = Add margin, 2 = Reduce margin
  Future<Map<String, dynamic>> modifyIsolatedPositionMargin({
    required String symbol,
    required String amount,
    required int type,
    String? positionSide,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol.toUpperCase(),
      'amount': amount,
      'type': type,
    };
    if (positionSide != null) params['positionSide'] = positionSide.toUpperCase();
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/dapi/v1/positionMargin',
        params: params, weight: 1);
  }

  /// Get position margin change history on testnet (Weight: 1)
  Future<List<dynamic>> getPositionMarginHistory({
    required String symbol,
    int? type,
    int? startTime,
    int? endTime,
    int limit = 500,
    int? recvWindow,
  }) async {
    final params = <String, dynamic>{
      'symbol': symbol,
      'limit': limit,
    };
    if (type != null) params['type'] = type;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response = await sendRequest('GET', '/dapi/v1/positionMargin/history',
        params: params, weight: 1);
    return response as List<dynamic>;
  }

  /// Get position information on testnet (Weight: 1)
  Future<List<dynamic>> getPositionRisk({
    String? marginAsset,
    String? pair,
    int? recvWindow,
  }) async {
    final params = <String, dynamic>{};
    if (marginAsset != null) params['marginAsset'] = marginAsset;
    if (pair != null) params['pair'] = pair;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response = await sendRequest('GET', '/dapi/v1/positionRisk',
        params: params, weight: 1);
    return response as List<dynamic>;
  }

  /// Get account trade history on testnet (Weight: 20)
  Future<List<dynamic>> getUserTrades({
    String? symbol,
    String? pair,
    int? startTime,
    int? endTime,
    int? fromId,
    int limit = 500,
    int? recvWindow,
  }) async {
    final params = <String, dynamic>{'limit': limit};
    if (symbol != null) params['symbol'] = symbol;
    if (pair != null) params['pair'] = pair;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (fromId != null) params['fromId'] = fromId;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response = await sendRequest('GET', '/dapi/v1/userTrades',
        params: params, weight: 20);
    return response as List<dynamic>;
  }

  /// Get income history on testnet (Weight: 20)
  Future<List<dynamic>> getIncomeHistory({
    String? symbol,
    String? incomeType,
    int? startTime,
    int? endTime,
    int limit = 100,
    int? recvWindow,
  }) async {
    final params = <String, dynamic>{'limit': limit};
    if (symbol != null) params['symbol'] = symbol;
    if (incomeType != null) params['incomeType'] = incomeType;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response = await sendRequest('GET', '/dapi/v1/income',
        params: params, weight: 20);
    return response as List<dynamic>;
  }

  /// Get notional and leverage brackets on testnet (Weight: 1)
  Future<dynamic> getLeverageBracket({String? pair, int? recvWindow}) async {
    final params = <String, dynamic>{};
    if (pair != null) params['pair'] = pair;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('GET', '/dapi/v2/leverageBracket',
        params: params, weight: 1);
  }

  /// Change position mode on testnet (Weight: 1)
  ///
  /// [dualSidePosition] true = Hedge Mode, false = One-way Mode
  Future<Map<String, dynamic>> changePositionMode({
    required bool dualSidePosition,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'dualSidePosition': dualSidePosition};
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('POST', '/dapi/v1/positionSide/dual',
        params: params, weight: 1);
  }

  /// Get current position mode on testnet (Weight: 30)
  Future<Map<String, dynamic>> getPositionMode({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('GET', '/dapi/v1/positionSide/dual',
        params: params, weight: 30);
  }

  /// Get user's force orders (liquidation) on testnet (Weight: 20)
  Future<List<dynamic>> getForceOrders({
    String? symbol,
    String? autoCloseType,
    int? startTime,
    int? endTime,
    int limit = 50,
    int? recvWindow,
  }) async {
    final params = <String, dynamic>{'limit': limit};
    if (symbol != null) params['symbol'] = symbol;
    if (autoCloseType != null) params['autoCloseType'] = autoCloseType;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response = await sendRequest('GET', '/dapi/v1/forceOrders',
        params: params, weight: 20);
    return response as List<dynamic>;
  }

  /// Get ADL quantile estimation on testnet (Weight: 5)
  Future<List<dynamic>> getAdlQuantile({String? symbol, int? recvWindow}) async {
    final params = <String, dynamic>{};
    if (symbol != null) params['symbol'] = symbol;
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    final response = await sendRequest('GET', '/dapi/v1/adlQuantile',
        params: params, weight: 5);
    return response as List<dynamic>;
  }

  /// Get user commission rate on testnet (Weight: 20)
  Future<Map<String, dynamic>> getCommissionRate({
    required String symbol,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'symbol': symbol};
    if (recvWindow != null) params['recvWindow'] = recvWindow;

    return sendRequest('GET', '/dapi/v1/commissionRate',
        params: params, weight: 20);
  }
}

/// COIN-M Futures User Data Stream for testnet
class TestnetFuturesCoinMUserDataStream extends BinanceBase {
  TestnetFuturesCoinMUserDataStream({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://testnet.binancefuture.com',
        );

  /// Start a new user data stream (Weight: 1)
  Future<Map<String, dynamic>> createListenKey() {
    return sendRequest('POST', '/dapi/v1/listenKey', weight: 1);
  }

  /// Keepalive a user data stream (Weight: 1)
  Future<Map<String, dynamic>> keepAliveListenKey() {
    return sendRequest('PUT', '/dapi/v1/listenKey', weight: 1);
  }

  /// Close a user data stream (Weight: 1)
  Future<Map<String, dynamic>> closeListenKey() {
    return sendRequest('DELETE', '/dapi/v1/listenKey', weight: 1);
  }
}
