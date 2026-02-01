// ============================================================================
// Cached Artwork - Network image with caching and placeholder
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../../../core/theme/everblush_colors.dart';

/// A widget that displays artwork (album cover, artist image, etc.)
/// with automatic caching and a nice loading placeholder.
class CachedArtwork extends StatelessWidget {
  /// URL of the image
  final String? url;
  
  /// Size of the image (width and height)
  final double size;
  
  /// Border radius (0 for no rounding)
  final double borderRadius;
  
  /// Whether this is circular (for artist photos)
  final bool isCircular;

  const CachedArtwork({
    super.key,
    required this.url,
    this.size = 56,
    this.borderRadius = 8,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    // Container decoration based on shape
    final decoration = BoxDecoration(
      color: EverblushColors.surfaceVariant,
      borderRadius: isCircular ? null : BorderRadius.circular(borderRadius),
      shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
    );

    // Placeholder when image is loading or URL is null
    Widget placeholder = Container(
      width: size,
      height: size,
      decoration: decoration,
      child: Icon(
        Icons.music_note_rounded,
        color: EverblushColors.textMuted,
        size: size * 0.4,
      ),
    );

    // If no URL, just show placeholder
    if (url == null || url!.isEmpty) {
      return placeholder;
    }

    // Load and cache the image
    return ClipRRect(
      borderRadius: isCircular
          ? BorderRadius.circular(size / 2)
          : BorderRadius.circular(borderRadius),
      child: CachedNetworkImage(
        imageUrl: url!,
        width: size,
        height: size,
        fit: BoxFit.cover,
        placeholder: (context, url) => placeholder,
        errorWidget: (context, url, error) => placeholder,
        fadeInDuration: const Duration(milliseconds: 200),
      ),
    );
  }
}
