// ignore_for_file: avoid_renaming_method_parameters
// (Our StateNotifier has a `state` setter, so we can't use `state` as the
// didChangeAppLifecycleState parameter name without shadowing it.)

import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Random one-shot behaviours the mascot plays on top of its base mood.
/// Quirks never fire during `thinking` or `sleeping` — those moods have
/// their own animation language and extra motion reads as jitter.
enum MascotQuirk {
  /// No quirk right now — baseline idle.
  none,

  /// Eyes sweep left → right → back. Cheapest, most common.
  lookAround,

  /// Two quick blinks in a row instead of one.
  doubleBlink,

  /// Gentle head tilt (~5°), held briefly.
  headTilt,

  /// Mouth opens in a tiny arc + eyes squint. The sleepy one.
  yawn,

  /// Fast horizontal shiver (×3) — "clearing head".
  shake,

  /// Sudden glance in a random direction + body flinch.
  noticeSomething,

  /// Two little vertical bounces — the rare cute one.
  danceHop,
}

/// Each quirk's play duration. Must be >0; controller auto-returns to
/// `none` after this.
const _quirkDurations = <MascotQuirk, Duration>{
  MascotQuirk.none:            Duration(milliseconds: 1),
  MascotQuirk.lookAround:      Duration(milliseconds: 1200),
  MascotQuirk.doubleBlink:     Duration(milliseconds: 500),
  MascotQuirk.headTilt:        Duration(milliseconds: 700),
  MascotQuirk.yawn:            Duration(milliseconds: 1000),
  MascotQuirk.shake:           Duration(milliseconds: 400),
  MascotQuirk.noticeSomething: Duration(milliseconds: 900),
  MascotQuirk.danceHop:        Duration(milliseconds: 900),
};

/// Weighted distribution over quirks (values sum to 100 — percentages).
const _weights = <MascotQuirk, int>{
  MascotQuirk.lookAround:      30,
  MascotQuirk.doubleBlink:     20,
  MascotQuirk.headTilt:        15,
  MascotQuirk.yawn:            10,
  MascotQuirk.shake:           10,
  MascotQuirk.noticeSomething: 10,
  MascotQuirk.danceHop:        5,
};

/// Rolls one quirk every 18–45 seconds. Consumers render the current
/// [MascotQuirk]; the controller auto-returns to `none` after the quirk's
/// duration, so no cleanup is needed at the call site.
///
/// Rate-limited: no two quirks within 15s; paused when the app is in the
/// background to save battery.
class MascotQuirkController extends StateNotifier<MascotQuirk>
    with WidgetsBindingObserver {
  MascotQuirkController() : super(MascotQuirk.none) {
    WidgetsBinding.instance.addObserver(this);
    _schedule();
  }

  final _rng = math.Random();
  Timer? _next;
  Timer? _revert;
  DateTime? _lastFired;
  bool _paused = false;

  void _schedule() {
    _next?.cancel();
    // Random interval in [18s, 45s].
    final seconds = 18 + _rng.nextInt(28);
    _next = Timer(Duration(seconds: seconds), _roll);
  }

  void _roll() {
    if (_paused || !mounted) {
      _schedule();
      return;
    }
    // Rate limit: at least 15s between quirks.
    final last = _lastFired;
    if (last != null && DateTime.now().difference(last).inSeconds < 15) {
      _schedule();
      return;
    }
    final quirk = _pickWeighted();
    _fire(quirk);
  }

  MascotQuirk _pickWeighted() {
    final total = _weights.values.fold<int>(0, (a, b) => a + b);
    final r = _rng.nextInt(total);
    var acc = 0;
    for (final entry in _weights.entries) {
      acc += entry.value;
      if (r < acc) return entry.key;
    }
    return MascotQuirk.lookAround;
  }

  void _fire(MascotQuirk q) {
    _lastFired = DateTime.now();
    state = q;
    _revert?.cancel();
    _revert = Timer(_quirkDurations[q]!, () {
      if (!mounted) return;
      state = MascotQuirk.none;
      _schedule();
    });
  }

  /// Force-play a specific quirk immediately. Used to celebrate explicit
  /// user actions from other providers (e.g. workout saved → `.danceHop`).
  void play(MascotQuirk q) {
    if (q == MascotQuirk.none) return;
    _fire(q);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState lifecycle) {
    _paused = lifecycle != AppLifecycleState.resumed;
    if (_paused) {
      _next?.cancel();
      _revert?.cancel();
      state = MascotQuirk.none;
    } else {
      _schedule();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _next?.cancel();
    _revert?.cancel();
    super.dispose();
  }
}

final mascotQuirkProvider =
    StateNotifierProvider<MascotQuirkController, MascotQuirk>(
  (ref) => MascotQuirkController(),
);
