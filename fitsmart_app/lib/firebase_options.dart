// Firebase configuration for FitSmart AI — project: fitsmart-9c7da
//
// ⚠️ SECURITY NOTE:
// These Firebase API keys are CLIENT-SIDE identifiers (like a project ID).
// They are NOT secret credentials. Firebase security is enforced by:
//   1. Firebase Security Rules (firestore.rules)
//   2. Firebase App Check (enable in Firebase Console before Play Store launch)
//   3. Google Cloud API key restrictions (restrict by app bundle ID / SHA-1)
// See: https://firebase.google.com/docs/projects/api-keys

import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) return web;
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for this platform.',
        );
    }
  }

  // ── Web ────────────────────────────────────────────────────────────
  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyBs8CEmll1l7nDLi-YJWiZ1aQL5HJ329DM',
    appId: '1:877602557773:web:8bb6fc0071c5c3d322f104',
    messagingSenderId: '877602557773',
    projectId: 'fitsmart-9c7da',
    authDomain: 'fitsmart-9c7da.firebaseapp.com',
    storageBucket: 'fitsmart-9c7da.firebasestorage.app',
    measurementId: 'G-V11NFXPHW2',
  );

  // ── Android ────────────────────────────────────────────────────────
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAGDonSp6IpdpGsxqBN_fCjJrqlOt59Pp8',
    appId: '1:877602557773:android:eb5fda1bde8939c222f104',
    messagingSenderId: '877602557773',
    projectId: 'fitsmart-9c7da',
    storageBucket: 'fitsmart-9c7da.firebasestorage.app',
  );

  // ── iOS ────────────────────────────────────────────────────────────
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBDHKElbjEb-X2l_bOX6z4KsxR53T5FBu0',
    appId: '1:877602557773:ios:1fcc40dc85454b5a22f104',
    messagingSenderId: '877602557773',
    projectId: 'fitsmart-9c7da',
    storageBucket: 'fitsmart-9c7da.firebasestorage.app',
    iosClientId: '877602557773-3bbrrhuv5iccll983poojobfbkhekrrs.apps.googleusercontent.com',
    iosBundleId: 'com.fitsmart.fitsmartApp',
  );
}
