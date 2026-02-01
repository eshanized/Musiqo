// ============================================================================
// Artwork Display - Large album art
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../images/cached_artwork.dart';

/// Large album artwork display for player screen.
class ArtworkDisplay extends StatelessWidget {
  final String? url;
  final double size;
  final bool showShadow;

  const ArtworkDisplay({
    super.key,
    this.url,
    this.size = 300,
    this.showShadow = true,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        boxShadow: showShadow
            ? [
                BoxShadow(
                  color: EverblushColors.primary.withValues(alpha: 0.2),
                  blurRadius: 40,
                  spreadRadius: 10,
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: CachedArtwork(url: url, size: size),
      ),
    );
  }
}
