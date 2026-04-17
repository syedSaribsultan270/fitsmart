import 'dart:async';

import 'package:animations/animations.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'features/auth/screens/login_screen.dart';
import 'features/splash/screens/splash_screen.dart';
import 'features/auth/screens/signup_screen.dart';
import 'features/auth/screens/forgot_password_screen.dart';
import 'features/onboarding/screens/onboarding_flow.dart';
import 'features/onboarding/providers/onboarding_provider.dart';
import 'features/dashboard/screens/dashboard_screen.dart';
import 'features/nutrition/screens/nutrition_screen.dart';
import 'features/nutrition/screens/log_meal_screen.dart';
import 'features/workouts/screens/workouts_screen.dart';
import 'features/workouts/screens/active_workout_screen.dart';
import 'features/progress/screens/progress_screen.dart';
import 'features/ai_coach/screens/ai_coach_screen.dart';
import 'features/settings/screens/settings_screen.dart';
import 'features/settings/screens/edit_profile_screen.dart';
import 'features/settings/screens/edit_goals_screen.dart';
import 'features/settings/screens/edit_diet_screen.dart';
import 'features/settings/screens/edit_sleep_screen.dart';
import 'features/settings/screens/faq_screen.dart';
import 'features/settings/screens/legal_screen.dart';
import 'features/paywall/screens/paywall_screen.dart';
import 'features/settings/screens/export_data_screen.dart';
import 'features/weekly_review/screens/weekly_review_screen.dart';
import 'services/analytics_service.dart';
import 'services/auth_service.dart';
import 'services/notification_service.dart';
import 'core/widgets/bottom_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

/// Wraps a child in a Material-Motion shared-axis page so push / pop
/// transitions between sub-routes feel intentional instead of cross-fading.
/// [axis] defaults to horizontal — the standard "going deeper" direction.
CustomTransitionPage<T> _sharedAxisPage<T>({
  required LocalKey key,
  required Widget child,
  SharedAxisTransitionType axis = SharedAxisTransitionType.horizontal,
}) {
  return CustomTransitionPage<T>(
    key: key,
    child: child,
    transitionDuration: const Duration(milliseconds: 320),
    reverseTransitionDuration: const Duration(milliseconds: 280),
    transitionsBuilder: (context, animation, secondary, child) {
      return SharedAxisTransition(
        animation: animation,
        secondaryAnimation: secondary,
        transitionType: axis,
        fillColor: Colors.transparent,
        child: child,
      );
    },
  );
}

final _analytics = FirebaseAnalytics.instance;

/// Converts a [Stream] into a [ChangeNotifier] so GoRouter can
/// re-evaluate its redirect whenever the stream emits.
class _GoRouterRefreshStream extends ChangeNotifier {
  _GoRouterRefreshStream(Stream<dynamic> stream) {
    _sub = stream.asBroadcastStream().listen((_) => notifyListeners());
  }
  late final StreamSubscription<dynamic> _sub;

