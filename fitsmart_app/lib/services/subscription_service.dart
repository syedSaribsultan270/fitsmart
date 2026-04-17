import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';

/// Exception thrown when the user hits a free-tier feature limit.
/// Kept here (not in QuotaService) for backward-compat with existing UI handlers.
class FreeTierLimitException implements Exception {
  final String feature;
  const FreeTierLimitException(this.feature);
  @override
  String toString() => 'FreeTierLimitException: $feature';
}

/// Premium status, sourced from Firestore.
///
/// Premium is granted by setting `users/{uid}.premium = true` (admin-only — see
/// firestore.rules). The standard activation flow is:
///   1. User submits payment via the bank-transfer paywall.
///   2. Operator verifies the bank transfer landed.
///   3. Operator runs a Firebase Console / Admin SDK script to set
///      `users/{uid}.premium = true` (and optionally `premiumExpiresAt`).
///
/// Why no RevenueCat: the app uses manual bank transfers (see BankConfig).
/// IAP would force a 30% Play Store cut and require RevenueCat infra.
class SubscriptionService {
  SubscriptionService._();
  static final instance = SubscriptionService._();

  static final _db = FirebaseFirestore.instance;

  /// True if the current user has `premium == true` on their user doc.
  /// Returns false when unauthenticated or on read errors (fail closed for
  /// cap-checks, fail open is QuotaService's responsibility).
  Future<bool> get isPremium async {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return false;
    try {
      final snap = await _db.collection('users').doc(uid).get();
      if (!snap.exists) return false;
      final data = snap.data();
      if (data == null) return false;
      // Optional expiry — if set and past, treat as not premium.
      final expires = data['premiumExpiresAt'];
      if (expires is Timestamp && expires.toDate().isBefore(DateTime.now())) {
        return false;
      }
      return data['premium'] == true;
    } catch (e) {
      debugPrint('[Premium] read failed: $e');
      return false;
    }
  }

  /// Live updates of premium status. Emits on every user-doc change.
  Stream<bool> get premiumStream {
    final uid = FirebaseAuth.instance.currentUser?.uid;
    if (uid == null) return Stream.value(false);
    return _db.collection('users').doc(uid).snapshots().map((snap) {
      if (!snap.exists) return false;
      final data = snap.data();
      if (data == null) return false;
      final expires = data['premiumExpiresAt'];
      if (expires is Timestamp && expires.toDate().isBefore(DateTime.now())) {
        return false;
      }
      return data['premium'] == true;
    }).handleError((Object e) {
      debugPrint('[Premium] stream error: $e');
      return false;
    });
  }
}
