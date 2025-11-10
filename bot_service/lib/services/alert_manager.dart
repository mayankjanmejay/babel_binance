import 'package:logging/logging.dart';
import '../models/price_alert.dart';
import 'appwrite_service.dart';
import 'email_service.dart';

/// Alert Manager Service
/// Manages price alerts and triggers notifications when conditions are met

class AlertManager {
  final AppwriteService appwrite;
  final EmailService? emailService;
  final String userId;
  final Logger _log = Logger('AlertManager');

  final List<PriceAlert> _activeAlerts = [];
  DateTime? _lastRefresh;

  AlertManager({
    required this.appwrite,
    this.emailService,
    required this.userId,
  });

  /// Load active alerts from database
  Future<void> loadAlerts() async {
    try {
      final alerts = await appwrite.getActiveAlerts(userId);
      _activeAlerts.clear();
      _activeAlerts.addAll(alerts);
      _lastRefresh = DateTime.now();

      _log.info('Loaded ${_activeAlerts.length} active alerts');
    } catch (e) {
      _log.warning('Failed to load alerts: $e');
    }
  }

  /// Check all active alerts against current prices
  Future<List<PriceAlert>> checkAlerts(Map<String, double> currentPrices) async {
    final triggeredAlerts = <PriceAlert>[];

    // Refresh alerts periodically
    if (_lastRefresh == null ||
        DateTime.now().difference(_lastRefresh!).inMinutes > 5) {
      await loadAlerts();
    }

    for (final alert in _activeAlerts) {
      final currentPrice = currentPrices[alert.symbol];
      if (currentPrice == null) continue;

      if (alert.shouldTrigger(currentPrice)) {
        _log.info('🔔 Alert triggered: ${alert.symbol} ${alert.condition.toString().split('.').last} \$${alert.targetPrice}');
        _log.info('   Current price: \$${currentPrice.toStringAsFixed(2)}');

        triggeredAlerts.add(alert);

        // Mark alert as triggered in database
        await _markAsTriggered(alert, currentPrice);

        // Send notification
        await _sendNotification(alert, currentPrice);
      }
    }

    // Remove triggered alerts from active list
    _activeAlerts.removeWhere((a) => triggeredAlerts.contains(a));

    return triggeredAlerts;
  }

  /// Add a new alert
  Future<void> addAlert({
    required String symbol,
    required AlertCondition condition,
    required double targetPrice,
    String? message,
  }) async {
    try {
      final alert = PriceAlert(
        id: '', // Will be set by Appwrite
        userId: userId,
        symbol: symbol,
        condition: condition,
        targetPrice: targetPrice,
        message: message,
        createdAt: DateTime.now(),
      );

      await appwrite.createAlert(alert);
      _log.info('✅ Alert created: $alert');

      // Reload alerts
      await loadAlerts();
    } catch (e) {
      _log.severe('Failed to create alert: $e');
      rethrow;
    }
  }

  /// Remove an alert
  Future<void> removeAlert(String alertId) async {
    try {
      await appwrite.deleteAlert(alertId);
      _activeAlerts.removeWhere((a) => a.id == alertId);
      _log.info('✅ Alert removed: $alertId');
    } catch (e) {
      _log.warning('Failed to remove alert: $e');
      rethrow;
    }
  }

  /// Get all active alerts
  List<PriceAlert> getActiveAlerts() {
    return List.unmodifiable(_activeAlerts);
  }

  /// Mark alert as triggered in database
  Future<void> _markAsTriggered(PriceAlert alert, double triggeredPrice) async {
    try {
      await appwrite.updateAlert(
        alert.id,
        {
          'triggered': true,
          'triggeredAt': DateTime.now().toIso8601String(),
          'active': false,
        },
      );
    } catch (e) {
      _log.warning('Failed to mark alert as triggered: $e');
    }
  }

  /// Send notification when alert triggers
  Future<void> _sendNotification(PriceAlert alert, double currentPrice) async {
    if (emailService == null) return;

    try {
      final conditionText = _getConditionText(alert.condition);
      final subject = '🔔 Price Alert: ${alert.symbol} $conditionText \$${alert.targetPrice.toStringAsFixed(2)}';

      final body = '''
<!DOCTYPE html>
<html>
<head>
  <style>
    body { font-family: Arial, sans-serif; line-height: 1.6; color: #333; }
    .container { max-width: 600px; margin: 0 auto; padding: 20px; }
    .header { background: linear-gradient(135deg, #667eea 0%, #764ba2 100%); color: white; padding: 30px; border-radius: 10px 10px 0 0; text-align: center; }
    .content { background: #f9fafb; padding: 30px; border-radius: 0 0 10px 10px; }
    .alert-box { background: white; border-left: 4px solid #667eea; padding: 20px; margin: 20px 0; border-radius: 5px; }
    .price { font-size: 2em; font-weight: bold; color: #667eea; margin: 10px 0; }
    .detail { margin: 10px 0; padding: 10px; background: #f3f4f6; border-radius: 5px; }
    .footer { text-align: center; margin-top: 20px; font-size: 0.9em; color: #6b7280; }
  </style>
</head>
<body>
  <div class="container">
    <div class="header">
      <h1>🔔 Price Alert Triggered!</h1>
    </div>
    <div class="content">
      <div class="alert-box">
        <h2>${alert.symbol}</h2>
        <div class="detail">
          <strong>Condition:</strong> Price $conditionText \$${alert.targetPrice.toStringAsFixed(2)}
        </div>
        <div class="detail">
          <strong>Current Price:</strong>
          <div class="price">\$${currentPrice.toStringAsFixed(2)}</div>
        </div>
        <div class="detail">
          <strong>Time:</strong> ${DateTime.now().toIso8601String()}
        </div>
        ${alert.message != null ? '<div class="detail"><strong>Note:</strong> ${alert.message}</div>' : ''}
      </div>
      <p>This alert has been automatically deactivated. You can create a new alert if needed.</p>
      <div class="footer">
        <p>Crypto Trading Bot - Automated Price Alerts</p>
      </div>
    </div>
  </div>
</body>
</html>
''';

      await emailService!.sendEmail(
        subject: subject,
        htmlContent: body,
        textContent: 'Price Alert: ${alert.symbol} $conditionText \$${alert.targetPrice.toStringAsFixed(2)}. Current price: \$${currentPrice.toStringAsFixed(2)}',
      );

      _log.info('✉️  Alert notification sent via email');
    } catch (e) {
      _log.warning('Failed to send alert notification: $e');
    }
  }

  /// Get human-readable condition text
  String _getConditionText(AlertCondition condition) {
    switch (condition) {
      case AlertCondition.above:
        return 'above';
      case AlertCondition.below:
        return 'below';
      case AlertCondition.crosses:
        return 'crosses';
    }
  }

  /// Get statistics
  Map<String, dynamic> getStatistics() {
    return {
      'active_alerts': _activeAlerts.length,
      'symbols_monitored': _activeAlerts.map((a) => a.symbol).toSet().length,
    };
  }
}
