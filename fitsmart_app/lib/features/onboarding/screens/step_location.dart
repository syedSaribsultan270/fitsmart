import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
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
    ('\uD83C\uDDFA\uD83C\uDDF8', 'United States'), ('\uD83C\uDDEC\uD83C\uDDE7', 'United Kingdom'), ('\uD83C\uDDEE\uD83C\uDDF3', 'India'),
    ('\uD83C\uDDE6\uD83C\uDDFA', 'Australia'), ('\uD83C\uDDE8\uD83C\uDDE6', 'Canada'), ('\uD83C\uDDE9\uD83C\uDDEA', 'Germany'),
    ('\uD83C\uDDEB\uD83C\uDDF7', 'France'), ('\uD83C\uDDE7\uD83C\uDDF7', 'Brazil'), ('\uD83C\uDDEF\uD83C\uDDF5', 'Japan'), ('\uD83C\uDDF2\uD83C\uDDFD', 'Mexico'),
    ('\uD83C\uDDFF\uD83C\uDDE6', 'South Africa'), ('\uD83C\uDDEA\uD83C\uDDF8', 'Spain'), ('\uD83C\uDDEE\uD83C\uDDF9', 'Italy'), ('\uD83C\uDDF8\uD83C\uDDEC', 'Singapore'),
    ('\uD83C\uDDF3\uD83C\uDDEC', 'Nigeria'), ('\uD83C\uDDF5\uD83C\uDDF0', 'Pakistan'), ('\uD83C\uDDF8\uD83C\uDDE6', 'Saudi Arabia'), ('\uD83C\uDDE6\uD83C\uDDEA', 'UAE'),
    ('\uD83C\uDDF3\uD83C\uDDFF', 'New Zealand'), ('\uD83C\uDDF0\uD83C\uDDF7', 'South Korea'), ('\uD83C\uDDF3\uD83C\uDDF1', 'Netherlands'),
    ('\uD83C\uDDF8\uD83C\uDDEA', 'Sweden'), ('\uD83C\uDDF3\uD83C\uDDF4', 'Norway'), ('\uD83C\uDDE8\uD83C\uDDED', 'Switzerland'), ('\uD83C\uDDF5\uD83C\uDDED', 'Philippines'),
    ('\uD83C\uDDEE\uD83C\uDDE9', 'Indonesia'), ('\uD83C\uDDF2\uD83C\uDDFE', 'Malaysia'), ('\uD83C\uDDF9\uD83C\uDDED', 'Thailand'), ('\uD83C\uDDF9\uD83C\uDDF7', 'Turkey'),
    ('\uD83C\uDF0D', 'Other'),
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
      emoji: '\uD83C\uDF0D',
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
              prefixIcon: Icon(Icons.search, color: context.colors.textTertiary, size: 20),
              hintStyle: AppTypography.body.copyWith(color: context.colors.textTertiary),
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
                      color: isSelected ? context.colors.lime : context.colors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                    ),
                  ),
                  trailing: isSelected
                      ? Icon(Icons.check_circle, color: context.colors.lime, size: 20)
                      : null,
                  tileColor: isSelected ? context.colors.limeGlow : null,
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
            decoration: InputDecoration(
              hintText: 'City (optional)',
              prefixIcon: Icon(Icons.location_city, color: context.colors.textTertiary, size: 20),
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
