import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/onboarding_provider.dart';
import '../../../services/analytics_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/notification_scheduler.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
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
  final bool fromReset;
  const OnboardingFlow({super.key, this.fromReset = false});

  @override
  ConsumerState<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends ConsumerState<OnboardingFlow> {
  final PageController _controller = PageController();
  int _currentStep = 0;
  bool _isSubmitting = false;
  DateTime? _onboardingStart;

  static const int _totalSteps = 11;

  static const _stepNames = [
    'welcome', 'mission', 'bio', 'body_stats', 'location',
    'activity', 'dream_body', 'sleep', 'diet', 'budget', 'targets', 'ai_setup',
  ];

  @override
  void initState() {
    super.initState();
    _onboardingStart = DateTime.now();
    AnalyticsService.instance.track('onboarding_step_viewed', props: {
      'step': 0,
      'step_name': 'welcome',
    });
  }

  void _next() {
    if (_currentStep < _totalSteps) {
      AnalyticsService.instance.tap('onboarding_next', screen: 'onboarding', props: {
        'step': _currentStep,
        'step_name': _stepNames[_currentStep],
      });
      _controller.animateToPage(
        _currentStep + 1,
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void _back() {
    if (_currentStep > 0) {
      AnalyticsService.instance.tap('onboarding_back', screen: 'onboarding', props: {
        'step': _currentStep,
        'step_name': _stepNames[_currentStep],
      });
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

      // 2. Sync profile to Firestore — awaited so it's reliably the source of
      //    truth across all devices/browsers. 8 s timeout keeps UX snappy.
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

        // Explicit completion flag — recovery doesn't have to reconstruct
        // isComplete from optional fields (some may be null if user skipped).
        profileData['isComplete'] = true;

        try {
          await FirestoreService.saveProfile(uid, profileData)
              .timeout(const Duration(seconds: 8));
        } catch (e) {
          // Local save already succeeded — user can continue.
          // On next sign-in the recovery path will retry.
          debugPrint('[Firestore] profile sync failed: $e');
        }
      }

      // Set Firebase Analytics user properties for segmentation
      final profile = ref.read(onboardingProvider);
      final restrictions = profile.dietaryRestrictions ?? [];
      final dietType = restrictions.contains('vegan')
          ? 'vegan'
          : restrictions.contains('vegetarian')
              ? 'vegetarian'
              : restrictions.contains('keto')
                  ? 'keto'
                  : restrictions.contains('halal')
                      ? 'halal'
                      : 'omnivore';
      AnalyticsService.instance.setUserProperties(
        goalType: profile.primaryGoal,
        activityLevel: profile.activityLevel,
        dietType: dietType,
        ageGroup: profile.age != null ? AnalyticsService.ageGroup(profile.age!) : null,
        gender: profile.gender,
      );

      final elapsed = _onboardingStart != null
          ? DateTime.now().difference(_onboardingStart!).inSeconds
          : 0;
      AnalyticsService.instance.track('onboarding_completed', props: {
        'total_steps': _totalSteps,
        'time_spent_s': elapsed,
      });
      // Schedule meal/streak notifications now that profile is complete.
      // Safe to call even before OS permission is granted — will be a no-op
      // if the user hasn't allowed notifications yet; the settings toggle
      // will reschedule once they do.
      NotificationScheduler.instance.rescheduleAll(enabled: true)
          .catchError((e) => debugPrint('[Notifications] reschedule after onboarding failed: $e'));
      if (mounted) context.go('/dashboard');
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Something went wrong. Please try again.'),
            backgroundColor: context.colors.error,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      body: Stack(
        children: [
          // Pages
          PageView(
            controller: _controller,
            physics: const NeverScrollableScrollPhysics(),
            onPageChanged: (i) {
              setState(() => _currentStep = i);
              AnalyticsService.instance.track('onboarding_step_viewed', props: {
                'step': i,
                'step_name': _stepNames[i],
              });
            },
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

          // Top progress indicator (hidden on welcome and last step)
          if (_currentStep > 0 && _currentStep < _totalSteps)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: 0,
              right: 0,
              child: _OnboardingProgress(
                currentStep: _currentStep,
                totalSteps: _totalSteps,
                onBack: _back,
                onSkip: _complete,
              ),
            ),

          // Back-to-auth button — only shown on step 0 when launched from reset
          if (widget.fromReset && _currentStep == 0)
            Positioned(
              top: MediaQuery.of(context).padding.top + 8,
              left: AppSpacing.pagePadding,
              child: GestureDetector(
                onTap: () async {
                  await AuthService.signOut();
                  if (context.mounted) context.go('/login');
                },
                child: Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: context.colors.surfaceCardBorder),
                  ),
                  child: Icon(
                    Icons.arrow_back_ios_new_rounded,
                    color: context.colors.textSecondary,
                    size: 16,
                  ),
                ),
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
  final VoidCallback onSkip;

  const _OnboardingProgress({
    required this.currentStep,
    required this.totalSteps,
    required this.onBack,
    required this.onSkip,
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
                color: context.colors.surfaceCard,
                borderRadius: BorderRadius.circular(AppRadius.md),
                border: Border.all(color: context.colors.surfaceCardBorder),
              ),
              child: Icon(
                Icons.arrow_back_ios_new_rounded,
                color: context.colors.textSecondary,
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

          // Skip button
          GestureDetector(
            onTap: onSkip,
            child: Text(
              'Skip',
              style: AppTypography.caption.copyWith(
                color: context.colors.textTertiary,
                fontWeight: FontWeight.w600,
              ),
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
                    ? context.colors.lime
                    : isActive
                        ? context.colors.lime.withValues(alpha: 0.7)
                        : context.colors.surfaceCardBorder,
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: isActive
                    ? [
                        BoxShadow(
                          color: context.colors.lime.withValues(alpha: 0.4),
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
                      .copyWith(color: context.colors.textSecondary))
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
