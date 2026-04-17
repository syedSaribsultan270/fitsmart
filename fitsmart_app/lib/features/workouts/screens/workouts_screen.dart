import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/liquid_glass.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../../../providers/gemini_provider.dart';
import '../../../services/analytics_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/snackbar_service.dart';
import '../../../services/user_context_service.dart';
import '../../../core/widgets/empty_state_widget.dart';

class WorkoutsScreen extends ConsumerStatefulWidget {
  const WorkoutsScreen({super.key});

  @override
  ConsumerState<WorkoutsScreen> createState() => _WorkoutsScreenState();
}

class _WorkoutsScreenState extends ConsumerState<WorkoutsScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) return;
      const names = ['today', 'plans', 'library'];
      AnalyticsService.instance.tabSwitch(names[_tabs.index], screen: 'workouts');
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
        title: const Text('Workouts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.play_circle_rounded),
            color: colors.lime,
            onPressed: () {
              AnalyticsService.instance.tap('start_workout_fab', screen: 'workouts');
              context.push('/workouts/active');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: colors.lime,
          indicatorWeight: 2,
          labelColor: colors.lime,
          unselectedLabelColor: colors.textTertiary,
          labelStyle: AppTypography.overline,
          tabs: const [
            Tab(text: 'TODAY'),
            Tab(text: 'PLANS'),
            Tab(text: 'LIBRARY'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: const [
          _TodayTab(),
          _PlansTab(),
          _LibraryTab(),
        ],
      ),
    );
  }
}

// ── Today Tab ──────────────────────────────────────────────────────────────

class _TodayTab extends ConsumerWidget {
  const _TodayTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final todaysWorkoutsAsync = ref.watch(todaysWorkoutsProvider);
    final plansAsync = ref.watch(workoutPlansProvider);
    final workouts = todaysWorkoutsAsync.valueOrNull ?? [];

