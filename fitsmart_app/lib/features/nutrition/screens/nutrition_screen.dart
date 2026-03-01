import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:drift/drift.dart' hide Column;
import 'package:shared_preferences/shared_preferences.dart';
import '../../dashboard/providers/dashboard_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_card.dart';
import '../../../core/widgets/app_button.dart';
import '../../../core/widgets/macro_bar.dart';
import '../../../core/widgets/skeleton_loader.dart';
import '../../../data/database/app_database.dart';
import '../../../data/database/database_provider.dart';
import '../../../providers/gemini_provider.dart';
import '../../../services/gemini_client.dart';
import '../../../services/snackbar_service.dart';

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
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final nutrition = ref.watch(dailyNutritionProvider);

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: const Text('Nutrition'),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded),
            color: AppColors.lime,
            onPressed: () => context.push('/nutrition/log'),
          ),
        ],
        bottom: TabBar(
          controller: _tabs,
          indicatorColor: AppColors.lime,
          indicatorWeight: 2,
          labelColor: AppColors.lime,
          unselectedLabelColor: AppColors.textTertiary,
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
                  color: AppColors.textTertiary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final meals = mealsAsync.valueOrNull ?? [];
    final hasAnyMeals = meals.isNotEmpty;

    return ListView(
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
                    style: AppTypography.overline.copyWith(color: AppColors.textTertiary),
                  ),
                  Text(
                    '${nutrition.consumedCalories.toStringAsFixed(0)} / ${nutrition.targetCalories.toStringAsFixed(0)} kcal',
                    style: AppTypography.caption.copyWith(
                      color: AppColors.lime,
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
            ],
          ),
        ).animate().fadeIn(duration: 300.ms),
        const SizedBox(height: AppSpacing.md),

        // Overall empty state CTA when no meals logged at all
        if (!hasAnyMeals) ...[
          AppCard(
            backgroundColor: AppColors.limeGlow,
            borderColor: AppColors.lime.withValues(alpha: 0.3),
            child: Column(
              children: [
                const Text('🍽️', style: TextStyle(fontSize: 40)),
                const SizedBox(height: AppSpacing.md),
                Text(
                  'No meals logged today',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Log your first meal to start tracking macros and earn XP!',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textTertiary,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: AppSpacing.md),
                AppButton(
                  label: '📸  Log a Meal',
                  onPressed: () => context.push('/nutrition/log'),
                  fullWidth: false,
                ),
              ],
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
              onAdd: () => context.push('/nutrition/log'),
            ).animate(delay: (e.key * 60).ms).fadeIn(duration: 300.ms),
          );
        })),
      ],
    );
  }
}

class _MealSection extends ConsumerWidget {
  final String mealType;
  final VoidCallback onAdd;

  const _MealSection({required this.mealType, required this.onAdd});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final allMeals = ref.watch(todaysMealsProvider).valueOrNull ?? [];
    final meals = allMeals
        .where((m) => m.mealType.toLowerCase() == mealType.toLowerCase())
        .toList();
    final totalCal =
        meals.fold(0.0, (sum, m) => sum + m.calories);

    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(_mealEmoji(mealType),
                        style: const TextStyle(fontSize: 18)),
                    const SizedBox(width: AppSpacing.sm),
                    Flexible(
                      child: Text(
                        mealType,
                        style: AppTypography.bodyMedium
                            .copyWith(fontWeight: FontWeight.w700),
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  Text(
                    meals.isEmpty
                        ? '0 kcal'
                        : '${totalCal.toStringAsFixed(0)} kcal',
                    style: AppTypography.caption.copyWith(
                      color: meals.isEmpty
                          ? AppColors.textTertiary
                          : AppColors.lime,
                      fontWeight: meals.isEmpty
                          ? FontWeight.normal
                          : FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  GestureDetector(
                    onTap: onAdd,
                    child: Container(
                      width: 28,
                      height: 28,
                      decoration: BoxDecoration(
                        color: AppColors.limeGlow,
                        shape: BoxShape.circle,
                        border: Border.all(
                            color: AppColors.lime.withValues(alpha: 0.4)),
                      ),
                      child: const Icon(Icons.add_rounded,
                          size: 16, color: AppColors.lime),
                    ),
                  ),
                ],
              ),
            ],
          ),
          if (meals.isEmpty)
            Padding(
              padding: const EdgeInsets.only(top: AppSpacing.md),
              child: Text(
                'Nothing logged yet',
                style: AppTypography.caption
                    .copyWith(color: AppColors.textTertiary),
              ),
            )
          else ...[
            const SizedBox(height: AppSpacing.sm),
            ...meals.map((m) => Dismissible(
                  key: ValueKey(m.id),
                  direction: DismissDirection.endToStart,
                  background: Container(
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 16),
                    decoration: BoxDecoration(
                      color: AppColors.error.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                    child: const Icon(Icons.delete_outline_rounded,
                        color: AppColors.error),
                  ),
                  onDismissed: (_) async {
                    final db = ref.read(databaseProvider);
                    await db.deleteMeal(m.id);
                    SnackbarService.info('Meal deleted');
                  },
                  child: Padding(
                    padding: const EdgeInsets.only(top: 6),
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            m.name,
                            style: AppTypography.body
                                .copyWith(color: AppColors.textSecondary),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Text(
                          '${m.calories.toStringAsFixed(0)} kcal · P${m.proteinG.toStringAsFixed(0)}g',
                          style: AppTypography.caption
                              .copyWith(color: AppColors.textTertiary),
                        ),
                      ],
                    ),
                  ),
                )),
          ],
        ],
      ),
    );
  }

  String _mealEmoji(String type) {
    switch (type) {
      case 'Breakfast':
        return '🌅';
      case 'Lunch':
        return '☀️';
      case 'Dinner':
        return '🌙';
      case 'Snack':
        return '🍎';
      default:
        return '🍽️';
    }
  }
}

