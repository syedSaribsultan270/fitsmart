import 'dart:async';
import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';
import 'analytics_service.dart';

/// Handles both cold-start and foreground deep links.
///
/// Supported scheme: `fitsmart://`
///
/// Supported paths:
///   fitsmart://dashboard    → /dashboard
///   fitsmart://nutrition    → /nutrition
///   fitsmart://log-meal     → /nutrition/log
///   fitsmart://coach        → /coach
///   fitsmart://workouts     → /workouts
///   fitsmart://progress     → /progress
///   fitsmart://settings     → /settings
///
/// Call [init] once after the router is ready. Call [dispose] on app teardown.
class DeepLinkService {
  DeepLinkService._();
  static final instance = DeepLinkService._();

  final _appLinks = AppLinks();
  StreamSubscription<Uri>? _sub;

  /// Starts listening. [router] is the GoRouter instance.
  Future<void> init(GoRouter router) async {
    if (kIsWeb) return;

    // Foreground links
    _sub = _appLinks.uriLinkStream.listen(
      (uri) => _handleUri(uri, router),
      onError: (e) => debugPrint('[DeepLink] stream error: $e'),
    );

    // Cold-start link
    try {
      final initial = await _appLinks.getInitialLink();
      if (initial != null) _handleUri(initial, router);
    } catch (e) {
      debugPrint('[DeepLink] getInitialLink error: $e');
    }
  }

  void dispose() => _sub?.cancel();

  void _handleUri(Uri uri, GoRouter router) {
    final path = _resolve(uri);
    if (path == null) return;

    final source = uri.queryParameters['ref'] ?? 'direct';
    AnalyticsService.instance.track('deep_link_opened', props: {
      'path': uri.path,
      'source': source,
    });
    debugPrint('[DeepLink] navigating to $path (from $source)');
    router.go(path);
  }

  static String? _resolve(Uri uri) {
    // Accept both fitsmart:// and https://fitsmart.app/
    final host = uri.host;
    final path = uri.path.replaceAll(RegExp(r'^/'), '');

    // Custom scheme: fitsmart://dashboard  → host = "dashboard", path = ""
    // Universal link: https://fitsmart.app/dashboard → host = "fitsmart.app", path = "dashboard"
    final segment = path.isNotEmpty ? path : host;

    return switch (segment) {
      'dashboard' => '/dashboard',
      'nutrition' => '/nutrition',
      'log-meal' || 'log_meal' => '/nutrition/log',
      'coach' => '/coach',
      'workouts' => '/workouts',
      'progress' => '/progress',
      'settings' => '/settings',
      _ => null,
    };
  }
}
