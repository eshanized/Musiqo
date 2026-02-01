// ============================================================================
// Icon Label - Icon with text label
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// Icon with text label displayed inline.
class IconLabel extends StatelessWidget {
  final IconData icon;
  final String label;
  final double iconSize;
  final double spacing;
  final TextStyle? textStyle;

  const IconLabel({
    super.key,
    required this.icon,
    required this.label,
    this.iconSize = 16,
    this.spacing = 4,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: iconSize, color: EverblushColors.textMuted),
        SizedBox(width: spacing),
        Text(
          label,
          style:
              textStyle ??
              const TextStyle(fontSize: 12, color: EverblushColors.textMuted),
        ),
      ],
    );
  }
}
