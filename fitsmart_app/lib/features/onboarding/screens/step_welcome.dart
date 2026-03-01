import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';

class StepWelcome extends StatelessWidget {
  final VoidCallback onNext;
  const StepWelcome({super.key, required this.onNext});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Background radial glow
          Positioned(
            top: -100,
            left: -100,
            child: Container(
              width: 400,
              height: 400,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.lime.withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          Positioned(
            bottom: -80,
            right: -80,
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.cyan.withValues(alpha: 0.06),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.pagePadding,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Spacer(flex: 2),

                  // Animated mascot / icon area
                  Center(
                    child: _AnimatedLogo(),
                  ),

                  const SizedBox(height: 40),

                  // Title
                  Text(
                    'FitSmart\nAI',
                    style: AppTypography.display.copyWith(
                      height: 1.05,
                      foreground: Paint()
                        ..shader = const LinearGradient(
                          colors: [AppColors.lime, AppColors.cyan],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ).createShader(
                          const Rect.fromLTWH(0, 0, 300, 80),
                        ),
                    ),
                  )
                      .animate()
                      .slideX(
                        begin: -0.15,
                        duration: 600.ms,
                        curve: Curves.easeOutCubic,
                      )
                      .fadeIn(duration: 600.ms),

                  const SizedBox(height: AppSpacing.md),

                  Text(
                    'Your AI-powered fitness & nutrition coach. Built for results. Designed for you.',
                    style: AppTypography.h3.copyWith(
                      color: AppColors.textSecondary,
                      fontWeight: FontWeight.w400,
                    ),
                  )
                      .animate(delay: 200.ms)
                      .slideX(
                        begin: -0.1,
                        duration: 500.ms,
                        curve: Curves.easeOut,
                      )
                      .fadeIn(duration: 500.ms),

                  const Spacer(flex: 1),

                  // Feature highlights
                  ..._features
                      .asMap()
                      .entries
                      .map(
                        (e) => Padding(
                          padding: const EdgeInsets.only(
                            bottom: AppSpacing.md,
                          ),
                          child: _FeatureRow(
                            icon: e.value['icon']!,
                            text: e.value['text']!,
                          )
                              .animate(delay: (300 + e.key * 100).ms)
                              .slideX(begin: 0.1, duration: 400.ms)
                              .fadeIn(duration: 400.ms),
                        ),
                      ),

                  const Spacer(flex: 1),

                  AppButton(
                    label: 'Begin Your Journey',
                    onPressed: onNext,
                  )
                      .animate(delay: 700.ms)
                      .slideY(begin: 0.3, duration: 400.ms, curve: Curves.easeOut)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: AppSpacing.lg),

                  Center(
                    child: Text(
                      'Takes 3 minutes • Free forever',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    ),
                  )
                      .animate(delay: 800.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: AppSpacing.xl),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  static const _features = [
    {'icon': '📸', 'text': 'AI meal analysis from photos'},
    {'icon': '💪', 'text': 'Personalized workout & meal plans'},
    {'icon': '🏆', 'text': 'Gamified progress tracking'},
  ];
}

class _AnimatedLogo extends StatefulWidget {
  @override
  State<_AnimatedLogo> createState() => _AnimatedLogoState();
}

class _AnimatedLogoState extends State<_AnimatedLogo>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _floatAnim;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);
    _floatAnim = Tween<double>(begin: -8, end: 8).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _floatAnim,
      builder: (_, child) => Transform.translate(
        offset: Offset(0, _floatAnim.value),
        child: child,
      ),
      child: Container(
        width: 120,
        height: 120,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [AppColors.limeGlow, Colors.transparent],
          ),
          border: Border.all(
            color: AppColors.lime.withValues(alpha: 0.3),
            width: 1.5,
          ),
        ),
        child: const Center(
          child: Text('⚡', style: TextStyle(fontSize: 56)),
        ),
      )
          .animate()
          .scale(duration: 600.ms, curve: Curves.elasticOut)
          .fadeIn(duration: 400.ms),
    );
  }
}

class _FeatureRow extends StatelessWidget {
  final String icon;
  final String text;
  const _FeatureRow({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.bgTertiary,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(color: AppColors.surfaceCardBorder),
          ),
          child: Center(child: Text(icon, style: const TextStyle(fontSize: 18))),
        ),
        const SizedBox(width: AppSpacing.md),
        Text(
          text,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
