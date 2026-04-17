import 'package:flutter/material.dart';
import '../../../core/widgets/liquid_glass.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';

class FaqScreen extends StatelessWidget {
  const FaqScreen({super.key});

  static const _faqs = [
    (
      'How does the AI meal analysis work?',
      'Take a photo of your meal or describe it in text. FitSmart AI uses Google Gemini to identify food items, estimate portions, and calculate nutritional values including calories, protein, carbs, and fat.'
    ),
    (
      'How accurate is the calorie tracking?',
      'AI-based estimates are generally within 10-20% of actual values. For most precise tracking, you can adjust the quantities manually after the AI analysis.'
    ),
    (
      'What is the XP and level system?',
      'You earn XP for logging meals, completing workouts, hitting your macros, and maintaining streaks. As you earn XP, you level up from Rookie to FitSmart, unlocking badges along the way.'
    ),
    (
      'How are my nutrition targets calculated?',
      'Your targets are based on the Mifflin-St Jeor equation using your height, weight, age, gender, and activity level. These are adjusted based on your fitness goal (fat loss, muscle gain, etc.).'
    ),
    (
      'Can I use FitSmart offline?',
      'Yes! Meal logging, workout tracking, and weight logging all work offline using local storage. AI features (photo analysis, chat, meal plans) require an internet connection.'
    ),
    (
      'How do streaks work?',
      'Log at least one meal or workout each day to maintain your streak. If you miss a day, your streak resets — unless you have a streak freeze available.'
    ),
    (
      'Is my data private?',
      'Your data is stored locally on your device and synced to your private Firebase account. We never share your personal health data with third parties.'
    ),
    (
      'What AI model does FitSmart use?',
      'FitSmart uses Google Gemini 2.5 Flash for all AI features including meal analysis, workout planning, and the AI coach chat.'
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: LiquidAppBar(
        title: Text('Help & FAQ', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: ListView.separated(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        itemCount: _faqs.length,
        separatorBuilder: (_, __) => const SizedBox(height: 4),
        itemBuilder: (context, i) {
          final (question, answer) = _faqs[i];
          return ExpansionTile(
            title: Text(question, style: AppTypography.bodyMedium),
            collapsedIconColor: context.colors.textTertiary,
            iconColor: context.colors.lime,
            tilePadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
            collapsedShape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: context.colors.surfaceCardBorder),
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppRadius.md),
              side: BorderSide(color: context.colors.lime),
            ),
            collapsedBackgroundColor: context.colors.surfaceCard,
            backgroundColor: context.colors.surfaceCard,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.md),
                child: Text(
                  answer,
                  style: AppTypography.body.copyWith(color: context.colors.textSecondary),
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
