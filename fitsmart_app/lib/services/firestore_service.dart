import 'package:cloud_firestore/cloud_firestore.dart';

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
    final snap = await _userDoc(uid).get();
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
    final ref = await _mealsCol(uid).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
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
    final ref = await _workoutsCol(uid).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return ref.id;
  }

  // ── Weight Logs ─────────────────────────────────────────────────

  static CollectionReference _weightCol(String uid) =>
      _userDoc(uid).collection('weight_logs');

  static Future<void> addWeightLog(
    String uid,
    Map<String, dynamic> data,
  ) async {
    await _weightCol(uid).add({
      ...data,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  static Stream<QuerySnapshot> watchWeightHistory(String uid, {int limit = 30}) {
    return _weightCol(uid)
        .orderBy('loggedAt', descending: true)
        .limit(limit)
        .snapshots();
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
}
