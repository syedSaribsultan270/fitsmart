import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/theme/app_theme.dart';
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
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      statusBarBrightness: Brightness.dark,
      systemNavigationBarColor: Color(0xFF111114),
      systemNavigationBarIconBrightness: Brightness.light,
    ));

    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    return MaterialApp.router(
      title: 'FitSmart AI',
      theme: AppTheme.dark,
      darkTheme: AppTheme.dark,
      themeMode: ThemeMode.dark,
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
              // Provide system emoji/symbol fonts as fallbacks so Flutter
              // Web can render emoji without triggering the Noto warning.
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
