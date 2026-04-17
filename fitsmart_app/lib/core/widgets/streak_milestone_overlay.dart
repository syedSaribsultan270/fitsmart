import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Full-screen celebration overlay shown when the user hits a streak milestone.
///
/// Usage: show as a dialog — it is self-dismissing via the tap anywhere gesture
/// or the close button. The caller is responsible for resetting the provider.
class StreakMilestoneOverlay extends StatefulWidget {
  final int days;
  final VoidCallback onDismiss;

  const StreakMilestoneOverlay({
    super.key,
    required this.days,
    required this.onDismiss,
  });

  @override
  State<StreakMilestoneOverlay> createState() => _StreakMilestoneOverlayState();
}

class _StreakMilestoneOverlayState extends State<StreakMilestoneOverlay> {
  @override
  void initState() {
    super.initState();
    // Heavy haptic when overlay appears
    HapticFeedback.heavyImpact();
    // Auto-dismiss after 4.5 seconds
    Future.delayed(const Duration(milliseconds: 4500), _dismiss);
  }

  void _dismiss() {
    if (mounted) {
      widget.onDismiss();
      Navigator.of(context).pop();
    }
  }

  String get _headline {
    if (widget.days >= 90) return 'LEGENDARY';
    if (widget.days >= 60) return 'UNSTOPPABLE';
    if (widget.days >= 30) return 'ON FIRE';
    if (widget.days >= 14) return 'INCREDIBLE';
    if (widget.days >= 7) return 'BLAZING';
    return 'STREAK!';
  }

  String get _subtitle {
    if (widget.days >= 90) return 'You are in the top 1%.\nThis is what legends are made of.';
    if (widget.days >= 60) return 'Two months of pure discipline.\nYour body is transforming.';
    if (widget.days >= 30) return 'A full month of showing up.\nHabit unlocked. Keep going.';
    if (widget.days >= 14) return 'Two weeks of consistency.\nYou are building something real.';
    if (widget.days >= 7) return 'One week of showing up every day.\nMomentum is yours.';
    return 'You are building a habit.\nEvery day counts.';
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _dismiss,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
          child: Container(
            color: AppColors.bgPrimary.withValues(alpha: 0.85),
            child: SafeArea(
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    // Fire emoji burst
                    _FireEmoji(days: widget.days),
                    const SizedBox(height: AppSpacing.lg),

                    // Day count hero
                    _DayCounter(days: widget.days),
                    const SizedBox(height: AppSpacing.sm),

                    // Headline
                    Text(
                      _headline,
                      style: AppTypography.display.copyWith(
                        color: AppColors.lime,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -1,
                      ),
                    )
                        .animate(delay: 400.ms)
                        .fadeIn(duration: 500.ms)
                        .slideY(begin: 0.3, curve: Curves.easeOutCubic),
                    const SizedBox(height: AppSpacing.md),

                    // Subtitle
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.xl,
                      ),
                      child: Text(
                        _subtitle,
                        textAlign: TextAlign.center,
                        style: AppTypography.body.copyWith(
                          color: AppColors.textSecondary,
                          height: 1.6,
                        ),
                      ),
                    )
                        .animate(delay: 600.ms)
                        .fadeIn(duration: 500.ms),
                    const SizedBox(height: AppSpacing.xl * 2),

                    // Tap to dismiss hint
                    Text(
                      'Tap anywhere to continue',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.textTertiary,
                      ),
                    )
                        .animate(delay: 1200.ms)
                        .fadeIn(duration: 600.ms),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Animated fire emoji that pulses and scales in.
class _FireEmoji extends StatelessWidget {
  final int days;
  const _FireEmoji({required this.days});

  @override
  Widget build(BuildContext context) {
    final size = days >= 30 ? 96.0 : days >= 14 ? 80.0 : 72.0;
    return Text(
      '🔥',
      style: TextStyle(fontSize: size),
    )
        .animate()
        .scale(
          begin: const Offset(0.3, 0.3),
          end: const Offset(1.0, 1.0),
          duration: 600.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 300.ms)
        .then(delay: 800.ms)
        // Gentle repeating pulse
        .animate(onPlay: (c) => c.repeat(reverse: true))
        .scale(
          begin: const Offset(1.0, 1.0),
          end: const Offset(1.06, 1.06),
          duration: 900.ms,
          curve: Curves.easeInOut,
        );
  }
}

/// Animated hero day number with a glowing lime ring behind it.
class _DayCounter extends StatelessWidget {
  final int days;
  const _DayCounter({required this.days});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 140,
      height: 140,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.bgTertiary,
        border: Border.all(
          color: AppColors.lime.withValues(alpha: 0.6),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.lime.withValues(alpha: 0.25),
            blurRadius: 40,
            spreadRadius: 8,
          ),
        ],
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '$days',
            style: AppTypography.display.copyWith(
              fontSize: 52,
              fontWeight: FontWeight.w800,
              color: AppColors.lime,
              height: 1,
            ),
          ),
          Text(
            days == 1 ? 'DAY' : 'DAYS',
            style: AppTypography.overline.copyWith(
              color: AppColors.textTertiary,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
    )
        .animate()
        .scale(
          begin: const Offset(0.4, 0.4),
          duration: 700.ms,
          curve: Curves.elasticOut,
        )
        .fadeIn(duration: 400.ms)
        .shimmer(
          delay: 800.ms,
          duration: 1200.ms,
          color: AppColors.lime.withValues(alpha: 0.3),
        );
  }
}
