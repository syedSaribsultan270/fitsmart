import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:google_sign_in/google_sign_in.dart';

/// Handles Firebase Authentication.
/// Supports anonymous, email/password, Google sign-in, and account linking.
/// On web, uses Firebase Auth popup flow. On mobile, uses google_sign_in package.
class AuthService {
  static final _auth = FirebaseAuth.instance;
  static final _googleSignIn = GoogleSignIn();

  static User? get currentUser => _auth.currentUser;
  static String? get uid => _auth.currentUser?.uid;
  static Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// Sign in anonymously if not already signed in.
  static Future<User?> signInAnonymously() async {
    if (_auth.currentUser != null) return _auth.currentUser;
    final cred = await _auth.signInAnonymously();
    return cred.user;
  }

  /// Sign in with email and password.
  static Future<User?> signInWithEmail(String email, String password) async {
    final cred = await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /// Create a new account with email and password.
  static Future<User?> signUpWithEmail(String email, String password) async {
    final cred = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    return cred.user;
  }

  /// Sign in with Google.
  /// On web: uses Firebase signInWithPopup (no extra config needed).
  /// On mobile: uses google_sign_in package.
  static Future<User?> signInWithGoogle() async {
    if (kIsWeb) {
      return _signInWithGoogleWeb();
    }
    return _signInWithGoogleMobile();
  }

  /// Web: Firebase handles the entire OAuth popup flow.
  static Future<User?> _signInWithGoogleWeb() async {
    final provider = GoogleAuthProvider();
    provider.addScope('email');
    provider.addScope('profile');

    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.isAnonymous) {
      try {
        final result = await currentUser.linkWithPopup(provider);
        return result.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use') {
          final result = await _auth.signInWithPopup(provider);
          return result.user;
        }
        rethrow;
      }
    }

    final result = await _auth.signInWithPopup(provider);
    return result.user;
  }

  /// Mobile: Uses google_sign_in package for native flow.
  static Future<User?> _signInWithGoogleMobile() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) return null; // User cancelled

    final googleAuth = await googleUser.authentication;
    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    final currentUser = _auth.currentUser;
    if (currentUser != null && currentUser.isAnonymous) {
      try {
        final result = await currentUser.linkWithCredential(credential);
        return result.user;
      } on FirebaseAuthException catch (e) {
        if (e.code == 'credential-already-in-use') {
          final result = await _auth.signInWithCredential(credential);
          return result.user;
        }
        rethrow;
      }
    }

    final result = await _auth.signInWithCredential(credential);
    return result.user;
  }

  /// Link an anonymous account to email/password (preserves UID & data).
  static Future<User?> linkWithEmail(String email, String password) async {
    final user = _auth.currentUser;
    if (user == null) return null;
    final credential = EmailAuthProvider.credential(
      email: email,
      password: password,
    );
    final result = await user.linkWithCredential(credential);
    return result.user;
  }

  /// Send a password reset email.
  static Future<void> sendPasswordReset(String email) async {
    await _auth.sendPasswordResetEmail(email: email);
  }

  /// Update the user's display name.
  static Future<void> updateDisplayName(String name) async {
    await _auth.currentUser?.updateDisplayName(name);
  }

  /// Sign out (clears local auth state and Google session).
  static Future<void> signOut() async {
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await _auth.signOut();
  }

  /// Delete the current user's account permanently.
  static Future<void> deleteAccount() async {
    final user = _auth.currentUser;
    if (user == null) return;
    if (!kIsWeb) {
      await _googleSignIn.signOut();
    }
    await user.delete();
  }

  /// Whether the current user is anonymous (not linked to email/Google).
  static bool get isAnonymous => _auth.currentUser?.isAnonymous ?? true;

  /// The user's email, if linked.
  static String? get email => _auth.currentUser?.email;

  /// The user's display name.
  static String? get displayName => _auth.currentUser?.displayName;

  /// The user's photo URL (from Google or other provider).
  static String? get photoUrl => _auth.currentUser?.photoURL;
}
