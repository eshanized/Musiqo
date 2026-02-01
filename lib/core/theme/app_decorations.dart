// ============================================================================
// App Decorations - BoxDecorations, gradients, shadows
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// Reusable decorations to keep our UI consistent.
// Instead of defining gradients everywhere, we define them once here.
// ============================================================================

import 'package:flutter/material.dart';
import 'everblush_colors.dart';

/// Common decorations used throughout the app
class AppDecorations {
  AppDecorations._();

  // ===========================================
  // Gradients
  // Gradients add depth and visual interest
  // ===========================================

  /// Fade from background to transparent (bottom to top)
  /// Perfect for overlaying on album art
  static const LinearGradient fadeUp = LinearGradient(
    begin: Alignment.bottomCenter,
    end: Alignment.topCenter,
    colors: [
      EverblushColors.background,
      Colors.transparent,
    ],
  );

  /// Fade from transparent to background (top to bottom)
  static const LinearGradient fadeDown = LinearGradient(
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
    colors: [
      Colors.transparent,
      EverblushColors.background,
    ],
  );

  /// A subtle glow effect for the player
  static LinearGradient playerGlow(Color albumColor) {
    return LinearGradient(
      begin: Alignment.topCenter,
      end: Alignment.bottomCenter,
      colors: [
        albumColor.withValues(alpha: 0.3),
        EverblushColors.background,
      ],
      stops: const [0.0, 0.6],
    );
  }

  // ===========================================
  // Box Decorations
  // ===========================================

  /// Card-like container with rounded corners
  static BoxDecoration get card => BoxDecoration(
    color: EverblushColors.surface,
    borderRadius: BorderRadius.circular(12),
  );

  /// Card with a subtle border
  static BoxDecoration get cardOutlined => BoxDecoration(
    color: EverblushColors.surface,
    borderRadius: BorderRadius.circular(12),
    border: Border.all(
      color: EverblushColors.outline,
      width: 0.5,
    ),
  );

  /// Circular container (for profile pics, play buttons)
  static BoxDecoration circle(Color color) => BoxDecoration(
    color: color,
    shape: BoxShape.circle,
  );

  /// The mini player container
  static BoxDecoration get miniPlayer => BoxDecoration(
    color: EverblushColors.surface,
    boxShadow: [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.3),
        blurRadius: 10,
        offset: const Offset(0, -2),
      ),
    ],
  );

  // ===========================================
  // Shadows
  // Subtle shadows add depth
  // ===========================================

  /// Soft shadow for cards
  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: Colors.black.withValues(alpha: 0.2),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];

  /// Glow effect (like a neon sign)
  static List<BoxShadow> glow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.4),
      blurRadius: 20,
      spreadRadius: 2,
    ),
  ];
}
