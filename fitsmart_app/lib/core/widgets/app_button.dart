import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../theme/app_colors.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';

enum AppButtonVariant { primary, secondary, ghost, danger, lime }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final AppButtonVariant variant;
  final IconData? icon;
  final bool isLoading;
  final bool fullWidth;
  final double? height;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.variant = AppButtonVariant.primary,
    this.icon,
    this.isLoading = false,
    this.fullWidth = true,
    this.height,
  });

  @override
  Widget build(BuildContext context) {
    final colors = _getColors();

    return SizedBox(
      width: fullWidth ? double.infinity : null,
      height: height ?? 52,
      child: AnimatedOpacity(
        opacity: onPressed == null ? 0.4 : 1.0,
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: colors['bg'],
          borderRadius: BorderRadius.circular(AppRadius.lg),
          child: InkWell(
            onTap: isLoading || onPressed == null
                ? null
                : () {
                    HapticFeedback.lightImpact();
                    onPressed!();
                  },
            borderRadius: BorderRadius.circular(AppRadius.lg),
            splashColor: colors['splash'],
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: colors['border'] != null
                    ? Border.all(color: colors['border']!, width: 1.5)
                    : null,
              ),
              child: isLoading
                  ? Center(
                      child: SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: colors['fg'],
                        ),
                      ),
                    )
                  : Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize:
                          fullWidth ? MainAxisSize.max : MainAxisSize.min,
                      children: [
                        if (icon != null) ...[
                          Icon(icon, color: colors['fg'], size: 20),
                          const SizedBox(width: AppSpacing.sm),
                        ],
                        Text(
                          label,
                          style: AppTypography.bodyMedium.copyWith(
                            color: colors['fg'],
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.3,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }

  Map<String, Color?> _getColors() {
    switch (variant) {
      case AppButtonVariant.primary:
      case AppButtonVariant.lime:
        return {
          'bg': AppColors.lime,
          'fg': AppColors.textInverse,
          'splash': AppColors.limeMuted,
          'border': null,
        };
      case AppButtonVariant.secondary:
        return {
          'bg': AppColors.surfaceCard,
          'fg': AppColors.textPrimary,
          'splash': AppColors.surfaceCardHover,
          'border': AppColors.surfaceCardBorder,
        };
      case AppButtonVariant.ghost:
        return {
          'bg': Colors.transparent,
          'fg': AppColors.lime,
          'splash': AppColors.limeGlow,
          'border': AppColors.lime,
        };
      case AppButtonVariant.danger:
        return {
          'bg': AppColors.errorBg,
          'fg': AppColors.error,
          'splash': AppColors.errorBg,
          'border': AppColors.error,
        };
    }
  }
}

/// A small pill-shaped button
class PillButton extends StatelessWidget {
  final String label;
  final bool isActive;
  final VoidCallback onTap;
  final Color? activeColor;

  const PillButton({
    super.key,
    required this.label,
    required this.isActive,
    required this.onTap,
    this.activeColor,
  });

  @override
  Widget build(BuildContext context) {
    final color = activeColor ?? AppColors.lime;
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: AnimatedContainer(
        duration: 200.ms,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 7),
        decoration: BoxDecoration(
          color: isActive ? color : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(
            color: isActive ? color : AppColors.surfaceCardBorder,
            width: 1.5,
          ),
        ),
        child: Text(
          label,
          style: AppTypography.caption.copyWith(
            color: isActive ? AppColors.textInverse : AppColors.textSecondary,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.3,
          ),
        ),
      ).animate(target: isActive ? 1 : 0).scaleXY(begin: 1, end: 1.02),
    );
  }
}
