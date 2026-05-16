import 'package:flutter/material.dart';
import 'package:paddy_scan/core/constants/enums.dart';

class AppColors {
  AppColors._();

  // ── Dark Palette (Splash Screen Inspired) ──────────────────────────────────
  static const Color darkBackground    = Color(0xFF060E06); // main scaffold bg
  static const Color darkCard          = Color(0xFF0D1A0D); // card / section bg
  static const Color darkCardElevated  = Color(0xFF122412); // modal / elevated
  static const Color darkBorder        = Color(0xFF1B3D1B); // subtle border
  static const Color darkDivider       = Color(0xFF1A2E1A); // dividers
  static const Color darkTextPrimary   = Colors.white;       // primary text
  static const Color darkTextSecondary = Color(0xFF81C784); // soft green text
  static const Color darkTextMuted     = Color(0xFF4A6B4A); // muted hints

  // ── Brand Greens ───────────────────────────────────────────────────────────
  static const Color primary       = Color(0xFF4CAF50); // bright green (dark bg)
  static const Color primaryDeep   = Color(0xFF2E7D32); // deep forest (buttons)
  static const Color primaryLight  = Color(0xFF81C784); // soft green
  static const Color neonAccent    = Color(0xFF00E676); // glow / highlight
  static const Color primarySubtle = Color(0xFF0D2B0D); // subtle bg tint

  // ── Mode Colors ────────────────────────────────────────────────────────────
  static const Color classify = Color(0xFF42A5F5); // lighter blue for dark bg
  static const Color detect   = Color(0xFFFF9800); // orange
  static const Color diagnose = Color(0xFFAB47BC); // purple

  // ── Semantic ───────────────────────────────────────────────────────────────
  static const Color success = Color(0xFF4CAF50);
  static const Color error   = Color(0xFFEF5350);
  static const Color warning = Color(0xFFFFB300);
  static const Color info    = Color(0xFF29B6F6);

  // ── Confidence Colors ──────────────────────────────────────────────────────
  static const Color highConfidence   = Color(0xFF4CAF50);
  static const Color mediumConfidence = Color(0xFFFFB300);
  static const Color lowConfidence    = Color(0xFFEF5350);

  // ── Surface alias (used by result_page, theme, etc.) ──────────────────────
  static const Color surface        = darkBackground;
  static const Color cardBackground = darkCard;

  // ── Shadows ────────────────────────────────────────────────────────────────
  static List<BoxShadow> softShadow = [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.25),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];

  // ── Gradients ──────────────────────────────────────────────────────────────
  static const LinearGradient brandGradient = LinearGradient(
    colors: [Color(0xFF1B5E20), Color(0xFF4CAF50)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Utility Methods ────────────────────────────────────────────────────────
  static Color getModeColor(AnalysisMode mode) {
    switch (mode) {
      case AnalysisMode.classify: return classify;
      case AnalysisMode.detect:   return detect;
      case AnalysisMode.diagnose: return diagnose;
    }
  }

  static Color getConfidenceColor(double confidence) {
    if (confidence >= 0.8) return highConfidence;
    if (confidence >= 0.5) return mediumConfidence;
    return lowConfidence;
  }

  static Color getSeverityColor(dynamic severity) {
    if (severity is DetectionSeverity) {
      switch (severity) {
        case DetectionSeverity.minimal:  return success;
        case DetectionSeverity.mild:     return warning;
        case DetectionSeverity.moderate: return detect;
        case DetectionSeverity.severe:   return error;
      }
    }
    final s = severity.toString().toLowerCase();
    if (s.contains('severe')) return error;
    if (s.contains('mod'))    return warning;
    return success;
  }

  static Color glassBackground(Color base) =>
      base.withValues(alpha: 0.12);

  // ── Legacy aliases (used by result_page, enums, etc.) ─────────────────────
  static const Color white           = darkTextPrimary;  // white text/icon
  static const Color textHigh        = darkTextPrimary;  // high-emphasis text
  static const Color textMedium      = darkTextSecondary; // medium-emphasis text
  static const Color secondaryOrange = warning;          // moderate severity

  // ── Light palette constants ────────────────────────────────────────────────
  static const Color lightBackground   = Color(0xFFF1F8F1);
  static const Color lightCard         = Colors.white;
  static const Color lightCardElevated = Color(0xFFF8FDF8);
  static const Color lightBorder       = Color(0xFFD0E8D0);
  static const Color lightDivider      = Color(0xFFD0E8D0);
  static const Color lightTextPrimary  = Color(0xFF1A2E1A);
  static const Color lightTextSecondary= Color(0xFF4A6B4A);
  static const Color lightTextMuted    = Color(0xFF7A9E7A);
}
