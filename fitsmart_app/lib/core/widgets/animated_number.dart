import 'package:flutter/material.dart';

/// Counts smoothly from the previous value to [value] whenever it changes.
///
/// Use everywhere a numeric stat changes from user action — calorie totals,
/// streak day count, XP, water ml, weight. Tween reads as "progress earned"
/// instead of "value updated", which converts better.
///
/// Usage:
/// ```dart
/// AnimatedNumber(
///   value: 1450,
///   duration: const Duration(milliseconds: 700),
///   builder: (v) => Text('$v', style: AppTypography.h1),
/// )
/// ```
class AnimatedNumber extends StatefulWidget {
  /// Target value to animate toward.
  final num value;

  /// Animation duration. Defaults to 700ms — long enough to read as
  /// "counting up", short enough to not block flow.
  final Duration duration;

  /// Easing curve. easeOutCubic feels like "settling into place".
  final Curve curve;

  /// Builder called with the interpolated value.
  /// Receives an [int] when [value] is an int, otherwise a [double].
  final Widget Function(num value) builder;

  /// Number of decimal places to round to when [value] is a double.
  /// Ignored when [value] is an int.
  final int decimals;

  const AnimatedNumber({
    super.key,
    required this.value,
    required this.builder,
    this.duration = const Duration(milliseconds: 700),
    this.curve = Curves.easeOutCubic,
    this.decimals = 0,
  });

  @override
  State<AnimatedNumber> createState() => _AnimatedNumberState();
}

class _AnimatedNumberState extends State<AnimatedNumber> {
  late num _previous;

  @override
  void initState() {
    super.initState();
    _previous = widget.value;
  }

  @override
  void didUpdateWidget(covariant AnimatedNumber old) {
    super.didUpdateWidget(old);
    // Hold previous as the start of the next tween.
    if (old.value != widget.value) {
      _previous = old.value;
    }
  }

  @override
  Widget build(BuildContext context) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: _previous.toDouble(), end: widget.value.toDouble()),
      duration: widget.duration,
      curve: widget.curve,
      builder: (_, v, __) {
        final num shown = widget.value is int
            ? v.round()
            : double.parse(v.toStringAsFixed(widget.decimals));
        return widget.builder(shown);
      },
    );
  }
}
