// ============================================================================
// Artist Card - Grid card for artists
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../images/cached_artwork.dart';

/// A circular artist card for grids.
class ArtistCard extends StatelessWidget {
  final String name;
  final String? thumbnailUrl;
  final VoidCallback? onTap;

  const ArtistCard({
    super.key,
    required this.name,
    this.thumbnailUrl,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CachedArtwork(url: thumbnailUrl, size: 100, isCircular: true),
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
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
