class DatabaseStructure {
  static Map<String, dynamic> getDefaultStructure() {
    return {
      'databaseId': 'babel_binance_db',
      'name': 'Babel Binance Database',
      'collections': [
        {
          'collectionId': 'users',
          'name': 'Users',
          'attributes': [
            {
              'key': 'displayName',
              'type': 'string',
              'size': 255,
              'required': true,
            },
            {
              'key': 'bio',
              'type': 'string',
              'size': 1000,
              'required': false,
            },
            {
              'key': 'avatar',
              'type': 'string',
              'size': 500,
              'required': false,
            },
            {
              'key': 'preferences',
              'type': 'string',
              'size': 5000,
              'required': false,
              'default': '{}',
            },
            {
              'key': 'subscriptionTier',
              'type': 'string',
              'size': 50,
              'required': false,
              'default': 'free',
            },
            {
              'key': 'isActive',
              'type': 'boolean',
              'required': true,
              'default': true,
            },
          ],
        },
        {
          'collectionId': 'trades',
          'name': 'Trades',
          'attributes': [
            {
              'key': 'userId',
              'type': 'string',
              'size': 255,
              'required': true,
            },
            {
              'key': 'symbol',
              'type': 'string',
              'size': 20,
              'required': true,
            },
            {
              'key': 'side',
              'type': 'string',
              'size': 10,
              'required': true,
            },
            {
              'key': 'type',
              'type': 'string',
              'size': 20,
              'required': true,
            },
            {
              'key': 'quantity',
              'type': 'string',
              'size': 50,
              'required': true,
            },
            {
              'key': 'price',
              'type': 'string',
              'size': 50,
              'required': true,
            },
            {
              'key': 'status',
              'type': 'string',
              'size': 20,
              'required': true,
            },
            {
              'key': 'orderId',
              'type': 'string',
              'size': 100,
              'required': false,
            },
            {
              'key': 'executedAt',
              'type': 'datetime',
              'required': false,
            },
          ],
        },
        {
          'collectionId': 'portfolios',
          'name': 'Portfolios',
          'attributes': [
            {
              'key': 'userId',
              'type': 'string',
              'size': 255,
              'required': true,
            },
            {
              'key': 'name',
              'type': 'string',
              'size': 255,
              'required': true,
            },
            {
              'key': 'description',
              'type': 'string',
              'size': 1000,
              'required': false,
            },
            {
              'key': 'assets',
              'type': 'string',
              'size': 10000,
              'required': false,
              'default': '[]',
            },
            {
              'key': 'totalValue',
              'type': 'string',
              'size': 50,
              'required': false,
              'default': '0',
            },
            {
              'key': 'isDefault',
              'type': 'boolean',
              'required': false,
              'default': false,
            },
          ],
        },
        {
          'collectionId': 'watchlist',
          'name': 'Watchlist',
          'attributes': [
            {
              'key': 'userId',
              'type': 'string',
              'size': 255,
              'required': true,
            },
            {
              'key': 'symbol',
              'type': 'string',
              'size': 20,
              'required': true,
            },
            {
              'key': 'notes',
              'type': 'string',
              'size': 1000,
              'required': false,
            },
            {
              'key': 'priceAlert',
              'type': 'string',
              'size': 50,
              'required': false,
            },
            {
              'key': 'addedAt',
              'type': 'datetime',
              'required': true,
            },
          ],
        },
        {
          'collectionId': 'analytics',
          'name': 'Analytics',
          'attributes': [
            {
              'key': 'userId',
              'type': 'string',
              'size': 255,
              'required': true,
            },
            {
              'key': 'eventType',
              'type': 'string',
              'size': 100,
              'required': true,
            },
            {
              'key': 'eventData',
              'type': 'string',
              'size': 5000,
              'required': false,
              'default': '{}',
            },
            {
              'key': 'timestamp',
              'type': 'datetime',
              'required': true,
            },
          ],
        },
      ],
    };
  }

  static Map<String, dynamic> getCustomStructure({
    required String databaseId,
    required String databaseName,
    required List<Map<String, dynamic>> collections,
  }) {
    return {
      'databaseId': databaseId,
      'name': databaseName,
      'collections': collections,
    };
  }
}
