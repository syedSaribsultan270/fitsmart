import 'dart:convert';
import 'package:flutter/foundation.dart' show debugPrint;
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../models/gamification.dart';
import '../../../models/onboarding_data.dart';
import '../../../core/constants/app_constants.dart';
import '../../../core/utils/tdee_calculator.dart';
import '../../../features/widgets/home_widget_service.dart';
import '../../../services/analytics_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/review_service.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';

// ── Streak Milestone Celebration ──────────────────────────────────────────
/// Non-zero when a streak milestone was just reached. UI listens and shows
/// the celebration overlay, then resets this to 0.
final streakMilestoneProvider = StateProvider<int>((ref) => 0);

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

/// Pre-filtered meals by type — each section only rebuilds when its own meals change.
final mealsByTypeProvider =
    Provider.family<List<MealLog>, String>((ref, mealType) {
  final all = ref.watch(todaysMealsProvider).valueOrNull ?? [];
  return all
      .where((m) => m.mealType.toLowerCase() == mealType.toLowerCase())
      .toList();
});

// ── Today's Workouts Stream ───────────────────────────────────────────────

final todaysWorkoutsProvider = StreamProvider<List<WorkoutLog>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.watchTodaysWorkouts();
});

// ── Today's Water Intake ──────────────────────────────────────────────────

final todaysWaterProvider = FutureProvider<int>((ref) async {
  // Invalidated manually after each water log via ref.invalidate(todaysWaterProvider)
  final db = ref.read(databaseProvider);
  return db.getTodaysWater();
});

/// Mutation provider: call ref.read(logWaterProvider.notifier).log(ml)
class _WaterNotifier extends StateNotifier<AsyncValue<void>> {
  _WaterNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// Match the goal used by [WaterTrackingCard]. Stays in sync with that
  /// card; move to a shared constant if we ever surface it elsewhere.
  static const _goalMl = 2500;

