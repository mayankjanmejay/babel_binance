import 'dart:math';
import 'binance_base.dart';

class SimulatedConvert extends BinanceBase {
  final Random _random = Random();
  
  // Simulated asset prices in USDT
  final Map<String, double> _assetPrices = {
    'BTC': 95000.0,
    'ETH': 3200.0,
    'BNB': 650.0,
    'ADA': 0.45,
    'SOL': 180.0,
    'DOT': 8.5,
    'LINK': 15.2,
    'MATIC': 0.92,
    'UNI': 7.8,
    'AVAX': 42.0,
    'USDT': 1.0,
    'BUSD': 1.0,
    'USDC': 1.0,
  };

  SimulatedConvert({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  /// Simulates the convert quote request with realistic timing
  Future<Map<String, dynamic>> simulateGetQuote({
    required String fromAsset,
    required String toAsset,
    required double fromAmount,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateQuoteDelay();
    }

    final quoteId = _generateQuoteId();
    final ratio = _calculateConversionRatio(fromAsset, toAsset);
    final toAmount = fromAmount * ratio;
    final inverseRatio = 1 / ratio;

    return {
      'quoteId': quoteId,
      'ratio': ratio.toString(),
      'inverseRatio': inverseRatio.toString(),
      'validTime': 10, // Quote valid for 10 seconds (like real Binance)
      'toAmount': toAmount.toString(),
      'fromAmount': fromAmount.toString(),
    };
  }

  /// Simulates the actual conversion with processing time
  Future<Map<String, dynamic>> simulateAcceptQuote({
    required String quoteId,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateConversionDelay();
    }

    final orderId = _generateOrderId();
    final createTime = DateTime.now().millisecondsSinceEpoch;

    // Simulate success/failure rates (98% success rate)
    final isSuccessful = _random.nextDouble() < 0.98;
    
    if (!isSuccessful) {
      return {
        'orderId': orderId,
        'orderStatus': 'FAILED',
        'createTime': createTime,
        'errorCode': 'INSUFFICIENT_BALANCE',
        'errorMsg': 'Insufficient balance for conversion',
      };
    }

    return {
      'orderId': orderId,
      'orderStatus': 'SUCCESS',
      'createTime': createTime,
    };
  }

  /// Simulates checking the status of a conversion order
  Future<Map<String, dynamic>> simulateOrderStatus({
    required String orderId,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateStatusCheckDelay();
    }

    // Simulate order progression
    final orderAge = _random.nextInt(60000); // 0-60 seconds old
    final status = _getConversionStatusByAge(orderAge);

    return {
      'orderId': orderId,
      'orderStatus': status,
      'fromAsset': 'BTC',
      'fromAmount': '0.001',
      'toAsset': 'USDT',
      'toAmount': '95.0',
      'ratio': '95000.0',
      'inverseRatio': '0.0000105263',
      'createTime': DateTime.now().millisecondsSinceEpoch - orderAge,
      'fee': '0.095', // 0.1% fee
      'feeAsset': 'USDT',
    };
  }

  /// Simulates getting conversion history
  Future<Map<String, dynamic>> simulateConversionHistory({
    int? limit,
    int? startTime,
    int? endTime,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateHistoryDelay();
    }

    final historyLimit = limit ?? 100;
    final List<Map<String, dynamic>> conversions = [];
    
    for (int i = 0; i < historyLimit && i < 20; i++) {
      final ageMs = _random.nextInt(7 * 24 * 60 * 60 * 1000); // Up to 7 days old
      conversions.add({
        'orderId': _generateOrderId(),
        'orderStatus': 'SUCCESS',
        'fromAsset': _getRandomAsset(),
        'fromAmount': (_random.nextDouble() * 10).toStringAsFixed(8),
        'toAsset': _getRandomAsset(),
        'toAmount': (_random.nextDouble() * 1000).toStringAsFixed(8),
        'ratio': (_random.nextDouble() * 100000).toStringAsFixed(8),
        'inverseRatio': (_random.nextDouble() * 0.001).toStringAsFixed(8),
        'createTime': DateTime.now().millisecondsSinceEpoch - ageMs,
        'fee': (_random.nextDouble() * 10).toStringAsFixed(8),
        'feeAsset': 'USDT',
      });
    }

    return {
      'list': conversions,
      'startTime': startTime ?? (DateTime.now().millisecondsSinceEpoch - 7 * 24 * 60 * 60 * 1000),
      'endTime': endTime ?? DateTime.now().millisecondsSinceEpoch,
      'limit': historyLimit,
      'moreData': conversions.length >= historyLimit,
    };
  }

  // Private helper methods for realistic simulation

  Future<void> _simulateQuoteDelay() async {
    // Quote requests typically take 100-800ms
    final delay = 100 + _random.nextInt(700);
    await Future.delayed(Duration(milliseconds: delay));
  }

  Future<void> _simulateConversionDelay() async {
    // Actual conversions take 500ms-3 seconds
    final baseDelay = 500 + _random.nextInt(2500);
    
    // 2% chance of extended delay (5-10 seconds) due to liquidity issues
    final extendedDelay = _random.nextDouble() < 0.02 ? 5000 + _random.nextInt(5000) : 0;
    
    await Future.delayed(Duration(milliseconds: baseDelay + extendedDelay));
  }

  Future<void> _simulateStatusCheckDelay() async {
    // Status checks are fast: 50-200ms
    final delay = 50 + _random.nextInt(150);
    await Future.delayed(Duration(milliseconds: delay));
  }

  Future<void> _simulateHistoryDelay() async {
    // History queries take 200ms-1.5 seconds depending on data amount
    final delay = 200 + _random.nextInt(1300);
    await Future.delayed(Duration(milliseconds: delay));
  }

  double _calculateConversionRatio(String fromAsset, String toAsset) {
    final fromPrice = _assetPrices[fromAsset] ?? 1.0;
    final toPrice = _assetPrices[toAsset] ?? 1.0;
    
    // Add spread (0.1-0.3% depending on liquidity)
    final spreadPercentage = 0.001 + (_random.nextDouble() * 0.002); // 0.1-0.3%
    final baseRatio = fromPrice / toPrice;
    
    return baseRatio * (1 - spreadPercentage);
  }

  String _generateQuoteId() {
    return 'quote_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(9999)}';
  }

  String _generateOrderId() {
    return (3000000000 + _random.nextInt(999999999)).toString();
  }

  String _getConversionStatusByAge(int ageMs) {
    if (ageMs < 2000) return 'PENDING'; // First 2 seconds
    if (ageMs < 5000) return _random.nextDouble() < 0.8 ? 'PROCESS' : 'PENDING';
    return 'SUCCESS'; // After 5 seconds, assume success
  }

  String _getRandomAsset() {
    final assets = _assetPrices.keys.toList();
    return assets[_random.nextInt(assets.length)];
  }
}
