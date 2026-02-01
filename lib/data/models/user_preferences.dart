// ============================================================================
// User Preferences Model
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'audio_quality.dart';

/// User preferences for the app.
class UserPreferences {
  final AudioQuality streamingQuality;
  final AudioQuality downloadQuality;
  final bool downloadOverWifiOnly;
  final bool audioNormalization;
  final bool skipSilence;
  final bool gaplessPlayback;
  final String? lastPlayedSongId;
  final Duration lastPlayedPosition;
  final double lastVolume;

  const UserPreferences({
    this.streamingQuality = AudioQuality.high,
    this.downloadQuality = AudioQuality.high,
    this.downloadOverWifiOnly = true,
    this.audioNormalization = false,
    this.skipSilence = false,
    this.gaplessPlayback = true,
    this.lastPlayedSongId,
    this.lastPlayedPosition = Duration.zero,
    this.lastVolume = 1.0,
  });

  UserPreferences copyWith({
    AudioQuality? streamingQuality,
    AudioQuality? downloadQuality,
    bool? downloadOverWifiOnly,
    bool? audioNormalization,
    bool? skipSilence,
    bool? gaplessPlayback,
    String? lastPlayedSongId,
    Duration? lastPlayedPosition,
    double? lastVolume,
  }) {
    return UserPreferences(
      streamingQuality: streamingQuality ?? this.streamingQuality,
      downloadQuality: downloadQuality ?? this.downloadQuality,
      downloadOverWifiOnly: downloadOverWifiOnly ?? this.downloadOverWifiOnly,
      audioNormalization: audioNormalization ?? this.audioNormalization,
      skipSilence: skipSilence ?? this.skipSilence,
      gaplessPlayback: gaplessPlayback ?? this.gaplessPlayback,
      lastPlayedSongId: lastPlayedSongId ?? this.lastPlayedSongId,
      lastPlayedPosition: lastPlayedPosition ?? this.lastPlayedPosition,
      lastVolume: lastVolume ?? this.lastVolume,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'streamingQuality': streamingQuality.index,
      'downloadQuality': downloadQuality.index,
      'downloadOverWifiOnly': downloadOverWifiOnly,
      'audioNormalization': audioNormalization,
      'skipSilence': skipSilence,
      'gaplessPlayback': gaplessPlayback,
      'lastPlayedSongId': lastPlayedSongId,
      'lastPlayedPosition': lastPlayedPosition.inMilliseconds,
      'lastVolume': lastVolume,
    };
  }

  factory UserPreferences.fromJson(Map<String, dynamic> json) {
    return UserPreferences(
      streamingQuality: AudioQuality.values[json['streamingQuality'] ?? 2],
      downloadQuality: AudioQuality.values[json['downloadQuality'] ?? 2],
      downloadOverWifiOnly: json['downloadOverWifiOnly'] ?? true,
      audioNormalization: json['audioNormalization'] ?? false,
      skipSilence: json['skipSilence'] ?? false,
      gaplessPlayback: json['gaplessPlayback'] ?? true,
      lastPlayedSongId: json['lastPlayedSongId'],
      lastPlayedPosition: Duration(
        milliseconds: json['lastPlayedPosition'] ?? 0,
      ),
      lastVolume: (json['lastVolume'] ?? 1.0).toDouble(),
    );
  }
}
