import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/onboarding_data.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/snackbar_service.dart';

class EditSleepScreen extends ConsumerStatefulWidget {
  const EditSleepScreen({super.key});

  @override
  ConsumerState<EditSleepScreen> createState() => _EditSleepScreenState();
}

class _EditSleepScreenState extends ConsumerState<EditSleepScreen> {
  TimeOfDay _bedtime = const TimeOfDay(hour: 23, minute: 0);
  TimeOfDay _wakeTime = const TimeOfDay(hour: 7, minute: 0);
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile != null) {
      if (profile.bedtimeHour != null) {
        _bedtime = TimeOfDay(hour: profile.bedtimeHour!, minute: profile.bedtimeMin ?? 0);
      }
      if (profile.wakeHour != null) {
        _wakeTime = TimeOfDay(hour: profile.wakeHour!, minute: profile.wakeMin ?? 0);
      }
    }
  }

  String _formatTime(TimeOfDay t) {
    final h = t.hourOfPeriod == 0 ? 12 : t.hourOfPeriod;
    final m = t.minute.toString().padLeft(2, '0');
    final p = t.period == DayPeriod.am ? 'AM' : 'PM';
    return '$h:$m $p';
  }

  double get _sleepDuration {
    var diff = (_wakeTime.hour * 60 + _wakeTime.minute) - (_bedtime.hour * 60 + _bedtime.minute);
    if (diff <= 0) diff += 24 * 60;
    return diff / 60;
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('onboarding_data');
      final data = json != null ? OnboardingData.fromJson(jsonDecode(json)) : OnboardingData();

      data.bedtimeHour = _bedtime.hour;
      data.bedtimeMin = _bedtime.minute;
      data.wakeHour = _wakeTime.hour;
      data.wakeMin = _wakeTime.minute;

      await prefs.setString('onboarding_data', jsonEncode(data.toJson()));
      final uid = AuthService.uid;
      if (uid != null) FirestoreService.saveProfile(uid, data.toJson()).catchError((_) {});
      ref.invalidate(userProfileProvider);

      if (mounted) {
        SnackbarService.success('Sleep schedule updated!');
        context.pop();
      }
    } catch (_) {
      SnackbarService.error('Failed to save.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text('Sleep Schedule', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.lime))
                : Text('Save', style: AppTypography.bodyMedium.copyWith(color: AppColors.lime)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          children: [
            _TimeTile(
              icon: Icons.bedtime_rounded,
              label: 'Bedtime',
              value: _formatTime(_bedtime),
              color: AppColors.cyan,
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: _bedtime);
                if (t != null) setState(() => _bedtime = t);
              },
            ),
            const SizedBox(height: AppSpacing.md),
            _TimeTile(
              icon: Icons.wb_sunny_rounded,
              label: 'Wake Up',
              value: _formatTime(_wakeTime),
              color: AppColors.lime,
              onTap: () async {
                final t = await showTimePicker(context: context, initialTime: _wakeTime);
                if (t != null) setState(() => _wakeTime = t);
              },
            ),
            const SizedBox(height: AppSpacing.xxl),
            Container(
              padding: const EdgeInsets.all(AppSpacing.lg),
              decoration: BoxDecoration(
                color: AppColors.surfaceCard,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.surfaceCardBorder),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.schedule_rounded, color: AppColors.textTertiary, size: 20),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${_sleepDuration.toStringAsFixed(1)} hours of sleep',
                    style: AppTypography.bodyMedium.copyWith(
                      color: _sleepDuration >= 7 ? AppColors.success : AppColors.warning,
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

class _TimeTile extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;
  final VoidCallback onTap;

  const _TimeTile({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.lg),
        decoration: BoxDecoration(
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceCardBorder),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(width: AppSpacing.md),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(label, style: AppTypography.caption.copyWith(color: AppColors.textTertiary)),
                Text(value, style: AppTypography.h3),
              ],
            ),
            const Spacer(),
            const Icon(Icons.edit_rounded, color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}
