import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../providers/connectivity_provider.dart';
import '../theme/app_typography.dart';
import '../theme/theme_extensions.dart';

/// A slim banner that slides down from the top of the screen when the device
/// goes offline. Auto-dismisses 2 seconds after connectivity is restored.
///
/// Place at the top of a [Column] wrapping the app's root [Navigator]/[Router].
class OfflineBanner extends ConsumerStatefulWidget {
  const OfflineBanner({super.key});

  @override
  ConsumerState<OfflineBanner> createState() => _OfflineBannerState();
}

class _OfflineBannerState extends ConsumerState<OfflineBanner> {
  bool _visible = false;
  bool _wasOffline = false;

  @override
  Widget build(BuildContext context) {
    final isOnline = ref.watch(isOnlineProvider);

    // Show banner immediately when going offline.
    if (!isOnline && !_visible) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() { _visible = true; _wasOffline = true; });
      });
    }

    // Keep banner for 2 s after recovering, then hide.
    if (isOnline && _wasOffline && _visible) {
      Future.delayed(const Duration(seconds: 2), () {
        if (mounted) setState(() { _visible = false; _wasOffline = false; });
      });
    }

    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _visible
          ? _BannerContent(isOnline: isOnline).animate().slideY(
                begin: -1,
                end: 0,
                duration: 300.ms,
                curve: Curves.easeOut,
              )
          : const SizedBox.shrink(),
    );
  }
}

class _BannerContent extends StatelessWidget {
  final bool isOnline;
  const _BannerContent({required this.isOnline});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: isOnline ? Colors.green.shade700 : context.colors.error,
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
      child: SafeArea(
        bottom: false,
        child: Row(
          children: [
            Icon(
              isOnline ? Icons.wifi_rounded : Icons.wifi_off_rounded,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    isOnline ? 'Back online' : 'No internet connection',
                    style: AppTypography.caption.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  if (!isOnline)
                    Text(
                      'Your logs are saved locally and will sync when reconnected.',
                      style: AppTypography.caption.copyWith(
                        color: Colors.white.withAlpha(210),
                        fontSize: 10,
                      ),
                    ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
