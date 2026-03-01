abstract class AppConstants {
  // ── Gemini ────────────────────────────────────────────────────
  static const geminiModel = 'gemini-2.5-flash';
  static const geminiRpmLimit = 15;
  static const geminiRpdLimit = 1500;
  static const geminiTpmLimit = 1000000;

  // ── XP & Levels ───────────────────────────────────────────────
  static const xpLogMeal = 10;
  static const xpAiMealAnalysis = 15;
  static const xpCompleteWorkout = 25;
  static const xpHitAllMacros = 20;
  static const xpLogWater = 5;
  static const xpNewPr = 50;
  static const xpDailyStreakBase = 5; // multiplied by streak day

  static const levelThresholds = [0, 100, 300, 600, 1000, 1500, 2200, 3000];
  static const levelNames = [
    'Rookie', 'Grinder', 'Hustler', 'Achiever',
    'Warrior', 'Beast', 'Legend', 'FitSmart',
  ];

  // ── Streak ────────────────────────────────────────────────────
  static const streakMilestonesForFireAnim = [3, 7, 14, 30, 60, 90];
  static const maxStreakFreezesStored = 2;

  // ── Onboarding Hive Box ───────────────────────────────────────
  static const onboardingBoxName = 'onboarding';
  static const profileBoxName = 'profile';
  static const gamificationBoxName = 'gamification';
  static const settingsBoxName = 'settings';

  // ── Cache TTL (hours) ─────────────────────────────────────────
  static const cacheTtlMealAnalysis = 0; // indefinite
  static const cacheTtlMealPlan = 24;
  static const cacheTtlDailyInsight = 16;
  static const cacheTtlWorkoutPlan = 168; // 7 days

  // ── Nutrition ─────────────────────────────────────────────────
  static const mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Pre-Workout', 'Post-Workout'];

  // ── Activity multipliers (TDEE) ───────────────────────────────
  static const activityMultipliers = {
    'sedentary': 1.2,
    'lightly_active': 1.375,
    'moderately_active': 1.55,
    'very_active': 1.725,
    'extremely_active': 1.9,
  };

  // ── Goal caloric adjustments (from TDEE) ─────────────────────
  static const goalCalAdjustments = {
    'lose_fat': -500,
    'lose_fat_slow': -250,
    'maintain': 0,
    'gain_muscle': 300,
    'gain_muscle_aggressive': 500,
    'recomp': 0, // same cals, different macros
    'athletic': 200,
  };
}
