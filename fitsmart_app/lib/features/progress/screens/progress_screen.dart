import 'package:drift/drift.dart' hide Column;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:fl_chart/fl_chart.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';

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
    _tabs = TabController(length: 4, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Progress'),
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.lime,
          indicatorWeight: 2,
          labelColor: AppColors.lime,
          unselectedLabelColor: AppColors.textTertiary,
          isScrollable: true,
          labelStyle: AppTypography.overline,
          tabs: const [
            Tab(text: 'WEIGHT'),
            Tab(text: 'STRENGTH'),
            Tab(text: 'BODY'),
            Tab(text: 'STATS'),
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

  static List<FlSpot> _toSpots(List<WeightLog> logs) {
    if (logs.isEmpty) return [];
    // logs are newest-first; reverse for chart (oldest left)
    final sorted = logs.reversed.toList();
    return sorted.asMap().entries
        .map((e) => FlSpot(e.key.toDouble(), e.value.weightKg))
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
    final weightAsync = ref.watch(filteredWeightProvider(_rangeDays));
    final profile = ref.watch(userProfileProvider).valueOrNull;
    if (weightAsync.isLoading && !weightAsync.hasValue) {
      return const Center(child: CircularProgressIndicator(color: AppColors.lime));
    }
    if (weightAsync.hasError && !weightAsync.hasValue) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Couldn\'t load weight data', style: AppTypography.body.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => ref.invalidate(filteredWeightProvider(_rangeDays)),
              child: Text('Retry', style: AppTypography.bodyMedium.copyWith(color: AppColors.lime)),
            ),
          ],
        ),
      );
    }
    final logs = weightAsync.valueOrNull ?? [];
    final spots = _toSpots(logs);
    final avgSpots = _movingAvg(spots);

    final currentWeight = logs.isNotEmpty ? logs.first.weightKg : null;
    final targetWeight = profile?.targetWeightKg;
    final weekLogs = logs.take(7).toList();
    final weekDelta = weekLogs.length >= 2
        ? weekLogs.first.weightKg - weekLogs.last.weightKg
        : null;

    // Chart y-axis bounds
    double minY = 60, maxY = 100;
    if (spots.isNotEmpty) {
      final ys = spots.map((s) => s.y).toList();
      minY = (ys.reduce((a, b) => a < b ? a : b) - 2).floorToDouble();
      maxY = (ys.reduce((a, b) => a > b ? a : b) + 2).ceilToDouble();
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        // Current weight + goal
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'CURRENT',
                value: currentWeight != null
                    ? '${currentWeight.toStringAsFixed(1)} kg'
                    : '— kg',
                sub: weekDelta != null
                    ? '${weekDelta >= 0 ? '+' : ''}${weekDelta.toStringAsFixed(1)} this week'
                    : 'No data yet',
                color: AppColors.lime,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                label: 'GOAL',
                value: targetWeight != null
                    ? '${targetWeight.toStringAsFixed(1)} kg'
                    : '— kg',
                sub: (currentWeight != null && targetWeight != null)
                    ? '${(currentWeight - targetWeight).abs().toStringAsFixed(1)} kg to go'
                    : 'Set in onboarding',
                color: AppColors.cyan,
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
                  onTap: () => setState(() => _rangeDays = r.days),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: _rangeDays == r.days
                          ? AppColors.limeGlow
                          : AppColors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: _rangeDays == r.days
                            ? AppColors.lime
                            : AppColors.surfaceCardBorder,
                      ),
                    ),
                    child: Text(
                      r.label,
                      style: AppTypography.overline.copyWith(
                        color: _rangeDays == r.days
                            ? AppColors.lime
                            : AppColors.textSecondary,
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
                        .copyWith(color: AppColors.textTertiary),
                  ),
                  if (spots.isNotEmpty)
                    Row(
                      children: [
                        _Legend(
                            color: AppColors.surfaceCardBorder, label: 'Daily'),
                        const SizedBox(width: AppSpacing.sm),
                        _Legend(color: AppColors.lime, label: '7d avg'),
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
                              color: AppColors.textTertiary),
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
                          color: AppColors.surfaceCardBorder,
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
                          color: AppColors.surfaceCardBorder,
                          barWidth: 1,
                          dotData: FlDotData(
                            show: true,
                            getDotPainter: (_, __, ___, ____) =>
                                FlDotCirclePainter(
                              radius: 2,
                              color: AppColors.surfaceCardBorder,
                              strokeWidth: 0,
                            ),
                          ),
                        ),
                        if (avgSpots.length > 1)
                          LineChartBarData(
                            spots: avgSpots,
                            isCurved: true,
                            color: AppColors.lime,
                            barWidth: 2.5,
                            dotData:
                                const FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.lime
                                      .withValues(alpha: 0.15),
                                  AppColors.lime
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
              color: AppColors.limeGlow,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border:
                  Border.all(color: AppColors.lime.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.add_rounded, color: AppColors.lime),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Log Today\'s Weight',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.lime,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ).animate(delay: 150.ms).fadeIn(duration: 300.ms),
      ],
    );
  }

  void _showLogWeight(BuildContext context) {
    final ctrl = TextEditingController();
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
                style: AppTypography.h2.copyWith(color: AppColors.lime),
                decoration: const InputDecoration(
                  hintText: '0.0',
                  suffixText: 'kg',
                ),
              ),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: isSaving
                    ? null
                    : () async {
                        final val = double.tryParse(ctrl.text.trim());
                        if (val == null || val <= 0) return;
                        setSheetState(() => isSaving = true);
                        try {
                          final db = ref.read(databaseProvider);
                          await db.insertWeight(WeightLogsCompanion(
                            weightKg: Value(val),
                            loggedAt: Value(DateTime.now()),
                          ));
                          // Sync to Firestore
                          final uid = AuthService.uid;
                          if (uid != null) {
                            FirestoreService.addWeightLog(uid, {
                              'weightKg': val,
                              'loggedAt': DateTime.now().toIso8601String(),
                            }).catchError((_) => '');
                          }
                          await ref
                              .read(gamificationProvider.notifier)
                              .awardXp(5, checkStreak: true);
                          if (context.mounted) {
                            Navigator.pop(context);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Weight logged! +5 XP ⚡'),
                                backgroundColor: AppColors.success,
                              ),
                            );
                          }
                        } catch (e) {
                          setSheetState(() => isSaving = false);
                          if (sheetCtx.mounted) {
                            ScaffoldMessenger.of(sheetCtx).showSnackBar(
                              SnackBar(
                                content: Text('Failed to save: $e'),
                                backgroundColor: AppColors.error,
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
    final prsAsync = ref.watch(personalRecordsProvider);
    if (prsAsync.isLoading && !prsAsync.hasValue) {
      return const Center(child: CircularProgressIndicator(color: AppColors.lime));
    }
    if (prsAsync.hasError && !prsAsync.hasValue) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Couldn\'t load PRs', style: AppTypography.body.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => ref.invalidate(personalRecordsProvider),
              child: Text('Retry', style: AppTypography.bodyMedium.copyWith(color: AppColors.lime)),
            ),
          ],
        ),
      );
    }
    final prs = prsAsync.valueOrNull ?? {};

    if (prs.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('🏋️', style: TextStyle(fontSize: 48)),
              const SizedBox(height: AppSpacing.md),
              Text(
                'No PRs yet',
                style: AppTypography.h3.copyWith(color: AppColors.textTertiary),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Complete workouts to see your personal records here.',
                style: AppTypography.body.copyWith(color: AppColors.textTertiary),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      );
    }

    final entries = prs.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: entries.asMap().entries.map((e) {
        final name = e.value.key;
        final weight = e.value.value;

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
                      Text(name, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
                      Text('Personal Record', style: AppTypography.caption.copyWith(color: AppColors.textTertiary)),
                    ],
                  ),
                ),
                Text(
                  '${weight.toStringAsFixed(1)} kg',
                  style: AppTypography.h3.copyWith(
                    color: AppColors.lime,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ],
            ),
          ).animate(delay: (e.key * 60).ms).fadeIn(duration: 300.ms),
        );
      }).toList(),
    );
  }
}

