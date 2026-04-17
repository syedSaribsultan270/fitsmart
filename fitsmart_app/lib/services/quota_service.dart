import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../core/constants/app_constants.dart';
import 'subscription_service.dart';

/// Server-enforced free-tier rate limits.
///
/// Counters live at `users/{uid}/quotas/{YYYY-MM-DD}` (UTC date) and are
/// incremented inside a Firestore transaction. Firestore rules cap each
/// counter at the free-tier limit; premium users bypass via SubscriptionService.
///
/// Why server-enforced: the previous SharedPreferences counters could be
/// reset by clearing app data, leaking unlimited free AI/photo usage.
class QuotaService {
  QuotaService._();
  static final instance = QuotaService._();

  static final _db = FirebaseFirestore.instance;

  static const _kAiMessages = 'aiMessages';
  static const _kPhotoAnalyses = 'photoAnalyses';

  /// Today's quota doc ID — UTC date so it's stable across timezone shifts.
  String _todayId() {
    final n = DateTime.now().toUtc();
    final m = n.month.toString().padLeft(2, '0');
    final d = n.day.toString().padLeft(2, '0');
    return '${n.year}-$m-$d';
  }

  DocumentReference<Map<String, dynamic>> _quotaDoc(String uid) =>
      _db.collection('users').doc(uid).collection('quotas').doc(_todayId());

  /// Increment one counter. Throws [FreeTierQuotaException] if cap hit.
  /// Premium users bypass entirely. Fails open if offline / unauthenticated.
  Future<void> consume(String counter) async {
    try {
      final isPremium = await SubscriptionService.instance.isPremium;
      if (isPremium) return;

      final user = FirebaseAuth.instance.currentUser;
      if (user == null) return; // unauthenticated — fall back to local cap (none)

      final cap = _capFor(counter);
      final ref = _quotaDoc(user.uid);

      await _db.runTransaction((tx) async {
        final snap = await tx.get(ref);
        final current = snap.exists
            ? ((snap.data()?[counter] as num?)?.toInt() ?? 0)
            : 0;
        if (current >= cap) {
          throw FreeTierQuotaException(counter, current, cap);
        }
        if (snap.exists) {
          tx.update(ref, {
            counter: FieldValue.increment(1),
            'updatedAt': FieldValue.serverTimestamp(),
          });
        } else {
          tx.set(ref, {
            _kAiMessages: counter == _kAiMessages ? 1 : 0,
            _kPhotoAnalyses: counter == _kPhotoAnalyses ? 1 : 0,
            'updatedAt': FieldValue.serverTimestamp(),
          });
        }
      });
    } on FreeTierQuotaException {
      rethrow;
    } catch (e, st) {
      // Network / permission error → fail open so legitimate users aren't
      // blocked. Unwrap Firebase errors so the actual reason is visible in
      // logs instead of the useless "Dart exception thrown from converted
      // Future" wrapper you see on web.
      if (e is FirebaseException) {
        debugPrint('[QuotaService] consume($counter) FirebaseException '
            'code=${e.code} plugin=${e.plugin} '
            'message=${e.message ?? "(no message)"}');
        if (e.code == 'permission-denied') {
          debugPrint('[QuotaService] ⚠️  Rules likely not deployed. Run: '
              'firebase deploy --only firestore:rules');
        }
      } else {
        debugPrint('[QuotaService] consume($counter) non-Firebase error: '
            '$e\n$st');
      }
    }
  }

  /// Read current counter usage without incrementing. Returns (used, cap).
  /// Used by paywall UI to show "X of Y used today".
  Future<({int used, int cap})> usage(String counter) async {
    final cap = _capFor(counter);
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) return (used: 0, cap: cap);
    try {
      final snap = await _quotaDoc(user.uid).get(
        const GetOptions(source: Source.serverAndCache),
      );
      final used = snap.exists
          ? ((snap.data()?[counter] as num?)?.toInt() ?? 0)
          : 0;
      return (used: used, cap: cap);
    } catch (_) {
      return (used: 0, cap: cap);
    }
  }

  int _capFor(String counter) => switch (counter) {
        _kAiMessages => AppConstants.freeTierDailyAiMessages,
        _kPhotoAnalyses => AppConstants.freeTierDailyPhotoAnalyses,
        _ => 9999,
      };

  // Convenience aliases for call sites.
  Future<void> consumeAiMessage() => consume(_kAiMessages);
  Future<void> consumePhotoAnalysis() => consume(_kPhotoAnalyses);
  Future<({int used, int cap})> aiMessagesUsage() => usage(_kAiMessages);
  Future<({int used, int cap})> photoAnalysesUsage() => usage(_kPhotoAnalyses);
}

/// Thrown when the daily free-tier quota for [counter] is exhausted.
/// Caller should surface the paywall.
class FreeTierQuotaException implements Exception {
  final String counter;
  final int used;
  final int cap;
  const FreeTierQuotaException(this.counter, this.used, this.cap);

  @override
  String toString() =>
      'FreeTierQuotaException($counter: $used/$cap used today)';
}
