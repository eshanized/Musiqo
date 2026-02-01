// ============================================================================
// Decorations - Common BoxDecoration patterns
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'everblush_colors.dart';

/// Common decoration patterns used throughout the app.
class AppDecorations {
  AppDecorations._();

  /// Card decoration with subtle shadow
  static BoxDecoration get card => BoxDecoration(
    color: EverblushColors.surface,
    borderRadius: BorderRadius.circular(12),
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.2),
        blurRadius: 8,
        offset: const Offset(0, 2),
      ),
    ],
  );

  /// Gradient background for headers
  static BoxDecoration get gradientHeader => const BoxDecoration(
    gradient: LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [EverblushColors.surface, EverblushColors.background],
    ),
  );
}
