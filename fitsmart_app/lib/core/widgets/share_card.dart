import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

/// Data model for a shareable achievement card.
class ShareCardData {
  final String title;
  final String subtitle;
  final String emoji;
  final String metricLabel;
  final String metricValue;
  final Color accentColor;

  const ShareCardData({
    required this.title,
    required this.subtitle,
    required this.emoji,
    this.metricLabel = '',
    this.metricValue = '',
    this.accentColor = const Color(0xFFBDFF3A),
  });

  // ── Convenience factories ────────────────────────────────────

  factory ShareCardData.streak(int days) => ShareCardData(
        emoji: '🔥',
        title: '$days-Day Streak',
        subtitle: 'Logging every day — consistency wins.',
        metricLabel: 'DAYS IN A ROW',
        metricValue: '$days',
        accentColor: const Color(0xFFFF6B6B),
      );

  factory ShareCardData.workoutCompleted({
    required String name,
    required int durationMin,
    required int sets,
  }) =>
      ShareCardData(
        emoji: '💪',
        title: 'Workout Complete',
        subtitle: name,
        metricLabel: 'SETS · MINUTES',
        metricValue: '$sets sets · ${durationMin}m',
      );

  factory ShareCardData.personalRecord({
    required String exercise,
    required double weightKg,
    required bool isMetric,
  }) =>
      ShareCardData(
        emoji: '🏆',
        title: 'New Personal Record',
        subtitle: exercise,
        metricLabel: isMetric ? 'KG' : 'LBS',
        metricValue: isMetric
            ? weightKg.toStringAsFixed(1)
            : (weightKg * 2.20462).toStringAsFixed(1),
        accentColor: const Color(0xFFFBBF24),
      );

  factory ShareCardData.levelUp(int level, String levelName) => ShareCardData(
        emoji: '⚡',
        title: 'Level Up!',
        subtitle: 'Reached $levelName',
        metricLabel: 'LEVEL',
        metricValue: '$level',
        accentColor: const Color(0xFFA78BFA),
      );
}

/// Off-screen widget rendered by [ScreenshotController] before sharing.
/// Keep it simple and fixed-size so the PNG is always 480 × 640.
class ShareCard extends StatelessWidget {
  final ShareCardData data;

  const ShareCard({super.key, required this.data});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 480,
      height: 640,
      child: Material(
        color: Colors.transparent,
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0A0A0C), Color(0xFF18181C)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: const EdgeInsets.all(AppSpacing.xl),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top accent bar
              Container(
                height: 4,
                width: 60,
                decoration: BoxDecoration(
                  color: data.accentColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),

              // Emoji
              Text(data.emoji, style: const TextStyle(fontSize: 64)),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                data.title,
                style: AppTypography.h1.copyWith(
                  color: Colors.white,
                  fontSize: 36,
                ),
              ),
              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              Text(
                data.subtitle,
                style: AppTypography.body.copyWith(
                  color: Colors.white.withAlpha(180),
                ),
              ),

              const Spacer(),

              // Metric highlight
              if (data.metricValue.isNotEmpty) ...[
                Text(
                  data.metricLabel,
                  style: AppTypography.overline.copyWith(
                    color: data.accentColor,
                    letterSpacing: 2,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  data.metricValue,
                  style: AppTypography.display.copyWith(
                    color: Colors.white,
                    fontSize: 56,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: AppSpacing.xl),
              ],

              // Branding footer
              Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color: data.accentColor,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const Center(
                      child: Text('F',
                          style: TextStyle(
                              color: Colors.black,
                              fontWeight: FontWeight.w900,
                              fontSize: 16)),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('FitSmart AI',
                          style: AppTypography.bodyMedium
                              .copyWith(color: Colors.white, fontWeight: FontWeight.w700)),
                      Text('fitsmart.app',
                          style: AppTypography.caption
                              .copyWith(color: Colors.white.withAlpha(120))),
                    ],
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
