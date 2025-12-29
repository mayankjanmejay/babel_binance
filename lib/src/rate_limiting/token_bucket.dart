import 'dart:async';

/// Token bucket algorithm for rate limiting with thread-safety
///
/// Uses async locking to prevent race conditions when multiple
/// concurrent requests try to consume tokens.
class TokenBucket {
  final int capacity;
  final Duration refillDuration;
  final int refillAmount;

  double _tokens;
  DateTime _lastRefill;

  // Lock mechanism for thread-safety
  Completer<void>? _lock;

  TokenBucket({
    required this.capacity,
    required this.refillDuration,
    int? refillAmount,
  })  : _tokens = capacity.toDouble(),
        _lastRefill = DateTime.now(),
        refillAmount = refillAmount ?? capacity;

  /// Acquire lock for thread-safe operations
  Future<void> _acquireLock() async {
    while (_lock != null) {
      await _lock!.future;
    }
    _lock = Completer<void>();
  }

  /// Release lock
  void _releaseLock() {
    final lock = _lock;
    _lock = null;
    lock?.complete();
  }

  /// Try to consume tokens. Returns true if successful.
  /// Thread-safe implementation using async lock.
  Future<bool> tryConsume(int tokens) async {
    await _acquireLock();
    try {
      _refill();

      if (_tokens >= tokens) {
        _tokens -= tokens;
        return true;
      }

      return false;
    } finally {
      _releaseLock();
    }
  }

  /// Synchronous version - use only when you're sure no concurrent access
  bool tryConsumeSync(int tokens) {
    _refill();

    if (_tokens >= tokens) {
      _tokens -= tokens;
      return true;
    }

    return false;
  }

  /// Wait until tokens are available, then consume
  Future<void> consume(int tokens) async {
    while (!(await tryConsume(tokens))) {
      final waitTime = await _calculateWaitTime(tokens);
      await Future.delayed(waitTime);
    }
  }

  /// Calculate how long to wait for tokens to be available
  Future<Duration> _calculateWaitTime(int tokensNeeded) async {
    await _acquireLock();
    try {
      _refill();

      if (_tokens >= tokensNeeded) {
        return Duration.zero;
      }

      final tokensShort = tokensNeeded - _tokens;
      final refillsNeeded = (tokensShort / refillAmount).ceil();

      return refillDuration * refillsNeeded;
    } finally {
      _releaseLock();
    }
  }

  /// Refill tokens based on elapsed time
  void _refill() {
    final now = DateTime.now();
    final elapsed = now.difference(_lastRefill);

    if (elapsed >= refillDuration) {
      final refills = elapsed.inMilliseconds / refillDuration.inMilliseconds;
      final tokensToAdd = (refills * refillAmount).floor();

      _tokens =
          (_tokens + tokensToAdd).clamp(0, capacity.toDouble()).toDouble();
      _lastRefill = now;
    }
  }

  /// Get current available tokens (thread-safe)
  Future<double> getAvailableTokens() async {
    await _acquireLock();
    try {
      _refill();
      return _tokens;
    } finally {
      _releaseLock();
    }
  }

  /// Get current available tokens (synchronous - use with caution)
  double get availableTokens {
    _refill();
    return _tokens;
  }

  /// Get percentage of capacity used
  double get usagePercent {
    _refill();
    return (1 - (_tokens / capacity)) * 100;
  }

  /// Reset bucket to full capacity
  Future<void> reset() async {
    await _acquireLock();
    try {
      _tokens = capacity.toDouble();
      _lastRefill = DateTime.now();
    } finally {
      _releaseLock();
    }
  }

  /// Reset bucket synchronously
  void resetSync() {
    _tokens = capacity.toDouble();
    _lastRefill = DateTime.now();
  }
}
