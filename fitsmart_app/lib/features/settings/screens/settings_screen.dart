import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../../../providers/auth_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../providers/gemini_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/snackbar_service.dart';

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
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
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
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      color: AppColors.bgTertiary,
                    ),
                    child: const Center(
                      child: Icon(Icons.person_outline_rounded, color: AppColors.textTertiary, size: 28),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  Text('Guest', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                  const SizedBox(height: 4),
                  Text(
                    'Sign in to sync your data across devices',
                    style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: AppSpacing.md),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => context.go('/login'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.lime,
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
                    CircleAvatar(radius: 28, backgroundImage: NetworkImage(photoUrl))
                  else
                    Container(
                      width: 56,
                      height: 56,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          colors: [AppColors.lime, AppColors.cyan],
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          displayName.isNotEmpty ? displayName[0].toUpperCase() : '⚡',
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.w700, color: Colors.black),
                        ),
                      ),
                    ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(displayName, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                        if (email != null) ...[
                          const SizedBox(height: 2),
                          Text(email, style: AppTypography.caption.copyWith(color: AppColors.textSecondary)),
                        ],
                        const SizedBox(height: 4),
                        Text(
                          'Level ${gamification.currentLevel} · ${gamification.levelName}',
                          style: AppTypography.caption.copyWith(color: AppColors.lime),
                        ),
                        const SizedBox(height: 4),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.full),
                          child: LinearProgressIndicator(
                            value: gamification.levelProgress,
                            backgroundColor: AppColors.surfaceCard,
                            valueColor: const AlwaysStoppedAnimation(AppColors.lime),
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
            subtitle: 'Reminders & achievement alerts',
            trailing: Switch(
              value: settings.notificationsEnabled,
              onChanged: (v) => ref.read(settingsProvider.notifier).setNotifications(v),
              activeThumbColor: AppColors.lime,
            ),
          ),
          _SettingsTile(
            icon: Icons.calculate_outlined,
            label: 'Units',
            subtitle: settings.isMetric ? 'Metric (kg, cm)' : 'Imperial (lbs, ft)',
            onTap: () => _showUnitsDialog(context, ref),
          ),
          _SettingsTile(
            icon: Icons.bar_chart_rounded,
            label: 'Weekly Report',
            subtitle: 'Every Sunday recap email',
            trailing: Switch(
              value: settings.weeklyReportEnabled,
              onChanged: (v) => ref.read(settingsProvider.notifier).setWeeklyReport(v),
              activeThumbColor: AppColors.lime,
            ),
          ),

          const SizedBox(height: AppSpacing.lg),

          _SectionHeader(title: 'AI & Data'),
          _SettingsTile(
            icon: Icons.auto_awesome_outlined,
            label: 'AI Usage',
            subtitle: 'Gemini API (free tier)',
            onTap: () => _showAiUsageDialog(context),
          ),
          _SettingsTile(
            icon: Icons.cloud_upload_outlined,
            label: 'Export Data',
            subtitle: 'Download your fitness history',
            onTap: () => _showExportDialog(context, ref),
          ),
          _SettingsTile(
            icon: Icons.delete_outline_rounded,
            label: 'Clear Cache',
            subtitle: 'Reset AI response cache',
            onTap: () => _showClearCacheDialog(context, ref),
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
                  style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                ),
                Text(
                  'v1.0.0 · Built with ❤️',
                  style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.xl),

          // Reset onboarding (dev/debug)
          TextButton(
            onPressed: () => _showResetDialog(context, ref),
            child: Text(
              'Reset & Re-run Onboarding',
              style: AppTypography.caption.copyWith(color: AppColors.error),
            ),
          ),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }

  void _showAiUsageDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: Text('AI Usage', style: AppTypography.h3),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'You are using the Gemini API free tier.',
              style: AppTypography.body.copyWith(color: AppColors.textSecondary),
            ),
            const SizedBox(height: AppSpacing.md),
            Text(
              'Free tier limits are managed by Google. If you hit a quota error, wait a moment and try again.',
              style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Got it', style: AppTypography.bodyMedium.copyWith(color: AppColors.lime)),
          ),
        ],
      ),
    );
  }

  void _showExportDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: Text('Export Data', style: AppTypography.h3),
        content: Text(
          'Export all your meals, workouts, and weight logs as JSON. This file can be used to back up or transfer your data.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              SnackbarService.info('Export feature coming soon!');
            },
            child: Text('Export', style: AppTypography.bodyMedium.copyWith(color: AppColors.lime)),
          ),
        ],
      ),
    );
  }

  void _showUnitsDialog(BuildContext context, WidgetRef ref) {
    final isMetric = ref.read(settingsProvider).isMetric;
    showModalBottomSheet(
      context: context,
      backgroundColor: AppColors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppRadius.xl)),
      ),
      builder: (_) => Padding(
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
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppSpacing.sm),
            _UnitOption(
              label: 'Imperial (lbs, ft)',
              isSelected: !isMetric,
              onTap: () {
                ref.read(settingsProvider.notifier).setMetric(false);
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: AppSpacing.xl),
          ],
        ),
      ),
    );
  }

  void _showClearCacheDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: Text('Clear AI Cache', style: AppTypography.h3),
        content: Text(
          'This will remove all cached AI responses. The app will re-fetch fresh responses for meals and insights.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              ref.read(geminiClientProvider).clearCache();
              Navigator.pop(context);
              SnackbarService.success('Cache cleared successfully');
            },
            child: Text('Clear', style: AppTypography.bodyMedium.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showResetDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: Text('Reset App', style: AppTypography.h3),
        content: Text(
          'This will clear all your data and restart the onboarding. This cannot be undone.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              final prefs = await SharedPreferences.getInstance();
              await prefs.clear();
              ref.read(geminiClientProvider).clearCache();
              if (context.mounted) context.go('/onboarding');
            },
            child: Text('Reset', style: AppTypography.bodyMedium.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: Text('Log Out', style: AppTypography.h3),
        content: Text(
          'Are you sure you want to log out?',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                await AuthService.signOut();
                // Router redirect will handle navigation to /login
              } catch (e) {
                SnackbarService.error('Failed to log out. Please try again.');
              }
            },
            child: Text('Log Out', style: AppTypography.bodyMedium.copyWith(color: AppColors.error)),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: AppColors.bgSecondary,
        title: Text('Delete Account', style: AppTypography.h3),
        content: Text(
          'This will permanently delete your account and all associated data. This action cannot be undone.',
          style: AppTypography.body.copyWith(color: AppColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
          ),
          TextButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final prefs = await SharedPreferences.getInstance();
                await prefs.clear();
                ref.read(geminiClientProvider).clearCache();
                await AuthService.deleteAccount();
                SnackbarService.success('Account deleted.');
                // Router redirect will handle navigation
              } catch (e) {
                SnackbarService.error('Failed to delete account. You may need to re-authenticate first.');
              }
            },
            child: Text('Delete', style: AppTypography.bodyMedium.copyWith(color: AppColors.error)),
          ),
        ],
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
        style: AppTypography.overline.copyWith(color: AppColors.textTertiary),
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
        tileColor: AppColors.surfaceCard,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(color: AppColors.surfaceCardBorder),
        ),
        leading: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: AppColors.bgTertiary,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          child: Icon(icon, size: 18, color: AppColors.textSecondary),
        ),
        title: Text(label, style: AppTypography.bodyMedium),
        subtitle: subtitle != null
            ? Text(subtitle!, style: AppTypography.caption.copyWith(color: AppColors.textTertiary))
            : null,
        trailing: trailing ??
            (onTap != null
                ? const Icon(Icons.chevron_right_rounded, color: AppColors.textTertiary, size: 20)
                : null),
        onTap: onTap,
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
          color: isSelected ? AppColors.limeGlow : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected ? AppColors.lime : AppColors.surfaceCardBorder,
          ),
        ),
        child: Row(
          children: [
            Expanded(child: Text(label, style: AppTypography.bodyMedium)),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.lime, size: 20),
          ],
        ),
      ),
    );
  }
}
