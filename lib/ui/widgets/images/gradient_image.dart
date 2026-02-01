// ============================================================================
// Gradient Image - Image with gradient overlay
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'cached_artwork.dart';

/// Image with gradient overlay for text readability.
class GradientImage extends StatelessWidget {
  final String? url;
  final double? height;
  final double? width;
  final List<Color>? gradientColors;
  final Widget? child;

  const GradientImage({
    super.key,
    this.url,
    this.height,
    this.width,
    this.gradientColors,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width ?? double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CachedArtwork(
            url: url,
            size: height ?? (width ?? 200),
          ),
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors:
                    gradientColors ??
                    [Colors.transparent, Colors.black.withValues(alpha: 0.7)],
              ),
            ),
          ),
          if (child != null) child!,
        ],
      ),
    );
  }
}
