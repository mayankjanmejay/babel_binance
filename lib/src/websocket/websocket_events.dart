/// Typed WebSocket event classes for Binance streams
///
/// These classes provide type-safe parsing of Binance WebSocket messages.
library;

/// Mini ticker event - lightweight price updates
///
/// Use this for trading bots that need real-time prices.
/// Format: symbol@miniTicker or !miniTicker@arr
class MiniTickerEvent {
  /// Event type (e.g., '24hrMiniTicker')
  final String eventType;

  /// Event time in milliseconds
  final int eventTime;

  /// Trading pair symbol
  final String symbol;

  /// Close/current price
  final double close;

  /// Open price (24h)
  final double open;

  /// High price (24h)
  final double high;

  /// Low price (24h)
  final double low;

  /// Total traded base asset volume
  final double baseVolume;

  /// Total traded quote asset volume
  final double quoteVolume;

  MiniTickerEvent({
    required this.eventType,
    required this.eventTime,
    required this.symbol,
    required this.close,
    required this.open,
    required this.high,
    required this.low,
    required this.baseVolume,
    required this.quoteVolume,
  });

  /// Parse from Binance WebSocket JSON
  factory MiniTickerEvent.fromJson(Map<String, dynamic> json) {
    return MiniTickerEvent(
      eventType: json['e'] as String? ?? '24hrMiniTicker',
      eventTime: json['E'] as int? ?? 0,
      symbol: json['s'] as String,
      close: double.parse(json['c'].toString()),
      open: double.parse(json['o'].toString()),
      high: double.parse(json['h'].toString()),
      low: double.parse(json['l'].toString()),
      baseVolume: double.parse(json['v'].toString()),
      quoteVolume: double.parse(json['q'].toString()),
    );
  }

  /// Get event time as DateTime
  DateTime get eventDateTime =>
      DateTime.fromMillisecondsSinceEpoch(eventTime);

  /// Alias for close price
  double get lastPrice => close;

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        'e': eventType,
        'E': eventTime,
        's': symbol,
        'c': close.toString(),
        'o': open.toString(),
        'h': high.toString(),
        'l': low.toString(),
        'v': baseVolume.toString(),
        'q': quoteVolume.toString(),
      };

  @override
  String toString() => 'MiniTickerEvent($symbol: $close)';
}

/// Full 24hr ticker event
///
/// Contains comprehensive market statistics.
/// Format: symbol@ticker or !ticker@arr
class TickerEvent {
  final String eventType;
  final int eventTime;
  final String symbol;
  final double priceChange;
  final double priceChangePercent;
  final double weightedAvgPrice;
  final double prevClosePrice;
  final double lastPrice;
  final double lastQty;
  final double bestBidPrice;
  final double bestBidQty;
  final double bestAskPrice;
  final double bestAskQty;
  final double openPrice;
  final double highPrice;
  final double lowPrice;
  final double baseVolume;
  final double quoteVolume;
  final int openTime;
  final int closeTime;
  final int firstTradeId;
  final int lastTradeId;
  final int tradeCount;

  TickerEvent({
    required this.eventType,
    required this.eventTime,
    required this.symbol,
    required this.priceChange,
    required this.priceChangePercent,
    required this.weightedAvgPrice,
    required this.prevClosePrice,
    required this.lastPrice,
    required this.lastQty,
    required this.bestBidPrice,
    required this.bestBidQty,
    required this.bestAskPrice,
    required this.bestAskQty,
    required this.openPrice,
    required this.highPrice,
    required this.lowPrice,
    required this.baseVolume,
    required this.quoteVolume,
    required this.openTime,
    required this.closeTime,
    required this.firstTradeId,
    required this.lastTradeId,
    required this.tradeCount,
  });

  factory TickerEvent.fromJson(Map<String, dynamic> json) {
    return TickerEvent(
      eventType: json['e'] as String? ?? '24hrTicker',
      eventTime: json['E'] as int? ?? 0,
      symbol: json['s'] as String,
      priceChange: double.parse(json['p'].toString()),
      priceChangePercent: double.parse(json['P'].toString()),
      weightedAvgPrice: double.parse(json['w'].toString()),
      prevClosePrice: double.parse(json['x'].toString()),
      lastPrice: double.parse(json['c'].toString()),
      lastQty: double.parse(json['Q'].toString()),
      bestBidPrice: double.parse(json['b'].toString()),
      bestBidQty: double.parse(json['B'].toString()),
      bestAskPrice: double.parse(json['a'].toString()),
      bestAskQty: double.parse(json['A'].toString()),
      openPrice: double.parse(json['o'].toString()),
      highPrice: double.parse(json['h'].toString()),
      lowPrice: double.parse(json['l'].toString()),
      baseVolume: double.parse(json['v'].toString()),
      quoteVolume: double.parse(json['q'].toString()),
      openTime: json['O'] as int? ?? 0,
      closeTime: json['C'] as int? ?? 0,
      firstTradeId: json['F'] as int? ?? 0,
      lastTradeId: json['L'] as int? ?? 0,
      tradeCount: json['n'] as int? ?? 0,
    );
  }

