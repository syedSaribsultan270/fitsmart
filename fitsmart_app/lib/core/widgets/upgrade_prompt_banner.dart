import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../theme/app_spacing.dart';
import '../theme/app_typography.dart';
import '../theme/theme_extensions.dart';
import '../../providers/auth_provider.dart';

/// Shows a dismissible banner prompting anonymous users to create an account.
/// Re-appears after 3 days if dismissed.
class UpgradePromptBanner extends ConsumerStatefulWidget {
  const UpgradePromptBanner({super.key});

  @override
  ConsumerState<UpgradePromptBanner> createState() =>
      _UpgradePromptBannerState();
}

class _UpgradePromptBannerState extends ConsumerState<UpgradePromptBanner> {
  bool _visible = false;
  bool _loaded = false;

  @override
  void initState() {
    super.initState();
    _checkVisibility();
  }

  Future<void> _checkVisibility() async {
    final prefs = await SharedPreferences.getInstance();
    final dismissedAt = prefs.getInt('upgrade_prompt_dismissed_at');
    if (dismissedAt != null) {
      final dismissedDate =
          DateTime.fromMillisecondsSinceEpoch(dismissedAt);
      final daysSince = DateTime.now().difference(dismissedDate).inDays;
      if (daysSince < 3) {
        setState(() => _loaded = true);
        return;
      }
    }
    setState(() {
      _visible = true;
      _loaded = true;
    });
  }

  Future<void> _dismiss() async {
    setState(() => _visible = false);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(
      'upgrade_prompt_dismissed_at',
      DateTime.now().millisecondsSinceEpoch,
    );
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(authUserProvider).valueOrNull;
    final isGuest = user == null || user.isAnonymous;

    if (!isGuest || !_visible || !_loaded) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.only(bottom: AppSpacing.md),
      padding: const EdgeInsets.all(AppSpacing.md),
      decoration: BoxDecoration(
        color: context.colors.surfaceCard,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: context.colors.lime.withValues(alpha: 0.3)),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: context.colors.limeGlow,
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Icon(
              Icons.shield_outlined,
              color: context.colors.lime,
              size: 20,
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Secure your progress',
                  style: AppTypography.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Create an account to sync across devices',
                  style: AppTypography.caption.copyWith(
                    color: context.colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          GestureDetector(
            onTap: () => context.push('/signup'),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
                vertical: AppSpacing.sm,
              ),
              decoration: BoxDecoration(
                color: context.colors.lime,
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
              child: Text(
                'Sign Up',
                style: AppTypography.caption.copyWith(
                  color: context.colors.textInverse,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: _dismiss,
            child: Icon(
              Icons.close_rounded,
              size: 18,
              color: context.colors.textTertiary,
            ),
          ),
        ],
      ),
    );
  }
}
