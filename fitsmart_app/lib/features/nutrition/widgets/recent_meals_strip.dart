import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../data/database/app_database.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../../../services/analytics_service.dart';

/// Horizontal strip of recent unique meals for one-tap re-log.
/// Only renders when the user has at least one previous meal logged.
class RecentMealsStrip extends ConsumerWidget {
  /// Called when the user taps a recent meal chip.
  /// Passes the original [MealLog] so the caller can re-log it directly.
  final void Function(MealLog meal) onSelect;

  const RecentMealsStrip({super.key, required this.onSelect});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recentAsync = ref.watch(recentMealsProvider);

    return recentAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (meals) {
        if (meals.isEmpty) return const SizedBox.shrink();

        return Container(
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: context.colors.surfaceCardBorder),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.pagePadding, AppSpacing.sm, AppSpacing.pagePadding, 0,
                ),
                child: Text(
                  'RECENT',
                  style: AppTypography.overline.copyWith(
                    color: context.colors.textTertiary,
                  ),
                ),
              ),
              SizedBox(
                height: 44,
                child: ListView.separated(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.pagePadding,
                    vertical: 6,
                  ),
                  itemCount: meals.length,
                  separatorBuilder: (_, __) => const SizedBox(width: AppSpacing.sm),
                  itemBuilder: (context, i) {
                    final meal = meals[i];
                    return _MealChip(
                      meal: meal,
                      onTap: () {
                        AnalyticsService.instance.track('recent_meal_tapped', props: {
                          'meal_name': meal.name,
                          'calories': meal.calories,
                          'meal_type': meal.mealType,
                        });
                        onSelect(meal);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _MealChip extends StatelessWidget {
  final MealLog meal;
  final VoidCallback onTap;

  const _MealChip({required this.meal, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
        decoration: BoxDecoration(
          color: context.colors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: context.colors.surfaceCardBorder),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              meal.name.length > 20 ? '${meal.name.substring(0, 18)}…' : meal.name,
              style: AppTypography.caption.copyWith(
                color: context.colors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '${meal.calories.toStringAsFixed(0)} kcal',
              style: AppTypography.caption.copyWith(
                color: context.colors.textTertiary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
