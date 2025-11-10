import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:sentry_flutter/sentry_flutter.dart';

import 'src/config/app_config.dart';
import 'src/config/theme_config.dart';
import 'src/services/analytics_service.dart';
import 'src/services/auth_service.dart';
import 'src/screens/splash_screen.dart';
import 'src/i18n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase
  await Firebase.initializeApp();

  // Initialize Sentry for error tracking
  await SentryFlutter.init(
    (options) {
      options.dsn = AppConfig.sentryDsn;
      options.tracesSampleRate = 1.0;
      options.enableAutoPerformanceTracing = true;
    },
    appRunner: () => runApp(
      const ProviderScope(
        child: BabelBinanceApp(),
      ),
    ),
  );
}

class BabelBinanceApp extends ConsumerStatefulWidget {
  const BabelBinanceApp({super.key});

  @override
  ConsumerState<BabelBinanceApp> createState() => _BabelBinanceAppState();
}

class _BabelBinanceAppState extends ConsumerState<BabelBinanceApp> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    // Initialize analytics
    await ref.read(analyticsServiceProvider).initialize();

    // Initialize auth
    await ref.read(authServiceProvider).initialize();
  }

  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: const Size(375, 812),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (context, child) {
        return MaterialApp(
          title: 'Babel Binance',
          debugShowCheckedModeBanner: false,
          theme: ThemeConfig.lightTheme,
          darkTheme: ThemeConfig.darkTheme,
          themeMode: ThemeMode.system,

          // Internationalization
          localizationsDelegates: const [
            AppLocalizations.delegate,
            GlobalMaterialLocalizations.delegate,
            GlobalWidgetsLocalizations.delegate,
            GlobalCupertinoLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,

          // Accessibility
          builder: (context, child) {
            return MediaQuery(
              data: MediaQuery.of(context).copyWith(
                textScaleFactor: MediaQuery.of(context).textScaleFactor.clamp(0.8, 1.5),
              ),
              child: child!,
            );
          },

          home: const SplashScreen(),
        );
      },
    );
  }
}