  DateTime get eventDateTime =>
      DateTime.fromMillisecondsSinceEpoch(eventTime);

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        'e': eventType,
        'E': eventTime,
        's': symbol,
        'p': priceChange.toString(),
        'P': priceChangePercent.toString(),
        'w': weightedAvgPrice.toString(),
        'x': prevClosePrice.toString(),
        'c': lastPrice.toString(),
        'Q': lastQty.toString(),
        'b': bestBidPrice.toString(),
        'B': bestBidQty.toString(),
        'a': bestAskPrice.toString(),
        'A': bestAskQty.toString(),
        'o': openPrice.toString(),
        'h': highPrice.toString(),
        'l': lowPrice.toString(),
        'v': baseVolume.toString(),
        'q': quoteVolume.toString(),
        'O': openTime,
        'C': closeTime,
        'F': firstTradeId,
        'L': lastTradeId,
        'n': tradeCount,
      };

  @override
  String toString() =>
      'TickerEvent($symbol: $lastPrice, ${priceChangePercent.toStringAsFixed(2)}%)';
}

/// Kline/Candlestick event
///
/// Real-time candle updates. Check `isClosed` to know when a candle is finalized.
/// Format: symbol@kline_interval
class KlineEvent {
  final String eventType;
  final int eventTime;
  final String symbol;

  /// Kline data
  final int openTime;
  final int closeTime;
  final String interval;
  final int firstTradeId;
  final int lastTradeId;
  final double open;
  final double high;
  final double low;
  final double close;
  final double volume;
  final double quoteVolume;
  final int tradeCount;

  /// Is this candle closed/finalized?
  final bool isClosed;

  /// Taker buy base asset volume
  final double takerBuyBaseVolume;

  /// Taker buy quote asset volume
  final double takerBuyQuoteVolume;

  KlineEvent({
    required this.eventType,
    required this.eventTime,
    required this.symbol,
    required this.openTime,
    required this.closeTime,
    required this.interval,
    required this.firstTradeId,
    required this.lastTradeId,
    required this.open,
    required this.high,
    required this.low,
    required this.close,
    required this.volume,
    required this.quoteVolume,
    required this.tradeCount,
    required this.isClosed,
    required this.takerBuyBaseVolume,
    required this.takerBuyQuoteVolume,
  });

  factory KlineEvent.fromJson(Map<String, dynamic> json) {
    final k = json['k'] as Map<String, dynamic>;
    return KlineEvent(
      eventType: json['e'] as String? ?? 'kline',
      eventTime: json['E'] as int? ?? 0,
      symbol: json['s'] as String,
      openTime: k['t'] as int,
      closeTime: k['T'] as int,
      interval: k['i'] as String,
      firstTradeId: k['f'] as int? ?? 0,
      lastTradeId: k['L'] as int? ?? 0,
      open: double.parse(k['o'].toString()),
      high: double.parse(k['h'].toString()),
      low: double.parse(k['l'].toString()),
      close: double.parse(k['c'].toString()),
      volume: double.parse(k['v'].toString()),
      quoteVolume: double.parse(k['q'].toString()),
      tradeCount: k['n'] as int? ?? 0,
      isClosed: k['x'] as bool? ?? false,
      takerBuyBaseVolume: double.parse(k['V'].toString()),
      takerBuyQuoteVolume: double.parse(k['Q'].toString()),
    );
  }

  DateTime get openDateTime => DateTime.fromMillisecondsSinceEpoch(openTime);
  DateTime get closeDateTime => DateTime.fromMillisecondsSinceEpoch(closeTime);
  DateTime get eventDateTime => DateTime.fromMillisecondsSinceEpoch(eventTime);

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        'e': eventType,
        'E': eventTime,
        's': symbol,
        'k': {
          't': openTime,
          'T': closeTime,
          'i': interval,
          'f': firstTradeId,
          'L': lastTradeId,
          'o': open.toString(),
          'h': high.toString(),
          'l': low.toString(),
          'c': close.toString(),
          'v': volume.toString(),
          'q': quoteVolume.toString(),
          'n': tradeCount,
          'x': isClosed,
          'V': takerBuyBaseVolume.toString(),
          'Q': takerBuyQuoteVolume.toString(),
        },
      };

  @override
  String toString() =>
      'KlineEvent($symbol $interval: O=$open H=$high L=$low C=$close, closed=$isClosed)';
}

