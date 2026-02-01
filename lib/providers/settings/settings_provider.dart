// ============================================================================
// Settings Provider - State for app settings
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../data/models/user_preferences.dart';
import '../../data/models/audio_quality.dart';
import '../../services/settings/settings_service.dart';

/// Provider for settings service
final settingsServiceProvider = Provider<SettingsService>((ref) {
  return SettingsService();
});

/// Provider for user preferences
final userPreferencesProvider =
    StateNotifierProvider<UserPreferencesNotifier, UserPreferences>(
      (ref) => UserPreferencesNotifier(ref.watch(settingsServiceProvider)),
    );

/// Notifier for user preferences
class UserPreferencesNotifier extends StateNotifier<UserPreferences> {
  final SettingsService _settingsService;

  UserPreferencesNotifier(this._settingsService)
    : super(const UserPreferences()) {
    _load();
  }

  Future<void> _load() async {
    await _settingsService.init();
    state = _settingsService.getPreferences();
  }

  Future<void> _save() async {
    await _settingsService.savePreferences(state);
  }

  /// Set streaming quality
  Future<void> setStreamingQuality(AudioQuality quality) async {
    state = state.copyWith(streamingQuality: quality);
    await _save();
  }

  /// Set download quality
  Future<void> setDownloadQuality(AudioQuality quality) async {
    state = state.copyWith(downloadQuality: quality);
    await _save();
  }

  /// Toggle WiFi-only downloads
  Future<void> toggleWifiOnlyDownload() async {
    state = state.copyWith(downloadOverWifiOnly: !state.downloadOverWifiOnly);
    await _save();
  }

  /// Toggle audio normalization
  Future<void> toggleAudioNormalization() async {
    state = state.copyWith(audioNormalization: !state.audioNormalization);
    await _save();
  }

  /// Toggle skip silence
  Future<void> toggleSkipSilence() async {
    state = state.copyWith(skipSilence: !state.skipSilence);
    await _save();
  }

  /// Toggle gapless playback
  Future<void> toggleGaplessPlayback() async {
    state = state.copyWith(gaplessPlayback: !state.gaplessPlayback);
    await _save();
  }
}
