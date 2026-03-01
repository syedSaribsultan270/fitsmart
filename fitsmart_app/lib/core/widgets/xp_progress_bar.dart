import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

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
    if (compact) return _buildCompact();
    return _buildFull();
  }

  Widget _buildFull() {
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
                    color: AppColors.limeGlow,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: AppColors.lime.withValues(alpha: 0.3),
                    ),
                  ),
                  child: Text(
                    'LVL $currentLevel',
                    style: AppTypography.overline.copyWith(
                      color: AppColors.lime,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  levelName,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
            Text(
              '$xpToNext XP to next',
              style: AppTypography.caption.copyWith(
                color: AppColors.textTertiary,
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
                    color: AppColors.surfaceCardBorder,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                ),
                AnimatedContainer(
                  duration: 1000.ms,
                  curve: Curves.easeOutCubic,
                  height: 8,
                  width: constraints.maxWidth * levelProgress,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.lime, AppColors.limeMuted],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.lime.withValues(alpha: 0.4),
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
        Text(
          '$totalXp total XP',
          style: AppTypography.overline.copyWith(
            color: AppColors.textTertiary,
          ),
        ),
      ],
    );
  }

  Widget _buildCompact() {
    return Row(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
          decoration: BoxDecoration(
            color: AppColors.limeGlow,
            borderRadius: BorderRadius.circular(AppRadius.full),
          ),
          child: Text(
            'LVL $currentLevel',
            style: AppTypography.overline.copyWith(
              color: AppColors.lime,
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
                      color: AppColors.surfaceCardBorder,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  AnimatedContainer(
                    duration: 800.ms,
                    curve: Curves.easeOutCubic,
                    height: 5,
                    width: constraints.maxWidth * levelProgress,
                    decoration: BoxDecoration(
                      color: AppColors.lime,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
        const SizedBox(width: AppSpacing.sm),
        Text(
          '$totalXp XP',
          style: AppTypography.overline.copyWith(
            color: AppColors.lime,
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: AppColors.limeGlow,
        borderRadius: BorderRadius.circular(AppRadius.full),
        border: Border.all(
          color: AppColors.lime.withValues(alpha: 0.4),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Text('⚡', style: TextStyle(fontSize: 16)),
          const SizedBox(width: AppSpacing.xs),
          Text(
            '+$xp XP',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.lime,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Text(
            reason,
            style: AppTypography.caption.copyWith(
              color: AppColors.textSecondary,
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
