// ============================================================================
// App Constants - Magic numbers belong here, not scattered in code
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

/// All the constant values used throughout the app.
/// 
/// WHY CONSTANTS?
/// Imagine you want to change the border radius from 12 to 16.
/// Without constants, you'd have to find and replace "12" everywhere.
/// With constants, you change it once here - done!
class AppConstants {
  AppConstants._();

  // App info
  static const String appName = 'Musiqo';
  static const String appVersion = '1.0.0';
  
  // UI dimensions
  static const double borderRadiusSmall = 8.0;
  static const double borderRadiusMedium = 12.0;
  static const double borderRadiusLarge = 20.0;
  static const double borderRadiusXL = 28.0;
  
  // Padding and spacing
  static const double paddingSmall = 8.0;
  static const double paddingMedium = 16.0;
  static const double paddingLarge = 24.0;
  
  // Player dimensions
  static const double miniPlayerHeight = 64.0;
  static const double bottomNavHeight = 64.0;
  static const double albumArtSize = 280.0;
  
  // Animation durations (in milliseconds)
  static const int animationFast = 150;
  static const int animationNormal = 300;
  static const int animationSlow = 500;
  
  // Thumbnails
  static const double thumbnailSmall = 48.0;
  static const double thumbnailMedium = 56.0;
  static const double thumbnailLarge = 160.0;
  
  // Search
  static const int searchDebounceMs = 400;
  static const int maxSearchHistory = 20;
  
  // Cache
  static const int maxCachedImages = 500;
  static const int maxCachedSongs = 100;
}
