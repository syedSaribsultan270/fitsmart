import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/config/bank_config.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../core/theme/theme_extensions.dart';
import '../../../core/widgets/liquid_glass.dart';
import '../../../services/analytics_service.dart';
import '../../../services/snackbar_service.dart';

/// Manual bank-transfer paywall — redesigned for clarity and breathing room.
///
/// Vertical flow:
///   Hero (icon + title + tagline)
///   3 hero benefits (compact, scannable)
///   Tier picker (3 cards)
///   Primary CTA — "Continue with [Tier]"
///   Bank details (collapsed; expands inline after tier selection or CTA)
///   Confirmation CTA — "I've sent the payment"
///
/// Operator manually flips users/{uid}.premium = true after verifying transfer.
class PaywallScreen extends ConsumerStatefulWidget {
  final String? trigger;
  const PaywallScreen({super.key, this.trigger});

  @override
  ConsumerState<PaywallScreen> createState() => _PaywallScreenState();
}

class _PaywallScreenState extends ConsumerState<PaywallScreen> {
  String _selectedTier = 'annual';
  bool _bankExpanded = false;

  @override
  void initState() {
    super.initState();
    AnalyticsService.instance.track('paywall_shown',
        props: {'trigger': widget.trigger ?? 'unknown'});
  }

  String get _tierPrice => switch (_selectedTier) {
        'monthly' => BankConfig.priceMonthly,
        'annual' => BankConfig.priceAnnual,
        'lifetime' => BankConfig.priceLifetime,
        _ => BankConfig.priceAnnual,
      };

  String get _referenceCode {
    final uid = FirebaseAuth.instance.currentUser?.uid ?? 'GUEST';
    return 'FS-${uid.substring(0, uid.length.clamp(0, 8)).toUpperCase()}';
  }

  Future<void> _copy(String value, String label) async {
    await Clipboard.setData(ClipboardData(text: value));
    SnackbarService.success('$label copied');
    AnalyticsService.instance.track('paywall_copied', props: {'field': label});
  }

  void _continue() {
    AnalyticsService.instance.track('paywall_tier_continue',
        props: {'tier': _selectedTier});
    setState(() => _bankExpanded = true);
  }

