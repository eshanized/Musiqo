// ============================================================================
// Storage Keys - Keys for SharedPreferences and local storage
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

/// Keys for storing data locally.
/// 
/// WHY USE A CLASS FOR KEYS?
/// Typos in strings are silent bugs. If you type "playbck_quality"
/// instead of "playback_quality", your app might just not work.
/// Using constants means the IDE will catch typos immediately.
class StorageKeys {
  StorageKeys._();

  // User preferences
  static const String themeMode = 'theme_mode';
  static const String playbackQuality = 'playback_quality';
  static const String downloadQuality = 'download_quality';
  static const String audioNormalization = 'audio_normalization';
  static const String skipSilence = 'skip_silence';
  static const String gaplessPlayback = 'gapless_playback';
  
  // Player state (to restore after app restart)
  static const String lastPlayedSongId = 'last_played_song_id';
  static const String lastPosition = 'last_position';
  static const String repeatMode = 'repeat_mode';
  static const String shuffleEnabled = 'shuffle_enabled';
  static const String playerVolume = 'player_volume';
  
  // Queue persistence
  static const String persistedQueue = 'persisted_queue';
  static const String queueIndex = 'queue_index';
  
  // Account (optional, for YouTube Premium features)
  static const String visitorData = 'visitor_data';
  static const String cookie = 'cookie';
  static const String accountName = 'account_name';
  static const String accountEmail = 'account_email';
  
  // App settings
  static const String contentLanguage = 'content_language';
  static const String contentCountry = 'content_country';
  static const String imageCacheSize = 'image_cache_size';
  static const String searchHistoryPaused = 'search_history_paused';
  
  // Settings bundle (for backup/restore)
  static const String userPreferences = 'user_preferences';
}
