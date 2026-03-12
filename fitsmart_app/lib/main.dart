import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'firebase_options.dart';
import 'app.dart';
import 'data/database/database_provider.dart';
import 'services/database_seeder.dart';
import 'services/food_knowledge_service.dart';

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
