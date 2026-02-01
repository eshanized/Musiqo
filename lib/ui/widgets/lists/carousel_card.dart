// ============================================================================
// Carousel Card - Card for horizontal scrolling lists
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../images/cached_artwork.dart';

/// A card used in horizontal carousels for albums, playlists, etc.
class CarouselCard extends StatelessWidget {
  final double width;
  final double? height;
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final LinearGradient? gradient;
  final VoidCallback? onTap;
  final bool isCircular;

  const CarouselCard({
    super.key,
    this.width = 140,
    this.height,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.gradient,
    this.onTap,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    final cardHeight = height ?? width + 60;

    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        height: cardHeight,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image or gradient background
            Container(
              width: width,
              height: width,
              decoration: BoxDecoration(
                color: EverblushColors.surfaceVariant,
                borderRadius:
                    isCircular
                        ? BorderRadius.circular(width / 2)
                        : BorderRadius.circular(12),
                gradient: gradient,
              ),
              child:
                  gradient == null
                      ? (imageUrl != null
                          ? CachedArtwork(
                            url: imageUrl,
                            size: width,
                            borderRadius: isCircular ? width / 2 : 12,
                            isCircular: isCircular,
                          )
                          : Icon(
                            Icons.music_note_rounded,
                            size: width * 0.3,
                            color: EverblushColors.textMuted,
                          ))
                      : null,
            ),

            const SizedBox(height: 8),

            // Title
            Flexible(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: EverblushColors.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),

            // Subtitle
            if (subtitle != null)
              Flexible(
                child: Text(
                  subtitle!,
                  style: const TextStyle(
                    fontSize: 11,
                    color: EverblushColors.textMuted,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
          ],
        ),
      ),
    );
  }
}
