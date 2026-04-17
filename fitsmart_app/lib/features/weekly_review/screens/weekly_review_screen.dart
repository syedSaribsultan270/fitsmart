import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../../core/widgets/liquid_glass.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../data/database/database_provider.dart';
import '../../../providers/settings_provider.dart';
import '../../../services/analytics_service.dart';
import '../../../services/weekly_review_service.dart';
import '../widgets/weekly_review_card.dart';

/// "Your week in review" — Monday morning ritual screen.
/// Shows aggregated stats from last week, a single AI-style highlight,
/// commitment picker for next week, and a shareable export.
class WeeklyReviewScreen extends ConsumerStatefulWidget {
  const WeeklyReviewScreen({super.key});

  @override
  ConsumerState<WeeklyReviewScreen> createState() => _WeeklyReviewScreenState();
}

class _WeeklyReviewScreenState extends ConsumerState<WeeklyReviewScreen> {
  final _shotCtrl = ScreenshotController();
  WeeklyReviewData? _data;
  /// The commitment the user pledged at the END of the week before the one
  /// being reviewed — i.e. the pledge that was supposed to govern the
  /// reviewed week. Null if none was set.
  String? _previousCommitment;
  bool _loading = true;
  bool _sharing = false;
  String? _selectedCommitment;

  @override
  void initState() {
    super.initState();
    _load();
    AnalyticsService.instance.track('weekly_review_opened');
  }

  Future<void> _load() async {
    final db = ref.read(databaseProvider);
    final data = await WeeklyReviewService.instance.buildLastWeek(db);
    // The commitment was saved with key = the start of the week it was
    // meant to govern. The reviewed week's start is `data.weekStart`.
    final prev = await WeeklyReviewService.instance
        .getCommitmentFor(data.weekStart);
    if (mounted) {
      setState(() {
        _data = data;
        _previousCommitment = prev;
        _loading = false;
      });
    }
  }

  Future<void> _share() async {
    final data = _data;
    if (data == null || _sharing) return;
    setState(() => _sharing = true);
    try {
      final settings = ref.read(settingsProvider);
      final firstName = settings.displayName.split(' ').first;
      final card = MediaQuery(
        data: MediaQuery.of(context),
        child: WeeklyReviewCard(
          data: data,
          firstName: firstName,
          isMetric: settings.isMetric,
          brandFooter: true,
        ),
      );
      final Uint8List bytes = await _shotCtrl.captureFromLongWidget(
        Material(color: AppColors.bgPrimary, child: Padding(
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: card,
        )),
        pixelRatio: 2,
        delay: const Duration(milliseconds: 100),
      );
      final file = XFile.fromData(
        bytes,
        mimeType: 'image/png',
        name: 'fitsmart_weekly_review.png',
      );
      final result = await Share.shareXFiles(
        [file],
        text: 'My week with FitSmart AI 💪',
      );
      AnalyticsService.instance.track('weekly_review_shared', props: {
        'status': result.status.name,
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Share failed: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sharing = false);
    }
  }

  Future<void> _commit() async {
    final data = _data;
    final pick = _selectedCommitment;
    if (data == null || pick == null) return;
    final nextWeekStart = data.weekEnd; // Monday after the reviewed week
    await WeeklyReviewService.instance.saveCommitment(
      forWeekStart: nextWeekStart,
      commitment: pick,
    );
    AnalyticsService.instance.track('weekly_commitment_set', props: {
      'commitment': pick,
    });
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Locked in. See you next Monday.'),
          backgroundColor: AppColors.lime,
        ),
      );
      context.pop();
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final firstName = settings.displayName.split(' ').first;

    return Scaffold(
      backgroundColor: AppColors.bgPrimary,
      appBar: LiquidAppBar(
        elevation: 0,
        title: Text(
          'Week in Review',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        actions: [
          if (_data != null)
            IconButton(
              icon: _sharing
                  ? const SizedBox(
                      width: 20, height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2, color: AppColors.lime,
                      ),
                    )
                  : const Icon(Icons.ios_share, color: AppColors.lime),
              onPressed: _sharing ? null : _share,
            ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppColors.lime),
            )
          : _data == null
              ? const Center(child: Text('No data yet — log a few things first.'))
              : SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.pagePadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Last week's pledge — closes the loop on the
                      // commitment ritual. Hidden when there was none.
                      if (_previousCommitment != null) ...[
                        _LastWeekPledge(commitment: _previousCommitment!),
                        const SizedBox(height: AppSpacing.lg),
                      ],
                      WeeklyReviewCard(
                        data: _data!,
                        firstName: firstName,
                        isMetric: settings.isMetric,
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      _CommitmentSection(
                        suggestions: WeeklyReviewService.instance
                            .suggestedCommitments(_data!),
                        selected: _selectedCommitment,
                        onSelect: (c) => setState(() => _selectedCommitment = c),
                      ),
                      const SizedBox(height: AppSpacing.xl),
                      SizedBox(
                        height: 52,
                        child: ElevatedButton(
                          onPressed: _selectedCommitment == null ? null : _commit,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.lime,
                            foregroundColor: AppColors.textInverse,
                            disabledBackgroundColor:
                                AppColors.surfaceCard,
                            disabledForegroundColor:
                                AppColors.textTertiary,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.md),
                            ),
                          ),
                          child: Text(
                            _selectedCommitment == null
                                ? 'Pick one to commit'
                                : 'Lock in for next week',
                            style: AppTypography.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: AppSpacing.lg),
                    ],
                  ),
                ),
    );
  }
}

/// Last week's pledge — shown above the review card to close the loop on
/// the previous Monday's commitment ritual. Quiet card, accent-rim only.
class _LastWeekPledge extends StatelessWidget {
  final String commitment;
  const _LastWeekPledge({required this.commitment});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: AppColors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: AppColors.lime.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 36, height: 36,
            decoration: BoxDecoration(
              color: AppColors.lime.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: const Icon(
              Icons.flag_rounded, color: AppColors.lime, size: 18,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'LAST WEEK YOU PLEDGED',
                  style: AppTypography.overline.copyWith(
                    color: AppColors.lime,
                    fontSize: 9,
                    letterSpacing: 1.4,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  commitment,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textPrimary,
                    fontWeight: FontWeight.w700,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Did you keep it? The numbers below tell the story.',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CommitmentSection extends StatelessWidget {
  final List<String> suggestions;
  final String? selected;
  final ValueChanged<String> onSelect;
  const _CommitmentSection({
    required this.suggestions,
    required this.selected,
    required this.onSelect,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'COMMIT TO ONE THING',
          style: AppTypography.caption.copyWith(
            color: AppColors.lime,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          'Next week, you will…',
          style: AppTypography.h3.copyWith(color: AppColors.textPrimary),
        ),
        const SizedBox(height: AppSpacing.md),
        ...suggestions.map((s) => Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: _CommitmentTile(
                text: s,
                selected: selected == s,
                onTap: () => onSelect(s),
              ),
            )),
      ],
    );
  }
}

class _CommitmentTile extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;
  const _CommitmentTile({
    required this.text, required this.selected, required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: selected
              ? AppColors.lime.withValues(alpha: 0.1)
              : AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? AppColors.lime : AppColors.surfaceCardBorder,
            width: selected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              selected ? Icons.check_circle : Icons.circle_outlined,
              color: selected ? AppColors.lime : AppColors.textTertiary,
              size: 22,
            ),
            const SizedBox(width: AppSpacing.sm),
            Expanded(
              child: Text(
                text,
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textPrimary,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
