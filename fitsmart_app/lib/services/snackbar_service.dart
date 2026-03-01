import 'package:flutter/material.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../core/theme/app_spacing.dart';

/// Global snackbar service — usable without BuildContext.
class SnackbarService {
  static final scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  static void show(
    String message, {
    bool isError = false,
    bool isSuccess = false,
    Duration duration = const Duration(seconds: 3),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final messenger = scaffoldMessengerKey.currentState;
    if (messenger == null) return;

    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            if (isError)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.error_outline_rounded, color: AppColors.error, size: 20),
              )
            else if (isSuccess)
              const Padding(
                padding: EdgeInsets.only(right: 8),
                child: Icon(Icons.check_circle_outline_rounded, color: AppColors.success, size: 20),
              ),
            Expanded(
              child: Text(
                message,
                style: AppTypography.body.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: isError
            ? AppColors.errorBg
            : isSuccess
                ? AppColors.successBg
                : AppColors.bgElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
          side: BorderSide(
            color: isError
                ? AppColors.error.withValues(alpha: 0.3)
                : isSuccess
                    ? AppColors.success.withValues(alpha: 0.3)
                    : AppColors.surfaceCardBorder,
          ),
        ),
        duration: duration,
        action: actionLabel != null
            ? SnackBarAction(
                label: actionLabel,
                textColor: AppColors.lime,
                onPressed: onAction ?? () {},
              )
            : null,
      ),
    );
  }

  static void success(String message) => show(message, isSuccess: true);
  static void error(String message) => show(message, isError: true);
  static void info(String message) => show(message);
}
