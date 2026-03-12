import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/theme/app_colors_extension.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/app_button.dart';
import 'onboarding_flow.dart';

class StepSleep extends ConsumerStatefulWidget {
  final VoidCallback onNext;
  const StepSleep({super.key, required this.onNext});

  @override
  ConsumerState<StepSleep> createState() => _StepSleepState();
}

class _StepSleepState extends ConsumerState<StepSleep> {
  int _bedHour = 22;
  int _bedMin = 30;
  int _wakeHour = 6;
  int _wakeMin = 30;

  int get _sleepMinutes {
    final bedTotal = _bedHour * 60 + _bedMin;
    var wakeTotal = _wakeHour * 60 + _wakeMin;
    if (wakeTotal <= bedTotal) wakeTotal += 24 * 60;
    return wakeTotal - bedTotal;
  }

  String get _sleepDuration {
    final h = _sleepMinutes ~/ 60;
    final m = _sleepMinutes % 60;
    return m > 0 ? '${h}h ${m}m' : '${h}h';
  }

  String get _sleepQuality {
    final h = _sleepMinutes / 60;
    if (h >= 8) return 'Optimal for recovery \uD83D\uDCAA';
    if (h >= 7) return 'Good for most adults \u2705';
    if (h >= 6) return 'Slightly below ideal \uD83D\uDE34';
    return 'Not enough \u2014 gains suffer! \uD83D\uDE2C';
  }

  Color _qualityColor(BuildContext context) {
    final h = _sleepMinutes / 60;
    if (h >= 8) return context.colors.success;
    if (h >= 7) return context.colors.lime;
    if (h >= 6) return context.colors.warning;
    return context.colors.error;
  }

  String _formatTime(int hour, int min) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = min.toString().padLeft(2, '0');
    final ampm = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    final qColor = _qualityColor(context);

    return OnboardingStepBase(
      emoji: '\uD83C\uDF19',
      title: 'Your Rest\nSchedule',
      subtitle: 'Sleep = gains. Seriously. Let\'s set your targets.',
      content: Column(
        children: [
          // Bedtime
          _TimeSelector(
            label: 'BEDTIME',
            emoji: '\uD83C\uDF19',
            time: _formatTime(_bedHour, _bedMin),
            hour: _bedHour,
            minute: _bedMin,
            color: AppColorsExtension.macroFiber,
            onChanged: (h, m) => setState(() {
              _bedHour = h;
              _bedMin = m;
            }),
          ),
          const SizedBox(height: AppSpacing.md),

          // Wake time
          _TimeSelector(
            label: 'WAKE TIME',
            emoji: '\u2600\uFE0F',
            time: _formatTime(_wakeHour, _wakeMin),
            hour: _wakeHour,
            minute: _wakeMin,
            color: context.colors.warning,
            onChanged: (h, m) => setState(() {
              _wakeHour = h;
              _wakeMin = m;
            }),
          ),
          const SizedBox(height: AppSpacing.sectionGap),

          // Sleep summary
          Container(
            padding: const EdgeInsets.all(AppSpacing.cardPadding),
            decoration: BoxDecoration(
              color: qColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: qColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Text(
                  _sleepDuration,
                  style: AppTypography.h2.copyWith(
                    color: qColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _sleepQuality,
                    style: AppTypography.bodyMedium.copyWith(
                      color: qColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          Text(
            'Sleep affects cortisol, muscle recovery, hunger hormones, and fat loss. This matters!',
            style: AppTypography.caption.copyWith(color: context.colors.textTertiary),
          ),
        ],
      ),
      cta: AppButton(
        label: 'Set My Sleep Schedule',
        onPressed: () {
          ref.read(onboardingProvider.notifier)
              .setSleepSchedule(_bedHour, _bedMin, _wakeHour, _wakeMin);
          widget.onNext();
        },
      ),
    );
  }
}

class _TimeSelector extends StatelessWidget {
  final String label;
  final String emoji;
  final String time;
  final int hour;
  final int minute;
  final Color color;
  final void Function(int hour, int minute) onChanged;

  const _TimeSelector({
    required this.label,
    required this.emoji,
    required this.time,
    required this.hour,
    required this.minute,
    required this.color,
    required this.onChanged,
  });

  Future<void> _pick(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: TimeOfDay(hour: hour, minute: minute),
      builder: (pickerCtx, child) {
        return Theme(
          data: Theme.of(pickerCtx).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: context.colors.bgSecondary,
              hourMinuteColor: context.colors.surfaceCard,
              dialBackgroundColor: context.colors.bgTertiary,
              dialHandColor: color,
            ),
          ),
          child: child!,
        );
      },
    );
    if (picked != null) {
      HapticFeedback.selectionClick();
      onChanged(picked.hour, picked.minute);
    }
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _pick(context),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.cardPadding),
        decoration: BoxDecoration(
          color: context.colors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: context.colors.surfaceCardBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Center(
                child: Text(emoji, style: const TextStyle(fontSize: 22)),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: AppTypography.overline.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                  Text(
                    time,
                    style: AppTypography.h3.copyWith(
                      color: color,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),
            Icon(Icons.edit_rounded, color: context.colors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}
