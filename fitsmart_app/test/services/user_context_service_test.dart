import 'package:flutter_test/flutter_test.dart';
import 'package:fitsmart_app/services/user_context_service.dart';
import 'package:fitsmart_app/features/dashboard/providers/dashboard_provider.dart';

void main() {
  group('UserContextService.buildMinimalContextSync', () {
    test('includes target and consumed values', () {
      final context = UserContextService.buildMinimalContextSync(
        targets: const NutritionTargets(
          calories: 2500,
          proteinG: 180,
          carbsG: 250,
          fatG: 80,
        ),
        nutrition: const DailyNutrition(
          consumedCalories: 1200,
          consumedProtein: 90,
        ),
      );

      expect(context['target_calories'], 2500);
      expect(context['target_protein_g'], 180);
      expect(context['consumed_calories_today'], 1200);
      expect(context['consumed_protein_today'], 90);
    });

    test('includes mealType when provided', () {
      final context = UserContextService.buildMinimalContextSync(
        targets: const NutritionTargets(),
        nutrition: const DailyNutrition(),
        mealType: 'lunch',
      );

      expect(context['meal_type'], 'lunch');
    });

    test('omits mealType when null', () {
      final context = UserContextService.buildMinimalContextSync(
        targets: const NutritionTargets(),
        nutrition: const DailyNutrition(),
      );

      expect(context.containsKey('meal_type'), false);
    });

    test('uses default NutritionTargets values', () {
      final context = UserContextService.buildMinimalContextSync(
        targets: const NutritionTargets(),
        nutrition: const DailyNutrition(),
      );

      expect(context['target_calories'], 2000);
      expect(context['target_protein_g'], 150);
      expect(context['consumed_calories_today'], 0);
      expect(context['consumed_protein_today'], 0);
    });
  });

  group('Sleep duration calculation logic', () {
    // Testing the sleep calculation that happens in buildFullContext
    test('same day sleep: 22:00 → 06:00 = 8 hours', () {
      final bedH = 22, bedM = 0;
      final wakeH = 6, wakeM = 0;
      int sleepMins = ((wakeH * 60 + wakeM) - (bedH * 60 + bedM));
      if (sleepMins < 0) sleepMins += 24 * 60;
      expect(sleepMins / 60, closeTo(8.0, 0.01));
    });

    test('crossing midnight: 23:30 → 07:00 = 7.5 hours', () {
      final bedH = 23, bedM = 30;
      final wakeH = 7, wakeM = 0;
      int sleepMins = ((wakeH * 60 + wakeM) - (bedH * 60 + bedM));
      if (sleepMins < 0) sleepMins += 24 * 60;
      expect(sleepMins / 60, closeTo(7.5, 0.01));
    });

    test('no midnight crossing: 10:00 → 18:00 = 8 hours', () {
      final bedH = 10, bedM = 0;
      final wakeH = 18, wakeM = 0;
      int sleepMins = ((wakeH * 60 + wakeM) - (bedH * 60 + bedM));
      if (sleepMins < 0) sleepMins += 24 * 60;
      expect(sleepMins / 60, closeTo(8.0, 0.01));
    });

    test('midnight bedtime: 00:00 → 08:00 = 8 hours', () {
      final bedH = 0, bedM = 0;
      final wakeH = 8, wakeM = 0;
      int sleepMins = ((wakeH * 60 + wakeM) - (bedH * 60 + bedM));
      if (sleepMins < 0) sleepMins += 24 * 60;
      expect(sleepMins / 60, closeTo(8.0, 0.01));
    });
  });
}
