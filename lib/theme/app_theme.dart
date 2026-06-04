import 'package:flutter/material.dart';

import 'app_colors.dart';
import 'app_text_styles.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get dark {
    const colorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      error: AppColors.danger,
      surface: AppColors.darkSurface,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: AppColors.darkText,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      mutedTextColor: AppColors.darkMutedText,
      navigationBackground: AppColors.darkSurface,
      outlineColor: AppColors.darkSurfaceHigh,
    );
  }

  static ThemeData get light {
    const colorScheme = ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.secondary,
      tertiary: AppColors.accent,
      error: AppColors.danger,
      surface: AppColors.lightSurface,
      onPrimary: Colors.black,
      onSecondary: Colors.white,
      onSurface: AppColors.lightText,
    );

    return _buildTheme(
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.lightBackground,
      mutedTextColor: AppColors.lightMutedText,
      navigationBackground: AppColors.lightSurface,
      outlineColor: AppColors.lightSurfaceHigh,
    );
  }

  static ThemeData _buildTheme({
    required ColorScheme colorScheme,
    required Color scaffoldBackgroundColor,
    required Color mutedTextColor,
    required Color navigationBackground,
    required Color outlineColor,
  }) {
    final textTheme = TextTheme(
      displaySmall: AppTextStyles.display.copyWith(
        color: colorScheme.onSurface,
      ),
      titleLarge: AppTextStyles.title.copyWith(color: colorScheme.onSurface),
      bodyLarge: AppTextStyles.body.copyWith(color: colorScheme.onSurface),
      bodyMedium: AppTextStyles.body.copyWith(
        color: mutedTextColor,
        fontSize: 14,
      ),
      labelLarge: AppTextStyles.label.copyWith(color: colorScheme.onSurface),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: colorScheme.brightness,
      colorScheme: colorScheme,
      fontFamily: AppTextStyles.fontFamily,
      scaffoldBackgroundColor: scaffoldBackgroundColor,
      textTheme: textTheme,
      splashColor: colorScheme.primary.withValues(alpha: 0.08),
      highlightColor: colorScheme.secondary.withValues(alpha: 0.06),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: colorScheme.onSurface,
          highlightColor: colorScheme.primary.withValues(alpha: 0.12),
        ),
      ),
      appBarTheme: AppBarTheme(
        centerTitle: false,
        elevation: 0,
        backgroundColor: scaffoldBackgroundColor,
        foregroundColor: colorScheme.onSurface,
        titleTextStyle: AppTextStyles.title.copyWith(
          color: colorScheme.onSurface,
          fontWeight: FontWeight.w900,
        ),
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        color: colorScheme.surface,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: outlineColor),
        ),
      ),
      dropdownMenuTheme: DropdownMenuThemeData(
        textStyle: AppTextStyles.body.copyWith(color: colorScheme.onSurface),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgBase,
        hintStyle: AppTextStyles.body.copyWith(color: mutedTextColor),
        labelStyle: AppTextStyles.label.copyWith(color: mutedTextColor),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(
            color: colorScheme.primary.withValues(alpha: 0.22),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide(color: colorScheme.primary),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: navigationBackground,
        elevation: 0,
        indicatorColor: colorScheme.primary.withValues(alpha: 0.16),
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return AppTextStyles.label.copyWith(
            color: isSelected ? colorScheme.primary : mutedTextColor,
          );
        }),
        iconTheme: WidgetStateProperty.resolveWith((states) {
          final isSelected = states.contains(WidgetState.selected);
          return IconThemeData(
            color: isSelected ? colorScheme.primary : mutedTextColor,
            size: 22,
          );
        }),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: colorScheme.primary,
          foregroundColor: colorScheme.onPrimary,
          textStyle: AppTextStyles.label.copyWith(fontWeight: FontWeight.w900),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        ),
      ),
    );
  }
}
