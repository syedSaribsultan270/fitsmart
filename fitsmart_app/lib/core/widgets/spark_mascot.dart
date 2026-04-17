import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../theme/theme_extensions.dart';
import '../../providers/mascot_quirk_provider.dart';
import '../../providers/pointer_tracker_provider.dart';

/// Mood states for the spark mascot. Drives expression + animation.
enum SparkMood {
  /// Default — soft bob and pulsing glow.
  idle,

  /// AI is composing. Mascot tilts and orbiting particles spin around it.
  thinking,

  /// Celebration — bounces with a particle burst.
  happy,

  /// User hasn't been around. Z floats above, dim glow.
  sleeping,
}

/// Procedural mascot — a glowing lime "spark" character with eyes.
/// Pure CustomPainter, no asset dependency.
///
/// Drop into an AppBar leading slot, into empty states, or hero areas.
/// Drives off [mood]; transitions between moods are smooth.
///
/// Usage:
/// ```dart
/// SparkMascot(mood: SparkMood.thinking, size: 64)
/// ```
class SparkMascot extends StatefulWidget {
  final SparkMood mood;
  final double size;

  /// Override the body / glow color. Defaults to theme accent (lime).
  final Color? color;

  /// Pupil shift in local coordinates (pixels, x/y). When null or zero,
  /// eyes are centered. Use [SparkMascot.reactive] to auto-populate this
  /// from the global pointer tracker.
  final Offset gazeOffset;

  /// Currently-playing random quirk. Stackable on top of [mood].
  /// Use [SparkMascot.reactive] to auto-populate from the global quirk
  /// controller.
  final MascotQuirk quirk;

  const SparkMascot({
    super.key,
    this.mood = SparkMood.idle,
    this.size = 64,
    this.color,
    this.gazeOffset = Offset.zero,
    this.quirk = MascotQuirk.none,
  });

  /// Pointer-aware, quirk-aware mascot. Drop this anywhere — it subscribes
  /// to the global pointer tracker + quirk controller internally and keeps
  /// its own position in sync so eyes track the cursor/touch correctly.
  ///
  /// Gaze is disabled automatically when `mood` is `thinking` or `sleeping`.
  static Widget reactive({
    Key? key,
    SparkMood mood = SparkMood.idle,
    double size = 64,
    Color? color,
  }) {
    return _ReactiveSparkMascot(
      key: key, mood: mood, size: size, color: color,
    );
  }

  @override
  State<SparkMascot> createState() => _SparkMascotState();
}

/// Thin wrapper that reads pointer + quirk providers, computes gaze in
/// local coords using a GlobalKey on the rendered mascot, and passes both
/// to the plain [SparkMascot] painter.
class _ReactiveSparkMascot extends ConsumerStatefulWidget {
  final SparkMood mood;
  final double size;
  final Color? color;
  const _ReactiveSparkMascot({
    super.key,
    required this.mood,
    required this.size,
    this.color,
  });

  @override
  ConsumerState<_ReactiveSparkMascot> createState() =>
      _ReactiveSparkMascotState();
}

class _ReactiveSparkMascotState extends ConsumerState<_ReactiveSparkMascot> {
  final _anchorKey = GlobalKey();
  Offset _gazeOffset = Offset.zero;

