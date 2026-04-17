import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../../services/connectivity_service.dart';

/// Slim banner that appears at the top of the app when offline.
///
/// - Offline: amber strip — "No internet connection · Offline mode active"
/// - Back online: green flash that auto-hides after 2.5 seconds
///
/// Wrap this around the body of [AppShell]:
/// ```dart
/// body: Column(
///   children: [
///     const ConnectivityBanner(),
///     Expanded(child: navigationShell),
///   ],
/// )
/// ```
class ConnectivityBanner extends ConsumerStatefulWidget {
  const ConnectivityBanner({super.key});

  @override
  ConsumerState<ConnectivityBanner> createState() =>
      _ConnectivityBannerState();
}

class _ConnectivityBannerState extends ConsumerState<ConnectivityBanner> {
  // null = unknown (first frame), true = online, false = offline
  bool? _prevOnline;
  bool _showReconnected = false;

  @override
  Widget build(BuildContext context) {
    final connectivityAsync = ref.watch(connectivityProvider);

    return connectivityAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (isOnline) {
        // Detect just-reconnected transition
        if (_prevOnline == false && isOnline) {
          _showReconnected = true;
          // Auto-hide after 2.5 seconds
          Future.delayed(const Duration(milliseconds: 2500), () {
            if (mounted) setState(() => _showReconnected = false);
          });
        }
        _prevOnline = isOnline;

        if (isOnline && !_showReconnected) return const SizedBox.shrink();

        return _BannerStrip(
          isOnline: isOnline,
          isReconnected: _showReconnected,
        );
      },
    );
  }
}

class _BannerStrip extends StatelessWidget {
  final bool isOnline;
  final bool isReconnected;

  const _BannerStrip({required this.isOnline, required this.isReconnected});

  @override
  Widget build(BuildContext context) {
    final color = isReconnected ? AppColors.success : AppColors.warning;
    final bgColor = isReconnected
        ? AppColors.successBg
        : AppColors.warningBg;
    final icon = isReconnected ? '✓' : '!';
    final message = isReconnected
        ? 'Back online'
        : 'No internet · Offline mode active';

    return Material(
      color: bgColor,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          border: Border(
            bottom: BorderSide(color: color.withValues(alpha: 0.3), width: 1),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 16,
              height: 16,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.2),
                shape: BoxShape.circle,
              ),
              alignment: Alignment.center,
              child: Text(
                icon,
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              message,
              style: AppTypography.caption.copyWith(
                color: color,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    )
        .animate(key: ValueKey(isReconnected ? 'online' : 'offline'))
        .slideY(
          begin: -1.0,
          end: 0.0,
          duration: 300.ms,
          curve: Curves.easeOutCubic,
        )
        .fadeIn(duration: 200.ms);
  }
}
