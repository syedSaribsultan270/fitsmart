import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_extensions.dart';

class MacroBar extends StatelessWidget {
  final String label;
  final double consumed;
  final double target;
  final Color color;
  final String unit;
  /// Stagger index when rendered inside a list of MacroBars.
  /// Each bar's fill animation starts staggerIndex × 90ms after mount.
  final int staggerIndex;

  const MacroBar({
    super.key,
    required this.label,
    required this.consumed,
    required this.target,
    required this.color,
    this.unit = 'g',
    this.staggerIndex = 0,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final double progress =
        (target > 0 ? (consumed / target).toDouble() : 0.0).clamp(0.0, 1.0);
    final isOver = consumed > target;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: AppSpacing.xs),
                Text(
                  label,
                  style: AppTypography.caption.copyWith(
                    color: c.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            Row(
              children: [
                Text(
                  consumed.toStringAsFixed(0),
                  style: AppTypography.caption.copyWith(
                    color: isOver ? c.error : c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  ' / ${target.toStringAsFixed(0)}$unit',
                  style: AppTypography.caption.copyWith(
                    color: c.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.xs),
        LayoutBuilder(
          builder: (context, constraints) {
            // Mount-time fill: tween from 0 → progress, staggered by index.
            // Subsequent value changes still use the AnimatedContainer below.
            return TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: progress),
              duration: const Duration(milliseconds: 700),
              curve: Curves.easeOutCubic,
              builder: (_, fillFrac, __) => Stack(
                children: [
                  // Track
                  Container(
                    height: 6,
                    decoration: BoxDecoration(
                      color: c.surfaceCardBorder,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  // Progress
                  Container(
                    height: 6,
                    width: constraints.maxWidth * fillFrac,
                    decoration: BoxDecoration(
                      color: isOver ? c.error : color,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      boxShadow: [
                        BoxShadow(
                          color: (isOver ? c.error : color)
                              .withValues(alpha: 0.4),
                          blurRadius: 4,
                          offset: const Offset(0, 1),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            )
                .animate()
                .fadeIn(
                  delay: Duration(milliseconds: staggerIndex * 90),
                  duration: 200.ms,
                );
          },
        ),
      ],
    );
  }
}

/// Compact inline macro row used in meal cards
class MacroChip extends StatelessWidget {
  final double value;
  final String label;
  final Color color;

  const MacroChip({
    super.key,
    required this.value,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(AppRadius.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value.toStringAsFixed(0),
            style: AppTypography.caption.copyWith(
              color: color,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(width: 2),
          Text(
            label,
            style: AppTypography.overline.copyWith(
              color: color.withValues(alpha: 0.8),
            ),
          ),
        ],
      ),
    );
  }
}
