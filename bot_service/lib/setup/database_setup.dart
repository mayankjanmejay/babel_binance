import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:logging/logging.dart';

/// Database Setup Service
/// Automatically creates database and collections on first run

class DatabaseSetup {
  final Client client;
  final Databases databases;
  final Logger _log = Logger('DatabaseSetup');

  final String databaseId;
  final String watchlistCollectionId;
  final String tradesCollectionId;
  final String algorithmsCollectionId;
  final String portfoliosCollectionId;
  final String botConfigsCollectionId;
  final String alertsCollectionId;

  DatabaseSetup({
    required this.client,
    required this.databaseId,
    required this.watchlistCollectionId,
    required this.tradesCollectionId,
    required this.algorithmsCollectionId,
    required this.portfoliosCollectionId,
    required this.botConfigsCollectionId,
    required this.alertsCollectionId,
  }) : databases = Databases(client);

  /// Run complete database setup
  Future<bool> setup() async {
    try {
      _log.info('🔧 Starting database setup...');

      // Step 1: Ensure database exists
      await _ensureDatabase();

      // Step 2: Create all collections
      await _ensureWatchlistCollection();
      await _ensureTradesCollection();
      await _ensureAlgorithmsCollection();
      await _ensurePortfoliosCollection();
      await _ensureBotConfigsCollection();
      await _ensureAlertsCollection();

      _log.info('✅ Database setup complete!');
      return true;
    } catch (e, stack) {
      _log.severe('❌ Database setup failed: $e\n$stack');
      return false;
    }
  }

  /// Ensure database exists
  Future<void> _ensureDatabase() async {
    try {
      await databases.get(databaseId: databaseId);
      _log.info('✓ Database "$databaseId" already exists');
    } catch (e) {
      _log.info('Creating database "$databaseId"...');
      await databases.create(
        databaseId: databaseId,
        name: 'Crypto Trading Database',
      );
      _log.info('✓ Database created');
    }
  }

  /// Ensure watchlist collection exists
  Future<void> _ensureWatchlistCollection() async {
    try {
      await databases.getCollection(
        databaseId: databaseId,
        collectionId: watchlistCollectionId,
      );
      _log.info('✓ Watchlist collection already exists');
    } catch (e) {
      _log.info('Creating watchlist collection...');

      await databases.createCollection(
        databaseId: databaseId,
        collectionId: watchlistCollectionId,
        name: 'Watchlist',
        permissions: [
          Permission.read(Role.any()),
          Permission.create(Role.any()),
          Permission.update(Role.any()),
          Permission.delete(Role.any()),
        ],
      );

      // Create attributes
      await databases.createStringAttribute(
        databaseId: databaseId,
        collectionId: watchlistCollectionId,
        key: 'user_id',
        size: 255,
        xrequired: true,
      );

      await databases.createStringAttribute(
        databaseId: databaseId,
        collectionId: watchlistCollectionId,
        key: 'symbol',
        size: 50,
        xrequired: true,
      );

      await databases.createFloatAttribute(
        databaseId: databaseId,
        collectionId: watchlistCollectionId,
        key: 'target_buy',
        xrequired: false,
      );

      await databases.createFloatAttribute(
        databaseId: databaseId,
        collectionId: watchlistCollectionId,
        key: 'target_sell',
        xrequired: false,
      );

      await databases.createBooleanAttribute(
        databaseId: databaseId,
        collectionId: watchlistCollectionId,
        key: 'active',
        xrequired: true,
        xdefault: true,
      );

      await databases.createDatetimeAttribute(
        databaseId: databaseId,
        collectionId: watchlistCollectionId,
        key: 'created_at',
        xrequired: true,
      );

      // Wait for attributes to be ready
      await Future.delayed(Duration(seconds: 2));

      // Create indexes
      await databases.createIndex(
        databaseId: databaseId,
        collectionId: watchlistCollectionId,
        key: 'user_id_idx',
        type: 'key',
        attributes: ['user_id'],
      );

      _log.info('✓ Watchlist collection created');
    }
  }

  /// Ensure trades collection exists
  Future<void> _ensureTradesCollection() async {
    try {
      await databases.getCollection(
        databaseId: databaseId,
        collectionId: tradesCollectionId,
      );
      _log.info('✓ Trades collection already exists');
    } catch (e) {
      _log.info('Creating trades collection...');

      await databases.createCollection(
        databaseId: databaseId,
        collectionId: tradesCollectionId,
        name: 'Trades',
        permissions: [
          Permission.read(Role.any()),
          Permission.create(Role.any()),
          Permission.update(Role.any()),
          Permission.delete(Role.any()),
        ],
      );

      // Create attributes
      final attributes = [
        {'key': 'user_id', 'size': 255},
        {'key': 'symbol', 'size': 50},
        {'key': 'side', 'size': 10},
        {'key': 'algorithm_name', 'size': 100},
        {'key': 'order_id', 'size': 255},
        {'key': 'status', 'size': 50},
      ];

      for (final attr in attributes) {
        await databases.createStringAttribute(
          databaseId: databaseId,
          collectionId: tradesCollectionId,
          key: attr['key'] as String,
          size: attr['size'] as int,
          xrequired: true,
        );
      }

      await databases.createFloatAttribute(
        databaseId: databaseId,
        collectionId: tradesCollectionId,
        key: 'quantity',
        xrequired: true,
      );

      await databases.createFloatAttribute(
        databaseId: databaseId,
        collectionId: tradesCollectionId,
        key: 'price',
        xrequired: true,
      );

      await databases.createFloatAttribute(
        databaseId: databaseId,
        collectionId: tradesCollectionId,
        key: 'total_value',
        xrequired: true,
      );

      await databases.createDatetimeAttribute(
        databaseId: databaseId,
        collectionId: tradesCollectionId,
        key: 'timestamp',
        xrequired: true,
      );

      await Future.delayed(Duration(seconds: 2));

      await databases.createIndex(
        databaseId: databaseId,
        collectionId: tradesCollectionId,
        key: 'timestamp_idx',
        type: 'key',
        attributes: ['timestamp'],
        orders: ['DESC'],
      );

      _log.info('✓ Trades collection created');
    }
  }

