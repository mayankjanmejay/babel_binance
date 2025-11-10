import 'dart:async';
import 'dart:io';
import 'package:babel_binance/babel_binance.dart';
import 'package:logging/logging.dart';

import '../algorithms/trading_algorithm.dart';
import '../models/watchlist_item.dart';
import '../models/trade_record.dart';
import '../services/appwrite_service.dart';
import '../services/stop_loss_manager.dart';
import '../services/email_service.dart';
import '../services/strategy_composer.dart';

/// Main trading bot that runs 24/7 monitoring markets and executing trades
class TradingBot {
  final Binance binance;
  final AppwriteService appwrite;
  final String userId;
  final List<TradingAlgorithm> algorithms;
  final int checkIntervalSeconds;
  final bool simulationMode;
  final StopLossManager? stopLossManager;
  final EmailService? emailService;
  final StrategyComposer? strategyComposer;
  final Logger _log = Logger('TradingBot');

  bool _running = false;
  Timer? _mainTimer;
  Timer? _healthCheckTimer;
  List<WatchlistItem> _watchlist = [];

  // Statistics
  int _cyclesCompleted = 0;
  int _tradesExecuted = 0;
  int _errorsEncountered = 0;
  DateTime? _startTime;

  TradingBot({
    required this.binance,
    required this.appwrite,
    required this.userId,
    required this.algorithms,
    this.checkIntervalSeconds = 30,
    this.simulationMode = true,
    this.stopLossManager,
    this.emailService,
    this.strategyComposer,
  });

  /// Start the trading bot
  Future<void> start() async {
    if (_running) {
      _log.warning('Bot is already running');
      return;
    }

    _running = true;
    _startTime = DateTime.now();
    _log.info('🤖 Starting Trading Bot');
    _log.info('   User ID: $userId');
    _log.info('   Mode: ${simulationMode ? "SIMULATION" : "LIVE TRADING"}');
    _log.info('   Check interval: ${checkIntervalSeconds}s');
    _log.info('   Algorithms: ${algorithms.map((a) => a.name).join(", ")}');

    if (strategyComposer != null) {
      final status = strategyComposer!.getStatus();
      _log.info('   🎯 Multi-Strategy Mode: ${status['mode']} (${status['requiredVotes'] ?? 'N/A'} votes)');
    } else {
      _log.info('   Strategy Mode: Independent algorithms');
    }

    // Verify Appwrite connection
    final appwriteOk = await appwrite.healthCheck();
    if (!appwriteOk) {
      _log.severe('❌ Appwrite connection failed - bot will not start');
      _running = false;
      return;
    }

    // Load watchlist
    await _refreshWatchlist();

    if (_watchlist.isEmpty) {
      _log.warning('⚠️  Watchlist is empty - add items to start trading');
    } else {
      _log.info('📋 Watching ${_watchlist.length} symbols: ${_watchlist.map((w) => w.symbol).join(", ")}');
    }

    // Start main trading cycle
    _mainTimer = Timer.periodic(
      Duration(seconds: checkIntervalSeconds),
      (_) => _runTradingCycle(),
    );

    // Start health check timer (every 5 minutes)
    _healthCheckTimer = Timer.periodic(
      Duration(minutes: 5),
      (_) => _performHealthCheck(),
    );

    // Run first cycle immediately
    await _runTradingCycle();

    _log.info('✅ Trading bot started successfully');
  }

  /// Stop the trading bot
  void stop() {
    _running = false;
    _mainTimer?.cancel();
    _healthCheckTimer?.cancel();

    final uptime = _startTime != null
        ? DateTime.now().difference(_startTime!).inMinutes
        : 0;

    _log.info('🛑 Trading bot stopped');
    _log.info('   Uptime: ${uptime} minutes');
    _log.info('   Cycles completed: $_cyclesCompleted');
    _log.info('   Trades executed: $_tradesExecuted');
    _log.info('   Errors encountered: $_errorsEncountered');
  }

  /// Main trading cycle - runs every check interval
  Future<void> _runTradingCycle() async {
    if (!_running) return;

    final cycleStart = DateTime.now();
    _cyclesCompleted++;

    try {
      _log.fine('🔄 Starting trading cycle #$_cyclesCompleted');

      // Refresh watchlist periodically
      if (_cyclesCompleted % 20 == 0) {
        await _refreshWatchlist();
      }

      // Check stop-loss and take-profit orders
      if (stopLossManager != null && _watchlist.isNotEmpty) {
        await _checkRiskManagement();
      }

      // Process each symbol in watchlist
      for (final item in _watchlist) {
        if (!_running) break;

        await _processSymbol(item);
      }

      final duration = DateTime.now().difference(cycleStart).inMilliseconds;
      _log.fine('✅ Cycle #$_cyclesCompleted completed in ${duration}ms');
    } catch (e, stack) {
      _errorsEncountered++;
      _log.severe('❌ Error in trading cycle: $e\n$stack');
    }
  }

