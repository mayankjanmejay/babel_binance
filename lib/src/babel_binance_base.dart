import './spot.dart';
import './simulated_convert.dart';
import './futures_usd.dart';
import './margin.dart';
import './testnet.dart';
import './config/binance_config.dart';
import './logging/logger.dart';
import './websocket/typed_websocket.dart';
import './websocket/websocket_events.dart';
import './websocket/websocket_config.dart';

/// Main entry point for the Binance API wrapper.
///
/// Provides access to all Binance API endpoints including:
/// - Spot trading (production)
/// - Futures USD-M trading (production)
/// - Margin trading (production)
/// - Testnet APIs (testnet.binance.vision)
/// - Demo Trading APIs (demo-api.binance.com)
///
/// Example usage:
/// ```dart
/// // Production trading
/// final binance = Binance(
///   apiKey: 'your-api-key',
///   apiSecret: 'your-api-secret',
/// );
///
/// // Testnet trading
/// final testnet = Binance.testnet(
///   apiKey: 'testnet-api-key',
///   apiSecret: 'testnet-api-secret',
/// );
///
/// // Demo trading (alternative testnet)
/// final demo = Binance.demo(
///   apiKey: 'demo-api-key',
///   apiSecret: 'demo-api-secret',
/// );
/// ```
class Binance {
  final Spot spot;
  final SimulatedConvert simulatedConvert;
  final FuturesUsd futuresUsd;
  final Margin margin;
  final TestnetSpot testnetSpot;
  final TestnetFuturesUsd testnetFutures;
  final TestnetFuturesCoinM testnetFuturesCoinM;
  final DemoSpot demoSpot;
  final DemoFuturesUsd demoFutures;
  final BinanceConfig config;
  final BinanceLogger logger;

  /// Typed WebSocket client for real-time data streams
  final TypedBinanceWebSocket websocket;

  /// WebSocket base URL for production
  static const String _productionWsUrl = 'wss://stream.binance.com:9443';

  /// WebSocket base URL for testnet
  static const String _testnetWsUrl = 'wss://testnet.binance.vision';

  Binance({
    String? apiKey,
    String? apiSecret,
    BinanceConfig? config,
    BinanceLogger? logger,
    String? wsBaseUrl,
    WebSocketConfig? wsConfig,
  })  : config = config ?? BinanceConfig.defaultConfig,
        logger = logger ?? const NoOpLogger(),
        spot = Spot(apiKey: apiKey, apiSecret: apiSecret),
        simulatedConvert =
            SimulatedConvert(apiKey: apiKey, apiSecret: apiSecret),
        futuresUsd = FuturesUsd(apiKey: apiKey, apiSecret: apiSecret),
        margin = Margin(apiKey: apiKey, apiSecret: apiSecret),
        testnetSpot = TestnetSpot(apiKey: apiKey, apiSecret: apiSecret),
        testnetFutures = TestnetFuturesUsd(apiKey: apiKey, apiSecret: apiSecret),
        testnetFuturesCoinM = TestnetFuturesCoinM(apiKey: apiKey, apiSecret: apiSecret),
        demoSpot = DemoSpot(apiKey: apiKey, apiSecret: apiSecret),
        demoFutures = DemoFuturesUsd(apiKey: apiKey, apiSecret: apiSecret),
        websocket = TypedBinanceWebSocket(
          baseUrl: wsBaseUrl ?? _productionWsUrl,
          config: wsConfig,
        );

  /// Create a Binance instance specifically configured for testnet
  ///
  /// Use this when you want to test with real API endpoints but test data.
  /// Get your testnet API keys from: https://testnet.binance.vision/
  ///
  /// Available endpoints:
  /// - REST API: https://testnet.binance.vision/api
  /// - WebSocket: wss://testnet.binance.vision
  ///
  /// Set [useProductionPrices] to true to use production WebSocket for
  /// real market prices while trading on testnet.
  factory Binance.testnet({
    required String apiKey,
    required String apiSecret,
    BinanceConfig? config,
    BinanceLogger? logger,
    bool useProductionPrices = false,
  }) {
    return Binance(
      apiKey: apiKey,
      apiSecret: apiSecret,
      config: config,
      logger: logger,
      wsBaseUrl: useProductionPrices ? _productionWsUrl : _testnetWsUrl,
    );
  }

  /// Create a Binance instance specifically configured for Demo Trading
  ///
  /// Use this when testnet.binance.vision is not accessible in your region.
  /// Get your demo API keys from your Binance account settings.
  ///
  /// Available endpoints:
  /// - REST API: https://demo-api.binance.com
  /// - WebSocket: wss://demo-stream.binance.com
  factory Binance.demo({
    required String apiKey,
    required String apiSecret,
    BinanceConfig? config,
    BinanceLogger? logger,
  }) {
    return Binance(
      apiKey: apiKey,
      apiSecret: apiSecret,
      config: config,
      logger: logger,
    );
  }

