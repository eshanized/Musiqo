// ============================================================================
// Everblush Color Palette for Musiqo
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// This file contains the beautiful Everblush dark theme colors.
// Everblush is a popular color scheme loved by developers and designers
// for its vibrant yet easy-on-the-eyes aesthetic.
// ============================================================================

import 'package:flutter/material.dart';

/// The Everblush color palette - a dark, vibrant theme
/// that's easy on the eyes during long listening sessions.
///
/// Why Everblush?
/// - Deep dark backgrounds reduce eye strain
/// - Vibrant accent colors make the UI pop
/// - Great contrast for readability
class EverblushColors {
  // You can't create an instance of this class
  // It's just a container for our color constants
  EverblushColors._();

  // ===========================================
  // Background Colors
  // These form the base of our dark theme
  // ===========================================
  
  /// The deepest, darkest background
  /// Used for the main scaffold background
  static const Color background = Color(0xFF141b1e);
  
  /// Slightly lighter surface for cards and sheets
  static const Color surface = Color(0xFF181f21);
  
  /// Even lighter for elevated elements like dialogs
  static const Color surfaceVariant = Color(0xFF232a2d);
  
  /// For subtle borders and dividers
  static const Color outline = Color(0xFF3b4244);

  // ===========================================
  // Accent Colors - The vibrant ones!
  // ===========================================
  
  /// Primary blue - for main actions and highlights
  /// This is the "signature" color of the app
  static const Color primary = Color(0xFF67b0e8);
  
  /// Secondary magenta - for secondary actions
  static const Color secondary = Color(0xFFc47fd5);
  
  /// Tertiary cyan - for additional accents
  static const Color tertiary = Color(0xFF6cbfbf);

  // ===========================================
  // Semantic Colors
  // These communicate meaning to users
  // ===========================================
  
  /// Red for errors (but still pretty!)
  static const Color error = Color(0xFFe57474);
  
  /// Green for success states
  static const Color success = Color(0xFF8ccf7e);
  
  /// Yellow for warnings
  static const Color warning = Color(0xFFe5c76b);

  // ===========================================
  // Text Colors
  // ===========================================
  
  /// Primary text - brightest, for important content
  static const Color textPrimary = Color(0xFFdadada);
  
  /// Secondary text - for less important content
  static const Color textSecondary = Color(0xFFb3b9b8);
  
  /// Muted text - for hints and placeholders
  static const Color textMuted = Color(0xFF6e7679);

  // ===========================================
  // Special Colors for the Player
  // ===========================================
  
  /// A soft white glow for the album art
  static const Color glow = Color(0x3367b0e8);
  
  /// Shimmer base color for loading states
  static const Color shimmerBase = Color(0xFF232a2d);
  
  /// Shimmer highlight for that nice animation
  static const Color shimmerHighlight = Color(0xFF3b4244);
}

// A quick helper to make semi-transparent versions of our colors
// Super useful for overlays and gradients
extension ColorWithOpacity on Color {
  /// Makes the color 10% visible (very transparent)
  Color get opacity10 => withValues(alpha: 0.1);
  
  /// 20% visible
  Color get opacity20 => withValues(alpha: 0.2);
  
  /// Half visible
  Color get opacity50 => withValues(alpha: 0.5);
  
  /// 80% visible (slightly transparent)
  Color get opacity80 => withValues(alpha: 0.8);
}
