import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:shelf/shelf.dart';
import 'package:shelf_web_socket/shelf_web_socket.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import 'package:babel_binance/babel_binance.dart';
import 'package:logging/logging.dart';

/// WebSocket Service for Real-Time Price Streams
/// Streams live price updates to connected clients using Binance WebSocket API

class WebSocketService {
  final Binance binance;
  final Logger _log = Logger('WebSocketService');

  final Set<WebSocketChannel> _clients = {};
  final Map<String, StreamSubscription> _symbolStreams = {};
  final Set<String> _subscribedSymbols = {};

  Timer? _heartbeatTimer;

  WebSocketService({required this.binance});

  /// Create WebSocket handler
  Handler createHandler() {
    return webSocketHandler((WebSocketChannel webSocket) {
      _log.info('New WebSocket client connected');
      _clients.add(webSocket);

      // Send initial connection message
      webSocket.sink.add(json.encode({
        'type': 'connected',
        'message': 'WebSocket connected',
        'timestamp': DateTime.now().toIso8601String(),
      }));

      // Handle incoming messages from client
      webSocket.stream.listen(
        (message) => _handleClientMessage(webSocket, message),
        onDone: () {
          _log.info('WebSocket client disconnected');
          _clients.remove(webSocket);
          _checkSubscriptions();
        },
        onError: (error) {
          _log.warning('WebSocket error: $error');
          _clients.remove(webSocket);
        },
      );
    });
  }

  /// Handle messages from client
  void _handleClientMessage(WebSocketChannel client, dynamic message) {
    try {
      final data = json.decode(message);
      final action = data['action'];

      switch (action) {
        case 'subscribe':
          final symbols = (data['symbols'] as List?)?.cast<String>() ?? [];
          _subscribe(symbols);
          break;
        case 'unsubscribe':
          final symbols = (data['symbols'] as List?)?.cast<String>() ?? [];
          _unsubscribe(symbols);
          break;
        case 'ping':
          client.sink.add(json.encode({
            'type': 'pong',
            'timestamp': DateTime.now().toIso8601String(),
          }));
          break;
        default:
          _log.warning('Unknown action: $action');
      }
    } catch (e) {
      _log.warning('Failed to handle client message: $e');
    }
  }

  /// Subscribe to symbol price streams
  void _subscribe(List<String> symbols) {
    for (final symbol in symbols) {
      if (_subscribedSymbols.contains(symbol)) continue;

      _log.info('Subscribing to $symbol stream');
      _subscribedSymbols.add(symbol);

      // Create WebSocket stream for this symbol
      try {
        final stream = binance.spot.websocket.miniTicker(
          symbol: symbol.toLowerCase(),
        );

        final subscription = stream.listen(
          (data) => _broadcastPriceUpdate(symbol, data),
          onError: (error) {
            _log.warning('Stream error for $symbol: $error');
            _symbolStreams.remove(symbol);
            _subscribedSymbols.remove(symbol);
          },
          cancelOnError: true,
        );

        _symbolStreams[symbol] = subscription;
      } catch (e) {
        _log.severe('Failed to subscribe to $symbol: $e');
      }
    }
  }

  /// Unsubscribe from symbol price streams
  void _unsubscribe(List<String> symbols) {
    for (final symbol in symbols) {
      _symbolStreams[symbol]?.cancel();
      _symbolStreams.remove(symbol);
      _subscribedSymbols.remove(symbol);
      _log.info('Unsubscribed from $symbol stream');
    }
  }

  /// Broadcast price update to all connected clients
  void _broadcastPriceUpdate(String symbol, Map<String, dynamic> data) {
    final message = json.encode({
      'type': 'price_update',
      'symbol': symbol,
      'price': data['c'],  // Close price
      'open': data['o'],   // Open price
      'high': data['h'],   // High price
      'low': data['l'],    // Low price
      'volume': data['v'], // Volume
      'change': data['p'], // Price change
      'changePercent': data['P'], // Price change percent
      'timestamp': DateTime.now().toIso8601String(),
    });

    final deadClients = <WebSocketChannel>[];

    for (final client in _clients) {
      try {
        client.sink.add(message);
      } catch (e) {
        _log.warning('Failed to send to client: $e');
        deadClients.add(client);
      }
    }

    // Remove dead clients
    _clients.removeAll(deadClients);
  }

  /// Broadcast trade update to all clients
  void broadcastTradeUpdate(Map<String, dynamic> trade) {
    final message = json.encode({
      'type': 'trade_update',
      'data': trade,
      'timestamp': DateTime.now().toIso8601String(),
    });

    _broadcastToAll(message);
  }

  /// Broadcast alert trigger to all clients
  void broadcastAlertTrigger(Map<String, dynamic> alert) {
    final message = json.encode({
      'type': 'alert_triggered',
      'data': alert,
      'timestamp': DateTime.now().toIso8601String(),
    });

    _broadcastToAll(message);
  }

  /// Broadcast performance update to all clients
  void broadcastPerformanceUpdate(Map<String, dynamic> performance) {
    final message = json.encode({
      'type': 'performance_update',
      'data': performance,
      'timestamp': DateTime.now().toIso8601String(),
    });

    _broadcastToAll(message);
  }

  /// Broadcast message to all connected clients
  void _broadcastToAll(String message) {
    final deadClients = <WebSocketChannel>[];

    for (final client in _clients) {
      try {
        client.sink.add(message);
      } catch (e) {
        deadClients.add(client);
      }
    }

    _clients.removeAll(deadClients);
  }

  /// Check if any subscriptions should be canceled
  void _checkSubscriptions() {
    if (_clients.isEmpty) {
      // No clients connected, cancel all subscriptions
      for (final subscription in _symbolStreams.values) {
        subscription.cancel();
      }
      _symbolStreams.clear();
      _subscribedSymbols.clear();
      _log.info('All clients disconnected, canceled all subscriptions');
    }
  }

  /// Start heartbeat to keep connections alive
  void startHeartbeat() {
    _heartbeatTimer?.cancel();
    _heartbeatTimer = Timer.periodic(Duration(seconds: 30), (_) {
      _broadcastToAll(json.encode({
        'type': 'heartbeat',
        'clients': _clients.length,
        'subscriptions': _subscribedSymbols.length,
        'timestamp': DateTime.now().toIso8601String(),
      }));
    });
  }

  /// Clean up resources
  void dispose() {
    _heartbeatTimer?.cancel();
    for (final subscription in _symbolStreams.values) {
      subscription.cancel();
    }
    _symbolStreams.clear();
    _subscribedSymbols.clear();
    for (final client in _clients) {
      client.sink.close();
    }
    _clients.clear();
  }

  /// Get current statistics
  Map<String, dynamic> getStatistics() {
    return {
      'connected_clients': _clients.length,
      'subscribed_symbols': _subscribedSymbols.toList(),
      'active_streams': _symbolStreams.length,
    };
  }
}
