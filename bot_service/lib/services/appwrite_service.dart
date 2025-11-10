import 'dart:io';
import 'package:dart_appwrite/dart_appwrite.dart';
import 'package:logging/logging.dart';
import '../models/watchlist_item.dart';
import '../models/trade_record.dart';
import '../models/price_alert.dart';

/// Service for interacting with Appwrite backend
class AppwriteService {
  final Client _client;
  final Databases _databases;
  final Logger _log = Logger('AppwriteService');

  final String databaseId;
  final String watchlistCollectionId;
  final String tradesCollectionId;
  final String algorithmsCollectionId;
  final String portfoliosCollectionId;
  final String alertsCollectionId;

  AppwriteService({
    required String endpoint,
    required String projectId,
    required String apiKey,
    required this.databaseId,
    required this.watchlistCollectionId,
    required this.tradesCollectionId,
    required this.algorithmsCollectionId,
    required this.portfoliosCollectionId,
    String? alertsCollectionId,
  })  : alertsCollectionId = alertsCollectionId ?? 'price_alerts',
        _client = Client()
            .setEndpoint(endpoint)
            .setProject(projectId)
            .setKey(apiKey),
        _databases = Databases(Client()
            .setEndpoint(endpoint)
            .setProject(projectId)
            .setKey(apiKey));

  /// Get active watchlist items for a user
  Future<List<WatchlistItem>> getActiveWatchlist(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: watchlistCollectionId,
        queries: [
          Query.equal('user_id', userId),
          Query.equal('active', true),
        ],
      );

      return response.documents
          .map((doc) => WatchlistItem.fromJson(doc.data))
          .toList();
    } catch (e) {
      _log.severe('Failed to get watchlist: $e');
      return [];
    }
  }

  /// Add item to watchlist
  Future<void> addToWatchlist(WatchlistItem item) async {
    try {
      await _databases.createDocument(
        databaseId: databaseId,
        collectionId: watchlistCollectionId,
        documentId: ID.unique(),
        data: item.toJson(),
      );
      _log.info('Added ${item.symbol} to watchlist');
    } catch (e) {
      _log.severe('Failed to add to watchlist: $e');
      rethrow;
    }
  }

  /// Save trade record to database
  Future<void> saveTrade(TradeRecord trade) async {
    try {
      await _databases.createDocument(
        databaseId: databaseId,
        collectionId: tradesCollectionId,
        documentId: ID.unique(),
        data: trade.toJson(),
      );
      _log.info('Saved trade: ${trade.symbol} ${trade.side} ${trade.quantity}');
    } catch (e) {
      _log.severe('Failed to save trade: $e');
      // Don't rethrow - we don't want to stop trading because of DB issues
    }
  }

  /// Get recent trades
  Future<List<TradeRecord>> getRecentTrades(String userId, {int limit = 100}) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: tradesCollectionId,
        queries: [
          Query.equal('user_id', userId),
          Query.orderDesc('timestamp'),
          Query.limit(limit),
        ],
      );

      return response.documents
          .map((doc) => TradeRecord.fromJson(doc.data))
          .toList();
    } catch (e) {
      _log.severe('Failed to get trades: $e');
      return [];
    }
  }

  /// Get total profit/loss for a user
  Future<double> getTotalProfitLoss(String userId) async {
    try {
      final trades = await getRecentTrades(userId, limit: 1000);

      double totalPL = 0;
      Map<String, double> positions = {}; // symbol -> quantity

      for (final trade in trades.reversed) {
        if (trade.side == 'BUY') {
          positions[trade.symbol] = (positions[trade.symbol] ?? 0) + trade.quantity;
        } else {
          final quantity = positions[trade.symbol] ?? 0;
          if (quantity > 0) {
            // Calculate P&L for this sell
            final sellValue = trade.totalValue;
            // This is simplified - in reality you'd need to track average buy price
            positions[trade.symbol] = quantity - trade.quantity;
          }
        }
      }

      return totalPL;
    } catch (e) {
      _log.severe('Failed to calculate P&L: $e');
      return 0;
    }
  }

  /// Get active price alerts for a user
  Future<List<PriceAlert>> getActiveAlerts(String userId) async {
    try {
      final response = await _databases.listDocuments(
        databaseId: databaseId,
        collectionId: alertsCollectionId,
        queries: [
          Query.equal('user_id', userId),
          Query.equal('active', true),
          Query.equal('triggered', false),
        ],
      );

      return response.documents
          .map((doc) => PriceAlert.fromJson(doc.$id, doc.data))
          .toList();
    } catch (e) {
      _log.severe('Failed to get active alerts: $e');
      return [];
    }
  }

  /// Create a new price alert
  Future<void> createAlert(PriceAlert alert) async {
    try {
      await _databases.createDocument(
        databaseId: databaseId,
        collectionId: alertsCollectionId,
        documentId: ID.unique(),
        data: alert.toJson(),
      );

      _log.info('✅ Alert created: ${alert.symbol}');
    } catch (e) {
      _log.severe('Failed to create alert: $e');
      rethrow;
    }
  }

  /// Update an alert (e.g., mark as triggered)
  Future<void> updateAlert(String alertId, Map<String, dynamic> data) async {
    try {
      await _databases.updateDocument(
        databaseId: databaseId,
        collectionId: alertsCollectionId,
        documentId: alertId,
        data: data,
      );

      _log.info('✅ Alert updated: $alertId');
    } catch (e) {
      _log.severe('Failed to update alert: $e');
      rethrow;
    }
  }

  /// Delete an alert
  Future<void> deleteAlert(String alertId) async {
    try {
      await _databases.deleteDocument(
        databaseId: databaseId,
        collectionId: alertsCollectionId,
        documentId: alertId,
      );

      _log.info('✅ Alert deleted: $alertId');
    } catch (e) {
      _log.severe('Failed to delete alert: $e');
      rethrow;
    }
  }

  /// Health check - verify connection to Appwrite
  Future<bool> healthCheck() async {
    try {
      await _databases.list();
      return true;
    } catch (e) {
      _log.severe('Appwrite health check failed: $e');
      return false;
    }
  }
}
