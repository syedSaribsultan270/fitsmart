import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../data/database/app_database.dart';
import 'firestore_service.dart';

/// Bidirectional sync between local Drift and Firestore.
///
/// PUSH  → happens automatically after every data write (already wired in
///          log_meal_screen, active_workout_screen, progress_screen).
///
/// PULL  → called once per hour when a non-anonymous user signs in.
///          Imports up to 90 days of history from Firestore into local Drift.
///          Safe to call multiple times — internally throttled.
class SyncService {
  SyncService._();
  static final instance = SyncService._();

  static const _prefUid = 'sync_uid';
  static const _prefLastPullMs = 'sync_last_pull_ms';
  static const _pullCooldownMs = 60 * 60 * 1000; // 1 hour between pulls

  bool _isPulling = false;

  // ── Pull ──────────────────────────────────────────────────────────────────

  /// Download cloud data and merge into local Drift. Throttled to once per
  /// hour for the same uid. Safe to call on every sign-in.
  Future<void> pullAndMerge(String uid, AppDatabase db) async {
    if (uid.isEmpty || _isPulling) return;

    final prefs = await SharedPreferences.getInstance();
    final lastUid = prefs.getString(_prefUid);
    final lastPull = prefs.getInt(_prefLastPullMs) ?? 0;
    final now = DateTime.now().millisecondsSinceEpoch;

    if (lastUid == uid && now - lastPull < _pullCooldownMs) return;

    _isPulling = true;
    debugPrint('[Sync] pull-and-merge uid=$uid');

    try {
      final since = DateTime.now().subtract(const Duration(days: 90));
      await Future.wait([
        _pullMeals(uid, db, since),
        _pullWorkouts(uid, db, since),
        _pullWeights(uid, db, since),
        _pullMeasurements(uid, db, since),
        _pullWorkoutPlans(uid, db),
        _pullMealPlans(uid, db),
      ]);
      await prefs.setString(_prefUid, uid);
      await prefs.setInt(_prefLastPullMs, now);
      debugPrint('[Sync] pull-and-merge complete');
    } catch (e) {
      debugPrint('[Sync] pull failed: $e');
    } finally {
      _isPulling = false;
    }
  }

  // ── Meals ─────────────────────────────────────────────────────────────────

  Future<void> _pullMeals(String uid, AppDatabase db, DateTime since) async {
    final snap = await FirestoreService.getMealLogs(uid, since: since);
    int imported = 0;
    for (final doc in snap.docs) {
      try {
        final d = doc.data() as Map<String, dynamic>;
        final loggedAt = _parseDateTime(d['loggedAt']);
        if (loggedAt == null) continue;
        if (await db.mealExistsNear(loggedAt)) continue;
        // Carry the Firestore doc ID across so future deletes target the
        // exact cloud doc instead of recomputing the deterministic hash.
        await db.insertMeal(MealLogsCompanion(
          name: Value(d['name'] as String? ?? ''),
          mealType: Value(d['mealType'] as String? ?? 'Lunch'),
          calories: Value((d['calories'] as num? ?? 0).toDouble()),
          proteinG: Value((d['proteinG'] as num? ?? 0).toDouble()),
          carbsG: Value((d['carbsG'] as num? ?? 0).toDouble()),
          fatG: Value((d['fatG'] as num? ?? 0).toDouble()),
          fiberG: Value((d['fiberG'] as num? ?? 0).toDouble()),
          healthScore: Value((d['healthScore'] as num?)?.toInt() ?? 7),
          aiFeedback: Value(d['aiFeedback'] as String? ?? ''),
          itemsJson: const Value('[]'),
          loggedAt: Value(loggedAt),
          cloudId: Value(doc.id),
        ));
        imported++;
      } catch (e) {
        debugPrint('[Sync] meal import error: $e');
      }
    }
    if (imported > 0) debugPrint('[Sync] meals imported: $imported');
  }

  // ── Workouts ──────────────────────────────────────────────────────────────

  Future<void> _pullWorkouts(String uid, AppDatabase db, DateTime since) async {
    final snap = await FirestoreService.getWorkoutLogs(uid, since: since);
    int imported = 0;
    for (final doc in snap.docs) {
      try {
        final d = doc.data() as Map<String, dynamic>;
        final completedAt = _parseDateTime(d['completedAt']);
        if (completedAt == null) continue;
        if (await db.workoutExistsNear(completedAt)) continue;
        final workoutId = await db.insertWorkout(WorkoutLogsCompanion(
          name: Value(d['name'] as String? ?? 'Workout'),
          durationSeconds: Value((d['durationSeconds'] as num? ?? 0).toInt()),
          totalSets: Value((d['totalSets'] as num? ?? 0).toInt()),
          totalReps: Value((d['totalReps'] as num? ?? 0).toInt()),
          estimatedCalories: Value((d['estimatedCalories'] as num? ?? 0).toDouble()),
          exercisesJson: const Value('[]'),
          completedAt: Value(completedAt),
          cloudId: Value(doc.id),
        ));
        imported++;

        // Restore per-set detail if present (added when sets sync was wired)
        final setsData = d['sets'] as List?;
        if (setsData != null && setsData.isNotEmpty) {
          try {
            final setCompanions = setsData.map((s) {
              final sm = s as Map<String, dynamic>;
              return WorkoutSetsCompanion(
                workoutLogId: Value(workoutId),
                exerciseName: Value(sm['exerciseName'] as String? ?? ''),
                muscleGroup: Value(sm['muscleGroup'] as String? ?? ''),
                setNumber: Value((sm['setNumber'] as num? ?? 1).toInt()),
                weightKg: Value((sm['weightKg'] as num? ?? 0).toDouble()),
                reps: Value((sm['reps'] as num? ?? 0).toInt()),
                rpe: Value((sm['rpe'] as num?)?.toInt()),
                isWarmup: Value(sm['isWarmup'] as bool? ?? false),
                isPr: Value(sm['isPr'] as bool? ?? false),
                estimated1Rm: Value((sm['estimated1Rm'] as num?)?.toDouble()),
                completedAt: Value(completedAt),
              );
            }).toList();
            await db.insertWorkoutSets(setCompanions);
          } catch (e) {
            debugPrint('[Sync] workout sets import error: $e');
          }
        }
      } catch (e) {
        debugPrint('[Sync] workout import error: $e');
      }
    }
    if (imported > 0) debugPrint('[Sync] workouts imported: $imported');
  }

