import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/onboarding_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import 'step_welcome.dart';
import 'step_mission.dart';
import 'step_bio.dart';
import 'step_body_stats.dart';
import 'step_location.dart';
import 'step_activity.dart';
import 'step_dream_body.dart';
import 'step_sleep.dart';
import 'step_diet.dart';
import 'step_budget.dart';
import 'step_targets.dart';
import 'step_ai_setup.dart';

class OnboardingFlow extends ConsumerStatefulWidget {
  const OnboardingFlow({super.key});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final PageController _controller = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;

  // Steps after welcome (step 0)
  static const int _totalSteps = 11; // steps 1-11 (welcome is 0)

  void _next() {
    if (_currentStep < 11) {
      _controller.animateToPage(
        _currentStep + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _back() {
    if (_currentStep > 0) {
      _controller.animateToPage(
        _currentStep - 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  Future<void> _complete() async {
    if (_isSubmitting) return;
    setState(() => _isSubmitting = true);

    try {
      // 1. Persist locally (SharedPreferences) & mark onboarding complete
      final notifier = ref.read(onboardingProvider.notifier);
      await notifier.saveToPrefs();

      // 2. Sync profile to Firestore
      final uid = AuthService.uid;
      if (uid != null) {
        final profileData = ref.read(onboardingProvider).toJson();

        // Include auth info so the Firestore profile is complete
        final displayName = AuthService.displayName;
        final email = AuthService.email;
        if (displayName != null && displayName.isNotEmpty) {
          profileData['displayName'] = displayName;
        }
        if (email != null && email.isNotEmpty) {
          profileData['email'] = email;
        }

        await FirestoreService.saveProfile(uid, profileData);
      }

      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Something went wrong. Please try again.'),
            backgroundColor: AppColors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      body: Stack(
        children: [
          // Pages
          PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) => setState(() => _currentStep = i),
            children: [
              StepWelcome(onNext: _next),
              StepMission(onNext: _next),
              StepBio(onNext: _next),
              StepBodyStats(onNext: _next),
              StepLocation(onNext: _next),
              StepActivity(onNext: _next),
              StepDreamBody(onNext: _next),
              StepSleep(onNext: _next),
              StepDiet(onNext: _next),
              StepBudget(onNext: _next),
              StepTargets(onNext: _next),
              StepAiSetup(onComplete: _complete, isSubmitting: _isSubmitting),
            ],
          ),

          // Top progress indicator (hidden on welcome screen)
          if (_currentStep > 0 && _currentStep < 11)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 0,
              right: 0,
              child: _OnboardingProgress(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                onBack: _back,
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _OnboardingProgress extends StatelessWidget {
  final int currentStep;
  final int totalSteps;
  final VoidCallback onBack;

  const _OnboardingProgress({
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Row(
        children: [
          // Back button
          GestureDetector(
            onTap: onBack,
            child: Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: AppColors.surfaceCardBorder),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new_rounded,
                color: AppColors.textSecondary,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),

          // Dot path progress
          Expanded(
            child: _DotProgress(
              current: currentStep,
              total: totalSteps,
            ),
          ),

          const SizedBox(width: AppSpacing.md),

          // Step counter
          Text(
            '$currentStep/$totalSteps',
            style: AppTypography.caption.copyWith(
              color: AppColors.textTertiary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _DotProgress extends StatelessWidget {
  final int current;
  final int total;

  const _DotProgress({required this.current, required this.total});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: List.generate(total, (i) {
        final isDone = i < current;
        final isActive = i == current;
        return Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 2),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              height: isActive ? 6 : 4,
              decoration: BoxDecoration(
                color: isDone
                    ? AppColors.lime
                    : isActive
                        ? AppColors.lime.withValues(alpha: 0.7)
                        : AppColors.surfaceCardBorder,
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: AppColors.lime.withValues(alpha: 0.4),
                          blurRadius: 6,
                        ),
                      ]
                    : null,
              ),
            ),
          ),
        );
      }),
    );
  }
}

/// Base layout used by all onboarding steps
class OnboardingStepBase extends StatelessWidget {
  final String title;
  final String subtitle;
  final String? emoji;
  final Widget content;
  final Widget? cta;
  final bool scrollable;
  final EdgeInsetsGeometry? contentPadding;

  const OnboardingStepBase({
    super.key,
    required this.title,
    required this.subtitle,
    this.emoji,
    required this.content,
    this.cta,
    this.scrollable = false,
    this.contentPadding,
  });

  @override
  Widget build(BuildContext context) {
    final topPad = MediaQuery.of(context).padding.top + 72;
    final bottomPad = MediaQuery.of(context).padding.bottom + 16;

    final header = Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (emoji != null) ...[
            Text(emoji!, style: const TextStyle(fontSize: 36))
                .animate()
                .scale(duration: 400.ms, curve: Curves.elasticOut),
            const SizedBox(height: AppSpacing.md),
          ],
          Text(title, style: AppTypography.h1)
              .animate()
              .slideX(begin: -0.1, duration: 350.ms, curve: Curves.easeOut)
              .fadeIn(duration: 350.ms),
          const SizedBox(height: AppSpacing.sm),
          Text(subtitle,
                  style: AppTypography.body
                      .copyWith(color: AppColors.textSecondary))
              .animate(delay: 100.ms)
              .fadeIn(duration: 300.ms),
        ],
      ),
    );

    final pad = contentPadding ??
        const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding);

    final animatedContent = content
        .animate(delay: 150.ms)
        .slideY(begin: 0.05, duration: 350.ms, curve: Curves.easeOut)
        .fadeIn(duration: 350.ms);

    final ctaWidget = cta != null
        ? Padding(
            padding: EdgeInsets.fromLTRB(
              AppSpacing.pagePadding,
              AppSpacing.lg,
              AppSpacing.pagePadding,
              bottomPad,
            ),
            child: cta!,
          )
        : null;

    // Scrollable: no Expanded — content flows naturally in scroll view
    if (scrollable) {
      return SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: topPad),
            header,
            const SizedBox(height: AppSpacing.sectionGap),
            Padding(padding: pad, child: animatedContent),
            if (ctaWidget != null) ctaWidget,
          ],
        ),
      );
    }

    // Non-scrollable: Expanded fills remaining height
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(height: topPad),
        header,
        const SizedBox(height: AppSpacing.sectionGap),
        Expanded(child: Padding(padding: pad, child: animatedContent)),
        if (ctaWidget != null) ctaWidget,
      ],
    );
  }
}
