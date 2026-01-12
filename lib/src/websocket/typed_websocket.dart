import 'dart:async';
import 'dart:convert';
import 'websocket_stream.dart';
import 'websocket_config.dart';
import 'websocket_events.dart';
import 'stream_types.dart';

/// Typed WebSocket client for Binance with strongly-typed event streams
///
/// Example usage:
/// ```dart
/// final ws = TypedBinanceWebSocket();
/// await ws.connect();
///
/// // Subscribe to multiple symbols at once
/// ws.subscribeMiniTickerMulti(['BTCUSDT', 'ETHUSDT']).listen((event) {
///   print('${event.symbol}: ${event.close}');
/// });
///
/// // Subscribe to kline streams
/// ws.subscribeKlineMulti(['BTCUSDT'], '5m').listen((event) {
///   if (event.isClosed) {
///     print('Candle closed: ${event.symbol} ${event.close}');
///   }
/// });
/// ```
class TypedBinanceWebSocket {
  final String baseUrl;
  final WebSocketConfig config;

  BinanceWebSocketStream? _stream;
  final Map<String, StreamController<dynamic>> _controllers = {};
  StreamSubscription<dynamic>? _messageSubscription;
  bool _isConnected = false;

  /// Currently subscribed stream names
  final Set<String> _subscribedStreams = {};

  TypedBinanceWebSocket({
    String? baseUrl,
    WebSocketConfig? config,
  })  : baseUrl = baseUrl ?? 'wss://stream.binance.com:9443',
        config = config ?? WebSocketConfig.defaultConfig;

  /// Whether the WebSocket is connected
  bool get isConnected => _isConnected;

  /// Get connection state
  ConnectionState? get state => _stream?.state;

  /// Stream of connection state changes
  Stream<ConnectionState>? get connectionState => _stream?.connectionState;

  /// Connect to WebSocket server
  Future<void> connect() async {
    if (_stream != null) return;

    // We'll connect when first stream is subscribed
    _isConnected = false;
  }

  /// Disconnect from WebSocket server
  Future<void> disconnect() async {
    await _messageSubscription?.cancel();
    _messageSubscription = null;
    await _stream?.dispose();
    _stream = null;
    _isConnected = false;
    _subscribedStreams.clear();

    // Close all controllers
    for (final controller in _controllers.values) {
      await controller.close();
    }
    _controllers.clear();
  }

  /// Reconnect with current subscriptions
  Future<void> reconnect() async {
    final streams = Set<String>.from(_subscribedStreams);
    await disconnect();
    if (streams.isNotEmpty) {
      await _connectToStreams(streams.toList());
    }
  }

  // ══════════════════════════════════════════════════════════════════════════
  // MINI TICKER STREAMS
  // ══════════════════════════════════════════════════════════════════════════

  /// Subscribe to mini ticker for a single symbol
  Stream<MiniTickerEvent> subscribeMiniTicker(String symbol) {
    return _subscribeTyped<MiniTickerEvent>(
      StreamConfig(type: StreamType.miniTicker, symbol: symbol),
      MiniTickerEvent.fromJson,
    );
  }

  /// Subscribe to mini tickers for multiple symbols (single connection)
  Stream<MiniTickerEvent> subscribeMiniTickerMulti(List<String> symbols) {
    final configs = symbols
        .map((s) => StreamConfig(type: StreamType.miniTicker, symbol: s))
        .toList();
    return _subscribeTypedMulti<MiniTickerEvent>(
      configs,
      MiniTickerEvent.fromJson,
    );
  }

