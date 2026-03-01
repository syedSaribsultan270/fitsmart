import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/utils/tdee_calculator.dart';

class StepAiSetup extends ConsumerStatefulWidget {
  final VoidCallback onComplete;
  final bool isSubmitting;
  const StepAiSetup({super.key, required this.onComplete, this.isSubmitting = false});

  @override
  ConsumerState<StepAiSetup> createState() => _StepAiSetupState();
}

class _StepAiSetupState extends ConsumerState<StepAiSetup>
    with SingleTickerProviderStateMixin {
  bool _done = false;
  TdeeResult? _result;
  int _phase = 0; // 0=loading, 1=reveal

  final _phases = [
    'Analyzing your profile...',
    'Computing your TDEE...',
    'Calibrating macro targets...',
    'Personalizing your plan...',
    'Ready! 🎉',
  ];

  @override
  void initState() {
    super.initState();
    _runSetup();
  }

  Future<void> _runSetup() async {
    final notifier = ref.read(onboardingProvider.notifier);
    final result = notifier.computeTargets();

    // Simulate AI analysis phases
    for (int i = 0; i < _phases.length - 1; i++) {
      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) setState(() => _phase = i + 1);
    }

    await Future.delayed(const Duration(milliseconds: 400));
    if (mounted) {
      setState(() {
        _result = result;
        _done = true;
        _phase = _phases.length - 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top;
    final bottomPad = MediaQuery.of(context).padding.bottom;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Background glow
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: Container(
              height: 300,
              decoration: BoxDecoration(
                gradient: RadialGradient(
                  center: Alignment.topCenter,
                  radius: 1.2,
                  colors: [
                    AppColors.lime.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
              child: Column(
                children: [
                  SizedBox(height: topPad + 20),
                  const Spacer(),

                  // Animated brain/AI icon
                  _AiPulseWidget(done: _done),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Phase text
                  AnimatedSwitcher(
                    duration: const Duration(milliseconds: 400),
                    child: Text(
                      _phases[_phase.clamp(0, _phases.length - 1)],
                      key: ValueKey(_phase),
                      style: AppTypography.h3.copyWith(
                        color: _done ? AppColors.lime : AppColors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const Spacer(),

                  // Results reveal
                  if (_done && _result != null) ...[
                    _ResultsReveal(result: _result!),
                    const SizedBox(height: AppSpacing.sectionGap),

                    // XP earned badge
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                      decoration: BoxDecoration(
                        color: AppColors.limeGlow,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                        border: Border.all(
                          color: AppColors.lime.withValues(alpha: 0.3),
                        ),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Text('⚡', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 8),
                          Text(
                            '+100 XP  Welcome bonus!',
                            style: AppTypography.bodyMedium.copyWith(
                              color: AppColors.lime,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ).animate().scale(duration: 500.ms, curve: Curves.elasticOut).fadeIn(),

                    const SizedBox(height: AppSpacing.sectionGap),

                    AppButton(
                      label: widget.isSubmitting
                          ? 'Saving your profile…'
                          : 'Unlock My Dashboard 🚀',
                      isLoading: widget.isSubmitting,
                      onPressed: widget.isSubmitting ? null : widget.onComplete,
                    ).animate(delay: 300.ms).slideY(begin: 0.2, duration: 400.ms).fadeIn(),
                  ],

                  if (!_done) ...[
                    // Progress dots
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(4, (i) {
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          width: i == _phase % 4 ? 20 : 8,
                          height: 8,
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          decoration: BoxDecoration(
                            color: i == _phase % 4
                                ? AppColors.lime
                                : AppColors.surfaceCardBorder,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                        );
                      }),
                    ),
                  ],

                  SizedBox(height: bottomPad + AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _AiPulseWidget extends StatefulWidget {
  final bool done;
  const _AiPulseWidget({required this.done});

  @override
  State<_AiPulseWidget> createState() => _AiPulseWidgetState();
}

class _AiPulseWidgetState extends State<_AiPulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.done) {
      return const Text('🎉', style: TextStyle(fontSize: 80))
          .animate()
          .scale(duration: 600.ms, curve: Curves.elasticOut)
          .fadeIn();
    }
    return AnimatedBuilder(
      animation: _controller,
      builder: (_, __) {
        final pulse = _controller.value;
        return Stack(
          alignment: Alignment.center,
          children: [
            // Outer pulse
            Container(
              width: 120 + pulse * 20,
              height: 120 + pulse * 20,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lime.withValues(alpha: 0.05 * pulse),
              ),
            ),
            // Middle pulse
            Container(
              width: 100 + pulse * 10,
              height: 100 + pulse * 10,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.lime.withValues(alpha: 0.08 * pulse),
              ),
            ),
            // Inner circle
            Container(
              width: 88,
              height: 88,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.bgTertiary,
                border: Border.all(
                  color: AppColors.lime.withValues(alpha: 0.3 + pulse * 0.4),
                  width: 1.5,
                ),
              ),
              child: const Center(
                child: Text('🧠', style: TextStyle(fontSize: 40)),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _ResultsReveal extends StatelessWidget {
  final TdeeResult result;
  const _ResultsReveal({required this.result});

  @override
  Widget build(BuildContext context) {
    final stats = [
      _Stat('🔥', 'Daily Calories', '${result.targetCalories.toStringAsFixed(0)} kcal', AppColors.warning),
      _Stat('💪', 'Protein', '${result.proteinG.toStringAsFixed(0)}g', AppColors.cyan),
      _Stat('⚡', 'Carbs', '${result.carbsG.toStringAsFixed(0)}g', AppColors.lime),
      _Stat('🥑', 'Fat', '${result.fatG.toStringAsFixed(0)}g', AppColors.coral),
    ];

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppColors.lime.withValues(alpha: 0.3)),
        boxShadow: [
          BoxShadow(
            color: AppColors.lime.withValues(alpha: 0.08),
            blurRadius: 20,
            spreadRadius: 0,
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Your Daily Targets',
            style: AppTypography.h3.copyWith(fontWeight: FontWeight.w700),
          ),
          Text(
            'Personalized for your goals',
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: stats.asMap().entries.map((e) {
              final s = e.value;
              return Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: s.color.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(color: s.color.withValues(alpha: 0.2)),
                ),
                child: Row(
                  children: [
                    Text(s.emoji, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            s.value,
                            style: AppTypography.bodyMedium.copyWith(
                              color: s.color,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          Text(
                            s.label,
                            style: AppTypography.overline.copyWith(
                              color: AppColors.textTertiary,
                              fontSize: 9,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ).animate(delay: (e.key * 100).ms).slideY(begin: 0.1, duration: 400.ms).fadeIn();
            }).toList(),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 500.ms).slideY(begin: 0.05);
  }
}

class _Stat {
  final String emoji;
  final String label;
  final String value;
  final Color color;
  const _Stat(this.emoji, this.label, this.value, this.color);
}
