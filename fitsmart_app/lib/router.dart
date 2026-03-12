import 'dart:async';

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
import 'services/auth_service.dart';
import 'core/widgets/bottom_nav.dart';

final _rootNavigatorKey = GlobalKey<NavigatorState>();

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
  ],
  redirect: (context, state) async {
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
      // Not onboarded: send to onboarding (they already chose guest).
      // Auth routes still allowed so they can upgrade their account.
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

    // Auth routes
    GoRoute(
      path: '/login',
      builder: (context, state) => const LoginScreen(),
    ),
    GoRoute(
      path: '/signup',
      builder: (context, state) => const SignupScreen(),
    ),
    GoRoute(
      path: '/forgot-password',
      builder: (context, state) => const ForgotPasswordScreen(),
    ),

    // Onboarding
    GoRoute(
      path: '/onboarding',
      builder: (context, state) => const OnboardingFlow(),
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
                builder: (context, state) => const LogMealScreen(),
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
                builder: (context, state) {
                  final workoutId = state.extra as String?;
                  return ActiveWorkoutScreen(workoutId: workoutId);
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

    // Settings & sub-routes
    GoRoute(
      path: '/settings',
      builder: (context, state) => const SettingsScreen(),
      routes: [
        GoRoute(
          path: 'edit-profile',
          builder: (context, state) => const EditProfileScreen(),
        ),
        GoRoute(
          path: 'edit-goals',
          builder: (context, state) => const EditGoalsScreen(),
        ),
        GoRoute(
          path: 'edit-diet',
          builder: (context, state) => const EditDietScreen(),
        ),
        GoRoute(
          path: 'edit-sleep',
          builder: (context, state) => const EditSleepScreen(),
        ),
        GoRoute(
          path: 'faq',
          builder: (context, state) => const FaqScreen(),
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
