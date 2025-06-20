import 'dart:math';
import 'binance_base.dart';

class Margin extends BinanceBase {
  final MarginMarket market;
  final MarginTrading trading;
  final SimulatedMarginTrading simulatedTrading;

  Margin({String? apiKey, String? apiSecret})
      : market = MarginMarket(apiKey: apiKey, apiSecret: apiSecret),
        trading = MarginTrading(apiKey: apiKey, apiSecret: apiSecret),
        simulatedTrading =
            SimulatedMarginTrading(apiKey: apiKey, apiSecret: apiSecret),
        super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getMarginAccountInfo({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/margin/account', params: params);
  }
}

class MarginMarket extends BinanceBase {
  MarginMarket({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getMarginPriceIndex(String symbol) {
    return sendRequest('GET', '/sapi/v1/margin/priceIndex',
        params: {'symbol': symbol});
  }

  Future<Map<String, dynamic>> getMarginOrderBook(String symbol,
      {int limit = 100}) {
    return sendRequest('GET', '/api/v3/depth',
        params: {'symbol': symbol, 'limit': limit});
  }

  Future<Map<String, dynamic>> getMarginAsset(String asset) {
    return sendRequest('GET', '/sapi/v1/margin/asset',
        params: {'asset': asset});
  }
}

class MarginTrading extends BinanceBase {
  MarginTrading({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> marginBorrow({
    required String asset,
    required double amount,
    String? isIsolated,
    String? symbol,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'asset': asset,
      'amount': amount,
    };
    if (isIsolated != null) params['isIsolated'] = isIsolated;
    if (symbol != null) params['symbol'] = symbol;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/margin/loan', params: params);
  }

  Future<Map<String, dynamic>> marginRepay({
    required String asset,
    required double amount,
    String? isIsolated,
    String? symbol,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'asset': asset,
      'amount': amount,
    };
    if (isIsolated != null) params['isIsolated'] = isIsolated;
    if (symbol != null) params['symbol'] = symbol;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/margin/repay', params: params);
  }

  Future<Map<String, dynamic>> placeMarginOrder({
    required String symbol,
    required String side,
    required String type,
    required double quantity,
    double? price,
    String? timeInForce,
    String? isIsolated,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'symbol': symbol,
      'side': side,
      'type': type,
      'quantity': quantity,
    };
    if (price != null) params['price'] = price;
    if (timeInForce != null) params['timeInForce'] = timeInForce;
    if (isIsolated != null) params['isIsolated'] = isIsolated;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/margin/order', params: params);
  }
}

class SimulatedMarginTrading {
  final String? apiKey;
  final String? apiSecret;
  final Random _random = Random();

  // Simulated margin account balances
  final Map<String, Map<String, double>> _marginBalances = {
    'BTC': {'free': 0.5, 'locked': 0.0, 'borrowed': 0.0, 'interest': 0.0},
    'ETH': {'free': 5.0, 'locked': 0.0, 'borrowed': 0.0, 'interest': 0.0},
    'USDT': {'free': 10000.0, 'locked': 0.0, 'borrowed': 0.0, 'interest': 0.0},
    'BNB': {'free': 20.0, 'locked': 0.0, 'borrowed': 0.0, 'interest': 0.0},
  };

  // Interest rates for borrowing (annual rates)
  final Map<String, double> _interestRates = {
    'BTC': 0.02, // 2% annual
    'ETH': 0.025, // 2.5% annual
    'USDT': 0.06, // 6% annual
    'BNB': 0.03, // 3% annual
  };

  SimulatedMarginTrading({this.apiKey, this.apiSecret});

  Future<Map<String, dynamic>> simulateBorrow({
    required String asset,
    required double amount,
    String? isIsolated,
    String? symbol,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateBorrowDelay();
    }

    // Check if borrowing is allowed for this asset
    if (!_marginBalances.containsKey(asset)) {
      throw Exception('Asset $asset is not supported for margin borrowing');
    }

    // Simulate borrowing limits
    final maxBorrowable = _calculateMaxBorrowable(asset);
    if (amount > maxBorrowable) {
      throw Exception(
          'Insufficient collateral to borrow $amount $asset. Max: $maxBorrowable');
    }

    final tranId = _generateTransactionId();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Update simulated balances
    _marginBalances[asset]!['borrowed'] =
        (_marginBalances[asset]!['borrowed']! + amount);
    _marginBalances[asset]!['free'] =
        (_marginBalances[asset]!['free']! + amount);

    return {
      'tranId': tranId,
      'asset': asset,
      'amount': amount.toString(),
      'type': 'BORROW',
      'timestamp': currentTime,
      'status': 'CONFIRMED',
      'isolatedSymbol': isIsolated == 'TRUE' ? symbol : null,
    };
  }

  Future<Map<String, dynamic>> simulateRepay({
    required String asset,
    required double amount,
    String? isIsolated,
    String? symbol,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateRepayDelay();
    }

    if (!_marginBalances.containsKey(asset)) {
      throw Exception('Asset $asset not found in margin account');
    }

    final borrowed = _marginBalances[asset]!['borrowed']!;
    if (amount > borrowed) {
      throw Exception('Cannot repay $amount $asset. Only borrowed: $borrowed');
    }

    final tranId = _generateTransactionId();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Update simulated balances
    _marginBalances[asset]!['borrowed'] = (borrowed - amount);
    _marginBalances[asset]!['free'] =
        (_marginBalances[asset]!['free']! - amount);

    return {
      'tranId': tranId,
      'asset': asset,
      'amount': amount.toString(),
      'type': 'REPAY',
      'timestamp': currentTime,
      'status': 'CONFIRMED',
      'isolatedSymbol': isIsolated == 'TRUE' ? symbol : null,
    };
  }

  Future<Map<String, dynamic>> simulatePlaceOrder({
    required String symbol,
    required String side,
    required String type,
    required double quantity,
    double? price,
    String? timeInForce,
    String? isIsolated,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateOrderDelay();
    }

    final orderId = _generateOrderId();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Simulate margin requirement check
    final marginRequired =
        _calculateMarginRequired(symbol, side, quantity, price);
    final availableMargin = _calculateAvailableMargin();

    if (marginRequired > availableMargin) {
      throw Exception(
          'Insufficient margin. Required: $marginRequired, Available: $availableMargin');
    }

    // Get simulated price
    final executionPrice = price ?? _getMarketPrice(symbol);
    final orderStatus = _determineOrderStatus(type, price, executionPrice);

    return {
      'symbol': symbol,
      'orderId': orderId,
      'clientOrderId': 'margin_sim_${DateTime.now().millisecondsSinceEpoch}',
      'transactTime': currentTime,
      'price': executionPrice.toString(),
      'origQty': quantity.toString(),
      'executedQty': orderStatus == 'FILLED' ? quantity.toString() : '0',
      'cummulativeQuoteQty': orderStatus == 'FILLED'
          ? (quantity * executionPrice).toString()
          : '0',
      'status': orderStatus,
      'timeInForce': timeInForce ?? 'GTC',
      'type': type,
      'side': side,
      'marginBuyBorrowAmount':
          side == 'BUY' ? (quantity * executionPrice * 0.5).toString() : '0',
      'marginBuyBorrowAsset': side == 'BUY' ? 'USDT' : '',
      'isIsolated': isIsolated == 'TRUE',
      'fills': orderStatus == 'FILLED'
          ? [
              {
                'price': executionPrice.toString(),
                'qty': quantity.toString(),
                'commission': (quantity * executionPrice * 0.001).toString(),
                'commissionAsset':
                    side == 'BUY' ? symbol.replaceAll('USDT', '') : 'USDT',
                'tradeId': _generateTradeId(),
              }
            ]
          : [],
    };
  }

  Future<Map<String, dynamic>> simulateGetMarginAccount({
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateStatusCheckDelay();
    }

    final totalAssetOfBtc = _calculateTotalAssetInBtc();
    final totalLiabilityOfBtc = _calculateTotalLiabilityInBtc();
    final marginLevel = totalAssetOfBtc /
        (totalLiabilityOfBtc + 0.000001); // Avoid division by zero

    final userAssets = _marginBalances.entries.map((entry) {
      final asset = entry.key;
      final balances = entry.value;
      return {
        'asset': asset,
        'borrowed': balances['borrowed'].toString(),
        'free': balances['free'].toString(),
        'interest': balances['interest'].toString(),
        'locked': balances['locked'].toString(),
        'netAsset': (balances['free']! - balances['borrowed']!).toString(),
      };
    }).toList();

    return {
      'borrowEnabled': true,
      'marginLevel': marginLevel.toStringAsFixed(4),
      'totalAssetOfBtc': totalAssetOfBtc.toStringAsFixed(8),
      'totalLiabilityOfBtc': totalLiabilityOfBtc.toStringAsFixed(8),
      'totalNetAssetOfBtc':
          (totalAssetOfBtc - totalLiabilityOfBtc).toStringAsFixed(8),
      'tradeEnabled': true,
      'transferEnabled': true,
      'userAssets': userAssets,
    };
  }

  // Helper methods for margin simulation
  Future<void> _simulateBorrowDelay() async {
    final delay = 200 + _random.nextInt(800); // 200-1000ms
    await Future.delayed(Duration(milliseconds: delay));
  }

  Future<void> _simulateRepayDelay() async {
    final delay = 150 + _random.nextInt(600); // 150-750ms
    await Future.delayed(Duration(milliseconds: delay));
  }

  Future<void> _simulateOrderDelay() async {
    final delay = 100 + _random.nextInt(400); // 100-500ms
    await Future.delayed(Duration(milliseconds: delay));
  }

  Future<void> _simulateStatusCheckDelay() async {
    final delay = 50 + _random.nextInt(150); // 50-200ms
    await Future.delayed(Duration(milliseconds: delay));
  }

  double _calculateMaxBorrowable(String asset) {
    // Simple simulation: can borrow up to 3x collateral value
    final collateralValue = _calculateCollateralValue();
    final assetPrice = _getAssetPrice(asset);
    return (collateralValue * 3.0) / assetPrice;
  }

  double _calculateCollateralValue() {
    double totalValue = 0;
    for (final entry in _marginBalances.entries) {
      final asset = entry.key;
      final balance = entry.value['free']!;
      final price = _getAssetPrice(asset);
      totalValue += balance * price;
    }
    return totalValue;
  }

  double _calculateMarginRequired(
      String symbol, String side, double quantity, double? price) {
    final executionPrice = price ?? _getMarketPrice(symbol);
    return (quantity * executionPrice) * 0.1; // 10x leverage = 10% margin
  }

  double _calculateAvailableMargin() {
    return _calculateCollateralValue() * 0.8; // 80% of collateral can be used
  }

  double _calculateTotalAssetInBtc() {
    final btcPrice = _getAssetPrice('BTC');
    double totalBtc = 0;

    for (final entry in _marginBalances.entries) {
      final asset = entry.key;
      final free = entry.value['free']!;
      final assetPrice = _getAssetPrice(asset);
      totalBtc += (free * assetPrice) / btcPrice;
    }

    return totalBtc;
  }

  double _calculateTotalLiabilityInBtc() {
    final btcPrice = _getAssetPrice('BTC');
    double totalBtc = 0;

    for (final entry in _marginBalances.entries) {
      final asset = entry.key;
      final borrowed = entry.value['borrowed']!;
      final interest = entry.value['interest']!;
      final assetPrice = _getAssetPrice(asset);
      totalBtc += ((borrowed + interest) * assetPrice) / btcPrice;
    }

    return totalBtc;
  }

  double _getAssetPrice(String asset) {
    // Simplified price simulation
    switch (asset) {
      case 'BTC':
        return 95000.0;
      case 'ETH':
        return 3200.0;
      case 'BNB':
        return 650.0;
      case 'USDT':
        return 1.0;
      default:
        return 1.0;
    }
  }

  double _getMarketPrice(String symbol) {
    // Extract base asset from symbol for pricing
    if (symbol.endsWith('USDT')) {
      final baseAsset = symbol.replaceAll('USDT', '');
      return _getAssetPrice(baseAsset);
    }
    return 1.0;
  }

  String _determineOrderStatus(String type, double? price, double marketPrice) {
    if (type == 'MARKET') return 'FILLED';
    if (price == null) return 'NEW';

    final priceDistance = (price - marketPrice).abs() / marketPrice;
    return priceDistance < 0.001 ? 'FILLED' : 'NEW';
  }

  int _generateOrderId() => 3000000000 + _random.nextInt(999999999);
  int _generateTradeId() => 1500000000 + _random.nextInt(499999999);
  int _generateTransactionId() => 4000000000 + _random.nextInt(999999999);
}
