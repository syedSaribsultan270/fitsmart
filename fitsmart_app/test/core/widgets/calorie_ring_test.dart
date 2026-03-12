import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsmart_app/core/widgets/calorie_ring.dart';
import 'package:fitsmart_app/core/theme/app_theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('CalorieRing', () {
    testWidgets('renders with 0% consumed', (tester) async {
      await tester.pumpWidget(_wrap(
        const CalorieRing(consumed: 0, target: 2000),
      ));
      await tester.pumpAndSettle();

      expect(find.text('0'), findsOneWidget);
      expect(find.text('of 2000'), findsOneWidget);
      expect(find.text('kcal'), findsOneWidget);
    });

    testWidgets('renders with 50% consumed', (tester) async {
      await tester.pumpWidget(_wrap(
        const CalorieRing(consumed: 1000, target: 2000),
      ));
      await tester.pumpAndSettle();

      expect(find.text('1000'), findsOneWidget);
      expect(find.text('of 2000'), findsOneWidget);
    });

    testWidgets('renders with 100% consumed', (tester) async {
      await tester.pumpWidget(_wrap(
        const CalorieRing(consumed: 2000, target: 2000),
      ));
      await tester.pumpAndSettle();

      expect(find.text('2000'), findsWidgets); // consumed + target
    });

    testWidgets('renders >100% consumed — shows over indicator', (tester) async {
      await tester.pumpWidget(_wrap(
        const CalorieRing(consumed: 2500, target: 2000),
      ));
      await tester.pumpAndSettle();

      expect(find.text('2500'), findsOneWidget);
      expect(find.textContaining('over'), findsOneWidget);
    });

    testWidgets('shows correct text labels', (tester) async {
      await tester.pumpWidget(_wrap(
        const CalorieRing(consumed: 1500, target: 2500),
      ));
      await tester.pumpAndSettle();

      expect(find.text('1500'), findsOneWidget);
      expect(find.text('of 2500'), findsOneWidget);
      expect(find.text('kcal'), findsOneWidget);
    });
  });
}
