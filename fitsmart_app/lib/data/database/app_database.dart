import 'package:drift/drift.dart';
import 'package:drift_flutter/drift_flutter.dart';

part 'app_database.g.dart';

// ─── Tables ────────────────────────────────────────────────────────────────

class MealLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get mealType => text()(); // breakfast/lunch/dinner/snack
  RealColumn get calories => real()();
  RealColumn get proteinG => real()();
  RealColumn get carbsG => real()();
  RealColumn get fatG => real()();
  RealColumn get fiberG => real().withDefault(const Constant(0.0))();
  TextColumn get itemsJson => text().withDefault(const Constant('[]'))();
  IntColumn get healthScore => integer().withDefault(const Constant(7))();
  TextColumn get aiFeedback => text().withDefault(const Constant(''))();
  DateTimeColumn get loggedAt => dateTime()();
}

class WorkoutLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  IntColumn get durationSeconds => integer()();
  IntColumn get totalSets => integer().withDefault(const Constant(0))();
  IntColumn get totalReps => integer().withDefault(const Constant(0))();
  RealColumn get estimatedCalories => real().withDefault(const Constant(0.0))();
  TextColumn get exercisesJson => text().withDefault(const Constant('[]'))();
  DateTimeColumn get completedAt => dateTime()();
}

class WorkoutSets extends Table {
  IntColumn get id => integer().autoIncrement()();
  IntColumn get workoutLogId => integer().references(WorkoutLogs, #id)();
  TextColumn get exerciseName => text()();
  TextColumn get muscleGroup => text().withDefault(const Constant(''))();
  IntColumn get setNumber => integer()();
  RealColumn get weightKg => real()();
  IntColumn get reps => integer()();
  IntColumn get rpe => integer().nullable()();
  BoolColumn get isWarmup => boolean().withDefault(const Constant(false))();
  BoolColumn get isPr => boolean().withDefault(const Constant(false))();
  DateTimeColumn get completedAt => dateTime()();
}

class Exercises extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text().unique()();
  TextColumn get muscleGroup => text()();
  TextColumn get equipment => text().withDefault(const Constant('bodyweight'))();
  TextColumn get instructions => text().withDefault(const Constant(''))();
  TextColumn get category => text().withDefault(const Constant('strength'))();
  BoolColumn get isCustom => boolean().withDefault(const Constant(false))();
}

class WorkoutPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get name => text()();
  TextColumn get planJson => text()(); // Full AI-generated plan as JSON
  IntColumn get weeks => integer().withDefault(const Constant(4))();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

class MealPlans extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get planJson => text()(); // Full AI-generated plan as JSON
  IntColumn get days => integer()();
  TextColumn get groceryListJson => text().withDefault(const Constant('[]'))();
  BoolColumn get isActive => boolean().withDefault(const Constant(false))();
  DateTimeColumn get createdAt => dateTime()();
}

class BodyMeasurements extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get chestCm => real().nullable()();
  RealColumn get waistCm => real().nullable()();
  RealColumn get hipsCm => real().nullable()();
  RealColumn get bicepCm => real().nullable()();
  RealColumn get thighCm => real().nullable()();
  RealColumn get neckCm => real().nullable()();
  RealColumn get shouldersCm => real().nullable()();
  RealColumn get calfCm => real().nullable()();
  DateTimeColumn get measuredAt => dateTime()();
}

class WeightLogs extends Table {
  IntColumn get id => integer().autoIncrement()();
  RealColumn get weightKg => real()();
  TextColumn get note => text().withDefault(const Constant(''))();
  DateTimeColumn get loggedAt => dateTime()();
}

class DailySummaries extends Table {
  IntColumn get id => integer().autoIncrement()();
  DateTimeColumn get date => dateTime()();
  RealColumn get totalCalories => real().withDefault(const Constant(0.0))();
  RealColumn get totalProteinG => real().withDefault(const Constant(0.0))();
  RealColumn get totalCarbsG => real().withDefault(const Constant(0.0))();
  RealColumn get totalFatG => real().withDefault(const Constant(0.0))();
  IntColumn get workoutsCompleted => integer().withDefault(const Constant(0))();
  IntColumn get xpEarned => integer().withDefault(const Constant(0))();
  BoolColumn get streakDay => boolean().withDefault(const Constant(false))();
  IntColumn get waterMl => integer().withDefault(const Constant(0))();
}

class AiInsights extends Table {
  IntColumn get id => integer().autoIncrement()();
  TextColumn get insight => text()();
  TextColumn get icon => text().withDefault(const Constant('💡'))();
  TextColumn get category => text().withDefault(const Constant('motivation'))();
  DateTimeColumn get generatedAt => dateTime()();
  BoolColumn get dismissed => boolean().withDefault(const Constant(false))();
}

// ─── Database ──────────────────────────────────────────────────────────────

@DriftDatabase(tables: [
  MealLogs, WorkoutLogs, WorkoutSets, Exercises, WorkoutPlans,
  MealPlans, BodyMeasurements, WeightLogs, DailySummaries, AiInsights,
])
class AppDatabase extends _$AppDatabase {
  AppDatabase() : super(_openConnection());

