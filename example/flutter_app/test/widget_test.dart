import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:babel_binance_example/main.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // Build our app and trigger a frame
    await tester.pumpWidget(
      const ProviderScope(
        child: BabelBinanceApp(),
      ),
    );

    // Verify that splash screen is shown
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    expect(find.text('Babel Binance'), findsOneWidget);
  });

  testWidgets('App has correct title', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: BabelBinanceApp(),
      ),
    );

    await tester.pump();

    final MaterialApp app = tester.widget(find.byType(MaterialApp));
    expect(app.title, 'Babel Binance');
  });
}
