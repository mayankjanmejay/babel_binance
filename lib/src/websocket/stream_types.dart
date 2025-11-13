/// Types of WebSocket streams available
enum StreamType {
  /// User data stream (requires listen key)
  userData,

  /// Aggregate trade stream
  aggTrade,

  /// Trade stream
  trade,

  /// Kline/Candlestick stream
  kline,

  /// Individual symbol mini ticker
  miniTicker,

  /// All market mini tickers
  allMarketMiniTicker,

  /// Individual symbol ticker
  ticker,

  /// All market tickers
  allMarketTicker,

  /// Individual symbol book ticker
  bookTicker,

  /// All book tickers
  allMarketBookTicker,

  /// Partial book depth
  partialBookDepth,

  /// Diff depth stream
  diffDepth,
}

/// WebSocket stream configuration
class StreamConfig {
  final StreamType type;
  final String? symbol;
  final String? interval; // For kline streams
  final int? levels; // For depth streams
  final int? updateSpeed; // For depth streams (100ms or 1000ms)

  const StreamConfig({
    required this.type,
    this.symbol,
    this.interval,
    this.levels,
    this.updateSpeed,
  });

  /// Build stream name for Binance WebSocket
  String get streamName {
    switch (type) {
      case StreamType.userData:
        throw ArgumentError('User data stream requires listen key');

      case StreamType.aggTrade:
        return '${symbol!.toLowerCase()}@aggTrade';

      case StreamType.trade:
        return '${symbol!.toLowerCase()}@trade';

      case StreamType.kline:
        return '${symbol!.toLowerCase()}@kline_$interval';

      case StreamType.miniTicker:
        return '${symbol!.toLowerCase()}@miniTicker';

      case StreamType.allMarketMiniTicker:
        return '!miniTicker@arr';

      case StreamType.ticker:
        return '${symbol!.toLowerCase()}@ticker';

      case StreamType.allMarketTicker:
        return '!ticker@arr';

      case StreamType.bookTicker:
        return '${symbol!.toLowerCase()}@bookTicker';

      case StreamType.allMarketBookTicker:
        return '!bookTicker';

      case StreamType.partialBookDepth:
        final speed = updateSpeed == 100 ? '@100ms' : '';
        return '${symbol!.toLowerCase()}@depth$levels$speed';

      case StreamType.diffDepth:
        final speed = updateSpeed == 100 ? '@100ms' : '';
        return '${symbol!.toLowerCase()}@depth$speed';
    }
  }

  /// Factory constructors for common streams
  factory StreamConfig.aggTrade(String symbol) =>
      StreamConfig(type: StreamType.aggTrade, symbol: symbol);

  factory StreamConfig.kline(String symbol, String interval) =>
      StreamConfig(type: StreamType.kline, symbol: symbol, interval: interval);

  factory StreamConfig.ticker(String symbol) =>
      StreamConfig(type: StreamType.ticker, symbol: symbol);

  factory StreamConfig.depth(String symbol, {int levels = 20, int? updateSpeed}) =>
      StreamConfig(
        type: StreamType.partialBookDepth,
        symbol: symbol,
        levels: levels,
        updateSpeed: updateSpeed,
      );
}