  // ── Weight ────────────────────────────────────────────────────────────────

  Future<void> _pullWeights(String uid, AppDatabase db, DateTime since) async {
    final snap = await FirestoreService.getWeightLogs(uid, since: since);
    int imported = 0;
    for (final doc in snap.docs) {
      try {
        final d = doc.data() as Map<String, dynamic>;
        final loggedAt = _parseDateTime(d['loggedAt']);
        if (loggedAt == null) continue;
        if (await db.weightExistsNear(loggedAt)) continue;
        await db.insertWeight(WeightLogsCompanion(
          weightKg: Value((d['weightKg'] as num? ?? 0).toDouble()),
          loggedAt: Value(loggedAt),
          cloudId: Value(doc.id),
        ));
        imported++;
      } catch (e) {
        debugPrint('[Sync] weight import error: $e');
      }
    }
    if (imported > 0) debugPrint('[Sync] weights imported: $imported');
  }

  // ── Body Measurements ─────────────────────────────────────────────────────

  Future<void> _pullMeasurements(String uid, AppDatabase db, DateTime since) async {
    try {
      final snap = await FirestoreService.getBodyMeasurements(uid, since: since);
      int imported = 0;
      for (final doc in snap.docs) {
        try {
          final d = doc.data() as Map<String, dynamic>;
          final measuredAt = _parseDateTime(d['measuredAt']);
          if (measuredAt == null) continue;
          if (await db.measurementExistsNear(measuredAt)) continue;
          await db.insertMeasurement(BodyMeasurementsCompanion(
            chestCm: Value((d['chestCm'] as num?)?.toDouble()),
            waistCm: Value((d['waistCm'] as num?)?.toDouble()),
            hipsCm: Value((d['hipsCm'] as num?)?.toDouble()),
            bicepCm: Value((d['bicepCm'] as num?)?.toDouble()),
            thighCm: Value((d['thighCm'] as num?)?.toDouble()),
            neckCm: Value((d['neckCm'] as num?)?.toDouble()),
            shouldersCm: Value((d['shouldersCm'] as num?)?.toDouble()),
            calfCm: Value((d['calfCm'] as num?)?.toDouble()),
            measuredAt: Value(measuredAt),
            cloudId: Value(doc.id),
          ));
          imported++;
        } catch (e) {
          debugPrint('[Sync] measurement import error: $e');
        }
      }
      if (imported > 0) debugPrint('[Sync] measurements imported: $imported');
    } catch (e) {
      debugPrint('[Sync] measurements pull failed: $e');
    }
  }

  // ── Workout Plans ─────────────────────────────────────────────────────────

  Future<void> _pullWorkoutPlans(String uid, AppDatabase db) async {
    try {
      final snap = await FirestoreService.getWorkoutPlans(uid);
      int imported = 0;
      for (final doc in snap.docs) {
        try {
          final d = doc.data() as Map<String, dynamic>;
          final createdAt = _parseDateTime(d['createdAt']);
          if (createdAt == null) continue;
          if (await db.workoutPlanExistsNear(createdAt)) continue;
          await db.insertWorkoutPlan(WorkoutPlansCompanion(
            name: Value(d['name'] as String? ?? 'AI Workout Plan'),
            planJson: Value(d['planJson'] as String? ?? '{}'),
            weeks: Value((d['weeks'] as num? ?? 4).toInt()),
            isActive: Value(d['isActive'] as bool? ?? false),
            createdAt: Value(createdAt),
          ));
          imported++;
        } catch (e) {
          debugPrint('[Sync] workout plan import error: $e');
        }
      }
      if (imported > 0) debugPrint('[Sync] workout plans imported: $imported');
    } catch (e) {
      debugPrint('[Sync] workout plans pull failed: $e');
    }
  }

  // ── Meal Plans ────────────────────────────────────────────────────────────

  Future<void> _pullMealPlans(String uid, AppDatabase db) async {
    try {
      final snap = await FirestoreService.getMealPlans(uid);
      int imported = 0;
      for (final doc in snap.docs) {
        try {
          final d = doc.data() as Map<String, dynamic>;
          final createdAt = _parseDateTime(d['createdAt']);
          if (createdAt == null) continue;
          if (await db.mealPlanExistsNear(createdAt)) continue;
          await db.insertMealPlan(MealPlansCompanion(
            planJson: Value(d['planJson'] as String? ?? '{}'),
            days: Value((d['days'] as num? ?? 7).toInt()),
            groceryListJson: Value(d['groceryListJson'] as String? ?? '[]'),
            isActive: Value(d['isActive'] as bool? ?? false),
            createdAt: Value(createdAt),
          ));
          imported++;
        } catch (e) {
          debugPrint('[Sync] meal plan import error: $e');
        }
      }
      if (imported > 0) debugPrint('[Sync] meal plans imported: $imported');
    } catch (e) {
      debugPrint('[Sync] meal plans pull failed: $e');
    }
  }

  // ── Helpers ───────────────────────────────────────────────────────────────

  DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is String) {
      try { return DateTime.parse(value); } catch (_) { return null; }
    }
    return null;
  }
}
