import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../theme/app_motion.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_extensions.dart';

/// A single tab in a [GlassSegment].
class GlassSegmentItem<T> {
  final T value;
  final String label;
  const GlassSegmentItem({required this.value, required this.label});
}

/// iOS-style segmented control with a glass track and a sliding active pill.
///
/// The pill smoothly translates and resizes between segments using the Apple
/// soft-spring curve. Drop-in replacement for `TabBar` when the tabs are
/// short labels (≤3-4 segments).
///
/// Mirrors `GlassSegment` in `liquid-glass-ds/src/components/Glass.jsx`.
///
/// Usage:
/// ```dart
/// GlassSegment<String>(
///   items: const [
///     GlassSegmentItem(value: 'today',   label: 'TODAY'),
///     GlassSegmentItem(value: 'week',    label: 'WEEK'),
///     GlassSegmentItem(value: 'month',   label: 'MONTH'),
///   ],
///   value: _scope,
///   onChanged: (v) => setState(() => _scope = v),
/// )
/// ```
class GlassSegment<T> extends StatefulWidget {
  final List<GlassSegmentItem<T>> items;
  final T value;
  final ValueChanged<T> onChanged;

  /// Vertical padding inside the track.
  final EdgeInsetsGeometry padding;

  /// Optional override for the pill background. Defaults to surfaceCard.
  final Color? pillColor;

  const GlassSegment({
    super.key,
    required this.items,
    required this.value,
    required this.onChanged,
    this.padding = const EdgeInsets.symmetric(horizontal: 18, vertical: 7),
    this.pillColor,
  });

  @override
  State<GlassSegment<T>> createState() => _GlassSegmentState<T>();
}

class _GlassSegmentState<T> extends State<GlassSegment<T>> {
  final _itemKeys = <T, GlobalKey>{};
  final _trackKey = GlobalKey();
  Rect? _pillRect;

  @override
  void initState() {
    super.initState();
    for (final item in widget.items) {
      _itemKeys[item.value] = GlobalKey();
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
  }

  @override
  void didUpdateWidget(covariant GlassSegment<T> old) {
    super.didUpdateWidget(old);
    if (old.value != widget.value || old.items.length != widget.items.length) {
      // Re-key any new items
      for (final item in widget.items) {
        _itemKeys.putIfAbsent(item.value, () => GlobalKey());
      }
      WidgetsBinding.instance.addPostFrameCallback((_) => _measure());
    }
  }

  void _measure() {
    final track = _trackKey.currentContext?.findRenderObject() as RenderBox?;
    final activeKey = _itemKeys[widget.value];
    final active = activeKey?.currentContext?.findRenderObject() as RenderBox?;
    if (track == null || active == null) return;
    final activeOffset =
        active.localToGlobal(Offset.zero, ancestor: track);
    final newRect = Rect.fromLTWH(
      activeOffset.dx,
      activeOffset.dy,
      active.size.width,
      active.size.height,
    );
    if (_pillRect != newRect) {
      setState(() => _pillRect = newRect);
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final pill = widget.pillColor ?? c.surfaceCard;
    final dur = motionGate(context, AppMotion.standard);

    return Container(
      key: _trackKey,
      decoration: BoxDecoration(
        color: c.bgTertiary.withValues(alpha: 0.8),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: c.surfaceCardBorder.withValues(alpha: 0.5),
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.all(3),
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Sliding pill — glides between active segments
          if (_pillRect != null)
            AnimatedPositioned(
              duration: dur,
              curve: AppMotion.springSoft,
              left: _pillRect!.left,
              top: _pillRect!.top,
              width: _pillRect!.width,
              height: _pillRect!.height,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: pill,
                  borderRadius:
                      BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.08),
                      blurRadius: 4,
                      offset: const Offset(0, 1),
                    ),
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.03),
                      blurRadius: 0,
                      spreadRadius: 0.5,
                    ),
                  ],
                ),
              ),
            ),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: widget.items.map((item) {
              final isActive = item.value == widget.value;
              return _Item(
                key: _itemKeys[item.value],
                label: item.label,
                isActive: isActive,
                padding: widget.padding,
                onTap: () {
                  if (item.value == widget.value) return;
                  HapticFeedback.selectionClick();
                  widget.onChanged(item.value);
                  // Re-measure on next frame after the active key changes
                  WidgetsBinding.instance
                      .addPostFrameCallback((_) => _measure());
                },
              );
            }).toList(),
          ),
        ],
      ),
    );
  }
}

class _Item extends StatefulWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final EdgeInsetsGeometry padding;

  const _Item({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    required this.padding,
  });

  @override
  State<_Item> createState() => _ItemState();
}

class _ItemState extends State<_Item> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedScale(
        scale: _pressed ? 0.95 : 1.0,
        duration: motionGate(context, const Duration(milliseconds: 100)),
        curve: AppMotion.spring,
        child: Padding(
          padding: widget.padding,
          child: AnimatedDefaultTextStyle(
            duration: motionGate(context, AppMotion.fast),
            curve: AppMotion.easeIO,
            style: AppTypography.caption.copyWith(
              color: widget.isActive ? c.textPrimary : c.textSecondary,
              fontWeight: widget.isActive
                  ? FontWeight.w700
                  : FontWeight.w500,
              letterSpacing: 0.5,
            ),
            child: Text(widget.label),
          ),
        ),
      ),
    );
  }
}
