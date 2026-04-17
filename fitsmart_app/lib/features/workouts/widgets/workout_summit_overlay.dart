import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/animated_number.dart';

/// Fullscreen "summit" celebration shown immediately after a workout is saved.
///
/// Pure code — no Lottie, no Rive. CustomPainter draws:
///   • A stroked mountain silhouette
///   • A flag that plants on the summit with elastic bounce
///   • A burst of lime particles fanning outward
///
/// Sequence (≈2400ms total):
///   0     scrim fades in
///   200   mountain stroke draws on
///   800   flag pole rises + flag plants (elastic)
///   1100  particle burst + heavy haptic
///   1300  stats row flies up from bottom (count-up animation)
///   2400  auto-dismiss back to caller (or earlier on tap)
///
/// Intensity (subtle vs full burst) scales with [setsCompleted] — short
/// sessions get a calmer celebration.
class WorkoutSummitOverlay extends StatefulWidget {
  final String workoutName;
  final int setsCompleted;
  final int repsCompleted;
  final int durationMinutes;
  final int calories;
  final int xpEarned;

  const WorkoutSummitOverlay({
    super.key,
    required this.workoutName,
    required this.setsCompleted,
    required this.repsCompleted,
    required this.durationMinutes,
    required this.calories,
    required this.xpEarned,
  });

  /// Push the overlay as a transparent route. Resolves when dismissed
  /// (auto-timeout or tap-to-skip).
  static Future<void> show(
    BuildContext context, {
    required String workoutName,
    required int setsCompleted,
    required int repsCompleted,
    required int durationMinutes,
    required int calories,
    required int xpEarned,
  }) {
    return Navigator.of(context, rootNavigator: true).push(
      PageRouteBuilder(
        opaque: false,
        barrierDismissible: false,
        transitionDuration: const Duration(milliseconds: 250),
        reverseTransitionDuration: const Duration(milliseconds: 250),
        pageBuilder: (_, anim, __) => FadeTransition(
          opacity: anim,
          child: WorkoutSummitOverlay(
            workoutName: workoutName,
            setsCompleted: setsCompleted,
            repsCompleted: repsCompleted,
            durationMinutes: durationMinutes,
            calories: calories,
            xpEarned: xpEarned,
          ),
        ),
      ),
    );
  }

  @override
  State<WorkoutSummitOverlay> createState() => _WorkoutSummitOverlayState();
}

class _WorkoutSummitOverlayState extends State<WorkoutSummitOverlay>
    with TickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<double> _mountainStroke;
  late final Animation<double> _flagRise;
  late final Animation<double> _flagPlant;
  late final Animation<double> _particles;
  bool _dismissed = false;

  /// Intensity multiplier — small workouts get gentler celebration.
  double get _intensity {
    final score = widget.setsCompleted + (widget.calories ~/ 50);
    return (score / 20).clamp(0.4, 1.0);
  }

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2400),
    );

    _mountainStroke = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.08, 0.42, curve: Curves.easeInOutCubic),
    );
    _flagRise = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.34, 0.50, curve: Curves.easeOutCubic),
    );
    _flagPlant = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.46, 0.64, curve: Curves.elasticOut),
    );
    _particles = CurvedAnimation(
      parent: _ctrl,
      curve: const Interval(0.46, 0.95, curve: Curves.easeOutCubic),
    );

    // Heavy haptic at flag plant.
    Future.delayed(const Duration(milliseconds: 1080), () {
      if (mounted) HapticFeedback.heavyImpact();
    });

    _ctrl.forward();

    // Auto-dismiss
    Future.delayed(const Duration(milliseconds: 2400), () {
      if (mounted && !_dismissed) _dismiss();
    });
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  void _dismiss() {
    if (_dismissed || !mounted) return;
    _dismissed = true;
    Navigator.of(context, rootNavigator: true).maybePop();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: _dismiss,
      child: Stack(
        fit: StackFit.expand,
        children: [
          // Scrim
          ColoredBox(color: Colors.black.withValues(alpha: 0.92))
              .animate()
              .fadeIn(duration: 250.ms),

          // Radial accent glow behind mountain (subtle stage light)
          Center(
            child: Container(
              width: 480,
              height: 480,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    c.lime.withValues(alpha: 0.12),
                    Colors.transparent,
                  ],
                ),
              ),
            ).animate().fadeIn(delay: 200.ms, duration: 800.ms),
          ),

          // Mountain + flag + particles painted layer
          Center(
            child: SizedBox(
              width: 320,
              height: 280,
              child: AnimatedBuilder(
                animation: _ctrl,
                builder: (_, __) => CustomPaint(
                  painter: _SummitPainter(
                    accent: c.lime,
                    mountainStroke: _mountainStroke.value,
                    flagRise: _flagRise.value,
                    flagPlant: _flagPlant.value,
                    particleProgress: _particles.value,
                    intensity: _intensity,
                  ),
                ),
              ),
            ),
          ),

          // Title — fades in with the mountain
          Positioned(
            top: MediaQuery.paddingOf(context).top + 80,
            left: 0, right: 0,
            child: Column(
              children: [
                Text(
                  'SUMMIT REACHED',
                  textAlign: TextAlign.center,
                  style: AppTypography.overline.copyWith(
                    color: c.lime,
                    letterSpacing: 3,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 400.ms, duration: 400.ms)
                    .slideY(begin: -0.3, end: 0, duration: 500.ms),
                const SizedBox(height: AppSpacing.xs),
                Text(
                  widget.workoutName,
                  textAlign: TextAlign.center,
                  style: AppTypography.h1.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 28,
                  ),
                )
                    .animate()
                    .fadeIn(delay: 550.ms, duration: 500.ms)
                    .slideY(begin: -0.2, end: 0, duration: 500.ms),
              ],
            ),
          ),

          // Stats row — slides up from bottom after the flag plants
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 80,
            left: 0, right: 0,
            child: _StatsRow(
              sets: widget.setsCompleted,
              reps: widget.repsCompleted,
              minutes: widget.durationMinutes,
              calories: widget.calories,
              xp: widget.xpEarned,
              accent: c.lime,
            )
                .animate()
                .fadeIn(delay: 1300.ms, duration: 500.ms)
                .slideY(
                  begin: 0.3, end: 0,
                  delay: 1300.ms,
                  duration: 600.ms,
                  curve: Curves.easeOutCubic,
                ),
          ),

          // Tap-to-skip hint
          Positioned(
            bottom: MediaQuery.paddingOf(context).bottom + 24,
            left: 0, right: 0,
            child: Text(
              'Tap to continue',
              textAlign: TextAlign.center,
              style: AppTypography.caption.copyWith(
                color: Colors.white.withValues(alpha: 0.45),
              ),
            ).animate().fadeIn(delay: 1900.ms, duration: 400.ms),
          ),
        ],
      ),
    );
  }
}

