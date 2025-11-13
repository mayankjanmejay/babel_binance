/// Tracks request weights from Binance headers
class WeightTracker {
  int _currentWeight = 0;
  DateTime _lastReset = DateTime.now();

  // Historical tracking for analysis
  final List<WeightSnapshot> _history = [];
  final int maxHistorySize;

  WeightTracker({this.maxHistorySize = 100});

  /// Update weight from response headers
  void updateFromHeaders(Map<String, String> headers) {
    // Binance returns these headers:
    // X-MBX-USED-WEIGHT-1M: current weight used
    // X-MBX-ORDER-COUNT-10S: order count in 10s window
    // X-MBX-ORDER-COUNT-1D: order count in 1 day window

    final usedWeight = headers['x-mbx-used-weight-1m'];
    if (usedWeight != null) {
      _currentWeight = int.tryParse(usedWeight) ?? _currentWeight;
      _recordSnapshot();
    }
  }

  /// Get current weight usage
  int get currentWeight => _currentWeight;

  /// Get weight usage percentage (out of 1200)
  double get usagePercent => (_currentWeight / 1200) * 100;

  /// Check if approaching rate limit
  bool isApproachingLimit({double threshold = 0.8}) {
    return usagePercent >= (threshold * 100);
  }

  /// Estimate time until weight resets
  Duration get timeUntilReset {
    final elapsed = DateTime.now().difference(_lastReset);
    final remaining = const Duration(minutes: 1) - elapsed;
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Record snapshot for analysis
  void _recordSnapshot() {
    _history.add(WeightSnapshot(
      weight: _currentWeight,
      timestamp: DateTime.now(),
    ));

    // Keep history size manageable
    if (_history.length > maxHistorySize) {
      _history.removeAt(0);
    }

    // Reset tracking every minute
    final now = DateTime.now();
    if (now.difference(_lastReset) >= const Duration(minutes: 1)) {
      _currentWeight = 0;
      _lastReset = now;
    }
  }

  /// Get weight history for analysis
  List<WeightSnapshot> get history => List.unmodifiable(_history);

  /// Get average weight usage over time
  double getAverageWeight() {
    if (_history.isEmpty) return 0;
    final sum = _history.fold<int>(0, (sum, s) => sum + s.weight);
    return sum / _history.length;
  }
}

class WeightSnapshot {
  final int weight;
  final DateTime timestamp;

  const WeightSnapshot({
    required this.weight,
    required this.timestamp,
  });
}
