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

  // ── Cache TTL (hours) ─────────────────────────────────────────
  static const cacheTtlMealAnalysis = 0; // indefinite
  static const cacheTtlMealPlan = 24;
  static const cacheTtlDailyInsight = 16;
  static const cacheTtlWorkoutPlan = 168; // 7 days

  // ── Nutrition ─────────────────────────────────────────────────
  static const mealTypes = ['Breakfast', 'Lunch', 'Dinner', 'Snack', 'Pre-Workout', 'Post-Workout'];

  /// Minimum food-search confidence score to show the verified badge.
  static const double foodMatchScoreThreshold = 0.89;

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

  // ── AI Fallback / Circuit Breaker ───────────────────────────
  /// How long (seconds) the circuit stays "open" after a Gemini failure
  /// before trying Gemini again.
  static const circuitBreakerOpenDurationSec = 120; // 2 min

  /// Number of consecutive Gemini failures before opening the circuit.
  static const circuitBreakerFailureThreshold = 2;

  /// Timeout for a single Gemini request (seconds).
  /// gemini-2.5-flash is a thinking model — needs more headroom than 1.5-flash.
  static const geminiRequestTimeoutSec = 30;

  /// Max local fallback response generation time (seconds).
  static const localFallbackTimeoutSec = 2;

  // ── On-Device LLM (Gemma 3 1B) ─────────────────────────────
  /// Gemma 3 1B int4 CPU model file name on disk (~529 MB).
  static const llmModelFileName = 'gemma3-1b-it-int4.task';

  /// Download URL for the on-device LLM model (Hugging Face — requires Gemma license acceptance).
  static const llmModelDownloadUrl =
      'https://huggingface.co/litert-community/Gemma3-1B-IT/resolve/main/gemma3-1b-it-int4.task';

  /// Max tokens for local LLM generation (input + output).
  static const llmMaxTokens = 1024;

  /// Temperature for local LLM (slightly creative for coach persona).
  static const llmTemperature = 0.7;

  /// Top-K sampling for local LLM.
  static const llmTopK = 40;

  /// Timeout for local LLM inference (seconds).
  static const llmInferenceTimeoutSec = 30;

  // ── Groq Cloud Fallback ──────────────────────────────────────
  /// Groq model — Llama 3.3 70B: fast, strong general knowledge.
  static const groqModel = 'llama-3.3-70b-versatile';

  /// Timeout for a single Groq request (seconds).
  static const groqRequestTimeoutSec = 20;

  // ── Workout Calorie Estimation ───────────────────────────────
  /// Base kcal contribution per rep (before weight factor).
  static const double workoutCalPerRepBase = 0.15;

  /// Additional kcal per kg of load per rep.
  static const double workoutCalPerKgFactor = 0.005;

  /// Approximate base metabolic rate during exercise (kcal / minute).
  static const double workoutBaseMetabolicRatePerMin = 3.0;

  // ── Workout Recovery ─────────────────────────────────────────
  /// Max age (hours) of a crash-saved workout state before it is discarded.
  static const int workoutRecoveryTimeoutHours = 6;

  // ── External APIs ─────────────────────────────────────────────
  /// Open Food Facts public API base URL (no key required).
  static const openFoodFactsBaseUrl = 'https://world.openfoodfacts.org';

  // ── Free Tier Limits ─────────────────────────────────────────
  /// Max AI chat messages per day for free users.
  /// Generous on text — keeps coach engagement loop alive.
  static const freeTierDailyAiMessages = 20;

  /// Max meal photo analyses per day for free users.
  /// Photo scans are the headline premium upsell — one taste, then paywall.
  static const freeTierDailyPhotoAnalyses = 1;

  /// Max progress photos for free users (total, not per day).
  static const freeTierMaxProgressPhotos = 3;

  // ── Weekly Review ────────────────────────────────────────────
  /// Default weekly review notification day (1=Monday … 7=Sunday).
  static const defaultWeeklyReviewWeekday = 1;
  /// Default weekly review notification hour (0–23, local time).
  static const defaultWeeklyReviewHour = 6;
}