    // ── Resolve today's workout from the active plan ──────────────────
    final planned = ref.watch(todaysPlannedWorkoutProvider);
    final hasPlan = planned.hasPlan;
    final workoutName = planned.workoutName;
    final dayExercises = planned.exercises;
    final focusLabel = planned.focusLabel;
    final estMinutes = planned.estMinutes;

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        // ── Plan loading ──
        if (plansAsync.isLoading && !plansAsync.hasValue)
          AppCard(
            child: Center(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.sectionGap),
                child:
                    CircularProgressIndicator(color: colors.lime),
              ),
            ),
          )
        // ── Plan error ──
        else if (plansAsync.hasError && !plansAsync.hasValue)
          AppCard(
            child: Column(
              children: [
                const Text('⚠️', style: TextStyle(fontSize: 28)),
                const SizedBox(height: AppSpacing.sm),
                Text('Couldn\'t load workout plan',
                    style: AppTypography.body
                        .copyWith(color: colors.textTertiary)),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: () =>
                      ref.invalidate(workoutPlansProvider),
                  child: Text('Retry',
                      style: AppTypography.bodyMedium
                          .copyWith(color: colors.lime)),
                ),
              ],
            ),
          )
        // ── No active plan ──
        else if (!hasPlan)
          GlowCard(
            glowColor: colors.cyan,
            child: Column(
              children: [
                const Text('📋', style: TextStyle(fontSize: 36)),
                const SizedBox(height: AppSpacing.md),
                Text('No Active Workout Plan',
                    style: AppTypography.h3
                        .copyWith(fontWeight: FontWeight.w700)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'Generate an AI plan in the Plans tab, or start a quick workout.',
                  style: AppTypography.body
                      .copyWith(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                AppButton(
                  label: '🏋️  Quick Workout',
                  onPressed: () {
                    AnalyticsService.instance.tap('quick_workout_btn', screen: 'workouts', props: {'context': 'no_plan'});
                    context.push('/workouts/active');
                  },
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms)
        // ── Rest day ──
        else if (planned.hasPlan && planned.exercises.isEmpty)
          GlowCard(
            glowColor: colors.success,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const Text('🧘', style: TextStyle(fontSize: 36)),
                const SizedBox(height: AppSpacing.md),
                Text('Rest Day',
                    style: AppTypography.h2
                        .copyWith(fontWeight: FontWeight.w800)),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  'No workout scheduled today. Recover and come back stronger!',
                  style: AppTypography.body
                      .copyWith(color: colors.textSecondary),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.sectionGap),
                AppButton(
                  label: '🏋️  Quick Workout',
                  variant: AppButtonVariant.secondary,
                  onPressed: () {
                    AnalyticsService.instance.tap('quick_workout_btn', screen: 'workouts', props: {'context': 'rest_day'});
                    context.push('/workouts/active');
                  },
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms)
        // ── Today's scheduled workout ──
        else
          GlowCard(
            glowColor: colors.cyan,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color:
                            colors.cyan.withValues(alpha: 0.15),
                        borderRadius:
                            BorderRadius.circular(AppRadius.full),
                      ),
                      child: Text(
                        'TODAY',
                        style: AppTypography.overline
                            .copyWith(color: colors.cyan),
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '~$estMinutes min',
                      style: AppTypography.caption
                          .copyWith(color: colors.textTertiary),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.md),
                Text(
                  workoutName,
                  style: AppTypography.h2
                      .copyWith(fontWeight: FontWeight.w800),
                ),
                Text(
                  focusLabel,
                  style: AppTypography.bodyMedium
                      .copyWith(color: colors.textSecondary),
                ),
                if (dayExercises.isNotEmpty) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Text(
                    '${dayExercises.length} exercise${dayExercises.length > 1 ? 's' : ''}',
                    style: AppTypography.caption.copyWith(
                      color: colors.textTertiary,
                    ),
                  ),
                ],
                const SizedBox(height: AppSpacing.sectionGap),
                AppButton(
                  label: '🏋️  Start Workout (+25 XP)',
                  onPressed: () {
                    AnalyticsService.instance.tap('start_planned_workout', screen: 'workouts', props: {'workout': workoutName});
                    context.push(
                      '/workouts/active',
                      extra: planned.rawDayJson,
                    );
                  },
                ),
              ],
            ),
          ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppSpacing.md),

        // Today's completed workouts
        if (workouts.isEmpty)
          EmptyStateWidget(
            emoji: '🎯',
            headline: 'No workouts logged yet',
            body: 'Complete a workout to see your stats here.',
            ctaLabel: 'Start a Workout',
            onCta: () {
              AnalyticsService.instance.tap('start_workout_empty_state', screen: 'workouts');
              context.push('/workouts/active');
            },
          ).animate().fadeIn(duration: 300.ms, delay: 200.ms)
        else if (workouts.isNotEmpty) ...[
          Text(
            'COMPLETED TODAY',
            style: AppTypography.overline
                .copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.sm),
          ...workouts.map((w) => Padding(
                padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                child: Dismissible(
                  key: ValueKey('workout_${w.id}'),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.lg,
                    ),
                    decoration: BoxDecoration(
                      color: colors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Icon(Icons.delete_outline_rounded,
                        color: colors.error),
                  ),
                  onDismissed: (_) async {
                    AnalyticsService.instance.track('workout_deleted', props: {
                      'name': w.name,
                      'sets': w.totalSets,
                    });
                    final db = ref.read(databaseProvider);
                    final cloudId = w.cloudId;
                    final uid = AuthService.uid;
                    if (cloudId != null && cloudId.isNotEmpty && uid != null) {
                      FirestoreService.deleteWorkoutLog(uid, cloudId)
                          .catchError((Object e) =>
                              debugPrint('[Firestore] workout delete: $e'));
                    }
                    await db.deleteWorkout(w.id);
                    SnackbarService.info('Workout deleted');
                  },
                  child: AppCard(
                  child: Row(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          color: colors.success.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Icon(Icons.check_rounded,
                              color: colors.success, size: 20),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            AppText(w.name,
                                style: AppTypography.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w700)),
                            AppText(
                              '${(w.durationSeconds / 60).round()} min · ${w.totalSets} sets · ${w.estimatedCalories.toStringAsFixed(0)} kcal',
                              style: AppTypography.caption
                                  .copyWith(color: colors.textTertiary),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                ),
              )),
          const SizedBox(height: AppSpacing.md),
        ],

        // Weekly volume (derived from plan data)
        if (hasPlan) _buildWeeklyVolume(context, plansAsync),
      ],
    );
  }

  Widget _buildWeeklyVolume(BuildContext context, AsyncValue<List<WorkoutPlan>> plansAsync) {
    final plans = plansAsync.valueOrNull ?? [];
    final activePlan = plans.where((p) => p.isActive).firstOrNull;
    if (activePlan == null) return const SizedBox.shrink();

    // Tally total sets per focus area across the current week
    final focusSets = <String, int>{};
    try {
      final planData =
          jsonDecode(activePlan.planJson) as Map<String, dynamic>;
      final weeks = planData['weeks'] as List? ?? [];
      if (weeks.isNotEmpty) {
        final weeksElapsed = DateTime.now()
                .difference(activePlan.createdAt)
                .inDays ~/
            7;
        final weekIdx = weeksElapsed % weeks.length;
        final week = weeks[weekIdx] as Map<String, dynamic>;
        final days = week['days'] as List? ?? [];
        for (final d in days) {
          final focus = d['focus'] as String? ?? 'Other';
          final exercises = d['exercises'] as List? ?? [];
          int sets = 0;
          for (final ex in exercises) {
            sets += (ex['sets'] as int? ?? 0);
          }
          focusSets[focus] = (focusSets[focus] ?? 0) + sets;
        }
      }
    } catch (e) { debugPrint('[Workouts] parse weekly volume failed: $e'); }

    if (focusSets.isEmpty) return const SizedBox.shrink();
    final maxSets =
        focusSets.values.reduce((a, b) => a > b ? a : b).toDouble();

    // Show top 3 focus areas by volume
    final sorted = focusSets.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    final top = sorted.take(3).toList();
    final remaining = sorted.length - 3;

    final colors = context.colors;
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'WEEKLY VOLUME',
            style: AppTypography.overline
                .copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.md),
          ...top.map((e) {
            final pct = maxSets > 0 ? e.value / maxSets : 0.0;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  SizedBox(
                    width: 80,
                    child: Text(e.key, style: AppTypography.caption),
                  ),
                  Expanded(
                    child: LinearProgressIndicator(
                      value: pct,
                      backgroundColor: colors.surfaceCardBorder,
                      valueColor: AlwaysStoppedAnimation(
                        pct >= 0.6 ? colors.success : colors.warning,
                      ),
                      minHeight: 6,
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    '${e.value} sets',
                    style: AppTypography.caption
                        .copyWith(color: colors.textTertiary),
                  ),
                ],
              ),
            );
          }),
          if (remaining > 0)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.xs),
              child: Text(
                '+ $remaining more muscle group${remaining > 1 ? 's' : ''}',
                style: AppTypography.caption
                    .copyWith(color: colors.textTertiary),
              ),
            ),
        ],
      ),
    ).animate(delay: 100.ms).fadeIn(duration: 300.ms);
  }
}

