import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/widgets/app_button.dart';
import 'onboarding_flow.dart';

class StepLocation extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const StepLocation({super.key, required this.onNext});

  @override
  ConsumerState<StepLocation> createState() => _StepLocationState();
}

class _StepLocationState extends ConsumerState<StepLocation> {
  String? _selectedCountry;
  final _cityController = TextEditingController();
  final _searchController = TextEditingController();
  String _searchQuery = '';

  static const _countries = [
    ('🇺🇸', 'United States'), ('🇬🇧', 'United Kingdom'), ('🇮🇳', 'India'),
    ('🇦🇺', 'Australia'), ('🇨🇦', 'Canada'), ('🇩🇪', 'Germany'),
    ('🇫🇷', 'France'), ('🇧🇷', 'Brazil'), ('🇯🇵', 'Japan'), ('🇲🇽', 'Mexico'),
    ('🇿🇦', 'South Africa'), ('🇪🇸', 'Spain'), ('🇮🇹', 'Italy'), ('🇸🇬', 'Singapore'),
    ('🇳🇬', 'Nigeria'), ('🇵🇰', 'Pakistan'), ('🇸🇦', 'Saudi Arabia'), ('🇦🇪', 'UAE'),
    ('🇳🇿', 'New Zealand'), ('🇰🇷', 'South Korea'), ('🇳🇱', 'Netherlands'),
    ('🇸🇪', 'Sweden'), ('🇳🇴', 'Norway'), ('🇨🇭', 'Switzerland'), ('🇵🇭', 'Philippines'),
    ('🇮🇩', 'Indonesia'), ('🇲🇾', 'Malaysia'), ('🇹🇭', 'Thailand'), ('🇹🇷', 'Turkey'),
    ('🌍', 'Other'),
  ];

  List<(String, String)> get _filtered {
    if (_searchQuery.isEmpty) return _countries;
    return _countries
        .where((c) => c.$2.toLowerCase().contains(_searchQuery.toLowerCase()))
        .toList();
  }

  @override
  void dispose() {
    _cityController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepBase(
      emoji: '🌍',
      title: 'Where Are\nYou Based?',
      subtitle: 'Helps us suggest locally available foods & time-aware tips.',
      content: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Country search
          TextField(
            controller: _searchController,
            style: AppTypography.body,
            decoration: InputDecoration(
              hintText: 'Search country...',
              prefixIcon: const Icon(Icons.search, color: AppColors.textTertiary, size: 20),
              hintStyle: AppTypography.body.copyWith(color: AppColors.textTertiary),
            ),
            onChanged: (v) => setState(() => _searchQuery = v),
          ),
          const SizedBox(height: AppSpacing.md),

          // Country list
          Expanded(
            child: ListView.separated(
              itemCount: _filtered.length,
              separatorBuilder: (_, __) => const Divider(height: 1),
              itemBuilder: (_, i) {
                final (flag, name) = _filtered[i];
                final isSelected = _selectedCountry == name;
                return ListTile(
                  dense: true,
                  leading: Text(flag, style: const TextStyle(fontSize: 22)),
                  title: Text(
                    name,
                    style: AppTypography.bodyMedium.copyWith(
                      color: isSelected ? AppColors.lime : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? const Icon(Icons.check_circle, color: AppColors.lime, size: 20)
                      : null,
                  tileColor: isSelected ? AppColors.limeGlow : null,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  onTap: () => setState(() => _selectedCountry = name),
                );
              },
            ),
          ),
          const SizedBox(height: AppSpacing.md),

          // City input
          TextField(
            controller: _cityController,
            style: AppTypography.body,
            decoration: const InputDecoration(
              hintText: 'City (optional)',
              prefixIcon: Icon(Icons.location_city, color: AppColors.textTertiary, size: 20),
            ),
          ),
        ],
      ),
      cta: AppButton(
        label: 'Set My Location',
        onPressed: _selectedCountry == null
            ? null
            : () {
                ref.read(onboardingProvider.notifier)
                  ..setCountry(_selectedCountry!)
                  ..setCity(_cityController.text.trim());
                widget.onNext();
              },
      ),
    );
  }
}