/// Aggregate trade event
///
/// Compressed/aggregated trades for tick-level data.
/// Format: symbol@aggTrade
class AggTradeEvent {
  final String eventType;
  final int eventTime;
  final String symbol;

  /// Aggregate trade ID
  final int aggregateTradeId;

  /// Price
  final double price;

  /// Quantity
  final double quantity;

  /// First trade ID
  final int firstTradeId;

  /// Last trade ID
  final int lastTradeId;

  /// Trade time
  final int tradeTime;

  /// Is the buyer the market maker?
  final bool isBuyerMaker;

  AggTradeEvent({
    required this.eventType,
    required this.eventTime,
    required this.symbol,
    required this.aggregateTradeId,
    required this.price,
    required this.quantity,
    required this.firstTradeId,
    required this.lastTradeId,
    required this.tradeTime,
    required this.isBuyerMaker,
  });

  factory AggTradeEvent.fromJson(Map<String, dynamic> json) {
    return AggTradeEvent(
      eventType: json['e'] as String? ?? 'aggTrade',
      eventTime: json['E'] as int? ?? 0,
      symbol: json['s'] as String,
      aggregateTradeId: json['a'] as int,
      price: double.parse(json['p'].toString()),
      quantity: double.parse(json['q'].toString()),
      firstTradeId: json['f'] as int,
      lastTradeId: json['l'] as int,
      tradeTime: json['T'] as int,
      isBuyerMaker: json['m'] as bool? ?? false,
    );
  }

  DateTime get tradeDateTime => DateTime.fromMillisecondsSinceEpoch(tradeTime);
  DateTime get eventDateTime => DateTime.fromMillisecondsSinceEpoch(eventTime);

  /// Trade value (price * quantity)
  double get value => price * quantity;

  /// Is this a buy order? (opposite of isBuyerMaker)
  bool get isBuy => !isBuyerMaker;

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        'e': eventType,
        'E': eventTime,
        's': symbol,
        'a': aggregateTradeId,
        'p': price.toString(),
        'q': quantity.toString(),
        'f': firstTradeId,
        'l': lastTradeId,
        'T': tradeTime,
        'm': isBuyerMaker,
      };

  @override
  String toString() =>
      'AggTradeEvent($symbol: ${isBuy ? "BUY" : "SELL"} $quantity @ $price)';
}

/// Individual trade event
///
/// Raw trade data (not aggregated).
/// Format: symbol@trade
class TradeEvent {
  final String eventType;
  final int eventTime;
  final String symbol;
  final int tradeId;
  final double price;
  final double quantity;
  final int buyerOrderId;
  final int sellerOrderId;
  final int tradeTime;
  final bool isBuyerMaker;

  TradeEvent({
    required this.eventType,
    required this.eventTime,
    required this.symbol,
    required this.tradeId,
    required this.price,
    required this.quantity,
    required this.buyerOrderId,
    required this.sellerOrderId,
    required this.tradeTime,
    required this.isBuyerMaker,
  });

  factory TradeEvent.fromJson(Map<String, dynamic> json) {
    return TradeEvent(
      eventType: json['e'] as String? ?? 'trade',
      eventTime: json['E'] as int? ?? 0,
      symbol: json['s'] as String,
      tradeId: json['t'] as int,
      price: double.parse(json['p'].toString()),
      quantity: double.parse(json['q'].toString()),
      buyerOrderId: json['b'] as int,
      sellerOrderId: json['a'] as int,
      tradeTime: json['T'] as int,
      isBuyerMaker: json['m'] as bool? ?? false,
    );
  }

  DateTime get tradeDateTime => DateTime.fromMillisecondsSinceEpoch(tradeTime);

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        'e': eventType,
        'E': eventTime,
        's': symbol,
        't': tradeId,
        'p': price.toString(),
        'q': quantity.toString(),
        'b': buyerOrderId,
        'a': sellerOrderId,
        'T': tradeTime,
        'm': isBuyerMaker,
      };

  @override
  String toString() => 'TradeEvent($symbol: $quantity @ $price)';
}

/// Book ticker event (best bid/ask)
///
/// Real-time best bid and ask prices.
/// Format: symbol@bookTicker or !bookTicker
class BookTickerEvent {
  final int updateId;
  final String symbol;
  final double bestBidPrice;
  final double bestBidQty;
  final double bestAskPrice;
  final double bestAskQty;