// ── Stats row ─────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  final int sets, reps, minutes, calories, xp;
  final Color accent;
  const _StatsRow({
    required this.sets,
    required this.reps,
    required this.minutes,
    required this.calories,
    required this.xp,
    required this.accent,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _stat(context, '$sets', 'SETS'),
          _divider(),
          _stat(context, '$reps', 'REPS'),
          _divider(),
          _stat(context, '${minutes}m', 'TIME'),
          _divider(),
          _stat(context, '$calories', 'KCAL'),
          _divider(),
          _statXp(context),
        ],
      ),
    );
  }

  Widget _divider() => Container(
        width: 1,
        height: 28,
        color: Colors.white.withValues(alpha: 0.1),
      );

  Widget _stat(BuildContext context, String value, String label) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          value,
          style: AppTypography.h3.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w800,
            fontSize: 22,
          ),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: AppTypography.overline.copyWith(
            color: Colors.white.withValues(alpha: 0.55),
            fontSize: 9,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }

  Widget _statXp(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedNumber(
          value: xp,
          duration: const Duration(milliseconds: 900),
          builder: (v) => Text(
            '+$v',
            style: AppTypography.h3.copyWith(
              color: accent,
              fontWeight: FontWeight.w800,
              fontSize: 22,
            ),
          ),
        ),
        const SizedBox(height: 2),
        Text(
          'XP',
          style: AppTypography.overline.copyWith(
            color: accent.withValues(alpha: 0.85),
            fontSize: 9,
            letterSpacing: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
      ],
    );
  }
}

// ── Painter ────────────────────────────────────────────────────────

class _SummitPainter extends CustomPainter {
  final Color accent;
  final double mountainStroke; // 0..1
  final double flagRise;       // 0..1 — flagpole height grows
  final double flagPlant;      // 0..1 — flag-cloth scale (elastic)
  final double particleProgress; // 0..1
  final double intensity;       // 0.4..1.0

