import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mixpanel_flutter/mixpanel_flutter.dart';
import '../config/app_config.dart';

final analyticsServiceProvider = Provider((ref) => AnalyticsService());

class AnalyticsService {
  late FirebaseAnalytics _firebaseAnalytics;
  Mixpanel? _mixpanel;

  Future<void> initialize() async {
    _firebaseAnalytics = FirebaseAnalytics.instance;

    if (AppConfig.enableAnalytics) {
      _mixpanel = await Mixpanel.init(
        AppConfig.mixpanelToken,
        trackAutomaticEvents: true,
      );
    }
  }

  Future<void> logEvent(String eventName, {Map<String, dynamic>? parameters}) async {
    await _firebaseAnalytics.logEvent(
      name: eventName,
      parameters: parameters,
    );

    _mixpanel?.track(eventName, properties: parameters);
  }

  Future<void> setUserId(String userId) async {
    await _firebaseAnalytics.setUserId(id: userId);
    _mixpanel?.identify(userId);
  }

  Future<void> setUserProperty(String name, String value) async {
    await _firebaseAnalytics.setUserProperty(name: name, value: value);
    _mixpanel?.getPeople().set(name, value);
  }

  Future<void> logScreenView(String screenName) async {
    await _firebaseAnalytics.logScreenView(screenName: screenName);
    _mixpanel?.track('\$screen_view', properties: {'screen_name': screenName});
  }

  Future<void> logPurchase({
    required double value,
    required String currency,
    required String itemId,
  }) async {
    await _firebaseAnalytics.logPurchase(
      value: value,
      currency: currency,
    );

    _mixpanel?.getPeople().trackCharge(value, properties: {
      'currency': currency,
      'item_id': itemId,
    });
  }
}
