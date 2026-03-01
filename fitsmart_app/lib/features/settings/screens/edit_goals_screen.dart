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

class EditGoalsScreen extends ConsumerStatefulWidget {
  const EditGoalsScreen({super.key});

  @override
  ConsumerState<EditGoalsScreen> createState() => _EditGoalsScreenState();
}

class _EditGoalsScreenState extends ConsumerState<EditGoalsScreen> {
  final _targetWeightController = TextEditingController();
  String? _goal;
  String? _pace;
  int _workoutDays = 4;
  bool _isLoading = false;

  static const _goals = {
    'lose_fat': ('🔥', 'Lose Fat'),
    'gain_muscle': ('💪', 'Gain Muscle'),
    'recomp': ('⚖️', 'Body Recomp'),
    'maintain': ('✅', 'Maintain'),
    'athletic': ('🏃', 'Athletic Performance'),
  };

  static const _paces = ['slow', 'steady', 'aggressive', 'maximum'];

  @override
  void initState() {
    super.initState();
    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile != null) {
      _goal = profile.primaryGoal;
      _pace = profile.weightChangePace;
      _workoutDays = profile.workoutDaysPerWeek ?? 4;
      _targetWeightController.text = profile.targetWeightKg?.toString() ?? '';
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('onboarding_data');
      final data = json != null ? OnboardingData.fromJson(jsonDecode(json)) : OnboardingData();

      if (_goal != null) data.primaryGoal = _goal;
      if (_pace != null) data.weightChangePace = _pace;
      data.workoutDaysPerWeek = _workoutDays;
      if (_targetWeightController.text.isNotEmpty) {
        data.targetWeightKg = double.tryParse(_targetWeightController.text);
      }

      await prefs.setString('onboarding_data', jsonEncode(data.toJson()));
      final uid = AuthService.uid;
      if (uid != null) FirestoreService.saveProfile(uid, data.toJson()).catchError((_) {});
      ref.invalidate(userProfileProvider);

      if (mounted) {
        SnackbarService.success('Goals updated!');
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
    _targetWeightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text('Fitness Goals', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
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
          Text('Primary Goal', style: AppTypography.caption.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: AppSpacing.sm),
          ..._goals.entries.map((e) => _GoalTile(
                emoji: e.value.$1,
                label: e.value.$2,
                isSelected: _goal == e.key,
                onTap: () => setState(() => _goal = e.key),
              )),

          const SizedBox(height: AppSpacing.lg),
          TextFormField(
            controller: _targetWeightController,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: AppTypography.body,
            decoration: const InputDecoration(labelText: 'Target Weight (kg)'),
          ),

          const SizedBox(height: AppSpacing.lg),
          Text('Pace', style: AppTypography.caption.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            children: _paces.map((p) {
              final isSelected = _pace == p;
              return ChoiceChip(
                label: Text(p[0].toUpperCase() + p.substring(1)),
                selected: isSelected,
                onSelected: (_) => setState(() => _pace = p),
                selectedColor: AppColors.lime.withValues(alpha: 0.2),
                labelStyle: AppTypography.caption.copyWith(
                  color: isSelected ? AppColors.lime : AppColors.textSecondary,
                ),
                side: BorderSide(color: isSelected ? AppColors.lime : AppColors.surfaceCardBorder),
                backgroundColor: AppColors.surfaceCard,
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.lg),
          Text('Workout Days / Week', style: AppTypography.caption.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: AppSpacing.sm),
          Slider(
            value: _workoutDays.toDouble(),
            min: 1,
            max: 7,
            divisions: 6,
            label: '$_workoutDays days',
            onChanged: (v) => setState(() => _workoutDays = v.round()),
          ),
          Center(
            child: Text(
              '$_workoutDays days per week',
              style: AppTypography.bodyMedium.copyWith(color: AppColors.lime),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoalTile extends StatelessWidget {
  final String emoji;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  const _GoalTile({
    required this.emoji,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.limeGlow : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: isSelected ? AppColors.lime : AppColors.surfaceCardBorder),
        ),
        child: Row(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 24)),
            const SizedBox(width: AppSpacing.md),
            Text(label, style: AppTypography.bodyMedium),
            const Spacer(),
            if (isSelected) const Icon(Icons.check_circle_rounded, color: AppColors.lime, size: 20),
          ],
        ),
      ),
    );
  }
}
