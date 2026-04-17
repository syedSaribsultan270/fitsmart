import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../services/analytics_service.dart';

/// Full-screen barcode scanner. Pops with the detected barcode string when
/// a barcode is found, or pops with null if the user closes the screen.
///
/// Usage:
/// ```dart
/// final barcode = await Navigator.of(context).push<String>(
///   MaterialPageRoute(builder: (_) => const BarcodeScanScreen(), fullscreenDialog: true),
/// );
/// ```
class BarcodeScanScreen extends StatefulWidget {
  const BarcodeScanScreen({super.key});

  @override
  State<BarcodeScanScreen> createState() => _BarcodeScanScreenState();
}

class _BarcodeScanScreenState extends State<BarcodeScanScreen> {
  final _controller = MobileScannerController();
  bool _detected = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.track('barcode_scan_started');
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onDetect(BarcodeCapture capture) {
    if (_detected) return;
    final raw = capture.barcodes.firstOrNull?.rawValue;
    if (raw == null || raw.isEmpty) return;
    _detected = true;
    _controller.stop();
    Navigator.of(context).pop(raw);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: Text(
          'Scan Barcode',
          style: AppTypography.bodyMedium
              .copyWith(color: Colors.white, fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () => _controller.toggleTorch(),
            tooltip: 'Toggle torch',
          ),
        ],
      ),
      body: Stack(
        children: [
          MobileScanner(
            controller: _controller,
            onDetect: _onDetect,
          ),
          // Aiming reticle overlay
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _ScanReticle(),
                const SizedBox(height: AppSpacing.lg),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.sm,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withAlpha(160),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: Text(
                    'Point at the barcode on the package',
                    style: AppTypography.caption.copyWith(color: Colors.white),
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

class _ScanReticle extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    const size = 220.0;
    const cornerLength = 28.0;
    const strokeWidth = 3.0;
    final color = context.colors.lime;

    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _CornerPainter(color: color, cornerLength: cornerLength, strokeWidth: strokeWidth),
      ),
    );
  }
}

class _CornerPainter extends CustomPainter {
  final Color color;
  final double cornerLength;
  final double strokeWidth;

  const _CornerPainter({
    required this.color,
    required this.cornerLength,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    final r = const Radius.circular(4);
    final w = size.width;
    final h = size.height;
    final cl = cornerLength;

    // Top-left
    canvas.drawPath(
        Path()
          ..moveTo(0, cl)
          ..arcToPoint(Offset(cl, 0), radius: r),
        paint);
    // Top-right
    canvas.drawPath(
        Path()
          ..moveTo(w - cl, 0)
          ..arcToPoint(Offset(w, cl), radius: r),
        paint);
    // Bottom-right
    canvas.drawPath(
        Path()
          ..moveTo(w, h - cl)
          ..arcToPoint(Offset(w - cl, h), radius: r),
        paint);
    // Bottom-left
    canvas.drawPath(
        Path()
          ..moveTo(cl, h)
          ..arcToPoint(Offset(0, h - cl), radius: r),
        paint);
  }

  @override
  bool shouldRepaint(_CornerPainter old) =>
      old.color != color ||
      old.cornerLength != cornerLength ||
      old.strokeWidth != strokeWidth;
}
