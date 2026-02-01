// ============================================================================
// Radio Card - Card for radio stations
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/radio.dart';
import '../images/cached_artwork.dart';

/// Card for displaying radio stations.
class RadioCard extends StatelessWidget {
  final Radio radio;
  final VoidCallback? onTap;
  final double width;

  const RadioCard({
    super.key,
    required this.radio,
    this.onTap,
    this.width = 150,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              alignment: Alignment.center,
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: CachedArtwork(url: radio.thumbnailUrl, size: width),
                ),
                // Radio indicator
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: EverblushColors.primary.withValues(alpha: 0.9),
                  ),
                  child: const Icon(
                    Icons.radio_rounded,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              radio.name,
              style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: EverblushColors.textPrimary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 2),
            const Text(
              'Radio',
              style: TextStyle(fontSize: 11, color: EverblushColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }
}
