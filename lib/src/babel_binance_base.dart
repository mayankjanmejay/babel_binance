import './spot.dart';
import './simulated_convert.dart';
import './futures_usd.dart';
import './margin.dart';

class Binance {
  final Spot spot;
  final SimulatedConvert simulatedConvert;
  final FuturesUsd futuresUsd;
  final Margin margin;

  Binance({String? apiKey, String? apiSecret})
      : spot = Spot(apiKey: apiKey, apiSecret: apiSecret),
        simulatedConvert =
            SimulatedConvert(apiKey: apiKey, apiSecret: apiSecret),
        futuresUsd = FuturesUsd(apiKey: apiKey, apiSecret: apiSecret),
        margin = Margin(apiKey: apiKey, apiSecret: apiSecret);
}

/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
}