// ── Plans Tab ──────────────────────────────────────────────────────────────

class _PlansTab extends ConsumerStatefulWidget {
  const _PlansTab();

  @override
  ConsumerState<_PlansTab> createState() => _PlansTabState();
}

class _PlansTabState extends ConsumerState<_PlansTab> {
  bool _isGenerating = false;

  Future<Map<String, dynamic>> _buildUserContext() =>
      UserContextService.buildWorkoutPlanContext(ref);

  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);
    AnalyticsService.instance.track('workout_plan_started', props: {'weeks': 4});
    final sw = Stopwatch()..start();
    try {
      final ai = ref.read(aiProvider);
      final ctx = await _buildUserContext();
      final result = await ai.generateWorkoutPlan(
        userContext: ctx,
        weeks: 4,
      );

      // Save to database
      final db = ref.read(databaseProvider);
      // Deactivate existing plans
      final existingPlans = await db.getWorkoutPlans();
      for (final p in existingPlans) {
        if (p.isActive) {
          await db.insertWorkoutPlan(WorkoutPlansCompanion(
            id: Value(p.id),
            name: Value(p.name),
            planJson: Value(p.planJson),
            isActive: const Value(false),
            createdAt: Value(p.createdAt),
          ));
        }
      }

      sw.stop();
      AnalyticsService.instance.track('workout_plan_generated', props: {
        'weeks': 4,
        'ai_source': ai.lastSource.name,
        'duration_ms': sw.elapsedMilliseconds,
        'plan_name': result['program_name'] ?? '',
      });

      final planCreatedAt = DateTime.now();
      final newPlanId = await db.insertWorkoutPlan(WorkoutPlansCompanion(
        name: Value(result['program_name'] as String? ?? 'AI Workout Plan'),
        planJson: Value(jsonEncode(result)),
        weeks: const Value(4),
        isActive: const Value(true),
        createdAt: Value(planCreatedAt),
      ));

      // Sync to Firestore for cross-device access
      final uid = AuthService.uid;
      if (uid != null) {
        FirestoreService.saveWorkoutPlan(uid, newPlanId.toString(), {
          'name': result['program_name'] as String? ?? 'AI Workout Plan',
          'planJson': jsonEncode(result),
          'weeks': 4,
          'isActive': true,
          'createdAt': planCreatedAt.toIso8601String(),
        }).catchError((e) => debugPrint('[Firestore] workout plan sync failed: $e'));
      }

      ref.invalidate(workoutPlansProvider);

      if (mounted) {
        setState(() => _isGenerating = false);
        SnackbarService.success('Workout plan generated! 💪');
      }
    } catch (e) {
      sw.stop();
      AnalyticsService.instance.track('workout_plan_error', props: {
        'error': e.toString().substring(0, e.toString().length.clamp(0, 200)),
      });
      debugPrint('Workout plan error: $e');
      if (mounted) {
        setState(() => _isGenerating = false);
        SnackbarService.error('Could not generate plan. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final plansAsync = ref.watch(workoutPlansProvider);
    if (plansAsync.isLoading && !plansAsync.hasValue) {
      return ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          AppButton(
            label: '🤖  Generate AI Workout Plan',
            onPressed: null,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Center(child: CircularProgressIndicator(color: colors.lime)),
        ],
      );
    }
    if (plansAsync.hasError && !plansAsync.hasValue) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Couldn\'t load plans', style: AppTypography.body.copyWith(color: colors.textTertiary)),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => ref.invalidate(workoutPlansProvider),
              child: Text('Retry', style: AppTypography.bodyMedium.copyWith(color: colors.lime)),
            ),
          ],
        ),
      );
    }
    final plans = plansAsync.valueOrNull ?? [];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        AppButton(
          label: _isGenerating
              ? '⏳  Generating...'
              : '🤖  Generate AI Workout Plan',
          onPressed: _isGenerating ? null : _generatePlan,
        ),
        const SizedBox(height: AppSpacing.sectionGap),

        if (plans.isNotEmpty) ...[
          Text(
            'YOUR PLANS',
            style: AppTypography.overline
                .copyWith(color: colors.textTertiary),
          ),
          const SizedBox(height: AppSpacing.md),
          ...plans.map((plan) {
            Map<String, dynamic> planData = {};
            try {
              planData =
                  jsonDecode(plan.planJson) as Map<String, dynamic>;
            } catch (e) { debugPrint('[Workouts] parse plan JSON failed: $e'); }
            // For the active plan, check if today has a workout
            final planned = plan.isActive
                ? ref.watch(todaysPlannedWorkoutProvider)
                : const TodaysPlannedWorkout();
            final hasTodaySession = plan.isActive &&
                planned.hasPlan &&
                planned.exercises.isNotEmpty;
            return Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                onTap: () {
                  AnalyticsService.instance.tap('workout_plan_card', screen: 'workouts', props: {'plan_name': plan.name});
                  _showPlanDetail(context, plan, planData);
                },
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: plan.isActive
                                ? colors.lime.withValues(alpha: 0.15)
                                : colors.bgTertiary,
                            borderRadius:
                                BorderRadius.circular(AppRadius.md),
                          ),
                          child: Center(
                            child: Text(
                              plan.isActive ? '✅' : '📋',
                              style: const TextStyle(fontSize: 22),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                plan.name,
                                style: AppTypography.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                              Text(
                                '${plan.weeks} weeks${plan.isActive ? ' · Active' : ''}',
                                style: AppTypography.caption.copyWith(
                                  color: plan.isActive
                                      ? colors.lime
                                      : colors.textTertiary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(Icons.chevron_right_rounded,
                            color: colors.textTertiary),
                      ],
                    ),
                    // "Start Today's Session" CTA — only on the active plan with a workout today
                    if (hasTodaySession) ...[
                      const SizedBox(height: AppSpacing.md),
                      SizedBox(
                        width: double.infinity,
                        child: FilledButton.icon(
                          onPressed: () {
                            AnalyticsService.instance.tap(
                              'start_session_plans_tab',
                              screen: 'workouts',
                              props: {'workout': planned.workoutName},
                            );
                            context.push('/workouts/active', extra: planned.rawDayJson);
                          },
                          icon: const Icon(Icons.play_arrow_rounded, size: 18),
                          label: Text('Start Today\'s Session · ${planned.workoutName}'),
                          style: FilledButton.styleFrom(
                            backgroundColor: colors.lime,
                            foregroundColor: colors.textInverse,
                            textStyle: AppTypography.caption.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppRadius.md),
                            ),
                            minimumSize: const Size(0, 44),
                          ),
                        ),
                      ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1),
                    ],
                  ],
                ),
              ),
            );
          }),
          const SizedBox(height: AppSpacing.md),
        ],

        Text(
          'TEMPLATES',
          style: AppTypography.overline
              .copyWith(color: colors.textTertiary),
        ),
        const SizedBox(height: AppSpacing.md),
        ..._templates.asMap().entries.map((e) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: AppCard(
                onTap: () {
                  AnalyticsService.instance.tap('workout_template_card', screen: 'workouts', props: {'template': e.value.name});
                  context.push('/workouts/active');
                },
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: e.value.color.withValues(alpha: 0.1),
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                      ),
                      child: Center(
                        child: Text(e.value.emoji,
                            style: const TextStyle(fontSize: 24)),
                      ),
                    ),
                    const SizedBox(width: AppSpacing.md),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            e.value.name,
                            style: AppTypography.bodyMedium
                                .copyWith(fontWeight: FontWeight.w700),
                          ),
                          Text(
                            e.value.desc,
                            style: AppTypography.caption.copyWith(
                                color: colors.textTertiary),
                          ),
                        ],
                      ),
                    ),
                    Icon(Icons.chevron_right_rounded,
                        color: colors.textTertiary),
                  ],
                ),
              ).animate(delay: (e.key * 50).ms).fadeIn(duration: 300.ms),
            )),
      ],
    );
  }

  void _showPlanDetail(BuildContext context, WorkoutPlan plan,
      Map<String, dynamic> planData) {
    final colors = context.colors;
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: colors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        maxChildSize: 0.95,
        expand: false,
        builder: (_, scrollCtrl) {
          final weeks = planData['weeks'] as List? ?? [];
          return ListView(
            controller: scrollCtrl,
            padding: const EdgeInsets.all(AppSpacing.pagePadding),
            children: [
              Center(
                child: Container(
                  width: 36,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: colors.surfaceCardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              Text(plan.name, style: AppTypography.h2),
              Text('${plan.weeks} weeks',
                  style: AppTypography.body
                      .copyWith(color: colors.textTertiary)),
              const SizedBox(height: AppSpacing.sectionGap),
              for (final week in weeks) ...[
                Text(
                  'Week ${week['week']}',
                  style: AppTypography.h3
                      .copyWith(color: colors.cyan),
                ),
                const SizedBox(height: AppSpacing.sm),
                for (final day in (week['days'] as List? ?? [])) ...[
                  AppCard(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                '${day['day_name']} — ${day['focus']}',
                                style: AppTypography.bodyMedium
                                    .copyWith(fontWeight: FontWeight.w700),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                Navigator.pop(context);
                                context.push(
                                  '/workouts/active',
                                  extra: jsonEncode(day),
                                );
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: colors.lime
                                      .withValues(alpha: 0.15),
                                  borderRadius: BorderRadius.circular(
                                      AppRadius.full),
                                ),
                                child: Text(
                                  'Start',
                                  style: AppTypography.overline
                                      .copyWith(color: colors.lime),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: AppSpacing.sm),
                        for (final ex
                            in (day['exercises'] as List? ?? []))
                          Padding(
                            padding: const EdgeInsets.only(bottom: 4),
                            child: Text(
                              '${ex['name']} · ${ex['sets']}×${ex['reps']}',
                              style: AppTypography.caption.copyWith(
                                  color: colors.textSecondary),
                            ),
                          ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                ],
                const SizedBox(height: AppSpacing.md),
              ],
            ],
          );
        },
      ),
    );
  }

  static final _templates = [
    (
      emoji: '💪',
      name: 'Push Pull Legs',
      desc: '6 days · Intermediate',
      color: AppColors.cyan
    ),
    (
      emoji: '⬆️',
      name: 'Upper/Lower Split',
      desc: '4 days · Beginner-friendly',
      color: AppColors.lime
    ),
    (
      emoji: '🏋️',
      name: 'Full Body 3×',
      desc: '3 days · Great for beginners',
      color: AppColors.coral
    ),
    (
      emoji: '🔥',
      name: 'HIIT Circuit',
      desc: '4 days · Fat loss focus',
      color: AppColors.warning
    ),
    (
      emoji: '🧘',
      name: 'Yoga + Mobility',
      desc: '5 days · Recovery focused',
      color: AppColors.macroFiber
    ),
  ];
}