  /// Ensure algorithms collection exists
  Future<void> _ensureAlgorithmsCollection() async {
    try {
      await databases.getCollection(
        databaseId: databaseId,
        collectionId: algorithmsCollectionId,
      );
      _log.info('✓ Algorithms collection already exists');
    } catch (e) {
      _log.info('Creating algorithms collection...');

      await databases.createCollection(
        databaseId: databaseId,
        collectionId: algorithmsCollectionId,
        name: 'Algorithms',
        permissions: [
          Permission.read(Role.any()),
          Permission.create(Role.any()),
          Permission.update(Role.any()),
          Permission.delete(Role.any()),
        ],
      );

      _log.info('✓ Algorithms collection created');
    }
  }

  /// Ensure portfolios collection exists
  Future<void> _ensurePortfoliosCollection() async {
    try {
      await databases.getCollection(
        databaseId: databaseId,
        collectionId: portfoliosCollectionId,
      );
      _log.info('✓ Portfolios collection already exists');
    } catch (e) {
      _log.info('Creating portfolios collection...');

      await databases.createCollection(
        databaseId: databaseId,
        collectionId: portfoliosCollectionId,
        name: 'Portfolios',
        permissions: [
          Permission.read(Role.any()),
          Permission.create(Role.any()),
          Permission.update(Role.any()),
          Permission.delete(Role.any()),
        ],
      );

      _log.info('✓ Portfolios collection created');
    }
  }

  /// Ensure bot_configs collection exists
  Future<void> _ensureBotConfigsCollection() async {
    try {
      await databases.getCollection(
        databaseId: databaseId,
        collectionId: botConfigsCollectionId,
      );
      _log.info('✓ Bot Configs collection already exists');
    } catch (e) {
      _log.info('Creating bot configs collection...');

      await databases.createCollection(
        databaseId: databaseId,
        collectionId: botConfigsCollectionId,
        name: 'Bot Configurations',
        permissions: [
          Permission.read(Role.any()),
          Permission.create(Role.any()),
          Permission.update(Role.any()),
          Permission.delete(Role.any()),
        ],
      );

      _log.info('✓ Bot Configs collection created');
    }
  }

  /// Ensure price_alerts collection exists
  Future<void> _ensureAlertsCollection() async {
    try {
      await databases.getCollection(
        databaseId: databaseId,
        collectionId: alertsCollectionId,
      );
      _log.info('✓ Price Alerts collection already exists');
    } catch (e) {
      _log.info('Creating price alerts collection...');

      await databases.createCollection(
        databaseId: databaseId,
        collectionId: alertsCollectionId,
        name: 'Price Alerts',
        permissions: [
          Permission.read(Role.any()),
          Permission.create(Role.any()),
          Permission.update(Role.any()),
          Permission.delete(Role.any()),
        ],
      );

      // Create attributes
      await databases.createStringAttribute(
        databaseId: databaseId,
        collectionId: alertsCollectionId,
        key: 'user_id',
        size: 255,
        xrequired: true,
      );

      await databases.createStringAttribute(
        databaseId: databaseId,
        collectionId: alertsCollectionId,
        key: 'symbol',
        size: 50,
        xrequired: true,
      );

      await databases.createStringAttribute(
        databaseId: databaseId,
        collectionId: alertsCollectionId,
        key: 'condition',
        size: 20,
        xrequired: true,
      );

      await databases.createFloatAttribute(
        databaseId: databaseId,
        collectionId: alertsCollectionId,
        key: 'target_price',
        xrequired: true,
      );

      await databases.createBooleanAttribute(
        databaseId: databaseId,
        collectionId: alertsCollectionId,
        key: 'active',
        xrequired: true,
        xdefault: true,
      );

      await databases.createBooleanAttribute(
        databaseId: databaseId,
        collectionId: alertsCollectionId,
        key: 'triggered',
        xrequired: true,
        xdefault: false,
      );

      await databases.createStringAttribute(
        databaseId: databaseId,
        collectionId: alertsCollectionId,
        key: 'message',
        size: 500,
        xrequired: false,
      );

      await databases.createDatetimeAttribute(
        databaseId: databaseId,
        collectionId: alertsCollectionId,
        key: 'created_at',
        xrequired: true,
      );

      await Future.delayed(Duration(seconds: 2));

      await databases.createIndex(
        databaseId: databaseId,
        collectionId: alertsCollectionId,
        key: 'user_id_active_idx',
        type: 'key',
        attributes: ['user_id', 'active'],
      );

      _log.info('✓ Price Alerts collection created');
    }
  }
}
