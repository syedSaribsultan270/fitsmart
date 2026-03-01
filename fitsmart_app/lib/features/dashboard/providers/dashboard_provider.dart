import 'dart:convert';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/gamification.dart';
import '../../../models/onboarding_data.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/tdee_calculator.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';

// ── User Profile (from SharedPreferences) ─────────────────────────────────

final userProfileProvider = FutureProvider<OnboardingData?>((ref) async {
  final prefs = await SharedPreferences.getInstance();
  final json = prefs.getString('onboarding_data');
  if (json == null) return null;
  return OnboardingData.fromJson(jsonDecode(json) as Map<String, dynamic>);
});

// ── Nutrition Targets (TDEE-derived) ──────────────────────────────────────

class NutritionTargets {
  final double calories;
  final double proteinG;
  final double carbsG;
  final double fatG;

  const NutritionTargets({
    this.calories = 2000,
    this.proteinG = 150,
    this.carbsG = 200,
    this.fatG = 65,
  });
}

final nutritionTargetsProvider = Provider<NutritionTargets>((ref) {
  final profileAsync = ref.watch(userProfileProvider);
  return profileAsync.when(
    data: (profile) {
      if (profile == null ||
          profile.weightKg == null ||
          profile.heightCm == null ||
          profile.age == null ||
          profile.gender == null ||
          profile.activityLevel == null ||
          profile.primaryGoal == null) {
        return const NutritionTargets();
      }
      final result = TdeeCalculator.calculate(
        weightKg: profile.weightKg!,
        heightCm: profile.heightCm!,
        age: profile.age!,
        gender: profile.gender!,
        activityLevel: profile.activityLevel!,
        goal: profile.primaryGoal!,
        bodyFatPct: profile.bodyFatPct,
      );
      return NutritionTargets(
        calories: result.targetCalories,
        proteinG: result.proteinG,
        carbsG: result.carbsG,
        fatG: result.fatG,
      );
    },
    loading: () => const NutritionTargets(),
    error: (_, __) => const NutritionTargets(),
  );
});

// ── Today's Meals Stream ──────────────────────────────────────────────────

final todaysMealsProvider = StreamProvider<List<MealLog>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTodaysMeals();
});

// ── Today's Workouts Stream ───────────────────────────────────────────────

final todaysWorkoutsProvider = StreamProvider<List<WorkoutLog>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTodaysWorkouts();
});

// ── Today's Water Intake ──────────────────────────────────────────────────

final todaysWaterProvider = FutureProvider<int>((ref) async {
  // Re-fetch when meals change (used as a proxy for "something was logged")
  ref.watch(todaysMealsProvider);
  final db = ref.read(databaseProvider);
  return db.getTodaysWater();
});

// ── Today's AI Insight ────────────────────────────────────────────────────

final todaysInsightProvider = FutureProvider<AiInsight?>((ref) async {
  final db = ref.read(databaseProvider);
  return db.getTodaysInsight();
});

// ── Daily Nutrition (targets + consumed from real Drift data) ─────────────

class DailyNutrition {
  final double consumedCalories;
  final double targetCalories;
  final double consumedProtein;
  final double targetProtein;
  final double consumedCarbs;
  final double targetCarbs;
  final double consumedFat;
  final double targetFat;

  const DailyNutrition({
    this.consumedCalories = 0,
    this.targetCalories = 2000,
    this.consumedProtein = 0,
    this.targetProtein = 150,
    this.consumedCarbs = 0,
    this.targetCarbs = 200,
    this.consumedFat = 0,
    this.targetFat = 65,
  });

  DailyNutrition copyWith({
    double? consumedCalories,
    double? targetCalories,
    double? consumedProtein,
    double? targetProtein,
    double? consumedCarbs,
    double? targetCarbs,
    double? consumedFat,
    double? targetFat,
  }) {
    return DailyNutrition(
      consumedCalories: consumedCalories ?? this.consumedCalories,
      targetCalories: targetCalories ?? this.targetCalories,
      consumedProtein: consumedProtein ?? this.consumedProtein,
      targetProtein: targetProtein ?? this.targetProtein,
      consumedCarbs: consumedCarbs ?? this.consumedCarbs,
      targetCarbs: targetCarbs ?? this.targetCarbs,
      consumedFat: consumedFat ?? this.consumedFat,
      targetFat: targetFat ?? this.targetFat,
    );
  }
}

final dailyNutritionProvider = Provider<DailyNutrition>((ref) {
  final targets = ref.watch(nutritionTargetsProvider);
  final mealsAsync = ref.watch(todaysMealsProvider);

  final meals = mealsAsync.valueOrNull ?? [];
  double totalCal = 0, totalProt = 0, totalCarbs = 0, totalFat = 0;
  for (final m in meals) {
    totalCal += m.calories;
    totalProt += m.proteinG;
    totalCarbs += m.carbsG;
    totalFat += m.fatG;
  }

  return DailyNutrition(
    consumedCalories: totalCal,
    targetCalories: targets.calories,
    consumedProtein: totalProt,
    targetProtein: targets.proteinG,
    consumedCarbs: totalCarbs,
    targetCarbs: targets.carbsG,
    consumedFat: totalFat,
    targetFat: targets.fatG,
  );
});

