import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_extensions.dart';
import '../../services/analytics_service.dart';
import 'connectivity_banner.dart';

class AppShell extends ConsumerWidget {
  final StatefulNavigationShell navigationShell;
  const AppShell({super.key, required this.navigationShell});

  static const _items = [
    _NavItem(icon: Icons.home_rounded, label: 'Home'),
    _NavItem(icon: Icons.restaurant_rounded, label: 'Nutrition'),
    _NavItem(icon: Icons.smart_toy_rounded, label: 'AI Coach', isCenterCta: true),
    _NavItem(icon: Icons.fitness_center_rounded, label: 'Workouts'),
    _NavItem(icon: Icons.show_chart_rounded, label: 'Progress'),
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bgPrimary,
      // Body no longer extends behind the nav — the bottom nav is now a
      // solid surface (the BackdropFilter version was sampling the lime
      // FAB / lime CTAs and bleeding green through the entire bar).
      // The "glass" feel survives via the top highlight gradient + accent
      // border on the solid surface.
      body: Column(
        children: [
          const ConnectivityBanner(),
          Expanded(child: navigationShell),
        ],
      ),
      bottomNavigationBar: _BottomNav(
        currentIndex: navigationShell.currentIndex,
        items: _items,
        onTap: (index) {
          const labels = ['home', 'nutrition', 'ai_coach', 'workouts', 'progress'];
          final from = labels[navigationShell.currentIndex];
          final to = labels[index];
          if (index != navigationShell.currentIndex) {
            AnalyticsService.instance.tap(
              'bottom_nav_$to',
              screen: 'bottom_nav',
              props: {'from': from, 'to': to},
            );
          }
          navigationShell.goBranch(
            index,
            initialLocation: index == navigationShell.currentIndex,
          );
        },
      ),
    );
  }
}

class _NavItem {
  final IconData icon;
  final String label;
  final bool isCenterCta;
  const _NavItem({required this.icon, required this.label, this.isCenterCta = false});
}

class _BottomNav extends StatelessWidget {
  final int currentIndex;
  final List<_NavItem> items;
  final ValueChanged<int> onTap;

  const _BottomNav({
    required this.currentIndex,
    required this.items,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return DecoratedBox(
      // Clean solid surface — no gradient, no blur. Earlier versions added
      // a top white-highlight gradient meant to suggest "glass-rim" but it
      // came across as 3D plastic shine on dark mode. Simpler reads better.
      decoration: BoxDecoration(
        color: c.bgSecondary,
        border: Border(
          top: BorderSide(
            color: c.surfaceCardBorder.withValues(alpha: 0.6),
            width: 0.5,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 60,
          child: Row(
            children: List.generate(items.length, (i) {
              final isActive = i == currentIndex;
              final item = items[i];

              // Center CTA (AI Coach) — elevated glowing button
              if (item.isCenterCta) {
                return Expanded(
                  child: GestureDetector(
                    onTap: () => onTap(i),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [c.lime, c.limeMuted],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: c.lime.withValues(alpha: isActive ? 0.5 : 0.25),
                                blurRadius: isActive ? 14 : 8,
                                spreadRadius: isActive ? 1 : 0,
                              ),
                            ],
                          ),
                          child: const Icon(
                            Icons.smart_toy_rounded,
                            color: Colors.black,
                            size: 22,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: AppTypography.overline.copyWith(
                            color: isActive
                                ? c.lime
                                : c.textSecondary,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              }

              // Standard nav item
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        AnimatedScale(
                          scale: isActive ? 1.12 : 1.0,
                          duration: const Duration(milliseconds: 280),
                          curve: Curves.easeOutBack,
                          child: AnimatedContainer(
                            duration: const Duration(milliseconds: 220),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 4),
                            decoration: BoxDecoration(
                              color: isActive
                                  ? c.limeGlow
                                  : Colors.transparent,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                            child: Icon(
                              item.icon,
                              color: isActive
                                  ? c.lime
                                  : c.textTertiary,
                              size: 20,
                            ),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label,
                          style: AppTypography.overline.copyWith(
                            color: isActive
                                ? c.lime
                                : c.textTertiary,
                            fontSize: 9,
                            fontWeight: isActive
                                ? FontWeight.w700
                                : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}