  /// Constructor for testing with a custom executor (e.g. in-memory).
  AppDatabase.forTesting(super.executor);

  @override
  int get schemaVersion => 2;

  @override
  MigrationStrategy get migration => MigrationStrategy(
    onCreate: (m) => m.createAll(),
    onUpgrade: (m, from, to) async {
      // From v1 → v2: add new tables
      if (from < 2) {
        await m.createTable(workoutSets);
        await m.createTable(exercises);
        await m.createTable(workoutPlans);
        await m.createTable(mealPlans);
        await m.createTable(bodyMeasurements);
        // Add waterMl column to dailySummaries
        await m.addColumn(dailySummaries, dailySummaries.waterMl);
      }
    },
  );

  static QueryExecutor _openConnection() {
    return driftDatabase(
      name: 'fitsmart_db',
      web: DriftWebOptions(
        sqlite3Wasm: Uri.parse('sqlite3.wasm'),
        driftWorker: Uri.parse('drift_worker.js'),
      ),
    );
  }

  // ── Meal DAOs ─────────────────────────────────────────────────────────

  Future<List<MealLog>> getMealsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(mealLogs)
          ..where((t) => t.loggedAt.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.asc(t.loggedAt)]))
        .get();
  }

  Future<int> insertMeal(MealLogsCompanion meal) => into(mealLogs).insert(meal);

  Future<bool> deleteMeal(int id) async {
    final count = await (delete(mealLogs)..where((t) => t.id.equals(id))).go();
    return count > 0;
  }

  Stream<List<MealLog>> watchTodaysMeals() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(mealLogs)
          ..where((t) => t.loggedAt.isBetweenValues(start, end))
          ..orderBy([(t) => OrderingTerm.asc(t.loggedAt)]))
        .watch();
  }

  Future<int> getMealCountAll() async {
    final count = countAll();
    final query = selectOnly(mealLogs)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // ── Workout DAOs ───────────────────────────────────────────────────────

  Future<List<WorkoutLog>> getWorkoutsForDate(DateTime date) {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    return (select(workoutLogs)
          ..where((t) => t.completedAt.isBetweenValues(start, end)))
        .get();
  }

  Future<List<WorkoutLog>> getRecentWorkouts({int limit = 10}) {
    return (select(workoutLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)])
          ..limit(limit))
        .get();
  }

  Future<int> insertWorkout(WorkoutLogsCompanion workout) =>
      into(workoutLogs).insert(workout);

  Future<int> getWorkoutCountAll() async {
    final count = countAll();
    final query = selectOnly(workoutLogs)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  Stream<List<WorkoutLog>> watchTodaysWorkouts() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    return (select(workoutLogs)
          ..where((t) => t.completedAt.isBetweenValues(start, end)))
        .watch();
  }

  // ── Workout Sets DAOs ──────────────────────────────────────────────────

  Future<int> insertWorkoutSet(WorkoutSetsCompanion s) =>
      into(workoutSets).insert(s);

  Future<void> insertWorkoutSets(List<WorkoutSetsCompanion> sets) async {
    await batch((b) => b.insertAll(workoutSets, sets));
  }

  Future<List<WorkoutSet>> getSetsForWorkout(int workoutLogId) {
    return (select(workoutSets)
          ..where((t) => t.workoutLogId.equals(workoutLogId))
          ..orderBy([(t) => OrderingTerm.asc(t.setNumber)]))
        .get();
  }

  /// Get the max weight lifted for a given exercise name.
  Future<double?> getExercisePr(String exerciseName) async {
    final query = selectOnly(workoutSets)
      ..addColumns([workoutSets.weightKg.max()])
      ..where(workoutSets.exerciseName.equals(exerciseName) &
          workoutSets.isWarmup.equals(false));
    final result = await query.getSingle();
    return result.read(workoutSets.weightKg.max());
  }

  /// Get all PRs (max weight per exercise).
  Future<Map<String, double>> getAllPrs() async {
    final query = selectOnly(workoutSets)
      ..addColumns([workoutSets.exerciseName, workoutSets.weightKg.max()])
      ..where(workoutSets.isWarmup.equals(false))
      ..groupBy([workoutSets.exerciseName]);
    final results = await query.get();
    final map = <String, double>{};
    for (final row in results) {
      final name = row.read(workoutSets.exerciseName);
      final max = row.read(workoutSets.weightKg.max());
      if (name != null && max != null) map[name] = max;
    }
    return map;
  }

  // ── Exercise DAOs ──────────────────────────────────────────────────────

  Future<List<Exercise>> getAllExercises() => select(exercises).get();

  Future<List<Exercise>> searchExercises(String query) {
    return (select(exercises)
          ..where((t) => t.name.like('%$query%'))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<List<Exercise>> getExercisesByMuscle(String muscle) {
    return (select(exercises)
          ..where((t) => t.muscleGroup.equals(muscle))
          ..orderBy([(t) => OrderingTerm.asc(t.name)]))
        .get();
  }

  Future<void> insertExercises(List<ExercisesCompanion> items) async {
    await batch((b) => b.insertAllOnConflictUpdate(exercises, items));
  }

  Future<int> getExerciseCount() async {
    final count = countAll();
    final query = selectOnly(exercises)..addColumns([count]);
    final result = await query.getSingle();
    return result.read(count) ?? 0;
  }

  // ── Workout Plans DAOs ─────────────────────────────────────────────────

  Future<int> insertWorkoutPlan(WorkoutPlansCompanion plan) =>
      into(workoutPlans).insert(plan);

  Future<List<WorkoutPlan>> getWorkoutPlans() {
    return (select(workoutPlans)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<WorkoutPlan?> getActiveWorkoutPlan() async {
    final results = await (select(workoutPlans)
          ..where((t) => t.isActive.equals(true))
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  // ── Meal Plans DAOs ────────────────────────────────────────────────────

  Future<int> insertMealPlan(MealPlansCompanion plan) =>
      into(mealPlans).insert(plan);

  Future<List<MealPlan>> getMealPlans() {
    return (select(mealPlans)
          ..orderBy([(t) => OrderingTerm.desc(t.createdAt)]))
        .get();
  }

  Future<MealPlan?> getActiveMealPlan() async {
    final results = await (select(mealPlans)
          ..where((t) => t.isActive.equals(true))
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  // ── Body Measurements DAOs ─────────────────────────────────────────────

  Future<int> insertMeasurement(BodyMeasurementsCompanion m) =>
      into(bodyMeasurements).insert(m);

  Future<List<BodyMeasurement>> getMeasurementHistory({int limit = 20}) {
    return (select(bodyMeasurements)
          ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)])
          ..limit(limit))
        .get();
  }

  Future<BodyMeasurement?> getLatestMeasurement() async {
    final results = await (select(bodyMeasurements)
          ..orderBy([(t) => OrderingTerm.desc(t.measuredAt)])
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  // ── Weight DAOs ────────────────────────────────────────────────────────

  Future<List<WeightLog>> getWeightHistory({int limit = 30}) {
    return (select(weightLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.loggedAt)])
          ..limit(limit))
        .get();
  }

  Future<int> insertWeight(WeightLogsCompanion entry) =>
      into(weightLogs).insert(entry);

  Stream<List<WeightLog>> watchWeightHistory({int limit = 60, DateTime? since}) {
    final q = select(weightLogs)
      ..orderBy([(t) => OrderingTerm.desc(t.loggedAt)]);
    if (since != null) {
      q.where((t) => t.loggedAt.isBiggerOrEqualValue(since));
    } else {
      q.limit(limit);
    }
    return q.watch();
  }

  Future<WeightLog?> getLatestWeight() async {
    final results = await (select(weightLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.loggedAt)])
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  // ── Daily Summary DAOs ─────────────────────────────────────────────────

  Future<DailySummary?> getSummaryForDate(DateTime date) async {
    final start = DateTime(date.year, date.month, date.day);
    final end = start.add(const Duration(days: 1));
    final results = await (select(dailySummaries)
          ..where((t) => t.date.isBetweenValues(start, end))
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  Future<List<DailySummary>> getRecentSummaries({int days = 30}) {
    final cutoff = DateTime.now().subtract(Duration(days: days));
    return (select(dailySummaries)
          ..where((t) => t.date.isBiggerThanValue(cutoff))
          ..orderBy([(t) => OrderingTerm.desc(t.date)]))
        .get();
  }

  Future<void> upsertDailySummary(DailySummariesCompanion summary) async {
    await into(dailySummaries).insertOnConflictUpdate(summary);
  }

  /// Update water intake for today.
  Future<void> addWater(int ml) async {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final existing = await getSummaryForDate(today);
    if (existing != null) {
      await (update(dailySummaries)..where((t) => t.id.equals(existing.id)))
          .write(DailySummariesCompanion(
        waterMl: Value(existing.waterMl + ml),
      ));
    } else {
      await into(dailySummaries).insert(DailySummariesCompanion(
        date: Value(today),
        waterMl: Value(ml),
      ));
    }
  }

  /// Get today's water intake in ml.
  Future<int> getTodaysWater() async {
    final summary = await getSummaryForDate(DateTime.now());
    return summary?.waterMl ?? 0;
  }

  // ── AI Insight DAOs ────────────────────────────────────────────────────

  Future<AiInsight?> getTodaysInsight() async {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    final end = start.add(const Duration(days: 1));
    final results = await (select(aiInsights)
          ..where((t) =>
              t.generatedAt.isBetweenValues(start, end) &
              t.dismissed.equals(false))
          ..limit(1))
        .get();
    return results.isEmpty ? null : results.first;
  }

  Future<int> insertInsight(AiInsightsCompanion insight) =>
      into(aiInsights).insert(insight);

  Future<void> dismissInsight(int id) async {
    await (update(aiInsights)..where((t) => t.id.equals(id)))
        .write(const AiInsightsCompanion(dismissed: Value(true)));
  }
}
