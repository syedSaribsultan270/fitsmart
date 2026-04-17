import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import '../../dashboard/providers/dashboard_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/app_text.dart';
import '../../../core/widgets/liquid_glass.dart';
import '../../../core/widgets/macro_bar.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../providers/gemini_provider.dart';
import '../../../services/analytics_service.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/snackbar_service.dart';
import '../../../services/user_context_service.dart';
import '../../../core/utils/meal_utils.dart';
import '../../../core/widgets/empty_state_widget.dart';

class NutritionScreen extends ConsumerStatefulWidget {
  const NutritionScreen({super.key});

  @override
  ConsumerState<NutritionScreen> createState() => _NutritionScreenState();
}

class _NutritionScreenState extends ConsumerState<NutritionScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 2, vsync: this);
    _tabs.addListener(() {
      if (!_tabs.indexIsChanging) return;
      const names = ['today', 'meal_plan'];
      AnalyticsService.instance.tabSwitch(names[_tabs.index], screen: 'nutrition');
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
    final nutrition = ref.watch(dailyNutritionProvider);

    return Scaffold(
      backgroundColor: colors.bgPrimary,
      appBar: LiquidAppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            color: colors.lime,
            onPressed: () {
              AnalyticsService.instance.tap('add_meal_btn', screen: 'nutrition');
              context.push('/nutrition/log');
            },
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: colors.lime,
          indicatorWeight: 2,
          labelColor: colors.lime,
          unselectedLabelColor: colors.textTertiary,
          labelStyle: AppTypography.caption.copyWith(fontWeight: FontWeight.w700),
          tabs: const [
            Tab(text: 'TODAY'),
            Tab(text: 'MEAL PLAN'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabs,
        children: [
          _TodayTab(nutrition: nutrition),
          _MealPlanTab(),
        ],
      ),
    );
  }
}

class _TodayTab extends ConsumerWidget {
  final DailyNutrition nutrition;
  const _TodayTab({required this.nutrition});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final mealsAsync = ref.watch(todaysMealsProvider);

    // Loading state
    if (mealsAsync.isLoading && !mealsAsync.hasValue) {
      return Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          children: const [
            SkeletonCard(height: 140),
            SizedBox(height: AppSpacing.md),
            SkeletonCard(height: 100),
            SizedBox(height: AppSpacing.md),
            SkeletonCard(height: 100),
          ],
        ),
      );
    }

    // Error state
    if (mealsAsync.hasError && !mealsAsync.hasValue) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text('😕', style: TextStyle(fontSize: 40)),
              const SizedBox(height: AppSpacing.md),
              Text(
                'Couldn\'t load meals',
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),
              Text(
                'Pull down to retry',
                style: AppTypography.caption.copyWith(
                  color: colors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final meals = mealsAsync.valueOrNull ?? [];
    final hasAnyMeals = meals.isNotEmpty;

    return RefreshIndicator(
      onRefresh: () async {
        ref.invalidate(todaysMealsProvider);
        await Future.delayed(const Duration(milliseconds: 600));
      },
      color: context.colors.lime,
      backgroundColor: context.colors.bgSecondary,
      child: ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        // Macro summary
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'TODAY\'S MACROS',
                    style: AppTypography.overline.copyWith(color: colors.textTertiary),
                  ),
                  Text(
                    '${nutrition.consumedCalories.toStringAsFixed(0)} / ${nutrition.targetCalories.toStringAsFixed(0)} kcal',
                    style: AppTypography.caption.copyWith(
                      color: colors.lime,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.md),
              MacroBar(
                label: 'Protein',
                consumed: nutrition.consumedProtein,
                target: nutrition.targetProtein,
                color: AppColors.macroProtein,
                staggerIndex: 0,
              ),
              const SizedBox(height: AppSpacing.md),
              MacroBar(
                label: 'Carbs',
                consumed: nutrition.consumedCarbs,
                target: nutrition.targetCarbs,
                color: AppColors.macroCarbs,
                staggerIndex: 1,
              ),
              const SizedBox(height: AppSpacing.md),
              MacroBar(
                label: 'Fat',
                consumed: nutrition.consumedFat,
                target: nutrition.targetFat,
                color: AppColors.macroFat,
                staggerIndex: 2,
              ),
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppSpacing.sectionGap),

        // Overall empty state CTA when no meals logged at all
        if (!hasAnyMeals) ...[
          AppCard(
            backgroundColor: colors.limeGlow,
            borderColor: colors.lime.withValues(alpha: 0.3),
            child: EmptyStateWidget(
              emoji: '🍽️',
              headline: 'No meals logged today',
              body: 'Log your first meal to start tracking macros and earn XP!',
              ctaLabel: 'Log a Meal',
              onCta: () {
                AnalyticsService.instance.tap('log_meal_cta', screen: 'nutrition');
                context.push('/nutrition/log');
              },
              compact: true,
            ),
          ).animate().fadeIn(duration: 300.ms),
          const SizedBox(height: AppSpacing.md),
        ],

        // Meal sections
        ...(['Breakfast', 'Lunch', 'Dinner', 'Snack'].asMap().entries.map((e) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: _MealSection(
              mealType: e.value,
              onAdd: () {
                AnalyticsService.instance.tap('meal_section_add', screen: 'nutrition', props: {'meal_type': e.value.toLowerCase()});
                context.push('/nutrition/log');
              },
            ).animate(delay: (e.key * 60).ms).fadeIn(duration: 300.ms),
          );
        })),
      ],
      ),
    );
  }
}

