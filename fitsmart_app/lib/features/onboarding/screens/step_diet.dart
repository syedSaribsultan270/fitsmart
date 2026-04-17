import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_button.dart';
import 'onboarding_flow.dart';

class StepDiet extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const StepDiet({super.key, required this.onNext});

  @override
  ConsumerState<StepDiet> createState() => _StepDietState();
}

class _StepDietState extends ConsumerState<StepDiet> {
  final Set<String> _restrictions = {};
  final Set<String> _cuisines = {};
  final _dislikedController = TextEditingController();

  static const _dietOptions = [
    ('\uD83C\uDF7D\uFE0F', 'Everything', 'no_restriction'),
    ('\uD83E\uDD57', 'Vegetarian', 'vegetarian'),
    ('\uD83C\uDF31', 'Vegan', 'vegan'),
    ('\uD83D\uDC1F', 'Pescatarian', 'pescatarian'),
    ('\uD83E\uDD53', 'Keto', 'keto'),
    ('\uD83E\uDDB4', 'Paleo', 'paleo'),
    ('\u262A\uFE0F', 'Halal', 'halal'),
    ('\u2721\uFE0F', 'Kosher', 'kosher'),
    ('\uD83C\uDF3E', 'Gluten-Free', 'gluten_free'),
    ('\uD83E\uDD5B', 'Dairy-Free', 'dairy_free'),
    ('\uD83C\uDF36\uFE0F', 'Low FODMAP', 'low_fodmap'),
    ('\uD83D\uDC89', 'Diabetic-Friendly', 'diabetic'),
  ];

  static const _cuisineOptions = [
    ('\uD83C\uDF5B', 'Indian'), ('\uD83C\uDF5D', 'Italian'), ('\uD83C\uDF2E', 'Mexican'), ('\uD83C\uDF5C', 'Asian'),
    ('\uD83E\uDD59', 'Mediterranean'), ('\uD83C\uDF54', 'American'), ('\uD83E\uDD58', 'Middle Eastern'),
    ('\uD83C\uDF71', 'Japanese'), ('\uD83E\uDD57', 'Salad/Healthy'), ('\uD83C\uDF55', 'Pizza/Comfort'),
    ('\uD83C\uDF56', 'BBQ'), ('\uD83C\uDF63', 'Sushi'), ('\uD83C\uDF0D', 'African'), ('\uD83E\uDD50', 'French'),
  ];

  @override
  void dispose() {
    _dislikedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepBase(
      emoji: '\uD83C\uDF7D\uFE0F',
      title: 'What Fuels\nYour Engine?',
      subtitle: 'Your AI meal plans will respect these preferences.',
      scrollable: true,
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('DIETARY STYLE', style: AppTypography.overline.copyWith(color: context.colors.textTertiary)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _dietOptions.asMap().entries.map((e) {
              final (emoji, label, id) = e.value;
              final isSelected = _restrictions.contains(id) ||
                  (id == 'no_restriction' && _restrictions.isEmpty);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (id == 'no_restriction') {
                      _restrictions.clear();
                    } else {
                      if (_restrictions.contains(id)) {
                        _restrictions.remove(id);
                      } else {
                        _restrictions.add(id);
                      }
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: 180.ms,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? context.colors.limeGlow : context.colors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: isSelected ? context.colors.lime : context.colors.surfaceCardBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 16)),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: AppTypography.caption.copyWith(
                          color: isSelected ? context.colors.lime : context.colors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ).animate(delay: (e.key * 30).ms).fadeIn(duration: 200.ms);
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          Text('CUISINE PREFERENCES', style: AppTypography.overline.copyWith(color: context.colors.textTertiary)),
          const SizedBox(height: AppSpacing.md),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _cuisineOptions.map((c) {
              final (emoji, label) = c;
              final isSelected = _cuisines.contains(label);
              return GestureDetector(
                onTap: () {
                  HapticFeedback.selectionClick();
                  setState(() {
                    if (isSelected) {
                      _cuisines.remove(label);
                    } else {
                      _cuisines.add(label);
                    }
                  });
                },
                child: AnimatedContainer(
                  duration: 180.ms,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected ? context.colors.cyan.withValues(alpha: 0.1) : context.colors.surfaceCard,
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: Border.all(
                      color: isSelected ? context.colors.cyan : context.colors.surfaceCardBorder,
                      width: isSelected ? 1.5 : 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(emoji, style: const TextStyle(fontSize: 14)),
                      const SizedBox(width: 6),
                      Text(
                        label,
                        style: AppTypography.caption.copyWith(
                          color: isSelected ? context.colors.cyan : context.colors.textSecondary,
                          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          Text('DISLIKED INGREDIENTS (OPTIONAL)', style: AppTypography.overline.copyWith(color: context.colors.textTertiary)),
          const SizedBox(height: AppSpacing.md),
          TextField(
            controller: _dislikedController,
            style: AppTypography.body,
            maxLines: 2,
            decoration: const InputDecoration(
              hintText: 'e.g. mushrooms, cilantro, liver...',
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
        ],
      ),
      cta: AppButton(
        label: 'Set My Food Preferences',
        onPressed: () {
          final notifier = ref.read(onboardingProvider.notifier);
          notifier.setDietaryRestrictions(_restrictions.toList());
          notifier.setCuisinePreferences(_cuisines.toList());
          if (_dislikedController.text.trim().isNotEmpty) {
            notifier.setDislikedIngredients(
              _dislikedController.text.split(',').map((s) => s.trim()).toList(),
            );
          }
          widget.onNext();
        },
      ),
    );
  }
}
