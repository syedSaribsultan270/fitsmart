import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/animated_number.dart';
import '../../../services/analytics_service.dart';
import '../providers/dashboard_provider.dart';

/// Water tracking card for the dashboard.
/// Shows today's intake vs. goal with a glasses visual + quick-add buttons.
class WaterTrackingCard extends ConsumerWidget {
  const WaterTrackingCard({super.key});

  static const _goalMl = 2500;
  static const _glassCount = 8;
  static const _mlPerGlass = _goalMl ~/ _glassCount; // 312 ml each
  static const _quickAmounts = [200, 350, 500];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final waterAsync = ref.watch(todaysWaterProvider);
    final isLogging = ref.watch(logWaterProvider).isLoading;

    final currentMl = waterAsync.valueOrNull ?? 0;
    final remaining = (_goalMl - currentMl).clamp(0, _goalMl);
    final isGoalMet = currentMl >= _goalMl;
    // How many full glasses are filled (partial glass shown differently)
    final fullGlasses = (currentMl / _mlPerGlass).floor().clamp(0, _glassCount);
    final partialFraction = ((currentMl % _mlPerGlass) / _mlPerGlass).clamp(0.0, 1.0);

    return Container(
      padding: const EdgeInsets.all(AppSpacing.cardPadding),
      decoration: BoxDecoration(
        color: context.colors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(
          color: isGoalMet
              ? context.colors.cyan.withValues(alpha: 0.4)
              : context.colors.surfaceCardBorder,
        ),
        boxShadow: isGoalMet
            ? [
                BoxShadow(
                  color: AppColors.cyan.withValues(alpha: 0.08),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.colors.cyan.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                child: const Center(child: Text('💧', style: TextStyle(fontSize: 16))),
              ),
              const SizedBox(width: AppSpacing.sm),
              Text(
                'Water',
                style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.w700),
              ),
              const Spacer(),
              // Pct badge
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: isGoalMet
                      ? context.colors.cyan.withValues(alpha: 0.15)
                      : context.colors.bgTertiary,
                  borderRadius: BorderRadius.circular(AppRadius.full),
                ),
                child: Text(
                  isGoalMet
                      ? '✓ Goal met!'
                      : '${((currentMl / _goalMl) * 100).round()}%',
                  style: AppTypography.overline.copyWith(
                    color: isGoalMet
                        ? context.colors.cyan
                        : context.colors.textTertiary,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ).animate(key: ValueKey(isGoalMet))
               .scale(duration: 400.ms, curve: Curves.elasticOut),
            ],
          ),

          const SizedBox(height: AppSpacing.lg),

