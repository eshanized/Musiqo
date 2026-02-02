// ============================================================================
// Routes - All route paths in one place
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

/// All the route paths used in the app.
///
/// WHY A SEPARATE CLASS?
/// Same reason as constants - avoid typos and make refactoring easy.
/// If you need to change '/library' to '/my-library', do it once here.
class Routes {
  Routes._();

  // Main tabs
  static const String home = '/';
  static const String explore = '/explore';
  static const String library = '/library';
  static const String downloads = '/downloads';

  // Search
  static const String search = '/search';

  // Player (full screen)
  static const String player = '/player';
  static const String lyrics = '/lyrics';
  static const String queue = '/queue';

  // Auth (optional)
  static const String login = '/login';

  // Detail pages
  static const String artist = '/artist'; // + /:id
  static const String album = '/album'; // + /:id
  static const String playlist = '/playlist'; // + /:id

  // Settings
  static const String settings = '/settings';

  // Nested settings
  static const String playbackSettings = '/settings/playback';
  static const String downloadSettings = '/settings/download';
  static const String appearanceSettings = '/settings/appearance';
  static const String storageSettings = '/settings/storage';
  static const String equalizer = '/settings/equalizer';
  static const String about = '/settings/about';
}