  /// Subscribe to all market mini tickers
  Stream<MiniTickerEvent> subscribeAllMiniTickers() {
    return _subscribeTyped<MiniTickerEvent>(
      const StreamConfig(type: StreamType.allMarketMiniTicker),
      MiniTickerEvent.fromJson,
      isArrayStream: true,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // 24HR TICKER STREAMS
  // ══════════════════════════════════════════════════════════════════════════

  /// Subscribe to 24hr ticker for a single symbol
  Stream<TickerEvent> subscribeTicker(String symbol) {
    return _subscribeTyped<TickerEvent>(
      StreamConfig(type: StreamType.ticker, symbol: symbol),
      TickerEvent.fromJson,
    );
  }

  /// Subscribe to 24hr tickers for multiple symbols
  Stream<TickerEvent> subscribeTickerMulti(List<String> symbols) {
    final configs = symbols
        .map((s) => StreamConfig(type: StreamType.ticker, symbol: s))
        .toList();
    return _subscribeTypedMulti<TickerEvent>(configs, TickerEvent.fromJson);
  }

  /// Subscribe to all market 24hr tickers
  Stream<TickerEvent> subscribeAllTickers() {
    return _subscribeTyped<TickerEvent>(
      const StreamConfig(type: StreamType.allMarketTicker),
      TickerEvent.fromJson,
      isArrayStream: true,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // KLINE (CANDLESTICK) STREAMS
  // ══════════════════════════════════════════════════════════════════════════

  /// Subscribe to kline/candlestick stream for a single symbol
  ///
  /// Intervals: 1s, 1m, 3m, 5m, 15m, 30m, 1h, 2h, 4h, 6h, 8h, 12h, 1d, 3d, 1w, 1M
  Stream<KlineEvent> subscribeKline(String symbol, String interval) {
    return _subscribeTyped<KlineEvent>(
      StreamConfig(type: StreamType.kline, symbol: symbol, interval: interval),
      KlineEvent.fromJson,
    );
  }

  /// Subscribe to kline streams for multiple symbols
  Stream<KlineEvent> subscribeKlineMulti(List<String> symbols, String interval) {
    final configs = symbols
        .map((s) => StreamConfig(
            type: StreamType.kline, symbol: s, interval: interval))
        .toList();
    return _subscribeTypedMulti<KlineEvent>(configs, KlineEvent.fromJson);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // AGGREGATE TRADE STREAMS
  // ══════════════════════════════════════════════════════════════════════════

  /// Subscribe to aggregate trade stream for a single symbol
  Stream<AggTradeEvent> subscribeAggTrade(String symbol) {
    return _subscribeTyped<AggTradeEvent>(
      StreamConfig(type: StreamType.aggTrade, symbol: symbol),
      AggTradeEvent.fromJson,
    );
  }

  /// Subscribe to aggregate trade streams for multiple symbols
  Stream<AggTradeEvent> subscribeAggTradeMulti(List<String> symbols) {
    final configs = symbols
        .map((s) => StreamConfig(type: StreamType.aggTrade, symbol: s))
        .toList();
    return _subscribeTypedMulti<AggTradeEvent>(configs, AggTradeEvent.fromJson);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // TRADE STREAMS
  // ══════════════════════════════════════════════════════════════════════════

  /// Subscribe to individual trade stream for a single symbol
  Stream<TradeEvent> subscribeTrade(String symbol) {
    return _subscribeTyped<TradeEvent>(
      StreamConfig(type: StreamType.trade, symbol: symbol),
      TradeEvent.fromJson,
    );
  }

  /// Subscribe to trade streams for multiple symbols
  Stream<TradeEvent> subscribeTradeMulti(List<String> symbols) {
    final configs = symbols
        .map((s) => StreamConfig(type: StreamType.trade, symbol: s))
        .toList();
    return _subscribeTypedMulti<TradeEvent>(configs, TradeEvent.fromJson);
  }

  // ══════════════════════════════════════════════════════════════════════════
  // BOOK TICKER STREAMS
  // ══════════════════════════════════════════════════════════════════════════

  /// Subscribe to book ticker for a single symbol
  Stream<BookTickerEvent> subscribeBookTicker(String symbol) {
    return _subscribeTyped<BookTickerEvent>(
      StreamConfig(type: StreamType.bookTicker, symbol: symbol),
      BookTickerEvent.fromJson,
    );
  }

  /// Subscribe to book tickers for multiple symbols
  Stream<BookTickerEvent> subscribeBookTickerMulti(List<String> symbols) {
    final configs = symbols
        .map((s) => StreamConfig(type: StreamType.bookTicker, symbol: s))
        .toList();
    return _subscribeTypedMulti<BookTickerEvent>(
        configs, BookTickerEvent.fromJson);
  }

  /// Subscribe to all book tickers
  Stream<BookTickerEvent> subscribeAllBookTickers() {
    return _subscribeTyped<BookTickerEvent>(
      const StreamConfig(type: StreamType.allMarketBookTicker),
      BookTickerEvent.fromJson,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // DEPTH STREAMS
  // ══════════════════════════════════════════════════════════════════════════

  /// Subscribe to depth stream for a single symbol
  ///
  /// [levels] - Number of levels (5, 10, or 20)
  /// [updateSpeed] - Update speed in ms (100 or 1000)
  Stream<DepthEvent> subscribeDepth(
    String symbol, {
    int levels = 10,
    int? updateSpeed,
  }) {
    return _subscribeTyped<DepthEvent>(
      StreamConfig(
        type: StreamType.partialBookDepth,
        symbol: symbol,
        levels: levels,
        updateSpeed: updateSpeed,
      ),
      DepthEvent.fromJson,
    );
  }

  /// Subscribe to diff depth stream for a single symbol
  Stream<DepthEvent> subscribeDiffDepth(String symbol, {int? updateSpeed}) {
    return _subscribeTyped<DepthEvent>(
      StreamConfig(
        type: StreamType.diffDepth,
        symbol: symbol,
        updateSpeed: updateSpeed,
      ),
      DepthEvent.fromJson,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // INTERNAL METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Subscribe to a typed stream
  Stream<T> _subscribeTyped<T>(
    StreamConfig config,
    T Function(Map<String, dynamic>) parser, {
    bool isArrayStream = false,
  }) {
    final streamName = config.streamName;
    final key = 'single_$streamName';

    if (!_controllers.containsKey(key)) {
      _controllers[key] = StreamController<T>.broadcast();
      _subscribedStreams.add(streamName);
      _reconnectWithNewStreams();
    }

    return (_controllers[key] as StreamController<T>).stream;
  }

  /// Subscribe to multiple typed streams (combined endpoint)
  Stream<T> _subscribeTypedMulti<T>(
    List<StreamConfig> configs,
    T Function(Map<String, dynamic>) parser,
  ) {
    final streamNames = configs.map((c) => c.streamName).toList();
    final key = 'multi_${streamNames.join('_')}';

    if (!_controllers.containsKey(key)) {
      _controllers[key] = StreamController<T>.broadcast();
      _subscribedStreams.addAll(streamNames);
      _reconnectWithNewStreams();
    }

    return (_controllers[key] as StreamController<T>).stream;
  }

  /// Reconnect with all subscribed streams
  Future<void> _reconnectWithNewStreams() async {
    if (_subscribedStreams.isEmpty) return;

    // Cancel existing subscription
    await _messageSubscription?.cancel();
    await _stream?.dispose();

    // Connect with all streams
    await _connectToStreams(_subscribedStreams.toList());
  }

  /// Connect to multiple streams via combined endpoint
  Future<void> _connectToStreams(List<String> streamNames) async {
    if (streamNames.isEmpty) return;

    final url = '$baseUrl/stream?streams=${streamNames.join('/')}';

    _stream = BinanceWebSocketStream(
      url: url,
      config: config,
      onDebug: config.debugMode ? (msg) => print('[TypedWS] $msg') : null,
    );

    await _stream!.connect();
    _isConnected = true;

    _messageSubscription = _stream!.messages.listen(
      _handleMessage,
      onError: (error) {
        print('[TypedWS] Stream error: $error');
      },
      onDone: () {
        _isConnected = false;
      },
    );
  }

  /// Handle incoming WebSocket message
  void _handleMessage(dynamic message) {
    try {
      Map<String, dynamic> json;

      if (message is String) {
        json = jsonDecode(message) as Map<String, dynamic>;
      } else if (message is Map<String, dynamic>) {
        json = message;
      } else {
        return;
      }

      // Handle combined stream format
      if (json.containsKey('stream') && json.containsKey('data')) {
        final streamName = json['stream'] as String;
        final data = json['data'];

        // Handle array streams (like !miniTicker@arr)
        if (data is List) {
          for (final item in data) {
            _routeMessage(streamName, item as Map<String, dynamic>);
          }
        } else if (data is Map<String, dynamic>) {
          _routeMessage(streamName, data);
        }
      } else {
        // Single stream format - try to detect type from event
        _routeMessage(null, json);
      }
    } catch (e) {
      print('[TypedWS] Error parsing message: $e');
    }
  }

  /// Route message to appropriate controller
  void _routeMessage(String? streamName, Map<String, dynamic> data) {
    final eventType = data['e'] as String?;

    // Try to parse and emit to all matching controllers
    for (final entry in _controllers.entries) {
      try {
        final key = entry.key;
        final controller = entry.value;

        if (controller.isClosed) continue;

        // Match based on event type and parse accordingly
        if (eventType == '24hrMiniTicker' || eventType == 'miniTicker') {
          if (key.contains('miniTicker') || key.contains('MiniTicker')) {
            (controller as StreamController<MiniTickerEvent>)
                .add(MiniTickerEvent.fromJson(data));
          }
        } else if (eventType == '24hrTicker') {
          if (key.contains('ticker') &&
              !key.contains('mini') &&
              !key.contains('book')) {
            (controller as StreamController<TickerEvent>)
                .add(TickerEvent.fromJson(data));
          }
        } else if (eventType == 'kline') {
          if (key.contains('kline')) {
            (controller as StreamController<KlineEvent>)
                .add(KlineEvent.fromJson(data));
          }
        } else if (eventType == 'aggTrade') {
          if (key.contains('aggTrade')) {
            (controller as StreamController<AggTradeEvent>)
                .add(AggTradeEvent.fromJson(data));
          }
        } else if (eventType == 'trade') {
          if (key.contains('trade') && !key.contains('agg')) {
            (controller as StreamController<TradeEvent>)
                .add(TradeEvent.fromJson(data));
          }
        } else if (eventType == 'bookTicker' || data.containsKey('u')) {
          // bookTicker doesn't have 'e' field
          if (key.contains('bookTicker')) {
            (controller as StreamController<BookTickerEvent>)
                .add(BookTickerEvent.fromJson(data));
          }
        } else if (eventType == 'depthUpdate') {
          if (key.contains('depth') || key.contains('Depth')) {
            (controller as StreamController<DepthEvent>)
                .add(DepthEvent.fromJson(data));
          }
        }
      } catch (e) {
        // Type mismatch or parsing error - skip this controller
      }
    }
  }

  /// Dispose and clean up all resources
  Future<void> dispose() async {
    await disconnect();
  }
}
