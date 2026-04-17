import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_button.dart';
import 'onboarding_flow.dart';

class StepActivity extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const StepActivity({super.key, required this.onNext});

  @override
  ConsumerState<StepActivity> createState() => _StepActivityState();
}

class _StepActivityState extends ConsumerState<StepActivity> {
  String? _selected;

  static List<_ActivityLevel> _levels(BuildContext context) {
    final colors = context.colors;
    return [
      _ActivityLevel(
        id: 'sedentary',
        emoji: '\uD83D\uDECB\uFE0F',
        title: 'Couch Potato',
        subtitle: 'Desk job, minimal movement',
        multiplier: '\u00D71.2 TDEE',
        color: colors.textTertiary,
      ),
      _ActivityLevel(
        id: 'lightly_active',
        emoji: '\uD83D\uDEB6',
        title: 'Lightly Active',
        subtitle: '1\u20133 light workouts/week',
        multiplier: '\u00D71.375 TDEE',
        color: AppColorsExtension.macroFiber,
      ),
      _ActivityLevel(
        id: 'moderately_active',
        emoji: '\uD83C\uDFC3',
        title: 'Moderately Active',
        subtitle: '3\u20135 workouts/week',
        multiplier: '\u00D71.55 TDEE',
        color: colors.cyan,
      ),
      _ActivityLevel(
        id: 'very_active',
        emoji: '\uD83D\uDD25',
        title: 'Very Active',
        subtitle: '6\u20137 intense workouts/week',
        multiplier: '\u00D71.725 TDEE',
        color: colors.lime,
      ),
      _ActivityLevel(
        id: 'extremely_active',
        emoji: '\u26A1',
        title: 'Athlete Mode',
        subtitle: '2\u00D7 daily training / physical job',
        multiplier: '\u00D71.9 TDEE',
        color: colors.coral,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final levels = _levels(context);

    return OnboardingStepBase(
      emoji: '\uD83C\uDFC3',
      title: 'How Active\nAre You?',
      subtitle: 'Be honest \u2014 this sets your calorie baseline. \uD83D\uDE05',
      content: Column(
        children: levels.asMap().entries.map((e) {
          final level = e.value;
          final isSelected = _selected == level.id;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm),
            child: GestureDetector(
              onTap: () {
                HapticFeedback.mediumImpact();
                setState(() => _selected = level.id);
              },
              child: AnimatedContainer(
                duration: 200.ms,
                padding: const EdgeInsets.all(AppSpacing.lg),
                decoration: BoxDecoration(
                  color: isSelected
                      ? level.color.withValues(alpha: 0.1)
                      : context.colors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isSelected ? level.color : context.colors.surfaceCardBorder,
                    width: isSelected ? 1.5 : 1,
                  ),
                  boxShadow: isSelected
                      ? [BoxShadow(color: level.color.withValues(alpha: 0.15), blurRadius: 10)]
                      : null,
                ),
                child: Row(
                  children: [
                    // Emoji in circle
                    AnimatedContainer(
                      duration: 200.ms,
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? level.color.withValues(alpha: 0.15)
                            : context.colors.bgTertiary,
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          level.emoji,
                          style: TextStyle(
                            fontSize: isSelected ? 26 : 22,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            level.title,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isSelected ? level.color : context.colors.textPrimary,
                            ),
                          ),
                          Text(
                            level.subtitle,
                            style: AppTypography.caption.copyWith(
                              color: context.colors.textTertiary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? level.color.withValues(alpha: 0.15)
                            : context.colors.bgTertiary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        level.multiplier,
                        style: AppTypography.overline.copyWith(
                          color: isSelected ? level.color : context.colors.textTertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ).animate(delay: (e.key * 50).ms).fadeIn(duration: 300.ms).slideX(begin: 0.05),
          );
        }).toList(),
      ),
      cta: AppButton(
        label: 'That\'s My Level',
        onPressed: _selected == null
            ? null
            : () {
                ref.read(onboardingProvider.notifier).setActivityLevel(_selected!);
                widget.onNext();
              },
      ),
    );
  }
}

class _ActivityLevel {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final String multiplier;
  final Color color;
  const _ActivityLevel({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.multiplier,
    required this.color,
  });
}
