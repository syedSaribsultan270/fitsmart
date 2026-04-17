import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database/database_provider.dart';
import '../features/dashboard/providers/dashboard_provider.dart';

/// Centralised helper that builds the user-context maps sent to Gemini.
///
/// Three levels of detail are exposed so each caller only sends what the
/// AI actually needs, keeping token usage low on simple requests while
/// giving the AI Coach the full picture.
///
/// All methods are **static** and accept a [WidgetRef] (or the raw data)
/// so that this class has no Riverpod dependency of its own.
class UserContextService {
  UserContextService._(); // prevent instantiation

  // ─── helpers ──────────────────────────────────────────────────────────

  /// Load the raw onboarding profile map from SharedPreferences.
  static Future<Map<String, dynamic>> _loadProfile() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('onboarding_data');
      if (jsonStr != null) {
        return jsonDecode(jsonStr) as Map<String, dynamic>;
      }
    } catch (e) {
      debugPrint('[UserContextService] load profile failed: $e');
    }
    return {};
  }

  // ─── MINIMAL context (meal analysis, text analysis) ───────────────────
  /// Contains only nutrition targets, current consumption, meal type,
  /// and dietary restrictions.  Used by `LogMealScreen` and
  /// `NutritionScreen` (meal-plan generation also extends this).

  static Map<String, dynamic> buildMinimalContextSync({
    required NutritionTargets targets,
    required DailyNutrition nutrition,
    String? mealType,
  }) {
    return {
      'target_calories': targets.calories,
      'target_protein_g': targets.proteinG,
      'consumed_calories_today': nutrition.consumedCalories,
      'consumed_protein_today': nutrition.consumedProtein,
      if (mealType != null) 'meal_type': mealType,
    };
  }

  // ─── PLAN context (meal-plan & workout-plan generation) ───────────────
  /// Adds the user's goal, dietary restrictions, cuisine preferences,
  /// and fitness profile on top of the nutrition targets.

  static Future<Map<String, dynamic>> buildMealPlanContext(
      WidgetRef ref) async {
    final targets = ref.read(nutritionTargetsProvider);
    final profile = await _loadProfile();
    return {
      'goal': profile['primaryGoal'] ?? 'general_fitness',
      'target_calories': targets.calories.round(),
      'target_protein_g': targets.proteinG.round(),
      'target_carbs_g': targets.carbsG.round(),
      'target_fat_g': targets.fatG.round(),
      'dietary_restrictions': profile['dietaryRestrictions'] ?? [],
      'cuisine_preferences': profile['cuisinePreferences'] ?? [],
      'disliked_ingredients': profile['dislikedIngredients'] ?? [],
    };
  }

  static Future<Map<String, dynamic>> buildWorkoutPlanContext(
      WidgetRef ref) async {
    final profile = await _loadProfile();
    return {
      'goal': profile['primaryGoal'] ?? 'build_muscle',
      'equipment': profile['equipment'] ?? 'full_gym',
      'workout_days': profile['workoutDaysPerWeek'] ?? 4,
      'activity_level': profile['activityLevel'] ?? 'moderate',
      'fitness_level': profile['fitnessLevel'] ?? 'intermediate',
    };
  }

  // ─── FULL context (AI Coach chat) ─────────────────────────────────────
  /// Gathers *everything*: profile, nutrition, workouts, PRs, body
  /// measurements, weight history, water intake, gamification, plans,
  /// weekly summary, badges, and sleep schedule.

  static Future<Map<String, dynamic>> buildFullContext(WidgetRef ref) async {
    final nutrition = ref.read(dailyNutritionProvider);
    final gamification = ref.read(gamificationProvider);
    final db = ref.read(databaseProvider);

    // ── Full onboarding profile ────────────────────────────────────────
    final profile = await _loadProfile();

    // ── Today's meals ──────────────────────────────────────────────────
    String todaysMealsStr = '';
    try {
      final meals = await db.getMealsForDate(DateTime.now());
      if (meals.isNotEmpty) {
        final mealLines = meals.map((m) =>
            '${m.mealType}: ${m.name} — ${m.calories.round()} kcal, '
            'P:${m.proteinG.toStringAsFixed(0)}g, '
            'C:${m.carbsG.toStringAsFixed(0)}g, '
            'F:${m.fatG.toStringAsFixed(0)}g '
            '(score: ${m.healthScore}/10)');
        todaysMealsStr = mealLines.join('\n');
      }
    } catch (e) {
      debugPrint('[UserContextService] load today meals failed: $e');
    }

    // ── Recent workouts (last 10) ──────────────────────────────────────
    String recentWorkoutsStr = '';
    try {
      final workouts = await db.getRecentWorkouts(limit: 10);
      if (workouts.isNotEmpty) {
        final wLines = workouts.map((w) =>
            '${w.name} — ${(w.durationSeconds / 60).round()} min, '
            '~${w.estimatedCalories.round()} kcal burned '
            '(${w.completedAt.toIso8601String().substring(0, 10)})');
        recentWorkoutsStr = wLines.join('\n');
      }
    } catch (e) {
      debugPrint('[UserContextService] load recent workouts failed: $e');
    }

    // ── Personal records (all PRs) ─────────────────────────────────────
    String prsStr = '';
    try {
      final prs = await db.getAllPrs();
      if (prs.isNotEmpty) {
        final prLines = prs.entries
            .map((e) => '${e.key}: ${e.value.toStringAsFixed(1)} kg');
        prsStr = prLines.join('\n');
      }
    } catch (e) {
      debugPrint('[UserContextService] load personal records failed: $e');
    }

    // ── Body measurements (latest) ─────────────────────────────────────
    String bodyMeasurementsStr = '';
    try {
      final m = await db.getLatestMeasurement();
      if (m != null) {
        final parts = <String>[];
        if (m.chestCm != null) parts.add('Chest: ${m.chestCm}cm');
        if (m.waistCm != null) parts.add('Waist: ${m.waistCm}cm');
        if (m.hipsCm != null) parts.add('Hips: ${m.hipsCm}cm');
        if (m.bicepCm != null) parts.add('Bicep: ${m.bicepCm}cm');
        if (m.thighCm != null) parts.add('Thigh: ${m.thighCm}cm');
        if (m.neckCm != null) parts.add('Neck: ${m.neckCm}cm');
        if (m.shouldersCm != null) {
          parts.add('Shoulders: ${m.shouldersCm}cm');
        }
        if (m.calfCm != null) parts.add('Calf: ${m.calfCm}cm');
        if (parts.isNotEmpty) {
          bodyMeasurementsStr =
              '${parts.join(', ')} (measured ${m.measuredAt.toIso8601String().substring(0, 10)})';
        }
      }
    } catch (e) {
      debugPrint('[UserContextService] load body measurements failed: $e');
    }

    // ── Weight history (last 30 entries) ───────────────────────────────
    String weightHistoryStr = '';
    try {
      final weights = await db.getWeightHistory(limit: 30);
      if (weights.isNotEmpty) {
        final wLines = weights.take(10).map((w) =>
            '${w.loggedAt.toIso8601String().substring(0, 10)}: '
            '${w.weightKg.toStringAsFixed(1)} kg'
            '${w.note.isNotEmpty ? ' (${w.note})' : ''}');
        weightHistoryStr = wLines.join('\n');
        if (weights.length > 1) {
          final diff = weights.first.weightKg - weights.last.weightKg;
          weightHistoryStr +=
              '\nTrend: ${diff > 0 ? '+' : ''}${diff.toStringAsFixed(1)} kg '
              'over ${weights.length} entries';
        }
      }
    } catch (e) {
      debugPrint('[UserContextService] load weight history failed: $e');
    }

    // ── Water intake today ─────────────────────────────────────────────
    int waterMl = 0;
    try {
      waterMl = await db.getTodaysWater();
    } catch (e) {
      debugPrint('[UserContextService] load water intake failed: $e');
    }

    // ── All-time stats ─────────────────────────────────────────────────
    int totalMeals = 0;
    int totalWorkouts = 0;
    try {
      totalMeals = await db.getMealCountAll();
      totalWorkouts = await db.getWorkoutCountAll();
    } catch (e) {
      debugPrint('[UserContextService] load all-time stats failed: $e');
    }

    // ── Active workout plan ────────────────────────────────────────────
    String activeWorkoutPlanStr = '';
    try {
      final plan = await db.getActiveWorkoutPlan();
      if (plan != null) {
        activeWorkoutPlanStr = '${plan.name} (${plan.weeks} weeks)';
      }
    } catch (e) {
      debugPrint('[UserContextService] load active workout plan failed: $e');
    }

    // ── Active meal plan ───────────────────────────────────────────────
    String activeMealPlanStr = '';
    try {
      final plan = await db.getActiveMealPlan();
      if (plan != null) {
        activeMealPlanStr =
            '${plan.days}-day plan (created ${plan.createdAt.toIso8601String().substring(0, 10)})';
      }
    } catch (e) {
      debugPrint('[UserContextService] load active meal plan failed: $e');
    }

    // ── Recent daily summaries (7 days) ────────────────────────────────
    String weeklySummaryStr = '';
    try {
      final summaries = await db.getRecentSummaries(days: 7);
      if (summaries.isNotEmpty) {
        final sLines = summaries.map((s) =>
            '${s.date.toIso8601String().substring(0, 10)}: '
            '${s.totalCalories.round()} kcal, '
            'P:${s.totalProteinG.round()}g, '
            '${s.workoutsCompleted} workouts, '
            'water:${s.waterMl}ml'
            '${s.streakDay ? ' \u2713streak' : ''}');
        weeklySummaryStr = sLines.join('\n');
      }
    } catch (e) {
      debugPrint('[UserContextService] load weekly summary failed: $e');
    }

    // ── Badges ─────────────────────────────────────────────────────────
    String badgesStr = '';
    if (gamification.unlockedBadges.isNotEmpty) {
      badgesStr = gamification.unlockedBadges.join(', ');
    }

    // ── Sleep schedule ─────────────────────────────────────────────────
    String sleepStr = '';
    if (profile['bedtimeHour'] != null && profile['wakeHour'] != null) {
      final bedH = profile['bedtimeHour'] as int;
      final bedM = profile['bedtimeMin'] as int? ?? 0;
      final wakeH = profile['wakeHour'] as int;
      final wakeM = profile['wakeMin'] as int? ?? 0;
      sleepStr =
          'Bedtime: ${bedH.toString().padLeft(2, '0')}:${bedM.toString().padLeft(2, '0')} '
          '\u2192 Wake: ${wakeH.toString().padLeft(2, '0')}:${wakeM.toString().padLeft(2, '0')}';
      // Calculate sleep hours
      int sleepMins = ((wakeH * 60 + wakeM) - (bedH * 60 + bedM));
      if (sleepMins < 0) sleepMins += 24 * 60;
      sleepStr += ' (~${(sleepMins / 60).toStringAsFixed(1)} hours)';
    }

    return {
      // Full profile
      'goal': profile['primaryGoal'] ?? 'general_fitness',
      'gender': profile['gender'],
      'age': profile['age'],
      'height_cm': profile['heightCm'],
      'weight_kg': profile['weightKg'],
      'body_fat_pct': profile['bodyFatPct'],
      'target_weight_kg': profile['targetWeightKg'],
      'weight_change_pace': profile['weightChangePace'],
      'activity_level': profile['activityLevel'],
      'target_body_type': profile['targetBodyType'],
      'workout_days_per_week': profile['workoutDaysPerWeek'],
      'country': profile['country'],
      'city': profile['city'],
      'dietary_restrictions': profile['dietaryRestrictions'],
      'cuisine_preferences': profile['cuisinePreferences'],
      'disliked_ingredients': profile['dislikedIngredients'],
      'monthly_budget_usd': profile['monthlyBudgetUsd'],
      'sleep_schedule': sleepStr,

      // Nutrition targets & progress
      'target_calories': nutrition.targetCalories.round(),
      'target_protein_g': nutrition.targetProtein.round(),
      'target_carbs_g': nutrition.targetCarbs.round(),
      'target_fat_g': nutrition.targetFat.round(),
      'consumed_calories_today': nutrition.consumedCalories.round(),
      'consumed_protein_today': nutrition.consumedProtein.round(),
      'consumed_carbs_today': nutrition.consumedCarbs.round(),
      'consumed_fat_today': nutrition.consumedFat.round(),
      'water_ml_today': waterMl,

      // Gamification
      'current_streak': gamification.currentStreak,
      'longest_streak': gamification.longestStreak,
      'level': gamification.currentLevel,
      'level_name': gamification.levelName,
      'total_xp': gamification.totalXp,
      'xp_to_next_level': gamification.xpToNextLevel,
      'streak_freezes_available': gamification.streakFreezesAvailable,
      if (badgesStr.isNotEmpty) 'unlocked_badges': badgesStr,

      // All-time stats
      'total_meals_logged': totalMeals,
      'total_workouts_logged': totalWorkouts,

      // Data sections
      if (todaysMealsStr.isNotEmpty) 'todays_meals': todaysMealsStr,
      if (recentWorkoutsStr.isNotEmpty) 'recent_workouts': recentWorkoutsStr,
      if (prsStr.isNotEmpty) 'personal_records': prsStr,
      if (bodyMeasurementsStr.isNotEmpty)
        'body_measurements': bodyMeasurementsStr,
      if (weightHistoryStr.isNotEmpty) 'weight_history': weightHistoryStr,
      if (weeklySummaryStr.isNotEmpty) 'weekly_summary': weeklySummaryStr,
      if (activeWorkoutPlanStr.isNotEmpty)
        'active_workout_plan': activeWorkoutPlanStr,
      if (activeMealPlanStr.isNotEmpty) 'active_meal_plan': activeMealPlanStr,
    };
  }
}