  @override
  void dispose() {
    _sub.cancel();
    super.dispose();
  }
}

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: '/splash',
  refreshListenable: _GoRouterRefreshStream(AuthService.authStateChanges),
  observers: [
    FirebaseAnalyticsObserver(analytics: _analytics),
    AnalyticsNavigatorObserver(),
  ],
  redirect: (context, state) async {
    // Consume pending notification deep-link if any. Set by
    // NotificationService._onLocalTap when the user taps a local notif.
    final pending = NotificationService.pendingDeepLink;
    if (pending != null && state.matchedLocation != pending) {
      NotificationService.pendingDeepLink = null;
      // Only redirect to the deep link if the user is past the gate.
      final user = AuthService.currentUser;
      if (user != null && !user.isAnonymous) return pending;
    }

    final loc = state.matchedLocation;
    final user = AuthService.currentUser;
    final isAuthRoute = loc == '/login' || loc == '/signup' || loc == '/forgot-password';
    final isSplashRoute = loc == '/splash';
    final isOnboardingRoute = loc == '/onboarding';

    final onboardingDone =
        await OnboardingNotifier.isOnboardingCompleteLocal();

    // ── 1. No user at all → force to login ─────────────────────────
    if (user == null) {
      return (isAuthRoute || isSplashRoute) ? null : '/login';
    }

    // ── 2. Anonymous user ──────────────────────────────────────────
    if (user.isAnonymous) {
      if (onboardingDone) {
        // /signup is the upgrade path for anonymous users — always allow it.
        // Only redirect away from /login and /forgot-password (they're already
        // in the app) and from onboarding (already done).
        if (loc == '/login' || loc == '/forgot-password' || isOnboardingRoute) {
          return '/dashboard';
        }
        return null;
      }
      // Try Firestore recovery (reinstall scenario)
      final recovered =
          await OnboardingNotifier.tryRestoreFromFirestore(user.uid);
      if (recovered) {
        if (loc == '/login' || loc == '/forgot-password' || isOnboardingRoute) {
          return '/dashboard';
        }
        return null;
      }
      // Not onboarded: send to onboarding (they already chose guest).
      // Auth routes (/signup included) still allowed so they can upgrade.
      if (isOnboardingRoute || isAuthRoute) return null;
      return '/onboarding';
    }

    // ── 3. Real user (email/Google) ────────────────────────────────
    if (onboardingDone) {
      if (isAuthRoute || isOnboardingRoute) return '/dashboard';
      return null;
    }

    // Try Firestore recovery (reinstall scenario)
    final recovered =
        await OnboardingNotifier.tryRestoreFromFirestore(user.uid);
    if (recovered) {
      if (isAuthRoute || isOnboardingRoute) return '/dashboard';
      return null;
    }

    // Onboarding not done → send to onboarding
    if (isOnboardingRoute) return null;
    return '/onboarding';
  },
  routes: [
    // Splash
    GoRoute(
      path: '/splash',
      builder: (context, state) => const SplashScreen(),
    ),

    // Auth routes — horizontal slide between login / signup / forgot
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => _sharedAxisPage(
        key: state.pageKey,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/signup',
      pageBuilder: (context, state) => _sharedAxisPage(
        key: state.pageKey,
        child: const SignupScreen(),
      ),
    ),
    GoRoute(
      path: '/forgot-password',
      pageBuilder: (context, state) => _sharedAxisPage(
        key: state.pageKey,
        child: const ForgotPasswordScreen(),
      ),
    ),

    // Onboarding — vertical scaled (full takeover, feels deeper)
    GoRoute(
      path: '/onboarding',
      pageBuilder: (context, state) => _sharedAxisPage(
        key: state.pageKey,
        axis: SharedAxisTransitionType.scaled,
        child: OnboardingFlow(
          fromReset: state.extra == 'from_reset',
        ),
      ),
    ),

    // Main app shell (IndexedStack preserves tab state across switches)
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          AppShell(navigationShell: navigationShell),
      branches: [
        // 0 — Dashboard
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/dashboard',
            builder: (context, state) => const DashboardScreen(),
          ),
        ]),
        // 1 — Nutrition
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/nutrition',
            builder: (context, state) => const NutritionScreen(),
            routes: [
              GoRoute(
                path: 'log',
                pageBuilder: (context, state) => _sharedAxisPage(
                  key: state.pageKey,
                  child: const LogMealScreen(),
                ),
              ),
            ],
          ),
        ]),
        // 2 — AI Coach
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/coach',
            builder: (context, state) => const AiCoachScreen(),
          ),
        ]),
        // 3 — Workouts
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/workouts',
            builder: (context, state) => const WorkoutsScreen(),
            routes: [
              GoRoute(
                path: 'active',
                pageBuilder: (context, state) {
                  final workoutId = state.extra as String?;
                  return _sharedAxisPage(
                    key: state.pageKey,
                    axis: SharedAxisTransitionType.scaled,
                    child: ActiveWorkoutScreen(workoutId: workoutId),
                  );
                },
              ),
            ],
          ),
        ]),
        // 4 — Progress
        StatefulShellBranch(routes: [
          GoRoute(
            path: '/progress',
            builder: (context, state) => const ProgressScreen(),
          ),
        ]),
      ],
    ),

    // Paywall — scaled axis (modal takeover feel)
    GoRoute(
      path: '/paywall',
      pageBuilder: (context, state) => _sharedAxisPage(
        key: state.pageKey,
        axis: SharedAxisTransitionType.scaled,
        child: PaywallScreen(trigger: state.extra as String?),
      ),
    ),

    // Weekly Review — scaled (full takeover from notification tap or banner)
    GoRoute(
      path: '/weekly-review',
      pageBuilder: (context, state) => _sharedAxisPage(
        key: state.pageKey,
        axis: SharedAxisTransitionType.scaled,
        child: const WeeklyReviewScreen(),
      ),
    ),

    // Settings & sub-routes — horizontal cascade
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => _sharedAxisPage(
        key: state.pageKey,
        child: const SettingsScreen(),
      ),
      routes: [
        GoRoute(
          path: 'edit-profile',
          pageBuilder: (context, state) => _sharedAxisPage(
            key: state.pageKey,
            child: const EditProfileScreen(),
          ),
        ),
        GoRoute(
          path: 'edit-goals',
          pageBuilder: (context, state) => _sharedAxisPage(
            key: state.pageKey,
            child: const EditGoalsScreen(),
          ),
        ),
        GoRoute(
          path: 'edit-diet',
          pageBuilder: (context, state) => _sharedAxisPage(
            key: state.pageKey,
            child: const EditDietScreen(),
          ),
        ),
        GoRoute(
          path: 'edit-sleep',
          pageBuilder: (context, state) => _sharedAxisPage(
            key: state.pageKey,
            child: const EditSleepScreen(),
          ),
        ),
        GoRoute(
          path: 'faq',
          pageBuilder: (context, state) => _sharedAxisPage(
            key: state.pageKey,
            child: const FaqScreen(),
          ),
        ),
        GoRoute(
          path: 'export',
          pageBuilder: (context, state) => _sharedAxisPage(
            key: state.pageKey,
            child: const ExportDataScreen(),
          ),
        ),
        GoRoute(
          path: 'privacy',
          builder: (context, state) => const LegalScreen(
            title: 'Privacy Policy',
            content: privacyPolicyText,
          ),
        ),
        GoRoute(
          path: 'terms',
          builder: (context, state) => const LegalScreen(
            title: 'Terms of Service',
            content: termsOfServiceText,
          ),
        ),
      ],
    ),
  ],
);
