// ============================================================================
// Platform Utils - Platform-specific utilities
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:io';

/// Platform-specific utilities.
class PlatformUtils {
  PlatformUtils._();

  /// Check if running on Android
  static bool get isAndroid => Platform.isAndroid;

  /// Check if running on iOS
  static bool get isIOS => Platform.isIOS;

  /// Check if running on mobile
  static bool get isMobile => isAndroid || isIOS;

  /// Check if running on desktop
  static bool get isDesktop => !isMobile;

  /// Get platform name
  static String get platformName {
    if (isAndroid) return 'Android';
    if (isIOS) return 'iOS';
    if (Platform.isLinux) return 'Linux';
    if (Platform.isMacOS) return 'macOS';
    if (Platform.isWindows) return 'Windows';
    return 'Unknown';
  }
}
