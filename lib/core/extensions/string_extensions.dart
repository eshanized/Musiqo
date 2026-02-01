// ============================================================================
// String Extensions - Text manipulation helpers
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

/// Extensions for String with common text operations.
extension StringExtensions on String {
  
  /// Capitalize the first letter
  /// "hello world" -> "Hello world"
  String get capitalized {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1)}';
  }
  
  /// Capitalize each word (title case)
  /// "hello world" -> "Hello World"
  String get titleCase {
    return split(' ').map((word) => word.capitalized).join(' ');
  }
  
  /// Truncate with ellipsis if too long
  /// "This is a very long text" -> "This is a very..."
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}...';
  }
  
  /// Remove HTML tags (useful for cleaning lyrics)
  String get stripHtml {
    return replaceAll(RegExp(r'<[^>]*>'), '');
  }
  
  /// Check if this looks like a YouTube video ID
  /// YouTube IDs are 11 characters, alphanumeric with - and _
  bool get isYouTubeId {
    return length == 11 && RegExp(r'^[a-zA-Z0-9_-]+$').hasMatch(this);
  }
  
  /// Extract YouTube video ID from a URL
  /// Works with youtube.com, youtu.be, and music.youtube.com URLs
  String? get extractYouTubeId {
    // Already looks like an ID
    if (isYouTubeId) return this;
    
    // Try to parse as URL
    final uri = Uri.tryParse(this);
    if (uri == null) return null;
    
    // youtube.com/watch?v=VIDEO_ID
    if (uri.queryParameters.containsKey('v')) {
      return uri.queryParameters['v'];
    }
    
    // youtu.be/VIDEO_ID
    if (uri.host == 'youtu.be' && uri.pathSegments.isNotEmpty) {
      return uri.pathSegments.first;
    }
    
    return null;
  }
}

/// Nullable string extensions
extension NullableStringExtensions on String? {
  /// Returns true if null or empty
  bool get isNullOrEmpty => this == null || this!.isEmpty;
  
  /// Returns true if not null and not empty
  bool get isNotNullOrEmpty => !isNullOrEmpty;
  
  /// Returns the string or a default value
  String orDefault(String defaultValue) => isNullOrEmpty ? defaultValue : this!;
}
