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

class StepDreamBody extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const StepDreamBody({super.key, required this.onNext});

  @override
  ConsumerState<StepDreamBody> createState() => _StepDreamBodyState();
}

class _StepDreamBodyState extends ConsumerState<StepDreamBody> {
  String? _selected;

  static List<_BodyType> _bodyTypes(BuildContext context) {
    final colors = context.colors;
    return [
      _BodyType(
        id: 'lean',
        emoji: '\uD83C\uDFC3',
        title: 'Lean',
        subtitle: 'Low body fat, toned but not bulky',
        bf: '8\u201315% BF',
        color: colors.cyan,
      ),
      _BodyType(
        id: 'athletic',
        emoji: '\uD83E\uDD38',
        title: 'Athletic',
        subtitle: 'Muscular, defined, performance-ready',
        bf: '12\u201320% BF',
        color: colors.lime,
      ),
      _BodyType(
        id: 'bulk',
        emoji: '\uD83D\uDCAA',
        title: 'Bulk',
        subtitle: 'Maximum muscle mass, powerlifter build',
        bf: '15\u201325% BF',
        color: colors.coral,
      ),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final bodyTypes = _bodyTypes(context);

    return OnboardingStepBase(
      emoji: '\uD83C\uDFC6',
      title: 'Your Dream\nPhysique',
      subtitle: 'What body type are you working towards?',
      content: Column(
        children: [
          Row(
            children: bodyTypes.asMap().entries.map((e) {
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
                            : context.colors.surfaceCard,
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        border: Border.all(
                          color: isSelected ? bt.color : context.colors.surfaceCardBorder,
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
                                  : context.colors.bgTertiary,
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
                              color: isSelected ? bt.color : context.colors.textPrimary,
                            ),
                            textAlign: TextAlign.center,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            bt.subtitle,
                            style: AppTypography.overline.copyWith(
                              color: context.colors.textTertiary,
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
                                  : context.colors.bgTertiary,
                              borderRadius: BorderRadius.circular(AppRadius.full),
                            ),
                            child: Text(
                              bt.bf,
                              style: AppTypography.overline.copyWith(
                                color: isSelected ? bt.color : context.colors.textTertiary,
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
                color: context.colors.bgTertiary,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: context.colors.surfaceCardBorder),
              ),
              child: Text(
                _selected == 'lean'
                    ? '\uD83D\uDCA1 Great choice! Lean builds prioritize cardio + moderate lifting with a calorie deficit.'
                    : _selected == 'athletic'
                        ? '\uD83D\uDCA1 Athletic builds balance strength training with good nutrition timing.'
                        : '\uD83D\uDCA1 Bulk builds focus on progressive overload with a calorie surplus.',
                style: AppTypography.caption.copyWith(color: context.colors.textSecondary),
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