// ── Library Tab ────────────────────────────────────────────────────────────

class _LibraryTab extends ConsumerStatefulWidget {
  const _LibraryTab();

  @override
  ConsumerState<_LibraryTab> createState() => _LibraryTabState();
}

class _LibraryTabState extends ConsumerState<_LibraryTab> {
  final _searchCtrl = TextEditingController();
  String _selectedMuscle = 'All';
  List<Exercise> _exercises = [];
  bool _isLoading = true;

  static const _muscleFilters = [
    'All',
    'chest',
    'back',
    'legs',
    'shoulders',
    'arms',
    'core',
    'glutes',
    'cardio',
    'flexibility',
  ];

  @override
  void initState() {
    super.initState();
    _loadExercises();
    _searchCtrl.addListener(_onSearch);
  }

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Future<void> _loadExercises() async {
    final db = ref.read(databaseProvider);
    final all = await db.getAllExercises();
    if (mounted) setState(() { _exercises = all; _isLoading = false; });
  }

  void _onSearch() async {
    final db = ref.read(databaseProvider);
    final query = _searchCtrl.text.trim();
    List<Exercise> results;
    if (query.isEmpty && _selectedMuscle == 'All') {
      results = await db.getAllExercises();
    } else if (query.isEmpty) {
      results = await db.getExercisesByMuscle(_selectedMuscle);
    } else {
      results = await db.searchExercises(query);
      if (_selectedMuscle != 'All') {
        results = results
            .where((e) => e.muscleGroup == _selectedMuscle)
            .toList();
      }
    }
    if (mounted) setState(() => _exercises = results);
  }

