import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get darkTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,

        // ── Scaffold & background ─────────────────────────────────────────
        scaffoldBackgroundColor: AppColors.darkBackground,

        // ── Color scheme ──────────────────────────────────────────────────
        colorScheme: const ColorScheme.dark(
          primary:          AppColors.primary,
          onPrimary:        Colors.white,
          secondary:        AppColors.neonAccent,
          onSecondary:      Colors.black,
          surface:          AppColors.darkCard,
          onSurface:        AppColors.darkTextPrimary,
          error:            AppColors.error,
          onError:          Colors.white,
        ),

        // ── AppBar ────────────────────────────────────────────────────────
        appBarTheme: const AppBarTheme(
          backgroundColor:  AppColors.darkBackground,
          foregroundColor:  AppColors.darkTextPrimary,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor:            Colors.transparent,
            statusBarIconBrightness:   Brightness.light,
            statusBarBrightness:       Brightness.dark,
          ),
        ),

        // ── Cards ─────────────────────────────────────────────────────────
        cardTheme: CardThemeData(
          color:     AppColors.darkCard,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: AppColors.darkBorder, width: 1),
          ),
        ),

        // ── Bottom navigation (legacy) ────────────────────────────────────
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor:      Color(0xFF0A1A0A),
          selectedItemColor:    AppColors.primary,
          unselectedItemColor:  AppColors.darkTextSecondary,
          type:                 BottomNavigationBarType.fixed,
          elevation:            0,
        ),

        // ── Navigation bar (Material 3) ───────────────────────────────────
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor:      const Color(0xFF0A1A0A),
          indicatorColor:       AppColors.primary.withValues(alpha: 0.20),
          surfaceTintColor:     Colors.transparent,
          shadowColor:          Colors.transparent,
          elevation:            0,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: Colors.white, size: 24);
            }
            return const IconThemeData(color: Colors.white70, size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                  color: Colors.white,
                  fontSize: 11,
                  fontWeight: FontWeight.w700);
            }
            return const TextStyle(
                color: Colors.white70,
                fontSize: 11,
                fontWeight: FontWeight.w500);
          }),
        ),

        // ── Divider ───────────────────────────────────────────────────────
        dividerColor:  AppColors.darkDivider,
        dividerTheme: const DividerThemeData(
          color:     AppColors.darkDivider,
          thickness: 1,
        ),

        // ── Elevated button ───────────────────────────────────────────────
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDeep,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // ── Outlined button ───────────────────────────────────────────────
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primary,
            side: const BorderSide(color: AppColors.primary),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
        ),

        // ── Text fields ───────────────────────────────────────────────────
        inputDecorationTheme: InputDecorationTheme(
          fillColor:  AppColors.darkCard,
          filled:     true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.darkBorder),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: AppColors.primary, width: 2),
          ),
          labelStyle: const TextStyle(color: AppColors.darkTextSecondary),
          hintStyle:  const TextStyle(color: AppColors.darkTextMuted),
          prefixStyle: const TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w600),
          suffixStyle: const TextStyle(
              color: AppColors.primary, fontWeight: FontWeight.w600),
        ),

        // ── Switch ────────────────────────────────────────────────────────
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.primary
                : AppColors.darkTextMuted,
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.primary.withValues(alpha: 0.4)
                : AppColors.darkBorder,
          ),
        ),

        // ── List tiles ────────────────────────────────────────────────────
        listTileTheme: const ListTileThemeData(
          tileColor:  Colors.transparent,
          textColor:  AppColors.darkTextPrimary,
          iconColor:  AppColors.primary,
        ),

        // ── Snack bar ─────────────────────────────────────────────────────
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.darkCardElevated,
          contentTextStyle: const TextStyle(color: AppColors.darkTextPrimary),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),

        // ── Dialog ────────────────────────────────────────────────────────
        dialogTheme: DialogThemeData(
          backgroundColor: AppColors.darkCardElevated,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          titleTextStyle: const TextStyle(
              color: AppColors.darkTextPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold),
          contentTextStyle:
              const TextStyle(color: AppColors.darkTextSecondary, fontSize: 14),
        ),

        // ── Text ──────────────────────────────────────────────────────────
        textTheme: const TextTheme(
          bodyLarge:   TextStyle(color: AppColors.darkTextPrimary),
          bodyMedium:  TextStyle(color: AppColors.darkTextPrimary),
          bodySmall:   TextStyle(color: AppColors.darkTextSecondary),
          titleLarge:  TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.bold),
          titleMedium: TextStyle(color: AppColors.darkTextPrimary, fontWeight: FontWeight.w600),
          labelSmall:  TextStyle(color: AppColors.darkTextSecondary),
        ),

        // ── Icon ──────────────────────────────────────────────────────────
        iconTheme: const IconThemeData(color: AppColors.primary),
      );

  static ThemeData get lightTheme => ThemeData(
        useMaterial3: true,
        brightness: Brightness.light,
        scaffoldBackgroundColor: const Color(0xFFF1F8F1),
        colorScheme: const ColorScheme.light(
          primary:     AppColors.primaryDeep,
          onPrimary:   Colors.white,
          secondary:   AppColors.primary,
          onSecondary: Colors.white,
          surface:     Colors.white,
          onSurface:   Color(0xFF1A2E1A),
          error:       AppColors.error,
          onError:     Colors.white,
        ),
        appBarTheme: const AppBarTheme(
          backgroundColor: AppColors.primaryDeep,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: true,
          systemOverlayStyle: SystemUiOverlayStyle(
            statusBarColor:          Colors.transparent,
            statusBarIconBrightness: Brightness.light,
            statusBarBrightness:     Brightness.dark,
          ),
        ),
        cardTheme: CardThemeData(
          color:     Colors.white,
          elevation: 0,
          shadowColor: Colors.transparent,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
            side: const BorderSide(color: Color(0xFFD0E8D0), width: 1),
          ),
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor:     Colors.white,
          selectedItemColor:   AppColors.primaryDeep,
          unselectedItemColor: Color(0xFF7A9E7A),
          type:                BottomNavigationBarType.fixed,
          elevation:           0,
        ),
        navigationBarTheme: NavigationBarThemeData(
          backgroundColor:  Colors.white,
          indicatorColor:   AppColors.primaryDeep.withValues(alpha: 0.15),
          surfaceTintColor: Colors.transparent,
          shadowColor:      Colors.transparent,
          elevation:        0,
          iconTheme: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const IconThemeData(color: AppColors.primaryDeep, size: 24);
            }
            return const IconThemeData(color: Color(0xFF7A9E7A), size: 24);
          }),
          labelTextStyle: WidgetStateProperty.resolveWith((states) {
            if (states.contains(WidgetState.selected)) {
              return const TextStyle(
                  color: AppColors.primaryDeep,
                  fontSize: 11,
                  fontWeight: FontWeight.w700);
            }
            return const TextStyle(
                color: Color(0xFF7A9E7A),
                fontSize: 11,
                fontWeight: FontWeight.w500);
          }),
        ),
        dividerColor: const Color(0xFFD0E8D0),
        dividerTheme: const DividerThemeData(
          color: Color(0xFFD0E8D0), thickness: 1),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColors.primaryDeep,
            foregroundColor: Colors.white,
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        outlinedButtonTheme: OutlinedButtonThemeData(
          style: OutlinedButton.styleFrom(
            foregroundColor: AppColors.primaryDeep,
            side: const BorderSide(color: AppColors.primaryDeep),
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          fillColor: const Color(0xFFF1F8F1),
          filled:    true,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD0E8D0)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide: const BorderSide(color: Color(0xFFD0E8D0)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(12),
            borderSide:
                const BorderSide(color: AppColors.primaryDeep, width: 2),
          ),
          labelStyle: const TextStyle(color: Color(0xFF4A6B4A)),
          hintStyle:  const TextStyle(color: Color(0xFF7A9E7A)),
        ),
        switchTheme: SwitchThemeData(
          thumbColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.primaryDeep
                : const Color(0xFFB0C8B0),
          ),
          trackColor: WidgetStateProperty.resolveWith(
            (s) => s.contains(WidgetState.selected)
                ? AppColors.primaryDeep.withValues(alpha: 0.4)
                : const Color(0xFFD0E8D0),
          ),
        ),
        listTileTheme: const ListTileThemeData(
          tileColor:  Colors.transparent,
          textColor:  Color(0xFF1A2E1A),
          iconColor:  AppColors.primaryDeep,
        ),
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppColors.primaryDeep,
          contentTextStyle: const TextStyle(color: Colors.white),
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12)),
          behavior: SnackBarBehavior.floating,
        ),
        dialogTheme: DialogThemeData(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20)),
          titleTextStyle: const TextStyle(
              color: Color(0xFF1A2E1A),
              fontSize: 18,
              fontWeight: FontWeight.bold),
          contentTextStyle: const TextStyle(
              color: Color(0xFF4A6B4A), fontSize: 14),
        ),
        textTheme: const TextTheme(
          bodyLarge:   TextStyle(color: Color(0xFF1A2E1A)),
          bodyMedium:  TextStyle(color: Color(0xFF1A2E1A)),
          bodySmall:   TextStyle(color: Color(0xFF4A6B4A)),
          titleLarge:  TextStyle(
              color: Color(0xFF1A2E1A), fontWeight: FontWeight.bold),
          titleMedium: TextStyle(
              color: Color(0xFF1A2E1A), fontWeight: FontWeight.w600),
          labelSmall:  TextStyle(color: Color(0xFF4A6B4A)),
        ),
        iconTheme: const IconThemeData(color: AppColors.primaryDeep),
      );
}
