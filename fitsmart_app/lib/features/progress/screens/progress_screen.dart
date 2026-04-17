import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/liquid_glass.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/analytics_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../widgets/photo_comparison_view.dart';
import '../../../core/widgets/empty_state_widget.dart';

// Conversion helpers — DB stores kg/cm, display converts if imperial
double _kgToDisplay(double kg, bool isMetric) => isMetric ? kg : kg * 2.20462;
double _displayToKg(double val, bool isMetric) => isMetric ? val : val / 2.20462;
double _cmToDisplay(double cm, bool isMetric) => isMetric ? cm : cm / 2.54;
double _displayToCm(double val, bool isMetric) => isMetric ? val : val * 2.54;
String _weightUnit(bool isMetric) => isMetric ? 'kg' : 'lbs';
String _lengthUnit(bool isMetric) => isMetric ? 'cm' : 'in';

class ProgressScreen extends StatefulWidget {
  const ProgressScreen({super.key});

  @override
  State<ProgressScreen> createState() => _ProgressScreenState();
}

class _ProgressScreenState extends State<ProgressScreen>
    with TickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 5, vsync: this);
    _tabs.addListener(() {
      if (_tabs.indexIsChanging) return;
      const names = ['weight', 'strength', 'body', 'stats', 'photos'];
      AnalyticsService.instance.tabSwitch(
        names[_tabs.index],
        screen: 'progress',
        from: names[_tabs.previousIndex],
      );
    });
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: LiquidAppBar(
        title: const Text('Progress'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: colors.lime,
          indicatorWeight: 2,
          labelColor: colors.lime,
          unselectedLabelColor: colors.textTertiary,
          isScrollable: true,
          labelStyle: AppTypography.overline,
          tabs: const [
            Tab(text: 'WEIGHT'),
            Tab(text: 'STRENGTH'),
            Tab(text: 'BODY'),
            Tab(text: 'STATS'),
            Tab(text: 'PHOTOS'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          const _WeightTab(),
          _StrengthTab(),
          _BodyTab(),
          _StatsTab(),
          const PhotoComparisonView(),
        ],
      ),
    );
  }
}

class _WeightTab extends ConsumerStatefulWidget {
  const _WeightTab();

  @override
  ConsumerState<_WeightTab> createState() => _WeightTabState();
}

class _WeightTabState extends ConsumerState<_WeightTab> {
  int _rangeDays = 30; // 7 = week, 30 = month, 0 = all

