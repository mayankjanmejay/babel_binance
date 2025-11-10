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
  // PERFORMANCE ANALYTICS
  // ============================================================================

  router.get('/api/performance/summary', (Request request) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: env['APPWRITE_COLLECTION_TRADES'] ?? 'trades',
        queries: [Query.limit(1000)],
      );

      final trades = response.documents.map((doc) => doc.data).toList();

      if (trades.isEmpty) {
        return Response.ok(
          json.encode({
            'total_trades': 0,
            'total_profit_loss': 0.0,
            'win_rate': 0.0,
            'avg_profit': 0.0,
            'avg_loss': 0.0,
            'total_wins': 0,
            'total_losses': 0,
          }),
          headers: {'Content-Type': 'application/json'},
        );
      }

      // Calculate P&L (simplified - assumes paired buy/sell trades)
      final buys = <String, Map<String, dynamic>>{};
      double totalPL = 0.0;
      int wins = 0;
      int losses = 0;
      double totalProfits = 0.0;
      double totalLosses = 0.0;

      for (final trade in trades) {
        final symbol = trade['symbol'];
        final side = trade['side'];
        final price = trade['price'] ?? 0.0;
        final quantity = trade['quantity'] ?? 0.0;

        if (side == 'BUY') {
          buys[symbol] = trade;
        } else if (side == 'SELL' && buys.containsKey(symbol)) {
          final buyPrice = buys[symbol]!['price'] ?? 0.0;
          final pl = (price - buyPrice) * quantity;
          totalPL += pl;

          if (pl > 0) {
            wins++;
            totalProfits += pl;
          } else if (pl < 0) {
            losses++;
            totalLosses += pl.abs();
          }

          buys.remove(symbol);
        }
      }

      final winRate = (wins + losses) > 0 ? wins / (wins + losses) : 0.0;
      final avgProfit = wins > 0 ? totalProfits / wins : 0.0;
      final avgLoss = losses > 0 ? totalLosses / losses : 0.0;

      return Response.ok(
        json.encode({
          'total_trades': trades.length,
          'total_profit_loss': totalPL,
          'win_rate': winRate,
          'avg_profit': avgProfit,
          'avg_loss': avgLoss,
          'total_wins': wins,
          'total_losses': losses,
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

  router.get('/api/performance/chart', (Request request) async {
    try {
      final params = request.url.queryParameters;
      final period = params['period'] ?? 'week'; // day, week, month

      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: env['APPWRITE_COLLECTION_TRADES'] ?? 'trades',
        queries: [
          Query.orderAsc('timestamp'),
          Query.limit(1000),
        ],
      );

      final trades = response.documents.map((doc) => doc.data).toList();
      final chartData = <Map<String, dynamic>>[];

      // Group trades by time period
      final buys = <String, Map<String, dynamic>>{};
      double cumulativePL = 0.0;

      for (final trade in trades) {
        final symbol = trade['symbol'];
        final side = trade['side'];
        final price = trade['price'] ?? 0.0;
        final quantity = trade['quantity'] ?? 0.0;
        final timestamp = trade['timestamp'];

        if (side == 'BUY') {
          buys[symbol] = trade;
        } else if (side == 'SELL' && buys.containsKey(symbol)) {
          final buyPrice = buys[symbol]!['price'] ?? 0.0;
          final pl = (price - buyPrice) * quantity;
          cumulativePL += pl;

          chartData.add({
            'timestamp': timestamp,
            'profit_loss': pl,
            'cumulative_pl': cumulativePL,
            'symbol': symbol,
          });

          buys.remove(symbol);
        }
      }

      return Response.ok(
        json.encode(chartData),
        headers: {'Content-Type': 'application/json'},
      );
    } catch (e) {
      return Response.internalServerError(
        body: json.encode({'error': e.toString()}),
        headers: {'Content-Type': 'application/json'},
      );
    }
  });

  router.get('/api/performance/algorithms', (Request request) async {
    try {
      final response = await databases.listDocuments(
        databaseId: databaseId,
        collectionId: env['APPWRITE_COLLECTION_TRADES'] ?? 'trades',
        queries: [Query.limit(1000)],
      );

      final trades = response.documents.map((doc) => doc.data).toList();
      final algoPerformance = <String, Map<String, dynamic>>{};

      for (final trade in trades) {
        final algo = trade['algorithmName'] ?? 'Unknown';

        if (!algoPerformance.containsKey(algo)) {
          algoPerformance[algo] = {
            'name': algo,
            'total_trades': 0,
            'total_volume': 0.0,
            'buy_count': 0,
            'sell_count': 0,
          };
        }

        algoPerformance[algo]!['total_trades'] =
          (algoPerformance[algo]!['total_trades'] as int) + 1;
        algoPerformance[algo]!['total_volume'] =
          (algoPerformance[algo]!['total_volume'] as double) + (trade['total_value'] ?? 0.0);

        if (trade['side'] == 'BUY') {
          algoPerformance[algo]!['buy_count'] =
            (algoPerformance[algo]!['buy_count'] as int) + 1;
        } else {
          algoPerformance[algo]!['sell_count'] =
            (algoPerformance[algo]!['sell_count'] as int) + 1;
        }
      }

      return Response.ok(
        json.encode(algoPerformance.values.toList()),
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
  log.info('   GET  /api/performance/summary');
  log.info('   GET  /api/performance/chart');
  log.info('   GET  /api/performance/algorithms');
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
