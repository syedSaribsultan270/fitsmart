import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_button.dart';
import 'onboarding_flow.dart';

class StepBudget extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const StepBudget({super.key, required this.onNext});

  @override
  ConsumerState<StepBudget> createState() => _StepBudgetState();
}

class _StepBudgetState extends ConsumerState<StepBudget> {
  int _tierIndex = 1; // 0=<100, 1=100-250, 2=250-500, 3=500+

  static List<_BudgetTier> _tiers(BuildContext context) {
    final colors = context.colors;
    return [
      _BudgetTier(
        emoji: '\uD83D\uDCB8',
        title: 'Budget',
        range: 'Under \$100/mo',
        desc: 'Simple, affordable meals. Rice, eggs, beans, seasonal veg.',
        value: 80.0,
        color: colors.textSecondary,
      ),
      _BudgetTier(
        emoji: '\uD83E\uDD57',
        title: 'Balanced',
        range: '\$100\u2013\$250/mo',
        desc: 'Meal preps with chicken, fish, whole grains, and variety.',
        value: 175.0,
        color: colors.lime,
      ),
      _BudgetTier(
        emoji: '\uD83E\uDD69',
        title: 'Premium',
        range: '\$250\u2013\$500/mo',
        desc: 'Quality cuts, organic options, superfoods, and supplements.',
        value: 375.0,
        color: colors.cyan,
      ),
      _BudgetTier(
        emoji: '\uD83D\uDC51',
        title: 'No Limits',
        range: '\$500+/mo',
        desc: 'Chef-level ingredients. Grass-fed, wild-caught, organic everything.',
        value: 600.0,
        color: colors.warning,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final tiers = _tiers(context);
    final tier = tiers[_tierIndex];

    return OnboardingStepBase(
      emoji: '\uD83D\uDCB0',
      title: 'Your Nutrition\nBudget',
      subtitle: 'We\'ll suggest meals that fit your wallet.',
      content: Column(
        children: [
          // Big display
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: tier.color.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.xl),
              border: Border.all(color: tier.color.withValues(alpha: 0.3)),
            ),
            child: Column(
              children: [
                Text(tier.emoji, style: const TextStyle(fontSize: 48))
                    .animate(key: ValueKey(_tierIndex))
                    .scale(duration: 300.ms, curve: Curves.elasticOut),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  tier.title,
                  style: AppTypography.h2.copyWith(
                    color: tier.color,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  tier.range,
                  style: AppTypography.bodyMedium.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  tier.desc,
                  style: AppTypography.body.copyWith(
                    color: context.colors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          // Tier selector
          Row(
            children: tiers.asMap().entries.map((e) {
              final isSelected = e.key == _tierIndex;
              final t = e.value;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: e.key < 3 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _tierIndex = e.key);
                    },
                    child: AnimatedContainer(
                      duration: 200.ms,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? t.color.withValues(alpha: 0.12)
                            : context.colors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isSelected ? t.color : context.colors.surfaceCardBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(t.emoji, style: const TextStyle(fontSize: 20)),
                          const SizedBox(height: 4),
                          Text(
                            t.title,
                            style: AppTypography.overline.copyWith(
                              color: isSelected ? t.color : context.colors.textTertiary,
                              fontWeight: FontWeight.w700,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
      cta: AppButton(
        label: 'Set My Budget',
        onPressed: () {
          ref.read(onboardingProvider.notifier)
              .setBudget(tiers[_tierIndex].value);
          widget.onNext();
        },
      ),
    );
  }
}

class _BudgetTier {
  final String emoji;
  final String title;
  final String range;
  final String desc;
  final double value;
  final Color color;
  const _BudgetTier({
    required this.emoji,
    required this.title,
    required this.range,
    required this.desc,
    required this.value,
    required this.color,
  });
}
