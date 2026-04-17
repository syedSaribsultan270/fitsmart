import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_extensions.dart';

/// Replaces Flutter's red error screen with a branded error UI.
///
/// Used in two ways:
///  1. [ErrorWidget.builder] — catches build-time widget errors.
///  2. Directly in screens for async / network error states.
class AppErrorWidget extends StatelessWidget {
  /// Optional error detail shown only in debug mode.
  final String? message;

  /// Optional label for the retry button. Pass [onRetry] to show it.
  final String? retryLabel;

  /// Called when the user taps retry. If null, no button is shown.
  final VoidCallback? onRetry;

  const AppErrorWidget({
    super.key,
    this.message,
    this.retryLabel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    final colors = context.colors;
    return Material(
      color: colors.bgPrimary,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.pagePadding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Icon
              Container(
                width: 72,
                height: 72,
                decoration: BoxDecoration(
                  color: colors.errorBg,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.error_outline_rounded,
                  color: colors.error,
                  size: 36,
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // Title
              Text(
                'Something went wrong',
                style: AppTypography.h3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: AppSpacing.sm),

              // Subtitle
              Text(
                'The app hit an unexpected error.\nPlease restart or try again.',
                style: AppTypography.body.copyWith(
                  color: colors.textSecondary,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),

              // Debug detail (debug builds only)
              if (kDebugMode && message != null) ...[
                const SizedBox(height: AppSpacing.lg),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(AppSpacing.md),
                  decoration: BoxDecoration(
                    color: colors.bgTertiary,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                    border: Border.all(color: colors.surfaceCardBorder),
                  ),
                  child: Text(
                    message!,
                    style: AppTypography.mono.copyWith(
                      fontSize: 11,
                      color: colors.error,
                    ),
                    maxLines: 8,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],

              // Retry button
              if (onRetry != null) ...[
                const SizedBox(height: AppSpacing.xl),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: onRetry,
                    style: FilledButton.styleFrom(
                      backgroundColor: colors.lime,
                      foregroundColor: colors.textInverse,
                      padding: const EdgeInsets.symmetric(
                          vertical: AppSpacing.md),
                      shape: RoundedRectangleBorder(
                        borderRadius:
                            BorderRadius.circular(AppRadius.md),
                      ),
                    ),
                    child: Text(
                      retryLabel ?? 'Try Again',
                      style: AppTypography.bodyMedium.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
