import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/foundation.dart';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/glass_toggle.dart';
import '../../../core/widgets/liquid_glass.dart';
import '../../../core/widgets/app_text.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/health_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/gemini_provider.dart';
import '../../../services/analytics_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/health_service.dart';
import '../../../services/notification_scheduler.dart';
import '../../../services/notification_service.dart';
import '../../../services/snackbar_service.dart';
import '../../../providers/subscription_provider.dart';
import '../../onboarding/providers/onboarding_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final gamification = ref.watch(gamificationProvider);
    final settings = ref.watch(settingsProvider);
    final authAsync = ref.watch(authUserProvider);
    final user = authAsync.valueOrNull;
    final isGuest = user == null || user.isAnonymous;
    final displayName = isGuest
        ? 'Guest'
        : (user.displayName?.isNotEmpty == true
            ? user.displayName!
            : settings.displayName);
    final email = isGuest ? null : user.email;
    final photoUrl = isGuest ? null : user.photoURL;

    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: LiquidAppBar(
        title: Text('Settings', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          // Profile card — shows real user info or guest prompt
          if (isGuest)
            AppCard(
              child: Column(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: context.colors.bgTertiary,
                    ),
                    child: Center(
                      child: Icon(Icons.person_outline_rounded, color: context.colors.textTertiary, size: 28),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Guest', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to sync your data across devices',
                    style: AppTypography.caption.copyWith(color: context.colors.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.colors.lime,
                        foregroundColor: Colors.black,
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: Text('Sign In', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700, color: Colors.black)),
                    ),
                  ),
                ],
              ),
            )
          else
            AppCard(
              child: Row(
                children: [
                  if (photoUrl != null && photoUrl.isNotEmpty)
                    ClipOval(
                      child: CachedNetworkImage(
                        imageUrl: photoUrl,
                        width: 56,
                        height: 56,
                        fit: BoxFit.cover,
                        memCacheWidth: 112,
                        errorWidget: (_, __, ___) => Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            gradient: LinearGradient(
                              colors: [context.colors.lime, context.colors.cyan],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              displayName.isNotEmpty ? displayName[0].toUpperCase() : '',
                              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
                            ),
                          ),
                        ),
                      ),
                    )
                  else
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [context.colors.lime, context.colors.cyan],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : '',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                      ),
                    ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(displayName,
                            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                        if (email != null) ...[
                          const SizedBox(height: 2),
                          AppText(email,
                              style: AppTypography.caption.copyWith(color: context.colors.textSecondary)),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'Level ${gamification.currentLevel} · ${gamification.levelName}',
                          style: AppTypography.caption.copyWith(color: context.colors.lime),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: LinearProgressIndicator(
                            value: gamification.levelProgress,
                            backgroundColor: context.colors.surfaceCard,
                            valueColor: AlwaysStoppedAnimation(context.colors.lime),
                            minHeight: 4,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),

          const SizedBox(height: AppSpacing.lg),

          // ── Premium upgrade card (free users only) ───────────────
          Consumer(
            builder: (ctx, refP, _) {
              final premiumAsync = refP.watch(isPremiumProvider);
              return premiumAsync.when(
                loading: () => const SizedBox.shrink(),
                error: (_, __) => const SizedBox.shrink(),
                data: (isPremium) {
                  if (isPremium) return const SizedBox.shrink();
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      GestureDetector(
                        onTap: () {
                          AnalyticsService.instance
                              .tap('upgrade_to_premium', screen: 'settings');
                          ctx.push('/paywall', extra: 'settings');
                        },
                        child: Container(
                          padding: const EdgeInsets.all(AppSpacing.lg),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              colors: [
                                const Color(0xFFBDFF3A).withAlpha(20),
                                const Color(0xFF3ADFFF).withAlpha(20),
                              ],
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                            ),
                            borderRadius:
                                BorderRadius.circular(AppRadius.lg),
                            border: Border.all(
                                color: const Color(0xFFBDFF3A).withAlpha(80)),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  gradient: LinearGradient(
                                    colors: [
                                      ctx.colors.lime,
                                      ctx.colors.cyan
                                    ],
                                    begin: Alignment.topLeft,
                                    end: Alignment.bottomRight,
                                  ),
                                ),
                                child: const Icon(Icons.bolt_rounded,
                                    size: 22, color: Colors.black),
                              ),
                              const SizedBox(width: AppSpacing.md),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment:
                                      CrossAxisAlignment.start,
                                  children: [
                                    Text('Upgrade to Premium',
                                        style: AppTypography.bodyMedium
                                            .copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: ctx.colors.lime)),
                                    const SizedBox(height: 2),
                                    Text(
                                        'Unlimited AI · Plans · Advanced analytics',
                                        style: AppTypography.caption.copyWith(
                                            color: ctx.colors.textSecondary)),
                                  ],
                                ),
                              ),
                              Icon(Icons.chevron_right_rounded,
                                  color: ctx.colors.lime, size: 20),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  );
                },
              );
            },
          ),

          _SectionHeader(title: 'Goals & Profile'),
          _SettingsTile(
            icon: Icons.person_outline_rounded,
            label: 'Edit Profile',
            subtitle: 'Update your bio & body stats',
            onTap: () => context.push('/settings/edit-profile'),
          ),
          _SettingsTile(
            icon: Icons.flag_outlined,
            label: 'Fitness Goals',
            subtitle: 'Change your target & pace',
            onTap: () => context.push('/settings/edit-goals'),
          ),
          _SettingsTile(
            icon: Icons.restaurant_outlined,
            label: 'Diet Preferences',
            subtitle: 'Restrictions & cuisine likes',
            onTap: () => context.push('/settings/edit-diet'),
          ),
          _SettingsTile(
            icon: Icons.bedtime_outlined,
            label: 'Sleep Schedule',
            subtitle: 'Bedtime & wake-up times',
            onTap: () => context.push('/settings/edit-sleep'),
          ),

          const SizedBox(height: AppSpacing.lg),

          _SectionHeader(title: 'App'),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            label: 'Notifications',
            subtitle: settings.notificationsEnabled
                ? 'Streak alerts, meal reminders & weekly recap'
                : 'Disabled',
            trailing: GlassToggle(
              value: settings.notificationsEnabled,
              onChanged: (v) => _toggleNotifications(context, ref, v),
            ),
          ),
          _SettingsTile(
            icon: Icons.calculate_outlined,
            label: 'Units',
            subtitle: settings.isMetric ? 'Metric (kg, cm)' : 'Imperial (lbs, ft)',
            onTap: () => _showUnitsDialog(context, ref),
          ),
          _SettingsTile(
            icon: Icons.dark_mode_outlined,
            label: 'Theme',
            subtitle: switch (settings.themeMode) {
              ThemeMode.system => 'System default',
              ThemeMode.dark => 'Dark',
              ThemeMode.light => 'Light',
            },
            onTap: () => _showThemeDialog(context, ref),
          ),
          _SettingsTile(
            icon: Icons.palette_outlined,
            label: 'Accent Color',
            subtitle: 'Customize app accent',
            trailing: Container(
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: settings.accentColor ?? context.colors.lime,
                border: Border.all(color: context.colors.surfaceCardBorder, width: 1.5),
              ),
            ),
            onTap: () => _showAccentColorPicker(context, ref),
          ),
          _SettingsTile(
            icon: Icons.bar_chart_rounded,
            label: 'Weekly Review',
            subtitle: _formatWeeklySchedule(settings),
            trailing: GlassToggle(
              value: settings.weeklyReportEnabled,
              onChanged: (v) async {
                await ref.read(settingsProvider.notifier).setWeeklyReport(v);
                final s = ref.read(settingsProvider);
                if (s.notificationsEnabled) {
                  await NotificationScheduler.instance.rescheduleAll(
                    enabled: true,
                    weeklyReviewWeekday: s.weeklyReviewWeekday,
                    weeklyReviewHour: s.weeklyReviewHour,
                  );
                }
                AnalyticsService.instance
                    .settingChanged('weekly_report', v, screen: 'settings');
              },
            ),
            onTap: () => _showWeeklyReviewPicker(context, ref),
          ),

          const SizedBox(height: AppSpacing.lg),

          _SectionHeader(title: 'Integrations'),
          Consumer(
            builder: (ctx, ref2, _) {
              final connected = ref2.watch(isHealthConnectedProvider);
              return _SettingsTile(
                icon: Icons.favorite_outline_rounded,
                label: kIsWeb
                    ? 'Apple Health / Health Connect'
                    : (!kIsWeb && Platform.isIOS)
                        ? 'Apple Health'
                        : 'Health Connect',
                subtitle: connected
                    ? 'Connected — steps & calories syncing'
                    : 'Sync steps, calories & weight',
                trailing: connected
                    ? Icon(Icons.check_circle_rounded,
                        color: ctx.colors.lime, size: 20)
                    : null,
                onTap: connected
                    ? null
                    : () => _connectHealth(ctx, ref2),
              );
            },
          ),

          const SizedBox(height: AppSpacing.lg),

          _SectionHeader(title: 'About'),
          _SettingsTile(
            icon: Icons.star_outline_rounded,
            label: 'Rate FitSmart',
            subtitle: 'Support us on the App Store',
            onTap: () => SnackbarService.info('Coming soon — App Store submission in progress!'),
          ),
          _SettingsTile(
            icon: Icons.help_outline_rounded,
            label: 'Help & FAQ',
            subtitle: 'Common questions answered',
            onTap: () => context.push('/settings/faq'),
          ),
          _SettingsTile(
            icon: Icons.download_outlined,
            label: 'Export My Data',
            subtitle: 'Download all your data as a ZIP',
            onTap: () => context.push('/settings/export'),
          ),
          _SettingsTile(
            icon: Icons.privacy_tip_outlined,
            label: 'Privacy Policy',
            onTap: () => context.push('/settings/privacy'),
          ),
          _SettingsTile(
            icon: Icons.description_outlined,
            label: 'Terms of Service',
            onTap: () => context.push('/settings/terms'),
          ),

          const SizedBox(height: AppSpacing.lg),

          // ── Account section ──────────────────────────────────────────
          _SectionHeader(title: 'Account'),
          if (!isGuest) ...[
            _SettingsTile(
              icon: Icons.logout_rounded,
              label: 'Log Out',
              subtitle: 'Sign out of your account',
              onTap: () => _showLogoutDialog(context),
            ),
            _SettingsTile(
              icon: Icons.delete_forever_rounded,
              label: 'Delete Account',
              subtitle: 'Permanently remove all data',
              onTap: () => _showDeleteAccountDialog(context, ref),
            ),
          ] else ...[
            _SettingsTile(
              icon: Icons.login_rounded,
              label: 'Sign In',
              subtitle: 'Create or link an account',
              onTap: () => context.go('/login'),
            ),
          ],

          const SizedBox(height: AppSpacing.lg),

          // App version
          Center(
            child: Column(
              children: [
                Text(
                  'FitSmart AI',
                  style: AppTypography.caption.copyWith(color: context.colors.textTertiary),
                ),
                Text(
                  'v1.0.0 · Built with \u2764\uFE0F',
                  style: AppTypography.caption.copyWith(color: context.colors.textTertiary),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Reset onboarding — debug builds only
          if (kDebugMode)
            TextButton(
              onPressed: () => _showResetDialog(context, ref),
              child: Text(
                'Reset & Re-run Onboarding',
                style: AppTypography.caption.copyWith(color: context.colors.error),
              ),
            ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  Future<void> _toggleNotifications(
      BuildContext context, WidgetRef ref, bool enable) async {
    if (enable) {
      final granted = await NotificationService.instance.requestPermission();
      if (!granted) {
        SnackbarService.info(
            'Permission denied. Enable notifications in your device settings.');
        return;
      }
      await ref.read(settingsProvider.notifier).setNotifications(true);
      final s = ref.read(settingsProvider);
      await NotificationScheduler.instance.rescheduleAll(
        enabled: true,
        weeklyReviewWeekday: s.weeklyReviewWeekday,
        weeklyReviewHour: s.weeklyReviewHour,
      );
      SnackbarService.success('Notifications enabled!');
    } else {
      await ref.read(settingsProvider.notifier).setNotifications(false);
      await NotificationScheduler.instance.cancelAll();
    }
    AnalyticsService.instance.settingChanged(
        'notifications', enable, screen: 'settings');
  }

  Future<void> _connectHealth(BuildContext context, WidgetRef ref) async {
    AnalyticsService.instance.tap('connect_health', screen: 'settings');
    final granted = await HealthService.instance.requestPermission();
    if (granted) {
      ref.read(isHealthConnectedProvider.notifier).state = true;
      SnackbarService.success('Health data connected!');
      HealthService.instance.syncToAnalytics();
    } else {
      SnackbarService.info(
          'Health access denied. You can enable it in your device settings.');
    }
  }

  void _showUnitsDialog(BuildContext context, WidgetRef ref) {
    AnalyticsService.instance.dialogOpened('units', screen: 'settings');
    final isMetric = ref.read(settingsProvider).isMetric;
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Units', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.lg),
            _UnitOption(
              label: 'Metric (kg, cm)',
              isSelected: isMetric,
              onTap: () {
                ref.read(settingsProvider.notifier).setMetric(true);
                AnalyticsService.instance.settingChanged('units', 'metric', screen: 'settings');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _UnitOption(
              label: 'Imperial (lbs, ft)',
              isSelected: !isMetric,
              onTap: () {
                ref.read(settingsProvider.notifier).setMetric(false);
                AnalyticsService.instance.settingChanged('units', 'imperial', screen: 'settings');
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _showThemeDialog(BuildContext context, WidgetRef ref) {
    AnalyticsService.instance.dialogOpened('theme', screen: 'settings');
    final current = ref.read(settingsProvider).themeMode;
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Theme', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.lg),
            for (final entry in [
              (ThemeMode.system, 'System Default', Icons.brightness_auto_rounded),
              (ThemeMode.dark, 'Dark', Icons.dark_mode_rounded),
              (ThemeMode.light, 'Light', Icons.light_mode_rounded),
            ])
              Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: _UnitOption(
                  label: entry.$2,
                  isSelected: current == entry.$1,
                  onTap: () {
                    ref.read(settingsProvider.notifier).setThemeMode(entry.$1);
                    AnalyticsService.instance.settingChanged('theme', entry.$2.toLowerCase(), screen: 'settings');
                    Navigator.pop(context);
                  },
                ),
              ),
            const SizedBox(height: AppSpacing.md),
          ],
        ),
      ),
    );
  }

  static const _accentPresets = <(String, Color)>[
    ('Lime', Color(0xFFBDFF3A)),
    ('Cyan', Color(0xFF3ADFFF)),
    ('Coral', Color(0xFFFF6B6B)),
    ('Purple', Color(0xFFA78BFA)),
    ('Blue', Color(0xFF60A5FA)),
    ('Orange', Color(0xFFFBBF24)),
    ('Pink', Color(0xFFF472B6)),
    ('Teal', Color(0xFF34D399)),
  ];

  void _showAccentColorPicker(BuildContext context, WidgetRef ref) {
    AnalyticsService.instance.dialogOpened('accent_color', screen: 'settings');
    final currentAccent = ref.read(settingsProvider).accentColorValue;
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetCtx) => Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Accent Color', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.lg),
            Wrap(
              spacing: AppSpacing.md,
              runSpacing: AppSpacing.md,
              children: _accentPresets.map((preset) {
                final isSelected = currentAccent == preset.$2.toARGB32() ||
                    (currentAccent == null && preset.$2 == const Color(0xFFBDFF3A));
                return GestureDetector(
                  onTap: () {
                    if (preset.$2 == const Color(0xFFBDFF3A)) {
                      ref.read(settingsProvider.notifier).setAccentColor(null);
                    } else {
                      ref.read(settingsProvider.notifier).setAccentColor(preset.$2);
                    }
                    AnalyticsService.instance.settingChanged('accent_color', preset.$1.toLowerCase(), screen: 'settings');
                    Navigator.pop(context);
                  },
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        width: 44,
                        height: 44,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: preset.$2,
                          border: Border.all(
                            color: isSelected ? Colors.white : Colors.transparent,
                            width: 2.5,
                          ),
                          boxShadow: isSelected
                              ? [BoxShadow(color: preset.$2.withAlpha(80), blurRadius: 10, spreadRadius: 2)]
                              : null,
                        ),
                        child: isSelected
                            ? const Icon(Icons.check_rounded, color: Colors.black, size: 20)
                            : null,
                      ),
                      const SizedBox(height: 6),
                      Text(
                        preset.$1,
                        style: AppTypography.caption.copyWith(
                          color: isSelected ? context.colors.textPrimary : context.colors.textTertiary,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  static String _formatWeeklySchedule(AppSettings s) {
    if (!s.weeklyReportEnabled) return 'Off';
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final day = days[(s.weeklyReviewWeekday - 1).clamp(0, 6)];
    final h = s.weeklyReviewHour;
    final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
    final ampm = h < 12 ? 'AM' : 'PM';
    return 'Every $day at $hour12:00 $ampm';
  }

  void _showWeeklyReviewPicker(BuildContext context, WidgetRef ref) {
    final settings = ref.read(settingsProvider);
    int weekday = settings.weeklyReviewWeekday;
    int hour = settings.weeklyReviewHour;
    AnalyticsService.instance.dialogOpened('weekly_review_schedule', screen: 'settings');
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (sheetCtx) => StatefulBuilder(
        builder: (ctx, setSheet) => Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Weekly Review Schedule', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'When should we send the recap notification?',
                style: AppTypography.body.copyWith(color: context.colors.textSecondary),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('DAY', style: AppTypography.caption.copyWith(
                color: context.colors.textTertiary, letterSpacing: 1.0,
              )),
              const SizedBox(height: AppSpacing.sm),
              Wrap(
                spacing: AppSpacing.sm,
                children: List.generate(7, (i) {
                  const labels = ['M', 'T', 'W', 'T', 'F', 'S', 'S'];
                  final d = i + 1;
                  final selected = weekday == d;
                  return GestureDetector(
                    onTap: () => setSheet(() => weekday = d),
                    child: Container(
                      width: 40, height: 40,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: selected ? context.colors.lime : context.colors.surfaceCard,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: selected ? context.colors.lime : context.colors.surfaceCardBorder,
                        ),
                      ),
                      child: Text(
                        labels[i],
                        style: AppTypography.bodyMedium.copyWith(
                          color: selected ? Colors.black : context.colors.textPrimary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  );
                }),
              ),
              const SizedBox(height: AppSpacing.lg),
              Text('HOUR', style: AppTypography.caption.copyWith(
                color: context.colors.textTertiary, letterSpacing: 1.0,
              )),
              const SizedBox(height: AppSpacing.sm),
              SizedBox(
                height: 60,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  itemCount: 24,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.xs),
                  itemBuilder: (_, h) {
                    final selected = hour == h;
                    final hour12 = h == 0 ? 12 : (h > 12 ? h - 12 : h);
                    final ampm = h < 12 ? 'AM' : 'PM';
                    return GestureDetector(
                      onTap: () => setSheet(() => hour = h),
                      child: Container(
                        width: 64,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: selected ? context.colors.lime : context.colors.surfaceCard,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                          border: Border.all(
                            color: selected ? context.colors.lime : context.colors.surfaceCardBorder,
                          ),
                        ),
                        child: Text(
                          '$hour12$ampm',
                          style: AppTypography.bodyMedium.copyWith(
                            color: selected ? Colors.black : context.colors.textPrimary,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              SizedBox(
                width: double.infinity,
                height: 48,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: context.colors.lime,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () async {
                    await ref.read(settingsProvider.notifier).setWeeklyReviewSchedule(
                      weekday: weekday, hour: hour,
                    );
                    final s = ref.read(settingsProvider);
                    if (s.notificationsEnabled && s.weeklyReportEnabled) {
                      await NotificationScheduler.instance.rescheduleAll(
                        enabled: true,
                        weeklyReviewWeekday: weekday,
                        weeklyReviewHour: hour,
                      );
                    }
                    AnalyticsService.instance.settingChanged(
                      'weekly_review_schedule', '${weekday}_$hour', screen: 'settings');
                    if (sheetCtx.mounted) Navigator.pop(sheetCtx);
                  },
                  child: const Text('Save schedule', style: TextStyle(fontWeight: FontWeight.w700)),
                ),
              ),
              const SizedBox(height: AppSpacing.md),
            ],
          ),
        ),
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: context.colors.bgSecondary,
        title: Text('Reset App', style: AppTypography.h3),
        content: Text(
          'This will clear all your data and restart the onboarding. This cannot be undone.',
          style: AppTypography.body.copyWith(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: AppTypography.bodyMedium.copyWith(color: context.colors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              // Block Firestore recovery for this session so the router
              // doesn't restore the profile and redirect back to /dashboard.
              // Uses an in-memory flag (not SharedPreferences) so the guard
              // resets on the next app launch — fixing the bug where users
              // who closed mid-reset were sent to onboarding on every future
              // sign-in.
              OnboardingNotifier.markResetInitiated();
              ref.read(aiProvider).clearCache();
              if (context.mounted) context.go('/onboarding', extra: 'from_reset');
            },
            child: Text('Reset', style: AppTypography.bodyMedium.copyWith(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    AnalyticsService.instance.dialogOpened('logout', screen: 'settings');
    showDialog(
      context: context,
      builder: (dialogCtx) => AlertDialog(
        backgroundColor: context.colors.bgSecondary,
        title: Text('Log Out', style: AppTypography.h3),
        content: Text(
          'Are you sure you want to log out?',
          style: AppTypography.body.copyWith(color: context.colors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogCtx),
            child: Text('Cancel', style: AppTypography.bodyMedium.copyWith(color: context.colors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(dialogCtx);
              AnalyticsService.instance.dialogAction('logout', 'confirmed', screen: 'settings');
              try {
                await AuthService.signOut();
                // Router redirect will handle navigation to /login
              } on Exception catch (e) {
                SnackbarService.error('Failed to log out: ${e.toString().replaceAll('Exception: ', '')}');
              }
            },
            child: Text('Log Out', style: AppTypography.bodyMedium.copyWith(color: context.colors.error)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    AnalyticsService.instance.dialogOpened('delete_account', screen: 'settings');
    final confirmCtrl = TextEditingController();
    bool canDelete = false;
    bool isDeleting = false;
    showDialog(
      context: context,
      builder: (dialogCtx) => StatefulBuilder(
        builder: (ctx, setDialogState) => AlertDialog(
          backgroundColor: context.colors.bgSecondary,
          title: Text('Delete Account', style: AppTypography.h3),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'This will permanently delete:',
                style: AppTypography.bodyMedium,
              ),
              const SizedBox(height: 8),
              for (final item in [
                '• Your Firebase account',
                '• All Firestore data (meals, workouts, progress)',
                '• All progress photos',
                '• All local app data',
              ])
                Padding(
                  padding: const EdgeInsets.only(bottom: 4),
                  child: Text(item,
                      style: AppTypography.body.copyWith(
                          color: context.colors.textSecondary)),
                ),
              const SizedBox(height: 16),
              Text(
                'Type DELETE to confirm',
                style: AppTypography.bodyMedium
                    .copyWith(color: context.colors.error),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: confirmCtrl,
                autofocus: true,
                style: AppTypography.body,
                decoration: InputDecoration(
                  hintText: 'DELETE',
                  hintStyle: AppTypography.body
                      .copyWith(color: context.colors.textTertiary),
                ),
                onChanged: (v) {
                  setDialogState(() => canDelete = v.trim() == 'DELETE');
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isDeleting ? null : () => Navigator.pop(dialogCtx),
              child: Text('Cancel',
                  style: AppTypography.bodyMedium
                      .copyWith(color: context.colors.textSecondary)),
            ),
            TextButton(
              onPressed: (!canDelete || isDeleting)
                  ? null
                  : () async {
                      setDialogState(() => isDeleting = true);
                      AnalyticsService.instance.dialogAction(
                          'delete_account', 'confirmed',
                          screen: 'settings');
                      try {
                        final prefs = await SharedPreferences.getInstance();
                        await prefs.clear();
                        ref.read(aiProvider).clearCache();
                        await AuthService.deleteAccount();
                        if (dialogCtx.mounted) Navigator.pop(dialogCtx);
                        // Router redirect will handle navigation to /login
                      } on Exception catch (_) {
                        setDialogState(() => isDeleting = false);
                        SnackbarService.error(
                            'Failed to delete account. '
                            'You may need to re-authenticate first.');
                      }
                    },
              child: isDeleting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(strokeWidth: 2))
                  : Text('Delete Permanently',
                      style: AppTypography.bodyMedium.copyWith(
                          color: canDelete
                              ? context.colors.error
                              : context.colors.textTertiary)),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm, left: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.overline.copyWith(color: context.colors.textTertiary),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String? subtitle;
  final Widget? trailing;
  final VoidCallback? onTap;

  const _SettingsTile({
    required this.icon,
    required this.label,
    this.subtitle,
    this.trailing,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 2),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
        tileColor: context.colors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: context.colors.surfaceCardBorder),
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: context.colors.bgTertiary,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 18, color: context.colors.textSecondary),
        ),
        title: Text(label, style: AppTypography.bodyMedium),
        subtitle: subtitle != null
            ? Text(subtitle!, style: AppTypography.caption.copyWith(color: context.colors.textTertiary))
            : null,
        trailing: trailing ??
            (onTap != null
                ? Icon(Icons.chevron_right_rounded, color: context.colors.textTertiary, size: 20)
                : null),
        onTap: onTap != null
            ? () {
                AnalyticsService.instance.tap(
                  label.toLowerCase().replaceAll(' ', '_').replaceAll('&', 'and'),
                  screen: 'settings',
                );
                onTap!();
              }
            : null,
      ),
    );
  }
}

class _UnitOption extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _UnitOption({required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? context.colors.limeGlow : context.colors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? context.colors.lime : context.colors.surfaceCardBorder,
          ),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTypography.bodyMedium)),
            if (isSelected) Icon(Icons.check_circle_rounded, color: context.colors.lime, size: 20),
          ],
        ),
      ),
    );
  }
}
