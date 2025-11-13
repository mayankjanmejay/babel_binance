import 'dart:async';
import 'dart:convert';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'websocket_config.dart';

/// Connection state of WebSocket
enum ConnectionState {
  disconnected,
  connecting,
  connected,
  reconnecting,
  disconnecting,
  failed,
}

/// WebSocket stream manager with reconnection and heartbeat
class BinanceWebSocketStream {
  final String url;
  final WebSocketConfig config;
  final void Function(String)? onDebug;

  WebSocketChannel? _channel;
  StreamSubscription? _subscription;
  Timer? _pingTimer;
  Timer? _pongTimer;
  Timer? _reconnectTimer;

  ConnectionState _state = ConnectionState.disconnected;
  int _reconnectAttempts = 0;
  DateTime? _lastPongReceived;
  DateTime? _connectedAt;

  final _messageController = StreamController<dynamic>.broadcast();
  final _stateController = StreamController<ConnectionState>.broadcast();

  bool _isDisposed = false;

  BinanceWebSocketStream({
    required this.url,
    WebSocketConfig? config,
    this.onDebug,
  }) : config = config ?? WebSocketConfig.defaultConfig;

  /// Stream of messages received from WebSocket
  Stream<dynamic> get messages => _messageController.stream;

  /// Stream of connection state changes
  Stream<ConnectionState> get connectionState => _stateController.stream;

  /// Current connection state
  ConnectionState get state => _state;

  /// Whether currently connected
  bool get isConnected => _state == ConnectionState.connected;

  /// Connection uptime
  Duration? get uptime {
    if (_connectedAt == null) return null;
    return DateTime.now().difference(_connectedAt!);
  }

  /// Connect to WebSocket
  Future<void> connect() async {
    if (_isDisposed) throw StateError('Stream is disposed');
    if (_state == ConnectionState.connected ||
        _state == ConnectionState.connecting) {
      return;
    }

    _updateState(ConnectionState.connecting);
    _debug('Connecting to $url');

    try {
      _channel = WebSocketChannel.connect(
        Uri.parse(url),
      );

      // Wait for connection with timeout
      await _channel!.ready.timeout(
        config.connectionTimeout,
        onTimeout: () {
          throw TimeoutException('Connection timeout');
        },
      );

      _updateState(ConnectionState.connected);
      _connectedAt = DateTime.now();
      _reconnectAttempts = 0;

      _debug('Connected successfully');

      // Start listening to messages
      _subscription = _channel!.stream.listen(
        _handleMessage,
        onError: _handleError,
        onDone: _handleDone,
        cancelOnError: false,
      );

      // Start ping/pong heartbeat
      _startHeartbeat();

    } catch (e) {
      _debug('Connection failed: $e');
      _updateState(ConnectionState.failed);

      if (config.autoReconnect) {
        _scheduleReconnect();
      } else {
        _messageController.addError(e);
      }
    }
  }

  /// Disconnect from WebSocket
  Future<void> disconnect() async {
    if (_state == ConnectionState.disconnected) return;

    _updateState(ConnectionState.disconnecting);
    _debug('Disconnecting...');

    _cancelTimers();
    await _subscription?.cancel();
    await _channel?.sink.close();

    _subscription = null;
    _channel = null;
    _connectedAt = null;

    _updateState(ConnectionState.disconnected);
    _debug('Disconnected');
  }

  /// Send message to WebSocket
  void send(dynamic message) {
    if (!isConnected) {
      throw StateError('Not connected');
    }

    final data = message is String ? message : json.encode(message);
    _channel!.sink.add(data);
    _debug('Sent: $data');
  }

  /// Handle incoming message
  void _handleMessage(dynamic message) {
    _debug('Received: $message');

    try {
      final data = json.decode(message as String);

      // Check for pong response
      if (data is Map && data['pong'] != null) {
        _handlePong();
        return;
      }

      // Emit message to subscribers
      _messageController.add(data);

    } catch (e) {
      _debug('Error parsing message: $e');
      _messageController.addError(e);
    }
  }

