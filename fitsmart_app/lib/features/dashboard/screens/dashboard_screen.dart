import 'package:drift/drift.dart' show Value;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/dashboard_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/widgets/streak_milestone_overlay.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/animated_number.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/calorie_ring.dart';
import '../../../core/widgets/macro_bar.dart';
import '../../../core/widgets/xp_progress_bar.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../providers/gemini_provider.dart';
import '../../../services/analytics_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/snackbar_service.dart';
import '../../../core/utils/meal_utils.dart';
import '../../../core/widgets/upgrade_prompt_banner.dart';
import '../widgets/water_tracking_card.dart';
import '../../progress/widgets/share_achievement_sheet.dart';
import '../../../core/widgets/share_card.dart';

class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mealsAsync = ref.watch(todaysMealsProvider);
    final nutrition = ref.watch(dailyNutritionProvider);
    final gamification = ref.watch(gamificationProvider);
    final displayName = AuthService.displayName;
    final firstName = (displayName != null && displayName.isNotEmpty)
        ? displayName.split(' ').first
        : null;

    final colors = context.colors;

    // Show streak milestone celebration overlay
    ref.listen<int>(streakMilestoneProvider, (_, milestone) {
      if (milestone > 0) {
        showGeneralDialog(
          context: context,
          barrierDismissible: false,
          barrierColor: Colors.transparent,
          pageBuilder: (ctx, _, __) => StreakMilestoneOverlay(
            days: milestone,
            onDismiss: () =>
                ref.read(streakMilestoneProvider.notifier).state = 0,
          ),
        );
      }
    });

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      body: RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(todaysMealsProvider);
          ref.invalidate(todaysWaterProvider);
          await Future.delayed(const Duration(milliseconds: 600));
        },
        color: colors.lime,
        backgroundColor: colors.bgSecondary,
        child: CustomScrollView(
          slivers: [
          // App bar — solid surface with top-edge highlight + accent border.
          // (BackdropFilter here would sample body content rendered first
          // and bleed it through the appbar — see LiquidAppBar comment.)
          SliverAppBar(
            backgroundColor: colors.bgPrimary,
            elevation: 0,
            scrolledUnderElevation: 0,
            floating: true,
            pinned: false,
            flexibleSpace: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.white.withValues(alpha: 0.04),
                    Colors.transparent,
                  ],
                  stops: const [0.0, 0.6],
                ),
                border: Border(
                  bottom: BorderSide(
                    color: colors.surfaceCardBorder.withValues(alpha: 0.5),
                  ),
                ),
              ),
            ),
            title: Row(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _greeting(),
                      style: AppTypography.caption.copyWith(
                        color: colors.textTertiary,
                      ),
                    ),
                    Text(
                      firstName != null
                          ? 'Hey, $firstName 👋'
                          : 'Your Dashboard',
                      style: AppTypography.h3,
                    ),
                  ],
                ),
                const Spacer(),
                // Streak badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: colors.bgTertiary,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(color: colors.surfaceCardBorder),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      // Breathing fire — subtle scale loop signals "alive" streak.
                      // Calendar emoji stays static (no streak yet).
                      gamification.currentStreak > 2
                          ? const Text('🔥', style: TextStyle(fontSize: 16))
                              .animate(
                                onPlay: (c) => c.repeat(reverse: true),
                              )
                              .scale(
                                begin: const Offset(1, 1),
                                end: const Offset(1.08, 1.08),
                                duration: 1100.ms,
                                curve: Curves.easeInOut,
                              )
                          : const Text('📅', style: TextStyle(fontSize: 16)),
                      const SizedBox(width: 4),
                      AnimatedNumber(
                        value: gamification.currentStreak,
                        builder: (v) => Text(
                          '${v}d',
                          style: AppTypography.bodyMedium.copyWith(
                            fontWeight: FontWeight.w700,
                            color: gamification.currentStreak > 0
                                ? colors.lime
                                : colors.textTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                // Settings
                IconButton(
                  icon: const Icon(Icons.settings_outlined, size: 22),
                  color: colors.textTertiary,
                  onPressed: () {
                    AnalyticsService.instance.tap('settings_btn', screen: 'dashboard');
                    context.push('/settings');
                  },
                ),
              ],
            ),
          ),

          if (mealsAsync.isLoading)
            const SliverToBoxAdapter(child: DashboardSkeleton())
          else if (mealsAsync.hasError)
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.all(AppSpacing.pagePadding),
                child: AppCard(
                  backgroundColor: colors.errorBg,
                  borderColor: colors.error.withValues(alpha: 0.3),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text('😕', style: TextStyle(fontSize: 36)),
                      const SizedBox(height: AppSpacing.md),
                      Text(
                        'Couldn\'t load your data',
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      Text(
                        'Check your connection and try again',
                        style: AppTypography.caption.copyWith(
                          color: colors.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.all(AppSpacing.pagePadding),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Upgrade prompt for anonymous users
                  const UpgradePromptBanner(),

                  // XP bar
                  XpProgressBar(
                    totalXp: gamification.totalXp,
                    currentLevel: gamification.currentLevel,
                    levelName: gamification.levelName,
                    levelProgress: gamification.levelProgress,
                    xpToNext: gamification.xpToNextLevel,
                    compact: true,
                  ).animate().fadeIn(duration: 300.ms),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Hero calorie card — tap to reveal macros
                  _CalorieMacroCard(
                    nutrition: nutrition,
                  ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.03),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Today's workout + streak row
                  Row(
                    children: [
                      Expanded(
                        child: _WorkoutTodayCard()
                            .animate(delay: 100.ms)
                            .fadeIn(duration: 400.ms),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      Expanded(
                        child: _StreakCard(
                          streak: gamification.currentStreak,
                        ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // AI insight
                  _AiInsightCard()
                      .animate(delay: 200.ms)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Meals — collapsed summary, tap to expand
                  const _MealTimelineCard()
                      .animate(delay: 250.ms)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Water tracking
                  const WaterTrackingCard()
                      .animate(delay: 300.ms)
                      .fadeIn(duration: 400.ms),
                  const SizedBox(height: AppSpacing.sectionGap),

                  // Daily challenge (secondary — at bottom)
                  _DailyChallengeCard()
                      .animate(delay: 350.ms)
                      .fadeIn(duration: 400.ms),

                  const SizedBox(height: 100), // FAB clearance
                ]),
              ),
            ),
        ],
        ),
      ),

      // Quick log FAB
      floatingActionButton: const _QuickLogFab(),
    );
  }

  String _greeting() {
    final hour = DateTime.now().hour;
    if (hour < 12) return 'Good morning ☀️';
    if (hour < 17) return 'Good afternoon 🌤️';
    return 'Good evening 🌙';
  }
}

