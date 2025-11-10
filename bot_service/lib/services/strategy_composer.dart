import 'package:logging/logging.dart';
import '../algorithms/trading_algorithm.dart';
import '../models/trade_signal.dart';

/// Composition modes for combining algorithm signals
enum CompositionMode {
  /// Require N of M algorithms to agree (e.g., 2 of 3)
  voting,

  /// Weighted average of signals (each algorithm has a weight)
  weighted,

  /// All algorithms must agree
  unanimous,
}

/// Combines signals from multiple trading algorithms
class StrategyComposer {
  final List<TradingAlgorithm> algorithms;
  final CompositionMode mode;
  final Map<String, double> weights; // Algorithm name -> weight (for weighted mode)
  final int requiredVotes; // For voting mode (default: majority)
  final Logger _log = Logger('StrategyComposer');

  StrategyComposer({
    required this.algorithms,
    required this.mode,
    Map<String, double>? weights,
    int? requiredVotes,
  })  : weights = weights ?? {},
        requiredVotes = requiredVotes ?? ((algorithms.length / 2).ceil()) {
    _validateConfiguration();
  }

  /// Validate that configuration makes sense
  void _validateConfiguration() {
    if (algorithms.isEmpty) {
      throw ArgumentError('At least one algorithm is required');
    }

    if (mode == CompositionMode.weighted) {
      // Ensure all algorithms have weights
      for (final algo in algorithms) {
        if (!weights.containsKey(algo.name)) {
          throw ArgumentError('Algorithm ${algo.name} missing weight in weighted mode');
        }
      }

      // Ensure weights sum to 1.0 (or close to it)
      final totalWeight = weights.values.reduce((a, b) => a + b);
      if ((totalWeight - 1.0).abs() > 0.01) {
        throw ArgumentError('Weights must sum to 1.0 (current: $totalWeight)');
      }
    }

    if (mode == CompositionMode.voting) {
      if (requiredVotes > algorithms.length) {
        throw ArgumentError('Required votes ($requiredVotes) cannot exceed number of algorithms (${algorithms.length})');
      }
      if (requiredVotes < 1) {
        throw ArgumentError('Required votes must be at least 1');
      }
    }
  }

  /// Compose signals from all algorithms and return a combined signal (or null)
  Future<TradeSignal?> composeSignal(String symbol, double currentPrice) async {
    try {
      // Get signals from all active algorithms
      final signals = <TradeSignal>[];
      final algorithmVotes = <String, TradeSignal>{};

      for (final algo in algorithms) {
        if (!algo.active) continue;

        final signal = await algo.analyze(symbol, currentPrice);
        if (signal != null) {
          signals.add(signal);
          algorithmVotes[algo.name] = signal;
        }
      }

      if (signals.isEmpty) {
        return null;
      }

      // Apply composition logic based on mode
      switch (mode) {
        case CompositionMode.voting:
          return _composeByVoting(signals, algorithmVotes, symbol, currentPrice);

        case CompositionMode.weighted:
          return _composeByWeights(signals, algorithmVotes, symbol, currentPrice);

        case CompositionMode.unanimous:
          return _composeByUnanimous(signals, algorithmVotes, symbol, currentPrice);
      }
    } catch (e, stack) {
      _log.severe('Failed to compose signal for $symbol: $e\n$stack');
      return null;
    }
  }

  /// Voting mode: require N of M algorithms to agree on direction (BUY/SELL)
  TradeSignal? _composeByVoting(
    List<TradeSignal> signals,
    Map<String, TradeSignal> algorithmVotes,
    String symbol,
    double currentPrice,
  ) {
    // Count votes for each side
    final buyVotes = signals.where((s) => s.side == 'BUY').length;
    final sellVotes = signals.where((s) => s.side == 'SELL').length;

    // Determine winning side
    String? winningSide;
    int winningCount = 0;

    if (buyVotes >= requiredVotes) {
      winningSide = 'BUY';
      winningCount = buyVotes;
    } else if (sellVotes >= requiredVotes) {
      winningSide = 'SELL';
      winningCount = sellVotes;
    }

    if (winningSide == null) {
      _log.info('No consensus reached for $symbol (BUY: $buyVotes, SELL: $sellVotes, Required: $requiredVotes)');
      return null;
    }

    // Get signals for winning side
    final winningSignals = signals.where((s) => s.side == winningSide).toList();

    // Average confidence of winning signals
    final avgConfidence = winningSignals.map((s) => s.confidence).reduce((a, b) => a + b) / winningSignals.length;

    // Average quantity
    final avgQuantity = winningSignals.map((s) => s.quantity).reduce((a, b) => a + b) / winningSignals.length;

    // Build reason
    final voters = winningSignals.map((s) => s.algorithmName).join(', ');
    final reason = 'Multi-Strategy Voting: $winningCount/${ algorithms.length} voted $winningSide ($voters)';

    _log.info('✅ $symbol: $reason (confidence: ${(avgConfidence * 100).toFixed(1)}%)');

    return TradeSignal(
      side: winningSide,
      type: 'MARKET',
      quantity: avgQuantity,
      reason: reason,
      algorithmName: 'Strategy Composer (Voting)',
      confidence: avgConfidence,
    );
  }

