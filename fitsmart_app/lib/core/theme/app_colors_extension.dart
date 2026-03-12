import 'package:flutter/material.dart';

/// Theme-aware color extension. Provides all app color tokens that switch
/// between dark and light mode. Macro colors stay fixed across themes.
class AppColorsExtension extends ThemeExtension<AppColorsExtension> {
  // ── Brand / Accent ───────────────────────────────────────────
  final Color lime;
  final Color limeMuted;
  final Color limeGlow;
  final Color coral;
  final Color coralMuted;
  final Color cyan;
  final Color cyanMuted;

  // ── Backgrounds ──────────────────────────────────────────────
  final Color bgPrimary;
  final Color bgSecondary;
  final Color bgTertiary;
  final Color bgElevated;
  final Color bgOverlay;

  // ── Surfaces ─────────────────────────────────────────────────
  final Color surfaceCard;
  final Color surfaceCardHover;
  final Color surfaceCardBorder;
  final Color surfaceInput;
  final Color surfaceInputBorder;
  final Color surfaceInputFocus;

  // ── Text ─────────────────────────────────────────────────────
  final Color textPrimary;
  final Color textSecondary;
  final Color textTertiary;
  final Color textInverse;
  final Color textLink;

  // ── Semantic ─────────────────────────────────────────────────
  final Color success;
  final Color warning;
  final Color error;
  final Color info;
  final Color successBg;
  final Color warningBg;
  final Color errorBg;
  final Color infoBg;

  const AppColorsExtension({
    required this.lime,
    required this.limeMuted,
    required this.limeGlow,
    required this.coral,
    required this.coralMuted,
    required this.cyan,
    required this.cyanMuted,
    required this.bgPrimary,
    required this.bgSecondary,
    required this.bgTertiary,
    required this.bgElevated,
    required this.bgOverlay,
    required this.surfaceCard,
    required this.surfaceCardHover,
    required this.surfaceCardBorder,
    required this.surfaceInput,
    required this.surfaceInputBorder,
    required this.surfaceInputFocus,
    required this.textPrimary,
    required this.textSecondary,
    required this.textTertiary,
    required this.textInverse,
    required this.textLink,
    required this.success,
    required this.warning,
    required this.error,
    required this.info,
    required this.successBg,
    required this.warningBg,
    required this.errorBg,
    required this.infoBg,
  });

  // ── Macro colors — fixed across all themes ───────────────────
  static const macroProtein = Color(0xFF3ADFFF);
  static const macroCarbs = Color(0xFFBDFF3A);
  static const macroFat = Color(0xFFFF6B6B);
  static const macroFiber = Color(0xFFA78BFA);
  static const macroCalories = Color(0xFFFBBF24);

  // ── Dark palette ─────────────────────────────────────────────
  factory AppColorsExtension.dark({Color? accentColor}) {
    final accent = accentColor ?? const Color(0xFFBDFF3A);
    final accentMuted = _mutedVariant(accent);
    final accentGlow = accent.withValues(alpha: 0.15);

    return AppColorsExtension(
      lime: accent,
      limeMuted: accentMuted,
      limeGlow: accentGlow,
      coral: const Color(0xFFFF6B6B),
      coralMuted: const Color(0xFFE85555),
      cyan: const Color(0xFF3ADFFF),
      cyanMuted: const Color(0xFF2BB8D4),
      bgPrimary: const Color(0xFF0A0A0C),
      bgSecondary: const Color(0xFF111114),
      bgTertiary: const Color(0xFF18181C),
      bgElevated: const Color(0xFF1F1F24),
      bgOverlay: const Color(0xD90A0A0C),
      surfaceCard: const Color(0xFF16161A),
      surfaceCardHover: const Color(0xFF1C1C21),
      surfaceCardBorder: const Color(0xFF2A2A30),
      surfaceInput: const Color(0xFF111114),
      surfaceInputBorder: const Color(0xFF2A2A30),
      surfaceInputFocus: accent,
      textPrimary: const Color(0xFFF0F0F2),
      textSecondary: const Color(0xFFA0A0A8),
      textTertiary: const Color(0xFF6B6B75),
      textInverse: const Color(0xFF0A0A0C),
      textLink: const Color(0xFF3ADFFF),
      success: const Color(0xFF34D399),
      warning: const Color(0xFFFBBF24),
      error: const Color(0xFFF87171),
      info: const Color(0xFF60A5FA),
      successBg: const Color(0x1F34D399),
      warningBg: const Color(0x1FFBBF24),
      errorBg: const Color(0x1FF87171),
      infoBg: const Color(0x1F60A5FA),
    );
  }