  /// Handle WebSocket error
  void _handleError(Object error, [StackTrace? stackTrace]) {
    _debug('WebSocket error: $error');
    _messageController.addError(error, stackTrace);

    // Reconnect on error if enabled
    if (config.autoReconnect && _state == ConnectionState.connected) {
      _handleDone();
    }
  }

  /// Handle WebSocket done/closed
  void _handleDone() {
    _debug('WebSocket closed');
    _cancelTimers();

    if (_state != ConnectionState.disconnecting &&
        _state != ConnectionState.disconnected) {

      if (config.autoReconnect) {
        _updateState(ConnectionState.reconnecting);
        _scheduleReconnect();
      } else {
        _updateState(ConnectionState.disconnected);
      }
    }
  }

  /// Start ping/pong heartbeat
  void _startHeartbeat() {
    _lastPongReceived = DateTime.now();

    _pingTimer?.cancel();
    _pingTimer = Timer.periodic(config.pingInterval, (_) {
      _sendPing();
    });
  }

  /// Send ping
  void _sendPing() {
    if (!isConnected) return;

    try {
      // Binance uses this format for ping
      send({'ping': DateTime.now().millisecondsSinceEpoch});
      _debug('Sent ping');

      // Start pong timeout timer
      _pongTimer?.cancel();
      _pongTimer = Timer(config.pongTimeout, () {
        _debug('Pong timeout - reconnecting');
        _handlePongTimeout();
      });

    } catch (e) {
      _debug('Failed to send ping: $e');
    }
  }

  /// Handle pong received
  void _handlePong() {
    _pongTimer?.cancel();
    _lastPongReceived = DateTime.now();
    _debug('Received pong');
  }

  /// Handle pong timeout
  void _handlePongTimeout() {
    _debug('No pong received - connection likely dead');

    if (config.autoReconnect) {
      disconnect().then((_) => _scheduleReconnect());
    } else {
      disconnect();
    }
  }

  /// Schedule reconnection with exponential backoff
  void _scheduleReconnect() {
    if (_isDisposed) return;

    final maxAttempts = config.maxReconnectAttempts;
    if (maxAttempts != null && _reconnectAttempts >= maxAttempts) {
      _debug('Max reconnection attempts reached');
      _updateState(ConnectionState.failed);
      return;
    }

    _reconnectAttempts++;

    // Exponential backoff: 1s, 2s, 4s, 8s, up to max
    final delay = _clampDuration(
      Duration(
        milliseconds: config.initialReconnectDelay.inMilliseconds *
            (1 << (_reconnectAttempts - 1).clamp(0, 5)),
      ),
      config.initialReconnectDelay,
      config.maxReconnectDelay,
    );

    _debug('Reconnecting in ${delay.inSeconds}s (attempt $_reconnectAttempts)');

    _reconnectTimer?.cancel();
    _reconnectTimer = Timer(delay, () {
      if (!_isDisposed) {
        connect();
      }
    });
  }

  /// Update connection state
  void _updateState(ConnectionState newState) {
    if (_state != newState) {
      _state = newState;
      _stateController.add(newState);
      _debug('State: $newState');
    }
  }

  /// Cancel all timers
  void _cancelTimers() {
    _pingTimer?.cancel();
    _pongTimer?.cancel();
    _reconnectTimer?.cancel();
    _pingTimer = null;
    _pongTimer = null;
    _reconnectTimer = null;
  }

  /// Debug logging
  void _debug(String message) {
    if (config.debugMode) {
      print('[WebSocket] $message');
    }
    onDebug?.call(message);
  }

  Duration _clampDuration(Duration value, Duration min, Duration max) {
    if (value < min) return min;
    if (value > max) return max;
    return value;
  }

  /// Dispose and clean up
  Future<void> dispose() async {
    _isDisposed = true;
    await disconnect();
    _cancelTimers();
    await _messageController.close();
    await _stateController.close();
  }
}