  void _selectMuscle(String muscle) {
    setState(() => _selectedMuscle = muscle);
    _onSearch();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      child: Column(
        children: [
          TextField(
            controller: _searchCtrl,
            style: AppTypography.body,
            decoration: InputDecoration(
              hintText:
                  'Search ${_exercises.length} exercises...',
              prefixIcon: Icon(Icons.search,
                  color: colors.textTertiary, size: 20),
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          SizedBox(
            height: 34,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: _muscleFilters.length,
              separatorBuilder: (_, __) => const SizedBox(width: 8),
              itemBuilder: (_, i) {
                final cat = _muscleFilters[i];
                final label =
                    cat == 'All' ? 'All' : cat[0].toUpperCase() + cat.substring(1);
                final selected = _selectedMuscle == cat;
                return GestureDetector(
                  onTap: () => _selectMuscle(cat),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: selected
                          ? colors.limeGlow
                          : colors.surfaceCard,
                      borderRadius:
                          BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: selected
                            ? colors.lime
                            : colors.surfaceCardBorder,
                      ),
                    ),
                    child: Text(
                      label,
                      style: AppTypography.caption.copyWith(
                        color: selected
                            ? colors.lime
                            : colors.textSecondary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          if (_isLoading)
            Expanded(
              child: Center(
                  child: CircularProgressIndicator(
                      color: colors.lime)),
            )
          else
            Expanded(
              child: ListView.separated(
                itemCount: _exercises.length,
                separatorBuilder: (_, __) =>
                    const SizedBox(height: 6),
                itemBuilder: (_, i) {
                  final ex = _exercises[i];
                  return AppCard(
                    child: Row(
                      children: [
                        Container(
                          width: 40,
                          height: 40,
                          decoration: BoxDecoration(
                            color: _muscleColor(ex.muscleGroup)
                                .withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(
                                AppRadius.sm),
                          ),
                          child: Center(
                            child: Text(
                              _muscleEmoji(ex.muscleGroup),
                              style:
                                  const TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                        const SizedBox(width: AppSpacing.md),
                        Expanded(
                          child: Column(
                            crossAxisAlignment:
                                CrossAxisAlignment.start,
                            children: [
                              Text(
                                ex.name,
                                style: AppTypography.bodyMedium
                                    .copyWith(
                                        fontWeight:
                                            FontWeight.w600),
                              ),
                              Text(
                                '${ex.muscleGroup} · ${ex.equipment}',
                                style: AppTypography.caption
                                    .copyWith(
                                        color: colors
                                            .textTertiary),
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: colors.bgTertiary,
                            borderRadius: BorderRadius.circular(
                                AppRadius.full),
                          ),
                          child: Text(
                            ex.category,
                            style: AppTypography.overline.copyWith(
                                color: colors.textTertiary,
                                fontSize: 9),
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
        ],
      ),
    );
  }

  String _muscleEmoji(String muscle) {
    switch (muscle) {
      case 'chest':
        return '🏋️';
      case 'back':
        return '🔙';
      case 'legs':
        return '🦵';
      case 'shoulders':
        return '💪';
      case 'arms':
        return '💪';
      case 'core':
        return '🎯';
      case 'glutes':
        return '🍑';
      case 'cardio':
        return '❤️';
      case 'flexibility':
        return '🧘';
      default:
        return '💪';
    }
  }

  Color _muscleColor(String muscle) {
    switch (muscle) {
      case 'chest':
        return AppColors.coral;
      case 'back':
        return AppColors.cyan;
      case 'legs':
        return AppColors.lime;
      case 'shoulders':
        return AppColors.warning;
      case 'arms':
        return AppColors.macroProtein;
      case 'core':
        return AppColors.info;
      case 'glutes':
        return AppColors.macroFat;
      case 'cardio':
        return AppColors.error;
      case 'flexibility':
        return AppColors.macroFiber;
      default:
        return AppColors.textSecondary;
    }
  }
}
