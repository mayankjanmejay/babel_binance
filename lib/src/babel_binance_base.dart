import './spot.dart';

// TODO: Put public facing types in this file.

/// Checks if you are awesome. Spoiler: you are.
class Awesome {
  bool get isAwesome => true;
}

class Binance {
  final Spot spot;

  Binance({String? apiKey, String? apiSecret})
      : spot = Spot(apiKey: apiKey, apiSecret: apiSecret);
}
