import 'package:flutter_test/flutter_test.dart';
import 'package:fitsmart_app/models/onboarding_data.dart';

void main() {
  OnboardingData makeComplete() {
    return OnboardingData()
      ..primaryGoal = 'lose_fat'
      ..gender = 'male'
      ..age = 25
      ..heightCm = 175.0
      ..weightKg = 80.0
      ..activityLevel = 'moderately_active'
      ..targetWeightKg = 70.0;
  }

  group('OnboardingData.isComplete', () {
    test('returns true when all required fields are set', () {
      final data = makeComplete();
      expect(data.isComplete, true);
    });

    test('returns false when primaryGoal is null', () {
      final data = makeComplete()..primaryGoal = null;
      expect(data.isComplete, false);
    });

    test('returns false when gender is null', () {
      final data = makeComplete()..gender = null;
      expect(data.isComplete, false);
    });

    test('returns false when age is null', () {
      final data = makeComplete()..age = null;
      expect(data.isComplete, false);
    });

    test('returns false when heightCm is null', () {
      final data = makeComplete()..heightCm = null;
      expect(data.isComplete, false);
    });

    test('returns false when weightKg is null', () {
      final data = makeComplete()..weightKg = null;
      expect(data.isComplete, false);
    });

    test('returns false when activityLevel is null', () {
      final data = makeComplete()..activityLevel = null;
      expect(data.isComplete, false);
    });

    test('returns false when targetWeightKg is null', () {
      final data = makeComplete()..targetWeightKg = null;
      expect(data.isComplete, false);
    });

    test('returns true even if optional fields are null', () {
      final data = makeComplete();
      // bodyFatPct, country, city, etc. are optional
      expect(data.bodyFatPct, isNull);
      expect(data.country, isNull);
      expect(data.isComplete, true);
    });
  });

  group('OnboardingData JSON round-trip', () {
    test('toJson → fromJson preserves all fields', () {
      final data = makeComplete()
        ..bodyFatPct = 15.0
        ..country = 'Pakistan'
        ..city = 'Lahore'
        ..targetBodyType = 'athletic'
        ..bedtimeHour = 23
        ..bedtimeMin = 30
        ..wakeHour = 7
        ..wakeMin = 0
        ..dietaryRestrictions = ['halal']
        ..cuisinePreferences = ['pakistani', 'indian']
        ..dislikedIngredients = ['mushroom']
        ..monthlyBudgetUsd = 200.0
        ..weightChangePace = 'steady'
        ..workoutDaysPerWeek = 5;

      final json = data.toJson();
      final restored = OnboardingData.fromJson(json);

      expect(restored.primaryGoal, 'lose_fat');
      expect(restored.gender, 'male');
      expect(restored.age, 25);
      expect(restored.heightCm, 175.0);
      expect(restored.weightKg, 80.0);
      expect(restored.bodyFatPct, 15.0);
      expect(restored.country, 'Pakistan');
      expect(restored.city, 'Lahore');
      expect(restored.activityLevel, 'moderately_active');
      expect(restored.targetBodyType, 'athletic');
      expect(restored.bedtimeHour, 23);
      expect(restored.bedtimeMin, 30);
      expect(restored.wakeHour, 7);
      expect(restored.wakeMin, 0);
      expect(restored.dietaryRestrictions, ['halal']);
      expect(restored.cuisinePreferences, ['pakistani', 'indian']);
      expect(restored.dislikedIngredients, ['mushroom']);
      expect(restored.monthlyBudgetUsd, 200.0);
      expect(restored.targetWeightKg, 70.0);
      expect(restored.weightChangePace, 'steady');
      expect(restored.workoutDaysPerWeek, 5);
    });

    test('fromJson with all nulls produces empty OnboardingData', () {
      final data = OnboardingData.fromJson({});
      expect(data.primaryGoal, isNull);
      expect(data.gender, isNull);
      expect(data.age, isNull);
      expect(data.isComplete, false);
    });
  });

  group('OnboardingData.clone', () {
    test('produces an independent copy', () {
      final original = makeComplete()
        ..dietaryRestrictions = ['vegan'];
      final cloned = original.clone();

      // Values match
      expect(cloned.primaryGoal, 'lose_fat');
      expect(cloned.dietaryRestrictions, ['vegan']);

      // Modifying clone doesn't affect original
      cloned.primaryGoal = 'gain_muscle';
      expect(original.primaryGoal, 'lose_fat');
    });
  });

  group('OnboardingData list fields', () {
    test('dietaryRestrictions handles multiple values', () {
      final data = OnboardingData()
        ..dietaryRestrictions = ['vegetarian', 'keto', 'halal'];
      final json = data.toJson();
      final restored = OnboardingData.fromJson(json);
      expect(restored.dietaryRestrictions, ['vegetarian', 'keto', 'halal']);
    });

    test('cuisinePreferences handles empty list', () {
      final data = OnboardingData()..cuisinePreferences = [];
      final json = data.toJson();
      final restored = OnboardingData.fromJson(json);
      expect(restored.cuisinePreferences, isEmpty);
    });

    test('null list fields return null from fromJson', () {
      final data = OnboardingData.fromJson({});
      expect(data.dietaryRestrictions, isNull);
      expect(data.cuisinePreferences, isNull);
      expect(data.dislikedIngredients, isNull);
    });
  });
}
