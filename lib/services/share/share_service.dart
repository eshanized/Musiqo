// ============================================================================
// Share Service - Share content
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:share_plus/share_plus.dart';

import '../../data/models/song.dart';

/// Service for sharing content.
class ShareService {
  /// Share a song
  static Future<void> shareSong(Song song) async {
    final text =
        '🎵 ${song.title} by ${song.artistName}\n'
        'Listen on YouTube Music: https://music.youtube.com/watch?v=${song.id}';

    await Share.share(text, subject: song.title);
  }

  /// Share playlist link
  static Future<void> sharePlaylist(String playlistId, String name) async {
    final text =
        '🎶 $name\n'
        'Check out this playlist: https://music.youtube.com/playlist?list=$playlistId';

    await Share.share(text, subject: name);
  }

  /// Share artist
  static Future<void> shareArtist(String artistId, String name) async {
    final text =
        '🎤 $name on YouTube Music\n'
        'https://music.youtube.com/channel/$artistId';

    await Share.share(text, subject: name);
  }
}
