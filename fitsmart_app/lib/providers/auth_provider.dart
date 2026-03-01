import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../services/auth_service.dart';

/// Streams the current Firebase user. Null means signed out.
final authUserProvider = StreamProvider<User?>((ref) {
  return AuthService.authStateChanges;
});

/// The current user's UID. Empty string if not signed in.
final uidProvider = Provider<String>((ref) {
  return ref.watch(authUserProvider).valueOrNull?.uid ?? '';
});

/// Whether Firebase auth is ready (user is signed in, even anonymously).
final isAuthReadyProvider = Provider<bool>((ref) {
  final asyncUser = ref.watch(authUserProvider);
  return asyncUser.hasValue && asyncUser.valueOrNull != null;
});
