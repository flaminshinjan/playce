import 'package:flutter/material.dart';

/// Main color palette for the app
class AppColors {
  // Primary colors - yellow accent on dark background
  static const Color primary = Color(0xFFF9E857);      // Bright yellow
  static const Color primaryVariant = Color(0xFFE5D648); // Slightly darker yellow
  static const Color secondary = Color(0xFFF9E857);    // Same yellow for secondary
  static const Color secondaryVariant = Color(0xFFE5D648);

  // Background colors - dark theme
  static const Color background = Color(0xFF121212);   // Very dark gray/black
  static const Color surface = Color(0xFF1E1E1E);      // Slightly lighter dark gray
  static const Color cardBackground = Color(0xFF252525); // Card background
  static const Color error = Color(0xFFCF6679);        // Red error color for dark theme

  // Text colors
  static const Color textPrimary = Colors.white;       // White text on dark background
  static const Color textSecondary = Color(0xFFB8B8B8); // Light gray secondary text
  static const Color textHint = Color(0xFF8A8A8A);      // Darker gray hint text
  
  // Button colors
  static const Color buttonText = Color(0xFF121212);   // Dark text on yellow buttons

  // Other common colors
  static const Color divider = Color(0xFF3A3A3A);      // Dark divider
  static const Color success = Color(0xFF4CAF50);      // Green
  static const Color warning = Color(0xFFFFC107);      // Amber
  static const Color info = Color(0xFF2196F3);         // Blue
}

/// Text styles for the app
class AppTextStyles {
  static const TextStyle headline1 = TextStyle(
    fontSize: 30,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headline2 = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle headline3 = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.bold,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyText1 = TextStyle(
    fontSize: 16,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle bodyText2 = TextStyle(
    fontSize: 14,
    color: AppColors.textPrimary,
  );
  
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    color: AppColors.textSecondary,
  );
  
  static const TextStyle button = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.bold,
    color: AppColors.buttonText,
  );
}

/// Theme data for the app
class AppTheme {
  static ThemeData get lightTheme {
    // Use dark theme as default since the reference design is dark
    return darkTheme;
  }

  static ThemeData get darkTheme {
    return ThemeData.dark().copyWith(
      primaryColor: AppColors.primary,
      scaffoldBackgroundColor: AppColors.background,
      canvasColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        primaryContainer: AppColors.primaryVariant,
        secondary: AppColors.secondary,
        secondaryContainer: AppColors.secondaryVariant,
        surface: AppColors.surface,
        background: AppColors.background,
        error: AppColors.error,
        onPrimary: AppColors.buttonText,
        onSecondary: AppColors.buttonText,
        onSurface: AppColors.textPrimary,
        onBackground: AppColors.textPrimary,
        onError: AppColors.textPrimary,
        brightness: Brightness.dark,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        elevation: 0,
        titleTextStyle: TextStyle(
          color: AppColors.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.bold,
        ),
        iconTheme: IconThemeData(
          color: AppColors.primary,
        ),
      ),
      textTheme: const TextTheme(
        headlineLarge: AppTextStyles.headline1,
        headlineMedium: AppTextStyles.headline2,
        headlineSmall: AppTextStyles.headline3,
        bodyLarge: AppTextStyles.bodyText1,
        bodyMedium: AppTextStyles.bodyText2,
        labelLarge: AppTextStyles.button,
        bodySmall: AppTextStyles.caption,
      ),
      buttonTheme: const ButtonThemeData(
        buttonColor: AppColors.primary,
        textTheme: ButtonTextTheme.primary,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.buttonText,
          textStyle: AppTextStyles.button,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
          padding: const EdgeInsets.symmetric(vertical: 16),
          elevation: 0,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: AppColors.primary,
          side: const BorderSide(color: AppColors.primary),
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(8.0),
          ),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: AppColors.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.surface,
        hintStyle: AppTextStyles.bodyText2.copyWith(color: AppColors.textHint),
        contentPadding: const EdgeInsets.all(16),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.primary, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 1),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: const BorderSide(color: AppColors.error, width: 2),
        ),
      ),
      cardTheme: CardTheme(
        color: AppColors.cardBackground,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.primary,
        unselectedItemColor: AppColors.textSecondary,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.divider,
        thickness: 1,
      ),
    );
  }
} 