  // Subtle gaze range per user decision: max 1.5px pupil shift.
  // Far enough to "feel alive", close enough to never read as googly.
  static const double _maxPupilShift = 1.5;
  // Eyes track the cursor anywhere on the screen — no distance falloff.
  // The max pupil shift is still bounded by [_maxPupilShift] above, so
  // the effect stays subtle even when the cursor is at the far edge.
  // Mobile-only: eyes spring back to centered after this long of silence.
  static const Duration _idleAfter = Duration(milliseconds: 1200);

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    WidgetsBinding.instance.addPostFrameCallback((_) => _recompute());
  }

  void _recompute() {
    if (!mounted) return;
    final pointer = ref.read(pointerTrackerProvider);
    final box = _anchorKey.currentContext?.findRenderObject() as RenderBox?;
    if (box == null || !box.hasSize) return;

    // Disable gaze for focused/unfocused moods
    if (widget.mood == SparkMood.thinking ||
        widget.mood == SparkMood.sleeping ||
        pointer.position == null ||
        pointer.at == null) {
      if (_gazeOffset != Offset.zero) {
        setState(() => _gazeOffset = Offset.zero);
      }
      return;
    }

    // Mobile-style: decay the reaction after no activity.
    final age = pointer.age;
    if (age != null && age > _idleAfter) {
      if (_gazeOffset != Offset.zero) {
        setState(() => _gazeOffset = Offset.zero);
      }
      return;
    }

    final center = box.localToGlobal(box.size.center(Offset.zero));
    final dir = pointer.position! - center;
    final dist = dir.distance;
    if (dist < 2) return;

    // No distance attenuation — eyes always look toward the cursor, anywhere
    // on screen. The magnitude is capped by [_maxPupilShift] so the effect
    // stays subtle even at the far edge of the viewport.
    //
    // Age attenuation stays — on mobile, pupils spring back to centered
    // during the last 400ms of the idle window after no pointer activity.
    final ageMs = age?.inMilliseconds ?? 0;
    final ageAtt = (1 -
            ((ageMs - (_idleAfter.inMilliseconds - 400)) /
                    400)
                .clamp(0.0, 1.0))
        .clamp(0.0, 1.0);

    final normalized = dir / dist;
    final target = normalized * _maxPupilShift * ageAtt;

    // Skip trivial updates to avoid frame churn.
    if ((target - _gazeOffset).distance < 0.1) return;
    setState(() => _gazeOffset = target);
  }

  @override
  Widget build(BuildContext context) {
    // Listen to pointer + quirk; trigger recompute post-frame.
    ref.listen(pointerTrackerProvider, (_, __) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _recompute());
    });
    final quirk = ref.watch(mascotQuirkProvider);

    return RepaintBoundary(
      key: _anchorKey,
      child: SparkMascot(
        mood: widget.mood,
        size: widget.size,
        color: widget.color,
        gazeOffset: _gazeOffset,
        quirk: quirk,
      ),
    );
  }
}

class _SparkMascotState extends State<SparkMascot>
    with TickerProviderStateMixin {
  // Two controllers:
  //   _loop drives perpetual idle/breath/orbit animations.
  //   _moodAnim plays a one-shot transition when [mood] changes.
  //   _quirkAnim plays a one-shot quirk animation.
  late final AnimationController _loop;
  late final AnimationController _moodAnim;
  late final AnimationController _quirkAnim;
  SparkMood _prevMood = SparkMood.idle;
  MascotQuirk _activeQuirk = MascotQuirk.none;

  @override
  void initState() {
    super.initState();
    _loop = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _moodAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );
    _quirkAnim = AnimationController(vsync: this);
    _prevMood = widget.mood;
    _moodAnim.forward(from: 0);
    _activeQuirk = widget.quirk;
    _playQuirkIfNeeded();
  }

  @override
  void didUpdateWidget(covariant SparkMascot old) {
    super.didUpdateWidget(old);
    if (old.mood != widget.mood) {
      _prevMood = old.mood;
      _moodAnim.forward(from: 0);
    }
    if (old.quirk != widget.quirk) {
      _activeQuirk = widget.quirk;
      _playQuirkIfNeeded();
    }
  }

  void _playQuirkIfNeeded() {
    if (widget.quirk == MascotQuirk.none) return;
    // Don't play quirks over focused moods.
    if (widget.mood == SparkMood.thinking ||
        widget.mood == SparkMood.sleeping) {
      return;
    }
    final dur = _quirkPlayDuration(widget.quirk);
    _quirkAnim
      ..stop()
      ..duration = dur
      ..forward(from: 0);
  }

  Duration _quirkPlayDuration(MascotQuirk q) {
    // Must match mascot_quirk_provider values.
    switch (q) {
      case MascotQuirk.lookAround:      return const Duration(milliseconds: 1200);
      case MascotQuirk.doubleBlink:     return const Duration(milliseconds: 500);
      case MascotQuirk.headTilt:        return const Duration(milliseconds: 700);
      case MascotQuirk.yawn:            return const Duration(milliseconds: 1000);
      case MascotQuirk.shake:           return const Duration(milliseconds: 400);
      case MascotQuirk.noticeSomething: return const Duration(milliseconds: 900);
      case MascotQuirk.danceHop:        return const Duration(milliseconds: 900);
      case MascotQuirk.none:            return const Duration(milliseconds: 1);
    }
  }

  @override
  void dispose() {
    _loop.dispose();
    _moodAnim.dispose();
    _quirkAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final c = widget.color ?? context.colors.lime;
    // Clamp gaze to the widget's pixel scale: 1.5px is calibrated for a
    // 64-wide mascot. For other sizes, scale proportionally.
    final scale = widget.size / 64.0;
    final clampedGaze = Offset(
      widget.gazeOffset.dx * scale,
      widget.gazeOffset.dy * scale,
    );
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_loop, _moodAnim, _quirkAnim]),
        builder: (_, __) => CustomPaint(
          painter: _SparkPainter(
            color: c,
            mood: widget.mood,
            prevMood: _prevMood,
            loop: _loop.value,
            moodT: _moodAnim.value,
            quirk: _activeQuirk,
            quirkT: _quirkAnim.value,
            gazeOffset: clampedGaze,
          ),
        ),
      ),
    );
  }
}

