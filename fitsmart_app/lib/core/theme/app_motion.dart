import 'package:flutter/material.dart';

/// Apple-spec motion tokens for Liquid Glass interactions.
///
/// Source of truth: liquid-glass-ds/src/components/Glass.css
/// (calibrated against real iOS 26 / macOS Tahoe).
///
/// THE Apple spring is `cubic-bezier(0.34, 1.56, 0.64, 1)` — subtle bounce
/// overshoot. Use it for any motion that should feel "iOS native":
/// panel slide-ins, tab switches, toggle thumb, sheet detents.
abstract class AppMotion {
  // ── Curves ─────────────────────────────────────────────────────

  /// Apple's signature spring. Has overshoot — use for entrances,
  /// state morphs, anything that should feel "alive".
  /// Matches `--spring` in the React DS.
  static const Cubic spring = Cubic(0.34, 1.56, 0.64, 1.0);

  /// Softer spring without overshoot. Good for layout shifts where
  /// bounce would feel unsettled (sliding pills, panel sizes).
  /// Matches `--spring-soft`.
  static const Cubic springSoft = Cubic(0.25, 1.2, 0.5, 1.0);

  /// Standard ease-in-out. Use for color/opacity changes, blur tweens,
  /// anywhere overshoot would feel wrong.
  /// Matches `--ease-io`.
  static const Cubic easeIO = Cubic(0.42, 0, 0.58, 1.0);

  /// Punchier ease-out — good for anything entering the screen
  /// (notifications, dropdown reveals).
  /// Matches `--ease-out`.
  static const Cubic easeOut = Cubic(0.16, 1, 0.3, 1.0);

  // ── Durations ──────────────────────────────────────────────────

  /// Tap-down feedback, hover state changes.
  static const Duration fast = Duration(milliseconds: 200);

  /// Standard transitions — toggle slides, pill morphs, sheet snaps.
  static const Duration standard = Duration(milliseconds: 300);

  /// Big surface transitions — sheet open, route push.
  static const Duration slow = Duration(milliseconds: 450);

  // ── Active-state press scale ───────────────────────────────────

  /// The standard "pressed" scale used on glass cards and tiles in iOS.
  /// `transform: scale(0.97)` in the React DS.
  static const double pressScale = 0.97;
}

/// True when the user (or system) has requested reduced motion.
/// All glass-spring animations should collapse to instant when this is true,
/// per Apple's accessibility guidance.
///
/// Usage:
/// ```dart
/// AnimatedScale(
///   scale: pressed ? AppMotion.pressScale : 1.0,
///   duration: AppMotion.shouldAnimate(context)
///       ? AppMotion.fast
///       : Duration.zero,
///   curve: AppMotion.spring,
///   ...
/// )
/// ```
extension AppMotionContext on BuildContext {
  /// True if motion is allowed (i.e. reduce-motion is OFF).
  /// Returns false when MediaQuery reports `disableAnimations: true`.
  bool get motionAllowed => !MediaQuery.disableAnimationsOf(this);
}

/// Helper: returns [d] when motion is allowed, else [Duration.zero].
/// Wrap any animation duration that targets a glass surface.
Duration motionGate(BuildContext context, Duration d) {
  return MediaQuery.disableAnimationsOf(context) ? Duration.zero : d;
}