  // ── Light palette ────────────────────────────────────────────
  factory AppColorsExtension.light({Color? accentColor}) {
    final accent = accentColor ?? const Color(0xFFBDFF3A);
    // For light mode, darken the accent so it's visible on white backgrounds
    final accentForLight = _ensureContrastOnWhite(accent);
    final accentMuted = _mutedVariant(accentForLight);
    final accentGlow = accentForLight.withValues(alpha: 0.12);

    return AppColorsExtension(
      lime: accentForLight,
      limeMuted: accentMuted,
      limeGlow: accentGlow,
      coral: const Color(0xFFE85555),
      coralMuted: const Color(0xFFD44040),
      cyan: const Color(0xFF0EA5D6),
      cyanMuted: const Color(0xFF0B8AB3),
      bgPrimary: const Color(0xFFF5F5F7),
      bgSecondary: const Color(0xFFFFFFFF),
      bgTertiary: const Color(0xFFEDEEF0),
      bgElevated: const Color(0xFFE8E8EC),
      bgOverlay: const Color(0xD9F5F5F7),
      surfaceCard: const Color(0xFFFFFFFF),
      surfaceCardHover: const Color(0xFFF0F0F2),
      surfaceCardBorder: const Color(0xFFE0E0E4),
      surfaceInput: const Color(0xFFFFFFFF),
      surfaceInputBorder: const Color(0xFFD0D0D6),
      surfaceInputFocus: accentForLight,
      textPrimary: const Color(0xFF1A1A1C),
      textSecondary: const Color(0xFF6B6B75),
      textTertiary: const Color(0xFFA0A0A8),
      textInverse: const Color(0xFFFFFFFF),
      textLink: const Color(0xFF0EA5D6),
      success: const Color(0xFF16A374),
      warning: const Color(0xFFD49B08),
      error: const Color(0xFFDC4444),
      info: const Color(0xFF3B82F6),
      successBg: const Color(0x1F34D399),
      warningBg: const Color(0x1FFBBF24),
      errorBg: const Color(0x1FF87171),
      infoBg: const Color(0x1F60A5FA),
    );
  }

  /// Compute a muted (darker, less saturated) variant using HSL.
  static Color _mutedVariant(Color c) {
    final hsl = HSLColor.fromColor(c);
    return hsl
        .withSaturation((hsl.saturation * 0.8).clamp(0.0, 1.0))
        .withLightness((hsl.lightness * 0.85).clamp(0.0, 1.0))
        .toColor();
  }

  /// Ensure accent is visible on white by darkening if luminance is too high.
  static Color _ensureContrastOnWhite(Color c) {
    final hsl = HSLColor.fromColor(c);
    if (hsl.lightness > 0.55) {
      return hsl.withLightness(0.42).toColor();
    }
    return c;
  }

