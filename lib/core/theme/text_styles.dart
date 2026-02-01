// ============================================================================
// Text Styles - Extra text styling helpers
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'everblush_colors.dart';

/// Extra text styles that aren't part of the standard theme.
/// Use these for special cases like player time, lyrics, etc.
class AppTextStyles {
  AppTextStyles._();

  // Player-specific styles
  
  /// Big song title on the player screen
  static const TextStyle playerTitle = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.bold,
    color: EverblushColors.textPrimary,
  );

  /// Artist name below the song title
  static const TextStyle playerArtist = TextStyle(
    fontSize: 16,
    color: EverblushColors.textSecondary,
  );

  /// Time display (00:00 format)
  static const TextStyle playerTime = TextStyle(
    fontSize: 12,
    fontFamily: 'monospace',  // monospace looks better for time
    color: EverblushColors.textMuted,
  );

  // Lyrics styles
  
  /// Current lyrics line (highlighted)
  static const TextStyle lyricsActive = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: EverblushColors.textPrimary,
    height: 1.5,
  );

  /// Other lyrics lines
  static const TextStyle lyricsInactive = TextStyle(
    fontSize: 18,
    color: EverblushColors.textMuted,
    height: 1.5,
  );

  // For song tiles in lists
  
  /// Song name in a list
  static const TextStyle songTitle = TextStyle(
    fontSize: 15,
    fontWeight: FontWeight.w500,
    color: EverblushColors.textPrimary,
  );

  /// Artist/album info under song name
  static const TextStyle songSubtitle = TextStyle(
    fontSize: 13,
    color: EverblushColors.textMuted,
  );
}
