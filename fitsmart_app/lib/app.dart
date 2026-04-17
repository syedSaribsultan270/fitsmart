import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/theme/app_theme.dart';
import 'core/widgets/app_error_widget.dart';
import 'core/widgets/offline_banner.dart';
import 'providers/settings_provider.dart';
import 'providers/pointer_tracker_provider.dart';
import 'router.dart';
import 'services/snackbar_service.dart';

class FitSmartApp extends ConsumerStatefulWidget {
  const FitSmartApp({super.key});

  @override
  ConsumerState<FitSmartApp> createState() => _FitSmartAppState();
}

class _FitSmartAppState extends ConsumerState<FitSmartApp> {
  @override
  void initState() {
    super.initState();
    // Replace Flutter's red error screen with our branded error widget.
    ErrorWidget.builder = (FlutterErrorDetails details) {
      return AppErrorWidget(
        message: kDebugMode ? details.exceptionAsString() : null,
      );
    };
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final accent = settings.accentColor;
    final isDark = settings.themeMode == ThemeMode.dark ||
        (settings.themeMode == ThemeMode.system &&
            MediaQuery.platformBrightnessOf(context) == Brightness.dark);

    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
      statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
      systemNavigationBarColor:
          isDark ? const Color(0xFF111114) : const Color(0xFFFFFFFF),
      systemNavigationBarIconBrightness:
          isDark ? Brightness.light : Brightness.dark,
    ));

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    // ScreenUtilInit must wrap MaterialApp so .sp / .w / .h work everywhere.
    return ScreenUtilInit(
      // Design reference: iPhone 14 / standard Android (390 × 844 logical px).
      designSize: const Size(390, 844),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (_, __) => MaterialApp.router(
        title: 'FitSmart AI',
        theme: AppTheme.light(accent: accent),
        darkTheme: AppTheme.dark(accent: accent),
        themeMode: settings.themeMode,
        routerConfig: appRouter,
        scaffoldMessengerKey: SnackbarService.scaffoldMessengerKey,
        debugShowCheckedModeBanner: false,
        builder: (context, child) {
          return MediaQuery(
            data: MediaQuery.of(context).copyWith(
              // Disable system font-size scaling — we handle it via screenutil.
              textScaler: TextScaler.noScaling,
            ),
            child: DefaultTextStyle(
              style: DefaultTextStyle.of(context).style.copyWith(
                fontFamilyFallback: const [
                  'Noto Color Emoji',
                  'Apple Color Emoji',
                  'Segoe UI Emoji',
                  'Noto Sans',
                ],
              ),
              // Global pointer listener — feeds PointerTracker so the spark
              // mascot (and future reactive widgets) can track cursor/touch
              // across every screen. Translucent behavior so we never eat
              // events from the widgets underneath.
              child: Listener(
                behavior: HitTestBehavior.translucent,
                onPointerDown: (e) => ref
                    .read(pointerTrackerProvider.notifier)
                    .update(e.position),
                onPointerMove: (e) => ref
                    .read(pointerTrackerProvider.notifier)
                    .update(e.position),
                onPointerHover: (e) => ref
                    .read(pointerTrackerProvider.notifier)
                    .update(e.position),
                child: Column(
                  children: [
                    const OfflineBanner(),
                    Expanded(child: child ?? const SizedBox.shrink()),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
