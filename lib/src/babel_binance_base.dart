import './spot.dart';
import './simulated_convert.dart';
import './futures_usd.dart';
import './margin.dart';
import './testnet.dart';
import './config/binance_config.dart';
import './logging/logger.dart';

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

  Binance({
    String? apiKey,
    String? apiSecret,
    BinanceConfig? config,
    BinanceLogger? logger,
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
        demoFutures = DemoFuturesUsd(apiKey: apiKey, apiSecret: apiSecret);

  /// Create a Binance instance specifically configured for testnet
  ///
  /// Use this when you want to test with real API endpoints but test data.
  /// Get your testnet API keys from: https://testnet.binance.vision/
  ///
  /// Available endpoints:
  /// - REST API: https://testnet.binance.vision/api
  /// - WebSocket: wss://stream.testnet.binance.vision:9443
  factory Binance.testnet({
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

  /// Dispose and clean up resources
  Future<void> dispose() async {
    spot.market.dispose();
    futuresUsd.dispose();
    margin.dispose();
    await testnetSpot.dispose();
    await demoSpot.dispose();
  }
}

/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
}