  /// Weighted mode: weighted average of signals
  TradeSignal? _composeByWeights(
    List<TradeSignal> signals,
    Map<String, TradeSignal> algorithmVotes,
    String symbol,
    double currentPrice,
  ) {
    // Calculate weighted scores for each side
    double buyScore = 0.0;
    double sellScore = 0.0;

    for (final signal in signals) {
      final weight = weights[signal.algorithmName] ?? 0.0;
      final weightedConfidence = weight * signal.confidence;

      if (signal.side == 'BUY') {
        buyScore += weightedConfidence;
      } else if (signal.side == 'SELL') {
        sellScore += weightedConfidence;
      }
    }

    // Determine winning side (must exceed threshold of 0.5)
    String? winningSide;
    double winningScore = 0.0;

    if (buyScore > sellScore && buyScore > 0.5) {
      winningSide = 'BUY';
      winningScore = buyScore;
    } else if (sellScore > buyScore && sellScore > 0.5) {
      winningSide = 'SELL';
      winningScore = sellScore;
    }

    if (winningSide == null) {
      _log.info('No weighted consensus for $symbol (BUY score: ${buyScore.toFixed(2)}, SELL score: ${sellScore.toFixed(2)})');
      return null;
    }

    // Get signals for winning side
    final winningSignals = signals.where((s) => s.side == winningSide).toList();

    // Weighted average quantity
    double weightedQuantity = 0.0;
    double totalWeight = 0.0;

    for (final signal in winningSignals) {
      final weight = weights[signal.algorithmName] ?? 0.0;
      weightedQuantity += signal.quantity * weight;
      totalWeight += weight;
    }

    final avgQuantity = totalWeight > 0 ? weightedQuantity / totalWeight : winningSignals.first.quantity;

    // Build reason
    final contributors = winningSignals.map((s) => '${s.algorithmName}(${((weights[s.algorithmName] ?? 0) * 100).toFixed(0)}%)').join(', ');
    final reason = 'Multi-Strategy Weighted: $winningSide score ${(winningScore * 100).toFixed(1)}% ($contributors)';

    _log.info('✅ $symbol: $reason');

    return TradeSignal(
      side: winningSide,
      type: 'MARKET',
      quantity: avgQuantity,
      reason: reason,
      algorithmName: 'Strategy Composer (Weighted)',
      confidence: winningScore,
    );
  }

  /// Unanimous mode: all algorithms must agree
  TradeSignal? _composeByUnanimous(
    List<TradeSignal> signals,
    Map<String, TradeSignal> algorithmVotes,
    String symbol,
    double currentPrice,
  ) {
    // Check if all signals agree on side
    final firstSide = signals.first.side;
    final allAgree = signals.every((s) => s.side == firstSide);

    if (!allAgree) {
      final buys = signals.where((s) => s.side == 'BUY').length;
      final sells = signals.where((s) => s.side == 'SELL').length;
      _log.info('No unanimous agreement for $symbol (BUY: $buys, SELL: $sells)');
      return null;
    }

    // All agree - calculate averages
    final avgConfidence = signals.map((s) => s.confidence).reduce((a, b) => a + b) / signals.length;
    final avgQuantity = signals.map((s) => s.quantity).reduce((a, b) => a + b) / signals.length;

    // Build reason
    final voters = signals.map((s) => s.algorithmName).join(', ');
    final reason = 'Multi-Strategy Unanimous: All ${signals.length} algorithms agree $firstSide ($voters)';

    _log.info('✅ $symbol: $reason (confidence: ${(avgConfidence * 100).toFixed(1)}%)');

    return TradeSignal(
      side: firstSide,
      type: 'MARKET',
      quantity: avgQuantity,
      reason: reason,
      algorithmName: 'Strategy Composer (Unanimous)',
      confidence: avgConfidence,
    );
  }

  /// Get current status of all algorithms
  Map<String, dynamic> getStatus() {
    return {
      'mode': mode.toString().split('.').last,
      'algorithms': algorithms.map((a) => {
            'name': a.name,
            'active': a.active,
            'weight': weights[a.name],
          }).toList(),
      'requiredVotes': mode == CompositionMode.voting ? requiredVotes : null,
    };
  }
}

// Extension for number formatting
extension DoubleFormatting on double {
  String toFixed(int decimals) {
    return toStringAsFixed(decimals);
  }
}
