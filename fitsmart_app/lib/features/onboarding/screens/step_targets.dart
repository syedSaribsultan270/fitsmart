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

  static List<_Pace> _paces(BuildContext context) {
    final colors = context.colors;
    return [
      _Pace('slow', '\uD83D\uDC22', 'Slow & Steady', '0.25 kg/week', 'Sustainable, easy lifestyle change', colors.success),
      _Pace('steady', '\uD83C\uDFC3', 'Steady', '0.5 kg/week', 'Recommended for most people', colors.lime),
      _Pace('aggressive', '\uD83D\uDD25', 'Aggressive', '0.75 kg/week', 'Challenging \u2014 needs discipline', colors.warning),
      _Pace('maximum', '\u26A1', 'Maximum', '1.0 kg/week', 'Extreme \u2014 consult a doctor', colors.error),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final paces = _paces(context);
    final data = ref.read(onboardingProvider);
    final currentWeight = data.weightKg ?? 70;
    final diff = (_targetWeightKg - currentWeight).abs();
    final weeksAtPace = _paceWeekMultiplier(_pace) > 0
        ? (diff / _paceWeekMultiplier(_pace)).ceil()
        : 0;

    return OnboardingStepBase(
      emoji: '\uD83C\uDFAF',
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
              color: context.colors.surfaceCard,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: context.colors.surfaceCardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('TARGET WEIGHT', style: AppTypography.overline.copyWith(color: context.colors.textTertiary)),
                const SizedBox(height: AppSpacing.sm),
                Row(
                  children: [
                    Text(
                      '${_targetWeightKg.toStringAsFixed(1)} kg',
                      style: AppTypography.h2.copyWith(
                        color: context.colors.lime,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const Spacer(),
                    if (currentWeight > 0) ...[
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: context.colors.bgTertiary,
                          borderRadius: BorderRadius.circular(AppRadius.full),
                        ),
                        child: Text(
                          _targetWeightKg < currentWeight
                              ? '\u2212${diff.toStringAsFixed(1)} kg'
                              : _targetWeightKg > currentWeight
                                  ? '+${diff.toStringAsFixed(1)} kg'
                                  : 'maintain',
                          style: AppTypography.caption.copyWith(
                            color: _targetWeightKg < currentWeight
                                ? context.colors.coral
                                : _targetWeightKg > currentWeight
                                    ? context.colors.cyan
                                    : context.colors.success,
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
          Text('PACE', style: AppTypography.overline.copyWith(color: context.colors.textTertiary)),
          const SizedBox(height: AppSpacing.md),
          ...(paces.asMap().entries.map((e) {
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
                    color: isSelected ? p.color.withValues(alpha: 0.08) : context.colors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(
                      color: isSelected ? p.color : context.colors.surfaceCardBorder,
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
                              '${p.title} \u00B7 ${p.rate}',
                              style: AppTypography.bodyMedium.copyWith(
                                fontWeight: FontWeight.w700,
                                color: isSelected ? p.color : context.colors.textPrimary,
                              ),
                            ),
                            Text(
                              p.desc,
                              style: AppTypography.caption.copyWith(color: context.colors.textTertiary),
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
          Text('WORKOUT DAYS PER WEEK', style: AppTypography.overline.copyWith(color: context.colors.textTertiary)),
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
                    color: isSelected ? context.colors.lime : context.colors.surfaceCard,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: isSelected ? context.colors.lime : context.colors.surfaceCardBorder,
                    ),
                    boxShadow: isSelected
                        ? [BoxShadow(color: context.colors.lime.withValues(alpha: 0.3), blurRadius: 8)]
                        : null,
                  ),
                  child: Center(
                    child: Text(
                      '$day',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                        color: isSelected ? context.colors.textInverse : context.colors.textSecondary,
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
              style: AppTypography.bodyMedium.copyWith(color: context.colors.textSecondary),
            ),
          ),

          if (weeksAtPace > 0) ...[
            const SizedBox(height: AppSpacing.sectionGap),
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: context.colors.limeGlow,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: context.colors.lime.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('\u23F1\uFE0F', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      'At your pace, you could reach your goal in ~$weeksAtPace weeks.',
                      style: AppTypography.bodyMedium.copyWith(
                        color: context.colors.lime,
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