class _MealPlanTab extends ConsumerStatefulWidget {
  @override
  ConsumerState<_MealPlanTab> createState() => _MealPlanTabState();
}

class _MealPlanTabState extends ConsumerState<_MealPlanTab> {
  bool _isGenerating = false;

  Future<Map<String, dynamic>> _buildUserContext() async {
    final targets = ref.read(nutritionTargetsProvider);
    Map<String, dynamic> profile = {};
    try {
      final prefs = await SharedPreferences.getInstance();
      final jsonStr = prefs.getString('onboarding_data');
      if (jsonStr != null) {
        profile = jsonDecode(jsonStr) as Map<String, dynamic>;
      }
    } catch (_) {}
    return {
      'goal': profile['primaryGoal'] ?? 'general_fitness',
      'target_calories': targets.calories.round(),
      'target_protein_g': targets.proteinG.round(),
      'target_carbs_g': targets.carbsG.round(),
      'target_fat_g': targets.fatG.round(),
      'dietary_restrictions': profile['dietaryRestrictions'] ?? [],
      'cuisine_preferences': profile['cuisinePreferences'] ?? [],
      'disliked_ingredients': profile['dislikedIngredients'] ?? [],
    };
  }

  Future<void> _generatePlan() async {
    setState(() => _isGenerating = true);
    try {
      final gemini = ref.read(geminiClientProvider);
      final ctx = await _buildUserContext();
      final result = await gemini.generateMealPlan(
        userContext: ctx,
        days: 7,
      );

      final db = ref.read(databaseProvider);
      final groceryList = result['grocery_list'] as List? ?? [];

      await db.insertMealPlan(MealPlansCompanion(
        planJson: Value(jsonEncode(result)),
        days: const Value(7),
        groceryListJson: Value(jsonEncode(groceryList)),
        isActive: const Value(true),
        createdAt: Value(DateTime.now()),
      ));

      ref.invalidate(mealPlansProvider);

      if (mounted) {
        setState(() => _isGenerating = false);
        SnackbarService.success('Meal plan generated! 🍽️');
      }
    } on GeminiException catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        SnackbarService.error(e.message);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isGenerating = false);
        SnackbarService.error('Failed to generate plan: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final plansAsync = ref.watch(
      mealPlansProvider,
    );
    if (plansAsync.isLoading && !plansAsync.hasValue) {
      return const Center(child: CircularProgressIndicator(color: AppColors.lime));
    }
    if (plansAsync.hasError && !plansAsync.hasValue) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text('Couldn\'t load meal plans', style: AppTypography.body.copyWith(color: AppColors.textTertiary)),
            const SizedBox(height: AppSpacing.sm),
            TextButton(
              onPressed: () => ref.invalidate(mealPlansProvider),
              child: Text('Retry', style: AppTypography.bodyMedium.copyWith(color: AppColors.lime)),
            ),
          ],
        ),
      );
    }
    final plans = plansAsync.valueOrNull ?? [];

    if (plans.isNotEmpty) {
      return _MealPlanView(plans: plans, onGenerate: _generatePlan, isGenerating: _isGenerating);
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
                  .copyWith(color: AppColors.textSecondary),
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

  @override
  Widget build(BuildContext context) {
    final activePlan = plans.firstWhere(
      (p) => p.isActive,
      orElse: () => plans.first,
    );
    Map<String, dynamic> planData = {};
    try {
      planData = jsonDecode(activePlan.planJson) as Map<String, dynamic>;
    } catch (_) {}
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
              onPressed: isGenerating ? null : onGenerate,
              icon: const Icon(Icons.refresh_rounded, size: 16),
              label: Text(isGenerating ? 'Generating...' : 'Regenerate'),
              style: TextButton.styleFrom(foregroundColor: AppColors.lime),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.md),
        ...days.asMap().entries.map((entry) {
          final day = entry.value as Map<String, dynamic>;
          final meals = day['meals'] as List? ?? [];
          final totalCal = day['total_calories'] ?? 0;
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
                            .copyWith(fontWeight: FontWeight.w700, color: AppColors.cyan),
                      ),
                      Text(
                        '$totalCal kcal',
                        style: AppTypography.caption
                            .copyWith(color: AppColors.lime, fontWeight: FontWeight.w700),
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  ...meals.map((meal) {
                    final m = meal as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Row(
                        children: [
                          Text(
                            _mealTypeEmoji(m['type'] as String? ?? ''),
                            style: const TextStyle(fontSize: 14),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              m['name'] as String? ?? '',
                              style: AppTypography.body.copyWith(
                                  color: AppColors.textSecondary),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          Text(
                            '${m['calories'] ?? 0} kcal',
                            style: AppTypography.caption
                                .copyWith(color: AppColors.textTertiary),
                          ),
                        ],
                      ),
                    );
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
                      .copyWith(color: AppColors.textTertiary),
                ),
                const SizedBox(height: AppSpacing.sm),
                ...(planData['grocery_list'] as List).map((item) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Row(
                        children: [
                          const Icon(Icons.check_box_outline_blank_rounded,
                              size: 16, color: AppColors.textTertiary),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              item.toString(),
                              style: AppTypography.body
                                  .copyWith(color: AppColors.textSecondary),
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

  String _mealTypeEmoji(String type) {
    switch (type.toLowerCase()) {
      case 'breakfast':
        return '🌅';
      case 'lunch':
        return '☀️';
      case 'dinner':
        return '🌙';
      case 'snack':
        return '🍎';
      default:
        return '🍽️';
    }
  }
}
