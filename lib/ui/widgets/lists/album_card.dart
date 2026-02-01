// ============================================================================
// Album Card - Grid card for albums
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../images/cached_artwork.dart';

/// A square album card for grids.
class AlbumCard extends StatelessWidget {
  final String name;
  final String? artistName;
  final String? thumbnailUrl;
  final VoidCallback? onTap;

  const AlbumCard({
    super.key,
    required this.name,
    this.artistName,
    this.thumbnailUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CachedArtwork(url: thumbnailUrl, size: 150, borderRadius: 8),
          const SizedBox(height: 8),
          Text(
            name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w500,
              color: EverblushColors.textPrimary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (artistName != null)
            Text(
              artistName!,
              style: const TextStyle(
                fontSize: 12,
                color: EverblushColors.textMuted,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
        ],
      ),
    );
  }
}
