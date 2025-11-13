import 'dart:async';
import 'websocket_stream.dart';
import 'websocket_config.dart';
import 'stream_types.dart';

/// Main WebSocket client for Binance
class BinanceWebSocket {
  final String baseUrl;
  final WebSocketConfig config;

  final Map<String, BinanceWebSocketStream> _activeStreams = {};

  BinanceWebSocket({
    String? baseUrl,
    WebSocketConfig? config,
  }) : baseUrl = baseUrl ?? 'wss://stream.binance.com:9443',
       config = config ?? WebSocketConfig.defaultConfig;

  /// Connect to user data stream (requires listen key)
  Stream<dynamic> connectUserDataStream(String listenKey) {
    return _connectToStream('$baseUrl/ws/$listenKey');
  }

  /// Connect to single market stream
  Stream<dynamic> connectMarketStream(StreamConfig streamConfig) {
    final streamName = streamConfig.streamName;
    return _connectToStream('$baseUrl/ws/$streamName');
  }

  /// Connect to combined streams
  Stream<dynamic> connectCombinedStreams(List<StreamConfig> streams) {
    final streamNames = streams.map((s) => s.streamName).join('/');
    return _connectToStream('$baseUrl/stream?streams=$streamNames');
  }

  /// Connect to a stream by URL
  Stream<dynamic> _connectToStream(String url) {
    // Reuse existing connection if already connected
    if (_activeStreams.containsKey(url)) {
      final stream = _activeStreams[url]!;
      if (stream.isConnected) {
        return stream.messages;
      }
    }

    // Create new stream
    final stream = BinanceWebSocketStream(
      url: url,
      config: config,
      onDebug: (msg) => print('[WebSocket:$url] $msg'),
    );

    _activeStreams[url] = stream;

    // Auto-connect
    stream.connect();

    return stream.messages;
  }

  /// Disconnect from specific stream
  Future<void> disconnectStream(String url) async {
    final stream = _activeStreams.remove(url);
    await stream?.dispose();
  }

  /// Disconnect from all streams
  Future<void> disconnectAll() async {
    await Future.wait(_activeStreams.values.map((s) => s.dispose()));
    _activeStreams.clear();
  }

  /// Get connection state of a stream
  ConnectionState? getStreamState(String url) {
    return _activeStreams[url]?.state;
  }

  /// Get all active stream URLs
  List<String> get activeStreamUrls => _activeStreams.keys.toList();

  /// Number of active streams
  int get activeStreamCount => _activeStreams.length;

  /// Dispose and clean up all resources
  Future<void> dispose() async {
    await disconnectAll();
  }
}
