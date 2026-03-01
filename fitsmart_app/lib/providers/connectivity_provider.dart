import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Provides current connectivity status as a stream.
final connectivityProvider = StreamProvider<bool>((ref) {
  final connectivity = Connectivity();

  // Transform ConnectivityResult list to a simple bool
  return connectivity.onConnectivityChanged.map((results) {
    return results.any((r) => r != ConnectivityResult.none);
  });
});

/// Synchronous access to last-known connectivity state.
final isOnlineProvider = Provider<bool>((ref) {
  return ref.watch(connectivityProvider).valueOrNull ?? true;
});
