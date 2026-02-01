// ============================================================================
// Everblush Theme - The complete theme data
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'everblush_colors.dart';

/// Creates the complete Everblush theme for the app.
class EverblushTheme {
  EverblushTheme._();

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: EverblushColors.background,
      colorScheme: const ColorScheme.dark(
        primary: EverblushColors.primary,
        secondary: EverblushColors.secondary,
        tertiary: EverblushColors.tertiary,
        error: EverblushColors.error,
        surface: EverblushColors.surface,
        onSurface: EverblushColors.textPrimary,
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: EverblushColors.background,
        foregroundColor: EverblushColors.textPrimary,
        elevation: 0,
      ),
      cardTheme: const CardThemeData(
        color: EverblushColors.surface,
        elevation: 0,
      ),
      dividerTheme: const DividerThemeData(
        color: EverblushColors.outline,
        thickness: 1,
      ),
      textTheme: const TextTheme(
        bodyLarge: TextStyle(color: EverblushColors.textPrimary),
        bodyMedium: TextStyle(color: EverblushColors.textSecondary),
        bodySmall: TextStyle(color: EverblushColors.textMuted),
      ),
    );
  }
}