  static List<FlSpot> _toSpots(List<WeightLog> logs, bool isMetric) {
    if (logs.isEmpty) return [];
    // logs are newest-first; reverse for chart (oldest left)
    final sorted = logs.reversed.toList();
    return sorted.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), _kgToDisplay(e.value.weightKg, isMetric)))
        .toList();
  }

  static List<FlSpot> _movingAvg(List<FlSpot> spots) {
    if (spots.length < 2) return spots;
    return List.generate(spots.length, (i) {
      final start = (i - 3).clamp(0, spots.length - 1);
      final end = (i + 3).clamp(0, spots.length - 1);
      final slice = spots.sublist(start, end + 1);
      final avg = slice.fold(0.0, (s, e) => s + e.y) / slice.length;
      return FlSpot(i.toDouble(), avg);
    });
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final isMetric = ref.watch(settingsProvider).isMetric;
    final unit = _weightUnit(isMetric);
    final weightAsync = ref.watch(filteredWeightProvider(_rangeDays));
    final profile = ref.watch(userProfileProvider).valueOrNull;
    if (weightAsync.isLoading && !weightAsync.hasValue) {
      return Center(child: CircularProgressIndicator(color: colors.lime));
    }
    if (weightAsync.hasError && !weightAsync.hasValue) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Couldn\'t load weight data', style: AppTypography.body.copyWith(color: colors.textTertiary)),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => ref.invalidate(filteredWeightProvider(_rangeDays)),
              child: Text('Retry', style: AppTypography.bodyMedium.copyWith(color: colors.lime)),
            ),
          ],
        ),
      );
    }
    final logs = weightAsync.valueOrNull ?? [];
    final spots = _toSpots(logs, isMetric);
    final avgSpots = _movingAvg(spots);

    final currentWeight = logs.isNotEmpty ? _kgToDisplay(logs.first.weightKg, isMetric) : null;
    final targetWeight = profile?.targetWeightKg != null ? _kgToDisplay(profile!.targetWeightKg!, isMetric) : null;
    final weekLogs = logs.take(7).toList();
    final weekDelta = weekLogs.length >= 2
        ? _kgToDisplay(weekLogs.first.weightKg, isMetric) - _kgToDisplay(weekLogs.last.weightKg, isMetric)
        : null;

    // Chart y-axis bounds
    double minY = 60, maxY = 100;
    if (spots.isNotEmpty) {
      final ys = spots.map((s) => s.y).toList();
      minY = (ys.reduce((a, b) => a < b ? a : b) - 2).floorToDouble();
      maxY = (ys.reduce((a, b) => a > b ? a : b) + 2).ceilToDouble();
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(filteredWeightProvider(_rangeDays));
        await Future.delayed(const Duration(milliseconds: 600));
      },
      color: context.colors.lime,
      backgroundColor: context.colors.bgSecondary,
      child: ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        // Current weight + goal
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'CURRENT',
                value: currentWeight != null
                    ? '${currentWeight.toStringAsFixed(1)} $unit'
                    : '— $unit',
                sub: weekDelta != null
                    ? '${weekDelta >= 0 ? '+' : ''}${weekDelta.toStringAsFixed(1)} this week'
                    : 'No data yet',
                color: colors.lime,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                label: 'GOAL',
                value: targetWeight != null
                    ? '${targetWeight.toStringAsFixed(1)} $unit'
                    : '— $unit',
                sub: (currentWeight != null && targetWeight != null)
                    ? '${(currentWeight - targetWeight).abs().toStringAsFixed(1)} $unit to go'
                    : 'Set in onboarding',
                color: colors.cyan,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppSpacing.md),

        // Date range selector
        Row(
          children: [
            for (final r in [(label: '1W', days: 7), (label: '1M', days: 30), (label: 'ALL', days: 0)])
              Padding(
                padding: const EdgeInsets.only(right: AppSpacing.sm),
                child: GestureDetector(
                  onTap: () {
                    setState(() => _rangeDays = r.days);
                    AnalyticsService.instance.tap(
                      'weight_range_${r.label.toLowerCase()}',
                      screen: 'progress',
                      props: {'days': r.days},
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _rangeDays == r.days
                          ? colors.limeGlow
                          : colors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: _rangeDays == r.days
                            ? colors.lime
                            : colors.surfaceCardBorder,
                      ),
                    ),
                    child: Text(
                      r.label,
                      style: AppTypography.overline.copyWith(
                        color: _rangeDays == r.days
                            ? colors.lime
                            : colors.textSecondary,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),

        // Chart
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'WEIGHT TREND',
                    style: AppTypography.overline
                        .copyWith(color: colors.textTertiary),
                  ),
                  if (spots.isNotEmpty)
                    Row(
                      children: [
                        _Legend(
                            color: colors.surfaceCardBorder, label: 'Daily'),
                        const SizedBox(width: AppSpacing.sm),
                        _Legend(color: colors.lime, label: '7d avg'),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: AppSpacing.sectionGap),
              if (spots.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: AppSpacing.xl),
                    child: Column(
                      children: [
                        const Text('⚖️',
                            style: TextStyle(fontSize: 36)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'Log your weight to see trends',
                          style: AppTypography.bodyMedium.copyWith(
                              color: colors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                SizedBox(
                  height: 200,
                  child: LineChart(
                    LineChartData(
                      backgroundColor: Colors.transparent,
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: 1,
                        getDrawingHorizontalLine: (_) => FlLine(
                          color: colors.surfaceCardBorder,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            reservedSize: 40,
                            getTitlesWidget: (v, _) => Text(
                              '${v.toInt()}',
                              style: AppTypography.overline
                                  .copyWith(fontSize: 9),
                            ),
                          ),
                        ),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: (spots.length / 4)
                                .ceilToDouble()
                                .clamp(1, double.infinity),
                            getTitlesWidget: (v, _) => Text(
                              'D${v.toInt() + 1}',
                              style: AppTypography.overline
                                  .copyWith(fontSize: 9),
                            ),
                          ),
                        ),
                        topTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(
                            sideTitles:
                                SideTitles(showTitles: false)),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: spots,
                          isCurved: false,
                          color: colors.surfaceCardBorder,
                          barWidth: 1,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (_, __, ___, ____) =>
                                FlDotCirclePainter(
                              radius: 2,
                              color: colors.surfaceCardBorder,
                              strokeWidth: 0,
                            ),
                          ),
                        ),
                        if (avgSpots.length > 1)
                          LineChartBarData(
                            spots: avgSpots,
                            isCurved: true,
                            color: colors.lime,
                            barWidth: 2.5,
                            dotData:
                                const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  colors.lime
                                      .withValues(alpha: 0.15),
                                  colors.lime
                                      .withValues(alpha: 0.0),
                                ],
                                begin: Alignment.topCenter,
                                end: Alignment.bottomCenter,
                              ),
                            ),
                          ),
                      ],
                      minY: minY,
                      maxY: maxY,
                    ),
                  ),
                ),
            ],
          ),
        ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
        const SizedBox(height: AppSpacing.md),

        // Log weight button
        GestureDetector(
          onTap: () => _showLogWeight(context),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: colors.limeGlow,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border:
                  Border.all(color: colors.lime.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.add_rounded, color: colors.lime),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Log Today\'s Weight',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.lime,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ).animate(delay: 150.ms).fadeIn(duration: 300.ms),
      ],
      ),
    );
  }

  void _showLogWeight(BuildContext context) {
    AnalyticsService.instance.dialogOpened('log_weight', screen: 'progress');
    final ctrl = TextEditingController();
    final isMetric = ref.read(settingsProvider).isMetric;
    final unit = _weightUnit(isMetric);
    bool isSaving = false;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => StatefulBuilder(
        builder: (sheetCtx, setSheetState) => Padding(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
            left: 20,
            right: 20,
            top: 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log Weight', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: ctrl,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                style: AppTypography.h2.copyWith(color: context.colors.lime),
                decoration: InputDecoration(
                  hintText: '0.0',
                  suffixText: unit,
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final rawVal = double.tryParse(ctrl.text.trim());
                        if (rawVal == null || rawVal <= 0) return;
                        final val = _displayToKg(rawVal, isMetric);
                        setSheetState(() => isSaving = true);
                        try {
                          final db = ref.read(databaseProvider);
                          final loggedAt = DateTime.now();
                          final localId =
                              await db.insertWeight(WeightLogsCompanion(
                            weightKg: Value(val),
                            loggedAt: Value(loggedAt),
                          ));
                          AnalyticsService.instance.track('weight_logged', props: {
                            'weight_kg': val,
                            'unit': isMetric ? 'kg' : 'lbs',
                          });
                          // Sync to Firestore — write cloudId back on success.
                          final uid = AuthService.uid;
                          if (uid != null) {
                            FirestoreService.addWeightLog(uid, {
                              'weightKg': val,
                              'loggedAt': loggedAt.toIso8601String(),
                            }).then((cloudId) {
                              if (cloudId.isNotEmpty) {
                                db.setWeightCloudId(localId, cloudId);
                              }
                            }).catchError((Object e) {
                              debugPrint('[Firestore] weight sync failed: $e');
                            });
                          }
                          await ref
                              .read(gamificationProvider.notifier)
                              .awardXp(5, checkStreak: true);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Weight logged! +5 XP ⚡'),
                                backgroundColor: context.colors.success,
                              ),
                            );
                          }
                        } catch (e) {
                          setSheetState(() => isSaving = false);
                          if (sheetCtx.mounted) {
                            ScaffoldMessenger.of(sheetCtx).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save: $e'),
                                backgroundColor: sheetCtx.colors.error,
                              ),
                            );
                          }
                        }
                      },
                child: isSaving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(
                            strokeWidth: 2, color: Colors.white))
                    : const Text('Save (+5 XP)'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _StrengthTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isMetric = ref.watch(settingsProvider).isMetric;
    final unit = _weightUnit(isMetric);
    final prsAsync = ref.watch(personalRecordsProvider);
    final oneRmsAsync = ref.watch(best1RmsProvider);
    if (prsAsync.isLoading && !prsAsync.hasValue) {
      return Center(child: CircularProgressIndicator(color: colors.lime));
    }
    if (prsAsync.hasError && !prsAsync.hasValue) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Couldn\'t load PRs', style: AppTypography.body.copyWith(color: colors.textTertiary)),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => ref.invalidate(personalRecordsProvider),
              child: Text('Retry', style: AppTypography.bodyMedium.copyWith(color: colors.lime)),
            ),
          ],
        ),
      );
    }
    final prs = prsAsync.valueOrNull ?? {};
    final oneRms = oneRmsAsync.valueOrNull ?? {};

    if (prs.isEmpty) {
      return Center(
        child: EmptyStateWidget(
          emoji: '🏋️',
          headline: 'No personal records yet',
          body: 'Complete workouts to see your PRs and estimated 1RMs here.',
        ),
      );
    }

    final entries = prs.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(personalRecordsProvider);
        await Future.delayed(const Duration(milliseconds: 600));
      },
      color: context.colors.lime,
      backgroundColor: context.colors.bgSecondary,
      child: ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        ...entries.asMap().entries.map((e) {
          final name = e.value.key;
          final weight = e.value.value;
          final est1rm = oneRms[name];

          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              child: Row(
                children: [
                  const Text('🏆', style: TextStyle(fontSize: 28)),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(name,
                            style: AppTypography.bodyMedium
                                .copyWith(fontWeight: FontWeight.w700)),
                        Text('PR: ${_kgToDisplay(weight, isMetric).toStringAsFixed(1)} $unit',
                            style: AppTypography.caption
                                .copyWith(color: colors.textTertiary)),
                        if (est1rm != null)
                          Text(
                            'Est. 1RM: ${_kgToDisplay(est1rm, isMetric).toStringAsFixed(1)} $unit',
                            style: AppTypography.caption
                                .copyWith(color: colors.cyan),
                          ),
                      ],
                    ),
                  ),
                  Text(
                    '${_kgToDisplay(weight, isMetric).toStringAsFixed(1)} $unit',
                    style: AppTypography.h3.copyWith(
                      color: colors.lime,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ).animate(delay: (e.key * 60).ms).fadeIn(duration: 300.ms),
          );
        }),
        if (entries.isNotEmpty) ...[
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Estimated 1RM uses the Epley formula: weight × (1 + reps / 30).',
            style: AppTypography.caption.copyWith(color: colors.textTertiary),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ],
      ),
    );
  }
}

