// ============================================================================
// Download Tile - Download item with progress
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/download.dart';
import '../images/cached_artwork.dart';

/// Download tile with progress indicator.
class DownloadTile extends StatelessWidget {
  final Download download;
  final VoidCallback? onCancel;
  final VoidCallback? onRetry;

  const DownloadTile({
    super.key,
    required this.download,
    this.onCancel,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Stack(
        alignment: Alignment.center,
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedArtwork(url: download.song.thumbnailUrl, size: 48),
          ),
          if (download.status == DownloadStatus.downloading)
            CircularProgressIndicator(
              value: download.progress,
              strokeWidth: 2,
              color: EverblushColors.primary,
            ),
        ],
      ),
      title: Text(
        download.song.title,
        style: const TextStyle(color: EverblushColors.textPrimary),
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
      ),
      subtitle: Text(
        _getStatusText(),
        style: TextStyle(
          color: download.status == DownloadStatus.failed
              ? EverblushColors.error
              : EverblushColors.textMuted,
          fontSize: 12,
        ),
      ),
      trailing: _buildTrailing(),
    );
  }

  String _getStatusText() {
    switch (download.status) {
      case DownloadStatus.pending:
        return 'Waiting...';
      case DownloadStatus.downloading:
        return '${(download.progress * 100).toInt()}%';
      case DownloadStatus.complete:
        return 'Completed';
      case DownloadStatus.failed:
        return 'Failed';
      case DownloadStatus.cancelled:
        return 'Cancelled';
    }
  }

  Widget? _buildTrailing() {
    switch (download.status) {
      case DownloadStatus.downloading:
        return IconButton(
          onPressed: onCancel,
          icon: const Icon(Icons.close_rounded),
          color: EverblushColors.textMuted,
        );
      case DownloadStatus.failed:
        return IconButton(
          onPressed: onRetry,
          icon: const Icon(Icons.refresh_rounded),
          color: EverblushColors.primary,
        );
      case DownloadStatus.complete:
        return const Icon(
          Icons.check_circle_rounded,
          color: EverblushColors.success,
        );
      default:
        return null;
    }
  }
}