class _MealSection extends ConsumerWidget {
  final String mealType;
  final VoidCallback onAdd;

  const _MealSection({required this.mealType, required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final colors = context.colors;
    final meals = ref.watch(mealsByTypeProvider(mealType));
    final totalCal = meals.fold(0.0, (sum, m) => sum + m.calories);

    // Empty — quiet single-line hint, no full card weight
    if (meals.isEmpty) {
      return GestureDetector(
        onTap: onAdd,
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.cardPadding,
            vertical: AppSpacing.md,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.lg),
            border: Border.all(color: colors.surfaceCardBorder),
          ),
          child: Row(
            children: [
              Text(mealEmoji(mealType), style: const TextStyle(fontSize: 16)),
              const SizedBox(width: AppSpacing.sm),
              Text(
                mealType,
                style: AppTypography.bodyMedium.copyWith(
                  color: colors.textTertiary,
                ),
              ),
              const Spacer(),
              Icon(Icons.add_rounded, size: 18, color: colors.textTertiary),
            ],
          ),
        ),
      );
    }

    // Populated — card with name + kcal only per item
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(mealEmoji(mealType), style: const TextStyle(fontSize: 18)),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    mealType,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  Text(
                    '${totalCal.toStringAsFixed(0)} kcal',
                    style: AppTypography.caption.copyWith(
                      color: colors.lime,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: colors.limeGlow,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: colors.lime.withValues(alpha: 0.4),
                        ),
                      ),
                      child: Icon(Icons.add_rounded, size: 16, color: colors.lime),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ...meals.map(
            (m) => Dismissible(
              key: ValueKey(m.id),
              direction: DismissDirection.endToStart,
              background: Container(
                alignment: Alignment.centerRight,
                padding: const EdgeInsets.only(right: 16),
                decoration: BoxDecoration(
                  color: colors.error.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Icon(Icons.delete_outline_rounded, color: colors.error),
              ),
              onDismissed: (_) async {
                AnalyticsService.instance.track('meal_deleted', props: {
                  'meal_name': m.name,
                  'calories': m.calories,
                  'meal_type': m.mealType,
                });
                final db = ref.read(databaseProvider);
                // Mirror the delete to Firestore if we have the cloud ID.
                // (Rows pre-cloudId-rollout have null and stay cloud-only —
                // SyncService dedup will catch them on next pull.)
                final cloudId = m.cloudId;
                final uid = AuthService.uid;
                if (cloudId != null && cloudId.isNotEmpty && uid != null) {
                  FirestoreService.deleteMealLog(uid, cloudId).catchError(
                      (e) => debugPrint('[Firestore] meal delete failed: $e'));
                }
                await db.deleteMeal(m.id);
                SnackbarService.info('Meal deleted');
              },
              child: Padding(
                padding: const EdgeInsets.only(top: AppSpacing.sm),
                child: Row(
                  children: [
                    Expanded(
                      child: AppText(
                        m.name,
                        style: AppTypography.body.copyWith(
                          color: colors.textSecondary,
                        ),
                      ),
                    ),
                    AppText(
                      '${m.calories.toStringAsFixed(0)} kcal',
                      style: AppTypography.caption.copyWith(
                        color: colors.warning,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _MealPlanTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MealPlanTab> createState() => _MealPlanTabState();
}

class _MealPlanTabState extends ConsumerState<_MealPlanTab> {
  bool _isGenerating = false;

  Future<Map<String, dynamic>> _buildUserContext() =>
      UserContextService.buildMealPlanContext(ref);

  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);
    AnalyticsService.instance.track('meal_plan_started', props: {'days': 7});
    final sw = Stopwatch()..start();
    try {
      final ai = ref.read(aiProvider);
      final ctx = await _buildUserContext();
      final result = await ai.generateMealPlan(
        userContext: ctx,
        days: 7,
      );

      sw.stop();
      AnalyticsService.instance.track('meal_plan_generated', props: {
        'days': 7,
        'ai_source': ai.lastSource.name,
        'duration_ms': sw.elapsedMilliseconds,
      });

      final db = ref.read(databaseProvider);
      final groceryList = result['grocery_list'] as List? ?? [];
      final planCreatedAt = DateTime.now();

      final newPlanId = await db.insertMealPlan(MealPlansCompanion(
        planJson: Value(jsonEncode(result)),
        days: const Value(7),
        groceryListJson: Value(jsonEncode(groceryList)),
        isActive: const Value(true),
        createdAt: Value(planCreatedAt),
      ));

      // Sync to Firestore for cross-device access
      final uid = AuthService.uid;
      if (uid != null) {
        FirestoreService.saveMealPlan(uid, newPlanId.toString(), {
          'planJson': jsonEncode(result),
          'days': 7,
          'groceryListJson': jsonEncode(groceryList),
          'isActive': true,
          'createdAt': planCreatedAt.toIso8601String(),
        }).catchError((e) => debugPrint('[Firestore] meal plan sync failed: $e'));
      }

      ref.invalidate(mealPlansProvider);

      if (mounted) {
        setState(() => _isGenerating = false);
        SnackbarService.success('Meal plan generated! 🍽️');
      }
    } catch (e) {
      sw.stop();
      AnalyticsService.instance.track('meal_plan_error', props: {
        'error': e.toString().substring(0, e.toString().length.clamp(0, 200)),
      });
      debugPrint('Meal plan error: $e');
      if (mounted) {
        setState(() => _isGenerating = false);
        SnackbarService.error('Could not generate plan. Please try again.');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final plansAsync = ref.watch(
      mealPlansProvider,
    );
    if (plansAsync.isLoading && !plansAsync.hasValue) {
      return Center(child: CircularProgressIndicator(color: colors.lime));
    }
    if (plansAsync.hasError && !plansAsync.hasValue) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Couldn\'t load meal plans', style: AppTypography.body.copyWith(color: colors.textTertiary)),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => ref.invalidate(mealPlansProvider),
              child: Text('Retry', style: AppTypography.bodyMedium.copyWith(color: colors.lime)),
            ),
          ],
        ),
      );
    }
    final plans = plansAsync.valueOrNull ?? [];

    if (plans.isNotEmpty) {
      return RefreshIndicator(
        onRefresh: () async {
          ref.invalidate(mealPlansProvider);
          await Future.delayed(const Duration(milliseconds: 600));
        },
        color: colors.lime,
        backgroundColor: colors.bgSecondary,
        child: _MealPlanView(plans: plans, onGenerate: _generatePlan, isGenerating: _isGenerating),
      );
    }

    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🤖', style: TextStyle(fontSize: 56)),
            const SizedBox(height: AppSpacing.md),
            Text('Generate AI Meal Plan', style: AppTypography.h3),
            const SizedBox(height: AppSpacing.sm),
            Text(
              'Get a personalized 7-day meal plan built around your goals, dietary preferences, and budget.',
              style: AppTypography.body
                  .copyWith(color: colors.textSecondary),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sectionGap),
            AppButton(
              label: _isGenerating
                  ? '⏳  Generating...'
                  : '⚡  Generate My Plan',
              onPressed: _isGenerating ? null : _generatePlan,
            ),
          ],
        ),
      ),
    );
  }
}

