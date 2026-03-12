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

class StepMission extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const StepMission({super.key, required this.onNext});

  @override
  ConsumerState<StepMission> createState() => _StepMissionState();
}

class _StepMissionState extends ConsumerState<StepMission> {
  String? _selected;

  static List<_GoalOption> _goals(BuildContext context) {
    final colors = context.colors;
    return [
      _GoalOption('lose_fat', '\uD83D\uDD25', 'Burn Fat', 'Lean & mean', colors.coral),
      _GoalOption('gain_muscle', '\uD83D\uDCAA', 'Build Muscle', 'Get swole', colors.cyan),
      _GoalOption('recomp', '\u26A1', 'Do Both', 'Body recomposition', colors.lime),
      _GoalOption('athletic', '\uD83C\uDFC6', 'Athletic Performance', 'Fast & strong', colors.warning),
      _GoalOption('maintain', '\uD83C\uDFAF', 'Maintain Weight', 'Stay perfect', AppColorsExtension.macroFiber),
      _GoalOption('healthy', '\u2764\uFE0F', 'Just Stay Healthy', 'Feel amazing', colors.success),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final goals = _goals(context);

    return OnboardingStepBase(
      emoji: '\uD83C\uDFAF',
      title: 'Choose Your\nMission',
      subtitle: 'What brings you here? Pick your primary goal.',
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      content: GridView.builder(
        itemCount: goals.length,
        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
          crossAxisCount: 2,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12,
          childAspectRatio: 1.1,
        ),
        itemBuilder: (_, i) {
          final g = goals[i];
          final isSelected = _selected == g.id;
          return _GoalCard(
            option: g,
            isSelected: isSelected,
            onTap: () {
              HapticFeedback.mediumImpact();
              setState(() => _selected = g.id);
            },
          ).animate(delay: (i * 60).ms).fadeIn(duration: 300.ms).slideY(begin: 0.05);
        },
      ),
      cta: AppButton(
        label: 'Lock In My Mission',
        onPressed: _selected == null
            ? null
            : () {
                ref.read(onboardingProvider.notifier).setGoal(_selected!);
                widget.onNext();
              },
      ),
    );
  }
}

class _GoalOption {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final Color color;
  const _GoalOption(this.id, this.emoji, this.title, this.subtitle, this.color);
}

class _GoalCard extends StatelessWidget {
  final _GoalOption option;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalCard({
    required this.option,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: 200.ms,
        decoration: BoxDecoration(
          color: isSelected
              ? option.color.withValues(alpha: 0.12)
              : context.colors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: isSelected ? option.color : context.colors.surfaceCardBorder,
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: option.color.withValues(alpha: 0.2),
                    blurRadius: 12,
                    spreadRadius: 0,
                  )
                ]
              : null,
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(option.emoji, style: const TextStyle(fontSize: 28)),
                  if (isSelected)
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: option.color,
                        shape: BoxShape.circle,
                      ),
                      child: Icon(Icons.check, size: 12, color: context.colors.textInverse),
                    ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    option.title,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                      color: isSelected ? option.color : context.colors.textPrimary,
                    ),
                  ),
                  Text(
                    option.subtitle,
                    style: AppTypography.caption.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
