import 'dart:io';
import 'dart:convert';
import 'package:shelf/shelf.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf_cors_headers/shelf_cors_headers.dart';
import 'package:dotenv/dotenv.dart';
import 'package:logging/logging.dart';
import 'package:babel_binance/babel_binance.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

/// REST API Server for the trading bot web UI
void main() async {
  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    print('[${record.time}] ${record.level.name}: ${record.message}');
  });

  final log = Logger('APIServer');

  log.info('🚀 Starting API Server...');

  // Load environment
  try {
    load('.env');
  } catch (e) {
    log.warning('No .env file found, using environment variables');
  }

  // Initialize Binance client
  final binance = Binance(
    apiKey: env['BINANCE_API_KEY'],
    apiSecret: env['BINANCE_API_SECRET'],
  );

  // Initialize Appwrite client
  final client = Client()
      .setEndpoint(env['APPWRITE_ENDPOINT'] ?? 'http://appwrite/v1')
      .setProject(env['APPWRITE_PROJECT_ID'] ?? '')
      .setKey(env['APPWRITE_API_KEY'] ?? '');

  final databases = Databases(client);
  final databaseId = env['APPWRITE_DATABASE_ID'] ?? 'crypto_trading';

  // Create router
  final router = Router();

  // ============================================================================
  // HEALTH & STATUS
  // ============================================================================

  router.get('/health', (Request request) {
    return Response.ok(
      json.encode({
        'status': 'healthy',
        'timestamp': DateTime.now().toIso8601String(),
        'version': '1.0.0',
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  router.get('/status', (Request request) async {
    try {
      // Test Binance connection
      final serverTime = await binance.spot.market.getServerTime();

      // Test Appwrite connection
      await databases.list();

      return Response.ok(
        json.encode({
          'status': 'operational',
          'services': {
            'binance': 'connected',
            'appwrite': 'connected',
          },
          'binance_time': serverTime['serverTime'],
          'timestamp': DateTime.now().toIso8601String(),
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // ============================================================================
  // MARKET DATA
  // ============================================================================

  router.get('/api/market/ticker/<symbol>', (Request request, String symbol) async {
    try {
      final ticker = await binance.spot.market.get24HrTicker(symbol.toUpperCase());
      return Response.ok(
        json.encode(ticker),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.get('/api/market/tickers', (Request request) async {
    try {
      final watchlist = await _getWatchlist(databases, databaseId);
      final tickers = <Map<String, dynamic>>[];

      for (final item in watchlist) {
        try {
          final ticker = await binance.spot.market.get24HrTicker(item['symbol']);
          tickers.add(ticker);
        } catch (e) {
          log.warning('Failed to get ticker for ${item['symbol']}: $e');
        }
      }

      return Response.ok(
        json.encode(tickers),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // ============================================================================
  // WATCHLIST
  // ============================================================================

  router.get('/api/watchlist', (Request request) async {
    try {
      final watchlist = await _getWatchlist(databases, databaseId);
      return Response.ok(
        json.encode(watchlist),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.post('/api/watchlist', (Request request) async {
    try {
      final payload = json.decode(await request.readAsString());

      await databases.createDocument(
        databaseId: databaseId,
        collectionId: env['APPWRITE_COLLECTION_WATCHLIST'] ?? 'watchlist',
        documentId: ID.unique(),
        data: {
          'user_id': env['BOT_USER_ID'] ?? 'default_user',
          'symbol': payload['symbol'],
          'target_buy': payload['target_buy'],
          'target_sell': payload['target_sell'],
          'active': true,
          'created_at': DateTime.now().toIso8601String(),
        },
      );

      return Response.ok(
        json.encode({'success': true, 'message': 'Symbol added to watchlist'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.delete('/api/watchlist/<id>', (Request request, String id) async {
    try {
      await databases.deleteDocument(
        databaseId: databaseId,
        collectionId: env['APPWRITE_COLLECTION_WATCHLIST'] ?? 'watchlist',
        documentId: id,
      );

      return Response.ok(
        json.encode({'success': true, 'message': 'Symbol removed from watchlist'}),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // ============================================================================
  // TRADES
  // ============================================================================

  router.get('/api/trades', (Request request) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: env['APPWRITE_COLLECTION_TRADES'] ?? 'trades',
        queries: [
          Query.orderDesc('timestamp'),
          Query.limit(100),
        ],
      );

      return Response.ok(
        json.encode(response.documents.map((doc) => doc.data).toList()),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.get('/api/trades/stats', (Request request) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: env['APPWRITE_COLLECTION_TRADES'] ?? 'trades',
        queries: [Query.limit(1000)],
      );

      final trades = response.documents.map((doc) => doc.data).toList();

      // Calculate stats
      int totalTrades = trades.length;
      int buyTrades = trades.where((t) => t['side'] == 'BUY').length;
      int sellTrades = trades.where((t) => t['side'] == 'SELL').length;

      double totalVolume = trades.fold(0.0, (sum, t) => sum + (t['total_value'] ?? 0));

      return Response.ok(
        json.encode({
          'total_trades': totalTrades,
          'buy_trades': buyTrades,
          'sell_trades': sellTrades,
          'total_volume': totalVolume,
          'last_trade': trades.isNotEmpty ? trades.first : null,
        }),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  // ============================================================================
  // BOT CONTROL (Future implementation)
  // ============================================================================

  router.get('/api/bot/status', (Request request) {
    return Response.ok(
      json.encode({
        'status': 'running',
        'mode': env['BOT_SIMULATION_MODE'] == 'true' ? 'simulation' : 'live',
        'message': 'Bot status endpoint - full implementation pending',
      }),
      headers: {'Content-Type': 'application/json'},
    );
  });

  // ============================================================================
  // START SERVER
  // ============================================================================

  final handler = Pipeline()
      .addMiddleware(logRequests())
      .addMiddleware(corsHeaders())
      .addHandler(router);

  final port = int.parse(env['API_PORT'] ?? '3000');
  final server = await shelf_io.serve(handler, InternetAddress.anyIPv4, port);

  log.info('✅ API Server running on http://${server.address.host}:${server.port}');
  log.info('📡 CORS enabled for all origins');
  log.info('🔗 Endpoints:');
  log.info('   GET  /health');
  log.info('   GET  /status');
  log.info('   GET  /api/market/ticker/<symbol>');
  log.info('   GET  /api/market/tickers');
  log.info('   GET  /api/watchlist');
  log.info('   POST /api/watchlist');
  log.info('   GET  /api/trades');
  log.info('   GET  /api/trades/stats');
}

/// Helper to get watchlist
Future<List<Map<String, dynamic>>> _getWatchlist(Databases databases, String databaseId) async {
  final response = await databases.listDocuments(
    databaseId: databaseId,
    collectionId: Platform.environment['APPWRITE_COLLECTION_WATCHLIST'] ?? 'watchlist',
    queries: [Query.equal('active', true)],
  );

  return response.documents.map((doc) => doc.data).toList();
}
