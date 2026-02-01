// ============================================================================
// Audio Quality Setting Model
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

/// Audio quality levels for streaming and downloads.
enum AudioQuality {
  low,
  medium,
  high,
  lossless;

  String get displayName {
    switch (this) {
      case AudioQuality.low:
        return 'Low (128 kbps)';
      case AudioQuality.medium:
        return 'Medium (192 kbps)';
      case AudioQuality.high:
        return 'High (320 kbps)';
      case AudioQuality.lossless:
        return 'Lossless';
    }
  }

  int get bitrate {
    switch (this) {
      case AudioQuality.low:
        return 128;
      case AudioQuality.medium:
        return 192;
      case AudioQuality.high:
        return 320;
      case AudioQuality.lossless:
        return 0; // Variable
    }
  }
}

/// Repeat mode for player
enum RepeatMode {
  off,
  all,
  one;

  RepeatMode get next {
    switch (this) {
      case RepeatMode.off:
        return RepeatMode.all;
      case RepeatMode.all:
        return RepeatMode.one;
      case RepeatMode.one:
        return RepeatMode.off;
    }
  }
}