  _SummitPainter({
    required this.accent,
    required this.mountainStroke,
    required this.flagRise,
    required this.flagPlant,
    required this.particleProgress,
    required this.intensity,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final summit = Offset(w * 0.50, h * 0.30);

    _drawMountain(canvas, w, h, summit);
    _drawFlag(canvas, summit);
    if (particleProgress > 0) _drawParticles(canvas, summit, w, h);
  }

  // Stroked triangular mountain that draws on left → right.
  void _drawMountain(Canvas canvas, double w, double h, Offset summit) {
    if (mountainStroke <= 0) return;

    // Three peaks for cinematic depth — back, mid, front.
    final back = Path()
      ..moveTo(w * 0.0, h * 0.78)
      ..lineTo(w * 0.30, h * 0.42)
      ..lineTo(w * 0.55, h * 0.62)
      ..lineTo(w * 0.85, h * 0.36)
      ..lineTo(w * 1.0, h * 0.78);

    final mid = Path()
      ..moveTo(w * 0.05, h * 0.85)
      ..lineTo(summit.dx, summit.dy)
      ..lineTo(w * 0.95, h * 0.85);

    // Back range (faint)
    _drawAnimatedStroke(canvas, back,
        accent.withValues(alpha: 0.25), 1.4, mountainStroke * 0.9);
    // Front mountain (bold)
    _drawAnimatedStroke(canvas, mid,
        accent.withValues(alpha: 0.95), 2.5, mountainStroke);

    // Soft fill under front mountain
    if (mountainStroke > 0.85) {
      final fillT = ((mountainStroke - 0.85) / 0.15).clamp(0.0, 1.0);
      final fillPath = Path.from(mid)
        ..lineTo(w * 0.95, h * 0.85)
        ..lineTo(w * 0.05, h * 0.85)
        ..close();
      canvas.drawPath(
        fillPath,
        Paint()..color = accent.withValues(alpha: 0.08 * fillT),
      );
    }
  }

  void _drawAnimatedStroke(
      Canvas canvas, Path path, Color color, double width, double t) {
    final metrics = path.computeMetrics();
    final paint = Paint()
      ..color = color
      ..strokeWidth = width
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;
    for (final m in metrics) {
      final extracted = m.extractPath(0, m.length * t.clamp(0.0, 1.0));
      canvas.drawPath(extracted, paint);
    }
  }

  // Flag pole + cloth at the summit.
  void _drawFlag(Canvas canvas, Offset summit) {
    if (flagRise <= 0) return;

    const poleHeight = 60.0;
    final poleTop = Offset(summit.dx, summit.dy - poleHeight * flagRise);

    // Pole
    canvas.drawLine(
      summit,
      poleTop,
      Paint()
        ..color = Colors.white
        ..strokeWidth = 2
        ..strokeCap = StrokeCap.round,
    );

    // Flag cloth — only after pole is up
    if (flagPlant <= 0) return;
    final clothPath = Path()
      ..moveTo(poleTop.dx, poleTop.dy)
      ..lineTo(poleTop.dx + 32 * flagPlant, poleTop.dy + 6)
      ..lineTo(poleTop.dx, poleTop.dy + 18)
      ..close();
    canvas.drawPath(
      clothPath,
      Paint()..color = accent.withValues(alpha: 0.95),
    );

    // Glow halo at summit when flag fully planted
    if (flagPlant > 0.7) {
      final haloT = ((flagPlant - 0.7) / 0.3).clamp(0.0, 1.0);
      canvas.drawCircle(
        summit,
        20 + 30 * haloT,
        Paint()
          ..color = accent.withValues(alpha: 0.35 * (1 - haloT))
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
      );
    }
  }

  // Particle fan — explodes from summit, drifts up + outward, fades out.
  void _drawParticles(Canvas canvas, Offset origin, double w, double h) {
    final count = (24 * intensity).round();
    final rng = math.Random(42); // deterministic so frame-to-frame is stable
    final t = particleProgress;

    for (var i = 0; i < count; i++) {
      // Direction: upward fan (-30° to -150° measured from horizontal)
      final angle =
          -math.pi * 0.5 + (rng.nextDouble() - 0.5) * math.pi * 0.85;
      final speed = 80 + rng.nextDouble() * 140;
      final stagger = i / count * 0.25;          // staggered launch
      final localT = ((t - stagger) / (1 - stagger)).clamp(0.0, 1.0);
      if (localT <= 0) continue;

      // Position via parametric arc — eased
      final eased = Curves.easeOutCubic.transform(localT);
      final dx = math.cos(angle) * speed * eased;
      final dy = math.sin(angle) * speed * eased + 60 * eased * eased;

      final pos = origin + Offset(dx, dy);
      final radius = 2.0 + rng.nextDouble() * 2.5;
      final alpha = (1 - localT).clamp(0.0, 1.0);

      // Glow
      canvas.drawCircle(
        pos,
        radius * 2.5,
        Paint()
          ..color = accent.withValues(alpha: 0.25 * alpha)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 4),
      );
      // Core
      canvas.drawCircle(
        pos,
        radius,
        Paint()..color = accent.withValues(alpha: alpha),
      );
    }
  }

  @override
  bool shouldRepaint(covariant _SummitPainter old) =>
      old.mountainStroke != mountainStroke ||
      old.flagRise != flagRise ||
      old.flagPlant != flagPlant ||
      old.particleProgress != particleProgress;
}