  Future<void> _confirmSent() async {
    AnalyticsService.instance.track('paywall_confirm_sent', props: {
      'tier': _selectedTier,
      'trigger': widget.trigger ?? 'unknown',
    });
    final msg = '''Hi FitSmart team,

I've sent payment for FitSmart Premium.

Tier: ${_selectedTier.toUpperCase()} ($_tierPrice)
Reference code: $_referenceCode
Account email: ${FirebaseAuth.instance.currentUser?.email ?? '(guest)'}

Attaching a screenshot of the transfer.

Thanks!''';
    await Share.share(msg, subject: 'FitSmart Premium — payment sent');
    if (mounted) {
      SnackbarService.success(
        "We'll verify your transfer and unlock premium within 24 hours.",
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Scaffold(
      backgroundColor: c.bgPrimary,
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.pagePadding,
            AppSpacing.sm,
            AppSpacing.pagePadding,
            AppSpacing.xxl,
          ),
          children: [
            // ── Close ───────────────────────────────────────────
            Align(
              alignment: Alignment.centerRight,
              child: IconButton(
                icon: Icon(Icons.close_rounded, color: c.textTertiary),
                splashRadius: 22,
                onPressed: () {
                  AnalyticsService.instance.track('paywall_dismissed',
                      props: {'trigger': widget.trigger ?? 'unknown'});
                  context.pop();
                },
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // ── Hero ────────────────────────────────────────────
            Center(
              child: Container(
                width: 80, height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [c.lime, c.cyan],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: c.lime.withValues(alpha: 0.25),
                      blurRadius: 32,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: const Icon(Icons.bolt_rounded,
                    size: 40, color: Colors.black),
              ).animate().scale(duration: 500.ms, curve: Curves.elasticOut),
            ),

            const SizedBox(height: AppSpacing.xl),

            Text(
              'FitSmart Premium',
              style: AppTypography.h1.copyWith(
                fontWeight: FontWeight.w800,
                fontSize: 30,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppSpacing.sm),
            Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.md,
              ),
              child: Text(
                'Unlimited AI coaching, unlimited photo scans, and your own meal plans.',
                style: AppTypography.body.copyWith(
                  color: c.textSecondary,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: AppSpacing.huge),

            // ── 3 Hero benefits ─────────────────────────────────
            // Reduced from 5 dense rows to 3 punchy ones — most users decide
            // on price not feature count, so save the vertical space.
            const _Benefit(
              icon: Icons.chat_bubble_outline_rounded,
              title: 'Unlimited AI coaching',
              subtitle: 'Ask anything, anytime',
            ),
            const SizedBox(height: AppSpacing.md),
            const _Benefit(
              icon: Icons.camera_alt_outlined,
              title: 'Unlimited meal scans',
              subtitle: 'Snap any plate, get instant macros',
            ),
            const SizedBox(height: AppSpacing.md),
            const _Benefit(
              icon: Icons.auto_awesome_rounded,
              title: 'Personalised plans',
              subtitle: 'AI-built workouts & meal plans',
            ),

            const SizedBox(height: AppSpacing.huge),

            // ── Tier picker ─────────────────────────────────────
            _TierSelector(
              selected: _selectedTier,
              onSelect: (t) => setState(() {
                _selectedTier = t;
                if (_bankExpanded) {
                  // refresh price shown in bank header
                }
              }),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Primary CTA ─────────────────────────────────────
            if (!_bankExpanded)
              _PrimaryButton(
                label: 'Continue · $_tierPrice',
                onTap: _continue,
              ).animate().fadeIn(duration: 250.ms),

            // ── Bank details (collapsed by default) ─────────────
            AnimatedSize(
              duration: const Duration(milliseconds: 350),
              curve: Curves.easeOutCubic,
              alignment: Alignment.topCenter,
              child: _bankExpanded
                  ? Padding(
                      padding: const EdgeInsets.only(top: AppSpacing.lg),
                      child: _BankSection(
                        tierPrice: _tierPrice,
                        referenceCode: _referenceCode,
                        onCopy: _copy,
                        onConfirmSent: _confirmSent,
                      ).animate().fadeIn(duration: 300.ms).slideY(
                            begin: 0.04,
                            duration: 300.ms,
                            curve: Curves.easeOutCubic,
                          ),
                    )
                  : const SizedBox.shrink(),
            ),

            const SizedBox(height: AppSpacing.xl),

            // ── Footer note ─────────────────────────────────────
            Center(
              child: Text(
                'Cancel anytime · No auto-renewal · 24h verification',
                style: AppTypography.caption.copyWith(
                  color: c.textTertiary,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            if (!BankConfig.isConfigured) ...[
              const SizedBox(height: AppSpacing.lg),
              const _DevModeChip(),
            ],
          ],
        ),
      ),
    );
  }
}

// ── Benefit row (compact, breathing) ─────────────────────────────

class _Benefit extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  const _Benefit({
    required this.icon, required this.title, required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Row(
      children: [
        Container(
          width: 44, height: 44,
          decoration: BoxDecoration(
            color: c.limeGlow,
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Icon(icon, size: 20, color: c.lime),
        ),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.w700,
                  height: 1.3,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: AppTypography.caption.copyWith(
                  color: c.textSecondary,
                  height: 1.35,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Tier selector ───────────────────────────────────────────────

class _TierSelector extends StatelessWidget {
  final String selected;
  final ValueChanged<String> onSelect;
  const _TierSelector({required this.selected, required this.onSelect});

  @override
  Widget build(BuildContext context) {
    final tiers = [
      ('monthly', 'Monthly', BankConfig.priceMonthly, null),
      ('annual', 'Annual', BankConfig.priceAnnual, 'BEST VALUE'),
      ('lifetime', 'Lifetime', BankConfig.priceLifetime, 'ONE-TIME'),
    ];
    return Column(
      children: [
        for (var i = 0; i < tiers.length; i++) ...[
          _TierTile(
            id: tiers[i].$1,
            label: tiers[i].$2,
            price: tiers[i].$3,
            badge: tiers[i].$4,
            selected: selected == tiers[i].$1,
            onTap: () => onSelect(tiers[i].$1),
          ),
          if (i < tiers.length - 1) const SizedBox(height: AppSpacing.sm),
        ],
      ],
    );
  }
}

class _TierTile extends StatelessWidget {
  final String id;
  final String label;
  final String price;
  final String? badge;
  final bool selected;
  final VoidCallback onTap;
  const _TierTile({
    required this.id,
    required this.label,
    required this.price,
    required this.badge,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.lg,
        ),
        decoration: BoxDecoration(
          color: selected ? c.limeGlow : c.surfaceCard,
          borderRadius: BorderRadius.circular(AppRadius.lg),
          border: Border.all(
            color: selected ? c.lime : c.surfaceCardBorder,
            width: selected ? 1.6 : 1,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              width: 22, height: 22,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: selected ? c.lime : Colors.transparent,
                border: Border.all(
                  color: selected ? c.lime : c.textTertiary,
                  width: 2,
                ),
              ),
              child: selected
                  ? const Icon(Icons.check_rounded,
                      size: 14, color: Colors.black)
                  : null,
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    children: [
                      Text(
                        label,
                        style: AppTypography.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (badge != null) ...[
                        const SizedBox(width: AppSpacing.sm),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: c.lime,
                            borderRadius: BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            badge!,
                            style: AppTypography.overline.copyWith(
                              fontSize: 9,
                              color: Colors.black,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            Text(
              price,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.w700,
                color: selected ? c.lime : c.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Primary CTA ─────────────────────────────────────────────────

class _PrimaryButton extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _PrimaryButton({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: c.lime,
          foregroundColor: Colors.black,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.lg),
          ),
          elevation: 0,
        ),
        child: Text(
          label,
          style: AppTypography.bodyMedium.copyWith(
            fontWeight: FontWeight.w800,
            fontSize: 16,
          ),
        ),
      ),
    );
  }
}

// ── Bank details (collapsed/expanded) ───────────────────────────

class _BankSection extends StatelessWidget {
  final String tierPrice;
  final String referenceCode;
  final void Function(String value, String label) onCopy;
  final VoidCallback onConfirmSent;

  const _BankSection({
    required this.tierPrice,
    required this.referenceCode,
    required this.onCopy,
    required this.onConfirmSent,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Bank card — glass for premium feel; high intensity for legibility
        LiquidGlass(
          borderRadius: BorderRadius.circular(AppRadius.lg),
          intensity: GlassIntensity.strong,
          accentRim: true,
          accentInnerGlow: true,
          padding: const EdgeInsets.all(AppSpacing.lg),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                children: [
                  Icon(Icons.account_balance_rounded,
                      size: 18, color: c.lime),
                  const SizedBox(width: AppSpacing.sm),
                  Text(
                    'TRANSFER',
                    style: AppTypography.caption.copyWith(
                      color: c.lime,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 1.4,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    tierPrice,
                    style: AppTypography.bodyMedium.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppSpacing.lg),

              _BankRow(label: 'Bank', value: BankConfig.bankName, onCopy: onCopy),
              _BankRow(label: 'Title', value: BankConfig.accountTitle, onCopy: onCopy),
              _BankRow(label: 'Account', value: BankConfig.accountNumber, onCopy: onCopy),
              _BankRow(label: 'IBAN', value: BankConfig.iban, onCopy: onCopy),

              const SizedBox(height: AppSpacing.md),

              // Reference code — the most important field
              Container(
                padding: const EdgeInsets.all(AppSpacing.md),
                decoration: BoxDecoration(
                  color: c.lime.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  border: Border.all(
                    color: c.lime.withValues(alpha: 0.4),
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'INCLUDE THIS REFERENCE',
                            style: AppTypography.overline.copyWith(
                              color: c.lime,
                              fontSize: 9,
                              letterSpacing: 1.4,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            referenceCode,
                            style: AppTypography.h3.copyWith(
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.copy_rounded, size: 20, color: c.lime),
                      onPressed: () => onCopy(referenceCode, 'Reference'),
                      visualDensity: VisualDensity.compact,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),

        const SizedBox(height: AppSpacing.lg),

        // Confirmation CTA
        SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton.icon(
            onPressed: onConfirmSent,
            icon: const Icon(Icons.send_rounded, size: 18),
            label: const Text(
              "I've sent the payment",
              style: TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
            ),
            style: ElevatedButton.styleFrom(
              backgroundColor: c.lime,
              foregroundColor: Colors.black,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.lg),
              ),
              elevation: 0,
            ),
          ),
        ),

        const SizedBox(height: AppSpacing.sm),

        // Quiet helper line
        Center(
          child: Text(
            'Need help? ${BankConfig.confirmEmail}',
            style: AppTypography.caption.copyWith(color: c.textTertiary),
          ),
        ),
      ],
    );
  }
}

class _BankRow extends StatelessWidget {
  final String label;
  final String value;
  final void Function(String value, String label) onCopy;
  const _BankRow({
    required this.label, required this.value, required this.onCopy,
  });

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 72,
            child: Text(
              label,
              style: AppTypography.caption.copyWith(
                color: c.textSecondary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTypography.bodyMedium.copyWith(
                color: c.textPrimary,
                fontWeight: FontWeight.w600,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          GestureDetector(
            onTap: () => onCopy(value, label),
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(4),
              child: Icon(Icons.copy_rounded, size: 16, color: c.textTertiary),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Dev mode chip ───────────────────────────────────────────────

class _DevModeChip extends StatelessWidget {
  const _DevModeChip();

  @override
  Widget build(BuildContext context) {
    final c = context.colors;
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md, vertical: 6,
        ),
        decoration: BoxDecoration(
          color: c.coral.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppRadius.full),
          border: Border.all(color: c.coral.withValues(alpha: 0.3)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.warning_amber_rounded, color: c.coral, size: 14),
            const SizedBox(width: 6),
            Text(
              'Dev build · placeholder bank info',
              style: AppTypography.caption.copyWith(
                color: c.coral,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
