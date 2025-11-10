import 'dart:io';
import 'dart:convert';
import 'package:babel_binance/babel_binance.dart';
import 'package:dotenv/dotenv.dart';
import 'package:logging/logging.dart';
import 'package:dart_appwrite/dart_appwrite.dart';

import '../lib/algorithms/sma_crossover.dart';
import '../lib/algorithms/rsi_strategy.dart';
import '../lib/algorithms/grid_trading.dart';
import '../lib/bot/trading_bot.dart';
import '../lib/services/appwrite_service.dart';
import '../lib/services/stop_loss_manager.dart';
import '../lib/services/email_service.dart';
import '../lib/services/strategy_composer.dart';
import '../lib/setup/database_setup.dart';

/// Main entry point for the 24/7 trading bot
void main(List<String> arguments) async {
  // Setup logging
  Logger.root.level = Level.ALL;
  Logger.root.onRecord.listen((record) {
    final timestamp = record.time.toIso8601String().substring(11, 19);
    print('[$timestamp] ${record.level.name}: ${record.message}');

    // Also write to file if configured
    final logToFile = env['LOG_TO_FILE'] == 'true';
    if (logToFile) {
      final logFile = File(env['LOG_FILE_PATH'] ?? '/var/log/trading_bot.log');
      logFile.writeAsStringSync(
        '[$timestamp] ${record.level.name}: ${record.message}\n',
        mode: FileMode.append,
      );
    }
  });

  final log = Logger('Main');

  log.info('🚀 Crypto Trading Bot Starting...');

  // Load environment variables
  try {
    load('.env');
    log.info('✅ Environment variables loaded from .env file');
  } catch (e) {
    log.warning('⚠️  No .env file found, using environment variables');
  }

  // Verify required environment variables
  final requiredVars = [
    'BINANCE_API_KEY',
    'BINANCE_API_SECRET',
    'APPWRITE_ENDPOINT',
    'APPWRITE_PROJECT_ID',
    'APPWRITE_API_KEY',
  ];

  for (final varName in requiredVars) {
    if (env[varName] == null || env[varName]!.isEmpty) {
      log.severe('❌ Missing required environment variable: $varName');
      exit(1);
    }
  }

  log.info('✅ All required environment variables present');

  // Initialize Binance client
  final binance = Binance(
    apiKey: env['BINANCE_API_KEY']!,
    apiSecret: env['BINANCE_API_SECRET']!,
  );

  log.info('✅ Binance client initialized');

  // Initialize Appwrite service
  final appwrite = AppwriteService(
    endpoint: env['APPWRITE_ENDPOINT']!,
    projectId: env['APPWRITE_PROJECT_ID']!,
    apiKey: env['APPWRITE_API_KEY']!,
    databaseId: env['APPWRITE_DATABASE_ID'] ?? 'crypto_trading',
    watchlistCollectionId: env['APPWRITE_COLLECTION_WATCHLIST'] ?? 'watchlist',
    tradesCollectionId: env['APPWRITE_COLLECTION_TRADES'] ?? 'trades',
    algorithmsCollectionId: env['APPWRITE_COLLECTION_ALGORITHMS'] ?? 'algorithms',
    portfoliosCollectionId: env['APPWRITE_COLLECTION_PORTFOLIOS'] ?? 'portfolios',
  );

  log.info('✅ Appwrite service initialized');

  // Setup database (auto-create collections if they don't exist)
  final dbSetup = DatabaseSetup(
    client: Client()
        .setEndpoint(env['APPWRITE_ENDPOINT']!)
        .setProject(env['APPWRITE_PROJECT_ID']!)
        .setKey(env['APPWRITE_API_KEY']!),
    databaseId: env['APPWRITE_DATABASE_ID'] ?? 'crypto_trading',
    watchlistCollectionId: env['APPWRITE_COLLECTION_WATCHLIST'] ?? 'watchlist',
    tradesCollectionId: env['APPWRITE_COLLECTION_TRADES'] ?? 'trades',
    algorithmsCollectionId: env['APPWRITE_COLLECTION_ALGORITHMS'] ?? 'algorithms',
    portfoliosCollectionId: env['APPWRITE_COLLECTION_PORTFOLIOS'] ?? 'portfolios',
    botConfigsCollectionId: env['APPWRITE_COLLECTION_BOT_CONFIGS'] ?? 'bot_configs',
    alertsCollectionId: 'price_alerts',
  );

  final dbReady = await dbSetup.setup();
  if (!dbReady) {
    log.severe('❌ Database setup failed - bot cannot start');
    exit(1);
  }

  // Initialize trading algorithms
  final algorithms = [
    SMACrossover(
      shortPeriod: 20,
      longPeriod: 50,
      quantity: 0.001,
    ),
    RSIStrategy(
      period: 14,
      oversold: 30,
      overbought: 70,
      quantity: 0.001,
    ),
    GridTrading(
      lowerBound: 90000,
      upperBound: 100000,
      gridLevels: 10,
      quantityPerGrid: 0.0001,
    ),
  ];

  log.info('✅ ${algorithms.length} trading algorithms loaded');

  // Initialize stop-loss manager
  final stopLossManager = StopLossManager(
    defaultStopLossPercent: double.parse(env['STOP_LOSS_PERCENT'] ?? '0.02'),
    defaultTakeProfitPercent: double.parse(env['TAKE_PROFIT_PERCENT'] ?? '0.05'),
    enableTrailingStop: env['ENABLE_TRAILING_STOP'] != 'false',
    trailingStopPercent: double.parse(env['TRAILING_STOP_PERCENT'] ?? '0.02'),
  );

  log.info('✅ Stop-loss manager initialized');

  // Initialize email service (optional)
  EmailService? emailService;
  if (env['EMAIL_ENABLED'] == 'true') {
    emailService = EmailService(
      provider: env['EMAIL_PROVIDER'] ?? 'sendgrid',
      apiKey: env['EMAIL_API_KEY'] ?? '',
      fromEmail: env['EMAIL_FROM'] ?? '',
      fromName: env['EMAIL_FROM_NAME'] ?? 'Crypto Trading Bot',
      toEmail: env['EMAIL_TO'] ?? '',
    );

    log.info('✅ Email service initialized');
  } else {
    log.info('⚠️  Email notifications disabled');
  }

  // Initialize strategy composer (optional)
  StrategyComposer? strategyComposer;
  try {
    final strategyConfigFile = File('config/strategy.config.json');
    if (await strategyConfigFile.exists()) {
      final configContent = await strategyConfigFile.readAsString();
      final config = json.decode(configContent) as Map<String, dynamic>;

      if (config['enabled'] == true) {
        final mode = config['mode'] as String;
        CompositionMode compositionMode;

        switch (mode) {
          case 'voting':
            compositionMode = CompositionMode.voting;
            break;
          case 'weighted':
            compositionMode = CompositionMode.weighted;
            break;
          case 'unanimous':
            compositionMode = CompositionMode.unanimous;
            break;
          default:
            log.warning('⚠️  Unknown strategy mode: $mode, defaulting to voting');
            compositionMode = CompositionMode.voting;
        }

        // Build weights map for weighted mode
        final weights = <String, double>{};
        if (mode == 'weighted' && config['modes']?['weighted']?['weights'] != null) {
          final weightsConfig = config['modes']['weighted']['weights'] as Map<String, dynamic>;
          weightsConfig.forEach((key, value) {
            weights[key] = (value as num).toDouble();
          });
        } else {
          // Default weights
          for (final algo in algorithms) {
            weights[algo.name] = 1.0 / algorithms.length;
          }
        }

        final requiredVotes = mode == 'voting'
            ? (config['modes']?['voting']?['requiredVotes'] as int? ?? (algorithms.length / 2).ceil())
            : null;

        strategyComposer = StrategyComposer(
          algorithms: algorithms,
          mode: compositionMode,
          weights: weights,
          requiredVotes: requiredVotes,
        );

        log.info('✅ Strategy composer initialized ($mode mode)');
      } else {
        log.info('⚠️  Strategy composer disabled in config');
      }
    } else {
      log.info('⚠️  No strategy config found, using independent algorithms');
    }
  } catch (e, stack) {
    log.warning('⚠️  Failed to load strategy config: $e');
    log.fine(stack.toString());
  }

  // Initialize trading bot
  final bot = TradingBot(
    binance: binance,
    appwrite: appwrite,
    userId: env['BOT_USER_ID'] ?? 'default_user',
    algorithms: algorithms,
    checkIntervalSeconds: int.parse(env['BOT_CHECK_INTERVAL_SECONDS'] ?? '30'),
    simulationMode: env['BOT_SIMULATION_MODE'] != 'false',
    stopLossManager: stopLossManager,
    emailService: emailService,
    strategyComposer: strategyComposer,
  );

  // Setup graceful shutdown
  ProcessSignal.sigint.watch().listen((signal) async {
    log.info('\n🛑 Received interrupt signal, shutting down gracefully...');
    bot.stop();

    // Wait a bit for cleanup
    await Future.delayed(Duration(seconds: 2));

    log.info('👋 Goodbye!');
    exit(0);
  });

  // Start the bot
  await bot.start();

  // Keep the process running
  log.info('🔄 Bot is now running... Press Ctrl+C to stop');

  // Optional: Start health check HTTP server
  if (env['ENABLE_HEALTH_CHECK'] == 'true') {
    final port = int.parse(env['HEALTH_CHECK_PORT'] ?? '8080');
    final server = await HttpServer.bind(InternetAddress.anyIPv4, port);

    log.info('🏥 Health check server running on port $port');

    server.listen((request) {
      final stats = bot.getStatistics();

      request.response
        ..statusCode = stats['running'] ? 200 : 503
        ..headers.contentType = ContentType.json
        ..write('''
{
  "status": "${stats['running'] ? 'healthy' : 'unhealthy'}",
  "uptime_minutes": ${stats['uptime_minutes']},
  "cycles_completed": ${stats['cycles_completed']},
  "trades_executed": ${stats['trades_executed']},
  "errors_encountered": ${stats['errors_encountered']},
  "watchlist_size": ${stats['watchlist_size']},
  "active_algorithms": ${stats['active_algorithms']},
  "active_stop_losses": ${stats['active_stop_losses'] ?? 0},
  "active_take_profits": ${stats['active_take_profits'] ?? 0},
  "total_positions": ${stats['total_positions'] ?? 0},
  "timestamp": "${DateTime.now().toIso8601String()}"
}
''')
        ..close();
    });
  }

  // Keep running forever (until interrupted)
  await Future.delayed(Duration(days: 365 * 100));
}