class _SparkPainter extends CustomPainter {
  final Color color;
  final SparkMood mood;
  final SparkMood prevMood;
  final double loop;
  final double moodT;
  final MascotQuirk quirk;
  /// 0..1 — progress through the active quirk animation.
  final double quirkT;
  /// Subtle pupil shift in local pixels.
  final Offset gazeOffset;

  _SparkPainter({
    required this.color,
    required this.mood,
    required this.prevMood,
    required this.loop,
    required this.moodT,
    required this.quirk,
    required this.quirkT,
    required this.gazeOffset,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final w = size.width, h = size.height;
    final center = Offset(w / 2, h / 2);
    // Body radius ~38% of canvas.
    final r = w * 0.38;

    // Vertical bob — calm sine wave.
    final bobAmp = mood == SparkMood.sleeping ? 1.0 : 3.0;
    final bobY = math.sin(loop * math.pi * 2) * bobAmp;

    // Mood-specific position tweaks.
    Offset bodyOffset = Offset(0, bobY);
    double tilt = 0;
    double squash = 1;

    switch (mood) {
      case SparkMood.idle:
        break;
      case SparkMood.thinking:
        tilt = math.sin(loop * math.pi * 4) * 0.08;
        break;
      case SparkMood.happy:
        final bounce = math.sin(moodT * math.pi * 3) * (1 - moodT);
        bodyOffset = Offset(0, bobY - bounce * 8);
        squash = 1 + (1 - moodT) * 0.15;
        break;
      case SparkMood.sleeping:
        bodyOffset = Offset(0, bobY + 2);
        break;
    }

    // ── Quirk overlays on top of mood ──────────────────────────────
    // Quirks never interfere with focused moods (thinking/sleeping).
    final quirkActive = quirk != MascotQuirk.none &&
        mood != SparkMood.thinking &&
        mood != SparkMood.sleeping;

    if (quirkActive) {
      switch (quirk) {
        case MascotQuirk.headTilt:
          // 5° tilt — ease in / hold / ease out across the window.
          final t = _bellCurve(quirkT);
          tilt += t * 0.09;
          break;
        case MascotQuirk.shake:
          // ±1.5px horizontal shake, 3 oscillations.
          bodyOffset = Offset(
            math.sin(quirkT * math.pi * 6) * 1.5 * (1 - quirkT),
            bodyOffset.dy,
          );
          break;
        case MascotQuirk.noticeSomething:
          // Sudden flinch: quick scale blip + slight body shift up.
          final blip = quirkT < 0.3 ? (quirkT / 0.3) : (1 - quirkT) / 0.7;
          bodyOffset = Offset(bodyOffset.dx, bodyOffset.dy - blip * 2.0);
          squash *= 1 + blip * 0.06;
          break;
        case MascotQuirk.danceHop:
          // Two vertical bounces.
          final hop = -math.sin(quirkT * math.pi * 2).abs() * 4.0;
          bodyOffset = Offset(bodyOffset.dx, bodyOffset.dy + hop);
          break;
        case MascotQuirk.yawn:
          // Subtle scale stretch.
          squash *= 1 + _bellCurve(quirkT) * 0.05;
          break;
        case MascotQuirk.lookAround:
        case MascotQuirk.doubleBlink:
        case MascotQuirk.none:
          break;
      }
    }

    canvas.save();
    canvas.translate(center.dx + bodyOffset.dx, center.dy + bodyOffset.dy);
    canvas.rotate(tilt);
    canvas.scale(squash, 1 / squash);

    _drawGlow(canvas, r);
    _drawBody(canvas, r);
    _drawHighlight(canvas, r);

    canvas.restore();

    // Eyes (drawn after restore so they don't get squash-scaled weirdly).
    canvas.save();
    canvas.translate(center.dx + bodyOffset.dx, center.dy + bodyOffset.dy);
    canvas.rotate(tilt);
    _drawEyes(canvas, r);
    canvas.restore();

    // Overlays per mood.
    if (mood == SparkMood.thinking) {
      _drawOrbitingParticles(canvas, center + bodyOffset, r);
    }
    if (mood == SparkMood.happy) {
      _drawHappyBurst(canvas, center + bodyOffset, r);
    }
    if (mood == SparkMood.sleeping) {
      _drawZ(canvas, center + bodyOffset, r);
    }
  }

  void _drawGlow(Canvas canvas, double r) {
    final pulse = 0.85 + math.sin(loop * math.pi * 2) * 0.15;
    final glowR = r * 1.55 * pulse;
    final alpha = mood == SparkMood.sleeping ? 0.10 : 0.22;
    canvas.drawCircle(
      Offset.zero,
      glowR,
      Paint()
        ..color = color.withValues(alpha: alpha)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12),
    );
  }

