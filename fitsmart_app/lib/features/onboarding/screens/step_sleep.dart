import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../providers/onboarding_provider.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
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
    if (h >= 8) return 'Optimal for recovery 💪';
    if (h >= 7) return 'Good for most adults ✅';
    if (h >= 6) return 'Slightly below ideal 😴';
    return 'Not enough — gains suffer! 😬';
  }

  Color get _qualityColor {
    final h = _sleepMinutes / 60;
    if (h >= 8) return AppColors.success;
    if (h >= 7) return AppColors.lime;
    if (h >= 6) return AppColors.warning;
    return AppColors.error;
  }

  String _formatTime(int hour, int min) {
    final h = hour % 12 == 0 ? 12 : hour % 12;
    final m = min.toString().padLeft(2, '0');
    final ampm = hour < 12 ? 'AM' : 'PM';
    return '$h:$m $ampm';
  }

  @override
  Widget build(BuildContext context) {
    return OnboardingStepBase(
      emoji: '🌙',
      title: 'Your Rest\nSchedule',
      subtitle: 'Sleep = gains. Seriously. Let\'s set your targets.',
      content: Column(
        children: [
          // Bedtime
          _TimeSelector(
            label: 'BEDTIME',
            emoji: '🌙',
            time: _formatTime(_bedHour, _bedMin),
            hour: _bedHour,
            minute: _bedMin,
            color: AppColors.macroFiber,
            onChanged: (h, m) => setState(() {
              _bedHour = h;
              _bedMin = m;
            }),
          ),
          const SizedBox(height: AppSpacing.md),

          // Wake time
          _TimeSelector(
            label: 'WAKE TIME',
            emoji: '☀️',
            time: _formatTime(_wakeHour, _wakeMin),
            hour: _wakeHour,
            minute: _wakeMin,
            color: AppColors.warning,
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
              color: _qualityColor.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppRadius.lg),
              border: Border.all(
                color: _qualityColor.withValues(alpha: 0.3),
              ),
            ),
            child: Row(
              children: [
                Text(
                  _sleepDuration,
                  style: AppTypography.h2.copyWith(
                    color: _qualityColor,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Text(
                    _sleepQuality,
                    style: AppTypography.bodyMedium.copyWith(
                      color: _qualityColor,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: AppSpacing.md),
          Text(
            'Sleep affects cortisol, muscle recovery, hunger hormones, and fat loss. This matters!',
            style: AppTypography.caption.copyWith(color: AppColors.textTertiary),
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
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            timePickerTheme: TimePickerThemeData(
              backgroundColor: AppColors.bgSecondary,
              hourMinuteColor: AppColors.surfaceCard,
              dialBackgroundColor: AppColors.bgTertiary,
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
          color: AppColors.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(color: AppColors.surfaceCardBorder),
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
                      color: AppColors.textTertiary,
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
            Icon(Icons.edit_rounded, color: AppColors.textTertiary, size: 18),
          ],
        ),
      ),
    );
  }
}