          // Hero amount + glasses row
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Hero ml number — counts up smoothly on each log
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  AnimatedNumber(
                    value: currentMl,
                    duration: const Duration(milliseconds: 600),
                    builder: (v) => Text(
                      _formatMl(v.toInt()),
                      style: AppTypography.display.copyWith(
                        fontSize: 36,
                        fontWeight: FontWeight.w800,
                        color: isGoalMet
                            ? context.colors.cyan
                            : context.colors.textPrimary,
                        height: 1,
                      ),
                    ),
                  ),
                  Text(
                    'of ${_formatMl(_goalMl)}',
                    style: AppTypography.caption.copyWith(
                      color: context.colors.textTertiary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: AppSpacing.lg),
              // Glasses visual — grows from the right
              Expanded(
                child: Wrap(
                  spacing: 4,
                  runSpacing: 4,
                  alignment: WrapAlignment.end,
                  children: List.generate(_glassCount, (i) {
                    final isFull = i < fullGlasses;
                    final isPartial = i == fullGlasses && partialFraction > 0;
                    return _GlassIcon(
                      isFull: isFull,
                      isPartial: isPartial,
                      partialFraction: partialFraction,
                    ).animate(delay: (i * 40).ms).fadeIn(duration: 200.ms);
                  }),
                ),
              ),
            ],
          ),

          const SizedBox(height: AppSpacing.sm),

          // Remaining label
          if (!isGoalMet)
            Text(
              '${_formatMl(remaining)} left to reach your goal',
              style: AppTypography.caption.copyWith(color: context.colors.textTertiary),
            ),

          const SizedBox(height: AppSpacing.md),

          // Quick-add buttons — every slot is Expanded so nothing overflows
          // even at narrow widths or large text-scale.
          waterAsync.when(
            loading: () => const SizedBox(height: 40),
            error: (_, __) => const SizedBox.shrink(),
            data: (_) => Row(
              children: [
                for (var i = 0; i < _quickAmounts.length; i++) ...[
                  Expanded(
                    child: _WaterButton(
                      label: '+${_quickAmounts[i]}ml',
                      onTap: isLogging ? null : () => _logWater(ref, _quickAmounts[i]),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.xs),
                ],
                Expanded(
                  child: _WaterButton(
                    label: 'Custom',
                    onTap: isLogging ? null : () => _showCustomDialog(context, ref),
                    isOutlined: true,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _logWater(WidgetRef ref, int ml) {
    HapticFeedback.lightImpact();
    ref.read(logWaterProvider.notifier).log(ml);
    AnalyticsService.instance.tap('water_quick_add_${ml}ml', screen: 'dashboard');
  }

  void _showCustomDialog(BuildContext context, WidgetRef ref) {
    AnalyticsService.instance.dialogOpened('water_custom', screen: 'dashboard');
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: context.colors.bgSecondary,
        title: Text('Add Water', style: AppTypography.h3),
        content: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: TextInputType.number,
          decoration: InputDecoration(
            hintText: 'Amount in ml',
            hintStyle: AppTypography.body.copyWith(color: context.colors.textTertiary),
            suffixText: 'ml',
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              AnalyticsService.instance.dialogAction('water_custom', 'cancelled', screen: 'dashboard');
              Navigator.pop(ctx);
            },
            child: Text('Cancel', style: AppTypography.bodyMedium.copyWith(color: context.colors.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              final ml = int.tryParse(controller.text);
              if (ml != null && ml > 0) {
                Navigator.pop(ctx);
                AnalyticsService.instance.dialogAction('water_custom', 'confirmed', screen: 'dashboard');
                ref.read(logWaterProvider.notifier).log(ml);
              }
            },
            child: Text('Add', style: AppTypography.bodyMedium.copyWith(color: context.colors.cyan)),
          ),
        ],
      ),
    );
  }

  String _formatMl(int ml) => ml >= 1000 ? '${(ml / 1000).toStringAsFixed(1)}L' : '${ml}ml';
}

/// A single glass icon — filled (full cyan), partial (half-fill), or empty.
class _GlassIcon extends StatelessWidget {
  final bool isFull;
  final bool isPartial;
  final double partialFraction;

  const _GlassIcon({
    required this.isFull,
    required this.isPartial,
    required this.partialFraction,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: 22,
      height: 26,
      child: CustomPaint(
        painter: _GlassPainter(
          fillColor: c.cyan,
          emptyColor: c.surfaceCardBorder,
          fillFraction: isFull ? 1.0 : isPartial ? partialFraction : 0.0,
        ),
      ),
    );
  }
}

class _GlassPainter extends CustomPainter {
  final Color fillColor;
  final Color emptyColor;
  final double fillFraction;

  const _GlassPainter({
    required this.fillColor,
    required this.emptyColor,
    required this.fillFraction,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width;
    final h = size.height;
    final r = 2.0; // corner radius

    // Trapezoid glass shape path (slight taper at bottom)
    final glassPaint = Paint()..color = emptyColor;
    final glassPath = Path()
      ..moveTo(r, 0)
      ..lineTo(w - r, 0)
      ..arcToPoint(Offset(w, r), radius: const Radius.circular(2))
      ..lineTo(w - r * 0.5, h - r)
      ..arcToPoint(Offset(w - r - r * 0.5, h), radius: const Radius.circular(2))
      ..lineTo(r + r * 0.5, h)
      ..arcToPoint(Offset(r * 0.5, h - r), radius: const Radius.circular(2))
      ..lineTo(0, r)
      ..arcToPoint(Offset(r, 0), radius: const Radius.circular(2))
      ..close();

    // Draw empty glass
    canvas.drawPath(glassPath, glassPaint);

    if (fillFraction > 0) {
      // Clip fill to glass shape then draw filled rect from bottom
      canvas.save();
      canvas.clipPath(glassPath);
      final fillTop = h * (1 - fillFraction);
      canvas.drawRect(
        Rect.fromLTRB(0, fillTop, w, h),
        Paint()..color = fillColor.withValues(alpha: 0.85),
      );
      canvas.restore();
    }
  }

  @override
  bool shouldRepaint(_GlassPainter old) =>
      old.fillFraction != fillFraction || old.fillColor != fillColor;
}

class _WaterButton extends StatelessWidget {
  final String label;
  final VoidCallback? onTap;
  final bool isOutlined;

  const _WaterButton({required this.label, this.onTap, this.isOutlined = false});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 36,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: isOutlined
              ? Colors.transparent
              : context.colors.cyan.withValues(alpha: onTap == null ? 0.04 : 0.12),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isOutlined
                ? context.colors.surfaceCardBorder
                : context.colors.cyan.withValues(alpha: onTap == null ? 0.1 : 0.3),
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isOutlined
                ? context.colors.textSecondary
                : context.colors.cyan.withValues(alpha: onTap == null ? 0.4 : 1.0),
            fontWeight: FontWeight.w700,
          ),
        ),
      ),
    );
  }
}
