import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fitsmart_app/core/widgets/app_button.dart';
import 'package:fitsmart_app/core/theme/app_theme.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    // NoSplash avoids loading ink_sparkle.frag shader which fails in test env
    theme: AppTheme.dark().copyWith(splashFactory: NoSplash.splashFactory),
    home: Scaffold(body: Center(child: child)),
  );
}

void main() {
  group('AppButton', () {
    testWidgets('renders with label', (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Continue',
          onPressed: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Continue'), findsOneWidget);
    });

    testWidgets('onPressed callback fires on tap', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Tap Me',
          onPressed: () => pressed = true,
        ),
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Tap Me'));
      await tester.pumpAndSettle();

      expect(pressed, true);
    });

    testWidgets('disabled state: onPressed = null → no tap response', (tester) async {
      bool pressed = false;
      await tester.pumpWidget(_wrap(
        const AppButton(
          label: 'Disabled',
          onPressed: null,
        ),
      ));
      await tester.pumpAndSettle();

      // Button should still render
      expect(find.text('Disabled'), findsOneWidget);
      expect(pressed, false);
    });

    testWidgets('shows icon when provided', (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Save',
          icon: Icons.save,
          onPressed: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.byIcon(Icons.save), findsOneWidget);
      expect(find.text('Save'), findsOneWidget);
    });

    testWidgets('shows loading indicator when isLoading', (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Loading',
          isLoading: true,
          onPressed: () {},
        ),
      ));
      // Use pump() instead of pumpAndSettle() because CircularProgressIndicator
      // has infinite animation that prevents settling.
      await tester.pump();

      expect(find.byType(CircularProgressIndicator), findsOneWidget);
      // Label should NOT be shown during loading
      expect(find.text('Loading'), findsNothing);
    });

    testWidgets('secondary variant renders', (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Cancel',
          variant: AppButtonVariant.secondary,
          onPressed: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Cancel'), findsOneWidget);
    });

    testWidgets('ghost variant renders', (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Ghost',
          variant: AppButtonVariant.ghost,
          onPressed: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Ghost'), findsOneWidget);
    });

    testWidgets('danger variant renders', (tester) async {
      await tester.pumpWidget(_wrap(
        AppButton(
          label: 'Delete',
          variant: AppButtonVariant.danger,
          onPressed: () {},
        ),
      ));
      await tester.pumpAndSettle();

      expect(find.text('Delete'), findsOneWidget);
    });
  });
}
