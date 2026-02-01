// ============================================================================
// Download Entity - Track downloaded songs
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:isar/isar.dart';

part 'download_entity.g.dart';

@collection
class DownloadEntity {
  Id id = Isar.autoIncrement;

  @Index(unique: true)
  late String songId;

  late String title;
  late String artistName;
  String? thumbnailUrl;

  /// File path on device
  late String filePath;

  /// File size in bytes
  int fileSize = 0;

  /// Audio quality/bitrate
  String? quality;

  DateTime downloadedAt = DateTime.now();
}
