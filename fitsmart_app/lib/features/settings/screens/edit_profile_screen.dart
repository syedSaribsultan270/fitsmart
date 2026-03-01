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
import '../../../providers/settings_provider.dart';
import '../../../services/auth_service.dart';
import '../../../services/firestore_service.dart';
import '../../../services/snackbar_service.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _ageController = TextEditingController();
  final _heightController = TextEditingController();
  final _weightController = TextEditingController();
  String? _gender;
  bool _isLoading = false;
  String? _photoUrl;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    final user = AuthService.currentUser;
    final settings = ref.read(settingsProvider);

    // Pre-fill from Firebase Auth first
    _nameController.text = user?.displayName ?? settings.displayName;
    _emailController.text = user?.email ?? '';
    _photoUrl = user?.photoURL;

    final profile = ref.read(userProfileProvider).valueOrNull;
    if (profile != null) {
      _ageController.text = profile.age?.toString() ?? '';
      _heightController.text = profile.heightCm?.toString() ?? '';
      _weightController.text = profile.weightKg?.toString() ?? '';
      _gender = profile.gender;
    }
  }

  Future<void> _save() async {
    setState(() => _isLoading = true);
    try {
      final user = AuthService.currentUser;

      // Update display name
      final newName = _nameController.text.trim();
      if (newName.isNotEmpty) {
        ref.read(settingsProvider.notifier).setDisplayName(newName);
        await AuthService.updateDisplayName(newName);
      }

      // Handle email change with re-verification
      final newEmail = _emailController.text.trim();
      if (user != null &&
          !user.isAnonymous &&
          newEmail.isNotEmpty &&
          newEmail != user.email) {
        try {
          await user.verifyBeforeUpdateEmail(newEmail);
          SnackbarService.info('Verification email sent to $newEmail. Please verify to complete the change.');
        } catch (e) {
          SnackbarService.error('Email change failed. You may need to re-authenticate.');
        }
      }

      // Update onboarding data
      final prefs = await SharedPreferences.getInstance();
      final json = prefs.getString('onboarding_data');
      final data = json != null
          ? OnboardingData.fromJson(jsonDecode(json))
          : OnboardingData();

      if (_ageController.text.isNotEmpty) data.age = int.tryParse(_ageController.text);
      if (_heightController.text.isNotEmpty) data.heightCm = double.tryParse(_heightController.text);
      if (_weightController.text.isNotEmpty) data.weightKg = double.tryParse(_weightController.text);
      if (_gender != null) data.gender = _gender;

      await prefs.setString('onboarding_data', jsonEncode(data.toJson()));

      // Sync to Firestore
      final uid = AuthService.uid;
      if (uid != null) {
        FirestoreService.saveProfile(uid, data.toJson()).catchError((_) {});
      }

      // Invalidate profile provider so dashboard recalculates
      ref.invalidate(userProfileProvider);

      if (mounted) {
        SnackbarService.success('Profile updated!');
        context.pop();
      }
    } catch (e) {
      SnackbarService.error('Failed to save. Please try again.');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _ageController.dispose();
    _heightController.dispose();
    _weightController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: AppBar(
        title: Text('Edit Profile', style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700)),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18),
          onPressed: () => context.pop(),
        ),
        actions: [
          TextButton(
            onPressed: _isLoading ? null : _save,
            child: _isLoading
                ? const SizedBox(
                    width: 20, height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2, color: AppColors.lime),
                  )
                : Text('Save', style: AppTypography.bodyMedium.copyWith(color: AppColors.lime)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppSpacing.pagePadding),
        children: [
          // Profile photo preview
          Center(
            child: Column(
              children: [
                if (_photoUrl != null && _photoUrl!.isNotEmpty)
                  CircleAvatar(radius: 40, backgroundImage: NetworkImage(_photoUrl!))
                else
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [AppColors.lime, AppColors.cyan],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Text(
                        _nameController.text.isNotEmpty ? _nameController.text[0].toUpperCase() : '?',
                        style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.black),
                      ),
                    ),
                  ),
                const SizedBox(height: AppSpacing.sm),
                Text(
                  'Photo synced from your Google account',
                  style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          _field('Display Name', _nameController, TextInputType.name),
          const SizedBox(height: AppSpacing.md),

          // Email field (read-only hint if anonymous)
          if (AuthService.currentUser != null && !AuthService.isAnonymous)
            _field('Email', _emailController, TextInputType.emailAddress),
          if (AuthService.currentUser != null && !AuthService.isAnonymous)
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                'Changing your email will send a verification link to the new address.',
                style: AppTypography.caption.copyWith(color: AppColors.textTertiary, fontSize: 11),
              ),
            ),
          const SizedBox(height: AppSpacing.md),

          // Gender selector
          Text('Gender', style: AppTypography.caption.copyWith(color: AppColors.textTertiary)),
          const SizedBox(height: AppSpacing.sm),
          Wrap(
            spacing: 8,
            children: ['male', 'female', 'non_binary'].map((g) {
              final isSelected = _gender == g;
              return ChoiceChip(
                label: Text(g.replaceAll('_', ' ').toUpperCase()),
                selected: isSelected,
                onSelected: (_) => setState(() => _gender = g),
                selectedColor: AppColors.lime.withValues(alpha: 0.2),
                labelStyle: AppTypography.caption.copyWith(
                  color: isSelected ? AppColors.lime : AppColors.textSecondary,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
                side: BorderSide(color: isSelected ? AppColors.lime : AppColors.surfaceCardBorder),
                backgroundColor: AppColors.surfaceCard,
              );
            }).toList(),
          ),

          const SizedBox(height: AppSpacing.md),
          _field('Age', _ageController, TextInputType.number),
          const SizedBox(height: AppSpacing.md),
          _field('Height (cm)', _heightController, const TextInputType.numberWithOptions(decimal: true)),
          const SizedBox(height: AppSpacing.md),
          _field('Weight (kg)', _weightController, const TextInputType.numberWithOptions(decimal: true)),
        ],
      ),
    );
  }

  Widget _field(String label, TextEditingController controller, TextInputType type) {
    return TextFormField(
      controller: controller,
      keyboardType: type,
      style: AppTypography.body,
      decoration: InputDecoration(labelText: label),
    );
  }
}
