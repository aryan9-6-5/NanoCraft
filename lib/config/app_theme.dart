import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';
import 'app_spacing.dart';
import 'app_animations.dart';

/// Centralized theme definition for NanoCraft.
/// Provides both light and dark ThemeData with full Material 3 component theming.
/// All screens inherit this automatically — no ad-hoc styling needed.
abstract final class AppTheme {
  // ════════════════════════════════════════════════════════════════
  //  LIGHT THEME
  // ════════════════════════════════════════════════════════════════
  static ThemeData get lightTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandPrimary,
      brightness: Brightness.light,
      surface: AppColors.lightSurface,
      onSurface: AppColors.lightOnSurface,
      onSurfaceVariant: AppColors.lightOnSurfaceVariant,
      outline: AppColors.lightOutline,
      outlineVariant: AppColors.lightOutlineVariant,
      error: AppColors.error,
    );

    final textTheme = _buildTextTheme(Brightness.light);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.lightSurface,
      appBarTheme: _appBarTheme(Brightness.light),
      cardTheme: _cardTheme(Brightness.light),
      elevatedButtonTheme: _elevatedButtonTheme(Brightness.light),
      outlinedButtonTheme: _outlinedButtonTheme(Brightness.light),
      textButtonTheme: _textButtonTheme(Brightness.light),
      inputDecorationTheme: _inputDecorationTheme(Brightness.light),
      navigationBarTheme: _navigationBarTheme(Brightness.light),
      dialogTheme: _dialogTheme(Brightness.light),
      snackBarTheme: _snackBarTheme(Brightness.light),
      chipTheme: _chipTheme(Brightness.light),
      sliderTheme: _sliderTheme(Brightness.light),
      dividerTheme: _dividerTheme(Brightness.light),
      iconTheme: IconThemeData(color: AppColors.lightOnSurfaceVariant),
      pageTransitionsTheme: _pageTransitionsTheme,
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  DARK THEME
  // ════════════════════════════════════════════════════════════════
  static ThemeData get darkTheme {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.brandPrimary,
      brightness: Brightness.dark,
      surface: AppColors.darkSurface,
      onSurface: AppColors.darkOnSurface,
      onSurfaceVariant: AppColors.darkOnSurfaceVariant,
      outline: AppColors.darkOutline,
      outlineVariant: AppColors.darkOutlineVariant,
      error: AppColors.error,
    );

    final textTheme = _buildTextTheme(Brightness.dark);

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      textTheme: textTheme,
      scaffoldBackgroundColor: AppColors.darkSurface,
      appBarTheme: _appBarTheme(Brightness.dark),
      cardTheme: _cardTheme(Brightness.dark),
      elevatedButtonTheme: _elevatedButtonTheme(Brightness.dark),
      outlinedButtonTheme: _outlinedButtonTheme(Brightness.dark),
      textButtonTheme: _textButtonTheme(Brightness.dark),
      inputDecorationTheme: _inputDecorationTheme(Brightness.dark),
      navigationBarTheme: _navigationBarTheme(Brightness.dark),
      dialogTheme: _dialogTheme(Brightness.dark),
      snackBarTheme: _snackBarTheme(Brightness.dark),
      chipTheme: _chipTheme(Brightness.dark),
      sliderTheme: _sliderTheme(Brightness.dark),
      dividerTheme: _dividerTheme(Brightness.dark),
      iconTheme: IconThemeData(color: AppColors.darkOnSurfaceVariant),
      pageTransitionsTheme: _pageTransitionsTheme,
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  TEXT THEME
  // ════════════════════════════════════════════════════════════════
  static TextTheme _buildTextTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    final Color primary = isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary;
    final Color secondary = isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary;

    return GoogleFonts.interTextTheme(
      TextTheme(
        // Display
        displayLarge: TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.5),
        displayMedium: TextStyle(fontSize: 28, fontWeight: FontWeight.w700, color: primary, letterSpacing: -0.3),
        displaySmall: TextStyle(fontSize: 24, fontWeight: FontWeight.w600, color: primary),
        // Headline
        headlineLarge: TextStyle(fontSize: 22, fontWeight: FontWeight.w600, color: primary),
        headlineMedium: TextStyle(fontSize: 20, fontWeight: FontWeight.w600, color: primary),
        headlineSmall: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
        // Title
        titleLarge: TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: primary),
        titleMedium: TextStyle(fontSize: 16, fontWeight: FontWeight.w500, color: primary),
        titleSmall: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primary),
        // Body
        bodyLarge: TextStyle(fontSize: 16, fontWeight: FontWeight.w400, color: primary, height: 1.5),
        bodyMedium: TextStyle(fontSize: 14, fontWeight: FontWeight.w400, color: secondary, height: 1.5),
        bodySmall: TextStyle(fontSize: 12, fontWeight: FontWeight.w400, color: secondary, height: 1.4),
        // Label
        labelLarge: TextStyle(fontSize: 14, fontWeight: FontWeight.w500, color: primary),
        labelMedium: TextStyle(fontSize: 12, fontWeight: FontWeight.w500, color: secondary),
        labelSmall: TextStyle(fontSize: 11, fontWeight: FontWeight.w500, color: secondary, letterSpacing: 0.3),
      ),
    );
  }

  // ════════════════════════════════════════════════════════════════
  //  COMPONENT THEMES
  // ════════════════════════════════════════════════════════════════

  static AppBarTheme _appBarTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    return AppBarTheme(
      backgroundColor: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      foregroundColor: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
      elevation: 0,
      scrolledUnderElevation: 0.5,
      centerTitle: false,
      titleTextStyle: GoogleFonts.inter(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
    );
  }

  static CardThemeData _cardTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    return CardThemeData(
      color: isDark ? AppColors.darkSurfaceContainer : AppColors.lightSurfaceContainer,
      elevation: isDark ? AppSpacing.elevationNone : AppSpacing.elevationSm,
      shadowColor: Colors.black.withOpacity(0.08),
      surfaceTintColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusXl,
        side: BorderSide(
          color: isDark ? AppColors.darkOutlineVariant : AppColors.lightOutlineVariant,
          width: 0.5,
        ),
      ),
      margin: EdgeInsets.zero,
    );
  }

  static ElevatedButtonThemeData _elevatedButtonTheme(Brightness brightness) {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.brandPrimary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, AppSpacing.minTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w600),
      ).copyWith(
        elevation: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.pressed)) return 0;
          if (states.contains(WidgetState.hovered)) return 2;
          return 0;
        }),
      ),
    );
  }

  static OutlinedButtonThemeData _outlinedButtonTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    return OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: isDark ? AppColors.darkOnSurface : AppColors.lightOnSurface,
        minimumSize: const Size(double.infinity, AppSpacing.minTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        side: BorderSide(
          color: isDark ? AppColors.darkOutline : AppColors.lightOutline,
        ),
        textStyle: GoogleFonts.inter(fontSize: 15, fontWeight: FontWeight.w500),
      ),
    );
  }

  static TextButtonThemeData _textButtonTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    return TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.brandPrimary,
        minimumSize: const Size(AppSpacing.minTouchTarget, AppSpacing.minTouchTarget),
        padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md),
        shape: RoundedRectangleBorder(
          borderRadius: AppSpacing.borderRadiusMd,
        ),
        textStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w500),
      ),
    );
  }

  static InputDecorationTheme _inputDecorationTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    return InputDecorationTheme(
      filled: true,
      fillColor: isDark ? AppColors.darkSurfaceContainerHigh : AppColors.lightSurfaceContainerHigh,
      contentPadding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.md),
      border: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        borderSide: BorderSide(
          color: isDark ? AppColors.darkOutlineVariant : AppColors.lightOutlineVariant,
          width: 0.5,
        ),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        borderSide: const BorderSide(color: AppColors.brandPrimary, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: AppSpacing.borderRadiusMd,
        borderSide: const BorderSide(color: AppColors.error, width: 1.0),
      ),
      labelStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
      ),
      hintStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
      ),
    );
  }

  static NavigationBarThemeData _navigationBarTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    return NavigationBarThemeData(
      backgroundColor: isDark ? AppColors.darkSurfaceContainer : AppColors.lightSurfaceContainer,
      elevation: 0,
      height: 72,
      indicatorColor: AppColors.brandPrimary.withOpacity(isDark ? 0.15 : 0.12),
      indicatorShape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
      iconTheme: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return IconThemeData(
            color: isDark ? const Color(0xFF8B85FF) : AppColors.brandPrimary,
            size: 24,
          );
        }
        return IconThemeData(
          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
          size: 24,
        );
      }),
      labelTextStyle: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return GoogleFonts.inter(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: isDark ? const Color(0xFF8B85FF) : AppColors.brandPrimary,
          );
        }
        return GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w400,
          color: isDark ? AppColors.darkOnSurfaceVariant : AppColors.lightOnSurfaceVariant,
        );
      }),
    );
  }

  static DialogThemeData _dialogTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    return DialogThemeData(
      backgroundColor: isDark ? AppColors.darkSurfaceContainer : AppColors.lightSurfaceContainer,
      elevation: AppSpacing.elevationLg,
      shadowColor: Colors.black.withOpacity(0.15),
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusXl),
      titleTextStyle: GoogleFonts.inter(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
      contentTextStyle: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
        height: 1.5,
      ),
    );
  }

  static SnackBarThemeData _snackBarTheme(Brightness brightness) {
    return SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: AppSpacing.borderRadiusMd),
      elevation: AppSpacing.elevationMd,
      contentTextStyle: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400),
    );
  }

  static ChipThemeData _chipTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    return ChipThemeData(
      backgroundColor: isDark ? AppColors.darkSurfaceContainerHigh : AppColors.lightSurfaceContainerHigh,
      selectedColor: AppColors.brandPrimary.withOpacity(0.15),
      labelStyle: GoogleFonts.inter(
        fontSize: 13,
        fontWeight: FontWeight.w500,
        color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: AppSpacing.borderRadiusSm,
        side: BorderSide(
          color: isDark ? AppColors.darkOutlineVariant : AppColors.lightOutlineVariant,
          width: 0.5,
        ),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.sm, vertical: AppSpacing.xs),
    );
  }

  static SliderThemeData _sliderTheme(Brightness brightness) {
    return SliderThemeData(
      activeTrackColor: AppColors.brandPrimary,
      inactiveTrackColor: AppColors.brandPrimary.withOpacity(0.15),
      thumbColor: AppColors.brandPrimary,
      overlayColor: AppColors.brandPrimary.withOpacity(0.12),
      trackHeight: 4,
      thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 8),
    );
  }

  static DividerThemeData _dividerTheme(Brightness brightness) {
    final bool isDark = brightness == Brightness.dark;
    return DividerThemeData(
      color: isDark ? AppColors.darkOutlineVariant : AppColors.lightOutlineVariant,
      thickness: 0.5,
      space: AppSpacing.lg,
    );
  }

  static const PageTransitionsTheme _pageTransitionsTheme = PageTransitionsTheme(
    builders: {
      TargetPlatform.android: FadeUpwardsPageTransitionsBuilder(),
      TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
    },
  );
}
