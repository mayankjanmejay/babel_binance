import 'dart:math';
import 'binance_base.dart';

class Wallet extends BinanceBase {
  final WalletAccount account;
  final WalletTransfer transfer;
  final WalletDeposit deposit;
  final WalletWithdraw withdraw;
  final SimulatedWallet simulatedWallet;

  Wallet({String? apiKey, String? apiSecret})
      : account = WalletAccount(apiKey: apiKey, apiSecret: apiSecret),
        transfer = WalletTransfer(apiKey: apiKey, apiSecret: apiSecret),
        deposit = WalletDeposit(apiKey: apiKey, apiSecret: apiSecret),
        withdraw = WalletWithdraw(apiKey: apiKey, apiSecret: apiSecret),
        simulatedWallet = SimulatedWallet(apiKey: apiKey, apiSecret: apiSecret),
        super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getAccountInformation({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/api/v3/account', params: params);
  }
}

class WalletAccount extends BinanceBase {
  WalletAccount({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getAccountInformation({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/api/v3/account', params: params);
  }

  Future<Map<String, dynamic>> getAccountStatus({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/account/status', params: params);
  }

  Future<Map<String, dynamic>> getApiTradingStatus({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/account/apiTradingStatus',
        params: params);
  }

  Future<Map<String, dynamic>> getSystemStatus() {
    return sendRequest('GET', '/sapi/v1/system/status');
  }

  Future<Map<String, dynamic>> getAccountCoins({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/capital/config/getall', params: params);
  }
}

class WalletTransfer extends BinanceBase {
  WalletTransfer({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> universalTransfer({
    required String type,
    required String asset,
    required double amount,
    String? fromSymbol,
    String? toSymbol,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'type': type,
      'asset': asset,
      'amount': amount,
    };
    if (fromSymbol != null) params['fromSymbol'] = fromSymbol;
    if (toSymbol != null) params['toSymbol'] = toSymbol;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/asset/transfer', params: params);
  }

  Future<Map<String, dynamic>> getUniversalTransferHistory({
    required String type,
    int? startTime,
    int? endTime,
    int? current,
    int? size,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'type': type};
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (current != null) params['current'] = current;
    if (size != null) params['size'] = size;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/asset/transfer', params: params);
  }
}

class WalletDeposit extends BinanceBase {
  WalletDeposit({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getDepositHistory({
    String? coin,
    int? status,
    int? startTime,
    int? endTime,
    int? offset,
    int? limit,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{};
    if (coin != null) params['coin'] = coin;
    if (status != null) params['status'] = status;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (offset != null) params['offset'] = offset;
    if (limit != null) params['limit'] = limit;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/capital/deposit/hisrec',
        params: params);
  }

  Future<Map<String, dynamic>> getDepositAddress({
    required String coin,
    String? network,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'coin': coin};
    if (network != null) params['network'] = network;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/capital/deposit/address',
        params: params);
  }
}

class WalletWithdraw extends BinanceBase {
  WalletWithdraw({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> withdraw({
    required String coin,
    required String address,
    required double amount,
    String? withdrawOrderId,
    String? network,
    String? addressTag,
    String? name,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'coin': coin,
      'address': address,
      'amount': amount,
    };
    if (withdrawOrderId != null) params['withdrawOrderId'] = withdrawOrderId;
    if (network != null) params['network'] = network;
    if (addressTag != null) params['addressTag'] = addressTag;
    if (name != null) params['name'] = name;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/capital/withdraw/apply',
        params: params);
  }

  Future<Map<String, dynamic>> getWithdrawHistory({
    String? coin,
    String? withdrawOrderId,
    int? status,
    int? startTime,
    int? endTime,
    int? offset,
    int? limit,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{};
    if (coin != null) params['coin'] = coin;
    if (withdrawOrderId != null) params['withdrawOrderId'] = withdrawOrderId;
    if (status != null) params['status'] = status;
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (offset != null) params['offset'] = offset;
    if (limit != null) params['limit'] = limit;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/capital/withdraw/history',
        params: params);
  }
}

class SimulatedWallet {
  final String? apiKey;
  final String? apiSecret;
  final Random _random = Random();

  // Simulated wallet balances
  final Map<String, Map<String, dynamic>> _walletBalances = {
    'BTC': {
      'coin': 'BTC',
      'free': 0.15420000,
      'locked': 0.00000000,
      'freeze': 0.00000000,
      'withdrawing': 0.00000000,
      'ipoable': 0.00000000,
      'ipoing': 0.00000000,
      'storage': 0.00000000,
      'isLegalMoney': false,
      'trading': true,
      'networkList': [
        {
          'network': 'BTC',
          'coin': 'BTC',
          'withdrawIntegerMultiple': '0.00000001',
          'isDefault': true,
          'depositEnable': true,
          'withdrawEnable': true,
          'depositDesc': '',
          'withdrawDesc': '',
          'specialTips': '',
          'name': 'Bitcoin',
          'resetAddressStatus': false,
          'addressRegex':
              '^[13][a-km-zA-HJ-NP-Z1-9]{25,34}|^bc1[a-z0-9]{39,59}\$',
          'memoRegex': '',
          'withdrawFee': '0.0005',
          'withdrawMin': '0.001',
          'withdrawMax': '9999999',
          'minConfirm': 1,
          'unLockConfirm': 2,
        }
      ],
    },
    'ETH': {
      'coin': 'ETH',
      'free': 2.75000000,
      'locked': 0.00000000,
      'freeze': 0.00000000,
      'withdrawing': 0.00000000,
      'ipoable': 0.00000000,
      'ipoing': 0.00000000,
      'storage': 0.00000000,
      'isLegalMoney': false,
      'trading': true,
      'networkList': [
        {
          'network': 'ETH',
          'coin': 'ETH',
          'withdrawIntegerMultiple': '0.00000001',
          'isDefault': true,
          'depositEnable': true,
          'withdrawEnable': true,
          'depositDesc': '',
          'withdrawDesc': '',
          'specialTips': '',
          'name': 'Ethereum',
          'resetAddressStatus': false,
          'addressRegex': '^0x[0-9A-Fa-f]{40}\$',
          'memoRegex': '',
          'withdrawFee': '0.005',
          'withdrawMin': '0.01',
          'withdrawMax': '9999999',
          'minConfirm': 12,
          'unLockConfirm': 12,
        }
      ],
    },
    'USDT': {
      'coin': 'USDT',
      'free': 8542.50000000,
      'locked': 0.00000000,
      'freeze': 0.00000000,
      'withdrawing': 0.00000000,
      'ipoable': 0.00000000,
      'ipoing': 0.00000000,
      'storage': 0.00000000,
      'isLegalMoney': false,
      'trading': true,
      'networkList': [
        {
          'network': 'TRX',
          'coin': 'USDT',
          'withdrawIntegerMultiple': '0.00000001',
          'isDefault': false,
          'depositEnable': true,
          'withdrawEnable': true,
          'depositDesc': '',
          'withdrawDesc': '',
          'specialTips': '',
          'name': 'Tron',
          'resetAddressStatus': false,
          'addressRegex': '^T[0-9A-Za-z]{33}\$',
          'memoRegex': '',
          'withdrawFee': '1.0',
          'withdrawMin': '2.0',
          'withdrawMax': '9999999',
          'minConfirm': 0,
          'unLockConfirm': 0,
        },
        {
          'network': 'ETH',
          'coin': 'USDT',
          'withdrawIntegerMultiple': '0.00000001',
          'isDefault': true,
          'depositEnable': true,
          'withdrawEnable': true,
          'depositDesc': '',
          'withdrawDesc': '',
          'specialTips': '',
          'name': 'Ethereum',
          'resetAddressStatus': false,
          'addressRegex': '^0x[0-9A-Fa-f]{40}\$',
          'memoRegex': '',
          'withdrawFee': '25.0',
          'withdrawMin': '50.0',
          'withdrawMax': '9999999',
          'minConfirm': 12,
          'unLockConfirm': 12,
        }
      ],
    },
    'BNB': {
      'coin': 'BNB',
      'free': 45.82000000,
      'locked': 0.00000000,
      'freeze': 0.00000000,
      'withdrawing': 0.00000000,
      'ipoable': 0.00000000,
      'ipoing': 0.00000000,
      'storage': 0.00000000,
      'isLegalMoney': false,
      'trading': true,
      'networkList': [
        {
          'network': 'BSC',
          'coin': 'BNB',
          'withdrawIntegerMultiple': '0.00000001',
          'isDefault': true,
          'depositEnable': true,
          'withdrawEnable': true,
          'depositDesc': '',
          'withdrawDesc': '',
          'specialTips': '',
          'name': 'BNB Smart Chain',
          'resetAddressStatus': false,
          'addressRegex': '^0x[0-9A-Fa-f]{40}\$',
          'memoRegex': '',
          'withdrawFee': '0.0005',
          'withdrawMin': '0.001',
          'withdrawMax': '9999999',
          'minConfirm': 15,
          'unLockConfirm': 15,
        }
      ],
    },
  };

  // Transaction history
  final List<Map<String, dynamic>> _depositHistory = [];
  final List<Map<String, dynamic>> _withdrawHistory = [];
  final List<Map<String, dynamic>> _transferHistory = [];

  SimulatedWallet({this.apiKey, this.apiSecret});

  Future<Map<String, dynamic>> simulateGetAccountInformation({
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final balances = <Map<String, dynamic>>[];

    // Convert wallet balances to account format
    _walletBalances.forEach((coin, coinData) {
      balances.add({
        'asset': coin,
        'free': coinData['free'].toString(),
        'locked': coinData['locked'].toString(),
      });
    });

    // Calculate account totals (simplified)
    double totalWalletBalance = 0;
    double totalUnrealizedProfit = 0;
    double totalMarginBalance = 0;

    return {
      'makerCommission': 10,
      'takerCommission': 10,
      'buyerCommission': 0,
      'sellerCommission': 0,
      'canTrade': true,
      'canWithdraw': true,
      'canDeposit': true,
      'updateTime': currentTime,
      'accountType': 'SPOT',
      'balances': balances,
      'permissions': ['SPOT'],
      'totalWalletBalance': totalWalletBalance.toStringAsFixed(8),
      'totalUnrealizedProfit': totalUnrealizedProfit.toStringAsFixed(8),
      'totalMarginBalance': totalMarginBalance.toStringAsFixed(8),
    };
  }

  Future<Map<String, dynamic>> simulateGetAccountStatus({
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    return {'data': 'Normal'};
  }

  Future<Map<String, dynamic>> simulateGetApiTradingStatus({
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    return {
      'data': {
        'isLocked': false,
        'plannedRecoverTime': 0,
        'triggerCondition': {
          'GCR': 150,
          'IFER': 150,
          'UFR': 300,
        },
        'updateTime': DateTime.now().millisecondsSinceEpoch,
      }
    };
  }

  Future<Map<String, dynamic>> simulateGetSystemStatus({
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    return {'status': 0, 'msg': 'normal'};
  }

  Future<Map<String, dynamic>> simulateGetAccountCoins({
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    return {
      'data': _walletBalances.values.toList(),
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateUniversalTransfer({
    required String type,
    required String asset,
    required double amount,
    String? fromSymbol,
    String? toSymbol,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    // Validate asset exists
    if (!_walletBalances.containsKey(asset)) {
      throw Exception('Asset not found: $asset');
    }

    final balance = _walletBalances[asset]!;
    final freeBalance = balance['free'] as double;

    // Check sufficient balance
    if (amount > freeBalance) {
      throw Exception('Insufficient balance. Available: $freeBalance');
    }

    final tranId = _generateTransactionId();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Simulate different transfer types
    String status = 'CONFIRMED';
    double actualAmount = amount;

    switch (type) {
      case 'MAIN_MARGIN':
      case 'MARGIN_MAIN':
        // Transfer between spot and margin
        break;
      case 'MAIN_UMFUTURE':
      case 'UMFUTURE_MAIN':
        // Transfer between spot and futures
        break;
      case 'MAIN_CMFUTURE':
      case 'CMFUTURE_MAIN':
        // Transfer between spot and coin futures
        break;
      case 'MARGIN_UMFUTURE':
      case 'UMFUTURE_MARGIN':
        // Transfer between margin and futures
        break;
      default:
        throw Exception('Unsupported transfer type: $type');
    }

    // Update balance (simplified - just reduce from source)
    balance['free'] = freeBalance - amount;

    // Record transfer
    _transferHistory.insert(0, {
      'tranId': int.parse(tranId),
      'type': type,
      'asset': asset,
      'amount': actualAmount.toString(),
      'timestamp': currentTime,
      'status': status,
      'fromSymbol': fromSymbol,
      'toSymbol': toSymbol,
    });

    return {
      'tranId': int.parse(tranId),
    };
  }

  Future<Map<String, dynamic>> simulateGetUniversalTransferHistory({
    required String type,
    int? startTime,
    int? endTime,
    int? current,
    int? size,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    final limit = size ?? 10;
    final page = current ?? 1;
    final offset = (page - 1) * limit;

    var filteredHistory = _transferHistory.where((transfer) {
      if (transfer['type'] != type) return false;
      if (startTime != null && transfer['timestamp'] < startTime) return false;
      if (endTime != null && transfer['timestamp'] > endTime) return false;
      return true;
    }).toList();

    final paginatedHistory = filteredHistory.skip(offset).take(limit).toList();

    return {
      'total': filteredHistory.length,
      'rows': paginatedHistory,
    };
  }

  Future<Map<String, dynamic>> simulateGetDepositHistory({
    String? coin,
    int? status,
    int? startTime,
    int? endTime,
    int? offset,
    int? limit,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    // Generate mock deposit history if empty
    if (_depositHistory.isEmpty) {
      _generateMockDepositHistory();
    }

    var filteredHistory = _depositHistory.where((deposit) {
      if (coin != null && deposit['coin'] != coin) return false;
      if (status != null && deposit['status'] != status) return false;
      if (startTime != null && deposit['insertTime'] < startTime) return false;
      if (endTime != null && deposit['insertTime'] > endTime) return false;
      return true;
    }).toList();

    final resultLimit = limit ?? 10;
    final resultOffset = offset ?? 0;
    final paginatedHistory =
        filteredHistory.skip(resultOffset).take(resultLimit).toList();

    return {
      'data': paginatedHistory,
      'total': filteredHistory.length,
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateGetDepositAddress({
    required String coin,
    String? network,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    if (!_walletBalances.containsKey(coin)) {
      throw Exception('Coin not supported: $coin');
    }

    final coinData = _walletBalances[coin]!;
    final networkList = coinData['networkList'] as List;

    Map<String, dynamic> selectedNetwork;
    if (network != null) {
      selectedNetwork = networkList.firstWhere(
        (net) => net['network'] == network,
        orElse: () => throw Exception('Network not supported: $network'),
      );
    } else {
      selectedNetwork =
          networkList.firstWhere((net) => net['isDefault'] == true);
    }

    return {
      'address': _generateDepositAddress(selectedNetwork['network']),
      'coin': coin,
      'tag':
          selectedNetwork['memoRegex'].isNotEmpty ? _generateAddressTag() : '',
      'url':
          'https://bscscan.com/address/${_generateDepositAddress(selectedNetwork['network'])}',
    };
  }

  Future<Map<String, dynamic>> simulateWithdraw({
    required String coin,
    required String address,
    required double amount,
    String? withdrawOrderId,
    String? network,
    String? addressTag,
    String? name,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    if (!_walletBalances.containsKey(coin)) {
      throw Exception('Coin not supported: $coin');
    }

    final balance = _walletBalances[coin]!;
    final freeBalance = balance['free'] as double;
    final networkList = balance['networkList'] as List;

    // Find network info
    Map<String, dynamic> selectedNetwork;
    if (network != null) {
      selectedNetwork = networkList.firstWhere(
        (net) => net['network'] == network,
        orElse: () => throw Exception('Network not supported: $network'),
      );
    } else {
      selectedNetwork =
          networkList.firstWhere((net) => net['isDefault'] == true);
    }

    final withdrawFee = double.parse(selectedNetwork['withdrawFee']);
    final withdrawMin = double.parse(selectedNetwork['withdrawMin']);
    final withdrawMax = double.parse(selectedNetwork['withdrawMax']);
    final totalRequired = amount + withdrawFee;

    // Validate withdrawal
    if (amount < withdrawMin) {
      throw Exception('Amount below minimum: $withdrawMin');
    }
    if (amount > withdrawMax) {
      throw Exception('Amount above maximum: $withdrawMax');
    }
    if (totalRequired > freeBalance) {
      throw Exception(
          'Insufficient balance. Required: $totalRequired, Available: $freeBalance');
    }
    if (!selectedNetwork['withdrawEnable']) {
      throw Exception('Withdrawal disabled for this network');
    }

    // Validate address format
    final addressRegex = selectedNetwork['addressRegex'];
    if (addressRegex.isNotEmpty && !RegExp(addressRegex).hasMatch(address)) {
      throw Exception('Invalid address format');
    }

    final withdrawId = withdrawOrderId ?? _generateTransactionId();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // Update balance
    balance['free'] = freeBalance - totalRequired;

    // 90% success rate for withdrawals
    final status =
        _random.nextDouble() < 0.9 ? 6 : 4; // 6 = completed, 4 = processing

    // Record withdrawal
    _withdrawHistory.insert(0, {
      'id': withdrawId,
      'withdrawOrderId': withdrawId,
      'amount': amount.toString(),
      'transactionFee': withdrawFee.toString(),
      'coin': coin,
      'status': status,
      'address': address,
      'addressTag': addressTag ?? '',
      'txId': status == 6 ? _generateTxId() : '',
      'applyTime': currentTime.toString(),
      'network': selectedNetwork['network'],
      'transferType': 0,
      'info': status == 6 ? 'Completed' : 'Processing',
      'confirmNo': status == 6 ? selectedNetwork['minConfirm'] : 0,
    });

    return {
      'id': withdrawId,
    };
  }

  Future<Map<String, dynamic>> simulateGetWithdrawHistory({
    String? coin,
    String? withdrawOrderId,
    int? status,
    int? startTime,
    int? endTime,
    int? offset,
    int? limit,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    var filteredHistory = _withdrawHistory.where((withdraw) {
      if (coin != null && withdraw['coin'] != coin) return false;
      if (withdrawOrderId != null &&
          withdraw['withdrawOrderId'] != withdrawOrderId) return false;
      if (status != null && withdraw['status'] != status) return false;
      if (startTime != null && int.parse(withdraw['applyTime']) < startTime)
        return false;
      if (endTime != null && int.parse(withdraw['applyTime']) > endTime)
        return false;
      return true;
    }).toList();

    final resultLimit = limit ?? 10;
    final resultOffset = offset ?? 0;
    final paginatedHistory =
        filteredHistory.skip(resultOffset).take(resultLimit).toList();

    return {
      'data': paginatedHistory,
      'total': filteredHistory.length,
      'success': true,
    };
  }

  // Helper methods
  Future<void> _simulateDataRetrievalDelay() async {
    final delay = 80 + _random.nextInt(220); // 80-300ms
    await Future.delayed(Duration(milliseconds: delay));
  }

  Future<void> _simulateTransactionDelay() async {
    final delay = 200 + _random.nextInt(1300); // 200ms-1.5s
    await Future.delayed(Duration(milliseconds: delay));
  }

  String _generateTransactionId() {
    return '${DateTime.now().millisecondsSinceEpoch}${_random.nextInt(9999)}';
  }

  String _generateDepositAddress(String network) {
    switch (network) {
      case 'BTC':
        return 'bc1q${_generateRandomString(39)}';
      case 'ETH':
      case 'BSC':
        return '0x${_generateRandomString(40, charset: '0123456789abcdef')}';
      case 'TRX':
        return 'T${_generateRandomString(33)}';
      default:
        return '${network}_${_generateRandomString(34)}';
    }
  }

  String _generateAddressTag() {
    return _random.nextInt(99999999).toString();
  }

  String _generateTxId() {
    return _generateRandomString(64, charset: '0123456789abcdef');
  }

  String _generateRandomString(int length,
      {String charset =
          '0123456789abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ'}) {
    return String.fromCharCodes(Iterable.generate(
        length, (_) => charset.codeUnitAt(_random.nextInt(charset.length))));
  }

  void _generateMockDepositHistory() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final coins = ['BTC', 'ETH', 'USDT', 'BNB'];

    for (int i = 0; i < 5; i++) {
      final coin = coins[_random.nextInt(coins.length)];
      final amount = _random.nextDouble() * 10 + 0.1;
      final time = currentTime - (i * 24 * 60 * 60 * 1000); // Daily intervals

      _depositHistory.add({
        'insertTime': time,
        'amount': amount.toStringAsFixed(8),
        'coin': coin,
        'network': coin == 'USDT' ? 'TRX' : coin,
        'status': 1, // Success
        'address': _generateDepositAddress(coin),
        'addressTag': '',
        'txId': _generateTxId(),
        'confirmTimes': coin == 'BTC' ? '1/1' : '12/12',
        'unlockConfirm': coin == 'BTC' ? 1 : 12,
        'walletType': 0,
      });
    }
  }
}