// ============================================================================
// App Theme - The complete Material 3 theme for Musiqo
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// This file creates the full theme by combining our Everblush colors
// with Flutter's Material 3 design system.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'everblush_colors.dart';

/// Creates the complete app theme.
///
/// WHAT IS A THEME?
/// Think of it as a "skin" for your app. It defines colors, fonts,
/// button styles, and more - all in one place. This way, you don't
/// have to specify colors every time you create a widget.
class AppTheme {
  // Private constructor - this class is just for holding theme data
  AppTheme._();

  // Our custom font - Poppins looks modern and clean
  static const String _fontFamily = 'Poppins';

  /// The main dark theme for Musiqo
  /// We call this from main.dart when setting up MaterialApp
  static ThemeData get darkTheme {
    // ColorScheme is like a "palette" that Flutter uses automatically
    // When you use Theme.of(context).colorScheme.primary, it picks from here
    final colorScheme = ColorScheme(
      brightness: Brightness.dark,

      // Main colors
      primary: EverblushColors.primary,
      onPrimary: EverblushColors.background, // text ON primary color
      secondary: EverblushColors.secondary,
      onSecondary: EverblushColors.background,
      tertiary: EverblushColors.tertiary,
      onTertiary: EverblushColors.background,

      // Error states
      error: EverblushColors.error,
      onError: EverblushColors.background,

      // Surfaces (cards, sheets, dialogs)
      surface: EverblushColors.surface,
      onSurface: EverblushColors.textPrimary,
      surfaceContainerHighest: EverblushColors.surfaceVariant,

      // Outline for borders
      outline: EverblushColors.outline,
      outlineVariant: EverblushColors.outline.withValues(alpha: 0.5),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      fontFamily: _fontFamily,

      // The scaffold is the base widget that provides background
      scaffoldBackgroundColor: EverblushColors.background,

      // AppBar styling - that top bar with the title
      appBarTheme: const AppBarTheme(
        backgroundColor: EverblushColors.background,
        foregroundColor: EverblushColors.textPrimary,
        elevation: 0, // flat, no shadow
        centerTitle: true,
        systemOverlayStyle: SystemUiOverlayStyle(
          statusBarColor: Colors.transparent,
          statusBarIconBrightness: Brightness.light,
        ),
      ),

      // Bottom navigation bar (Home, Search, Library tabs)
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: EverblushColors.surface,
        selectedItemColor: EverblushColors.primary,
        unselectedItemColor: EverblushColors.textMuted,
        type: BottomNavigationBarType.fixed,
        elevation: 8,
      ),

      // Card styling for song tiles, album cards, etc.
      cardTheme: CardThemeData(
        color: EverblushColors.surface,
        elevation: 0,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),

      // Icon colors
      iconTheme: const IconThemeData(
        color: EverblushColors.textSecondary,
        size: 24,
      ),

      // Text styles
      textTheme: _buildTextTheme(),

      // Buttons!
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: EverblushColors.primary,
          foregroundColor: EverblushColors.background,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(24),
          ),
        ),
      ),

      // Text buttons (like "See All")
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: EverblushColors.primary),
      ),

      // Icon buttons (play, pause, etc.)
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: EverblushColors.textPrimary,
        ),
      ),

      // Slider for progress bar
      sliderTheme: SliderThemeData(
        activeTrackColor: EverblushColors.primary,
        inactiveTrackColor: EverblushColors.outline,
        thumbColor: EverblushColors.primary,
        overlayColor: EverblushColors.primary.withValues(alpha: 0.2),
        trackHeight: 4,
      ),

      // Bottom sheet (player, queue)
      bottomSheetTheme: const BottomSheetThemeData(
        backgroundColor: EverblushColors.surface,
        modalBackgroundColor: EverblushColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
      ),

      // Dialogs
      dialogTheme: DialogThemeData(
        backgroundColor: EverblushColors.surfaceVariant,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      ),

      // Snackbars (those little messages at the bottom)
      snackBarTheme: SnackBarThemeData(
        backgroundColor: EverblushColors.surfaceVariant,
        contentTextStyle: const TextStyle(color: EverblushColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        behavior: SnackBarBehavior.floating,
      ),

      // Dividers between list items
      dividerTheme: const DividerThemeData(
        color: EverblushColors.outline,
        thickness: 0.5,
        space: 0,
      ),

      // List tiles
      listTileTheme: const ListTileThemeData(
        iconColor: EverblushColors.textSecondary,
        textColor: EverblushColors.textPrimary,
      ),

      // Switch toggle
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return EverblushColors.primary;
          }
          return EverblushColors.textMuted;
        }),
        trackColor: WidgetStateProperty.resolveWith((states) {
          if (states.contains(WidgetState.selected)) {
            return EverblushColors.primary.withValues(alpha: 0.5);
          }
          return EverblushColors.outline;
        }),
      ),

      // Progress indicator (loading spinner)
      progressIndicatorTheme: const ProgressIndicatorThemeData(
        color: EverblushColors.primary,
      ),
    );
  }

  /// Build our text styles
  ///
  /// Flutter has different text "roles" like headline, title, body, label
  /// Each role has large, medium, and small variants
  static TextTheme _buildTextTheme() {
    return const TextTheme(
      // Headlines - for big, prominent text
      headlineLarge: TextStyle(
        fontSize: 32,
        fontWeight: FontWeight.bold,
        color: EverblushColors.textPrimary,
        letterSpacing: -0.5,
      ),
      headlineMedium: TextStyle(
        fontSize: 28,
        fontWeight: FontWeight.bold,
        color: EverblushColors.textPrimary,
      ),
      headlineSmall: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w600,
        color: EverblushColors.textPrimary,
      ),

      // Titles - for section headers
      titleLarge: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: EverblushColors.textPrimary,
      ),
      titleMedium: TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: EverblushColors.textPrimary,
      ),
      titleSmall: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: EverblushColors.textPrimary,
      ),

      // Body - for regular content
      bodyLarge: TextStyle(fontSize: 16, color: EverblushColors.textPrimary),
      bodyMedium: TextStyle(fontSize: 14, color: EverblushColors.textSecondary),
      bodySmall: TextStyle(fontSize: 12, color: EverblushColors.textMuted),

      // Labels - for buttons, chips, etc.
      labelLarge: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w500,
        color: EverblushColors.textPrimary,
      ),
      labelMedium: TextStyle(
        fontSize: 12,
        fontWeight: FontWeight.w500,
        color: EverblushColors.textSecondary,
      ),
      labelSmall: TextStyle(
        fontSize: 10,
        fontWeight: FontWeight.w500,
        color: EverblushColors.textMuted,
        letterSpacing: 0.5,
      ),
    );
  }
}
