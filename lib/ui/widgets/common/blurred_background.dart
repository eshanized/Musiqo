// ============================================================================
// Blurred Background - Frosted glass effect
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:ui';
import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// A container with blurred background (frosted glass effect).
class BlurredBackground extends StatelessWidget {
  final Widget child;
  final double blurAmount;
  final Color? overlayColor;
  final double borderRadius;

  const BlurredBackground({
    super.key,
    required this.child,
    this.blurAmount = 10,
    this.overlayColor,
    this.borderRadius = 0,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: blurAmount, sigmaY: blurAmount),
        child: Container(
          color:
              overlayColor ?? EverblushColors.background.withValues(alpha: 0.6),
          child: child,
        ),
      ),
    );
  }
}
