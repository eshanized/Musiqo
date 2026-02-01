// ============================================================================
// Avatar Circle - User/artist avatar
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../images/cached_artwork.dart';

/// Circular avatar for users or artists.
class AvatarCircle extends StatelessWidget {
  final String? imageUrl;
  final double size;
  final String? fallbackText;

  const AvatarCircle({
    super.key,
    this.imageUrl,
    this.size = 40,
    this.fallbackText,
  });

  @override
  Widget build(BuildContext context) {
    if (imageUrl != null && imageUrl!.isNotEmpty) {
      return ClipOval(
        child: CachedArtwork(url: imageUrl, size: size),
      );
    }

    return Container(
      width: size,
      height: size,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        color: EverblushColors.surfaceVariant,
      ),
      child: Center(
        child: fallbackText != null && fallbackText!.isNotEmpty
            ? Text(
                fallbackText![0].toUpperCase(),
                style: TextStyle(
                  fontSize: size * 0.4,
                  fontWeight: FontWeight.bold,
                  color: EverblushColors.textPrimary,
                ),
              )
            : Icon(
                Icons.person_rounded,
                size: size * 0.5,
                color: EverblushColors.textMuted,
              ),
      ),
    );
  }
}
