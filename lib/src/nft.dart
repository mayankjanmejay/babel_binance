import 'dart:math';
import 'binance_base.dart';

class Nft extends BinanceBase {
  final NftTransactions transactions;
  final NftMarketplace marketplace;
  final NftAssets assets;
  final SimulatedNft simulatedNft;

  Nft({String? apiKey, String? apiSecret})
      : transactions = NftTransactions(apiKey: apiKey, apiSecret: apiSecret),
        marketplace = NftMarketplace(apiKey: apiKey, apiSecret: apiSecret),
        assets = NftAssets(apiKey: apiKey, apiSecret: apiSecret),
        simulatedNft = SimulatedNft(apiKey: apiKey, apiSecret: apiSecret),
        super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getNftTransactionHistory({
    required int orderType,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'orderType': orderType};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/nft/history/transactions',
        params: params);
  }
}

class NftTransactions extends BinanceBase {
  NftTransactions({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getNftTransactionHistory({
    required int orderType,
    int? startTime,
    int? endTime,
    int? limit,
    int? page,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'orderType': orderType};
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (limit != null) params['limit'] = limit;
    if (page != null) params['page'] = page;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/nft/history/transactions', params: params);
  }

  Future<Map<String, dynamic>> getNftDepositHistory({
    int? startTime,
    int? endTime,
    int? limit,
    int? page,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{};
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (limit != null) params['limit'] = limit;
    if (page != null) params['page'] = page;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/nft/history/deposit', params: params);
  }

  Future<Map<String, dynamic>> getNftWithdrawHistory({
    int? startTime,
    int? endTime,
    int? limit,
    int? page,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{};
    if (startTime != null) params['startTime'] = startTime;
    if (endTime != null) params['endTime'] = endTime;
    if (limit != null) params['limit'] = limit;
    if (page != null) params['page'] = page;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/nft/history/withdraw', params: params);
  }
}

class NftMarketplace extends BinanceBase {
  NftMarketplace({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getNftAssetInfo({
    required String nftId,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{'nftId': nftId};
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/nft/user/getAsset', params: params);
  }
}

class NftAssets extends BinanceBase {
  NftAssets({String? apiKey, String? apiSecret})
      : super(
          apiKey: apiKey,
          apiSecret: apiSecret,
          baseUrl: 'https://api.binance.com',
        );

  Future<Map<String, dynamic>> getUserAssets({
    int? limit,
    int? page,
    int? recvWindow,
  }) {
    final params = <String, dynamic>{};
    if (limit != null) params['limit'] = limit;
    if (page != null) params['page'] = page;
    if (recvWindow != null) params['recvWindow'] = recvWindow;
    return sendRequest('GET', '/sapi/v1/nft/user/getAsset', params: params);
  }
}

class SimulatedNft {
  final String? apiKey;
  final String? apiSecret;
  final Random _random = Random();

  // NFT Collections and Assets
  final Map<String, Map<String, dynamic>> _nftCollections = {
    'binance-anniversary': {
      'collectionId': 'binance-anniversary',
      'collectionName': 'Binance Anniversary Collection',
      'creator': 'Binance Official',
      'description': 'Limited edition NFTs celebrating Binance milestones',
      'totalSupply': 10000,
      'mintedCount': 8500,
      'floorPrice': 0.5,
      'currency': 'BNB',
      'verified': true,
      'createdAt': 1640995200000, // Jan 1, 2022
    },
    'crypto-punks-binance': {
      'collectionId': 'crypto-punks-binance',
      'collectionName': 'Crypto Punks Binance Edition',
      'creator': 'Larva Labs x Binance',
      'description': 'Exclusive Binance edition of the iconic CryptoPunks',
      'totalSupply': 5000,
      'mintedCount': 5000,
      'floorPrice': 2.5,
      'currency': 'ETH',
      'verified': true,
      'createdAt': 1641081600000, // Jan 2, 2022
    },
    'binance-heroes': {
      'collectionId': 'binance-heroes',
      'collectionName': 'Binance Heroes',
      'creator': 'Binance Studios',
      'description': 'Legendary heroes from the Binance universe',
      'totalSupply': 25000,
      'mintedCount': 15000,
      'floorPrice': 0.1,
      'currency': 'BNB',
      'verified': true,
      'createdAt': 1641168000000, // Jan 3, 2022
    },
  };

  // User NFT Assets
  final Map<String, List<Map<String, dynamic>>> _userAssets = {};

  // Transaction History
  final List<Map<String, dynamic>> _transactionHistory = [];
  final List<Map<String, dynamic>> _depositHistory = [];
  final List<Map<String, dynamic>> _withdrawHistory = [];

  SimulatedNft({this.apiKey, this.apiSecret});

  Future<Map<String, dynamic>> simulateGetNftTransactionHistory({
    required int orderType,
    int? startTime,
    int? endTime,
    int? limit,
    int? page,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    // Generate transaction history if empty
    if (_transactionHistory.isEmpty) {
      _generateMockTransactionHistory();
    }

    final resultLimit = limit ?? 50;
    final resultPage = page ?? 1;
    final offset = (resultPage - 1) * resultLimit;

    var filteredTransactions = _transactionHistory.where((tx) {
      if (tx['orderType'] != orderType) return false;
      if (startTime != null && tx['tradeTime'] < startTime) return false;
      if (endTime != null && tx['tradeTime'] > endTime) return false;
      return true;
    }).toList();

    // Sort by trade time (newest first)
    filteredTransactions.sort(
        (a, b) => (b['tradeTime'] as int).compareTo(a['tradeTime'] as int));

    final paginatedTransactions =
        filteredTransactions.skip(offset).take(resultLimit).toList();

    return {
      'code': '000000',
      'message': 'success',
      'data': {
        'list': paginatedTransactions,
        'total': filteredTransactions.length,
      },
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateGetNftDepositHistory({
    int? startTime,
    int? endTime,
    int? limit,
    int? page,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    // Generate deposit history if empty
    if (_depositHistory.isEmpty) {
      _generateMockDepositHistory();
    }

    final resultLimit = limit ?? 50;
    final resultPage = page ?? 1;
    final offset = (resultPage - 1) * resultLimit;

    var filteredDeposits = _depositHistory.where((deposit) {
      if (startTime != null && deposit['timestamp'] < startTime) return false;
      if (endTime != null && deposit['timestamp'] > endTime) return false;
      return true;
    }).toList();

    final paginatedDeposits =
        filteredDeposits.skip(offset).take(resultLimit).toList();

    return {
      'code': '000000',
      'message': 'success',
      'data': {
        'list': paginatedDeposits,
        'total': filteredDeposits.length,
      },
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateGetNftWithdrawHistory({
    int? startTime,
    int? endTime,
    int? limit,
    int? page,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    // Generate withdraw history if empty
    if (_withdrawHistory.isEmpty) {
      _generateMockWithdrawHistory();
    }

    final resultLimit = limit ?? 50;
    final resultPage = page ?? 1;
    final offset = (resultPage - 1) * resultLimit;

    var filteredWithdraws = _withdrawHistory.where((withdraw) {
      if (startTime != null && withdraw['timestamp'] < startTime) return false;
      if (endTime != null && withdraw['timestamp'] > endTime) return false;
      return true;
    }).toList();

    final paginatedWithdraws =
        filteredWithdraws.skip(offset).take(resultLimit).toList();

    return {
      'code': '000000',
      'message': 'success',
      'data': {
        'list': paginatedWithdraws,
        'total': filteredWithdraws.length,
      },
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateGetUserAssets({
    int? limit,
    int? page,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    final userId = 'user_${apiKey?.hashCode ?? 'demo'}';

    // Generate user assets if empty
    if (!_userAssets.containsKey(userId)) {
      _generateMockUserAssets(userId);
    }

    final userAssets = _userAssets[userId] ?? [];
    final resultLimit = limit ?? 50;
    final resultPage = page ?? 1;
    final offset = (resultPage - 1) * resultLimit;

    final paginatedAssets = userAssets.skip(offset).take(resultLimit).toList();

    return {
      'code': '000000',
      'message': 'success',
      'data': {
        'list': paginatedAssets,
        'total': userAssets.length,
      },
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateGetNftAssetInfo({
    required String nftId,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateDataRetrievalDelay();
    }

    final userId = 'user_${apiKey?.hashCode ?? 'demo'}';
    final userAssets = _userAssets[userId] ?? [];

    final asset = userAssets.firstWhere(
      (asset) => asset['nftId'] == nftId,
      orElse: () => {},
    );

    if (asset.isEmpty) {
      return {
        'code': '404',
        'message': 'NFT not found',
        'data': null,
        'success': false,
      };
    }

    return {
      'code': '000000',
      'message': 'success',
      'data': asset,
      'success': true,
    };
  }

  Future<Map<String, dynamic>> simulateBuyNft({
    required String nftId,
    required double price,
    required String currency,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    final transactionId = _generateTransactionId();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // 90% success rate for NFT purchases
    final success = _random.nextDouble() < 0.9;

    if (success) {
      // Add to user's assets
      final userId = 'user_${apiKey?.hashCode ?? 'demo'}';
      if (!_userAssets.containsKey(userId)) {
        _userAssets[userId] = [];
      }

      final newAsset = _generateNftAsset(nftId);
      _userAssets[userId]!.add(newAsset);

      // Add to transaction history
      _transactionHistory.insert(0, {
        'orderId': transactionId,
        'nftId': nftId,
        'orderType': 0, // Buy
        'tradeTime': currentTime,
        'tradeAmount': price.toString(),
        'tradeCurrency': currency,
        'tradeStatus': 'SUCCESS',
        'buyerAddress': userId,
        'sellerAddress': 'marketplace_${_random.nextInt(99999)}',
        'transactionHash': _generateTransactionHash(),
        'blockNumber': _random.nextInt(999999999) + 15000000,
        'gasUsed': (_random.nextInt(200000) + 50000).toString(),
      });
    }

    return {
      'code': success ? '000000' : 'FAILED',
      'message': success ? 'Purchase successful' : 'Purchase failed',
      'data': success
          ? {
              'orderId': transactionId,
              'nftId': nftId,
              'status': 'SUCCESS',
              'transactionHash': _generateTransactionHash(),
            }
          : null,
      'success': success,
    };
  }

  Future<Map<String, dynamic>> simulateSellNft({
    required String nftId,
    required double price,
    required String currency,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    final userId = 'user_${apiKey?.hashCode ?? 'demo'}';
    final userAssets = _userAssets[userId] ?? [];

    // Check if user owns the NFT
    final assetIndex =
        userAssets.indexWhere((asset) => asset['nftId'] == nftId);
    if (assetIndex == -1) {
      return {
        'code': 'NOT_FOUND',
        'message': 'NFT not found in user assets',
        'data': null,
        'success': false,
      };
    }

    final transactionId = _generateTransactionId();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // 85% success rate for NFT sales
    final success = _random.nextDouble() < 0.85;

    if (success) {
      // Remove from user's assets
      userAssets.removeAt(assetIndex);

      // Add to transaction history
      _transactionHistory.insert(0, {
        'orderId': transactionId,
        'nftId': nftId,
        'orderType': 1, // Sell
        'tradeTime': currentTime,
        'tradeAmount': price.toString(),
        'tradeCurrency': currency,
        'tradeStatus': 'SUCCESS',
        'buyerAddress': 'buyer_${_random.nextInt(99999)}',
        'sellerAddress': userId,
        'transactionHash': _generateTransactionHash(),
        'blockNumber': _random.nextInt(999999999) + 15000000,
        'gasUsed': (_random.nextInt(200000) + 50000).toString(),
      });
    }

    return {
      'code': success ? '000000' : 'FAILED',
      'message': success ? 'Sale successful' : 'Sale failed',
      'data': success
          ? {
              'orderId': transactionId,
              'nftId': nftId,
              'status': 'SUCCESS',
              'transactionHash': _generateTransactionHash(),
            }
          : null,
      'success': success,
    };
  }

  Future<Map<String, dynamic>> simulateTransferNft({
    required String nftId,
    required String toAddress,
    bool enableSimulationDelay = true,
  }) async {
    if (enableSimulationDelay) {
      await _simulateTransactionDelay();
    }

    final userId = 'user_${apiKey?.hashCode ?? 'demo'}';
    final userAssets = _userAssets[userId] ?? [];

    // Check if user owns the NFT
    final assetIndex =
        userAssets.indexWhere((asset) => asset['nftId'] == nftId);
    if (assetIndex == -1) {
      return {
        'code': 'NOT_FOUND',
        'message': 'NFT not found in user assets',
        'data': null,
        'success': false,
      };
    }

    final transactionId = _generateTransactionId();
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    // 95% success rate for transfers
    final success = _random.nextDouble() < 0.95;

    if (success) {
      // Remove from user's assets (simulating transfer out)
      userAssets.removeAt(assetIndex);

      // Add to transaction history
      _transactionHistory.insert(0, {
        'orderId': transactionId,
        'nftId': nftId,
        'orderType': 2, // Transfer
        'tradeTime': currentTime,
        'tradeAmount': '0',
        'tradeCurrency': '',
        'tradeStatus': 'SUCCESS',
        'buyerAddress': toAddress,
        'sellerAddress': userId,
        'transactionHash': _generateTransactionHash(),
        'blockNumber': _random.nextInt(999999999) + 15000000,
        'gasUsed': (_random.nextInt(100000) + 25000).toString(),
      });
    }

    return {
      'code': success ? '000000' : 'FAILED',
      'message': success ? 'Transfer successful' : 'Transfer failed',
      'data': success
          ? {
              'orderId': transactionId,
              'nftId': nftId,
              'status': 'SUCCESS',
              'transactionHash': _generateTransactionHash(),
              'toAddress': toAddress,
            }
          : null,
      'success': success,
    };
  }

  // Helper methods
  Future<void> _simulateDataRetrievalDelay() async {
    final delay = 150 + _random.nextInt(350); // 150-500ms
    await Future.delayed(Duration(milliseconds: delay));
  }

  Future<void> _simulateTransactionDelay() async {
    final delay = 800 + _random.nextInt(2200); // 800ms-3s
    await Future.delayed(Duration(milliseconds: delay));
  }

  String _generateTransactionId() {
    return 'nft_${DateTime.now().millisecondsSinceEpoch}_${_random.nextInt(999999)}';
  }

  String _generateNftId() {
    return 'nft_${_random.nextInt(999999999)}';
  }

  String _generateTransactionHash() {
    const chars = '0123456789abcdef';
    return '0x' +
        String.fromCharCodes(Iterable.generate(
            64, (_) => chars.codeUnitAt(_random.nextInt(chars.length))));
  }

  Map<String, dynamic> _generateNftAsset(String? nftId) {
    final collections = _nftCollections.keys.toList();
    final collection =
        _nftCollections[collections[_random.nextInt(collections.length)]]!;
    final tokenId = _random.nextInt(collection['totalSupply'] as int) + 1;

    return {
      'nftId': nftId ?? _generateNftId(),
      'contractAddress': '0x${_generateRandomHexString(40)}',
      'tokenId': tokenId.toString(),
      'collectionName': collection['collectionName'],
      'collectionId': collection['collectionId'],
      'name': '${collection['collectionName']} #$tokenId',
      'description':
          'A unique NFT from the ${collection['collectionName']} collection',
      'imageUrl':
          'https://nft.binance.com/images/${collection['collectionId']}/$tokenId.png',
      'animationUrl': null,
      'externalUrl':
          'https://nft.binance.com/nft/${collection['collectionId']}/$tokenId',
      'attributes': _generateNftAttributes(),
      'creator': collection['creator'],
      'royalty': '${_random.nextInt(10) + 1}', // 1-10% royalty
      'status': 'ACTIVE',
      'network': 'BSC', // Binance Smart Chain
      'standard': 'BEP-721',
      'mintTime': DateTime.now().millisecondsSinceEpoch -
          (_random.nextInt(365 * 24 * 60 * 60 * 1000)),
    };
  }

  List<Map<String, dynamic>> _generateNftAttributes() {
    final attributeTypes = [
      'Background',
      'Eyes',
      'Mouth',
      'Accessory',
      'Rarity'
    ];
    final attributes = <Map<String, dynamic>>[];

    for (final type in attributeTypes) {
      if (_random.nextDouble() < 0.7) {
        // 70% chance of having each attribute
        attributes.add({
          'trait_type': type,
          'value': _getRandomAttributeValue(type),
          'rarity': _random.nextDouble(),
        });
      }
    }

    return attributes;
  }

  String _getRandomAttributeValue(String type) {
    final values = {
      'Background': ['Blue', 'Red', 'Green', 'Purple', 'Gold', 'Rainbow'],
      'Eyes': ['Normal', 'Laser', 'Sleepy', 'Wink', 'Star', 'Heart'],
      'Mouth': ['Smile', 'Frown', 'Open', 'Surprised', 'Cool', 'Angry'],
      'Accessory': ['Hat', 'Glasses', 'Earring', 'Necklace', 'Watch', 'None'],
      'Rarity': ['Common', 'Uncommon', 'Rare', 'Epic', 'Legendary'],
    };

    final typeValues = values[type] ?? ['Unknown'];
    return typeValues[_random.nextInt(typeValues.length)];
  }

  String _generateRandomHexString(int length) {
    const chars = '0123456789abcdef';
    return String.fromCharCodes(Iterable.generate(
        length, (_) => chars.codeUnitAt(_random.nextInt(chars.length))));
  }

  void _generateMockTransactionHistory() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < 20; i++) {
      final orderType = _random.nextInt(3); // 0=Buy, 1=Sell, 2=Transfer
      final time = currentTime - (i * 6 * 60 * 60 * 1000); // 6-hour intervals
      final price = orderType == 2 ? 0.0 : _random.nextDouble() * 10 + 0.1;

      _transactionHistory.add({
        'orderId': _generateTransactionId(),
        'nftId': _generateNftId(),
        'orderType': orderType,
        'tradeTime': time,
        'tradeAmount': price.toStringAsFixed(4),
        'tradeCurrency':
            orderType == 2 ? '' : ['BNB', 'ETH', 'USDT'][_random.nextInt(3)],
        'tradeStatus': _random.nextDouble() < 0.95 ? 'SUCCESS' : 'FAILED',
        'buyerAddress': 'buyer_${_random.nextInt(99999)}',
        'sellerAddress': 'seller_${_random.nextInt(99999)}',
        'transactionHash': _generateTransactionHash(),
        'blockNumber': _random.nextInt(999999999) + 15000000,
        'gasUsed': (_random.nextInt(200000) + 50000).toString(),
      });
    }
  }

  void _generateMockDepositHistory() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < 5; i++) {
      final time = currentTime - (i * 24 * 60 * 60 * 1000); // Daily intervals

      _depositHistory.add({
        'depositId': 'dep_${time}_${_random.nextInt(9999)}',
        'nftId': _generateNftId(),
        'contractAddress': '0x${_generateRandomHexString(40)}',
        'tokenId': (_random.nextInt(9999) + 1).toString(),
        'fromAddress': '0x${_generateRandomHexString(40)}',
        'network': 'BSC',
        'timestamp': time,
        'status': _random.nextDouble() < 0.95 ? 'SUCCESS' : 'PENDING',
        'transactionHash': _generateTransactionHash(),
        'blockNumber': _random.nextInt(999999999) + 15000000,
      });
    }
  }

  void _generateMockWithdrawHistory() {
    final currentTime = DateTime.now().millisecondsSinceEpoch;

    for (int i = 0; i < 3; i++) {
      final time = currentTime - (i * 48 * 60 * 60 * 1000); // 2-day intervals

      _withdrawHistory.add({
        'withdrawId': 'with_${time}_${_random.nextInt(9999)}',
        'nftId': _generateNftId(),
        'contractAddress': '0x${_generateRandomHexString(40)}',
        'tokenId': (_random.nextInt(9999) + 1).toString(),
        'toAddress': '0x${_generateRandomHexString(40)}',
        'network': 'BSC',
        'timestamp': time,
        'status': _random.nextDouble() < 0.9 ? 'SUCCESS' : 'PENDING',
        'transactionHash': _generateTransactionHash(),
        'blockNumber': _random.nextInt(999999999) + 15000000,
        'fee': (_random.nextDouble() * 0.01 + 0.001).toStringAsFixed(6),
        'feeCurrency': 'BNB',
      });
    }
  }

  void _generateMockUserAssets(String userId) {
    final assets = <Map<String, dynamic>>[];
    final assetCount = 2 + _random.nextInt(8); // 2-10 NFTs

    for (int i = 0; i < assetCount; i++) {
      assets.add(_generateNftAsset(null));
    }

    _userAssets[userId] = assets;
  }
}