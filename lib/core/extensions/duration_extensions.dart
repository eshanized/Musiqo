// ============================================================================
// Duration Extensions - Helpers for time formatting
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

/// Extensions for Duration to format time nicely.
/// 
/// A music player needs to show time in different formats:
/// - "3:45" for song duration
/// - "1:23:45" for long podcasts
/// - "45s" for very short clips
extension DurationExtensions on Duration {
  
  /// Format as "mm:ss" or "h:mm:ss" for longer durations
  /// 
  /// Examples:
  /// - 3 min 45 sec -> "3:45"
  /// - 1 hour 23 min 45 sec -> "1:23:45"
  String get formatted {
    final hours = inHours;
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    
    if (hours > 0) {
      // Long format: 1:23:45
      return '$hours:${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
    } else {
      // Short format: 3:45
      return '$minutes:${seconds.toString().padLeft(2, '0')}';
    }
  }
  
  /// Format with always two digits for minutes
  /// "03:45" instead of "3:45"
  String get formattedPadded {
    final minutes = inMinutes.remainder(60);
    final seconds = inSeconds.remainder(60);
    return '${minutes.toString().padLeft(2, '0')}:${seconds.toString().padLeft(2, '0')}';
  }
  
  /// Human-readable format like "3 min" or "1 hr 23 min"
  String get humanReadable {
    if (inHours > 0) {
      final minutes = inMinutes.remainder(60);
      return '$inHours hr ${minutes > 0 ? '$minutes min' : ''}';
    } else if (inMinutes > 0) {
      return '$inMinutes min';
    } else {
      return '${inSeconds}s';
    }
  }
}

/// Parse a duration string back to Duration
Duration parseDuration(String formatted) {
  final parts = formatted.split(':').map(int.parse).toList();
  
  if (parts.length == 3) {
    // Format: h:mm:ss
    return Duration(
      hours: parts[0],
      minutes: parts[1],
      seconds: parts[2],
    );
  } else if (parts.length == 2) {
    // Format: mm:ss
    return Duration(
      minutes: parts[0],
      seconds: parts[1],
    );
  }
  
  return Duration.zero;
}
