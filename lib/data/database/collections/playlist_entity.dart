// ============================================================================
// Playlist Entity - Isar collection for playlists
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:isar/isar.dart';

part 'playlist_entity.g.dart';

/// Playlist entity for local storage.
@collection
class PlaylistEntity {
  Id id = Isar.autoIncrement;

  /// Unique playlist ID (for YouTube playlists) or local ID
  @Index(unique: true)
  late String playlistId;

  late String name;
  String? description;
  String? thumbnailUrl;

  /// Is this a local playlist or from YouTube
  bool isLocal = true;

  /// Author name (for YouTube playlists)
  String? author;

  /// Song video IDs in order
  List<String> songIds = [];

  DateTime createdAt = DateTime.now();
  DateTime? updatedAt;
}
