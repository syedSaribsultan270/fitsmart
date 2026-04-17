import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../../data/database/app_database.dart';
import '../../data/database/database_provider.dart';
import '../auth_service.dart';
import '../firestore_service.dart';
import 'ai_tool.dart';

/// Quick summary-level workout log (no per-set detail). For when the user
/// tells the AI they just finished something — e.g. "did a 40-min jog".
/// For full per-set logging, the user should use the Workouts screen.
class LogQuickWorkoutTool extends AiTool {
  @override
  String get name => 'log_quick_workout';

  @override
  bool get isWrite => true;

  @override
  String get confirmTitle => 'Log workout';

  @override
  String get description =>
      'Log a completed workout at summary level (duration + rough calories). '
      'Call this when the user reports finishing a workout via chat. For '
      'lifting with per-set detail, tell the user to use the Workouts tab. '
      'Estimate calories from duration + workout type (light cardio ~5kcal/min, '
      'hard cardio ~10, strength ~6).';

  @override
  Map<String, dynamic> get parameterSchema => {
        'type': 'object',
        'properties': {
          'name': {'type': 'string', 'description': 'Short workout name.'},
          'duration_minutes': {
            'type': 'integer',
            'description': 'Duration in whole minutes.',
          },
          'total_sets': {
            'type': 'integer',
            'description': 'Total sets if strength-style; 0 for cardio.',
          },
          'estimated_calories': {
            'type': 'number',
            'description': 'Rough calories burned.',
          },
        },
        'required': ['name', 'duration_minutes', 'estimated_calories'],
      };

  @override
  String summarize(Map<String, dynamic> args) {
    final name = args['name'] ?? 'Workout';
    final mins = (args['duration_minutes'] as num?)?.toInt() ?? 0;
    final cal = (args['estimated_calories'] as num?)?.round() ?? 0;
    return '$name · ${mins}m · $cal kcal';
  }

  @override
  Future<AiToolResult> execute(ToolRef read, Map<String, dynamic> args) async {
    final mins = (args['duration_minutes'] as num?)?.toInt() ?? 0;
    final cal = (args['estimated_calories'] as num?)?.toDouble() ?? 0;
    final sets = (args['total_sets'] as num?)?.toInt() ?? 0;
    if (mins < 1 || mins > 600) {
      return AiToolResult.error(
        'duration_minutes must be 1-600 — you sent $mins',
      );
    }
    if (cal < 0 || cal > 3000) {
      return AiToolResult.error('estimated_calories must be 0-3000');
    }

    final completedAt = DateTime.now();
    final db = read(databaseProvider);
    final localId = await db.insertWorkout(WorkoutLogsCompanion(
      name: Value(args['name'] as String),
      durationSeconds: Value(mins * 60),
      totalSets: Value(sets),
      totalReps: const Value(0),
      estimatedCalories: Value(cal),
      exercisesJson: const Value('[]'),
      completedAt: Value(completedAt),
    ));

    final uid = AuthService.uid;
    if (uid != null) {
      FirestoreService.addWorkoutLog(uid, {
        'name': args['name'],
        'durationSeconds': mins * 60,
        'totalSets': sets,
        'totalReps': 0,
        'estimatedCalories': cal,
        'completedAt': completedAt.toIso8601String(),
        'sets': const <Map<String, dynamic>>[],
      }).then((cloudId) {
        if (cloudId.isNotEmpty) db.setWorkoutCloudId(localId, cloudId);
      }).catchError((Object e) {
        debugPrint('[AiTool:log_quick_workout] cloud sync failed: $e');
      });
    }

    return AiToolResult.ok(
      {
        'logged': true,
        'name': args['name'],
        'duration_minutes': mins,
        'estimated_calories': cal,
      },
      entityId: localId,
    );
  }
}
