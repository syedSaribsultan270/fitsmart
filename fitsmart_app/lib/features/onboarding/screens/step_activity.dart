import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
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

  static const _levels = [
    _ActivityLevel(
      id: 'sedentary',
      emoji: '🛋️',
      title: 'Couch Potato',
      subtitle: 'Desk job, minimal movement',
      multiplier: '×1.2 TDEE',
      color: AppColors.textTertiary,
    ),
    _ActivityLevel(
      id: 'lightly_active',
      emoji: '🚶',
      title: 'Lightly Active',
      subtitle: '1–3 light workouts/week',
      multiplier: '×1.375 TDEE',
      color: AppColors.macroFiber,
    ),
    _ActivityLevel(
      id: 'moderately_active',
      emoji: '🏃',
      title: 'Moderately Active',
      subtitle: '3–5 workouts/week',
      multiplier: '×1.55 TDEE',
      color: AppColors.cyan,
    ),
    _ActivityLevel(
      id: 'very_active',
      emoji: '🔥',
      title: 'Very Active',
      subtitle: '6–7 intense workouts/week',
      multiplier: '×1.725 TDEE',
      color: AppColors.lime,
    ),
    _ActivityLevel(
      id: 'extremely_active',
      emoji: '⚡',
      title: 'Athlete Mode',
      subtitle: '2× daily training / physical job',
      multiplier: '×1.9 TDEE',
      color: AppColors.coral,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return OnboardingStepBase(
      emoji: '🏃',
      title: 'How Active\nAre You?',
      subtitle: 'Be honest — this sets your calorie baseline. 😅',
      content: Column(
        children: _levels.asMap().entries.map((e) {
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
                      : AppColors.surfaceCard,
                  borderRadius: BorderRadius.circular(AppRadius.lg),
                  border: Border.all(
                    color: isSelected ? level.color : AppColors.surfaceCardBorder,
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
                            : AppColors.bgTertiary,
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
                              color: isSelected ? level.color : AppColors.textPrimary,
                            ),
                          ),
                          Text(
                            level.subtitle,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textTertiary,
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
                            : AppColors.bgTertiary,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        level.multiplier,
                        style: AppTypography.overline.copyWith(
                          color: isSelected ? level.color : AppColors.textTertiary,
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
