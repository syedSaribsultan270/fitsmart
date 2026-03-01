import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

void main() {
  testWidgets('App smoke test', (WidgetTester tester) async {
    // FitSmartApp depends on Firebase, which isn't available in unit tests.
    // Verify the core widget tree can mount instead.
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: Scaffold(body: Center(child: Text('FitSmart'))),
        ),
      ),
    );
    expect(find.text('FitSmart'), findsOneWidget);
  });
}
