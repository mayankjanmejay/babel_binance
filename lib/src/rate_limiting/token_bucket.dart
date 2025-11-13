/// Token bucket algorithm for rate limiting
class TokenBucket {
  final int capacity;
  final Duration refillDuration;
  final int refillAmount;

  double _tokens;
  DateTime _lastRefill;

  TokenBucket({
    required this.capacity,
    required this.refillDuration,
    int? refillAmount,
  }) : _tokens = capacity.toDouble(),
       _lastRefill = DateTime.now(),
       refillAmount = refillAmount ?? capacity;

  /// Try to consume tokens. Returns true if successful.
  bool tryConsume(int tokens) {
    _refill();

    if (_tokens >= tokens) {
      _tokens -= tokens;
      return true;
    }

    return false;
  }

  /// Wait until tokens are available, then consume
  Future<void> consume(int tokens) async {
    while (!tryConsume(tokens)) {
      final waitTime = _calculateWaitTime(tokens);
      await Future.delayed(waitTime);
    }
  }

  /// Calculate how long to wait for tokens to be available
  Duration _calculateWaitTime(int tokensNeeded) {
    _refill();

    if (_tokens >= tokensNeeded) {
      return Duration.zero;
    }

    final tokensShort = tokensNeeded - _tokens;
    final refillsNeeded = (tokensShort / refillAmount).ceil();

    return refillDuration * refillsNeeded;
  }

  /// Refill tokens based on elapsed time
  void _refill() {
    final now = DateTime.now();
    final elapsed = now.difference(_lastRefill);

    if (elapsed >= refillDuration) {
      final refills = elapsed.inMilliseconds / refillDuration.inMilliseconds;
      final tokensToAdd = (refills * refillAmount).floor();

      _tokens = (_tokens + tokensToAdd).clamp(0, capacity.toDouble()).toDouble();
      _lastRefill = now;
    }
  }

  /// Get current available tokens
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
  void reset() {
    _tokens = capacity.toDouble();
    _lastRefill = DateTime.now();
  }
}

extension on double {
  double clamp(num min, num max) {
    if (this < min) return min.toDouble();
    if (this > max) return max.toDouble();
    return this;
  }
}
