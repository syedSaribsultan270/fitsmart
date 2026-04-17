import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_typography.dart';
import '../theme/theme_extensions.dart';

class CalorieRing extends StatefulWidget {
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
  State<CalorieRing> createState() => _CalorieRingState();
}

class _CalorieRingState extends State<CalorieRing> {
  bool _goalCelebrated = false;

  @override
  void didUpdateWidget(CalorieRing old) {
    super.didUpdateWidget(old);
    final wasUnder = old.target > 0 && old.consumed / old.target < 1.0;
    final isNowOver = widget.target > 0 && widget.consumed / widget.target >= 1.0;
    if (wasUnder && isNowOver && !_goalCelebrated) {
      _goalCelebrated = true;
      HapticFeedback.mediumImpact();
    }
    // Reset flag when calories drop back below goal (e.g. meal deleted)
    if (!isNowOver) _goalCelebrated = false;
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    final progress = (widget.target > 0 ? widget.consumed / widget.target : 0)
        .clamp(0.0, 1.2);
    final isOver = widget.consumed > widget.target;
    final isGoalMet = progress >= 1.0;
    final ringColor = isOver
        ? c.error
        : progress > 0.85
            ? c.warning
            : c.lime;

    Widget ring = SizedBox(
      width: widget.size,
      height: widget.size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          // Background ring
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _RingPainter(
              progress: 1.0,
              color: c.surfaceCardBorder,
              strokeWidth: widget.strokeWidth,
            ),
          ),
          // Progress ring — animates from 0 on first build
          CustomPaint(
            size: Size(widget.size, widget.size),
            painter: _RingPainter(
              progress: progress.clamp(0.0, 1.0).toDouble(),
              color: ringColor,
              strokeWidth: widget.strokeWidth,
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
                    size: Size(widget.size, widget.size),
                    painter: _RingPainter(
                      progress: (progress * value).clamp(0.0, 1.0),
                      color: ringColor,
                      strokeWidth: widget.strokeWidth,
                      hasShadow: true,
                      shadowColor: ringColor,
                    ),
                  );
                },
              ),
          // Goal-met glow ring (appears only when ≥ 100%)
          if (isGoalMet)
            SizedBox(
              width: widget.size + 16,
              height: widget.size + 16,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.lime.withValues(alpha: 0.2),
                      blurRadius: 24,
                      spreadRadius: 8,
                    ),
                  ],
                ),
              ),
            )
                .animate(onPlay: (c) => c.repeat(reverse: true))
                .scale(
                  begin: const Offset(0.95, 0.95),
                  end: const Offset(1.05, 1.05),
                  duration: 900.ms,
                  curve: Curves.easeInOut,
                ),
          // Center text
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.consumed.toStringAsFixed(0),
                style: AppTypography.h1.copyWith(
                  color: c.textPrimary,
                  fontSize: 36,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                'of ${widget.target.toStringAsFixed(0)}',
                style: AppTypography.caption.copyWith(
                  color: c.textSecondary,
                ),
              ),
              Text(
                'kcal',
                style: AppTypography.overline.copyWith(
                  color: c.textTertiary,
                ),
              ),
              if (isOver)
                Text(
                  '+${(widget.consumed - widget.target).toStringAsFixed(0)} over',
                  style: AppTypography.caption.copyWith(
                    color: c.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              if (isGoalMet && !isOver)
                Text(
                  '✓ Goal reached',
                  style: AppTypography.caption.copyWith(
                    color: AppColors.lime,
                    fontWeight: FontWeight.w600,
                  ),
                ),
            ],
          ),
        ],
      ),
    );

    // When goal is met, gently pulse the whole ring
    if (isGoalMet) {
      ring = ring
          .animate(onPlay: (c) => c.repeat(reverse: true))
          .scale(
            begin: const Offset(1.0, 1.0),
            end: const Offset(1.015, 1.015),
            duration: 1000.ms,
            curve: Curves.easeInOut,
          );
    }

    return ring;
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
