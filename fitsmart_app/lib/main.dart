import 'dart:async';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'data/database/database_provider.dart';
import 'models/onboarding_data.dart';
import 'services/analytics_service.dart';
import 'services/database_seeder.dart';
import 'services/food_knowledge_service.dart';
import 'router.dart' show appRouter;
import 'services/deep_link_service.dart';
import 'services/notification_service.dart';
import 'services/sync_service.dart';
import 'features/widgets/home_widget_service.dart';

/// FCM background message handler — must be a top-level function.
@pragma('vm:entry-point')
Future<void> _onFcmBackground(RemoteMessage message) async {
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  debugPrint('[FCM] Background message: ${message.messageId}');
}

/// Re-applies Firebase Analytics user properties for returning users
/// who already completed onboarding. Fire-and-forget, non-blocking.
Future<void> _restoreUserProperties() async {
  try {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString('onboarding_data');
    if (json == null) return;
    final profile = OnboardingData.fromJson(jsonDecode(json) as Map<String, dynamic>);
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
    await AnalyticsService.instance.setUserProperties(
      goalType: profile.primaryGoal,
      activityLevel: profile.activityLevel,
      dietType: dietType,
      ageGroup: profile.age != null ? AnalyticsService.ageGroup(profile.age!) : null,
      gender: profile.gender,
    );
  } catch (_) {}
}

void main() async {
  // Catch async errors not caught by Flutter framework
  runZonedGuarded(
    () async {
      WidgetsFlutterBinding.ensureInitialized();

      // Initialize Firebase
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );

      // Configure Crashlytics (skip in debug/web)
      if (!kIsWeb) {
        await FirebaseCrashlytics.instance
            .setCrashlyticsCollectionEnabled(!kDebugMode);
      }

      // Enable Firestore offline persistence on web (IndexedDB).
      // Mobile already has this on by default.
      // This makes Firestore the reliable cross-device source of truth:
      // even on a cold start or network blip, the last known profile is readable.
      if (kIsWeb) {
        FirebaseFirestore.instance.settings = const Settings(
          persistenceEnabled: true,
          cacheSizeBytes: Settings.CACHE_SIZE_UNLIMITED,
        );
      }

      // Start analytics — sets up terminal + file logging + auth monitoring
      await AnalyticsService.instance.init();

      // Register FCM background handler (must be before runApp)
      if (!kIsWeb) {
        FirebaseMessaging.onBackgroundMessage(_onFcmBackground);
        await NotificationService.instance.init();
      }

      // Initialize home widget data channel
      if (!kIsWeb) {
        await HomeWidgetService.instance.init();
      }

      // Restore user properties for returning users (fire-and-forget)
      _restoreUserProperties();

      // Cloud sync + FCM token refresh on every sign-in.
      // Fires on app start (if already signed in) and after every future sign-in.
      if (!kIsWeb) {
        FirebaseAuth.instance.authStateChanges().listen((user) {
          if (user != null && !user.isAnonymous) {
            SyncService.instance.pullAndMerge(user.uid, appDatabaseInstance)
                .catchError((e) => debugPrint('[Sync] auth-triggered pull failed: $e'));
            // Refresh FCM token so stale tokens (reinstalls, token rotation)
            // never silently break push notifications.
            NotificationService.instance.refreshFcmToken()
                .catchError((e) => debugPrint('[FCM] token refresh failed: $e'));
          }
        });
      }

      // Deep link listener (started after router is ready)
      if (!kIsWeb) {
        DeepLinkService.instance.init(appRouter);
      }

      // Seed exercise library on first launch
      await DatabaseSeeder(appDatabaseInstance).seedIfNeeded();

      // Preload food knowledge base (Indian + common foods) for RAG
      FoodKnowledgeService.instance.load(); // fire-and-forget, non-blocking

      // Global Flutter error handler → Crashlytics
      FlutterError.onError = (details) {
        FlutterError.presentError(details);
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordFlutterFatalError(details);
        }
      };

      // Forward platform dispatcher errors to Crashlytics
      PlatformDispatcher.instance.onError = (error, stack) {
        if (!kIsWeb) {
          FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        }
        return true;
      };

      runApp(
        const ProviderScope(
          child: FitSmartApp(),
        ),
      );
    },
    (error, stack) {
      debugPrint('Uncaught error: $error');
      if (!kIsWeb) {
        FirebaseCrashlytics.instance.recordError(error, stack);
      }
    },
  );
}
