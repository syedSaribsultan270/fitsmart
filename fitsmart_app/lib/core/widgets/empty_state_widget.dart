import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Reusable empty-state card. Shows an emoji icon, headline, body text, and
/// an optional CTA button. Use inside any list/grid that can be empty.
///
/// ```dart
/// EmptyStateWidget(
///   emoji: '🍽️',
///   headline: 'No meals logged yet',
///   body: 'Log your first meal to track your nutrition today.',
///   ctaLabel: 'Log a Meal',
///   onCta: () => context.push('/log-meal'),
/// )
/// ```
class EmptyStateWidget extends StatelessWidget {
  final String emoji;
  final String headline;
  final String body;
  final String? ctaLabel;
  final VoidCallback? onCta;
  /// Inline variant removes padding and reduces the emoji size — use inside
  /// a card that already has its own padding.
  final bool compact;

  const EmptyStateWidget({
    super.key,
    required this.emoji,
    required this.headline,
    required this.body,
    this.ctaLabel,
    this.onCta,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context) {
    final emojiSize = compact ? 40.0 : 56.0;
    final outerPadding = compact
        ? const EdgeInsets.symmetric(vertical: AppSpacing.md)
        : const EdgeInsets.symmetric(
            horizontal: AppSpacing.xl,
            vertical: AppSpacing.xl,
          );

    return Padding(
      padding: outerPadding,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Emoji icon with a subtle frosted circle behind it
          Container(
            width: emojiSize + 24,
            height: emojiSize + 24,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.bgTertiary,
              border: Border.all(
                color: AppColors.surfaceCardBorder,
                width: 1,
              ),
            ),
            alignment: Alignment.center,
            child: Text(
              emoji,
              style: TextStyle(fontSize: emojiSize * 0.7),
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 100.ms)
              .scale(
                begin: const Offset(0.7, 0.7),
                duration: 500.ms,
                delay: 100.ms,
                curve: Curves.easeOutBack,
              ),
          const SizedBox(height: AppSpacing.md),

          // Headline
          Text(
            headline,
            textAlign: TextAlign.center,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.textPrimary,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 200.ms)
              .slideY(begin: 0.2, delay: 200.ms, duration: 400.ms),
          const SizedBox(height: AppSpacing.xs),

          // Body text
          Text(
            body,
            textAlign: TextAlign.center,
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              height: 1.5,
            ),
          )
              .animate()
              .fadeIn(duration: 400.ms, delay: 300.ms),

          // Optional CTA
          if (ctaLabel != null && onCta != null) ...[
            const SizedBox(height: AppSpacing.lg),
            FilledButton(
              onPressed: onCta,
              style: FilledButton.styleFrom(
                backgroundColor: AppColors.lime,
                foregroundColor: AppColors.textInverse,
                textStyle: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.xl,
                  vertical: AppSpacing.md,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                minimumSize: const Size(0, 48),
              ),
              child: Text(ctaLabel!),
            )
                .animate()
                .fadeIn(duration: 400.ms, delay: 400.ms)
                .slideY(begin: 0.2, delay: 400.ms, duration: 400.ms),
          ],
        ],
      ),
    );
  }
}
