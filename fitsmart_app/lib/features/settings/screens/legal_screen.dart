import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';

class LegalScreen extends StatelessWidget {
  final String title;
  final String content;

  const LegalScreen({super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.bgPrimary,
      appBar: AppBar(
        title: Text(title, style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        child: Text(
          content,
          style: AppTypography.body.copyWith(color: context.colors.textSecondary, height: 1.7),
        ),
      ),
    );
  }
}

const privacyPolicyText = '''
Privacy Policy — FitSmart AI
Last updated: February 2026

1. DATA WE COLLECT
FitSmart AI collects the following data to provide personalized fitness and nutrition tracking:
• Profile information (age, gender, height, weight, fitness goals)
• Meal logs and nutritional data
• Workout logs and exercise history
• Weight and body measurement history
• Photos submitted for AI meal analysis (processed in real-time, not stored on our servers)

2. HOW WE USE YOUR DATA
Your data is used exclusively to:
• Calculate personalized nutrition targets (TDEE, macros)
• Provide AI-powered meal analysis and coaching
• Track your fitness progress over time
• Maintain your XP, streaks, and gamification state

3. DATA STORAGE
• Local data is stored on your device using SQLite (Drift) and SharedPreferences
• Cloud data is stored in your private Firebase Firestore document, accessible only to your authenticated account
• AI requests are processed via Google Gemini API and are subject to Google's privacy policy

4. DATA SHARING
We do NOT sell, share, or distribute your personal health data to any third parties.

5. DATA DELETION
You can delete all your data at any time by using the "Reset & Re-run Onboarding" option in Settings, or by deleting your account.

6. CONTACT
For privacy concerns, please reach out via the app's feedback form.
''';

const termsOfServiceText = '''
Terms of Service — FitSmart AI
Last updated: February 2026

1. ACCEPTANCE
By using FitSmart AI, you agree to these terms of service.

2. SERVICE DESCRIPTION
FitSmart AI is a fitness and nutrition tracking application that uses artificial intelligence to help users monitor their diet, exercise, and body composition. The app provides estimates and suggestions — it is NOT a substitute for professional medical or nutritional advice.

3. AI DISCLAIMER
• Nutritional estimates from photo/text analysis are approximations and may not be 100% accurate
• AI-generated meal and workout plans are suggestions, not prescriptions
• Always consult a healthcare provider before making significant changes to your diet or exercise routine

4. USER RESPONSIBILITIES
• You are responsible for the accuracy of the profile information you provide
• You must be at least 16 years old to use FitSmart AI
• You agree not to misuse the AI features (e.g., submitting inappropriate content)

5. DATA & PRIVACY
Your data usage is governed by our Privacy Policy. By using the app, you consent to the data practices described therein.

6. LIMITATION OF LIABILITY
FitSmart AI is provided "as is" without warranty. We are not liable for any health outcomes resulting from following AI-generated suggestions.

7. MODIFICATIONS
We reserve the right to modify these terms at any time. Continued use of the app constitutes acceptance of updated terms.
''';
