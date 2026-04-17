import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/onboarding_data.dart';
import '../../../core/utils/tdee_calculator.dart';
import '../../../services/firestore_service.dart';

class OnboardingNotifier extends StateNotifier<OnboardingData> {
  OnboardingNotifier() : super(OnboardingData());

  // In-memory flag: true only during the current app session after a data reset.
  // Resets to false on every app restart, so it never poisons future sign-ins.
  static bool _resetInitiated = false;

  /// Call this when the user explicitly resets their data in settings.
  static void markResetInitiated() => _resetInitiated = true;

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
    // Scope completion to the current user so a different user's stale
    // flag is never inherited (fixes signup-goes-to-dashboard bug).
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid != null) await prefs.setString('onboarding_uid', uid);
    // Clear the in-memory reset flag and remove any legacy prefs key.
    _resetInitiated = false;
    await prefs.remove('_skip_cloud_recovery');
  }

  /// Check whether onboarding has been completed for the *current* user.
  /// Returns false if a reset was initiated this session, or if the stored
  /// completion belongs to a different UID.
  static Future<bool> isOnboardingCompleteLocal() async {
    if (_resetInitiated) return false;
    final prefs = await SharedPreferences.getInstance();
    if (!(prefs.getBool('onboarding_complete') ?? false)) return false;
    final storedUid = prefs.getString('onboarding_uid');
    if (storedUid != null) {
      final currentUid = FirebaseAuth.instance.currentUser?.uid;
      if (currentUid != null && currentUid != storedUid) return false;
    }
    return true;
  }

  /// Try to recover onboarding profile from Firestore (reinstall / new-device scenario).
  /// Returns true if a complete profile was found and restored locally.
  ///
  /// Only skipped when [_resetInitiated] is true (user explicitly reset data
  /// THIS session). Using an in-memory flag means app restarts always get a
  /// fresh recovery attempt — fixing the "goes to onboarding every sign-in"
  /// bug that was caused by the old SharedPreferences skip guard persisting
  /// across sessions.
  static Future<bool> tryRestoreFromFirestore(String uid) async {
    try {
      // Only block recovery if a reset was initiated in this app session.
      // The old _skip_cloud_recovery SharedPreferences key is intentionally
      // NOT checked here — it could persist across restarts and block recovery
      // indefinitely when the user never completed post-reset onboarding.
      if (_resetInitiated) return false;

      final profile = await FirestoreService.getProfile(uid);
      if (profile == null) return false;

      // Accept profiles with an explicit isComplete flag (set since v2) OR
      // where all required fields are non-null (legacy profiles before the flag).
      final hasExplicitFlag = profile['isComplete'] == true;
      final data = OnboardingData.fromJson(profile);
      if (!hasExplicitFlag && !data.isComplete) return false;

      // Restore to SharedPreferences so all local providers work.
      // Always scope to this UID so a future sign-in by someone else
      // doesn't inherit this completed state.
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('onboarding_data', jsonEncode(data.toJson()));
      await prefs.setBool('onboarding_complete', true);
      await prefs.setString('onboarding_uid', uid);
      return true;
    } catch (e) {
      debugPrint('[OnboardingNotifier] Firestore recovery failed: $e');
      return false;
    }
  }
}

final onboardingProvider =
    StateNotifierProvider<OnboardingNotifier, OnboardingData>(
  (ref) => OnboardingNotifier(),
);
