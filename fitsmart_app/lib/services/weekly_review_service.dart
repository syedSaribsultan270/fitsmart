import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../data/database/app_database.dart';

/// Aggregated stats for a single week, used by the Weekly Review screen.
class WeeklyReviewData {
  /// Inclusive start of the review week (Monday 00:00 local).
  final DateTime weekStart;
  /// Exclusive end (next Monday 00:00 local).
  final DateTime weekEnd;

  // Headline tiles
  final int workoutsCompleted;
  final int totalSets;
  final int totalXp;
  final int streakDays; // distinct days within week with any log
  final int waterMl;

  // Macro adherence
  final double avgCalories;
  final double avgProteinG;
  final double avgCarbsG;
  final double avgFatG;
  final int daysLogged; // days in week with at least one meal log

  // PR highlight (top e1RM gain vs prior week)
  final String? prExerciseName;
  final double? prDeltaKg;
  final double? prCurrentE1Rm;

  // Most consistent macro fallback (when no PR)
  final String? topMacroName;

  // Weight delta
  final double? weightStartKg;
  final double? weightEndKg;

  WeeklyReviewData({
    required this.weekStart,
    required this.weekEnd,
    required this.workoutsCompleted,
    required this.totalSets,
    required this.totalXp,
    required this.streakDays,
    required this.waterMl,
    required this.avgCalories,
    required this.avgProteinG,
    required this.avgCarbsG,
    required this.avgFatG,
    required this.daysLogged,
    this.prExerciseName,
    this.prDeltaKg,
    this.prCurrentE1Rm,
    this.topMacroName,
    this.weightStartKg,
    this.weightEndKg,
  });

  bool get hasPr => prExerciseName != null && (prDeltaKg ?? 0) > 0;
  double? get weightDeltaKg =>
      (weightStartKg != null && weightEndKg != null)
          ? weightEndKg! - weightStartKg!
          : null;
}

class WeeklyReviewService {
  WeeklyReviewService._();
  static final instance = WeeklyReviewService._();

  /// Returns the Monday 00:00 local of the week containing [date].
  DateTime weekStartFor(DateTime date) {
    final d = DateTime(date.year, date.month, date.day);
    // DateTime.weekday: monday=1, sunday=7
    return d.subtract(Duration(days: d.weekday - 1));
  }

  /// Build the review for the week ending most recently before now.
  /// (i.e. last completed Monday→Sunday block.)
  Future<WeeklyReviewData> buildLastWeek(AppDatabase db) {
    final thisWeekStart = weekStartFor(DateTime.now());
    final lastWeekStart = thisWeekStart.subtract(const Duration(days: 7));
    return buildForWeek(db, lastWeekStart);
  }

  /// Build the review for the in-progress current week (used by mid-week peeks).
  Future<WeeklyReviewData> buildCurrentWeek(AppDatabase db) {
    return buildForWeek(db, weekStartFor(DateTime.now()));
  }