  /// Process a single symbol - get price and run algorithms
  Future<void> _processSymbol(WatchlistItem item) async {
    try {
      // Get current market price
      final ticker = await binance.spot.market.get24HrTicker(item.symbol);
      final currentPrice = double.parse(ticker['lastPrice']);

      _log.fine('${item.symbol}: \$${currentPrice.toStringAsFixed(2)}');

      // Use strategy composer if enabled, otherwise run algorithms independently
      if (strategyComposer != null) {
        // Multi-strategy mode - compose signals from multiple algorithms
        final composedSignal = await strategyComposer!.composeSignal(item.symbol, currentPrice);

        if (composedSignal != null) {
          _log.info('📊 Multi-Strategy Signal: ${composedSignal.algorithmName}');
          _log.info('   ${composedSignal.side} ${item.symbol} @ ${composedSignal.price ?? "MARKET"}');
          _log.info('   Reason: ${composedSignal.reason}');
          _log.info('   Confidence: ${(composedSignal.confidence * 100).toStringAsFixed(1)}%');

          // Execute composed trade
          await _executeTrade(item.symbol, composedSignal);
        }
      } else {
        // Independent algorithm mode - run each algorithm separately
        for (final algorithm in algorithms) {
          if (!algorithm.active) continue;

          final signal = await algorithm.analyze(item.symbol, currentPrice);

          if (signal != null) {
            _log.info('📊 Signal: ${signal.algorithmName} - ${signal.side} ${item.symbol} @ ${signal.price ?? "MARKET"}');
            _log.info('   Reason: ${signal.reason}');
            _log.info('   Confidence: ${(signal.confidence * 100).toStringAsFixed(1)}%');

            // Execute trade
            await _executeTrade(item.symbol, signal);
          }
        }
      }
    } catch (e) {
      _log.warning('Failed to process ${item.symbol}: $e');
    }
  }

  /// Execute a trade based on a signal
  Future<void> _executeTrade(String symbol, dynamic signal) async {
    try {
      Map<String, dynamic> order;

      if (simulationMode) {
        // Use simulation mode
        _log.info('🎯 Executing SIMULATED trade');
        order = await binance.spot.simulatedTrading.simulatePlaceOrder(
          symbol: symbol,
          side: signal.side,
          type: signal.type,
          quantity: signal.quantity,
          price: signal.price,
          timeInForce: signal.timeInForce,
        );
      } else {
        // Live trading - BE CAREFUL!
        _log.warning('🔴 Executing LIVE trade');
        order = await binance.spot.trading.placeOrder(
          symbol: symbol,
          side: signal.side,
          type: signal.type,
          quantity: signal.quantity,
          price: signal.price,
          timeInForce: signal.timeInForce,
        );
      }

      _tradesExecuted++;

      final executedPrice = double.tryParse(order['price']?.toString() ?? '0') ?? 0;

      _log.info('✅ Trade executed successfully');
      _log.info('   Order ID: ${order['orderId']}');
      _log.info('   Status: ${order['status']}');
      _log.info('   Filled: ${order['executedQty']} ${symbol.replaceAll('USDT', '')}');

      // Save to database
      final trade = TradeRecord(
        userId: userId,
        symbol: symbol,
        side: signal.side,
        quantity: signal.quantity,
        price: executedPrice,
        totalValue: double.tryParse(order['cummulativeQuoteQty']?.toString() ?? '0') ?? 0,
        timestamp: DateTime.now(),
        algorithmName: signal.algorithmName,
        orderId: order['orderId'].toString(),
        status: order['status'],
      );

      await appwrite.saveTrade(trade);

      // Add stop-loss and take-profit orders for this position
      if (stopLossManager != null && executedPrice > 0) {
        stopLossManager!.addStopLoss(
          symbol: symbol,
          side: signal.side,
          entryPrice: executedPrice,
          quantity: signal.quantity,
        );

        stopLossManager!.addTakeProfit(
          symbol: symbol,
          side: signal.side,
          entryPrice: executedPrice,
          quantity: signal.quantity,
        );

        _log.info('   Risk management orders added (SL/TP)');
      }

      // Send email notification
      if (emailService != null) {
        try {
          await emailService!.notifyTradeExecuted(trade);
          _log.fine('   Email notification sent');
        } catch (e) {
          _log.warning('   Failed to send email notification: $e');
        }
      }
    } catch (e, stack) {
      _errorsEncountered++;
      _log.severe('❌ Failed to execute trade: $e\n$stack');

      // Send error notification
      if (emailService != null) {
        try {
          await emailService!.notifyError(
            'Failed to execute trade for $symbol',
            details: e.toString(),
          );
        } catch (_) {
          // Ignore email errors
        }
      }
    }
  }

