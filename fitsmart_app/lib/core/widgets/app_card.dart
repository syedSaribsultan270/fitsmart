import 'package:flutter/material.dart';
import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/theme_extensions.dart';
import 'liquid_glass.dart';

class AppCard extends StatefulWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final Color? backgroundColor;
  final Color? borderColor;
  final double? borderWidth;
  final VoidCallback? onTap;
  final double? borderRadius;
  final List<BoxShadow>? boxShadow;

  const AppCard({
    super.key,
    required this.child,
    this.padding,
    this.backgroundColor,
    this.borderColor,
    this.borderWidth,
    this.onTap,
    this.borderRadius,
    this.boxShadow,
  });

  @override
  State<AppCard> createState() => _AppCardState();
}

class _AppCardState extends State<AppCard> {
  bool _pressed = false;

  void _setPressed(bool v) {
    if (widget.onTap == null) return;
    if (_pressed != v) setState(() => _pressed = v);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final radius = BorderRadius.circular(widget.borderRadius ?? AppRadius.lg);
    // Background colour passed in (e.g. errorBg, successBg) implies the caller
    // wants a SOLID semantic-tinted surface — not glass — for legibility.
    final useGlass = widget.backgroundColor == null;
    final isLight = Theme.of(context).brightness == Brightness.light;

    // Light mode needs a soft drop-shadow to lift the card off the near-white
    // page wash; dark mode relies on the glass border for separation.
    final lightShadow = isLight
        ? [
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.04),
              blurRadius: 16,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: const Color(0xFF0F172A).withValues(alpha: 0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ]
        : null;

    final card = useGlass
        ? DecoratedBox(
            decoration: BoxDecoration(
              borderRadius: radius,
              boxShadow: lightShadow,
            ),
            child: LiquidGlass(
              borderRadius: radius,
              intensity: GlassIntensity.strong,
              borderColor: widget.borderColor,
              padding: widget.padding ??
                  const EdgeInsets.all(AppSpacing.cardPadding),
              child: widget.child,
            ),
          )
        : Container(
            decoration: BoxDecoration(
              color: widget.backgroundColor,
              borderRadius: radius,
              border: Border.all(
                color: widget.borderColor ?? c.surfaceCardBorder,
                width: widget.borderWidth ?? 1,
              ),
              boxShadow: widget.boxShadow ?? lightShadow,
            ),
            padding: widget.padding ??
                const EdgeInsets.all(AppSpacing.cardPadding),
            child: widget.child,
          );

    if (widget.onTap != null) {
      // Apple's active-state press: scale to 0.97 with the spring curve
      // for the satisfying "iOS card press" feel. Reduce-motion gates this.
      return AnimatedScale(
        scale: _pressed ? AppMotion.pressScale : 1.0,
        duration: motionGate(context, AppMotion.fast),
        curve: AppMotion.spring,
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: widget.onTap,
            onTapDown: (_) => _setPressed(true),
            onTapUp: (_) => _setPressed(false),
            onTapCancel: () => _setPressed(false),
            borderRadius: radius,
            splashColor: c.surfaceCardHover.withValues(alpha: 0.5),
            child: card,
          ),
        ),
      );
    }

    return card;
  }
}

/// Card with a colored left accent border
class AccentCard extends StatelessWidget {
  final Widget child;
  final Color? accentColor;
  final EdgeInsetsGeometry? padding;

  const AccentCard({
    super.key,
    required this.child,
    this.accentColor,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final accent = accentColor ?? c.lime;
    return LiquidGlass(
      borderRadius: BorderRadius.circular(AppRadius.lg),
      intensity: GlassIntensity.strong,
      borderColor: accent.withValues(alpha: 0.35),
      child: Row(
        children: [
          Container(
            width: 3,
            decoration: BoxDecoration(
              color: accent,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.lg),
                bottomLeft: Radius.circular(AppRadius.lg),
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
              child: child,
            ),
          ),
        ],
      ),
    );
  }
}

/// A glowing card with a colored glow border
class GlowCard extends StatelessWidget {
  final Widget child;
  final Color? glowColor;
  final EdgeInsetsGeometry? padding;
  final double glowRadius;

  const GlowCard({
    super.key,
    required this.child,
    this.glowColor,
    this.padding,
    this.glowRadius = 12,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final glow = glowColor ?? c.lime;
    // Outer glow stays solid (BoxShadow can't paint through a clip),
    // wrapped around a glass core. Best of both worlds.
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        boxShadow: [
          BoxShadow(
            color: glow.withValues(alpha: 0.18),
            blurRadius: glowRadius,
            spreadRadius: 0,
          ),
        ],
      ),
      child: LiquidGlass(
        borderRadius: BorderRadius.circular(AppRadius.lg),
        intensity: GlassIntensity.strong,
        borderColor: glow.withValues(alpha: 0.4),
        accentInnerGlow: glow == c.lime,
        padding: padding ?? const EdgeInsets.all(AppSpacing.cardPadding),
        child: child,
      ),
    );
  }
}
