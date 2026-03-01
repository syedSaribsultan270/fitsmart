import 'dart:convert';

import 'package:drift/drift.dart';
import 'package:flutter/services.dart' show rootBundle;

import '../data/database/app_database.dart';

/// Seeds the exercise library from bundled JSON on first launch.
class DatabaseSeeder {
  final AppDatabase _db;

  DatabaseSeeder(this._db);

  /// Seed exercises only if the table is empty.
  Future<void> seedIfNeeded() async {
    final count = await _db.getExerciseCount();
    if (count > 0) return; // already seeded
    await _seedExercises();
  }

  Future<void> _seedExercises() async {
    final json = await rootBundle.loadString('assets/data/exercises.json');
    final List<dynamic> items = jsonDecode(json) as List;

    final companions = items.map((e) {
      final m = e as Map<String, dynamic>;
      return ExercisesCompanion(
        name: Value(m['name'] as String),
        muscleGroup: Value(m['muscleGroup'] as String),
        equipment: Value(m['equipment'] as String? ?? 'bodyweight'),
        instructions: Value(m['instructions'] as String? ?? ''),
        category: Value(m['category'] as String? ?? 'strength'),
        isCustom: const Value(false),
      );
    }).toList();

    await _db.insertExercises(companions);
  }
}