  /// Check stop-loss and take-profit orders
  Future<void> _checkRiskManagement() async {
    try {
      // Get current prices for all symbols with active orders
      final activeStopLosses = stopLossManager!.getActiveStopLosses();
      final activeTakeProfits = stopLossManager!.getActiveTakeProfits();

      if (activeStopLosses.isEmpty && activeTakeProfits.isEmpty) {
        return;
      }

      // Build map of current prices
      final priceMap = <String, double>{};
      final symbols = <String>{
        ...activeStopLosses.map((sl) => sl.symbol),
        ...activeTakeProfits.map((tp) => tp.symbol),
      };

      for (final symbol in symbols) {
        try {
          final ticker = await binance.spot.market.get24HrTicker(symbol);
          priceMap[symbol] = double.parse(ticker['lastPrice']);
        } catch (e) {
          _log.warning('Failed to get price for $symbol: $e');
        }
      }

      // Check all risk management orders
      final triggeredSignals = stopLossManager!.checkAll(priceMap);

      // Execute exit trades for triggered orders
      for (final signal in triggeredSignals) {
        _log.warning('🛑 Risk management order triggered: ${signal.reason}');

        // Execute the exit trade
        await _executeTrade(signal.side == 'BUY' ? 'BTCUSDT' : 'BTCUSDT', signal);

        // Send stop-loss notification if it was a stop-loss trigger
        if (emailService != null && signal.reason.contains('Stop-loss')) {
          try {
            final stopLoss = activeStopLosses.firstWhere(
              (sl) => sl.symbol == signal.side,
              orElse: () => activeStopLosses.first,
            );

            final currentPrice = priceMap[stopLoss.symbol] ?? 0;
            final loss = stopLoss.calculatePL(currentPrice);
            final lossPercent = stopLoss.calculatePLPercent(currentPrice);

            await emailService!.notifyStopLoss(
              symbol: stopLoss.symbol,
              entryPrice: stopLoss.entryPrice,
              exitPrice: currentPrice,
              loss: loss.abs(),
              lossPercent: lossPercent.abs(),
            );
          } catch (e) {
            _log.warning('Failed to send stop-loss email: $e');
          }
        }
      }
    } catch (e, stack) {
      _log.warning('Error checking risk management: $e\n$stack');
    }
  }

  /// Refresh watchlist from database
  Future<void> _refreshWatchlist() async {
    try {
      _watchlist = await appwrite.getActiveWatchlist(userId);
      _log.info('📋 Watchlist refreshed: ${_watchlist.length} items');
    } catch (e) {
      _log.warning('Failed to refresh watchlist: $e');
    }
  }

  /// Perform health check
  Future<void> _performHealthCheck() async {
    _log.info('🏥 Health check');

    // Check Appwrite
    final appwriteOk = await appwrite.healthCheck();
    _log.info('   Appwrite: ${appwriteOk ? "✅" : "❌"}');

    // Check Binance API
    try {
      await binance.spot.market.getServerTime();
      _log.info('   Binance: ✅');
    } catch (e) {
      _log.severe('   Binance: ❌ ($e)');
    }

    // Statistics
    final uptime = _startTime != null
        ? DateTime.now().difference(_startTime!).inMinutes
        : 0;

    _log.info('   Uptime: ${uptime} minutes');
    _log.info('   Cycles: $_cyclesCompleted');
    _log.info('   Trades: $_tradesExecuted');
    _log.info('   Errors: $_errorsEncountered');
  }

  /// Get bot statistics
  Map<String, dynamic> getStatistics() {
    final uptime = _startTime != null
        ? DateTime.now().difference(_startTime!).inMinutes
        : 0;

    final stats = {
      'running': _running,
      'uptime_minutes': uptime,
      'cycles_completed': _cyclesCompleted,
      'trades_executed': _tradesExecuted,
      'errors_encountered': _errorsEncountered,
      'watchlist_size': _watchlist.length,
      'active_algorithms': algorithms.where((a) => a.active).length,
      'total_algorithms': algorithms.length,
    };

    // Add risk management statistics if available
    if (stopLossManager != null) {
      stats.addAll(stopLossManager!.getStatistics());
    }

    return stats;
  }
}