// ── Gamification Provider ─────────────────────────────────────────────────

class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier() : super(const GamificationState()) {
    _load();
  }

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('gamification');
    if (json != null) {
      state = GamificationState.fromJson(jsonDecode(json));
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gamification', jsonEncode(state.toJson()));
  }

  Future<int> awardXp(int xp, {bool checkStreak = false}) async {
    final prevLevel = state.currentLevel;
    state = state.copyWith(totalXp: state.totalXp + xp);

    if (checkStreak) await _updateStreak();

    // Check for level up
    final newLevel = state.currentLevel;
    await _save();
    return newLevel > prevLevel ? newLevel : 0; // Returns new level if leveled up
  }

  Future<void> _updateStreak() async {
    final now = DateTime.now();
    final last = state.lastLogDate;

    if (last == null) {
      // First ever log
      state = state.copyWith(
        currentStreak: 1,
        longestStreak: 1,
        lastLogDate: now,
      );
      await unlockBadgeIfNeeded(Badges.firstLog);
      return;
    }

    final daysDiff = now.difference(last).inDays;

    if (daysDiff == 0) {
      // Already logged today
      return;
    } else if (daysDiff == 1) {
      // Consecutive day
      final newStreak = state.currentStreak + 1;
      state = state.copyWith(
        currentStreak: newStreak,
        longestStreak: newStreak > state.longestStreak
            ? newStreak
            : state.longestStreak,
        lastLogDate: now,
      );
      // Award streak bonus XP
      final bonusXp = AppConstants.xpDailyStreakBase * newStreak;
      state = state.copyWith(totalXp: state.totalXp + bonusXp);

      // Check streak badges
      if (newStreak >= 7) await unlockBadgeIfNeeded(Badges.streak7);
      if (newStreak >= 30) await unlockBadgeIfNeeded(Badges.streak30);
      if (newStreak >= 100) await unlockBadgeIfNeeded(Badges.streak100);
    } else if (daysDiff > 1) {
      // Check if they have a streak freeze
      if (state.streakFreezesAvailable > 0) {
        state = state.copyWith(
          streakFreezesAvailable: state.streakFreezesAvailable - 1,
          lastLogDate: now,
        );
      } else {
        // Streak broken
        state = state.copyWith(
          currentStreak: 1,
          lastLogDate: now,
        );
      }
    }

    await _save();
  }

  Future<void> unlockBadgeIfNeeded(String badgeId) async {
    if (!state.unlockedBadges.contains(badgeId)) {
      final newBadges = [...state.unlockedBadges, badgeId];
      state = state.copyWith(unlockedBadges: newBadges);
      // Award badge XP
      final badgeInfo = Badges.all[badgeId];
      if (badgeInfo != null) {
        state = state.copyWith(totalXp: state.totalXp + badgeInfo.xpReward);
      }
      await _save();
    }
  }

  Future<void> addStreakFreeze() async {
    if (state.streakFreezesAvailable < AppConstants.maxStreakFreezesStored) {
      state = state.copyWith(
        streakFreezesAvailable: state.streakFreezesAvailable + 1,
      );
      await _save();
    }
  }
}

final gamificationProvider =
    StateNotifierProvider<GamificationNotifier, GamificationState>(
  (ref) => GamificationNotifier(),
);

// ── Workout Plans ─────────────────────────────────────────────────────────

final workoutPlansProvider = FutureProvider<List<WorkoutPlan>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getWorkoutPlans();
});

// ── Meal Plans ────────────────────────────────────────────────────────────

final mealPlansProvider = FutureProvider<List<MealPlan>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getMealPlans();
});

// ── Weight History (last 30 entries) ──────────────────────────────────────

final weightHistoryProvider = StreamProvider<List<WeightLog>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchWeightHistory(limit: 30);
});

// ── Filtered Weight History (by range in days, 0 = all) ──────────────────

final filteredWeightProvider =
    StreamProvider.family<List<WeightLog>, int>((ref, days) {
  final db = ref.watch(databaseProvider);
  if (days <= 0) return db.watchWeightHistory(limit: 365);
  final since = DateTime.now().subtract(Duration(days: days));
  return db.watchWeightHistory(since: since);
});

// ── Personal Records ──────────────────────────────────────────────────────

final personalRecordsProvider = FutureProvider<Map<String, double>>((ref) {
  // Refresh when new workouts are logged
  ref.watch(todaysWorkoutsProvider);
  final db = ref.watch(databaseProvider);
  return db.getAllPrs();
});

// ── Latest Body Measurement ───────────────────────────────────────────────

final latestMeasurementProvider = FutureProvider<BodyMeasurement?>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getLatestMeasurement();
});

// ── All-Time Stats ────────────────────────────────────────────────────────

final allTimeStatsProvider = FutureProvider<Map<String, dynamic>>((ref) async {
  final gamification = ref.watch(gamificationProvider);
  final db = ref.watch(databaseProvider);
  final mealCount = await db.getMealCountAll();
  final workoutCount = await db.getWorkoutCountAll();
  return {
    'meals': mealCount,
    'workouts': workoutCount,
    'totalXp': gamification.totalXp,
    'level': gamification.currentLevel,
    'streak': gamification.currentStreak,
    'badges': gamification.unlockedBadges.length,
  };
});
