import 'dart:ui';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/theme_extensions.dart';

/// Visual intensity of the glass surface.
/// Stronger = more opaque fill (better legibility, less "see-through" feel).
enum GlassIntensity {
  /// Barely-there frost — for floating banners over rich content.
  subtle,
  /// Default — for nav bars, sheets, snackbars.
  regular,
  /// High-opacity glass — for tiles where data legibility is critical.
  strong,
}

/// Centralized glass tokens. Tweak in one place; every glass surface follows.
abstract class AppGlass {
  /// Backdrop blur sigma. Higher = more pronounced frost.
  /// Web caps at 8 because heavy BackdropFilter cripples the impeller renderer.
  static double blurSigma(BuildContext context) {
    if (kIsWeb) return 8;
    return Theme.of(context).brightness == Brightness.dark ? 24 : 18;
  }

  /// Fill alpha for the translucent layer behind the blur.
  /// Light theme uses higher alpha (white needs more body to register as glass).
  static double fillAlpha(BuildContext context, GlassIntensity i) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (isDark) {
      return switch (i) {
        GlassIntensity.subtle => 0.35,
        GlassIntensity.regular => 0.55,
        GlassIntensity.strong => 0.72,
      };
    }
    return switch (i) {
      GlassIntensity.subtle => 0.55,
      GlassIntensity.regular => 0.72,
      GlassIntensity.strong => 0.85,
    };
  }

  /// Top-edge highlight alpha that mimics a glass rim catching light.
  static double rimHighlightAlpha(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? 0.12 : 0.6;

  /// Bottom-edge shadow alpha for a slight dimensional drop.
  static double rimShadowAlpha(BuildContext context) =>
      Theme.of(context).brightness == Brightness.dark ? 0.30 : 0.06;

  /// Accent-tint alpha when [LiquidGlass.accentRim] is true.
  /// Always low — the accent is a hint, not a fill.
  static const double accentRimAlpha = 0.18;
  static const double accentInnerGlowAlpha = 0.05;
}

/// Liquid-glass surface — backdrop blur + translucent fill + rim highlight.
///
/// Theme- and accent-aware out of the box. Drop on top of any background
/// (gradient, image, scrolling content) and it will frost what's behind.
///
/// Maximalist iOS-26 styling:
/// - Backdrop blur with theme-tuned sigma
/// - Translucent fill from [intensity]
/// - Top-edge highlight (the "rim" you see on real glass)
/// - Bottom-edge soft shadow
/// - Optional accent-color tinted rim (uses settings accent automatically)
///
/// Performance:
/// - One BackdropFilter per instance — don't stack 5 of these in a row.
/// - On web, blur is capped at sigma 8 (Impeller perf).
/// - Children should be opaque-ish text/icons — don't put another glass inside.
class LiquidGlass extends StatelessWidget {
  final Widget child;
  final BorderRadius borderRadius;
  final GlassIntensity intensity;

  /// When true, the top edge picks up the user's accent color (via theme).
  /// Use sparingly — premium banners, hero cards, paywall tiles.
  final bool accentRim;

  /// When true, draws a subtle inner accent glow at the top.
  /// Pairs with [accentRim] for upgrade prompts and unlock moments.
  final bool accentInnerGlow;

  /// Optional override of the rim border color (defaults to surfaceCardBorder).
  final Color? borderColor;

  /// Optional padding inside the glass surface.
  final EdgeInsetsGeometry? padding;

  /// Optional fixed background tint underneath the blur.
  /// Defaults to context.colors.bgSecondary (theme-aware).
  final Color? tintColor;

  const LiquidGlass({
    super.key,
    required this.child,
    this.borderRadius = const BorderRadius.all(Radius.circular(16)),
    this.intensity = GlassIntensity.regular,
    this.accentRim = false,
    this.accentInnerGlow = false,
    this.borderColor,
    this.padding,
    this.tintColor,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sigma = AppGlass.blurSigma(context);
    final fill = AppGlass.fillAlpha(context, intensity);
    final tint = (tintColor ?? c.bgSecondary).withValues(alpha: fill);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final rimColor = accentRim
        ? c.lime.withValues(alpha: AppGlass.accentRimAlpha)
        : (borderColor ?? c.surfaceCardBorder.withValues(alpha: 0.6));

    return ClipRRect(
      borderRadius: borderRadius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
        child: Container(
          decoration: BoxDecoration(
            color: tint,
            borderRadius: borderRadius,
            border: Border.all(color: rimColor, width: 1),
            // Subtle gradient mimics a light-catching rim on the top edge.
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Colors.white.withValues(
                  alpha: AppGlass.rimHighlightAlpha(context) *
                      (isDark ? 1.0 : 0.4),
                ),
                Colors.transparent,
                Colors.black.withValues(
                  alpha: AppGlass.rimShadowAlpha(context) *
                      (isDark ? 1.0 : 0.5),
                ),
              ],
              stops: const [0.0, 0.5, 1.0],
            ),
          ),
          foregroundDecoration: accentInnerGlow
              ? BoxDecoration(
                  borderRadius: borderRadius,
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.center,
                    colors: [
                      c.lime.withValues(alpha: AppGlass.accentInnerGlowAlpha),
                      Colors.transparent,
                    ],
                  ),
                )
              : null,
          child: padding != null
              ? Padding(padding: padding!, child: child)
              : child,
        ),
      ),
    );
  }
}

