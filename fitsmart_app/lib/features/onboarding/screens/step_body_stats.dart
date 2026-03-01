import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import 'onboarding_flow.dart';

class StepBodyStats extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const StepBodyStats({super.key, required this.onNext});

  @override
  ConsumerState<StepBodyStats> createState() => _StepBodyStatsState();
}

class _StepBodyStatsState extends ConsumerState<StepBodyStats> {
  double _heightCm = 170;
  double _weightKg = 70;
  bool _heightInFt = false;
  bool _weightInLbs = false;

  String get _heightLabel {
    if (_heightInFt) {
      final feet = (_heightCm / 30.48).floor();
      final inches = ((_heightCm / 30.48 - feet) * 12).round();
      return '$feet\' $inches"';
    }
    return '${_heightCm.toStringAsFixed(0)} cm';
  }

  String get _weightLabel {
    if (_weightInLbs) {
      return '${(_weightKg * 2.20462).toStringAsFixed(1)} lbs';
    }
    return '${_weightKg.toStringAsFixed(1)} kg';
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepBase(
      emoji: '📏',
      title: 'Your Current\nStats',
      subtitle: 'Used to calculate your personalized calorie targets.',
      content: Column(
        children: [
          // Height
          _StatSection(
            label: 'HEIGHT',
            displayValue: _heightLabel,
            unit1: 'cm',
            unit2: 'ft',
            useSecondUnit: _heightInFt,
            onUnitToggle: () => setState(() => _heightInFt = !_heightInFt),
            slider: Slider(
              value: _heightCm,
              min: 120,
              max: 230,
              divisions: 110,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _heightCm = v);
              },
            ),
            minLabel: '120cm',
            maxLabel: '230cm',
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          // Weight
          _StatSection(
            label: 'CURRENT WEIGHT',
            displayValue: _weightLabel,
            unit1: 'kg',
            unit2: 'lbs',
            useSecondUnit: _weightInLbs,
            onUnitToggle: () => setState(() => _weightInLbs = !_weightInLbs),
            slider: Slider(
              value: _weightKg,
              min: 30,
              max: 250,
              divisions: 220,
              onChanged: (v) {
                HapticFeedback.selectionClick();
                setState(() => _weightKg = v);
              },
            ),
            minLabel: '30kg',
            maxLabel: '250kg',
          ),
        ],
      ),
      cta: AppButton(
        label: 'These Are My Stats',
        onPressed: () {
          ref.read(onboardingProvider.notifier)
            ..setHeight(_heightCm)
            ..setWeight(_weightKg);
          widget.onNext();
        },
      ),
    );
  }
}

class _StatSection extends StatelessWidget {
  final String label;
  final String displayValue;
  final String unit1;
  final String unit2;
  final bool useSecondUnit;
  final VoidCallback onUnitToggle;
  final Widget slider;
  final String minLabel;
  final String maxLabel;

  const _StatSection({
    required this.label,
    required this.displayValue,
    required this.unit1,
    required this.unit2,
    required this.useSecondUnit,
    required this.onUnitToggle,
    required this.slider,
    required this.minLabel,
    required this.maxLabel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.surfaceCardBorder),
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                label,
                style: AppTypography.overline.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              // Unit toggle
              GestureDetector(
                onTap: onUnitToggle,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.bgTertiary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: AppColors.surfaceCardBorder),
                  ),
                  child: Row(
                    children: [
                      Text(
                        unit1,
                        style: AppTypography.overline.copyWith(
                          color: !useSecondUnit ? AppColors.lime : AppColors.textTertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(' / ', style: AppTypography.overline.copyWith(color: AppColors.textTertiary)),
                      Text(
                        unit2,
                        style: AppTypography.overline.copyWith(
                          color: useSecondUnit ? AppColors.lime : AppColors.textTertiary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            displayValue,
            style: AppTypography.h1.copyWith(
              color: AppColors.lime,
              fontWeight: FontWeight.w800,
            ),
          ),
          slider,
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(minLabel, style: AppTypography.overline),
              Text(maxLabel, style: AppTypography.overline),
            ],
          ),
        ],
      ),
    );
  }
}
