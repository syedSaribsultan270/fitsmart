import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Emits `true` when the device has any network interface, `false` when offline.
///
/// Uses connectivity_plus's stream so it reacts in real-time without polling.
/// Note: connectivity_plus reports interface presence, not internet reachability —
/// this is the right trade-off for instant UX feedback without a DNS round-trip.
final connectivityProvider = StreamProvider<bool>((ref) async* {
  final connectivity = Connectivity();

  // Emit the current state immediately so the UI doesn't start unknown
  final initial = await connectivity.checkConnectivity();
  yield _isOnline(initial);

  // Then stream changes
  yield* connectivity.onConnectivityChanged.map(_isOnline);
});

bool _isOnline(List<ConnectivityResult> results) =>
    results.any((r) => r != ConnectivityResult.none);
