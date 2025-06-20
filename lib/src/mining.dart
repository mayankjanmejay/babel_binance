import 'dart:math';
import 'binance_base.dart';

class Mining extends BinanceBase {
  final MiningPool pool;
  final MiningStatistics statistics;
  final MiningAccount account;
  final SimulatedMining simulatedMining;

  Mining({String? apiKey, String? apiSecret})
      : pool = MiningPool(apiKey: apiKey, apiSecret: apiSecret),
        statistics = MiningStatistics(apiKey: apiKey, apiSecret: apiSecret),
        account = MiningAccount(apiKey: apiKey, apiSecret: apiSecret),
        simulatedMining = SimulatedMining(apiKey: apiKey, apiSecret: apiSecret),
        super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getHashrateResaleList({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/mining/hash-transfer/config/list',
        params: params);
  }
}

class MiningPool extends BinanceBase {
  MiningPool({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getAlgorithmList({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/mining/pub/algoList', params: params);
  }

  Future<Map<String, dynamic>> getCoinList({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/mining/pub/coinList', params: params);
  }

  Future<Map<String, dynamic>> getMinerDetail({
    required String algo,
    required String userName,
    required String workerName,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'algo': algo,
      'userName': userName,
      'workerName': workerName,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/mining/worker/detail', params: params);
  }

  Future<Map<String, dynamic>> getMinerList({
    required String algo,
    required String userName,
    int? pageIndex,
    String? sort,
    int? sortColumn,
    String? workerStatus,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'algo': algo,
      'userName': userName,
    };
    if (pageIndex != null) params['pageIndex'] = pageIndex;
    if (sort != null) params['sort'] = sort;
    if (sortColumn != null) params['sortColumn'] = sortColumn;
    if (workerStatus != null) params['workerStatus'] = workerStatus;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/mining/worker/list', params: params);
  }
}

class MiningStatistics extends BinanceBase {
  MiningStatistics({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getEarningsStatistics({
    required String algo,
    required String userName,
    String? coin,
    int? startDate,
    int? endDate,
    int? pageIndex,
    int? pageSize,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'algo': algo,
      'userName': userName,
    };
    if (coin != null) params['coin'] = coin;
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    if (pageIndex != null) params['pageIndex'] = pageIndex;
    if (pageSize != null) params['pageSize'] = pageSize;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/mining/payment/list', params: params);
  }

  Future<Map<String, dynamic>> getStatisticsList({
    required String algo,
    required String userName,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'algo': algo,
      'userName': userName,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/mining/statistics/user/status',
        params: params);
  }

  Future<Map<String, dynamic>> getAccountList({
    required String algo,
    required String userName,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'algo': algo,
      'userName': userName,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/mining/statistics/user/list',
        params: params);
  }
}

class MiningAccount extends BinanceBase {
  MiningAccount({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getHashrateResaleList({int? recvWindow}) {
    final params = <String, dynamic>{};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/mining/hash-transfer/config/list', params: params);
  }

  Future<Map<String, dynamic>> getHashrateResaleDetail({
    required int configId,
    required String userName,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'configId': configId,
      'userName': userName,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest(
        'GET', '/sapi/v1/mining/hash-transfer/config/details/list',
        params: params);
  }

  Future<Map<String, dynamic>> requestHashrateResale({
    required String userName,
    required String algo,
    int? startDate,
    int? endDate,
    required String toPoolUser,
    required String hashRate,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'userName': userName,
      'algo': algo,
      'toPoolUser': toPoolUser,
      'hashRate': hashRate,
    };
    if (startDate != null) params['startDate'] = startDate;
    if (endDate != null) params['endDate'] = endDate;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/mining/hash-transfer/config',
        params: params);
  }

  Future<Map<String, dynamic>> cancelHashrateResale({
    required int configId,
    required String userName,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{
      'configId': configId,
      'userName': userName,
    };
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('POST', '/sapi/v1/mining/hash-transfer/config/cancel',
        params: params);
  }
}

class SimulatedMining {
  final String? apiKey;
  final String? apiSecret;
  final Random _random = Random();

  // Supported mining algorithms
  final Map<String, Map<String, dynamic>> _algorithms = {
    'sha256': {
      'algoName': 'sha256',
      'algoId': 1,
      'poolIndex': 0,
      'unit': 'T',
      'coins': ['BTC', 'BCH', 'BSV'],
      'profitability': 0.000045, // BTC per TH/s per day
    },
    'scrypt': {
      'algoName': 'scrypt',
      'algoId': 2,
      'poolIndex': 1,
      'unit': 'M',
      'coins': ['LTC', 'DOGE'],
      'profitability': 0.012, // LTC per MH/s per day
    },
    'ethash': {
      'algoName': 'ethash',
      'algoId': 3,
      'poolIndex': 2,
      'unit': 'M',
      'coins': ['ETH', 'ETC'],
      'profitability': 0.0025, // ETH per MH/s per day
    },
  };

  // Simulated mining workers
  final Map<String, List<Map<String, dynamic>>> _workers = {};

  // Simulated earnings history
  final Map<String, List<Map<String, dynamic>>> _earningsHistory = {};

  // Hashrate resale configurations
  final Map<int, Map<String, dynamic>> _hashrateResales = {};
  int _nextConfigId = 1000;

  SimulatedMining({this.apiKey, this.apiSecret});

  Future<Map<String, dynamic>> simulateGetAlgorithmList({
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    final algorithms = _algorithms.values
        .map((algo) => {
              'algoName': algo['algoName'],
              'algoId': algo['algoId'],
              'poolIndex': algo['poolIndex'],
              'unit': algo['unit'],
            })
        .toList();

    return {
      'code': 0,
      'msg': '',
      'data': algorithms,
    };
  }

  Future<Map<String, dynamic>> simulateGetCoinList({
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    final coins = <Map<String, dynamic>>[];

    _algorithms.forEach((algoName, algoData) {
      for (final coin in algoData['coins']) {
        coins.add({
          'coinName': coin,
          'coinId': coins.length + 1,
          'poolIndex': algoData['poolIndex'],
          'algoId': algoData['algoId'],
          'algoName': algoName,
        });
      }
    });

    return {
      'code': 0,
      'msg': '',
      'data': coins,
    };
  }

  Future<Map<String, dynamic>> simulateGetMinerList({
    required String algo,
    required String userName,
    int? pageIndex,
    String? sort,
    int? sortColumn,
    String? workerStatus,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    // Generate workers if not exist
    if (!_workers.containsKey(userName)) {
      _generateMockWorkers(userName, algo);
    }

    final userWorkers = _workers[userName] ?? [];
    var filteredWorkers = userWorkers.where((worker) {
      if (worker['algo'] != algo) return false;
      if (workerStatus != null && worker['status'] != workerStatus)
        return false;
      return true;
    }).toList();

    // Apply sorting
    if (sort != null && sortColumn != null) {
      filteredWorkers.sort((a, b) {
        final aVal = _getWorkerSortValue(a, sortColumn);
        final bVal = _getWorkerSortValue(b, sortColumn);

        final comparison = aVal.compareTo(bVal);
        return sort == 'ASC' ? comparison : -comparison;
      });
    }

    // Apply pagination
    final page = pageIndex ?? 1;
    final pageSize = 10;
    final startIndex = (page - 1) * pageSize;
    final endIndex = startIndex + pageSize;

    final paginatedWorkers = filteredWorkers.sublist(
      startIndex,
      endIndex > filteredWorkers.length ? filteredWorkers.length : endIndex,
    );

    return {
      'code': 0,
      'msg': '',
      'data': {
        'workerDatas': paginatedWorkers,
        'totalNum': filteredWorkers.length,
        'pageSize': pageSize,
      },
    };
  }

  Future<Map<String, dynamic>> simulateGetMinerDetail({
    required String algo,
    required String userName,
    required String workerName,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    final userWorkers = _workers[userName] ?? [];
    final worker = userWorkers.firstWhere(
      (w) => w['workerName'] == workerName && w['algo'] == algo,
      orElse: () => {},
    );

    if (worker.isEmpty) {
      return {
        'code': 2028,
        'msg': 'Worker not found',
        'data': {},
      };
    }

    // Generate 24-hour hashrate history
    final hashrateHistory = <Map<String, dynamic>>[];
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final baseHashrate = worker['hashRate'] as double;

    for (int i = 23; i >= 0; i--) {
      final time = currentTime - (i * 60 * 60 * 1000); // Hourly intervals
      final variance = 0.8 + (_random.nextDouble() * 0.4); // 80%-120% variance
      final hashrate = baseHashrate * variance;

      hashrateHistory.add({
        'time': time,
        'hashrate': hashrate.toStringAsFixed(2),
        'reject': (_random.nextDouble() * 0.05)
            .toStringAsFixed(4), // 0-5% reject rate
      });
    }

    return {
      'code': 0,
      'msg': '',
      'data': {
        'workerName': workerName,
        'type': worker['type'],
        'hashrateDatas': hashrateHistory,
      },
    };
  }

  Future<Map<String, dynamic>> simulateGetEarningsStatistics({
    required String algo,
    required String userName,
    String? coin,
    int? startDate,
    int? endDate,
    int? pageIndex,
    int? pageSize,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    // Generate earnings history if not exists
    if (!_earningsHistory.containsKey(userName)) {
      _generateMockEarningsHistory(userName, algo, coin);
    }

    final earnings = _earningsHistory[userName] ?? [];
    var filteredEarnings = earnings.where((earning) {
      if (earning['algo'] != algo) return false;
      if (coin != null && earning['coinName'] != coin) return false;
      if (startDate != null && earning['time'] < startDate) return false;
      if (endDate != null && earning['time'] > endDate) return false;
      return true;
    }).toList();

    // Apply pagination
    final page = pageIndex ?? 1;
    final size = pageSize ?? 20;
    final startIndex = (page - 1) * size;
    final endIndex = startIndex + size;

    final paginatedEarnings = filteredEarnings.sublist(
      startIndex,
      endIndex > filteredEarnings.length ? filteredEarnings.length : endIndex,
    );

    return {
      'code': 0,
      'msg': '',
      'data': {
        'accountProfits': paginatedEarnings,
        'totalNum': filteredEarnings.length,
        'pageSize': size,
      },
    };
  }

  Future<Map<String, dynamic>> simulateGetStatisticsList({
    required String algo,
    required String userName,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    final userWorkers = _workers[userName] ?? [];
    final algoWorkers = userWorkers.where((w) => w['algo'] == algo).toList();

    if (algoWorkers.isEmpty) {
      return {
        'code': 0,
        'msg': '',
        'data': {
          'fifteenMinHashRate': '0',
          'dayHashRate': '0',
          'validNum': 0,
          'invalidNum': 0,
          'profitToday': {},
          'profitYesterday': {},
          'userName': userName,
          'unit': _algorithms[algo]?['unit'] ?? 'T',
          'algo': algo,
        },
      };
    }

    // Calculate total hashrate
    final totalHashrate = algoWorkers.fold<double>(
      0.0,
      (sum, worker) => sum + (worker['hashRate'] as double),
    );

    // Calculate profits
    final profitability = _algorithms[algo]?['profitability'] ?? 0.000045;
    final todayProfit = totalHashrate * profitability;
    final yesterdayProfit =
        totalHashrate * profitability * (0.9 + _random.nextDouble() * 0.2);

    final primaryCoin = _algorithms[algo]?['coins'][0] ?? 'BTC';

    return {
      'code': 0,
      'msg': '',
      'data': {
        'fifteenMinHashRate':
            (totalHashrate * (0.95 + _random.nextDouble() * 0.1))
                .toStringAsFixed(2),
        'dayHashRate': totalHashrate.toStringAsFixed(2),
        'validNum': algoWorkers.where((w) => w['status'] == 'Valid').length,
        'invalidNum': algoWorkers.where((w) => w['status'] != 'Valid').length,
        'profitToday': {
          primaryCoin: todayProfit.toStringAsFixed(8),
        },
        'profitYesterday': {
          primaryCoin: yesterdayProfit.toStringAsFixed(8),
        },
        'userName': userName,
        'unit': _algorithms[algo]?['unit'] ?? 'T',
        'algo': algo,
      },
    };
  }

  Future<Map<String, dynamic>> simulateRequestHashrateResale({
    required String userName,
    required String algo,
    int? startDate,
    int? endDate,
    required String toPoolUser,
    required String hashRate,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    final configId = _nextConfigId++;
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    _hashrateResales[configId] = {
      'configId': configId,
      'fromUser': userName,
      'toPoolUser': toPoolUser,
      'algoName': algo,
      'hashRate': hashRate,
      'startDate': startDate ?? currentTime,
      'endDate':
          endDate ?? (currentTime + (30 * 24 * 60 * 60 * 1000)), // 30 days
      'status': 0, // 0: Processing, 1: Cancelled, 2: Terminated
      'createTime': currentTime,
    };

    return {
      'code': 0,
      'msg': '',
      'data': configId,
    };
  }

  Future<Map<String, dynamic>> simulateGetHashrateResaleList({
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    final resaleList = _hashrateResales.values.toList();

    return {
      'code': 0,
      'msg': '',
      'data': {
        'configDetails': resaleList,
        'totalNum': resaleList.length,
      },
    };
  }

  Future<Map<String, dynamic>> simulateCancelHashrateResale({
    required int configId,
    required String userName,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    final config = _hashrateResales[configId];
    if (config == null) {
      return {
        'code': 2028,
        'msg': 'Configuration not found',
        'data': false,
      };
    }

    if (config['fromUser'] != userName) {
      return {
        'code': 2028,
        'msg': 'Unauthorized to cancel this configuration',
        'data': false,
      };
    }

    config['status'] = 1; // Cancelled
    config['cancelTime'] = DateTime.now().millisecondsSinceEpoch;

    return {
      'code': 0,
      'msg': '',
      'data': true,
    };
  }

  // Helper methods
  Future<void> _simulateDataRetrievalDelay() async {
    final delay = 200 + _random.nextInt(400); // 200-600ms
    await Future.delayed(Duration(milliseconds: delay));
  }

  Future<void> _simulateTransactionDelay() async {
    final delay = 500 + _random.nextInt(1500); // 500ms-2s
    await Future.delayed(Duration(milliseconds: delay));
  }

  void _generateMockWorkers(String userName, String algo) {
    final workers = <Map<String, dynamic>>[];
    final workerCount = 3 + _random.nextInt(8); // 3-10 workers

    for (int i = 1; i <= workerCount; i++) {
      final status = _random.nextDouble() < 0.85 ? 'Valid' : 'Invalid';
      final hashRate = _random.nextDouble() * 100 + 10; // 10-110 TH/s
      final lastShareTime = DateTime.now().millisecondsSinceEpoch -
          (_random.nextInt(3600) * 1000);

      workers.add({
        'workerId': '${userName}_worker_$i',
        'workerName': 'worker_$i',
        'status': status,
        'hashRate': hashRate,
        'dayHashRate': hashRate * (0.9 + _random.nextDouble() * 0.2),
        'rejectRate': _random.nextDouble() * 0.05, // 0-5%
        'lastShareTime': lastShareTime,
        'algo': algo,
        'type': _random.nextBool() ? 'ASIC' : 'GPU',
      });
    }

    _workers[userName] = workers;
  }

  void _generateMockEarningsHistory(
      String userName, String algo, String? coin) {
    final earnings = <Map<String, dynamic>>[];
    final currentTime = DateTime.now().millisecondsSinceEpoch;
    final primaryCoin = coin ?? _algorithms[algo]?['coins'][0] ?? 'BTC';
    final profitability = _algorithms[algo]?['profitability'] ?? 0.000045;

    // Generate 30 days of earnings
    for (int i = 0; i < 30; i++) {
      final time = currentTime - (i * 24 * 60 * 60 * 1000);
      final totalHashrate = 50 + _random.nextDouble() * 200; // 50-250 TH/s
      final earnings24h =
          totalHashrate * profitability * (0.8 + _random.nextDouble() * 0.4);

      earnings.add({
        'time': time,
        'type': 31, // Mining earnings
        'hashRate': totalHashrate.toStringAsFixed(2),
        'amount': earnings24h.toStringAsFixed(8),
        'coinName': primaryCoin,
        'status': 1, // Paid
        'algo': algo,
        'userName': userName,
      });
    }

    _earningsHistory[userName] = earnings;
  }

  dynamic _getWorkerSortValue(Map<String, dynamic> worker, int sortColumn) {
    switch (sortColumn) {
      case 1: // Worker name
        return worker['workerName'];
      case 2: // Status
        return worker['status'];
      case 3: // Hash rate
        return worker['hashRate'];
      case 4: // Reject rate
        return worker['rejectRate'];
      case 5: // Last share time
        return worker['lastShareTime'];
      default:
        return worker['workerName'];
    }
  }
}