// ============================================================================
// Download Model - Track download progress and state
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'song.dart';

/// Represents a download task
class Download {
  final String id;
  final Song song;
  final DownloadStatus status;
  final double progress;
  final String? filePath;
  final String? error;
  final DateTime createdAt;

  const Download({
    required this.id,
    required this.song,
    required this.status,
    this.progress = 0,
    this.filePath,
    this.error,
    required this.createdAt,
  });

  Download copyWith({
    String? id,
    Song? song,
    DownloadStatus? status,
    double? progress,
    String? filePath,
    String? error,
    DateTime? createdAt,
  }) {
    return Download(
      id: id ?? this.id,
      song: song ?? this.song,
      status: status ?? this.status,
      progress: progress ?? this.progress,
      filePath: filePath ?? this.filePath,
      error: error ?? this.error,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  bool get isComplete => status == DownloadStatus.complete;
  bool get isDownloading => status == DownloadStatus.downloading;
  bool get hasFailed => status == DownloadStatus.failed;
}

/// Download status enum
enum DownloadStatus { pending, downloading, complete, failed, cancelled }
