import 'websocket/websocket_client.dart';
import 'websocket/websocket_config.dart';
import 'websocket/stream_types.dart';

export 'websocket/websocket_client.dart';
export 'websocket/websocket_config.dart';
export 'websocket/stream_types.dart';
export 'websocket/websocket_stream.dart';

/// WebSocket client for Binance API
class Websockets {
  final BinanceWebSocket _client;

  Websockets({
    String? baseUrl,
    WebSocketConfig? config,
  }) : _client = BinanceWebSocket(baseUrl: baseUrl, config: config);

  /// Connect to user data stream
  Stream<dynamic> connectToStream(String listenKey) {
    return _client.connectUserDataStream(listenKey);
  }

  /// Connect to aggregate trade stream
  Stream<dynamic> aggTradeStream(String symbol) {
    return _client.connectMarketStream(StreamConfig.aggTrade(symbol));
  }

  /// Connect to kline/candlestick stream
  Stream<dynamic> klineStream(String symbol, String interval) {
    return _client.connectMarketStream(StreamConfig.kline(symbol, interval));
  }

  /// Connect to ticker stream
  Stream<dynamic> tickerStream(String symbol) {
    return _client.connectMarketStream(StreamConfig.ticker(symbol));
  }

  /// Connect to depth/order book stream
  Stream<dynamic> depthStream(String symbol, {int levels = 20, int? updateSpeed}) {
    return _client.connectMarketStream(
      StreamConfig.depth(symbol, levels: levels, updateSpeed: updateSpeed),
    );
  }

  /// Connect to multiple streams at once
  Stream<dynamic> combinedStreams(List<StreamConfig> streams) {
    return _client.connectCombinedStreams(streams);
  }

  /// Disconnect all streams
  Future<void> disconnectAll() => _client.disconnectAll();

  /// Dispose resources
  Future<void> dispose() => _client.dispose();
}
