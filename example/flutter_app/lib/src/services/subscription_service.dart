import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import '../config/app_config.dart';

final subscriptionServiceProvider = Provider((ref) => SubscriptionService());

class SubscriptionService {
  Future<void> initialize() async {
    await Purchases.setLogLevel(LogLevel.debug);

    PurchasesConfiguration configuration;
    configuration = PurchasesConfiguration(AppConfig.revenueCatApiKey)
      ..appUserID = null
      ..observerMode = false;

    await Purchases.configure(configuration);
  }

  Future<Offerings?> getOfferings() async {
    try {
      return await Purchases.getOfferings();
    } catch (e) {
      return null;
    }
  }

  Future<CustomerInfo> purchasePackage(Package package) async {
    try {
      final purchaserInfo = await Purchases.purchasePackage(package);
      return purchaserInfo.customerInfo;
    } catch (e) {
      rethrow;
    }
  }

  Future<CustomerInfo> restorePurchases() async {
    try {
      return await Purchases.restorePurchases();
    } catch (e) {
      rethrow;
    }
  }

  Future<CustomerInfo> getCustomerInfo() async {
    return await Purchases.getCustomerInfo();
  }

  Future<bool> isSubscriptionActive() async {
    final customerInfo = await getCustomerInfo();
    return customerInfo.entitlements.active.isNotEmpty;
  }

  Stream<CustomerInfo> get customerInfoStream {
    return Purchases.customerInfoStream;
  }
}
