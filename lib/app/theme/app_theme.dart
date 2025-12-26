import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'colors.dart';
import 'typography.dart';

/// Thryve App Theme
/// Provides light and dark theme configurations matching the website aesthetics
class ThryveTheme {
  ThryveTheme._();

  /// Light theme configuration
  static ThemeData get light {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      
      // Colors
      colorScheme: const ColorScheme.light(
        primary: ThryveColors.accent,
        onPrimary: Colors.white,
        primaryContainer: ThryveColors.accentLight,
        onPrimaryContainer: ThryveColors.textPrimary,
        secondary: ThryveColors.textSecondary,
        onSecondary: Colors.white,
        surface: ThryveColors.surface,
        onSurface: ThryveColors.textPrimary,
        error: ThryveColors.error,
        onError: Colors.white,
      ),
      
      scaffoldBackgroundColor: ThryveColors.background,
      
      // App Bar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: ThryveColors.background,
        foregroundColor: ThryveColors.textPrimary,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: ThryveTypography.displayFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ThryveColors.textPrimary,
        ),
      ),
      
      // Text Theme
      textTheme: _buildTextTheme(ThryveColors.textPrimary, ThryveColors.textSecondary),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThryveColors.surface,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ThryveColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ThryveColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ThryveColors.error, width: 2),
        ),
        hintStyle: ThryveTypography.bodyMedium.copyWith(
          color: ThryveColors.textTertiary,
        ),
        labelStyle: ThryveTypography.bodyMedium.copyWith(
          color: ThryveColors.textSecondary,
        ),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThryveColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: ThryveTypography.button,
        ),
      ),
      
      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ThryveColors.accent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: ThryveColors.accent, width: 1.5),
          textStyle: ThryveTypography.button,
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ThryveColors.accent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: ThryveTypography.button,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        color: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: ThryveColors.accent,
        unselectedItemColor: ThryveColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: ThryveTypography.labelSmall,
        unselectedLabelStyle: ThryveTypography.labelSmall,
      ),
      
      // Divider
      dividerTheme: const DividerThemeData(
        color: ThryveColors.divider,
        thickness: 1,
        space: 1,
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: ThryveColors.surface,
        selectedColor: ThryveColors.accentLight,
        labelStyle: ThryveTypography.labelMedium,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
      ),
      
      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ThryveColors.textPrimary,
        contentTextStyle: ThryveTypography.bodyMedium.copyWith(color: Colors.white),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Dark theme configuration
  static ThemeData get dark {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      
      // Colors
      colorScheme: const ColorScheme.dark(
        primary: ThryveColors.accent,
        onPrimary: Colors.white,
        primaryContainer: ThryveColors.accentDark,
        onPrimaryContainer: Colors.white,
        secondary: ThryveColors.textSecondaryDark,
        onSecondary: ThryveColors.backgroundDark,
        surface: ThryveColors.surfaceDark,
        onSurface: ThryveColors.textPrimaryDark,
        error: ThryveColors.error,
        onError: Colors.white,
      ),
      
      scaffoldBackgroundColor: ThryveColors.backgroundDark,
      
      // App Bar
      appBarTheme: const AppBarTheme(
        elevation: 0,
        scrolledUnderElevation: 0,
        backgroundColor: ThryveColors.backgroundDark,
        foregroundColor: ThryveColors.textPrimaryDark,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: ThryveTypography.displayFontFamily,
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: ThryveColors.textPrimaryDark,
        ),
      ),
      
      // Text Theme
      textTheme: _buildTextTheme(ThryveColors.textPrimaryDark, ThryveColors.textSecondaryDark),
      
      // Input Decoration
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: ThryveColors.surfaceDark,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ThryveColors.accent, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ThryveColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: ThryveColors.error, width: 2),
        ),
        hintStyle: ThryveTypography.bodyMedium.copyWith(
          color: ThryveColors.textSecondaryDark,
        ),
        labelStyle: ThryveTypography.bodyMedium.copyWith(
          color: ThryveColors.textSecondaryDark,
        ),
      ),
      
      // Elevated Button
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: ThryveColors.accent,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: ThryveTypography.button,
        ),
      ),
      
      // Outlined Button
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: ThryveColors.accent,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          side: const BorderSide(color: ThryveColors.accent, width: 1.5),
          textStyle: ThryveTypography.button,
        ),
      ),
      
      // Text Button
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: ThryveColors.accent,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          textStyle: ThryveTypography.button,
        ),
      ),
      
      // Card
      cardTheme: CardThemeData(
        elevation: 0,
        color: ThryveColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        margin: EdgeInsets.zero,
      ),
      
      // Bottom Navigation Bar
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: ThryveColors.surfaceDark,
        selectedItemColor: ThryveColors.accent,
        unselectedItemColor: ThryveColors.textSecondaryDark,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
        selectedLabelStyle: ThryveTypography.labelSmall,
        unselectedLabelStyle: ThryveTypography.labelSmall,
      ),
      
      // Divider
      dividerTheme: DividerThemeData(
        color: ThryveColors.surfaceElevatedDark,
        thickness: 1,
        space: 1,
      ),
      
      // Chip
      chipTheme: ChipThemeData(
        backgroundColor: ThryveColors.surfaceElevatedDark,
        selectedColor: ThryveColors.accentDark,
        labelStyle: ThryveTypography.labelMedium.copyWith(
          color: ThryveColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        side: BorderSide.none,
      ),
      
      // Bottom Sheet
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: ThryveColors.surfaceDark,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      
      // Snackbar
      snackBarTheme: SnackBarThemeData(
        backgroundColor: ThryveColors.surfaceElevatedDark,
        contentTextStyle: ThryveTypography.bodyMedium.copyWith(
          color: ThryveColors.textPrimaryDark,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  /// Build text theme with given colors
  static TextTheme _buildTextTheme(Color primaryColor, Color secondaryColor) {
    return TextTheme(
      displayLarge: ThryveTypography.displayLarge.copyWith(color: primaryColor),
      displayMedium: ThryveTypography.displayMedium.copyWith(color: primaryColor),
      displaySmall: ThryveTypography.displaySmall.copyWith(color: primaryColor),
      headlineLarge: ThryveTypography.headlineLarge.copyWith(color: primaryColor),
      headlineMedium: ThryveTypography.headlineMedium.copyWith(color: primaryColor),
      headlineSmall: ThryveTypography.headlineSmall.copyWith(color: primaryColor),
      titleLarge: ThryveTypography.titleLarge.copyWith(color: primaryColor),
      titleMedium: ThryveTypography.titleMedium.copyWith(color: primaryColor),
      titleSmall: ThryveTypography.titleSmall.copyWith(color: primaryColor),
      bodyLarge: ThryveTypography.bodyLarge.copyWith(color: primaryColor),
      bodyMedium: ThryveTypography.bodyMedium.copyWith(color: primaryColor),
      bodySmall: ThryveTypography.bodySmall.copyWith(color: secondaryColor),
      labelLarge: ThryveTypography.labelLarge.copyWith(color: primaryColor),
      labelMedium: ThryveTypography.labelMedium.copyWith(color: secondaryColor),
      labelSmall: ThryveTypography.labelSmall.copyWith(color: secondaryColor),
    );
  }
}
