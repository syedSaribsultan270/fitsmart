// Generated/configured for FitSmart AI
// Web config from Firebase console: fitsmart-9c7da
// Android/iOS configs pending (add google-services.json + GoogleService-Info.plist)
//
// ⚠️ SECURITY NOTE:
// These Firebase API keys are CLIENT-SIDE identifiers (like a project ID).
// They are NOT secret credentials. Firebase security is enforced by:
//   1. Firebase Security Rules (firestore.rules)
//   2. Firebase App Check (enable in Firebase Console)
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
      case TargetPlatform.macOS:
        return macos;
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
  // Download google-services.json from Firebase console → android/app/
  // then run: flutterfire configure --platforms=android
  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyBs8CEmll1l7nDLi-YJWiZ1aQL5HJ329DM',
    appId: '1:877602557773:android:PLACEHOLDER',
    messagingSenderId: '877602557773',
    projectId: 'fitsmart-9c7da',
    storageBucket: 'fitsmart-9c7da.firebasestorage.app',
  );

  // ── iOS ────────────────────────────────────────────────────────────
  // Download GoogleService-Info.plist from Firebase console → ios/Runner/
  // then run: flutterfire configure --platforms=ios
  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyBs8CEmll1l7nDLi-YJWiZ1aQL5HJ329DM',
    appId: '1:877602557773:ios:PLACEHOLDER',
    messagingSenderId: '877602557773',
    projectId: 'fitsmart-9c7da',
    storageBucket: 'fitsmart-9c7da.firebasestorage.app',
    iosBundleId: 'com.fitsmart.fitsmartApp',
  );

  // ── macOS ──────────────────────────────────────────────────────────
  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyBs8CEmll1l7nDLi-YJWiZ1aQL5HJ329DM',
    appId: '1:877602557773:ios:PLACEHOLDER',
    messagingSenderId: '877602557773',
    projectId: 'fitsmart-9c7da',
    storageBucket: 'fitsmart-9c7da.firebasestorage.app',
    iosBundleId: 'com.fitsmart.fitsmartApp',
  );
}