class _CalorieMacroCard extends ConsumerWidget {
  final DailyNutrition nutrition;
  const _CalorieMacroCard({required this.nutrition});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final workoutsAsync = ref.watch(todaysWorkoutsProvider);
    final workouts = workoutsAsync.valueOrNull ?? [];
    final burnedCal = workouts.fold<double>(
      0,
      (s, w) => s + w.estimatedCalories,
    );
    final remaining = (nutrition.targetCalories - nutrition.consumedCalories)
        .clamp(0, double.infinity)
        .toDouble();

    return GestureDetector(
      onTap: () => _showMacroSheet(context, burnedCal),
      child: AppCard(
        child: Column(
          children: [
            // Centered calorie ring
            Center(
              child: CalorieRing(
                consumed: nutrition.consumedCalories,
                target: nutrition.targetCalories,
                size: 160,
                strokeWidth: 12,
              ),
            ),
            const SizedBox(height: AppSpacing.md),

            // Hero remaining number
            Text(
              remaining.toStringAsFixed(0),
              style: AppTypography.display.copyWith(
                color: colors.lime,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              'kcal remaining',
              style: AppTypography.caption.copyWith(
                color: colors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Tap hint
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'PROTEIN · CARBS · FAT',
                  style: AppTypography.overline.copyWith(
                    color: colors.textTertiary,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.keyboard_arrow_down_rounded,
                  size: 16,
                  color: colors.textTertiary,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  void _showMacroSheet(BuildContext context, double burnedCal) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => _MacroSheet(nutrition: nutrition, burnedCal: burnedCal),
    );
  }
}

class _MacroSheet extends StatelessWidget {
  final DailyNutrition nutrition;
  final double burnedCal;
  const _MacroSheet({required this.nutrition, required this.burnedCal});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final remaining = (nutrition.targetCalories - nutrition.consumedCalories)
        .clamp(0, double.infinity)
        .toDouble();
    final net = nutrition.consumedCalories - burnedCal;

    return Container(
      margin: const EdgeInsets.fromLTRB(
        AppSpacing.md,
        0,
        AppSpacing.md,
        AppSpacing.md,
      ),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.surfaceCardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colors.surfaceCardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Your Macros', style: AppTypography.h3),
          const SizedBox(height: AppSpacing.sectionGap),
          MacroBar(
            label: 'Protein',
            consumed: nutrition.consumedProtein,
            target: nutrition.targetProtein,
            color: AppColors.macroProtein,
          ),
          const SizedBox(height: AppSpacing.md),
          MacroBar(
            label: 'Carbs',
            consumed: nutrition.consumedCarbs,
            target: nutrition.targetCarbs,
            color: AppColors.macroCarbs,
          ),
          const SizedBox(height: AppSpacing.md),
          MacroBar(
            label: 'Fat',
            consumed: nutrition.consumedFat,
            target: nutrition.targetFat,
            color: AppColors.macroFat,
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _QuickStat(
                label: 'Remaining',
                value: '${remaining.toStringAsFixed(0)} kcal',
                color: colors.lime,
              ),
              Container(width: 1, height: 24, color: colors.surfaceCardBorder),
              _QuickStat(
                label: 'Burned',
                value: '${burnedCal.toStringAsFixed(0)} kcal',
                color: colors.coral,
              ),
              Container(width: 1, height: 24, color: colors.surfaceCardBorder),
              _QuickStat(
                label: 'Net',
                value: '${net.toStringAsFixed(0)} kcal',
                color: colors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}

class _QuickStat extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _QuickStat({
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(
          value,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        Text(
          label,
          style: AppTypography.overline.copyWith(color: context.colors.textTertiary),
        ),
      ],
    );
  }
}

class _WorkoutTodayCard extends ConsumerWidget {
  const _WorkoutTodayCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final workoutsAsync = ref.watch(todaysWorkoutsProvider);

    if (workoutsAsync.isLoading) return const SkeletonCard(height: 150);
    if (workoutsAsync.hasError) {
      return AppCard(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'TODAY',
              style: AppTypography.overline.copyWith(
                color: colors.textTertiary,
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Couldn\'t load workouts',
              style: AppTypography.caption.copyWith(color: colors.error),
            ),
          ],
        ),
      );
    }

    final workouts = workoutsAsync.value!;
    final done = workouts.isNotEmpty;
    final totalDuration =
        workouts.fold<int>(0, (s, w) => s + w.durationSeconds) ~/ 60;
    final totalCal = workouts.fold<double>(
      0,
      (s, w) => s + w.estimatedCalories,
    );

    return AppCard(
      onTap: () {
        AnalyticsService.instance.tap('workout_today_card', screen: 'dashboard');
        context.go('/workouts');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TODAY',
                style: AppTypography.overline.copyWith(
                  color: colors.textTertiary,
                ),
              ),
              Icon(
                done
                    ? Icons.check_circle_rounded
                    : Icons.fitness_center_rounded,
                size: 16,
                color: done ? colors.success : colors.cyan,
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            done
                ? '${workouts.length} workout${workouts.length > 1 ? 's' : ''}'
                : 'No workout yet',
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.w700,
            ),
          ),
          Text(
            done
                ? '$totalDuration min · ${totalCal.toStringAsFixed(0)} kcal'
                : 'Tap to start a session',
            style: AppTypography.caption.copyWith(
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: (done ? colors.success : colors.cyan).withValues(
                alpha: 0.1,
              ),
              borderRadius: BorderRadius.circular(AppRadius.full),
              border: Border.all(
                color: (done ? colors.success : colors.cyan).withValues(
                  alpha: 0.3,
                ),
              ),
            ),
            child: Text(
              done ? 'View Details →' : 'Start Workout →',
              style: AppTypography.caption.copyWith(
                color: done ? colors.success : colors.cyan,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  final int streak;
  const _StreakCard({required this.streak});

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final milestones = [3, 7, 14, 30, 60, 90];
    final nextMilestone = milestones.firstWhere(
      (m) => m > streak,
      orElse: () => streak + 10,
    );

    final isMilestone = [3, 7, 14, 30, 60, 90].contains(streak);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'STREAK',
                style: AppTypography.overline.copyWith(
                  color: colors.textTertiary,
                ),
              ),
              Row(
                children: [
                  if (isMilestone)
                    GestureDetector(
                      onTap: () => ShareAchievementSheet.show(
                        context,
                        data: ShareCardData.streak(streak),
                      ),
                      child: Icon(Icons.share_rounded,
                          size: 16, color: colors.textTertiary),
                    ),
                  if (isMilestone) const SizedBox(width: 8),
                  Text(
                    streak > 2 ? '🔥' : '📅',
                    style: const TextStyle(fontSize: 16),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            '$streak',
            style: AppTypography.h1.copyWith(
              color: streak > 0 ? colors.lime : colors.textTertiary,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            streak == 1 ? 'day streak' : 'days streak',
            style: AppTypography.caption.copyWith(
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Text(
            '$nextMilestone days = 🔥',
            style: AppTypography.overline.copyWith(
              color: colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}

class _DailyChallengeCard extends ConsumerWidget {
  const _DailyChallengeCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final nutrition = ref.watch(dailyNutritionProvider);
    final proteinTarget = nutrition.targetProtein;
    final proteinConsumed = nutrition.consumedProtein;
    final progress = (proteinConsumed / proteinTarget.clamp(1, double.infinity))
        .clamp(0.0, 1.0);
    final done = proteinConsumed >= proteinTarget;

    return GlowCard(
      glowColor: done ? colors.success : colors.warning,
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: (done ? colors.success : colors.warning).withValues(
                alpha: 0.15,
              ),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                done ? '🏆' : '⚡',
                style: const TextStyle(fontSize: 20),
              ),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'DAILY CHALLENGE',
                  style: AppTypography.overline.copyWith(
                    color: done ? colors.success : colors.warning,
                  ),
                ),
                Text(
                  'Hit ${proteinTarget.toStringAsFixed(0)}g protein today',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  done ? 'Challenge complete! +30 XP 🎉' : '+30 XP reward',
                  style: AppTypography.caption.copyWith(
                    color: done ? colors.success : colors.textTertiary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Column(
            children: [
              Text(
                '${proteinConsumed.toStringAsFixed(0)}/${proteinTarget.toStringAsFixed(0)}g',
                style: AppTypography.caption.copyWith(
                  color: done ? colors.success : colors.warning,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 4),
              SizedBox(
                width: 40,
                height: 40,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 3,
                  backgroundColor: colors.surfaceCardBorder,
                  valueColor: AlwaysStoppedAnimation(
                    done ? colors.success : colors.warning,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _AiInsightCard extends ConsumerStatefulWidget {
  @override
  ConsumerState<_AiInsightCard> createState() => _AiInsightCardState();
}

class _AiInsightCardState extends ConsumerState<_AiInsightCard> {
  bool _loading = false;
  String? _insightText;
  String _icon = '🤖';
  int? _insightId;
  bool _generated = false;

  @override
  void initState() {
    super.initState();
    _loadInsight();
  }

  Future<void> _loadInsight() async {
    final db = ref.read(databaseProvider);
    final existing = await db.getTodaysInsight();
    if (existing != null) {
      if (mounted) {
        setState(() {
          _insightText = existing.insight;
          _icon = existing.icon;
          _insightId = existing.id;
          _generated = true;
        });
      }
      return;
    }

    // Check if we have meals to generate from
    final meals = ref.read(todaysMealsProvider).valueOrNull ?? [];
    if (meals.isEmpty) return;

    setState(() => _loading = true);
    AnalyticsService.instance.track('daily_insight_started');
    final sw = Stopwatch()..start();
    try {
      final ai = ref.read(aiProvider);
      final nutrition = ref.read(dailyNutritionProvider);
      final result = await ai.getDailyInsight(
        userContext: {
          'meals_today': meals.length,
          'calories': nutrition.consumedCalories.toStringAsFixed(0),
          'protein': nutrition.consumedProtein.toStringAsFixed(0),
          'carbs': nutrition.consumedCarbs.toStringAsFixed(0),
          'fat': nutrition.consumedFat.toStringAsFixed(0),
          'target_calories': nutrition.targetCalories.toStringAsFixed(0),
        },
      );
      sw.stop();
      AnalyticsService.instance.track('daily_insight_received', props: {
        'ai_source': ai.lastSource.name,
        'duration_ms': sw.elapsedMilliseconds,
        'category': result['category'] ?? '',
      });

      final insight = result['insight'] as String? ?? 'Keep up the good work!';
      final icon = result['icon'] as String? ?? '💡';

      final id = await db.insertInsight(
        AiInsightsCompanion(
          insight: Value(insight),
          icon: Value(icon),
          category: Value(result['category'] as String? ?? 'motivation'),
          generatedAt: Value(DateTime.now()),
        ),
      );

      if (mounted) {
        setState(() {
          _insightText = insight;
          _icon = icon;
          _insightId = id;
          _generated = true;
          _loading = false;
        });
      }
    } catch (_) {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _dismiss() async {
    if (_insightId != null) {
      final db = ref.read(databaseProvider);
      await db.dismissInsight(_insightId!);
      if (mounted) {
        setState(() {
          _insightText = null;
          _generated = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final displayText =
        _insightText ??
        'Welcome! Log your first meal to get personalized AI insights about your nutrition.';

    return AppCard(
      backgroundColor: colors.infoBg,
      borderColor: colors.info.withValues(alpha: 0.3),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: colors.info.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: _loading
                  ? SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: colors.info,
                      ),
                    )
                  : Text(_icon, style: const TextStyle(fontSize: 18)),
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'AI INSIGHT',
                  style: AppTypography.overline.copyWith(color: colors.info),
                ),
                const SizedBox(height: 4),
                Text(
                  displayText,
                  style: AppTypography.body.copyWith(
                    color: colors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          if (_generated)
            GestureDetector(
              onTap: () {
                AnalyticsService.instance.tap('ai_insight_dismissed', screen: 'dashboard');
                _dismiss();
              },
              child: Icon(
                Icons.close,
                size: 16,
                color: colors.textTertiary,
              ),
            ),
        ],
      ),
    );
  }
}

class _MealTimelineCard extends ConsumerStatefulWidget {
  const _MealTimelineCard();

  @override
  ConsumerState<_MealTimelineCard> createState() => _MealTimelineCardState();
}

class _MealTimelineCardState extends ConsumerState<_MealTimelineCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final mealsAsync = ref.watch(todaysMealsProvider);
    final meals = mealsAsync.valueOrNull ?? [];
    final totalCal = meals.fold<double>(0, (s, m) => s + m.calories);

    // Empty state — visual hint with border
    if (meals.isEmpty) {
      return GestureDetector(
        onTap: () {
          AnalyticsService.instance.tap('log_meal_link', screen: 'dashboard');
          context.push('/nutrition/log');
        },
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadding,
            vertical: AppSpacing.lg,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.surfaceCardBorder),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.add_circle_outline_rounded,
                size: 18,
                color: colors.textTertiary,
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Log your first meal',
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    // Meals exist — collapsed summary with expand
    return AppCard(
      onTap: () => setState(() => _expanded = !_expanded),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'TODAY\'S MEALS',
                style: AppTypography.overline.copyWith(
                  color: colors.textTertiary,
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${meals.length} meal${meals.length > 1 ? 's' : ''} · ${totalCal.toStringAsFixed(0)} kcal',
                    style: AppTypography.caption.copyWith(
                      color: colors.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(width: 4),
                  AnimatedRotation(
                    turns: _expanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      size: 18,
                      color: colors.textTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 250),
            curve: Curves.easeInOut,
            child: _expanded
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.md),
                      ...meals.map(
                        (meal) => Padding(
                          padding: const EdgeInsets.only(bottom: AppSpacing.sm),
                          child: Row(
                            children: [
                              Text(
                                mealEmoji(meal.mealType),
                                style: const TextStyle(fontSize: 18),
                              ),
                              const SizedBox(width: AppSpacing.sm),
                              Expanded(
                                child: Text(
                                  meal.name,
                                  style: AppTypography.bodyMedium.copyWith(
                                    fontWeight: FontWeight.w600,
                                  ),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                              Text(
                                '${meal.calories.toStringAsFixed(0)} kcal',
                                style: AppTypography.bodyMedium.copyWith(
                                  fontWeight: FontWeight.w700,
                                  color: colors.warning,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.sm),
                      GestureDetector(
                        onTap: () {
                          AnalyticsService.instance.tap(
                            'log_meal_link',
                            screen: 'dashboard',
                          );
                          context.push('/nutrition/log');
                        },
                        child: Text(
                          '+ Log another meal',
                          style: AppTypography.caption.copyWith(
                            color: colors.lime,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                    ],
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

class _QuickLogFab extends ConsumerWidget {
  const _QuickLogFab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    return FloatingActionButton.extended(
      onPressed: () {
        AnalyticsService.instance.tap('quick_log_fab', screen: 'dashboard');
        _showQuickLog(context);
      },
      backgroundColor: colors.lime,
      foregroundColor: colors.textInverse,
      icon: const Icon(Icons.add_rounded, size: 22),
      label: Text(
        'Log',
        style: AppTypography.bodyMedium.copyWith(
          fontWeight: FontWeight.w700,
          color: colors.textInverse,
        ),
      ),
      elevation: 0,
      shape: const StadiumBorder(),
    );
  }

  void _showQuickLog(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => const _QuickLogSheet(),
    );
  }
}

class _QuickLogSheet extends ConsumerWidget {
  const _QuickLogSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final actions = [
      (
        '📸',
        'Scan Meal',
        'AI photo analysis',
        colors.lime,
        '/nutrition/log',
      ),
      (
        '✏️',
        'Log Meal',
        'Text or manual entry',
        colors.cyan,
        '/nutrition/log',
      ),
      (
        '💪',
        'Log Workout',
        'Start or log a session',
        colors.coral,
        '/workouts/active',
      ),
      ('💧', 'Log Water', '+250ml · +5 XP', colors.info, null),
    ];

    return Container(
      margin: const EdgeInsets.all(AppSpacing.lg),
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: colors.surfaceCardBorder),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle
          Center(
            child: Container(
              width: 36,
              height: 4,
              margin: const EdgeInsets.only(bottom: 20),
              decoration: BoxDecoration(
                color: colors.surfaceCardBorder,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          Text('Quick Log', style: AppTypography.h3),
          const SizedBox(height: 4),
          Text(
            'What do you want to track?',
            style: AppTypography.caption.copyWith(
              color: colors.textTertiary,
            ),
          ),
          const SizedBox(height: AppSpacing.sectionGap),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.5,
            children: actions
                .asMap()
                .entries
                .map(
                  (e) =>
                      GestureDetector(
                            onTap: () async {
                              final label = e.value.$2.toLowerCase().replaceAll(' ', '_');
                              AnalyticsService.instance.tap('quick_log_$label', screen: 'quick_log_sheet');
                              Navigator.pop(context);
                              if (e.value.$5 != null) {
                                context.push(e.value.$5!);
                              } else if (e.value.$1 == '💧') {
                                // Log 250ml of water
                                final db = ref.read(databaseProvider);
                                await db.addWater(250);
                                await ref
                                    .read(gamificationProvider.notifier)
                                    .awardXp(5);
                                SnackbarService.success(
                                  '💧 +250ml water · +5 XP',
                                );
                              }
                            },
                            child: Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: e.value.$4.withValues(alpha: 0.08),
                                borderRadius: BorderRadius.circular(
                                  AppRadius.md,
                                ),
                                border: Border.all(
                                  color: e.value.$4.withValues(alpha: 0.3),
                                ),
                              ),
                              child: Row(
                                children: [
                                  Text(
                                    e.value.$1,
                                    style: const TextStyle(fontSize: 20),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          e.value.$2,
                                          style: AppTypography.bodyMedium
                                              .copyWith(
                                                fontWeight: FontWeight.w700,
                                                color: e.value.$4,
                                                fontSize: 13,
                                              ),
                                        ),
                                        Text(
                                          e.value.$3,
                                          style: AppTypography.overline
                                              .copyWith(
                                                color: colors.textTertiary,
                                                fontSize: 9,
                                              ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                          .animate(delay: (e.key * 50).ms)
                          .fadeIn()
                          .slideY(begin: 0.05),
                )
                .toList(),
          ),
          SizedBox(
            height: MediaQuery.of(context).padding.bottom + AppSpacing.md,
          ),
        ],
      ),
    );
  }
}
