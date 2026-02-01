// ============================================================================
// Radio Model - Endless radio stations
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

/// Radio station based on a song or artist.
class Radio {
  final String id;
  final String name;
  final String? seedSongId;
  final String? seedArtistId;
  final String? thumbnailUrl;

  const Radio({
    required this.id,
    required this.name,
    this.seedSongId,
    this.seedArtistId,
    this.thumbnailUrl,
  });

  bool get isFromSong => seedSongId != null;
  bool get isFromArtist => seedArtistId != null;
}