/// A SliverAppBar (or AppBar) with a liquid-glass background.
/// Drop into any sliver list — content scrolls under it and gets frosted.
///
/// Usage:
/// ```dart
/// LiquidGlassAppBar(
///   title: Text('Nutrition'),
///   actions: [...],
/// )
/// ```
class LiquidGlassAppBar extends StatelessWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool floating;
  final bool pinned;
  final bool centerTitle;
  final double toolbarHeight;
  final PreferredSizeWidget? bottom;

  const LiquidGlassAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.floating = true,
    this.pinned = false,
    this.centerTitle = false,
    this.toolbarHeight = kToolbarHeight,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final sigma = AppGlass.blurSigma(context);
    return SliverAppBar(
      backgroundColor: Colors.transparent,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      floating: floating,
      pinned: pinned,
      leading: leading,
      title: title,
      actions: actions,
      centerTitle: centerTitle,
      toolbarHeight: toolbarHeight,
      bottom: bottom,
      flexibleSpace: ClipRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: sigma, sigmaY: sigma),
          child: DecoratedBox(
            decoration: BoxDecoration(
              color: c.bgPrimary.withValues(
                alpha: AppGlass.fillAlpha(context, GlassIntensity.regular),
              ),
              border: Border(
                bottom: BorderSide(
                  color: c.surfaceCardBorder.withValues(alpha: 0.4),
                  width: 1,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Drop-in [AppBar] replacement that frosts content scrolled under it.
/// The host [Scaffold] should set `extendBodyBehindAppBar: true` so the
/// blur has something to capture.
class LiquidAppBar extends StatelessWidget implements PreferredSizeWidget {
  final Widget? title;
  final List<Widget>? actions;
  final Widget? leading;
  final bool centerTitle;
  final double elevation;
  final PreferredSizeWidget? bottom;
  final bool automaticallyImplyLeading;

  const LiquidAppBar({
    super.key,
    this.title,
    this.actions,
    this.leading,
    this.centerTitle = false,
    this.elevation = 0,
    this.bottom,
    this.automaticallyImplyLeading = true,
  });

  static const _toolbar = kToolbarHeight;

  @override
  Size get preferredSize => Size.fromHeight(
        _toolbar + (bottom?.preferredSize.height ?? 0),
      );

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    // Solid surface to prevent body content bleeding through the appbar.
    // Scaffold's body paints before the appbar, so a BackdropFilter here
    // would sample body pixels and produce visible artefacts. The "glass"
    // aesthetic is preserved via a faint top-edge highlight + accent-tinted
    // bottom border, which on an OLED-dark background reads as glass without
    // needing real translucency. Real frost lives on the bottom nav where
    // there's genuine content scrolling underneath.
    return AppBar(
      backgroundColor: c.bgPrimary,
      surfaceTintColor: Colors.transparent,
      elevation: elevation,
      scrolledUnderElevation: 0,
      title: title,
      actions: actions,
      leading: leading,
      centerTitle: centerTitle,
      bottom: bottom,
      automaticallyImplyLeading: automaticallyImplyLeading,
      flexibleSpace: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Colors.white.withValues(
                alpha: Theme.of(context).brightness == Brightness.dark
                    ? 0.04
                    : 0.18,
              ),
              Colors.transparent,
            ],
            stops: const [0.0, 0.6],
          ),
        ),
      ),
      shape: Border(
        bottom: BorderSide(
          color: c.surfaceCardBorder.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
    );
  }
}

/// Show a modal bottom sheet with a liquid-glass surface.
///
/// Drop-in replacement for `showModalBottomSheet`:
/// - Transparent barrier so the blur shows the page behind
/// - Sheet shape uses theme radii
/// - [accentRim] enables the accent-tinted top edge for premium moments
Future<T?> showLiquidGlassSheet<T>(
  BuildContext context, {
  required WidgetBuilder builder,
  bool isScrollControlled = false,
  bool useSafeArea = true,
  bool accentRim = false,
  GlassIntensity intensity = GlassIntensity.regular,
  EdgeInsets padding = const EdgeInsets.fromLTRB(20, 16, 20, 24),
}) {
  return showModalBottomSheet<T>(
    context: context,
    isScrollControlled: isScrollControlled,
    useSafeArea: useSafeArea,
    backgroundColor: Colors.transparent,
    barrierColor: Colors.black.withValues(alpha: 0.45),
    elevation: 0,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
    ),
    builder: (ctx) => LiquidGlass(
      borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
      intensity: intensity,
      accentRim: accentRim,
      accentInnerGlow: accentRim,
      padding: padding,
      child: builder(ctx),
    ),
  );
}
