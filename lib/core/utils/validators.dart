// ============================================================================
// Validators - Common validation functions
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

/// Common validation functions.
class Validators {
  Validators._();

  /// Validate playlist name
  static String? playlistName(String? value) {
    if (value == null || value.trim().isEmpty) {
      return 'Playlist name is required';
    }
    if (value.length > 50) {
      return 'Playlist name is too long';
    }
    return null;
  }

  /// Validate search query
  static bool isValidSearchQuery(String query) {
    return query.trim().length >= 2;
  }

  /// Validate URL
  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.scheme == 'http' || uri.scheme == 'https');
    } catch (_) {
      return false;
    }
  }

  /// Validate YouTube video ID
  static bool isValidVideoId(String id) {
    return RegExp(r'^[a-zA-Z0-9_-]{11}$').hasMatch(id);
  }
}
