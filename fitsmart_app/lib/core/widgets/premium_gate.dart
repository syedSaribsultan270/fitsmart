import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../providers/subscription_provider.dart';
import '../../services/analytics_service.dart';

/// Wraps [child] and renders it only for premium users.
///
/// Free users see a lock overlay that opens the paywall on tap.
///
/// ```dart
/// PremiumGate(
///   feature: 'unlimited_ai',
///   child: SomeWidget(),
/// )
/// ```
class PremiumGate extends ConsumerWidget {
  final String feature;
  final Widget child;

  /// If true, show a full replacement placeholder instead of overlaying the child.
  final bool replace;

  const PremiumGate({
    super.key,
    required this.feature,
    required this.child,
    this.replace = false,
  });

  void _openPaywall(BuildContext context) {
    AnalyticsService.instance.track('free_tier_limit_hit',
        props: {'feature': feature});
    context.push('/paywall', extra: feature);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final premiumAsync = ref.watch(isPremiumProvider);

    return premiumAsync.when(
      loading: () => child,
      error: (_, __) => child,
      data: (isPremium) {
        if (isPremium) return child;
        if (replace) return _LockedPlaceholder(onTap: () => _openPaywall(context));
        return Stack(
          children: [
            child,
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _openPaywall(context),
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(140),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.lock_rounded, color: Colors.white, size: 28),
                        SizedBox(height: 6),
                        Text(
                          'Premium',
                          style: TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        );
      },
    );
  }
}

class _LockedPlaceholder extends StatelessWidget {
  final VoidCallback onTap;
  const _LockedPlaceholder({required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 16),
        decoration: BoxDecoration(
          color: const Color(0xFF111114),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: const Color(0xFF2A2A30)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: Color(0xFF1F1F24),
              ),
              child: const Icon(Icons.lock_rounded,
                  color: Color(0xFFBDFF3A), size: 22),
            ),
            const SizedBox(height: 12),
            const Text(
              'Premium Feature',
              style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 15),
            ),
            const SizedBox(height: 6),
            const Text(
              'Upgrade to unlock this and all premium features.',
              style: TextStyle(color: Color(0xFF8A8A96), fontSize: 13),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            Container(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              decoration: BoxDecoration(
                color: const Color(0xFFBDFF3A),
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Upgrade to Premium',
                style: TextStyle(
                    color: Colors.black,
                    fontWeight: FontWeight.w700,
                    fontSize: 14),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
