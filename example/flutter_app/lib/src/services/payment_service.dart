import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:stripe_flutter/stripe_flutter.dart';
import '../config/app_config.dart';

final paymentServiceProvider = Provider((ref) => PaymentService());

class PaymentService {
  Future<void> initialize() async {
    Stripe.publishableKey = AppConfig.stripePublishableKey;
    await Stripe.instance.applySettings();
  }

  Future<PaymentIntent?> createPaymentIntent({
    required int amount,
    required String currency,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      // In production, call your backend to create payment intent
      // This is just a placeholder
      return null;
    } catch (e) {
      return null;
    }
  }

  Future<bool> processPayment({
    required String paymentIntentClientSecret,
    required BuildContext context,
  }) async {
    try {
      final paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: paymentIntentClientSecret,
      );

      return paymentIntent.status == PaymentIntentsStatus.Succeeded;
    } catch (e) {
      return false;
    }
  }

  Future<void> presentPaymentSheet() async {
    try {
      await Stripe.instance.presentPaymentSheet();
    } catch (e) {
      rethrow;
    }
  }
}