  // ══════════════════════════════════════════════════════════════════════════
  // CONVENIENCE WEBSOCKET METHODS
  // ══════════════════════════════════════════════════════════════════════════

  /// Get real-time price stream for multiple symbols
  ///
  /// Returns a stream of [MiniTickerEvent] for efficient price updates.
  /// Uses a single WebSocket connection for all symbols.
  ///
  /// Example:
  /// ```dart
  /// binance.priceStream(['BTCUSDT', 'ETHUSDT', 'SOLUSDT']).listen((event) {
  ///   print('${event.symbol}: ${event.close}');
  /// });
  /// ```
  Stream<MiniTickerEvent> priceStream(List<String> symbols) {
    return websocket.subscribeMiniTickerMulti(symbols);
  }

  /// Get real-time candlestick/kline stream for multiple symbols
  ///
  /// Returns a stream of [KlineEvent]. Check [KlineEvent.isClosed] to know
  /// when a candle is finalized.
  ///
  /// Supported intervals: 1s, 1m, 3m, 5m, 15m, 30m, 1h, 2h, 4h, 6h, 8h, 12h, 1d, 3d, 1w, 1M
  ///
  /// Example:
  /// ```dart
  /// binance.candleStream(['BTCUSDT'], '5m').listen((event) {
  ///   if (event.isClosed) {
  ///     print('Closed candle: ${event.symbol} O=${event.open} C=${event.close}');
  ///   }
  /// });
  /// ```
  Stream<KlineEvent> candleStream(List<String> symbols, String interval) {
    return websocket.subscribeKlineMulti(symbols, interval);
  }

  /// Get real-time aggregate trade stream for multiple symbols
  ///
  /// Returns a stream of [AggTradeEvent] for tick-level data.
  /// Useful for UHFT strategies that need individual trade information.
  ///
  /// Example:
  /// ```dart
  /// binance.tradeStream(['BTCUSDT']).listen((event) {
  ///   print('${event.isBuy ? "BUY" : "SELL"} ${event.quantity} @ ${event.price}');
  /// });
  /// ```
  Stream<AggTradeEvent> tradeStream(List<String> symbols) {
    return websocket.subscribeAggTradeMulti(symbols);
  }

  /// Get real-time book ticker stream for multiple symbols
  ///
  /// Returns a stream of [BookTickerEvent] with best bid/ask prices.
  ///
  /// Example:
  /// ```dart
  /// binance.bookTickerStream(['BTCUSDT']).listen((event) {
  ///   print('${event.symbol}: bid=${event.bestBidPrice} ask=${event.bestAskPrice}');
  /// });
  /// ```
  Stream<BookTickerEvent> bookTickerStream(List<String> symbols) {
    return websocket.subscribeBookTickerMulti(symbols);
  }

  /// Get real-time 24hr ticker stream for multiple symbols
  ///
  /// Returns a stream of [TickerEvent] with full market statistics.
  /// Use [priceStream] if you only need price updates (more efficient).
  ///
  /// Example:
  /// ```dart
  /// binance.tickerStream(['BTCUSDT']).listen((event) {
  ///   print('${event.symbol}: ${event.priceChangePercent}% volume=${event.baseVolume}');
  /// });
  /// ```
  Stream<TickerEvent> tickerStream(List<String> symbols) {
    return websocket.subscribeTickerMulti(symbols);
  }

  /// Dispose and clean up all resources
  ///
  /// Call this when you're done using the Binance client to properly
  /// close all HTTP connections, WebSocket connections, and release resources.
  Future<void> dispose() async {
    // Dispose WebSocket first
    await websocket.dispose();

    // Dispose spot trading resources
    spot.market.dispose();
    spot.trading.dispose();
    spot.userDataStream.dispose();

    // Dispose simulated convert
    simulatedConvert.dispose();

    // Dispose futures resources
    futuresUsd.dispose();

    // Dispose margin resources
    margin.dispose();

    // Dispose testnet resources (async due to WebSocket)
    await testnetSpot.dispose();

    // Dispose testnet futures
    testnetFutures.market.dispose();
    testnetFutures.trading.dispose();

    // Dispose testnet COIN-M futures
    testnetFuturesCoinM.market.dispose();
    testnetFuturesCoinM.trading.dispose();

    // Dispose demo resources (async due to WebSocket)
    await demoSpot.dispose();

    // Dispose demo futures
    demoFutures.market.dispose();
    demoFutures.trading.dispose();
  }
}
