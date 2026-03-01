import 'package:flutter/material.dart';

abstract class AppColors {
  // ── Brand ────────────────────────────────────────────────────
  static const lime = Color(0xFFBDFF3A);
  static const limeMuted = Color(0xFF9AD42A);
  static const limeGlow = Color(0x26BDFF3A); // 15% opacity
  static const coral = Color(0xFFFF6B6B);
  static const coralMuted = Color(0xFFE85555);
  static const cyan = Color(0xFF3ADFFF);
  static const cyanMuted = Color(0xFF2BB8D4);

  // ── Backgrounds (OLED dark stack) ────────────────────────────
  static const bgPrimary = Color(0xFF0A0A0C);
  static const bgSecondary = Color(0xFF111114);
  static const bgTertiary = Color(0xFF18181C);
  static const bgElevated = Color(0xFF1F1F24);
  static const bgOverlay = Color(0xD90A0A0C); // 85% opacity

  // ── Surfaces ─────────────────────────────────────────────────
  static const surfaceCard = Color(0xFF16161A);
  static const surfaceCardHover = Color(0xFF1C1C21);
  static const surfaceCardBorder = Color(0xFF2A2A30);
  static const surfaceInput = Color(0xFF111114);
  static const surfaceInputBorder = Color(0xFF2A2A30);
  static const surfaceInputFocus = lime;

  // ── Text ─────────────────────────────────────────────────────
  static const textPrimary = Color(0xFFF0F0F2);
  static const textSecondary = Color(0xFFA0A0A8);
  static const textTertiary = Color(0xFF6B6B75);
  static const textInverse = Color(0xFF0A0A0C);
  static const textLink = cyan;

  // ── Semantic ─────────────────────────────────────────────────
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const error = Color(0xFFF87171);
  static const info = Color(0xFF60A5FA);
  static const successBg = Color(0x1F34D399); // 12%
  static const warningBg = Color(0x1FFBBF24);
  static const errorBg = Color(0x1FF87171);
  static const infoBg = Color(0x1F60A5FA);

  // ── Macros (consistent across ALL charts) ────────────────────
  static const macroProtein = cyan;       // #3ADFFF
  static const macroCarbs = lime;         // #BDFF3A
  static const macroFat = coral;          // #FF6B6B
  static const macroFiber = Color(0xFFA78BFA);
  static const macroCalories = warning;   // #FBBF24

  // ── Gradients ────────────────────────────────────────────────
  static const limeGradient = LinearGradient(
    colors: [lime, limeMuted],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const darkGradient = LinearGradient(
    colors: [bgPrimary, bgSecondary],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );

  static const cardGradient = LinearGradient(
    colors: [surfaceCard, bgElevated],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
