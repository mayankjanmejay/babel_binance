class AppConfig {
  // Firebase Configuration
  static const String firebaseProjectId = 'babel-binance-app';

  // Sentry Configuration
  static const String sentryDsn = 'YOUR_SENTRY_DSN_HERE';

  // RevenueCat Configuration
  static const String revenueCatApiKey = 'YOUR_REVENUECAT_API_KEY';
  static const String revenueCatAppleKey = 'YOUR_APPLE_KEY';
  static const String revenueCatGoogleKey = 'YOUR_GOOGLE_KEY';

  // Stripe Configuration
  static const String stripePublishableKey = 'YOUR_STRIPE_PUBLISHABLE_KEY';

  // Mixpanel Configuration
  static const String mixpanelToken = 'YOUR_MIXPANEL_TOKEN';

  // AI Configuration
  static const String geminiApiKey = 'YOUR_GEMINI_API_KEY';

  // White Label Configuration
  static const String appName = 'Babel Binance';
  static const String appLogo = 'assets/images/logo.png';
  static const String primaryColor = '#1E88E5';
  static const String accentColor = '#FFC107';

  // Feature Flags
  static const bool enableSubscriptions = true;
  static const bool enableBiometrics = true;
  static const bool enableGeofencing = true;
  static const bool enableAIChat = true;
  static const bool enableVideoRecording = true;
  static const bool enableAnalytics = true;

  // API Configuration
  static const String binanceApiKey = '';
  static const String binanceApiSecret = '';

  // Performance Configuration
  static const int cacheExpirationMinutes = 30;
  static const int maxCachedItems = 100;
  static const int apiTimeoutSeconds = 30;
}
