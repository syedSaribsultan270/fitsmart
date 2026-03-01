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

class StepTargets extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const StepTargets({super.key, required this.onNext});

  @override
  ConsumerState<StepTargets> createState() => _StepTargetsState();
}

class _StepTargetsState extends ConsumerState<StepTargets> {
  double _targetWeightKg = 70;
  String _pace = 'steady';
  int _workoutDays = 4;

  static const _paces = [
    _Pace('slow', '🐢', 'Slow & Steady', '0.25 kg/week', 'Sustainable, easy lifestyle change', AppColors.success),
    _Pace('steady', '🏃', 'Steady', '0.5 kg/week', 'Recommended for most people', AppColors.lime),
    _Pace('aggressive', '🔥', 'Aggressive', '0.75 kg/week', 'Challenging — needs discipline', AppColors.warning),
    _Pace('maximum', '⚡', 'Maximum', '1.0 kg/week', 'Extreme — consult a doctor', AppColors.error),
  ];

  @override
  Widget build(BuildContext context) {
    final data = ref.read(onboardingProvider);
    final currentWeight = data.weightKg ?? 70;
    final diff = (_targetWeightKg - currentWeight).abs();
    final weeksAtPace = _paceWeekMultiplier(_pace) > 0
        ? (diff / _paceWeekMultiplier(_pace)).ceil()
        : 0;

    return OnboardingStepBase(
      emoji: '🎯',
      title: 'Set Your\nTargets',
      subtitle: 'Where are you headed and how fast?',
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Target weight
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: AppColors.surfaceCard,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.surfaceCardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TARGET WEIGHT', style: AppTypography.overline.copyWith(color: AppColors.textTertiary)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      '${_targetWeightKg.toStringAsFixed(1)} kg',
                      style: AppTypography.h2.copyWith(
                        color: AppColors.lime,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    if (currentWeight > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.bgTertiary,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          _targetWeightKg < currentWeight
                              ? '−${diff.toStringAsFixed(1)} kg'
                              : _targetWeightKg > currentWeight
                                  ? '+${diff.toStringAsFixed(1)} kg'
                                  : 'maintain',
                          style: AppTypography.caption.copyWith(
                            color: _targetWeightKg < currentWeight
                                ? AppColors.coral
                                : _targetWeightKg > currentWeight
                                    ? AppColors.cyan
                                    : AppColors.success,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
                Slider(
                  value: _targetWeightKg,
                  min: 30,
                  max: 250,
                  divisions: 220,
                  onChanged: (v) {
                    HapticFeedback.selectionClick();
                    setState(() => _targetWeightKg = v);
                  },
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('30 kg', style: AppTypography.overline),
                    Text('250 kg', style: AppTypography.overline),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          // Pace selector
          Text('PACE', style: AppTypography.overline.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: AppSpacing.md),
          ...(_paces.asMap().entries.map((e) {
            final p = e.value;
            final isSelected = _pace == p.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _pace = p.id);
                },
                child: AnimatedContainer(
                  duration: 200.ms,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: isSelected ? p.color.withValues(alpha: 0.08) : AppColors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isSelected ? p.color : AppColors.surfaceCardBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    children: [
                      Text(p.emoji, style: const TextStyle(fontSize: 22)),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              '${p.title} · ${p.rate}',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isSelected ? p.color : AppColors.textPrimary,
                              ),
                            ),
                            Text(
                              p.desc,
                              style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: (e.key * 40).ms).fadeIn(duration: 250.ms),
            );
          })),
          const SizedBox(height: AppSpacing.sectionGap),

          // Workout days
          Text('WORKOUT DAYS PER WEEK', style: AppTypography.overline.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(7, (i) {
              final day = i + 1;
              final isSelected = _workoutDays == day;
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() => _workoutDays = day);
                },
                child: AnimatedContainer(
                  duration: 200.ms,
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: isSelected ? AppColors.lime : AppColors.surfaceCard,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? AppColors.lime : AppColors.surfaceCardBorder,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: AppColors.lime.withValues(alpha: 0.3), blurRadius: 8)]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected ? AppColors.textInverse : AppColors.textSecondary,
                      ),
                    ),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          Center(
            child: Text(
              '$_workoutDays day${_workoutDays > 1 ? 's' : ''} per week',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary),
            ),
          ),

          if (weeksAtPace > 0) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.limeGlow,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.lime.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('⏱️', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'At your pace, you could reach your goal in ~$weeksAtPace weeks.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.lime,
                      ),
                    ),
                  ),
                ],
              ),
            ).animate().fadeIn(duration: 300.ms),
          ],
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
      cta: AppButton(
        label: 'Lock In My Targets',
        onPressed: () {
          final notifier = ref.read(onboardingProvider.notifier);
          notifier.setTargetWeight(_targetWeightKg);
          notifier.setPace(_pace);
          notifier.setWorkoutDays(_workoutDays);
          widget.onNext();
        },
      ),
    );
  }

  double _paceWeekMultiplier(String pace) {
    switch (pace) {
      case 'slow': return 0.25;
      case 'steady': return 0.5;
      case 'aggressive': return 0.75;
      case 'maximum': return 1.0;
      default: return 0.5;
    }
  }
}

class _Pace {
  final String id;
  final String emoji;
  final String title;
  final String rate;
  final String desc;
  final Color color;
  const _Pace(this.id, this.emoji, this.title, this.rate, this.desc, this.color);
}
