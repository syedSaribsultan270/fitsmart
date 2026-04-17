import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:screenshot/screenshot.dart';
import 'package:share_plus/share_plus.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/share_card.dart';
import '../../../services/analytics_service.dart';

/// Shows a bottom sheet previewing the share card and a "Share" CTA.
///
/// Usage:
/// ```dart
/// ShareAchievementSheet.show(context, data: ShareCardData.streak(7));
/// ```
class ShareAchievementSheet extends StatefulWidget {
  final ShareCardData data;
  const ShareAchievementSheet({super.key, required this.data});

  static Future<void> show(BuildContext context, {required ShareCardData data}) {
    AnalyticsService.instance.track('share_card_shown',
        props: {'trigger': data.title});
    return showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (_) => ShareAchievementSheet(data: data),
    );
  }

  @override
  State<ShareAchievementSheet> createState() => _ShareAchievementSheetState();
}

class _ShareAchievementSheetState extends State<ShareAchievementSheet> {
  final _screenshotCtrl = ScreenshotController();
  bool _sharing = false;
  bool _closed = false; // guard against double-pop

  Future<void> _share() async {
    if (_sharing || _closed) return;
    setState(() => _sharing = true);
    try {
      // Capture the off-screen share card at 2× for crisp screens
      final Uint8List bytes = await _screenshotCtrl.captureFromLongWidget(
        ShareCard(data: widget.data),
        pixelRatio: 2,
        delay: const Duration(milliseconds: 100),
      );
      final file = XFile.fromData(bytes, mimeType: 'image/png', name: 'fitsmart_achievement.png');
      final result = await Share.shareXFiles(
        [file],
        text: '${widget.data.emoji} ${widget.data.title} — tracked with FitSmart AI',
      );
      if (mounted && !_closed) {
        _closed = true;
        AnalyticsService.instance.track('share_card_shared', props: {
          'trigger': widget.data.title,
          'status': result.status.name,
        });
        Navigator.of(context).pop();
      }
    } catch (e) {
      if (mounted) setState(() => _sharing = false);
    }
  }

  void _dismiss() {
    if (_closed) return;
    _closed = true;
    AnalyticsService.instance.track('share_card_dismissed',
        props: {'trigger': widget.data.title});
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Container(
      margin: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      decoration: BoxDecoration(
        color: colors.bgSecondary,
        borderRadius: BorderRadius.circular(AppRadius.xl),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: colors.surfaceCardBorder,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),

          // Preview — scaled down to fit the sheet
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppRadius.lg),
              child: Transform.scale(
                scale: 0.6,
                child: SizedBox(
                  height: 384, // 640 × 0.6
                  child: ShareCard(data: widget.data),
                ),
              ),
            ),
          ),

          const SizedBox(height: AppSpacing.lg),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.pagePadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ElevatedButton.icon(
                  onPressed: _sharing ? null : _share,
                  icon: _sharing
                      ? const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                        )
                      : const Icon(Icons.share_rounded, size: 18),
                  label: Text(_sharing ? 'Sharing…' : 'Share Achievement'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: widget.data.accentColor,
                    foregroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.md)),
                    textStyle: AppTypography.bodyMedium
                        .copyWith(fontWeight: FontWeight.w700),
                  ),
                ),
                const SizedBox(height: AppSpacing.sm),
                TextButton(
                  onPressed: _dismiss,
                  child: Text('Not now',
                      style: AppTypography.bodyMedium
                          .copyWith(color: colors.textTertiary)),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }
}
