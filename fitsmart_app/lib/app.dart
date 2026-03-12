import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
import 'providers/settings_provider.dart';
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
    // Auth is handled by the login/signup screens — no auto sign-in.
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

    return MaterialApp.router(
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
            child: child ?? const SizedBox.shrink(),
          ),
        );
      },
    );
  }
}
