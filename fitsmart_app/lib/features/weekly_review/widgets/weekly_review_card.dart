import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../services/weekly_review_service.dart';

/// Visual card for a [WeeklyReviewData] block.
/// Used both in-screen and as the off-screen render for the share PNG.
/// Aspect 9:16-friendly: looks crisp on Stories and as a feed image.
class WeeklyReviewCard extends StatelessWidget {
  final WeeklyReviewData data;
  final String firstName;
  final bool isMetric;

  /// When true, renders a wordmark + watermark for the share image.
  final bool brandFooter;

  const WeeklyReviewCard({
    super.key,
    required this.data,
    required this.firstName,
    required this.isMetric,
    this.brandFooter = false,
  });

  String get _dateRange {
    final fmt = DateFormat('MMM d');
    final endInclusive = data.weekEnd.subtract(const Duration(days: 1));
    return '${fmt.format(data.weekStart)} – ${fmt.format(endInclusive)}';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 360,
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.bgSecondary, AppColors.bgPrimary],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceCardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Header ──────────────────────────────────────────────
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _dateRange.toUpperCase(),
                      style: AppTypography.caption.copyWith(
                        color: AppColors.lime,
                        letterSpacing: 1.2,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Your week, $firstName',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.textPrimary,
                        fontWeight: FontWeight.w800,
                        height: 1.1,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                width: 4, height: 36,
                decoration: BoxDecoration(
                  color: AppColors.lime,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),

          // ── 3 stat tiles ────────────────────────────────────────
          Row(
            children: [
              _StatTile(
                value: '${data.workoutsCompleted}',
                label: data.workoutsCompleted == 1 ? 'WORKOUT' : 'WORKOUTS',
                color: AppColors.lime,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatTile(
                value: '${data.streakDays}',
                label: 'ACTIVE DAYS',
                color: AppColors.coral,
              ),
              const SizedBox(width: AppSpacing.sm),
              _StatTile(
                value: '${data.totalXp}',
                label: 'XP EARNED',
                color: AppColors.warning,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),

          // ── Highlight row: PR or top macro ──────────────────────
          _HighlightRow(data: data, isMetric: isMetric),

          // ── Weight delta (only if logged twice this week) ───────
          if (data.weightDeltaKg != null) ...[
            const SizedBox(height: AppSpacing.md),
            _WeightDeltaRow(
              deltaKg: data.weightDeltaKg!,
              isMetric: isMetric,
            ),
          ],

          if (brandFooter) ...[
            const SizedBox(height: AppSpacing.lg),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(children: [
                  Container(
                    width: 8, height: 8,
                    decoration: const BoxDecoration(
                      color: AppColors.lime, shape: BoxShape.circle,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    'FitSmart AI',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.textPrimary,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ]),
                Text(
                  'fitsmart.ai',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}

class _StatTile extends StatelessWidget {
  final String value;
  final String label;
  final Color color;
  const _StatTile({
    required this.value, required this.label, required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(
          vertical: AppSpacing.md, horizontal: AppSpacing.sm,
        ),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.surfaceCardBorder),
        ),
        child: Column(
          children: [
            Text(
              value,
              style: AppTypography.h1.copyWith(
                color: color,
                fontWeight: FontWeight.w800,
                fontSize: 28,
                height: 1,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: AppColors.textSecondary,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.6,
                fontSize: 9,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HighlightRow extends StatelessWidget {
  final WeeklyReviewData data;
  final bool isMetric;
  const _HighlightRow({required this.data, required this.isMetric});

  @override
  Widget build(BuildContext context) {
    String title;
    String subtitle;
    String emoji;
    Color tint;

    if (data.hasPr) {
      final unit = isMetric ? 'kg' : 'lb';
      final delta = isMetric
          ? data.prDeltaKg!
          : data.prDeltaKg! * 2.20462;
      title = 'New PR · ${data.prExerciseName}';
      subtitle = '+${delta.toStringAsFixed(1)} $unit estimated 1RM gain';
      emoji = '🏆';
      tint = AppColors.warning;
    } else if (data.topMacroName != null) {
      title = 'Most consistent: ${data.topMacroName}';
      subtitle = 'You hit your target ${data.daysLogged} of 7 days';
      emoji = '🎯';
      tint = AppColors.cyan;
    } else if (data.workoutsCompleted > 0) {
      title = '${data.totalSets} sets crushed';
      subtitle = 'Keep stacking volume — the bar moves next week';
      emoji = '💪';
      tint = AppColors.lime;
    } else {
      title = 'A reset week';
      subtitle = 'One log tomorrow gets the streak rolling';
      emoji = '🌱';
      tint = AppColors.success;
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: tint.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: tint.withValues(alpha: 0.3)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 28)),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: AppTypography.body.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeightDeltaRow extends StatelessWidget {
  final double deltaKg;
  final bool isMetric;
  const _WeightDeltaRow({required this.deltaKg, required this.isMetric});

  @override
  Widget build(BuildContext context) {
    final unit = isMetric ? 'kg' : 'lb';
    final v = isMetric ? deltaKg : deltaKg * 2.20462;
    final isLoss = v < 0;
    final color = isLoss ? AppColors.success : AppColors.cyan;
    final sign = v > 0 ? '+' : '';
    return Row(
      children: [
        Icon(
          isLoss ? Icons.trending_down : Icons.trending_up,
          size: 18,
          color: color,
        ),
        const SizedBox(width: 6),
        Text(
          'Weight: $sign${v.toStringAsFixed(1)} $unit this week',
          style: AppTypography.body.copyWith(
            color: AppColors.textSecondary,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}