  Future<WeeklyReviewData> buildForWeek(
    AppDatabase db,
    DateTime weekStart,
  ) async {
    final weekEnd = weekStart.add(const Duration(days: 7));

    // ── Aggregate from daily_summaries (already-computed) ──
    final summaries = await db.getRecentSummaries(days: 21);
    final weekSummaries = summaries.where((s) =>
        !s.date.isBefore(weekStart) && s.date.isBefore(weekEnd)).toList();

    int workouts = 0;
    int xp = 0;
    int water = 0;
    int streakDays = 0;
    final caloriesPerDay = <double>[];
    final proteinPerDay = <double>[];
    final carbsPerDay = <double>[];
    final fatPerDay = <double>[];
    int daysLogged = 0;

    for (final s in weekSummaries) {
      workouts += s.workoutsCompleted;
      xp += s.xpEarned;
      water += s.waterMl;
      if (s.streakDay) streakDays++;
      if (s.totalCalories > 0) {
        caloriesPerDay.add(s.totalCalories);
        proteinPerDay.add(s.totalProteinG);
        carbsPerDay.add(s.totalCarbsG);
        fatPerDay.add(s.totalFatG);
        daysLogged++;
      }
    }

    double avg(List<double> xs) =>
        xs.isEmpty ? 0 : xs.reduce((a, b) => a + b) / xs.length;

    // ── Per-set details for total sets + PR detection ──
    int totalSets = 0;
    String? prName;
    double? prDelta;
    double? prCurrent;
    try {
      final allWorkouts = await db.getRecentWorkouts(limit: 50);
      final weekWorkouts = allWorkouts.where((w) =>
          !w.completedAt.isBefore(weekStart) &&
          w.completedAt.isBefore(weekEnd)).toList();
      final priorWorkouts = allWorkouts.where((w) =>
          w.completedAt.isBefore(weekStart)).toList();

      // Sum sets from this week's workouts.
      final thisWeekSets = <WorkoutSet>[];
      for (final w in weekWorkouts) {
        thisWeekSets.addAll(await db.getSetsForWorkout(w.id));
      }
      totalSets = thisWeekSets.length;

      // PR detection: best e1RM per exercise this week vs prior best.
      final bestThisWeek = <String, double>{};
      for (final s in thisWeekSets) {
        if (s.isWarmup) continue;
        final e = s.estimated1Rm;
        if (e == null) continue;
        if ((bestThisWeek[s.exerciseName] ?? 0) < e) {
          bestThisWeek[s.exerciseName] = e;
        }
      }

      final priorSetsByExercise = <String, double>{};
      for (final w in priorWorkouts) {
        final sets = await db.getSetsForWorkout(w.id);
        for (final s in sets) {
          if (s.isWarmup) continue;
          final e = s.estimated1Rm;
          if (e == null) continue;
          if ((priorSetsByExercise[s.exerciseName] ?? 0) < e) {
            priorSetsByExercise[s.exerciseName] = e;
          }
        }
      }

      double biggestDelta = 0;
      bestThisWeek.forEach((name, current) {
        final prior = priorSetsByExercise[name] ?? 0;
        final delta = current - prior;
        if (delta > biggestDelta) {
          biggestDelta = delta;
          prName = name;
          prDelta = delta;
          prCurrent = current;
        }
      });
    } catch (e) {
      debugPrint('[WeeklyReview] sets aggregation failed: $e');
    }

    // ── Top macro (when no PR) — highest avg adherence. Simple heuristic:
    //    pick the macro with the highest gram total relative to a 100g floor.
    String? topMacro;
    if (prName == null) {
      final p = avg(proteinPerDay);
      final c = avg(carbsPerDay);
      final f = avg(fatPerDay);
      if (p >= c && p >= f && p > 50) {
        topMacro = 'Protein';
      } else if (c >= f && c > 100) {
        topMacro = 'Carbs';
      } else if (f > 30) {
        topMacro = 'Fat';
      }
    }

    // ── Weight delta across the week ──
    double? weightStart;
    double? weightEnd;
    try {
      final hist = await db.getWeightHistory(limit: 60);
      final inWeek = hist
          .where((w) =>
              !w.loggedAt.isBefore(weekStart) && w.loggedAt.isBefore(weekEnd))
          .toList()
        ..sort((a, b) => a.loggedAt.compareTo(b.loggedAt));
      if (inWeek.isNotEmpty) {
        weightStart = inWeek.first.weightKg;
        weightEnd = inWeek.last.weightKg;
      }
    } catch (e) {
      debugPrint('[WeeklyReview] weight delta failed: $e');
    }

    return WeeklyReviewData(
      weekStart: weekStart,
      weekEnd: weekEnd,
      workoutsCompleted: workouts,
      totalSets: totalSets,
      totalXp: xp,
      streakDays: streakDays,
      waterMl: water,
      avgCalories: avg(caloriesPerDay),
      avgProteinG: avg(proteinPerDay),
      avgCarbsG: avg(carbsPerDay),
      avgFatG: avg(fatPerDay),
      daysLogged: daysLogged,
      prExerciseName: prName,
      prDeltaKg: prDelta,
      prCurrentE1Rm: prCurrent,
      topMacroName: topMacro,
      weightStartKg: weightStart,
      weightEndKg: weightEnd,
    );
  }

  // ── Commitment persistence ──────────────────────────────────────
  // Key = `weekly_commit_{YYYY-MM-DD}` of the week start (Monday).

  String _weekId(DateTime weekStart) {
    final m = weekStart.month.toString().padLeft(2, '0');
    final d = weekStart.day.toString().padLeft(2, '0');
    return '${weekStart.year}-$m-$d';
  }

  /// Save the user's commitment for the upcoming week. Mirrors to Firestore.
  Future<void> saveCommitment({
    required DateTime forWeekStart,
    required String commitment,
  }) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return;
    try {
      final id = _weekId(forWeekStart);
      await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('weekly_commitments')
          .doc(id)
          .set({
        'commitment': commitment,
        'weekStart': Timestamp.fromDate(forWeekStart),
        'createdAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      debugPrint('[WeeklyReview] saveCommitment failed: $e');
    }
  }

  /// Read the commitment the user pledged for [forWeekStart] (week start
  /// = Monday). Returns null if none was set or on read error.
  /// Used by the Weekly Review screen to close the loop on last week's pledge.
  Future<String?> getCommitmentFor(DateTime forWeekStart) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return null;
    try {
      final id = _weekId(forWeekStart);
      final snap = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('weekly_commitments')
          .doc(id)
          .get();
      if (!snap.exists) return null;
      return snap.data()?['commitment'] as String?;
    } catch (e) {
      debugPrint('[WeeklyReview] getCommitmentFor failed: $e');
      return null;
    }
  }

  /// Suggested commitments based on this week's gaps. Static set with
  /// data-driven prioritization (no AI call needed — keeps this offline-ok).
  List<String> suggestedCommitments(WeeklyReviewData data) {
    final out = <String>[];
    if (data.workoutsCompleted < 3) {
      out.add('Train 3 times next week');
    }
    if (data.daysLogged < 5) {
      out.add('Log meals 6 days next week');
    }
    if (data.avgProteinG < 100) {
      out.add('Hit 130g protein every day');
    }
    if (data.streakDays < 5) {
      out.add('Keep a 7-day streak alive');
    }
    if (data.waterMl < 14000) {
      out.add('Drink 2.5L of water daily');
    }
    if (out.length < 3) {
      out.addAll([
        'Add one new exercise PR attempt',
        'Sleep 7+ hours every night',
        'Walk 8k steps daily',
      ]);
    }
    return out.take(3).toList();
  }
}
