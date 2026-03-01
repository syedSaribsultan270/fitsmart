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

class StepDreamBody extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const StepDreamBody({super.key, required this.onNext});

  @override
  ConsumerState<StepDreamBody> createState() => _StepDreamBodyState();
}

class _StepDreamBodyState extends ConsumerState<StepDreamBody> {
  String? _selected;

  static const _bodyTypes = [
    _BodyType(
      id: 'lean',
      emoji: '🏃',
      title: 'Lean',
      subtitle: 'Low body fat, toned but not bulky',
      bf: '8–15% BF',
      color: AppColors.cyan,
    ),
    _BodyType(
      id: 'athletic',
      emoji: '🤸',
      title: 'Athletic',
      subtitle: 'Muscular, defined, performance-ready',
      bf: '12–20% BF',
      color: AppColors.lime,
    ),
    _BodyType(
      id: 'bulk',
      emoji: '💪',
      title: 'Bulk',
      subtitle: 'Maximum muscle mass, powerlifter build',
      bf: '15–25% BF',
      color: AppColors.coral,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return OnboardingStepBase(
      emoji: '🏆',
      title: 'Your Dream\nPhysique',
      subtitle: 'What body type are you working towards?',
      content: Column(
        children: [
          Row(
            children: _bodyTypes.asMap().entries.map((e) {
              final bt = e.value;
              final isSelected = _selected == bt.id;
              return Expanded(
                child: Padding(
                  padding: EdgeInsets.only(right: e.key < 2 ? 10 : 0),
                  child: GestureDetector(
                    onTap: () {
                      HapticFeedback.mediumImpact();
                      setState(() => _selected = bt.id);
                    },
                    child: AnimatedContainer(
                      duration: 200.ms,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? bt.color.withValues(alpha: 0.1)
                            : AppColors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isSelected ? bt.color : AppColors.surfaceCardBorder,
                          width: isSelected ? 2 : 1,
                        ),
                        boxShadow: isSelected
                            ? [BoxShadow(color: bt.color.withValues(alpha: 0.2), blurRadius: 14)]
                            : null,
                      ),
                      child: Column(
                        children: [
                          // Body visual
                          AnimatedContainer(
                            duration: 200.ms,
                            width: isSelected ? 64 : 56,
                            height: isSelected ? 64 : 56,
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? bt.color.withValues(alpha: 0.15)
                                  : AppColors.bgTertiary,
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                bt.emoji,
                                style: TextStyle(fontSize: isSelected ? 30 : 26),
                              ),
                            ),
                          ),
                          const SizedBox(height: AppSpacing.md),
                          Text(
                            bt.title,
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                              color: isSelected ? bt.color : AppColors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bt.subtitle,
                            style: AppTypography.overline.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 9,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 8),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? bt.color.withValues(alpha: 0.15)
                                  : AppColors.bgTertiary,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              bt.bf,
                              style: AppTypography.overline.copyWith(
                                color: isSelected ? bt.color : AppColors.textTertiary,
                                fontSize: 9,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  )
                      .animate(delay: (e.key * 80).ms)
                      .scale(begin: const Offset(0.95, 0.95), duration: 300.ms, curve: Curves.easeOut)
                      .fadeIn(duration: 300.ms),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          if (_selected != null)
            Container(
              padding: const EdgeInsets.all(AppSpacing.cardPadding),
              decoration: BoxDecoration(
                color: AppColors.bgTertiary,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.surfaceCardBorder),
              ),
              child: Text(
                _selected == 'lean'
                    ? '💡 Great choice! Lean builds prioritize cardio + moderate lifting with a calorie deficit.'
                    : _selected == 'athletic'
                        ? '💡 Athletic builds balance strength training with good nutrition timing.'
                        : '💡 Bulk builds focus on progressive overload with a calorie surplus.',
                style: AppTypography.caption.copyWith(color: AppColors.textSecondary),
              ),
            ).animate().fadeIn(duration: 300.ms),
        ],
      ),
      cta: AppButton(
        label: 'This Is My Goal',
        onPressed: _selected == null
            ? null
            : () {
                ref.read(onboardingProvider.notifier).setTargetBodyType(_selected!);
                widget.onNext();
              },
      ),
    );
  }
}

class _BodyType {
  final String id;
  final String emoji;
  final String title;
  final String subtitle;
  final String bf;
  final Color color;
  const _BodyType({
    required this.id,
    required this.emoji,
    required this.title,
    required this.subtitle,
    required this.bf,
    required this.color,
  });
}