  @override
  AppColorsExtension copyWith({
    Color? lime,
    Color? limeMuted,
    Color? limeGlow,
    Color? coral,
    Color? coralMuted,
    Color? cyan,
    Color? cyanMuted,
    Color? bgPrimary,
    Color? bgSecondary,
    Color? bgTertiary,
    Color? bgElevated,
    Color? bgOverlay,
    Color? surfaceCard,
    Color? surfaceCardHover,
    Color? surfaceCardBorder,
    Color? surfaceInput,
    Color? surfaceInputBorder,
    Color? surfaceInputFocus,
    Color? textPrimary,
    Color? textSecondary,
    Color? textTertiary,
    Color? textInverse,
    Color? textLink,
    Color? success,
    Color? warning,
    Color? error,
    Color? info,
    Color? successBg,
    Color? warningBg,
    Color? errorBg,
    Color? infoBg,
  }) {
    return AppColorsExtension(
      lime: lime ?? this.lime,
      limeMuted: limeMuted ?? this.limeMuted,
      limeGlow: limeGlow ?? this.limeGlow,
      coral: coral ?? this.coral,
      coralMuted: coralMuted ?? this.coralMuted,
      cyan: cyan ?? this.cyan,
      cyanMuted: cyanMuted ?? this.cyanMuted,
      bgPrimary: bgPrimary ?? this.bgPrimary,
      bgSecondary: bgSecondary ?? this.bgSecondary,
      bgTertiary: bgTertiary ?? this.bgTertiary,
      bgElevated: bgElevated ?? this.bgElevated,
      bgOverlay: bgOverlay ?? this.bgOverlay,
      surfaceCard: surfaceCard ?? this.surfaceCard,
      surfaceCardHover: surfaceCardHover ?? this.surfaceCardHover,
      surfaceCardBorder: surfaceCardBorder ?? this.surfaceCardBorder,
      surfaceInput: surfaceInput ?? this.surfaceInput,
      surfaceInputBorder: surfaceInputBorder ?? this.surfaceInputBorder,
      surfaceInputFocus: surfaceInputFocus ?? this.surfaceInputFocus,
      textPrimary: textPrimary ?? this.textPrimary,
      textSecondary: textSecondary ?? this.textSecondary,
      textTertiary: textTertiary ?? this.textTertiary,
      textInverse: textInverse ?? this.textInverse,
      textLink: textLink ?? this.textLink,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      error: error ?? this.error,
      info: info ?? this.info,
      successBg: successBg ?? this.successBg,
      warningBg: warningBg ?? this.warningBg,
      errorBg: errorBg ?? this.errorBg,
      infoBg: infoBg ?? this.infoBg,
    );
  }

  @override
  AppColorsExtension lerp(AppColorsExtension? other, double t) {
    if (other is! AppColorsExtension) return this;
    return AppColorsExtension(
      lime: Color.lerp(lime, other.lime, t)!,
      limeMuted: Color.lerp(limeMuted, other.limeMuted, t)!,
      limeGlow: Color.lerp(limeGlow, other.limeGlow, t)!,
      coral: Color.lerp(coral, other.coral, t)!,
      coralMuted: Color.lerp(coralMuted, other.coralMuted, t)!,
      cyan: Color.lerp(cyan, other.cyan, t)!,
      cyanMuted: Color.lerp(cyanMuted, other.cyanMuted, t)!,
      bgPrimary: Color.lerp(bgPrimary, other.bgPrimary, t)!,
      bgSecondary: Color.lerp(bgSecondary, other.bgSecondary, t)!,
      bgTertiary: Color.lerp(bgTertiary, other.bgTertiary, t)!,
      bgElevated: Color.lerp(bgElevated, other.bgElevated, t)!,
      bgOverlay: Color.lerp(bgOverlay, other.bgOverlay, t)!,
      surfaceCard: Color.lerp(surfaceCard, other.surfaceCard, t)!,
      surfaceCardHover: Color.lerp(surfaceCardHover, other.surfaceCardHover, t)!,
      surfaceCardBorder: Color.lerp(surfaceCardBorder, other.surfaceCardBorder, t)!,
      surfaceInput: Color.lerp(surfaceInput, other.surfaceInput, t)!,
      surfaceInputBorder: Color.lerp(surfaceInputBorder, other.surfaceInputBorder, t)!,
      surfaceInputFocus: Color.lerp(surfaceInputFocus, other.surfaceInputFocus, t)!,
      textPrimary: Color.lerp(textPrimary, other.textPrimary, t)!,
      textSecondary: Color.lerp(textSecondary, other.textSecondary, t)!,
      textTertiary: Color.lerp(textTertiary, other.textTertiary, t)!,
      textInverse: Color.lerp(textInverse, other.textInverse, t)!,
      textLink: Color.lerp(textLink, other.textLink, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      error: Color.lerp(error, other.error, t)!,
      info: Color.lerp(info, other.info, t)!,
      successBg: Color.lerp(successBg, other.successBg, t)!,
      warningBg: Color.lerp(warningBg, other.warningBg, t)!,
      errorBg: Color.lerp(errorBg, other.errorBg, t)!,
      infoBg: Color.lerp(infoBg, other.infoBg, t)!,
    );
  }
}
