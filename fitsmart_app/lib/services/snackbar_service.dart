import 'dart:async';
import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_spacing.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/theme_extensions.dart';

/// Top-anchored toast service. Slides down from above the status bar,
/// solid high-contrast surface (legibility wins over translucency for
/// transient text). Replaces the previous bottom-floating SnackBar so
/// it never hides the bottom nav, FAB, or active CTA.
class SnackbarService {
  /// Kept for backwards-compat with main.dart wiring. The messenger is no
  /// longer used for toasts (we use the overlay) but other widgets may still
  /// expect this key, e.g. error boundaries.
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static OverlayEntry? _entry;
  static Timer? _dismissTimer;

  static void show(
    String message, {
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final ctx = scaffoldMessengerKey.currentContext;
    if (ctx == null) return;
    final overlay = Overlay.maybeOf(ctx, rootOverlay: true);
    if (overlay == null) return;

    // Replace any in-flight banner so back-to-back toasts don't stack.
    _dismiss();

    final entry = OverlayEntry(
      builder: (overlayContext) => _TopBanner(
        message: message,
        isError: isError,
        isSuccess: isSuccess,
        actionLabel: actionLabel,
        onAction: onAction,
        onDismiss: _dismiss,
      ),
    );
    _entry = entry;
    overlay.insert(entry);

    _dismissTimer = Timer(duration, _dismiss);
  }

  static void _dismiss() {
    _dismissTimer?.cancel();
    _dismissTimer = null;
    _entry?.remove();
    _entry = null;
  }

  static void success(String message) => show(message, isSuccess: true);
  static void error(String message) => show(message, isError: true);
  static void info(String message) => show(message);
}

class _TopBanner extends StatefulWidget {
  final String message;
  final bool isError;
  final bool isSuccess;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;

  const _TopBanner({
    required this.message,
    required this.isError,
    required this.isSuccess,
    required this.actionLabel,
    required this.onAction,
    required this.onDismiss,
  });

  @override
  State<_TopBanner> createState() => _TopBannerState();
}

class _TopBannerState extends State<_TopBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _ctrl;
  late final Animation<Offset> _slide;
  late final Animation<double> _fade;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )..forward();
    _slide = Tween<Offset>(
      begin: const Offset(0, -1),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOutCubic));
    _fade = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _dismissWithAnim() async {
    if (!mounted) return;
    await _ctrl.reverse();
    widget.onDismiss();
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;

    // High-contrast surface — solid (not glass) so the message is always
    // legible regardless of what's behind it.
    final accent = widget.isError
        ? c.error
        : widget.isSuccess
            ? c.success
            : c.lime;
    final iconData = widget.isError
        ? Icons.error_outline_rounded
        : widget.isSuccess
            ? Icons.check_circle_outline_rounded
            : Icons.info_outline_rounded;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = isDark
        ? const Color(0xFF1F1F24)
        : const Color(0xFFFFFFFF);
    final shadowColor = Colors.black.withValues(alpha: isDark ? 0.5 : 0.18);

    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slide,
        child: FadeTransition(
          opacity: _fade,
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(
                AppSpacing.md, AppSpacing.sm,
                AppSpacing.md, 0,
              ),
              child: GestureDetector(
                onVerticalDragEnd: (d) {
                  if ((d.primaryVelocity ?? 0) < -200) _dismissWithAnim();
                },
                onTap: _dismissWithAnim,
                child: Material(
                  color: Colors.transparent,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppSpacing.md,
                      vertical: AppSpacing.sm + 2,
                    ),
                    decoration: BoxDecoration(
                      color: surface,
                      borderRadius: BorderRadius.circular(AppRadius.md),
                      border: Border(
                        left: BorderSide(color: accent, width: 3),
                        top: BorderSide(
                          color: c.surfaceCardBorder.withValues(alpha: 0.6),
                        ),
                        right: BorderSide(
                          color: c.surfaceCardBorder.withValues(alpha: 0.6),
                        ),
                        bottom: BorderSide(
                          color: c.surfaceCardBorder.withValues(alpha: 0.6),
                        ),
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: shadowColor,
                          blurRadius: 24,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: Row(
                      children: [
                        Icon(iconData, color: accent, size: 20),
                        const SizedBox(width: AppSpacing.sm),
                        Expanded(
                          child: Text(
                            widget.message,
                            style: AppTypography.body.copyWith(
                              color: c.textPrimary,
                              height: 1.35,
                            ),
                            maxLines: 3,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        if (widget.actionLabel != null) ...[
                          const SizedBox(width: AppSpacing.sm),
                          TextButton(
                            onPressed: () {
                              widget.onAction?.call();
                              _dismissWithAnim();
                            },
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.lime,
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppSpacing.sm,
                              ),
                              minimumSize: const Size(0, 36),
                            ),
                            child: Text(
                              widget.actionLabel!,
                              style: const TextStyle(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
