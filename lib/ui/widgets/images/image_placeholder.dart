// ============================================================================
// Image Placeholder - Default placeholder for images
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// Default placeholder for images when loading or error.
class ImagePlaceholder extends StatelessWidget {
  final double? size;
  final IconData icon;
  final bool isCircular;

  const ImagePlaceholder({
    super.key,
    this.size,
    this.icon = Icons.music_note_rounded,
    this.isCircular = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: EverblushColors.surfaceVariant,
        shape: isCircular ? BoxShape.circle : BoxShape.rectangle,
        borderRadius: isCircular ? null : BorderRadius.circular(8),
      ),
      child: Icon(
        icon,
        size: size != null ? size! * 0.4 : 24,
        color: EverblushColors.textMuted,
      ),
    );
  }
}
