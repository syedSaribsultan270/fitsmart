import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../models/onboarding_data.dart';
import '../../../features/dashboard/providers/dashboard_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/snackbar_service.dart';

class EditDietScreen extends ConsumerStatefulWidget {
  const EditDietScreen({super.key});

  @override
  ConsumerState<EditDietScreen> createState() => _EditDietScreenState();
}

class _EditDietScreenState extends ConsumerState<EditDietScreen> {
  List<String> _restrictions = [];
  List<String> _cuisines = [];
  final _dislikedController = TextEditingController();
  bool _isLoading = false;

  static const _allRestrictions = [
    'Vegetarian', 'Vegan', 'Keto', 'Paleo', 'Halal',
    'Kosher', 'Gluten-Free', 'Dairy-Free', 'Nut-Free', 'Low-Carb',
  ];

  static const _allCuisines = [
    'Mediterranean', 'Asian', 'Mexican', 'Indian', 'American',
    'Italian', 'Japanese', 'Middle Eastern', 'Thai', 'Korean',
  ];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile != null) {
      _restrictions = List.from(profile.dietaryRestrictions ?? []);
      _cuisines = List.from(profile.cuisinePreferences ?? []);
      _dislikedController.text = (profile.dislikedIngredients ?? []).join(', ');
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('onboarding_data');
      final data = json != null ? OnboardingData.fromJson(jsonDecode(json)) : OnboardingData();

      data.dietaryRestrictions = _restrictions;
      data.cuisinePreferences = _cuisines;
      data.dislikedIngredients = _dislikedController.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();

      await prefs.setString('onboarding_data', jsonEncode(data.toJson()));
      final uid = AuthService.uid;
      if (uid != null) FirestoreService.saveProfile(uid, data.toJson()).catchError((_) {});
      ref.invalidate(userProfileProvider);

      if (mounted) {
        SnackbarService.success('Diet preferences updated!');
        context.pop();
      }
    } catch (_) {
      SnackbarService.error('Failed to save.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _dislikedController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text('Diet Preferences', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.lime))
                : Text('Save', style: AppTypography.bodyMedium.copyWith(color: AppColors.lime)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          Text('DIETARY RESTRICTIONS', style: AppTypography.overline),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allRestrictions.map((r) {
              final selected = _restrictions.contains(r.toLowerCase());
              return FilterChip(
                label: Text(r),
                selected: selected,
                onSelected: (v) => setState(() {
                  v ? _restrictions.add(r.toLowerCase()) : _restrictions.remove(r.toLowerCase());
                }),
                selectedColor: AppColors.lime.withValues(alpha: 0.2),
                checkmarkColor: AppColors.lime,
                labelStyle: AppTypography.caption.copyWith(
                  color: selected ? AppColors.lime : AppColors.textSecondary,
                ),
                side: BorderSide(color: selected ? AppColors.lime : AppColors.surfaceCardBorder),
                backgroundColor: AppColors.surfaceCard,
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.lg),
          Text('CUISINE PREFERENCES', style: AppTypography.overline),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allCuisines.map((c) {
              final selected = _cuisines.contains(c.toLowerCase());
              return FilterChip(
                label: Text(c),
                selected: selected,
                onSelected: (v) => setState(() {
                  v ? _cuisines.add(c.toLowerCase()) : _cuisines.remove(c.toLowerCase());
                }),
                selectedColor: AppColors.cyan.withValues(alpha: 0.2),
                checkmarkColor: AppColors.cyan,
                labelStyle: AppTypography.caption.copyWith(
                  color: selected ? AppColors.cyan : AppColors.textSecondary,
                ),
                side: BorderSide(color: selected ? AppColors.cyan : AppColors.surfaceCardBorder),
                backgroundColor: AppColors.surfaceCard,
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _dislikedController,
            style: AppTypography.body,
            maxLines: 2,
            decoration: const InputDecoration(
              labelText: 'Disliked Ingredients',
              hintText: 'e.g. mushrooms, olives, cilantro',
            ),
          ),
        ],
      ),
    );
  }
}
