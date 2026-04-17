import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_motion.dart';
import '../theme/theme_extensions.dart';

/// iOS 26-faithful glass toggle (the "Apple switch").
///
/// Differences from Material's [Switch]:
/// - Track turns translucent **glass** while pressed/dragged
/// - Thumb stretches horizontally (the iOS "squish" affordance)
/// - Spring-bounce slide from off → on
/// - Light haptic on toggle
/// - Accent flows through (uses `context.colors.lime` when checked)
///
/// Mirrors `GlassToggle` in `liquid-glass-ds/src/components/Glass.jsx`.
class GlassToggle extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final bool disabled;

  /// Override the on-state track color. Defaults to context.colors.lime.
  final Color? activeColor;

  const GlassToggle({
    super.key,
    required this.value,
    required this.onChanged,
    this.disabled = false,
    this.activeColor,
  });

  @override
  State<GlassToggle> createState() => _GlassToggleState();
}

class _GlassToggleState extends State<GlassToggle> {
  bool _pressed = false;

  static const _trackWidth = 51.0;
  static const _trackHeight = 31.0;
  static const _thumbSize = 27.0;
  static const _padding = 2.0;

  void _setPressed(bool v) {
    if (widget.disabled || widget.onChanged == null) return;
    if (_pressed != v) setState(() => _pressed = v);
  }

  void _toggle() {
    if (widget.disabled) return;
    HapticFeedback.lightImpact();
    widget.onChanged?.call(!widget.value);
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final activeColor = widget.activeColor ?? c.lime;
    final isOn = widget.value;
    final dur = motionGate(context, AppMotion.standard);

    // Track background — glass when pressed, accent when on, neutral when off.
    final Color trackColor;
    if (_pressed) {
      trackColor = isOn
          ? activeColor.withValues(alpha: 0.55) // glass-tinted accent
          : c.surfaceCard.withValues(alpha: 0.55); // pure glass
    } else {
      trackColor = isOn ? activeColor : c.surfaceCardBorder;
    }

    // Thumb stretches horizontally on press (iOS squish).
    final thumbW = _pressed ? _thumbSize + 6 : _thumbSize;
    // When ON, thumb sits on the right; press while ON stretches to the LEFT.
    final thumbLeft = isOn
        ? (_trackWidth - thumbW - _padding)
        : _padding;

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _toggle,
      onTapDown: (_) => _setPressed(true),
      onTapUp: (_) => _setPressed(false),
      onTapCancel: () => _setPressed(false),
      child: Opacity(
        opacity: widget.disabled ? 0.35 : 1.0,
        child: AnimatedContainer(
          duration: dur,
          curve: AppMotion.easeIO,
          width: _trackWidth,
          height: _trackHeight,
          decoration: BoxDecoration(
            color: trackColor,
            borderRadius: BorderRadius.circular(_trackHeight / 2),
            border: Border.all(
              color: _pressed
                  ? c.surfaceCardBorder.withValues(alpha: 0.3)
                  : Colors.transparent,
              width: 0.5,
            ),
          ),
          child: Stack(
            clipBehavior: Clip.none,
            children: [
              AnimatedPositioned(
                duration: dur,
                curve: AppMotion.spring,
                left: thumbLeft,
                top: _padding,
                child: AnimatedContainer(
                  duration: motionGate(context, AppMotion.fast),
                  curve: AppMotion.easeIO,
                  width: thumbW,
                  height: _thumbSize,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius:
                        BorderRadius.circular(_thumbSize / 2),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(
                          alpha: _pressed ? 0.18 : 0.15,
                        ),
                        blurRadius: _pressed ? 4 : 3,
                        offset: const Offset(0, 2),
                      ),
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.04),
                        blurRadius: 0,
                        spreadRadius: 0.5,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
