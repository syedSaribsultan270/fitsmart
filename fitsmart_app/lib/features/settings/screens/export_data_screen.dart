import 'package:flutter/material.dart';
import '../../../core/widgets/liquid_glass.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../data/database/database_provider.dart';
import '../../../services/export_service.dart';
import '../../../services/snackbar_service.dart';

class ExportDataScreen extends ConsumerStatefulWidget {
  const ExportDataScreen({super.key});

  @override
  ConsumerState<ExportDataScreen> createState() => _ExportDataScreenState();
}

class _ExportDataScreenState extends ConsumerState<ExportDataScreen> {
  bool _isExporting = false;

  Future<void> _export() async {
    if (_isExporting) return;
    setState(() => _isExporting = true);
    try {
      final db = ref.read(databaseProvider);
      final path = await ExportService.instance.exportAll(db);
      if (!mounted) return;
      if (path == null) {
        SnackbarService.error('Export failed. Please try again.');
        return;
      }
      final file = XFile(path, mimeType: 'application/zip');
      await Share.shareXFiles(
        [file],
        text: 'My FitSmart data export — ${DateTime.now().toIso8601String().substring(0, 10)}',
      );
    } finally {
      if (mounted) setState(() => _isExporting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: LiquidAppBar(
        title: Text('Export My Data',
            style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          // Info card
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: colors.surfaceCard,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.surfaceCardBorder),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.shield_outlined, color: colors.lime, size: 22),
                    const SizedBox(width: AppSpacing.sm),
                    Text('Your Data, Your Rights',
                        style: AppTypography.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700)),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'Download a complete copy of your FitSmart data as a ZIP archive. '
                  'This is your right under GDPR and similar privacy laws.',
                  style: AppTypography.body
                      .copyWith(color: colors.textSecondary),
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),

          const SizedBox(height: AppSpacing.sectionGap),

          Text('WHAT\'S INCLUDED',
              style: AppTypography.overline
                  .copyWith(color: colors.textTertiary)),
          const SizedBox(height: AppSpacing.sm),

          ...[
            (Icons.restaurant_outlined, 'meal_logs.csv',
                'Every meal you\'ve logged'),
            (Icons.fitness_center_rounded, 'workout_logs.csv',
                'All completed workouts'),
            (Icons.straighten_rounded, 'workout_sets.csv',
                'Individual sets with weight & reps'),
            (Icons.monitor_weight_outlined, 'weight_logs.csv',
                'Weight history'),
            (Icons.accessibility_new_rounded, 'body_measurements.csv',
                'Body measurements'),
            (Icons.calendar_month_outlined, 'daily_summaries.csv',
                'Daily nutrition + streak summaries'),
          ].asMap().entries.map((e) {
            final (icon, filename, desc) = e.value;
            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                tileColor: colors.surfaceCard,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  side: BorderSide(color: colors.surfaceCardBorder),
                ),
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: colors.bgTertiary,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: Icon(icon, size: 18, color: colors.textSecondary),
                ),
                title: Text(filename,
                    style: AppTypography.bodyMedium
                        .copyWith(fontFamily: 'GoogleSansFlex', fontSize: 13)),
                subtitle: Text(desc,
                    style: AppTypography.caption
                        .copyWith(color: colors.textTertiary)),
              ).animate(delay: (e.key * 50).ms).fadeIn(duration: 250.ms),
            );
          }),

          const SizedBox(height: AppSpacing.sectionGap),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: _isExporting ? null : _export,
              icon: _isExporting
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                          strokeWidth: 2, color: Colors.black))
                  : const Icon(Icons.download_rounded, size: 18),
              label: Text(_isExporting ? 'Preparing export…' : 'Export & Share ZIP'),
              style: ElevatedButton.styleFrom(
                backgroundColor: colors.lime,
                foregroundColor: Colors.black,
                disabledBackgroundColor: colors.lime.withAlpha(120),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md)),
                textStyle: AppTypography.bodyMedium
                    .copyWith(fontWeight: FontWeight.w700),
              ),
            ),
          ).animate(delay: 350.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: AppSpacing.md),

          Text(
            'The ZIP is created locally on your device and shared only via the system share sheet — '
            'FitSmart never uploads your export to any server.',
            style: AppTypography.caption
                .copyWith(color: colors.textTertiary),
            textAlign: TextAlign.center,
          ).animate(delay: 400.ms).fadeIn(duration: 300.ms),

          const SizedBox(height: AppSpacing.xl),
        ],
      ),
    );
  }
}