class _BodyTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final isMetric = ref.watch(settingsProvider).isMetric;
    final unit = _lengthUnit(isMetric);
    final measurementAsync = ref.watch(latestMeasurementProvider);
    if (measurementAsync.isLoading && !measurementAsync.hasValue) {
      return Center(child: CircularProgressIndicator(color: colors.lime));
    }
    if (measurementAsync.hasError && !measurementAsync.hasValue) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Couldn\'t load measurements', style: AppTypography.body.copyWith(color: colors.textTertiary)),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => ref.invalidate(latestMeasurementProvider),
              child: Text('Retry', style: AppTypography.bodyMedium.copyWith(color: colors.lime)),
            ),
          ],
        ),
      );
    }
    final measurement = measurementAsync.valueOrNull;

    final entries = <(String, String)>[];
    if (measurement != null) {
      String fmt(double cm) => '${_cmToDisplay(cm, isMetric).toStringAsFixed(1)} $unit';
      if (measurement.chestCm != null) entries.add(('Chest', fmt(measurement.chestCm!)));
      if (measurement.waistCm != null) entries.add(('Waist', fmt(measurement.waistCm!)));
      if (measurement.hipsCm != null) entries.add(('Hips', fmt(measurement.hipsCm!)));
      if (measurement.bicepCm != null) entries.add(('Bicep', fmt(measurement.bicepCm!)));
      if (measurement.thighCm != null) entries.add(('Thigh', fmt(measurement.thighCm!)));
      if (measurement.neckCm != null) entries.add(('Neck', fmt(measurement.neckCm!)));
      if (measurement.shouldersCm != null) entries.add(('Shoulders', fmt(measurement.shouldersCm!)));
      if (measurement.calfCm != null) entries.add(('Calf', fmt(measurement.calfCm!)));
    }

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(latestMeasurementProvider);
        await Future.delayed(const Duration(milliseconds: 600));
      },
      color: context.colors.lime,
      backgroundColor: context.colors.bgSecondary,
      child: ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MEASUREMENTS', style: AppTypography.overline.copyWith(color: colors.textTertiary)),
              const SizedBox(height: AppSpacing.md),
              if (entries.isEmpty)
                EmptyStateWidget(
                  emoji: '📏',
                  headline: 'No measurements yet',
                  body: 'Log your body measurements to track your transformation over time.',
                  compact: true,
                )
              else
                ...entries.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(m.$1, style: AppTypography.body.copyWith(color: colors.textSecondary)),
                      Text(
                        m.$2,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: colors.textPrimary,
                        ),
                      ),
                    ],
                  ),
                )),
              if (measurement != null)
                Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Text(
                    'Last updated: ${_formatDate(measurement.measuredAt)}',
                    style: AppTypography.caption.copyWith(color: colors.textTertiary),
                  ),
                ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppSpacing.md),
        GestureDetector(
          onTap: () => _showLogMeasurements(context, ref),
          child: Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: colors.limeGlow,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: colors.lime.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.straighten_rounded, color: colors.lime),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Update Measurements',
                  style: AppTypography.bodyMedium.copyWith(
                    color: colors.lime,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
      ],
      ),
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  void _showLogMeasurements(BuildContext context, WidgetRef ref) {
    final isMetric = ref.read(settingsProvider).isMetric;
    final unit = _lengthUnit(isMetric);
    final ctrls = {
      'Chest': TextEditingController(),
      'Waist': TextEditingController(),
      'Hips': TextEditingController(),
      'Bicep': TextEditingController(),
      'Thigh': TextEditingController(),
      'Neck': TextEditingController(),
      'Shoulders': TextEditingController(),
      'Calf': TextEditingController(),
    };

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (_) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          left: 20,
          right: 20,
          top: 20,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Log Measurements', style: AppTypography.h3),
              const SizedBox(height: AppSpacing.sm),
              Text('Leave blank to skip ($unit)', style: AppTypography.caption.copyWith(color: context.colors.textTertiary)),
              const SizedBox(height: AppSpacing.md),
              ...ctrls.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: TextField(
                  controller: e.value,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: e.key,
                    suffixText: unit,
                    isDense: true,
                  ),
                ),
              )),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () async {
                  double? parse(String key) {
                    final t = ctrls[key]!.text.trim();
                    if (t.isEmpty) return null;
                    final v = double.tryParse(t);
                    return v != null ? _displayToCm(v, isMetric) : null;
                  }
                  final db = ref.read(databaseProvider);
                  final measuredAt = DateTime.now();
                  final localId = await db.insertMeasurement(
                      BodyMeasurementsCompanion(
                    chestCm: Value(parse('Chest')),
                    waistCm: Value(parse('Waist')),
                    hipsCm: Value(parse('Hips')),
                    bicepCm: Value(parse('Bicep')),
                    thighCm: Value(parse('Thigh')),
                    neckCm: Value(parse('Neck')),
                    shouldersCm: Value(parse('Shoulders')),
                    calfCm: Value(parse('Calf')),
                    measuredAt: Value(measuredAt),
                  ));

                  // Sync to Firestore — write cloudId back on success.
                  final uid = AuthService.uid;
                  if (uid != null) {
                    final payload = <String, dynamic>{
                      'measuredAt': measuredAt.toIso8601String(),
                    };
                    final fields = {
                      'Chest': 'chestCm', 'Waist': 'waistCm',
                      'Hips': 'hipsCm', 'Bicep': 'bicepCm',
                      'Thigh': 'thighCm', 'Neck': 'neckCm',
                      'Shoulders': 'shouldersCm', 'Calf': 'calfCm',
                    };
                    fields.forEach((label, key) {
                      final v = parse(label);
                      if (v != null) payload[key] = v;
                    });
                    FirestoreService.addBodyMeasurement(uid, payload)
                        .then((cloudId) {
                          if (cloudId.isNotEmpty) {
                            db.setMeasurementCloudId(localId, cloudId);
                          }
                        })
                        .catchError((Object e) {
                          debugPrint(
                              '[Firestore] measurement sync failed: $e');
                        });
                  }

                  AnalyticsService.instance.track('body_measurement_logged', props: {
                    'fields_filled': ctrls.values.where((c) => c.text.trim().isNotEmpty).length,
                    'unit': isMetric ? 'cm' : 'in',
                  });
                  await ref.read(gamificationProvider.notifier).awardXp(10);
                  ref.invalidate(latestMeasurementProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: const Text('Measurements saved! +10 XP ⚡'),
                        backgroundColor: context.colors.success,
                      ),
                    );
                  }
                },
                child: const Text('Save (+10 XP)'),
              ),
              const SizedBox(height: 8),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatsTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final statsAsync = ref.watch(allTimeStatsProvider);
    if (statsAsync.isLoading && !statsAsync.hasValue) {
      return Center(child: CircularProgressIndicator(color: colors.lime));
    }
    if (statsAsync.hasError && !statsAsync.hasValue) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Couldn\'t load stats', style: AppTypography.body.copyWith(color: colors.textTertiary)),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => ref.invalidate(allTimeStatsProvider),
              child: Text('Retry', style: AppTypography.bodyMedium.copyWith(color: colors.lime)),
            ),
          ],
        ),
      );
    }
    final stats = statsAsync.valueOrNull ??
        {'meals': 0, 'workouts': 0, 'totalXp': 0, 'level': 1, 'streak': 0, 'badges': 0};

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(allTimeStatsProvider);
        await Future.delayed(const Duration(milliseconds: 600));
      },
      color: context.colors.lime,
      backgroundColor: context.colors.bgSecondary,
      child: ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'TOTAL MEALS',
                value: '${stats['meals']}',
                sub: 'Meals logged',
                color: colors.lime,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                label: 'WORKOUTS',
                value: '${stats['workouts']}',
                sub: 'Sessions completed',
                color: colors.cyan,
              ),
            ),
          ],
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'TOTAL XP',
                value: '${stats['totalXp']}',
                sub: 'Level ${stats['level']}',
                color: colors.coral,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                label: 'STREAK',
                value: '${stats['streak']}',
                sub: 'Day${(stats['streak'] as int) == 1 ? '' : 's'} streak',
                color: colors.warning,
              ),
            ),
          ],
        ).animate(delay: 80.ms).fadeIn(duration: 300.ms),
        const SizedBox(height: AppSpacing.md),
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'BADGES',
                value: '${stats['badges']}',
                sub: 'Unlocked',
                color: AppColorsExtension.macroFiber,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(child: SizedBox()),
          ],
        ).animate(delay: 160.ms).fadeIn(duration: 300.ms),
      ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String sub;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.sub,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.overline.copyWith(color: colors.textTertiary)),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTypography.h2.copyWith(color: color, fontWeight: FontWeight.w800)),
          Text(sub, style: AppTypography.caption.copyWith(color: colors.textTertiary)),
        ],
      ),
    );
  }
}

class _Legend extends StatelessWidget {
  final Color color;
  final String label;
  const _Legend({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(width: 12, height: 3, color: color),
        const SizedBox(width: 4),
        Text(label, style: AppTypography.overline),
      ],
    );
  }
}
