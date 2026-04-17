import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_extensions.dart';
import 'animated_number.dart';

class XpProgressBar extends StatelessWidget {
  final int totalXp;
  final int currentLevel;
  final String levelName;
  final double levelProgress;
  final int xpToNext;
  final bool compact;

  const XpProgressBar({
    super.key,
    required this.totalXp,
    required this.currentLevel,
    required this.levelName,
    required this.levelProgress,
    required this.xpToNext,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    if (compact) return _buildCompact(context);
    return _buildFull(context);
  }

  Widget _buildFull(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: c.limeGlow,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: c.lime.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'LVL $currentLevel',
                    style: AppTypography.overline.copyWith(
                      color: c.lime,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  levelName,
                  style: AppTypography.bodyMedium.copyWith(
                    color: c.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              '$xpToNext XP to next',
              style: AppTypography.caption.copyWith(
                color: c.textTertiary,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.sm),
        LayoutBuilder(
          builder: (context, constraints) {
            return Stack(
              children: [
                Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: c.surfaceCardBorder,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
                AnimatedContainer(
                  duration: 1000.ms,
                  curve: Curves.easeOutCubic,
                  height: 8,
                  width: constraints.maxWidth * levelProgress,
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      colors: [c.lime, c.limeMuted],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: [
                      BoxShadow(
                        color: c.lime.withValues(alpha: 0.4),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
        const SizedBox(height: AppSpacing.xs),
        AnimatedNumber(
          value: totalXp,
          builder: (v) => Text(
            '$v total XP',
            style: AppTypography.overline.copyWith(
              color: c.textTertiary,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompact(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: c.limeGlow,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            'LVL $currentLevel',
            style: AppTypography.overline.copyWith(
              color: c.lime,
              fontWeight: FontWeight.w800,
            ),
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Expanded(
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  Container(
                    height: 5,
                    decoration: BoxDecoration(
                      color: c.surfaceCardBorder,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  AnimatedContainer(
                    duration: 800.ms,
                    curve: Curves.easeOutCubic,
                    height: 5,
                    width: constraints.maxWidth * levelProgress,
                    decoration: BoxDecoration(
                      color: c.lime,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        AnimatedNumber(
          value: totalXp,
          builder: (v) => Text(
            '$v XP',
            style: AppTypography.overline.copyWith(
              color: c.lime,
            ),
          ),
        ),
      ],
    );
  }
}

/// Floating +XP toast notification
class XpGainToast extends StatelessWidget {
  final int xp;
  final String reason;

  const XpGainToast({super.key, required this.xp, required this.reason});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: c.limeGlow,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: c.lime.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('\u26A1', style: TextStyle(fontSize: 16)),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '+$xp XP',
            style: AppTypography.bodyMedium.copyWith(
              color: c.lime,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            reason,
            style: AppTypography.caption.copyWith(
              color: c.textSecondary,
            ),
          ),
        ],
      ),
    )
        .animate()
        .slideY(begin: 0.3, end: 0, duration: 300.ms, curve: Curves.elasticOut)
        .fadeIn(duration: 200.ms);
  }
}
