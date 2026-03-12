import 'package:flutter_test/flutter_test.dart';
import 'package:drift/drift.dart' hide isNull, isNotNull;
import 'package:drift/native.dart';
import 'package:fitsmart_app/data/database/app_database.dart';

/// Creates an in-memory database for testing.
AppDatabase _createTestDb() {
  return AppDatabase.forTesting(NativeDatabase.memory());
}

void main() {
  late AppDatabase db;

  setUp(() {
    db = _createTestDb();
  });

  tearDown(() async {
    await db.close();
  });

  group('MealLog CRUD', () {
    test('insertMeal and getMealsForDate — date filtering', () async {
      final today = DateTime.now();
      final yesterday = today.subtract(const Duration(days: 1));

      // Insert a meal for today
      await db.insertMeal(MealLogsCompanion(
        name: const Value('Chicken Salad'),
        mealType: const Value('lunch'),
        calories: const Value(350.0),
        proteinG: const Value(40.0),
        carbsG: const Value(15.0),
        fatG: const Value(12.0),
        loggedAt: Value(today),
      ));

      // Insert a meal for yesterday
      await db.insertMeal(MealLogsCompanion(
        name: const Value('Pizza'),
        mealType: const Value('dinner'),
        calories: const Value(800.0),
        proteinG: const Value(30.0),
        carbsG: const Value(80.0),
        fatG: const Value(35.0),
        loggedAt: Value(yesterday),
      ));

      // Query today's meals
      final todayMeals = await db.getMealsForDate(today);
      expect(todayMeals.length, 1);
      expect(todayMeals.first.name, 'Chicken Salad');

      // Query yesterday's meals
      final yesterdayMeals = await db.getMealsForDate(yesterday);
      expect(yesterdayMeals.length, 1);
      expect(yesterdayMeals.first.name, 'Pizza');
    });
  });

  group('WorkoutLog CRUD', () {
    test('insertWorkout and getWorkoutsForDate', () async {
      final today = DateTime.now();

      await db.insertWorkout(WorkoutLogsCompanion(
        name: const Value('Push Day'),
        durationSeconds: const Value(3600),
        completedAt: Value(today),
      ));

      final workouts = await db.getWorkoutsForDate(today);
      expect(workouts.length, 1);
      expect(workouts.first.name, 'Push Day');
      expect(workouts.first.durationSeconds, 3600);
    });
  });

  group('WorkoutSets and PR detection', () {
    test('insertWorkoutSet and getExercisePr', () async {
      final now = DateTime.now();

      // Insert a workout first
      final workoutId = await db.insertWorkout(WorkoutLogsCompanion(
        name: const Value('Chest Day'),
        durationSeconds: const Value(3600),
        completedAt: Value(now),
      ));

      // Insert sets with different weights
      await db.insertWorkoutSet(WorkoutSetsCompanion(
        workoutLogId: Value(workoutId),
        exerciseName: const Value('Bench Press'),
        setNumber: const Value(1),
        weightKg: const Value(80.0),
        reps: const Value(8),
        completedAt: Value(now),
      ));

      await db.insertWorkoutSet(WorkoutSetsCompanion(
        workoutLogId: Value(workoutId),
        exerciseName: const Value('Bench Press'),
        setNumber: const Value(2),
        weightKg: const Value(100.0),
        reps: const Value(5),
        completedAt: Value(now),
      ));

      await db.insertWorkoutSet(WorkoutSetsCompanion(
        workoutLogId: Value(workoutId),
        exerciseName: const Value('Bench Press'),
        setNumber: const Value(3),
        weightKg: const Value(90.0),
        reps: const Value(6),
        completedAt: Value(now),
      ));

      // PR should be 100.0
      final pr = await db.getExercisePr('Bench Press');
      expect(pr, 100.0);
    });

    test('getExercisePr excludes warmup sets', () async {
      final now = DateTime.now();

      final workoutId = await db.insertWorkout(WorkoutLogsCompanion(
        name: const Value('Leg Day'),
        durationSeconds: const Value(3600),
        completedAt: Value(now),
      ));

      // Warmup set with heavy weight (should be excluded)
      await db.insertWorkoutSet(WorkoutSetsCompanion(
        workoutLogId: Value(workoutId),
        exerciseName: const Value('Squat'),
        setNumber: const Value(1),
        weightKg: const Value(200.0),
        reps: const Value(1),
        isWarmup: const Value(true),
        completedAt: Value(now),
      ));

      // Working set
      await db.insertWorkoutSet(WorkoutSetsCompanion(
        workoutLogId: Value(workoutId),
        exerciseName: const Value('Squat'),
        setNumber: const Value(2),
        weightKg: const Value(120.0),
        reps: const Value(5),
        isWarmup: const Value(false),
        completedAt: Value(now),
      ));

      final pr = await db.getExercisePr('Squat');
      expect(pr, 120.0);
    });

    test('getAllPrs returns max weight per exercise', () async {
      final now = DateTime.now();

      final workoutId = await db.insertWorkout(WorkoutLogsCompanion(
        name: const Value('Full Body'),
        durationSeconds: const Value(5400),
        completedAt: Value(now),
      ));

      await db.insertWorkoutSet(WorkoutSetsCompanion(
        workoutLogId: Value(workoutId),
        exerciseName: const Value('Bench Press'),
        setNumber: const Value(1),
        weightKg: const Value(100.0),
        reps: const Value(5),
        completedAt: Value(now),
      ));

      await db.insertWorkoutSet(WorkoutSetsCompanion(
        workoutLogId: Value(workoutId),
        exerciseName: const Value('Squat'),
        setNumber: const Value(1),
        weightKg: const Value(140.0),
        reps: const Value(5),
        completedAt: Value(now),
      ));

      final prs = await db.getAllPrs();
      expect(prs['Bench Press'], 100.0);
      expect(prs['Squat'], 140.0);
    });
  });

  group('WeightLog', () {
    test('insertWeight and getWeightHistory ordering', () async {
      await db.insertWeight(WeightLogsCompanion(
        weightKg: const Value(80.0),
        loggedAt: Value(DateTime(2025, 3, 1)),
      ));

      await db.insertWeight(WeightLogsCompanion(
        weightKg: const Value(79.5),
        loggedAt: Value(DateTime(2025, 3, 2)),
      ));

      await db.insertWeight(WeightLogsCompanion(
        weightKg: const Value(79.0),
        loggedAt: Value(DateTime(2025, 3, 3)),
      ));

      final history = await db.getWeightHistory(limit: 10);
      // Should be ordered descending by loggedAt
      expect(history.length, 3);
      expect(history.first.weightKg, 79.0); // most recent
      expect(history.last.weightKg, 80.0); // oldest
    });
  });

  group('Water intake (DailySummary)', () {
    test('addWater creates summary if none exists', () async {
      await db.addWater(250);
      final water = await db.getTodaysWater();
      expect(water, 250);
    });

    test('addWater upserts — accumulates water', () async {
      await db.addWater(250);
      await db.addWater(500);
      final water = await db.getTodaysWater();
      expect(water, 750);
    });
  });

  group('Exercise search', () {
    test('insertExercises and searchExercises', () async {
      await db.insertExercises([
        const ExercisesCompanion(
          name: Value('Bench Press'),
          muscleGroup: Value('chest'),
        ),
        const ExercisesCompanion(
          name: Value('Incline Bench Press'),
          muscleGroup: Value('chest'),
        ),
        const ExercisesCompanion(
          name: Value('Squat'),
          muscleGroup: Value('legs'),
        ),
      ]);

      final results = await db.searchExercises('Bench');
      expect(results.length, 2);
      expect(results.any((e) => e.name == 'Bench Press'), true);
      expect(results.any((e) => e.name == 'Incline Bench Press'), true);
    });

    test('searchExercises returns empty for no match', () async {
      await db.insertExercises([
        const ExercisesCompanion(
          name: Value('Squat'),
          muscleGroup: Value('legs'),
        ),
      ]);

      final results = await db.searchExercises('Curl');
      expect(results, isEmpty);
    });
  });

  group('AI Insights', () {
    test('insertInsight and getTodaysInsight', () async {
      final now = DateTime.now();
      await db.insertInsight(AiInsightsCompanion(
        insight: const Value('Great job hitting your protein target!'),
        icon: const Value('💪'),
        category: const Value('nutrition'),
        generatedAt: Value(now),
      ));

      final insight = await db.getTodaysInsight();
      expect(insight, isNotNull);
      expect(insight!.insight, 'Great job hitting your protein target!');
      expect(insight.icon, '💪');
    });

    test('dismissInsight marks insight as dismissed', () async {
      final now = DateTime.now();
      final id = await db.insertInsight(AiInsightsCompanion(
        insight: const Value('Stay hydrated!'),
        generatedAt: Value(now),
      ));

      await db.dismissInsight(id);

      // getTodaysInsight should return null (filtered by dismissed = false)
      final insight = await db.getTodaysInsight();
      expect(insight, isNull);
    });
  });
}
