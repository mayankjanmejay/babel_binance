import './spot.dart';
import './simulated_convert.dart';
import './futures_usd.dart';
import './margin.dart';
import './testnet.dart';
import './config/binance_config.dart';
import './logging/logger.dart';

class Binance {
  final Spot spot;
  final SimulatedConvert simulatedConvert;
  final FuturesUsd futuresUsd;
  final Margin margin;
  final TestnetSpot testnetSpot;
  final TestnetFuturesUsd testnetFutures;
  final BinanceConfig config;
  final BinanceLogger logger;

  Binance({
    String? apiKey,
    String? apiSecret,
    BinanceConfig? config,
    BinanceLogger? logger,
  }) : config = config ?? BinanceConfig.defaultConfig,
       logger = logger ?? const NoOpLogger(),
       spot = Spot(apiKey: apiKey, apiSecret: apiSecret),
       simulatedConvert =
           SimulatedConvert(apiKey: apiKey, apiSecret: apiSecret),
       futuresUsd = FuturesUsd(apiKey: apiKey, apiSecret: apiSecret),
       margin = Margin(apiKey: apiKey, apiSecret: apiSecret),
       testnetSpot = TestnetSpot(apiKey: apiKey, apiSecret: apiSecret),
       testnetFutures =
           TestnetFuturesUsd(apiKey: apiKey, apiSecret: apiSecret);

  /// Create a Binance instance specifically configured for testnet
  ///
  /// Use this when you want to test with real API endpoints but test data
  /// Get your testnet API keys from: https://testnet.binance.vision/
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

  /// Dispose and clean up resources
  void dispose() {
    spot.market.dispose();
    futuresUsd.dispose();
    margin.dispose();
    // Note: TestnetSpot and TestnetFuturesUsd don't have dispose methods
    // as they are composed of sub-classes that handle their own cleanup
  }
}

/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
}
