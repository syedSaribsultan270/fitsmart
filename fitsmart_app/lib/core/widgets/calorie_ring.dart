import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';

class CalorieRing extends StatelessWidget {
  final double consumed;
  final double target;
  final double size;
  final double strokeWidth;

  const CalorieRing({
    super.key,
    required this.consumed,
    required this.target,
    this.size = 180,
    this.strokeWidth = 14,
  });

  @override
  Widget build(BuildContext context) {
    final progress = (target > 0 ? consumed / target : 0).clamp(0.0, 1.2);
    final isOver = consumed > target;
    final ringColor = isOver
        ? AppColors.error
        : progress > 0.85
            ? AppColors.warning
            : AppColors.lime;

    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: 1.0,
              color: AppColors.surfaceCardBorder,
              strokeWidth: strokeWidth,
            ),
          ),
          // Progress ring
          CustomPaint(
            size: Size(size, size),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0).toDouble(),
              color: ringColor,
              strokeWidth: strokeWidth,
              hasShadow: true,
              shadowColor: ringColor,
            ),
          )
              .animate()
              .custom(
                duration: 1200.ms,
                curve: Curves.easeOutCubic,
                builder: (context, value, child) {
                  return CustomPaint(
                    size: Size(size, size),
                    painter: _RingPainter(
                      progress: (progress * value).clamp(0.0, 1.0),
                      color: ringColor,
                      strokeWidth: strokeWidth,
                      hasShadow: true,
                      shadowColor: ringColor,
                    ),
                  );
                },
              ),
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                consumed.toStringAsFixed(0),
                style: AppTypography.h1.copyWith(
                  color: AppColors.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'of ${target.toStringAsFixed(0)}',
                style: AppTypography.caption.copyWith(
                  color: AppColors.textSecondary,
                ),
              ),
              Text(
                'kcal',
                style: AppTypography.overline.copyWith(
                  color: AppColors.textTertiary,
                ),
              ),
              if (isOver)
                Text(
                  '+${(consumed - target).toStringAsFixed(0)} over',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  final double progress;
  final Color color;
  final double strokeWidth;
  final bool hasShadow;
  final Color? shadowColor;

  _RingPainter({
    required this.progress,
    required this.color,
    required this.strokeWidth,
    this.hasShadow = false,
    this.shadowColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;
    const startAngle = -math.pi / 2;
    final sweepAngle = 2 * math.pi * progress;

    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    if (hasShadow && shadowColor != null) {
      final shadowPaint = Paint()
        ..color = shadowColor!.withValues(alpha: 0.3)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth + 4
        ..strokeCap = StrokeCap.round
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);
      canvas.drawArc(
        Rect.fromCircle(center: center, radius: radius),
        startAngle,
        sweepAngle,
        false,
        shadowPaint,
      );
    }

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress || old.color != color;
}
