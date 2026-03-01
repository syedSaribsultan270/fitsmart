import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/onboarding_data.dart';
import '../../../core/utils/tdee_calculator.dart';

class OnboardingNotifier extends StateNotifier<OnboardingData> {
  OnboardingNotifier() : super(OnboardingData());

  // Each setter clones the state so StateNotifier detects the change
  // and notifies listeners. The old `state = state..x = v` pattern
  // mutated in-place and re-assigned the same reference, which meant
  // `previousState != value` was false and listeners were never called.

  void setGoal(String goal) => state = state.clone()..primaryGoal = goal;
  void setGender(String gender) => state = state.clone()..gender = gender;
  void setAge(int age) => state = state.clone()..age = age;
  void setHeight(double cm) => state = state.clone()..heightCm = cm;
  void setWeight(double kg) => state = state.clone()..weightKg = kg;
  void setBodyFat(double? pct) => state = state.clone()..bodyFatPct = pct;
  void setCountry(String country) => state = state.clone()..country = country;
  void setCity(String city) => state = state.clone()..city = city;
  void setActivityLevel(String level) => state = state.clone()..activityLevel = level;
  void setTargetBodyType(String type) => state = state.clone()..targetBodyType = type;
  void setSleepSchedule(int bedHour, int bedMin, int wakeHour, int wakeMin) {
    state = state.clone()
      ..bedtimeHour = bedHour
      ..bedtimeMin = bedMin
      ..wakeHour = wakeHour
      ..wakeMin = wakeMin;
  }

  void setDietaryRestrictions(List<String> restrictions) =>
      state = state.clone()..dietaryRestrictions = restrictions;
  void setCuisinePreferences(List<String> prefs) =>
      state = state.clone()..cuisinePreferences = prefs;
  void setDislikedIngredients(List<String> items) =>
      state = state.clone()..dislikedIngredients = items;
  void setBudget(double budget) => state = state.clone()..monthlyBudgetUsd = budget;
  void setTargetWeight(double kg) => state = state.clone()..targetWeightKg = kg;
  void setPace(String pace) => state = state.clone()..weightChangePace = pace;
  void setWorkoutDays(int days) => state = state.clone()..workoutDaysPerWeek = days;

  TdeeResult? computeTargets() {
    final d = state;
    if (d.weightKg == null ||
        d.heightCm == null ||
        d.age == null ||
        d.gender == null ||
        d.activityLevel == null ||
        d.primaryGoal == null) {
      return null;
    }

    return TdeeCalculator.calculate(
      weightKg: d.weightKg!,
      heightCm: d.heightCm!,
      age: d.age!,
      gender: d.gender!,
      activityLevel: d.activityLevel!,
      goal: d.primaryGoal!,
      bodyFatPct: d.bodyFatPct,
    );
  }

  Future<void> saveToPrefs() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('onboarding_data', jsonEncode(state.toJson()));
    await prefs.setBool('onboarding_complete', true);
  }

  /// Check whether onboarding has been completed (SharedPreferences).
  static Future<bool> isOnboardingCompleteLocal() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('onboarding_complete') ?? false;
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingData>(
  (ref) => OnboardingNotifier(),
);