  void _drawBody(Canvas canvas, double r) {
    // Soft gradient body — inner highlight to bottom-right shadow.
    final rect = Rect.fromCircle(center: Offset.zero, radius: r);
    final paint = Paint()
      ..shader = RadialGradient(
        center: const Alignment(-0.3, -0.4),
        radius: 1.1,
        colors: [
          Color.lerp(color, Colors.white, 0.35)!,
          color,
          Color.lerp(color, Colors.black, 0.20)!,
        ],
        stops: const [0.0, 0.6, 1.0],
      ).createShader(rect);
    canvas.drawCircle(Offset.zero, r, paint);

    // Outline ring for definition.
    canvas.drawCircle(
      Offset.zero,
      r,
      Paint()
        ..color = Colors.black.withValues(alpha: 0.25)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 0.8,
    );
  }

  void _drawHighlight(Canvas canvas, double r) {
    // Tiny specular highlight top-left — sells the "orb" 3D feel.
    canvas.drawCircle(
      Offset(-r * 0.30, -r * 0.40),
      r * 0.18,
      Paint()
        ..color = Colors.white.withValues(alpha: 0.55)
        ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2),
    );
  }

  void _drawEyes(Canvas canvas, double r) {
    final eyeY = -r * 0.05;
    final eyeOffset = r * 0.30;
    final eyeColor = Colors.black.withValues(alpha: 0.85);

    if (mood == SparkMood.sleeping) {
      // Closed eyes — short horizontal arcs.
      final paint = Paint()
        ..color = eyeColor
        ..strokeWidth = 1.6
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      const arcW = 8.0;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(-eyeOffset, eyeY),
          width: arcW, height: arcW,
        ),
        0, math.pi, false, paint,
      );
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(eyeOffset, eyeY),
          width: arcW, height: arcW,
        ),
        0, math.pi, false, paint,
      );
      return;
    }

    if (mood == SparkMood.happy) {
      // Happy eyes — upside-down arcs (^^).
      final paint = Paint()
        ..color = eyeColor
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;
      const arcW = 10.0;
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(-eyeOffset, eyeY),
          width: arcW, height: arcW,
        ),
        math.pi, math.pi, false, paint,
      );
      canvas.drawArc(
        Rect.fromCenter(
          center: Offset(eyeOffset, eyeY),
          width: arcW, height: arcW,
        ),
        math.pi, math.pi, false, paint,
      );
      return;
    }

    // Default round eyes — blink occasionally.
    // Natural blink every 4s; double-blink quirk adds a second blink.
    bool isBlinking = loop > 0.96;
    if (quirk == MascotQuirk.doubleBlink && !(mood == SparkMood.thinking)) {
      // Two blinks inside the 500ms quirk window.
      final blinkPhase = (quirkT * 2) % 1.0;
      if (blinkPhase > 0.80) isBlinking = true;
    }
    if (quirk == MascotQuirk.yawn) {
      // Squint during yawn.
      final bell = _bellCurve(quirkT);
      if (bell > 0.45) isBlinking = true;
    }

    // Pupil offset: combines continuous gaze-follow + one-shot quirk glances.
    Offset pupilShift = gazeOffset;
    if (quirk == MascotQuirk.lookAround && mood == SparkMood.idle) {
      // Full left → right → center sweep across the 1200ms window.
      final lr = math.sin(quirkT * math.pi * 2);
      pupilShift = Offset(lr * 2.2, 0);
    } else if (quirk == MascotQuirk.noticeSomething) {
      // Sudden glance in a random-but-deterministic direction (from quirkT seed).
      final angle = (loop * 6.28) % 6.28; // reuse loop as seed
      final eased = _bellCurve(quirkT);
      pupilShift = Offset(math.cos(angle), math.sin(angle)) * 2.5 * eased;
    }

    final rx = 2.4;
    final ry = isBlinking ? 0.4 : 2.4;
    final eyePaint = Paint()..color = eyeColor;
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(-eyeOffset + pupilShift.dx, eyeY + pupilShift.dy),
        width: rx * 2, height: ry * 2,
      ),
      eyePaint,
    );
    canvas.drawOval(
      Rect.fromCenter(
        center: Offset(eyeOffset + pupilShift.dx, eyeY + pupilShift.dy),
        width: rx * 2, height: ry * 2,
      ),
      eyePaint,
    );

    // Yawn: little mouth arc opening, peak at mid-quirk.
    if (quirk == MascotQuirk.yawn) {
      final openAmount = _bellCurve(quirkT);
      final mouthH = 2 + openAmount * 4;
      canvas.drawOval(
        Rect.fromCenter(
          center: Offset(0, r * 0.30),
          width: 4 + openAmount * 4,
          height: mouthH,
        ),
        Paint()..color = Colors.black.withValues(alpha: 0.7),
      );
    }
  }

  /// Smooth 0 → 1 → 0 curve over the 0..1 input.
  double _bellCurve(double t) {
    if (t <= 0 || t >= 1) return 0;
    return math.sin(t * math.pi);
  }

  void _drawOrbitingParticles(Canvas canvas, Offset center, double r) {
    // 3 small dots orbit the body, phase-shifted.
    const count = 3;
    final orbitR = r * 1.25;
    for (var i = 0; i < count; i++) {
      final phase = (loop + i / count) * math.pi * 2;
      final pos = center + Offset(math.cos(phase), math.sin(phase) * 0.8) * orbitR;
      // Particles fade as they pass behind the body (sin > 0 means front).
      final inFront = math.sin(phase) > 0;
      final alpha = inFront ? 0.95 : 0.35;
      canvas.drawCircle(
        pos,
        2.5,
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
  }

  void _drawHappyBurst(Canvas canvas, Offset center, double r) {
    // Radial particle burst over the mood transition window.
    if (moodT >= 1) return;
    final burstR = r * (1.5 + moodT * 1.5);
    const count = 8;
    final alpha = (1 - moodT).clamp(0.0, 1.0);
    for (var i = 0; i < count; i++) {
      final angle = (i / count) * math.pi * 2;
      final pos = center + Offset(math.cos(angle), math.sin(angle)) * burstR;
      canvas.drawCircle(
        pos,
        3,
        Paint()..color = color.withValues(alpha: alpha),
      );
    }
  }

  void _drawZ(Canvas canvas, Offset center, double r) {
    // Floating "Z" above the head — fades up and out.
    final t = (loop * 2) % 1.0;
    final zPos = center + Offset(r * 0.8, -r * 0.8 - t * 16);
    final paint = TextPainter(
      text: TextSpan(
        text: 'Z',
        style: TextStyle(
          color: color.withValues(alpha: (1 - t) * 0.9),
          fontWeight: FontWeight.w800,
          fontSize: 14 + t * 6,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    paint.paint(canvas, zPos - Offset(paint.width / 2, paint.height / 2));
  }

  @override
  bool shouldRepaint(covariant _SparkPainter old) =>
      old.loop != loop ||
      old.moodT != moodT ||
      old.mood != mood ||
      old.color != color ||
      old.quirk != quirk ||
      old.quirkT != quirkT ||
      old.gazeOffset != gazeOffset;
}
