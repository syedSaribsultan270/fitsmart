import 'dart:async';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/widgets/spark_mascot.dart';

/// Controls the global mood of [SparkMascot] instances across the app.
///
/// Why global: actions in one screen (logging a meal, saving a workout)
/// should *visibly* affect the mascot wherever it appears — most importantly
/// the AI Coach screen, so the user comes back to a cheering character.
///
/// The controller auto-reverts to [SparkMood.idle] after the celebration
/// window so the mascot doesn't stay stuck in `happy` forever.
class MascotMoodController extends StateNotifier<SparkMood> {
  MascotMoodController() : super(SparkMood.idle);

  Timer? _revert;

  /// Push a one-shot mood that auto-reverts to [SparkMood.idle].
  /// Use for celebrations triggered by user actions.
  void celebrate({
    SparkMood mood = SparkMood.happy,
    Duration hold = const Duration(seconds: 5),
  }) {
    _revert?.cancel();
    state = mood;
    _revert = Timer(hold, () {
      if (mounted) state = SparkMood.idle;
    });
  }

  /// Set a sticky mood (e.g. when AI is mid-thought). Caller is responsible
  /// for clearing back to [SparkMood.idle] when done.
  void setSticky(SparkMood mood) {
    _revert?.cancel();
    state = mood;
  }

  void clear() {
    _revert?.cancel();
    state = SparkMood.idle;
  }

  @override
  void dispose() {
    _revert?.cancel();
    super.dispose();
  }
}

/// App-wide mood for the spark mascot. Defaults to idle.
final mascotMoodProvider =
    StateNotifierProvider<MascotMoodController, SparkMood>(
  (ref) => MascotMoodController(),
);