  Future<void> log(int ml) async {
    state = const AsyncValue.loading();
    try {
      final db = _ref.read(databaseProvider);
      final before = await db.getTodaysWater();
      await db.addWater(ml);
      final after = before + ml;
      _ref.invalidate(todaysWaterProvider);
      state = const AsyncValue.data(null);

      // Rich analytics — totals, remaining, goal state, and the
      // specifically-useful "crossed_goal_this_log" bool so a funnel can
      // pinpoint exactly which log completed the daily target.
      AnalyticsService.instance.track('water_logged', props: {
        'amount_ml': ml,
        'total_before_ml': before,
        'total_after_ml': after,
        'goal_ml': _goalMl,
        'remaining_ml': (_goalMl - after).clamp(0, _goalMl),
        'pct_of_goal': ((after / _goalMl) * 100).round(),
        'goal_reached': after >= _goalMl,
        'crossed_goal_this_log': before < _goalMl && after >= _goalMl,
        'rollback': ml < 0, // undo from AI tool writes negative
      });
      syncHomeWidget(_ref); // fire-and-forget
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final logWaterProvider =
    StateNotifierProvider<_WaterNotifier, AsyncValue<void>>(
  (ref) => _WaterNotifier(ref),
);

// ── Recent Unique Meals (for quick re-log) ────────────────────────────────

/// Returns up to 8 most-recently-logged unique meals (by name).
/// Used in LogMealScreen for one-tap re-log.
final recentMealsProvider = FutureProvider<List<MealLog>>((ref) async {
  // Refresh after any new meal is logged
  ref.watch(todaysMealsProvider);
  final db = ref.read(databaseProvider);
  return db.getRecentUniqueMeals();
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

// ── Home Widget Sync ──────────────────────────────────────────────────────

/// Push today's nutrition + streak to the home-screen widget.
/// Call after any meal log, workout log, or water log.
Future<void> syncHomeWidget(Ref ref) async {
  try {
    final nutrition = ref.read(dailyNutritionProvider);
    final gamification = ref.read(gamificationProvider);
    await HomeWidgetService.instance.update(
      caloriesConsumed: nutrition.consumedCalories.round(),
      caloriesGoal: nutrition.targetCalories.round(),
      proteinG: nutrition.consumedProtein.round(),
      carbsG: nutrition.consumedCarbs.round(),
      fatG: nutrition.consumedFat.round(),
      streakDays: gamification.currentStreak,
    );
  } catch (_) {
    // Fire-and-forget — never block the UI
  }
}

// ── Gamification Provider ─────────────────────────────────────────────────

class GamificationNotifier extends StateNotifier<GamificationState> {
  GamificationNotifier(this._ref) : super(const GamificationState()) {
    _load();
  }

  final Ref _ref;

  Future<void> _load() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('gamification');
    if (json != null) {
      state = GamificationState.fromJson(jsonDecode(json));
    }
    // Restore from Firestore if signed in — use cloud data if it has more XP
    if (!AuthService.isAnonymous) {
      final uid = AuthService.uid;
      if (uid != null) {
        try {
          final cloudData = await FirestoreService.getGamification(uid);
          if (cloudData != null) {
            final cloudState = GamificationState.fromJson(
              Map<String, dynamic>.from(cloudData),
            );
            if (cloudState.totalXp > state.totalXp) {
              state = cloudState;
              await prefs.setString('gamification', jsonEncode(cloudState.toJson()));
            }
          }
        } catch (_) {}
      }
    }
  }

  Future<void> _save() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('gamification', jsonEncode(state.toJson()));
    // Push to Firestore for non-anonymous users (fire-and-forget)
    if (!AuthService.isAnonymous) {
      final uid = AuthService.uid;
      if (uid != null) {
        FirestoreService.saveGamification(uid, state.toJson())
            .catchError((_) {});
      }
    }
  }

  Future<int> awardXp(int xp, {bool checkStreak = false, String reason = ''}) async {
    final prevLevel = state.currentLevel;
    state = state.copyWith(totalXp: state.totalXp + xp);

    if (checkStreak) await _updateStreak();

    // Check for level up
    final newLevel = state.currentLevel;
    await _save();

    AnalyticsService.instance.track('xp_awarded', props: {
      'amount': xp,
      'reason': reason,
      'new_total': state.totalXp,
    });

    if (newLevel > prevLevel) {
      final levelName = newLevel <= AppConstants.levelNames.length
          ? AppConstants.levelNames[newLevel - 1]
          : 'Unknown';
      AnalyticsService.instance.track('level_up', props: {
        'from': prevLevel,
        'to': newLevel,
        'level_name': levelName,
      });
    }

    syncHomeWidget(_ref); // fire-and-forget — keep widget in sync after XP award
    return newLevel > prevLevel ? newLevel : 0;
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
      AnalyticsService.instance.track('streak_updated', props: {'streak': 1, 'action': 'started'});
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

      AnalyticsService.instance.track('streak_updated', props: {'streak': newStreak, 'action': 'continued'});

      // Check streak badges
      if (newStreak >= 7) await unlockBadgeIfNeeded(Badges.streak7);
      if (newStreak >= 30) await unlockBadgeIfNeeded(Badges.streak30);
      if (newStreak >= 100) await unlockBadgeIfNeeded(Badges.streak100);

      // Fire celebration overlay on milestone days
      if (AppConstants.streakMilestonesForFireAnim.contains(newStreak)) {
        _ref.read(streakMilestoneProvider.notifier).state = newStreak;
      }

      // Trigger in-app review at milestone streaks (7, 14, 30 days)
      if (newStreak == 7 || newStreak == 14 || newStreak == 30) {
        ReviewService.instance.maybeRequestReview(
          trigger: 'streak_milestone_$newStreak',
        );
      }
    } else if (daysDiff > 1) {
      // Check if they have a streak freeze
      if (state.streakFreezesAvailable > 0) {
        state = state.copyWith(
          streakFreezesAvailable: state.streakFreezesAvailable - 1,
          lastLogDate: now,
        );
        AnalyticsService.instance.track('streak_updated', props: {
          'streak': state.currentStreak,
          'action': 'frozen',
          'freezes_left': state.streakFreezesAvailable,
        });
      } else {
        // Streak broken
        state = state.copyWith(
          currentStreak: 1,
          lastLogDate: now,
        );
        AnalyticsService.instance.track('streak_updated', props: {'streak': 1, 'action': 'broken'});
      }
    }

    await _save();
  }

  Future<void> unlockBadgeIfNeeded(String badgeId) async {
    if (!state.unlockedBadges.contains(badgeId)) {
      HapticFeedback.heavyImpact();
      final newBadges = [...state.unlockedBadges, badgeId];
      state = state.copyWith(unlockedBadges: newBadges);
      // Award badge XP
      final badgeInfo = Badges.all[badgeId];
      if (badgeInfo != null) {
        state = state.copyWith(totalXp: state.totalXp + badgeInfo.xpReward);
        AnalyticsService.instance.track('badge_unlocked', props: {
          'badge_id': badgeId,
          'badge_name': badgeInfo.name,
          'xp_reward': badgeInfo.xpReward,
          'total_badges': newBadges.length,
        });
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
  (ref) => GamificationNotifier(ref),
);

// ── Workout Plans ─────────────────────────────────────────────────────────

final workoutPlansProvider = FutureProvider<List<WorkoutPlan>>((ref) {
  final db = ref.watch(databaseProvider);
  return db.getWorkoutPlans();
});

// ── Today's Planned Workout (derived from active plan) ────────────────────

class TodaysPlannedWorkout {
  final bool hasPlan;
  final String workoutName;
  final List<dynamic> exercises;
  final String focusLabel;
  final int estMinutes;
  /// Raw JSON string of the full day object, passed to the active workout screen.
  final String? rawDayJson;

  const TodaysPlannedWorkout({
    this.hasPlan = false,
    this.workoutName = '',
    this.exercises = const [],
    this.focusLabel = '',
    this.estMinutes = 0,
    this.rawDayJson,
  });
}

final todaysPlannedWorkoutProvider = Provider<TodaysPlannedWorkout>((ref) {
  final plansAsync = ref.watch(workoutPlansProvider);
  if (!plansAsync.hasValue) return const TodaysPlannedWorkout();

  final activePlan = plansAsync.value!.where((p) => p.isActive).firstOrNull;
  if (activePlan == null) return const TodaysPlannedWorkout();

  try {
    final planData = jsonDecode(activePlan.planJson) as Map<String, dynamic>;
    final weeks = planData['weeks'] as List? ?? [];
    if (weeks.isEmpty) return const TodaysPlannedWorkout(hasPlan: true);

    final weeksElapsed =
        DateTime.now().difference(activePlan.createdAt).inDays ~/ 7;
    final week = weeks[weeksElapsed % weeks.length] as Map<String, dynamic>;
    final days = week['days'] as List? ?? [];

    const dayNames = [
      'Monday', 'Tuesday', 'Wednesday', 'Thursday',
      'Friday', 'Saturday', 'Sunday',
    ];
    final todayName = dayNames[DateTime.now().weekday - 1];

    Map<String, dynamic>? todayDay;
    for (final d in days) {
      if (d['day_name'] == todayName) {
        todayDay = d as Map<String, dynamic>;
        break;
      }
    }

    if (todayDay == null) return const TodaysPlannedWorkout(hasPlan: true);

    final exercises = todayDay['exercises'] as List? ?? [];
    int totalSets = 0;
    for (final ex in exercises) {
      totalSets += (ex['sets'] as int? ?? 3);
    }
    return TodaysPlannedWorkout(
      hasPlan: true,
      workoutName: todayDay['focus'] as String? ?? 'Workout',
      exercises: exercises,
      focusLabel: todayDay['focus'] as String? ?? '',
      estMinutes: (totalSets * 3).clamp(15, 120),
      rawDayJson: jsonEncode(todayDay),
    );
  } catch (e) {
    debugPrint('[Workouts] parse today workout plan failed: $e');
    return const TodaysPlannedWorkout(hasPlan: true);
  }
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

// ── Best Estimated 1RMs ───────────────────────────────────────────────────

final best1RmsProvider = FutureProvider<Map<String, double>>((ref) {
  ref.watch(todaysWorkoutsProvider);
  final db = ref.watch(databaseProvider);
  return db.getBest1Rms();
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
