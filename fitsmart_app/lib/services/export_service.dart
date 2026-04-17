import 'dart:convert';
import 'package:archive/archive.dart';
import 'package:drift/drift.dart' show OrderingTerm;
import 'package:flutter/foundation.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import '../data/database/app_database.dart';
import 'analytics_service.dart';

/// GDPR-compliant data export.
/// Produces a ZIP archive containing CSV files for all local data tables.
class ExportService {
  ExportService._();
  static final instance = ExportService._();

  /// Build a ZIP archive from all local Drift tables and return the file path.
  Future<String?> exportAll(AppDatabase db) async {
    AnalyticsService.instance.track('data_export_requested');
    try {
      final archive = Archive();
      int recordCount = 0;

      // ── profile.json ─────────────────────────────────────────
      // (no Drift table — user profile lives in SharedPreferences)
      archive.addFile(ArchiveFile(
        'profile.json',
        0,
        Uint8List.fromList(utf8.encode(
          const JsonEncoder.withIndent('  ').convert(
            {'note': 'Profile data is stored in device preferences (SharedPreferences).'},
          ),
        )),
      ));

      // ── meal_logs.csv ─────────────────────────────────────────
      final meals = await _getAllMeals(db);
      final mealsCsv = _buildCsv(
        headers: ['id', 'name', 'meal_type', 'calories', 'protein_g', 'carbs_g',
                   'fat_g', 'fiber_g', 'health_score', 'ai_feedback', 'logged_at'],
        rows: meals.map((m) => [
          m.id, m.name, m.mealType, m.calories, m.proteinG, m.carbsG,
          m.fatG, m.fiberG, m.healthScore,
          m.aiFeedback.replaceAll(',', ';').replaceAll('\n', ' '),
          m.loggedAt.toIso8601String(),
        ]).toList(),
      );
      archive.addFile(ArchiveFile(
        'meal_logs.csv',
        mealsCsv.length,
        Uint8List.fromList(utf8.encode(mealsCsv)),
      ));
      recordCount += meals.length;

      // ── workout_logs.csv ──────────────────────────────────────
      final workouts = await _getAllWorkouts(db);
      final workoutsCsv = _buildCsv(
        headers: ['id', 'name', 'duration_seconds', 'total_sets', 'total_reps',
                   'estimated_calories', 'completed_at'],
        rows: workouts.map((w) => [
          w.id, w.name.replaceAll(',', ';'), w.durationSeconds,
          w.totalSets, w.totalReps, w.estimatedCalories,
          w.completedAt.toIso8601String(),
        ]).toList(),
      );
      archive.addFile(ArchiveFile(
        'workout_logs.csv',
        workoutsCsv.length,
        Uint8List.fromList(utf8.encode(workoutsCsv)),
      ));
      recordCount += workouts.length;

      // ── workout_sets.csv ──────────────────────────────────────
      final sets = await _getAllSets(db);
      final setsCsv = _buildCsv(
        headers: ['id', 'workout_log_id', 'exercise_name', 'muscle_group',
                   'set_number', 'weight_kg', 'reps', 'rpe', 'is_warmup',
                   'is_pr', 'completed_at'],
        rows: sets.map((s) => [
          s.id, s.workoutLogId, s.exerciseName.replaceAll(',', ';'),
          s.muscleGroup, s.setNumber, s.weightKg, s.reps,
          s.rpe ?? '', s.isWarmup, s.isPr,
          s.completedAt.toIso8601String(),
        ]).toList(),
      );
      archive.addFile(ArchiveFile(
        'workout_sets.csv',
        setsCsv.length,
        Uint8List.fromList(utf8.encode(setsCsv)),
      ));
      recordCount += sets.length;

      // ── weight_logs.csv ───────────────────────────────────────
      final weights = await db.getWeightHistory(limit: 10000);
      final weightsCsv = _buildCsv(
        headers: ['id', 'weight_kg', 'note', 'logged_at'],
        rows: weights.map((w) => [
          w.id, w.weightKg,
          w.note.replaceAll(',', ';'), w.loggedAt.toIso8601String(),
        ]).toList(),
      );
      archive.addFile(ArchiveFile(
        'weight_logs.csv',
        weightsCsv.length,
        Uint8List.fromList(utf8.encode(weightsCsv)),
      ));
      recordCount += weights.length;

      // ── body_measurements.csv ─────────────────────────────────
      final measurements = await db.getMeasurementHistory(limit: 10000);
      final measureCsv = _buildCsv(
        headers: ['id', 'chest_cm', 'waist_cm', 'hips_cm', 'bicep_cm',
                   'thigh_cm', 'neck_cm', 'shoulders_cm', 'calf_cm', 'measured_at'],
        rows: measurements.map((m) => [
          m.id, m.chestCm ?? '', m.waistCm ?? '', m.hipsCm ?? '',
          m.bicepCm ?? '', m.thighCm ?? '', m.neckCm ?? '',
          m.shouldersCm ?? '', m.calfCm ?? '', m.measuredAt.toIso8601String(),
        ]).toList(),
      );
      archive.addFile(ArchiveFile(
        'body_measurements.csv',
        measureCsv.length,
        Uint8List.fromList(utf8.encode(measureCsv)),
      ));
      recordCount += measurements.length;

      // ── daily_summaries.csv ───────────────────────────────────
      final summaries = await db.getRecentSummaries(days: 3650);
      final summariesCsv = _buildCsv(
        headers: ['id', 'date', 'total_calories', 'total_protein_g',
                   'total_carbs_g', 'total_fat_g', 'workouts_completed',
                   'xp_earned', 'streak_day', 'water_ml'],
        rows: summaries.map((s) => [
          s.id, s.date.toIso8601String().substring(0, 10),
          s.totalCalories, s.totalProteinG, s.totalCarbsG, s.totalFatG,
          s.workoutsCompleted, s.xpEarned, s.streakDay, s.waterMl,
        ]).toList(),
      );
      archive.addFile(ArchiveFile(
        'daily_summaries.csv',
        summariesCsv.length,
        Uint8List.fromList(utf8.encode(summariesCsv)),
      ));
      recordCount += summaries.length;

      // ── Write ZIP to temp dir ─────────────────────────────────
      final zipBytes = ZipEncoder().encode(archive);

      final dir = await getTemporaryDirectory();
      final dateStr = DateTime.now().toIso8601String().substring(0, 10);
      final file = File('${dir.path}/fitsmart_export_$dateStr.zip');
      await file.writeAsBytes(zipBytes);

      AnalyticsService.instance.track('data_export_completed',
          props: {'record_count': recordCount});

      return file.path;
    } catch (e) {
      debugPrint('[Export] failed: $e');
      return null;
    }
  }

  // ── Helpers ────────────────────────────────────────────────────

  Future<List<MealLog>> _getAllMeals(AppDatabase db) async {
    return (db.select(db.mealLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.loggedAt)]))
        .get();
  }

  Future<List<WorkoutLog>> _getAllWorkouts(AppDatabase db) async {
    return (db.select(db.workoutLogs)
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .get();
  }

  Future<List<WorkoutSet>> _getAllSets(AppDatabase db) async {
    return (db.select(db.workoutSets)
          ..orderBy([(t) => OrderingTerm.desc(t.completedAt)]))
        .get();
  }

  String _buildCsv({
    required List<String> headers,
    required List<List<dynamic>> rows,
  }) {
    final buf = StringBuffer();
    buf.writeln(headers.join(','));
    for (final row in rows) {
      buf.writeln(row.map((v) => _escapeCsv(v)).join(','));
    }
    return buf.toString();
  }

  String _escapeCsv(dynamic value) {
    if (value == null) return '';
    final s = value.toString();
    if (s.contains(',') || s.contains('"') || s.contains('\n')) {
      return '"${s.replaceAll('"', '""')}"';
    }
    return s;
  }
}
