import 'package:flutter/material.dart';
import 'color_tokens.dart';

/// Fortuna typography scale.
/// Extracted from the reference HTML Tailwind config.
class FortunaTextStyles {
  FortunaTextStyles._();

  static const String _fontFamily = 'Inter';

  static const TextStyle displayLarge = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 48,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.02,
    color: FortunaColors.onSurface,
    height: 56 / 48,
  );

  static const TextStyle headlineLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 32,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01,
    color: FortunaColors.onSurface,
    height: 40 / 32,
  );

  static const TextStyle headlineLgMobile = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 28,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.01,
    color: FortunaColors.onSurface,
    height: 36 / 28,
  );

  static const TextStyle numericDisplay = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: FortunaColors.onSurface,
    height: 32 / 24,
  );

  static const TextStyle titleMd = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 20,
    fontWeight: FontWeight.w600,
    color: FortunaColors.onSurface,
    height: 28 / 20,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: FortunaColors.onSurface,
    height: 24 / 16,
  );

  static const TextStyle bodySm = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: FortunaColors.onSurface,
    height: 20 / 14,
  );

  static const TextStyle labelCaps = TextStyle(
    fontFamily: _fontFamily,
    fontSize: 12,
    fontWeight: FontWeight.w700,
    letterSpacing: 0.05,
    color: FortunaColors.onSurface,
    height: 16 / 12,
  );
}
