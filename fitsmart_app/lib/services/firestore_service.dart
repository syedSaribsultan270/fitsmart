import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';

/// Deterministic document ID — SHA1(uid|kind|key1|key2|...) → 24 hex chars.
/// Two writes of the same logical event collapse into the same Firestore doc,
/// so retries / duplicate triggers are idempotent. Replaces the brittle
/// timestamp-window dedup that SyncService used to do.
String _makeDocId(String uid, String kind, List<Object?> parts) {
  final raw = '$uid|$kind|${parts.map((p) => p?.toString() ?? '').join('|')}';
  return sha1.convert(utf8.encode(raw)).toString().substring(0, 24);
}

/// Central Firestore service.
/// Document layout:
///   users/{uid}/
///     profile       — onboarding answers (goals, diet, etc.)
///     gamification  — XP, streaks, badges
///     meal_logs/{id} — synced meal entries
///     workout_logs/{id} — synced workout entries
///     weight_logs/{id} — weigh-in history
///     ai_insights/{id} — cached daily insights
class FirestoreService {
  static final _db = FirebaseFirestore.instance;

  static DocumentReference _userDoc(String uid) =>
      _db.collection('users').doc(uid);

  // ── Profile ─────────────────────────────────────────────────────

  static Future<void> saveProfile(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _userDoc(uid).set(
      {'profile': data, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  static Future<Map<String, dynamic>?> getProfile(String uid) async {
    // Always try the local cache first (instant if fetched before).
    // On cold start the server call can hang or fail if offline.
    try {
      final cached = await _userDoc(uid)
          .get(const GetOptions(source: Source.cache));
      if (cached.exists) {
        final d = cached.data() as Map<String, dynamic>?;
        final profile = d?['profile'] as Map<String, dynamic>?;
        if (profile != null) return profile;
      }
    } catch (_) {
      // Cache miss — fall through to server.
    }

    // Server call with a timeout so it doesn't block app startup
    final snap = await _userDoc(uid)
        .get()
        .timeout(const Duration(seconds: 5));
    if (!snap.exists) return null;
    final d = snap.data() as Map<String, dynamic>?;
    return d?['profile'] as Map<String, dynamic>?;
  }

  // ── Gamification ────────────────────────────────────────────────

  static Future<void> saveGamification(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _userDoc(uid).set(
      {'gamification': data, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  // ── Meal Logs ───────────────────────────────────────────────────

  static CollectionReference _mealsCol(String uid) =>
      _userDoc(uid).collection('meal_logs');

  static Future<String> addMealLog(
    String uid,
    Map<String, dynamic> data,
  ) async {
    final docId = _makeDocId(uid, 'meal', [data['loggedAt'], data['name']]);
    await _mealsCol(uid).doc(docId).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return docId;
  }

  static Future<void> deleteMealLog(String uid, String docId) =>
      _mealsCol(uid).doc(docId).delete();

  static Stream<QuerySnapshot> watchTodaysMeals(String uid) {
    final start = DateTime.now();
    final dayStart = DateTime(start.year, start.month, start.day);
    final dayEnd = dayStart.add(const Duration(days: 1));
    return _mealsCol(uid)
        .where('loggedAt',
            isGreaterThanOrEqualTo: Timestamp.fromDate(dayStart))
        .where('loggedAt', isLessThan: Timestamp.fromDate(dayEnd))
        .orderBy('loggedAt')
        .snapshots();
  }

  // ── Workout Logs ────────────────────────────────────────────────

  static CollectionReference _workoutsCol(String uid) =>
      _userDoc(uid).collection('workout_logs');

  static Future<String> addWorkoutLog(
    String uid,
    Map<String, dynamic> data,
  ) async {
    final docId = _makeDocId(uid, 'workout', [data['completedAt'], data['name']]);
    await _workoutsCol(uid).doc(docId).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return docId;
  }

  static Future<void> deleteWorkoutLog(String uid, String docId) =>
      _workoutsCol(uid).doc(docId).delete();

  // ── Weight Logs ─────────────────────────────────────────────────

  static CollectionReference _weightCol(String uid) =>
      _userDoc(uid).collection('weight_logs');

  static Future<String> addWeightLog(
    String uid,
    Map<String, dynamic> data,
  ) async {
    final docId = _makeDocId(uid, 'weight', [data['loggedAt'], data['weightKg']]);
    await _weightCol(uid).doc(docId).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return docId;
  }

  static Future<void> deleteWeightLog(String uid, String docId) =>
      _weightCol(uid).doc(docId).delete();

  static Stream<QuerySnapshot> watchWeightHistory(String uid, {int limit = 30}) {
    return _weightCol(uid)
        .orderBy('loggedAt', descending: true)
        .limit(limit)
        .snapshots();
  }

  // ── Fetch collections for pull-and-merge ────────────────────────

  /// Returns meal log documents created (synced) within the last [since] period.
  static Future<QuerySnapshot> getMealLogs(String uid,
          {required DateTime since}) =>
      _mealsCol(uid)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(since))
          .orderBy('createdAt')
          .get();

  /// Returns workout log documents created (synced) since [since].
  static Future<QuerySnapshot> getWorkoutLogs(String uid,
          {required DateTime since}) =>
      _workoutsCol(uid)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(since))
          .orderBy('createdAt')
          .get();

  /// Returns weight log documents created (synced) since [since].
  static Future<QuerySnapshot> getWeightLogs(String uid,
          {required DateTime since}) =>
      _weightCol(uid)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(since))
          .orderBy('createdAt')
          .get();

  // ── App Settings ────────────────────────────────────────────────

  static Future<void> saveSettings(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _userDoc(uid).set(
      {'settings': data, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  static Future<Map<String, dynamic>?> getSettings(String uid) async {
    try {
      final cached = await _userDoc(uid)
          .get(const GetOptions(source: Source.cache));
      if (cached.exists) {
        final d = cached.data() as Map<String, dynamic>?;
        final settings = d?['settings'] as Map<String, dynamic>?;
        if (settings != null) return settings;
      }
    } catch (_) {}
    final snap = await _userDoc(uid)
        .get()
        .timeout(const Duration(seconds: 5));
    if (!snap.exists) return null;
    final d = snap.data() as Map<String, dynamic>?;
    return d?['settings'] as Map<String, dynamic>?;
  }

  // ── AI Coach Conversations ───────────────────────────────────────

  static CollectionReference _convsCol(String uid) =>
      _userDoc(uid).collection('ai_conversations');

  /// Upserts a single conversation document (keyed by conversation id).
  static Future<void> saveConversation(
    String uid,
    Map<String, dynamic> data,
  ) async {
    final id = data['id'] as String;
    await _convsCol(uid).doc(id).set(data);
  }

  static Future<void> deleteConversation(String uid, String convId) =>
      _convsCol(uid).doc(convId).delete();

  /// Returns all conversations ordered newest-first (max 30).
  ///
  /// Sorting is done client-side to avoid the Firestore composite index
  /// requirement for orderBy on subcollections. `updatedAt` is stored as
  /// an ISO8601 string, which is lexicographically sortable.
  static Future<List<Map<String, dynamic>>> getConversations(
      String uid) async {
    try {
      final snap = await _convsCol(uid)
          .limit(30)
          .get()
          .timeout(const Duration(seconds: 5));
      final docs = snap.docs
          .map((d) => d.data() as Map<String, dynamic>)
          .toList();
      docs.sort((a, b) {
        final aDate = a['updatedAt'] as String? ?? '';
        final bDate = b['updatedAt'] as String? ?? '';
        return bDate.compareTo(aDate); // descending
      });
      return docs;
    } catch (e) {
      debugPrint('[FirestoreService] getConversations failed: $e');
      return [];
    }
  }

  // ── Gamification (cloud backup) ─────────────────────────────────

  /// Fetch gamification state stored in the user document.
  static Future<Map<String, dynamic>?> getGamification(String uid) async {
    try {
      final snap = await _userDoc(uid)
          .get(const GetOptions(source: Source.server))
          .timeout(const Duration(seconds: 5));
      if (!snap.exists) return null;
      final d = snap.data() as Map<String, dynamic>?;
      return d?['gamification'] as Map<String, dynamic>?;
    } catch (_) {
      return null;
    }
  }

  // ── AI Insights ─────────────────────────────────────────────────

  static CollectionReference _insightsCol(String uid) =>
      _userDoc(uid).collection('ai_insights');

  static Future<void> saveInsight(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _insightsCol(uid).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
      'dismissed': false,
    });
  }

  static Future<void> dismissInsight(String uid, String docId) =>
      _insightsCol(uid).doc(docId).update({'dismissed': true});

  // ── Body Measurements ────────────────────────────────────────────────────

  static CollectionReference _measurementsCol(String uid) =>
      _userDoc(uid).collection('body_measurements');

  static Future<String> addBodyMeasurement(
    String uid,
    Map<String, dynamic> data,
  ) async {
    final docId = _makeDocId(uid, 'measurement', [data['measuredAt']]);
    await _measurementsCol(uid).doc(docId).set({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
    return docId;
  }

  static Future<void> deleteBodyMeasurement(String uid, String docId) =>
      _measurementsCol(uid).doc(docId).delete();

  /// Returns body measurement documents created since [since].
  static Future<QuerySnapshot> getBodyMeasurements(String uid,
          {required DateTime since}) =>
      _measurementsCol(uid)
          .where('createdAt',
              isGreaterThanOrEqualTo: Timestamp.fromDate(since))
          .orderBy('createdAt')
          .get();

  // ── Workout Plans ────────────────────────────────────────────────────────

  static CollectionReference _workoutPlansCol(String uid) =>
      _userDoc(uid).collection('workout_plans');

  /// Upsert a workout plan document keyed by [docId] (localId.toString()).
  static Future<void> saveWorkoutPlan(
    String uid,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _workoutPlansCol(uid).doc(docId).set(
      {...data, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  /// Returns all workout plan documents for the user.
  static Future<QuerySnapshot> getWorkoutPlans(String uid) =>
      _workoutPlansCol(uid).get();

  // ── Meal Plans ───────────────────────────────────────────────────────────

  static CollectionReference _mealPlansCol(String uid) =>
      _userDoc(uid).collection('meal_plans');

  /// Upsert a meal plan document keyed by [docId] (localId.toString()).
  static Future<void> saveMealPlan(
    String uid,
    String docId,
    Map<String, dynamic> data,
  ) async {
    await _mealPlansCol(uid).doc(docId).set(
      {...data, 'updatedAt': FieldValue.serverTimestamp()},
      SetOptions(merge: true),
    );
  }

  /// Returns all meal plan documents for the user.
  static Future<QuerySnapshot> getMealPlans(String uid) =>
      _mealPlansCol(uid).get();
}
