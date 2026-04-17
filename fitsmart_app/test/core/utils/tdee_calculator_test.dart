import 'package:flutter_test/flutter_test.dart';
import 'package:fitsmart_app/core/utils/tdee_calculator.dart';

void main() {
  group('TdeeCalculator.calculateBmr', () {
    test('calculates BMR correctly for male', () {
      // Mifflin-St Jeor: (10 * 80) + (6.25 * 175) - (5 * 25) + 5 = 800 + 1093.75 - 125 + 5 = 1773.75
      final bmr = TdeeCalculator.calculateBmr(
        weightKg: 80,
        heightCm: 175,
        age: 25,
        gender: 'male',
      );
      expect(bmr, closeTo(1773.75, 0.01));
    });

    test('calculates BMR correctly for female', () {
      // Mifflin-St Jeor: (10 * 60) + (6.25 * 165) - (5 * 30) - 161 = 600 + 1031.25 - 150 - 161 = 1320.25
      final bmr = TdeeCalculator.calculateBmr(
        weightKg: 60,
        heightCm: 165,
        age: 30,
        gender: 'female',
      );
      expect(bmr, closeTo(1320.25, 0.01));
    });

    test('treats non-male gender as female formula', () {
      // 'other' uses the female formula (-161)
      final bmrFemale = TdeeCalculator.calculateBmr(
        weightKg: 70,
        heightCm: 170,
        age: 28,
        gender: 'female',
      );
      final bmrOther = TdeeCalculator.calculateBmr(
        weightKg: 70,
        heightCm: 170,
        age: 28,
        gender: 'other',
      );
      expect(bmrOther, equals(bmrFemale));
    });
  });

  group('TdeeCalculator.calculate', () {
    test('applies sedentary activity multiplier (1.2)', () {
      final result = TdeeCalculator.calculate(
        weightKg: 80,
        heightCm: 175,
        age: 25,
        gender: 'male',
        activityLevel: 'sedentary',
        goal: 'maintain',
      );
      // BMR = 1773.75, TDEE = 1773.75 * 1.2 = 2128.5, maintain = +0
      expect(result.bmr, closeTo(1773.75, 0.01));
      expect(result.tdee, closeTo(2128.5, 0.01));
      expect(result.targetCalories, closeTo(2128.5, 0.01));
    });

    test('applies lightly_active multiplier (1.375)', () {
      final result = TdeeCalculator.calculate(
        weightKg: 80,
        heightCm: 175,
        age: 25,
        gender: 'male',
        activityLevel: 'lightly_active',
        goal: 'maintain',
      );
      expect(result.tdee, closeTo(1773.75 * 1.375, 0.01));
    });

    test('applies moderately_active multiplier (1.55)', () {
      final result = TdeeCalculator.calculate(
        weightKg: 80,
        heightCm: 175,
        age: 25,
        gender: 'male',
        activityLevel: 'moderately_active',
        goal: 'maintain',
      );
      expect(result.tdee, closeTo(1773.75 * 1.55, 0.01));
    });

    test('applies very_active multiplier (1.725)', () {
      final result = TdeeCalculator.calculate(
        weightKg: 80,
        heightCm: 175,
        age: 25,
        gender: 'male',
        activityLevel: 'very_active',
        goal: 'maintain',
      );
      expect(result.tdee, closeTo(1773.75 * 1.725, 0.01));
    });

    test('applies extremely_active multiplier (1.9)', () {
      final result = TdeeCalculator.calculate(
        weightKg: 80,
        heightCm: 175,
        age: 25,
        gender: 'male',
        activityLevel: 'extremely_active',
        goal: 'maintain',
      );
      expect(result.tdee, closeTo(1773.75 * 1.9, 0.01));
    });

    test('falls back to 1.55 multiplier for unknown activity level', () {
      final result = TdeeCalculator.calculate(
        weightKg: 80,
        heightCm: 175,
        age: 25,
        gender: 'male',
        activityLevel: 'unknown_level',
        goal: 'maintain',
      );
      expect(result.tdee, closeTo(1773.75 * 1.55, 0.01));
    });

    test('clamps target calories to minimum 1200', () {
      // Use very low weight + sedentary + lose_fat to push below 1200
      final result = TdeeCalculator.calculate(
        weightKg: 40,
        heightCm: 150,
        age: 60,
        gender: 'female',
        activityLevel: 'sedentary',
        goal: 'lose_fat', // -500
      );
      // BMR = (10*40) + (6.25*150) - (5*60) - 161 = 400 + 937.5 - 300 - 161 = 876.5
      // TDEE = 876.5 * 1.2 = 1051.8
      // targetCalories = 1051.8 - 500 = 551.8 → clamped to 1200
      expect(result.targetCalories, equals(1200.0));
    });

    test('clamps target calories to maximum 6000', () {
      // Use extremely high values to push above 6000
      final result = TdeeCalculator.calculate(
        weightKg: 200,
        heightCm: 210,
        age: 20,
        gender: 'male',
        activityLevel: 'extremely_active',
        goal: 'gain_muscle_aggressive', // +500
      );
      // BMR = (10*200) + (6.25*210) - (5*20) + 5 = 2000 + 1312.5 - 100 + 5 = 3217.5
      // TDEE = 3217.5 * 1.9 = 6113.25
      // targetCalories = 6113.25 + 500 = 6613.25 → clamped to 6000
      expect(result.targetCalories, equals(6000.0));
    });

    test('gain_muscle goal: protein=2.2g/kg, fat=25%', () {
      final result = TdeeCalculator.calculate(
        weightKg: 80,
        heightCm: 175,
        age: 25,
        gender: 'male',
        activityLevel: 'moderately_active',
        goal: 'gain_muscle',
      );
      expect(result.proteinG, closeTo(80 * 2.2, 0.01));
    });

    test('lose_fat goal: protein=2.4g/kg, fat=30%', () {
      final result = TdeeCalculator.calculate(
        weightKg: 70,
        heightCm: 170,
        age: 28,
        gender: 'male',
        activityLevel: 'moderately_active',
        goal: 'lose_fat',
      );
      expect(result.proteinG, closeTo(70 * 2.4, 0.01));
    });

    test('recomp goal: protein=2.5g/kg, fat=28%', () {
      final result = TdeeCalculator.calculate(
        weightKg: 75,
        heightCm: 178,
        age: 30,
        gender: 'male',
        activityLevel: 'very_active',
        goal: 'recomp',
      );
      expect(result.proteinG, closeTo(75 * 2.5, 0.01));
    });

    test('athletic goal: protein=2.0g/kg, fat=28%', () {
      final result = TdeeCalculator.calculate(
        weightKg: 85,
        heightCm: 180,
        age: 22,
        gender: 'male',
        activityLevel: 'very_active',
        goal: 'athletic',
      );
      expect(result.proteinG, closeTo(85 * 2.0, 0.01));
    });

    test('maintain (default) goal: protein=1.8g/kg, fat=30%', () {
      final result = TdeeCalculator.calculate(
        weightKg: 70,
        heightCm: 170,
        age: 35,
        gender: 'male',
        activityLevel: 'moderately_active',
        goal: 'maintain',
      );
      expect(result.proteinG, closeTo(70 * 1.8, 0.01));
    });

    test('carbs are clamped between 50 and 1000', () {
      // Very low calories scenario → carbs should be ≥ 50
      final result = TdeeCalculator.calculate(
        weightKg: 40,
        heightCm: 150,
        age: 60,
        gender: 'female',
        activityLevel: 'sedentary',
        goal: 'lose_fat',
      );
      expect(result.carbsG, greaterThanOrEqualTo(50.0));
      expect(result.carbsG, lessThanOrEqualTo(1000.0));
    });

    test('TdeeResult has all expected fields', () {
      final result = TdeeCalculator.calculate(
        weightKg: 80,
        heightCm: 175,
        age: 25,
        gender: 'male',
        activityLevel: 'moderately_active',
        goal: 'maintain',
      );
      expect(result.bmr, isA<double>());
      expect(result.tdee, isA<double>());
      expect(result.targetCalories, isA<double>());
      expect(result.proteinG, isA<double>());
      expect(result.carbsG, isA<double>());
      expect(result.fatG, isA<double>());
    });
  });

  group('TdeeCalculator.levelToGoalKey', () {
    test('slow → lose_fat_slow', () {
      expect(TdeeCalculator.levelToGoalKey('slow'), 'lose_fat_slow');
    });

    test('aggressive → lose_fat', () {
      expect(TdeeCalculator.levelToGoalKey('aggressive'), 'lose_fat');
    });

    test('default → lose_fat', () {
      expect(TdeeCalculator.levelToGoalKey('anything'), 'lose_fat');
    });
  });
}
