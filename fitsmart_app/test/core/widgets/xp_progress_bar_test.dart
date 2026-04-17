import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsmart_app/core/widgets/xp_progress_bar.dart';
import 'package:fitsmart_app/core/theme/app_theme.dart';

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
  group('XpProgressBar — full mode', () {
    testWidgets('renders level name and XP display', (tester) async {
      await tester.pumpWidget(_wrap(
        const XpProgressBar(
          totalXp: 450,
          currentLevel: 3,
          levelName: 'Hustler',
          levelProgress: 0.5,
          xpToNext: 150,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('LVL 3'), findsOneWidget);
      expect(find.text('Hustler'), findsOneWidget);
      expect(find.text('150 XP to next'), findsOneWidget);
      expect(find.text('450 total XP'), findsOneWidget);
    });
  });

  group('XpProgressBar — compact mode', () {
    testWidgets('renders compact layout', (tester) async {
      await tester.pumpWidget(_wrap(
        const XpProgressBar(
          totalXp: 1000,
          currentLevel: 5,
          levelName: 'Warrior',
          levelProgress: 0.0,
          xpToNext: 500,
          compact: true,
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('LVL 5'), findsOneWidget);
      expect(find.text('1000 XP'), findsOneWidget);
      // In compact mode, level name is not shown
      expect(find.text('Warrior'), findsNothing);
    });
  });
}