  BookTickerEvent({
    required this.updateId,
    required this.symbol,
    required this.bestBidPrice,
    required this.bestBidQty,
    required this.bestAskPrice,
    required this.bestAskQty,
  });

  factory BookTickerEvent.fromJson(Map<String, dynamic> json) {
    return BookTickerEvent(
      updateId: json['u'] as int? ?? 0,
      symbol: json['s'] as String,
      bestBidPrice: double.parse(json['b'].toString()),
      bestBidQty: double.parse(json['B'].toString()),
      bestAskPrice: double.parse(json['a'].toString()),
      bestAskQty: double.parse(json['A'].toString()),
    );
  }

  /// Spread between best ask and best bid
  double get spread => bestAskPrice - bestBidPrice;

  /// Spread as percentage of mid price
  double get spreadPercent {
    final mid = (bestAskPrice + bestBidPrice) / 2;
    return mid > 0 ? (spread / mid) * 100 : 0;
  }

  /// Mid price
  double get midPrice => (bestAskPrice + bestBidPrice) / 2;

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        'u': updateId,
        's': symbol,
        'b': bestBidPrice.toString(),
        'B': bestBidQty.toString(),
        'a': bestAskPrice.toString(),
        'A': bestAskQty.toString(),
      };

  @override
  String toString() =>
      'BookTickerEvent($symbol: bid=$bestBidPrice ask=$bestAskPrice)';
}

/// Price level for order book
class PriceLevel {
  final double price;
  final double quantity;

  const PriceLevel({required this.price, required this.quantity});

  factory PriceLevel.fromList(List<dynamic> data) {
    return PriceLevel(
      price: double.parse(data[0].toString()),
      quantity: double.parse(data[1].toString()),
    );
  }

  /// Convert to list format
  List<String> toList() => [price.toString(), quantity.toString()];

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        'price': price.toString(),
        'quantity': quantity.toString(),
      };

  @override
  String toString() => 'PriceLevel($price: $quantity)';
}

/// Depth/Order book event
///
/// Order book updates.
/// Format: symbol@depth or symbol@depthN
class DepthEvent {
  final String eventType;
  final int eventTime;
  final String symbol;
  final int firstUpdateId;
  final int lastUpdateId;
  final List<PriceLevel> bids;
  final List<PriceLevel> asks;

  DepthEvent({
    required this.eventType,
    required this.eventTime,
    required this.symbol,
    required this.firstUpdateId,
    required this.lastUpdateId,
    required this.bids,
    required this.asks,
  });

  factory DepthEvent.fromJson(Map<String, dynamic> json) {
    return DepthEvent(
      eventType: json['e'] as String? ?? 'depthUpdate',
      eventTime: json['E'] as int? ?? 0,
      symbol: json['s'] as String,
      firstUpdateId: json['U'] as int? ?? 0,
      lastUpdateId: json['u'] as int? ?? 0,
      bids: (json['b'] as List<dynamic>)
          .map((b) => PriceLevel.fromList(b as List<dynamic>))
          .toList(),
      asks: (json['a'] as List<dynamic>)
          .map((a) => PriceLevel.fromList(a as List<dynamic>))
          .toList(),
    );
  }

  /// Best bid price
  double? get bestBid => bids.isNotEmpty ? bids.first.price : null;

  /// Best ask price
  double? get bestAsk => asks.isNotEmpty ? asks.first.price : null;

  /// Spread
  double? get spread =>
      bestBid != null && bestAsk != null ? bestAsk! - bestBid! : null;

  /// Convert to JSON map
  Map<String, dynamic> toJson() => {
        'e': eventType,
        'E': eventTime,
        's': symbol,
        'U': firstUpdateId,
        'u': lastUpdateId,
        'b': bids.map((b) => b.toList()).toList(),
        'a': asks.map((a) => a.toList()).toList(),
      };

  @override
  String toString() =>
      'DepthEvent($symbol: ${bids.length} bids, ${asks.length} asks)';
}

/// Combined stream wrapper
///
/// Used when subscribing to multiple streams via combined endpoint.
class CombinedStreamEvent<T> {
  final String stream;
  final T data;

  CombinedStreamEvent({required this.stream, required this.data});

  factory CombinedStreamEvent.fromJson(
    Map<String, dynamic> json,
    T Function(Map<String, dynamic>) parser,
  ) {
    return CombinedStreamEvent(
      stream: json['stream'] as String,
      data: parser(json['data'] as Map<String, dynamic>),
    );
  }
}