class _BodyTab extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final measurementAsync = ref.watch(latestMeasurementProvider);
    if (measurementAsync.isLoading && !measurementAsync.hasValue) {
      return const Center(child: CircularProgressIndicator(color: AppColors.lime));
    }
    if (measurementAsync.hasError && !measurementAsync.hasValue) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Couldn\'t load measurements', style: AppTypography.body.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => ref.invalidate(latestMeasurementProvider),
              child: Text('Retry', style: AppTypography.bodyMedium.copyWith(color: AppColors.lime)),
            ),
          ],
        ),
      );
    }
    final measurement = measurementAsync.valueOrNull;

    final entries = <(String, String)>[];
    if (measurement != null) {
      if (measurement.chestCm != null) entries.add(('Chest', '${measurement.chestCm!.toStringAsFixed(1)} cm'));
      if (measurement.waistCm != null) entries.add(('Waist', '${measurement.waistCm!.toStringAsFixed(1)} cm'));
      if (measurement.hipsCm != null) entries.add(('Hips', '${measurement.hipsCm!.toStringAsFixed(1)} cm'));
      if (measurement.bicepCm != null) entries.add(('Bicep', '${measurement.bicepCm!.toStringAsFixed(1)} cm'));
      if (measurement.thighCm != null) entries.add(('Thigh', '${measurement.thighCm!.toStringAsFixed(1)} cm'));
      if (measurement.neckCm != null) entries.add(('Neck', '${measurement.neckCm!.toStringAsFixed(1)} cm'));
      if (measurement.shouldersCm != null) entries.add(('Shoulders', '${measurement.shouldersCm!.toStringAsFixed(1)} cm'));
      if (measurement.calfCm != null) entries.add(('Calf', '${measurement.calfCm!.toStringAsFixed(1)} cm'));
    }

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('MEASUREMENTS', style: AppTypography.overline.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: AppSpacing.md),
              if (entries.isEmpty)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                    child: Column(
                      children: [
                        const Text('📏', style: TextStyle(fontSize: 36)),
                        const SizedBox(height: AppSpacing.sm),
                        Text(
                          'No measurements logged yet',
                          style: AppTypography.bodyMedium.copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                )
              else
                ...entries.map((m) => Padding(
                  padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(m.$1, style: AppTypography.body.copyWith(color: AppColors.textSecondary)),
                      Text(
                        m.$2,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                          color: AppColors.textPrimary,
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
                    style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
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
              color: AppColors.limeGlow,
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(color: AppColors.lime.withValues(alpha: 0.3)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.straighten_rounded, color: AppColors.lime),
                const SizedBox(width: AppSpacing.sm),
                Text(
                  'Update Measurements',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.lime,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
        ).animate(delay: 100.ms).fadeIn(duration: 300.ms),
      ],
    );
  }

  String _formatDate(DateTime dt) {
    final months = ['Jan','Feb','Mar','Apr','May','Jun','Jul','Aug','Sep','Oct','Nov','Dec'];
    return '${months[dt.month - 1]} ${dt.day}, ${dt.year}';
  }

  void _showLogMeasurements(BuildContext context, WidgetRef ref) {
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
              Text('Leave blank to skip (cm)', style: AppTypography.caption.copyWith(color: AppColors.textTertiary)),
              const SizedBox(height: AppSpacing.md),
              ...ctrls.entries.map((e) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: TextField(
                  controller: e.value,
                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                  decoration: InputDecoration(
                    labelText: e.key,
                    suffixText: 'cm',
                    isDense: true,
                  ),
                ),
              )),
              const SizedBox(height: AppSpacing.md),
              ElevatedButton(
                onPressed: () async {
                  double? parse(String key) {
                    final t = ctrls[key]!.text.trim();
                    return t.isEmpty ? null : double.tryParse(t);
                  }
                  final db = ref.read(databaseProvider);
                  await db.insertMeasurement(BodyMeasurementsCompanion(
                    chestCm: Value(parse('Chest')),
                    waistCm: Value(parse('Waist')),
                    hipsCm: Value(parse('Hips')),
                    bicepCm: Value(parse('Bicep')),
                    thighCm: Value(parse('Thigh')),
                    neckCm: Value(parse('Neck')),
                    shouldersCm: Value(parse('Shoulders')),
                    calfCm: Value(parse('Calf')),
                    measuredAt: Value(DateTime.now()),
                  ));
                  await ref.read(gamificationProvider.notifier).awardXp(10);
                  ref.invalidate(latestMeasurementProvider);
                  if (context.mounted) {
                    Navigator.pop(context);
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text('Measurements saved! +10 XP ⚡'),
                        backgroundColor: AppColors.success,
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
    final statsAsync = ref.watch(allTimeStatsProvider);
    if (statsAsync.isLoading && !statsAsync.hasValue) {
      return const Center(child: CircularProgressIndicator(color: AppColors.lime));
    }
    if (statsAsync.hasError && !statsAsync.hasValue) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Couldn\'t load stats', style: AppTypography.body.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => ref.invalidate(allTimeStatsProvider),
              child: Text('Retry', style: AppTypography.bodyMedium.copyWith(color: AppColors.lime)),
            ),
          ],
        ),
      );
    }
    final stats = statsAsync.valueOrNull ??
        {'meals': 0, 'workouts': 0, 'totalXp': 0, 'level': 1, 'streak': 0, 'badges': 0};

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        Row(
          children: [
            Expanded(
              child: _StatCard(
                label: 'TOTAL MEALS',
                value: '${stats['meals']}',
                sub: 'Meals logged',
                color: AppColors.lime,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                label: 'WORKOUTS',
                value: '${stats['workouts']}',
                sub: 'Sessions completed',
                color: AppColors.cyan,
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
                color: AppColors.coral,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: _StatCard(
                label: 'STREAK',
                value: '${stats['streak']}',
                sub: 'Day${(stats['streak'] as int) == 1 ? '' : 's'} streak',
                color: AppColors.warning,
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
                color: AppColors.macroFiber,
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            const Expanded(child: SizedBox()),
          ],
        ).animate(delay: 160.ms).fadeIn(duration: 300.ms),
      ],
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
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: AppTypography.overline.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTypography.h2.copyWith(color: color, fontWeight: FontWeight.w800)),
          Text(sub, style: AppTypography.caption.copyWith(color: AppColors.textTertiary)),
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
