import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Last known pointer position in **global** screen coordinates.
/// `at` is the timestamp — consumers use it to attenuate reactions
/// (e.g. eyes spring back to centered idle after X ms of no activity).
class PointerState {
  final Offset? position;
  final DateTime? at;
  const PointerState({this.position, this.at});

  /// How long ago was the last pointer event (or `null` if never).
  Duration? get age => at == null
      ? null
      : DateTime.now().difference(at!);
}

class PointerTracker extends StateNotifier<PointerState> {
  PointerTracker() : super(const PointerState());

  void update(Offset pos) {
    state = PointerState(position: pos, at: DateTime.now());
  }
}

/// Global pointer tracker. Fed by the Listener wrapping the app root
/// in `app.dart`. Consumed by any widget that wants to react to cursor/
/// touch position — the spark mascot is the first and main consumer.
final pointerTrackerProvider =
    StateNotifierProvider<PointerTracker, PointerState>(
  (ref) => PointerTracker(),
);
