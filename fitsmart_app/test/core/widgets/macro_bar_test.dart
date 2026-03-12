import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsmart_app/core/widgets/macro_bar.dart';
import 'package:fitsmart_app/core/theme/app_theme.dart';
import 'package:fitsmart_app/core/theme/app_colors_extension.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    theme: AppTheme.dark(),
    home: Scaffold(body: Padding(
      padding: const EdgeInsets.all(16),
      child: child,
    )),
  );
}

void main() {
  group('MacroBar', () {
    testWidgets('renders with label and values', (tester) async {
      await tester.pumpWidget(_wrap(
        const MacroBar(
          label: 'Protein',
          consumed: 80,
          target: 150,
          color: AppColorsExtension.macroProtein,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Protein'), findsOneWidget);
      expect(find.text('80'), findsOneWidget);
      expect(find.textContaining('150'), findsOneWidget);
    });

    testWidgets('renders with zero values', (tester) async {
      await tester.pumpWidget(_wrap(
        const MacroBar(
          label: 'Carbs',
          consumed: 0,
          target: 200,
          color: AppColorsExtension.macroCarbs,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Carbs'), findsOneWidget);
      expect(find.text('0'), findsOneWidget);
    });

    testWidgets('renders with consumed > target (over)', (tester) async {
      await tester.pumpWidget(_wrap(
        const MacroBar(
          label: 'Fat',
          consumed: 100,
          target: 65,
          color: AppColorsExtension.macroFat,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Fat'), findsOneWidget);
      expect(find.text('100'), findsOneWidget);
    });

    testWidgets('shows correct unit', (tester) async {
      await tester.pumpWidget(_wrap(
        const MacroBar(
          label: 'Fiber',
          consumed: 20,
          target: 30,
          color: AppColorsExtension.macroFiber,
          unit: 'g',
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.textContaining('g'), findsOneWidget);
    });
  });
}
