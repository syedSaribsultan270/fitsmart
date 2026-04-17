import 'dart:convert';

import 'package:drift/drift.dart' show Value;
import 'package:flutter/foundation.dart';

import '../../data/database/app_database.dart';
import '../../data/database/database_provider.dart';
import '../auth_service.dart';
import '../firestore_service.dart';
import 'ai_tool.dart';

/// Logs a meal — macros + cal — to Drift + Firestore.
/// Mirrors `log_meal_screen._saveMeal` except it's invoked by the AI
/// on behalf of the user after confirmation.
class LogMealTool extends AiTool {
  @override
  String get name => 'log_meal';

  @override
  bool get isWrite => true;

  @override
  String get confirmTitle => 'Log meal';

  @override
  String get description =>
      'Log a meal the user just ate, with macros. Call this when the user '
      'mentions eating something and provides enough info to estimate '
      'calories + macros. Never call this just because the user asked a '
      'question about food. Always include reasonable macro estimates.';

  @override
  Map<String, dynamic> get parameterSchema => {
        'type': 'object',
        'properties': {
          'name': {
            'type': 'string',
            'description':
                'Short title for the meal, e.g. "Aloo Gobi" or "Chicken Caesar Salad".',
          },
          'meal_type': {
            'type': 'string',
            'enum': ['Breakfast', 'Lunch', 'Dinner', 'Snack',
              'Pre-Workout', 'Post-Workout'],
            'description':
                'The meal slot. Infer from time of day if the user did not say.',
          },
          'calories':   {'type': 'number', 'description': 'Total kcal.'},
          'protein_g':  {'type': 'number', 'description': 'Grams of protein.'},
          'carbs_g':    {'type': 'number', 'description': 'Grams of carbohydrates.'},
          'fat_g':      {'type': 'number', 'description': 'Grams of fat.'},
          'fiber_g':    {'type': 'number', 'description': 'Grams of fiber. Optional.'},
        },
        'required': ['name', 'meal_type', 'calories', 'protein_g', 'carbs_g', 'fat_g'],
      };

  @override
  String summarize(Map<String, dynamic> args) {
    final name = args['name'] ?? 'Meal';
    final cal = (args['calories'] as num?)?.round() ?? 0;
    final p = (args['protein_g'] as num?)?.round() ?? 0;
    final c = (args['carbs_g'] as num?)?.round() ?? 0;
    final f = (args['fat_g'] as num?)?.round() ?? 0;
    return '$name · $cal kcal · ${p}p / ${c}c / ${f}f';
  }

  @override
  Future<AiToolResult> execute(ToolRef read, Map<String, dynamic> args) async {
    // Validate — sanity bounds. If the model hallucinates 9000 kcal for a
    // snack, reject so it can retry with a sane value.
    final cal = (args['calories'] as num?)?.toDouble() ?? 0;
    if (cal < 1 || cal > 5000) {
      return AiToolResult.error(
        'calories must be between 1 and 5000 — you sent $cal',
      );
    }
    final p = (args['protein_g'] as num?)?.toDouble() ?? 0;
    final c = (args['carbs_g'] as num?)?.toDouble() ?? 0;
    final fat = (args['fat_g'] as num?)?.toDouble() ?? 0;
    if ([p, c, fat].any((v) => v < 0 || v > 1000)) {
      return AiToolResult.error('macros must be between 0g and 1000g');
    }

    final db = read(databaseProvider);
    final loggedAt = DateTime.now();
    final name = args['name'] as String;
    final mealType = args['meal_type'] as String? ?? 'Snack';

    final localId = await db.insertMeal(MealLogsCompanion(
      name: Value(name),
      mealType: Value(mealType),
      calories: Value(cal),
      proteinG: Value(p),
      carbsG: Value(c),
      fatG: Value(fat),
      fiberG: Value((args['fiber_g'] as num?)?.toDouble() ?? 0),
      itemsJson: Value(jsonEncode([
        {'name': name, 'calories': cal, 'protein_g': p, 'carbs_g': c, 'fat_g': fat}
      ])),
      aiFeedback: const Value('Logged via AI Coach'),
      loggedAt: Value(loggedAt),
    ));

    // Firestore sync with cloud-id write-back.
    final uid = AuthService.uid;
    if (uid != null) {
      FirestoreService.addMealLog(uid, {
        'name': name,
        'mealType': mealType,
        'calories': cal,
        'proteinG': p,
        'carbsG': c,
        'fatG': fat,
        'fiberG': (args['fiber_g'] as num?)?.toDouble() ?? 0,
        'aiFeedback': 'Logged via AI Coach',
        'loggedAt': loggedAt.toIso8601String(),
      }).then((cloudId) {
        if (cloudId.isNotEmpty) db.setMealCloudId(localId, cloudId);
      }).catchError((Object e) {
        debugPrint('[AiTool:log_meal] cloud sync failed: $e');
      });
    }

    return AiToolResult.ok(
      {
        'logged': true,
        'name': name,
        'calories': cal,
        'protein_g': p,
        'carbs_g': c,
        'fat_g': fat,
      },
      entityId: localId,
    );
  }
}
