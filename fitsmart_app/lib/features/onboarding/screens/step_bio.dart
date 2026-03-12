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

class StepBio extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const StepBio({super.key, required this.onNext});

  @override
  ConsumerState<StepBio> createState() => _StepBioState();
}

class _StepBioState extends ConsumerState<StepBio> {
  String? _gender;
  int _age = 25;

  static const _genders = [
    ('male', '\u2642\uFE0F', 'Male'),
    ('female', '\u2640\uFE0F', 'Female'),
    ('non_binary', '\u26A7\uFE0F', 'Non-binary'),
    ('prefer_not', '\uD83D\uDE48', 'Prefer not to say'),
  ];

  @override
  Widget build(BuildContext context) {
    return OnboardingStepBase(
      emoji: '\uD83D\uDC64',
      title: 'Tell Us About\nYourself',
      subtitle: 'Helps us personalize your plan accurately.',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'GENDER',
            style: AppTypography.overline.copyWith(color: context.colors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: _genders.asMap().entries.map((e) {
              final (id, emoji, label) = e.value;
              final isSelected = _gender == id;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: e.key < 3 ? 8 : 0),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.selectionClick();
                      setState(() => _gender = id);
                    },
                    child: AnimatedContainer(
                      duration: 200.ms,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      decoration: BoxDecoration(
                        color: isSelected ? context.colors.limeGlow : context.colors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppRadius.md),
                        border: Border.all(
                          color: isSelected ? context.colors.lime : context.colors.surfaceCardBorder,
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(emoji, style: const TextStyle(fontSize: 22)),
                          const SizedBox(height: 4),
                          Text(
                            label,
                            style: AppTypography.overline.copyWith(
                              color: isSelected ? context.colors.lime : context.colors.textTertiary,
                              fontSize: 9,
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
          const SizedBox(height: AppSpacing.sectionGap),
          Text(
            'AGE',
            style: AppTypography.overline.copyWith(color: context.colors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.md),
          _AgeDrumPicker(
            value: _age,
            onChanged: (v) => setState(() => _age = v),
          ),
        ],
      ),
      cta: AppButton(
        label: 'Continue',
        onPressed: _gender == null
            ? null
            : () {
                ref.read(onboardingProvider.notifier)
                  ..setGender(_gender!)
                  ..setAge(_age);
                widget.onNext();
              },
      ),
    );
  }
}

class _AgeDrumPicker extends StatefulWidget {
  final int value;
  final ValueChanged<int> onChanged;
  const _AgeDrumPicker({required this.value, required this.onChanged});

  @override
  State<_AgeDrumPicker> createState() => _AgeDrumPickerState();
}

class _AgeDrumPickerState extends State<_AgeDrumPicker> {
  late FixedExtentScrollController _controller;

  @override
  void initState() {
    super.initState();
    _controller = FixedExtentScrollController(
      initialItem: widget.value - 10,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 140,
      decoration: BoxDecoration(
        color: context.colors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.surfaceCardBorder),
      ),
      child: Stack(
        children: [
          // Center highlight
          Center(
            child: Container(
              height: 44,
              margin: const EdgeInsets.symmetric(horizontal: 16),
              decoration: BoxDecoration(
                color: context.colors.limeGlow,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(
                  color: context.colors.lime.withValues(alpha: 0.3),
                ),
              ),
            ),
          ),
          // Drum scroll
          ListWheelScrollView.useDelegate(
            controller: _controller,
            itemExtent: 44,
            physics: const FixedExtentScrollPhysics(),
            perspective: 0.003,
            diameterRatio: 2.5,
            onSelectedItemChanged: (i) {
              HapticFeedback.selectionClick();
              widget.onChanged(i + 10);
            },
            childDelegate: ListWheelChildBuilderDelegate(
              childCount: 91, // 10 to 100
              builder: (_, i) {
                final age = i + 10;
                final isSelected = age == widget.value;
                return Center(
                  child: Text(
                    '$age years',
                    style: isSelected
                        ? AppTypography.h3.copyWith(
                            color: context.colors.lime,
                            fontWeight: FontWeight.w800,
                          )
                        : AppTypography.body.copyWith(
                            color: context.colors.textTertiary,
                          ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
