import 'package:flutter/material.dart';
import 'app_colors.dart';

/// Context-aware color resolver.
/// Usage: `final tc = ThemeColors.of(context);`
/// Then use `tc.background`, `tc.card`, `tc.textPrimary`, etc.
class ThemeColors {
  final Color background;
  final Color card;
  final Color cardElevated;
  final Color border;
  final Color divider;
  final Color textPrimary;
  final Color textSecondary;
  final Color textMuted;
  final Color inputFill;
  final Color iconUnselected;
  final Color cardUnselected; // for unselected mode cards, nav, etc.
  final bool isDark;

  const ThemeColors._({
    required this.background,
    required this.card,
    required this.cardElevated,
    required this.border,
    required this.divider,
    required this.textPrimary,
    required this.textSecondary,
    required this.textMuted,
    required this.inputFill,
    required this.iconUnselected,
    required this.cardUnselected,
    required this.isDark,
  });

  static ThemeColors of(BuildContext context) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    return dark ? _dark : _light;
  }

  static const _dark = ThemeColors._(
    background: AppColors.darkBackground,
    card: AppColors.darkCard,
    cardElevated: AppColors.darkCardElevated,
    border: AppColors.darkBorder,
    divider: AppColors.darkDivider,
    textPrimary: AppColors.darkTextPrimary,
    textSecondary: AppColors.darkTextSecondary,
    textMuted: AppColors.darkTextMuted,
    inputFill: AppColors.darkBackground,
    iconUnselected: AppColors.darkTextSecondary,
    cardUnselected: AppColors.darkCard,
    isDark: true,
  );

  static const _light = ThemeColors._(
    background: AppColors.lightBackground,
    card: AppColors.lightCard,
    cardElevated: AppColors.lightCardElevated,
    border: AppColors.lightBorder,
    divider: AppColors.lightDivider,
    textPrimary: Color.fromARGB(255, 39, 68, 39),
    textSecondary: AppColors.lightTextSecondary,
    textMuted: AppColors.lightTextMuted,
    inputFill: AppColors.lightBackground,
    iconUnselected: AppColors.lightTextSecondary,
    cardUnselected: Color(0xFFEEF5EE),
    isDark: false,
  );
}