class _MealPlanView extends StatelessWidget {
  final List<MealPlan> plans;
  final VoidCallback onGenerate;
  final bool isGenerating;

  const _MealPlanView({
    required this.plans,
    required this.onGenerate,
    required this.isGenerating,
  });

  void _showMealDetail(BuildContext context, Map<String, dynamic> meal) {
    final colors = context.colors;
    final ingredients = (meal['ingredients'] as List?)?.cast<String>() ?? [];
    final availability = (meal['availability'] as List?)
            ?.map((e) => e as Map<String, dynamic>)
            .toList() ??
        [];
    final bestPrice = meal['best_price'];
    final currency = meal['currency'] as String? ?? 'PKR';
    final totals = meal['totals'] as Map? ?? {};
    final mealName = meal['name'] as String? ?? '';

    showModalBottomSheet(
      context: context,
      backgroundColor: colors.bgSecondary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      isScrollControlled: true,
      builder: (ctx) => DraggableScrollableSheet(
        expand: false,
        initialChildSize: 0.6,
        maxChildSize: 0.92,
        builder: (_, sc) => SingleChildScrollView(
          controller: sc,
          padding: const EdgeInsets.fromLTRB(
              AppSpacing.pagePadding, 12, AppSpacing.pagePadding, 32),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40, height: 4,
                  decoration: BoxDecoration(
                    color: colors.surfaceCardBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.md),

              // Meal name + type
              Text(
                mealName,
                style: AppTypography.h2.copyWith(fontWeight: FontWeight.w800),
              ),
              Text(
                (meal['meal_type'] as String? ?? meal['type'] as String? ?? '')
                    .toUpperCase(),
                style: AppTypography.overline.copyWith(color: colors.textTertiary),
              ),
              const SizedBox(height: AppSpacing.md),

              // Macros row
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _MacroChip2('Cal', '${totals['calories'] ?? 0}', colors.warning),
                  _MacroChip2('Protein', '${totals['protein_g'] ?? 0}g', colors.cyan),
                  _MacroChip2('Carbs', '${totals['carbs_g'] ?? 0}g', colors.lime),
                  _MacroChip2('Fat', '${totals['fat_g'] ?? 0}g', colors.coral),
                ],
              ),
              const SizedBox(height: AppSpacing.md),

              // Ingredients
              if (ingredients.isNotEmpty) ...[
                Text('INGREDIENTS', style: AppTypography.overline.copyWith(color: colors.textTertiary)),
                const SizedBox(height: AppSpacing.sm),
                Wrap(
                  spacing: 6,
                  runSpacing: 6,
                  children: ingredients.map((ing) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                    decoration: BoxDecoration(
                      color: colors.surfaceCard,
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(color: colors.surfaceCardBorder),
                    ),
                    child: Text(
                      ing,
                      style: AppTypography.caption.copyWith(color: colors.textSecondary),
                    ),
                  )).toList(),
                ),
                const SizedBox(height: AppSpacing.md),
              ],

              // Availability + pricing
              if (availability.isNotEmpty) ...[
                Row(
                  children: [
                    Text('AVAILABILITY & PRICE', style: AppTypography.overline.copyWith(color: colors.textTertiary)),
                    const Spacer(),
                    Text(currency, style: AppTypography.overline.copyWith(color: colors.textTertiary)),
                  ],
                ),
                const SizedBox(height: AppSpacing.sm),
                ...availability.map((a) {
                  final area = a['area'] as String? ?? '';
                  final minP = (a['min_price'] as num?)?.toInt() ?? 0;
                  final maxP = (a['max_price'] as num?)?.toInt() ?? 0;
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Row(
                      children: [
                        const Text('📍', style: TextStyle(fontSize: 13)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(area, style: AppTypography.body.copyWith(color: colors.textSecondary)),
                        ),
                        Text(
                          'Rs $minP – $maxP',
                          style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
                        ),
                      ],
                    ),
                  );
                }),
                if (bestPrice != null) ...[
                  const SizedBox(height: AppSpacing.sm),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
                    decoration: BoxDecoration(
                      color: colors.lime.withValues(alpha: 0.08),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border.all(color: colors.lime.withValues(alpha: 0.25)),
                    ),
                    child: Row(
                      children: [
                        const Text('💰', style: TextStyle(fontSize: 14)),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            'Best price: Rs $bestPrice',
                            style: AppTypography.caption.copyWith(
                              color: colors.lime,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    final activePlan = plans.firstWhere(
      (p) => p.isActive,
      orElse: () => plans.first,
    );
    Map<String, dynamic> planData = {};
    try {
      planData = jsonDecode(activePlan.planJson) as Map<String, dynamic>;
    } catch (e) { debugPrint('[Nutrition] parse meal plan JSON failed: $e'); }
    final days = planData['days'] as List? ?? [];

    return ListView(
      padding: const EdgeInsets.all(AppSpacing.pagePadding),
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                '7-Day Meal Plan',
                style: AppTypography.h3.copyWith(fontWeight: FontWeight.w800),
              ),
            ),
            TextButton.icon(
              onPressed: isGenerating ? null : () {
                AnalyticsService.instance.tap('meal_plan_regenerate', screen: 'nutrition');
                onGenerate();
              },
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(isGenerating ? 'Generating...' : 'Regenerate'),
              style: TextButton.styleFrom(foregroundColor: colors.lime),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...days.asMap().entries.map((entry) {
          final day = entry.value as Map<String, dynamic>;
          final meals = day['meals'] as List? ?? [];
          final dayTotals = day['day_totals'] as Map? ?? {};
          final totalCal = dayTotals['calories'] ?? day['total_calories'] ?? 0;
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'Day ${day['day']}',
                        style: AppTypography.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700, color: colors.cyan),
                      ),
                      Text(
                        '$totalCal kcal',
                        style: AppTypography.caption
                            .copyWith(color: colors.lime, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...meals.map((meal) {
                    final m = meal as Map<String, dynamic>;
                    final mCal = (m['totals'] as Map?)?['calories'] ?? m['calories'] ?? 0;
                    return GestureDetector(
                      onTap: () {
                        AnalyticsService.instance.tap('meal_plan_item', screen: 'nutrition', props: {'meal': m['name'] ?? ''});
                        _showMealDetail(context, m);
                      },
                      child: Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text(
                            mealEmoji(m['meal_type'] as String? ?? m['type'] as String? ?? ''),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              m['name'] as String? ?? '',
                              style: AppTypography.body.copyWith(
                                  color: colors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '$mCal kcal',
                            style: AppTypography.caption
                                .copyWith(color: colors.textTertiary),
                          ),
                          const SizedBox(width: 4),
                          Icon(Icons.chevron_right_rounded, size: 14, color: colors.textTertiary),
                        ],
                      ),
                    ));
                  }),
                ],
              ),
            ).animate(delay: (entry.key * 50).ms).fadeIn(duration: 300.ms),
          );
        }),

        // Grocery list
        if (planData['grocery_list'] != null) ...[
          const SizedBox(height: AppSpacing.sm),
          AppCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '🛒 GROCERY LIST',
                  style: AppTypography.overline
                      .copyWith(color: colors.textTertiary),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...(planData['grocery_list'] as List).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          Icon(Icons.check_box_outline_blank_rounded,
                              size: 16, color: colors.textTertiary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.toString(),
                              style: AppTypography.body
                                  .copyWith(color: colors.textSecondary),
                            ),
                          ),
                        ],
                      ),
                    )),
              ],
            ),
          ),
        ],
      ],
    );
  }

}

class _MacroChip2 extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  const _MacroChip2(this.label, this.value, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(value,
            style: AppTypography.bodyMedium
                .copyWith(fontWeight: FontWeight.w700, color: color)),
        Text(label,
            style: AppTypography.overline
                .copyWith(color: context.colors.textTertiary)),
      ],
    );
  }
}
