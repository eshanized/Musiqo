// ============================================================================
// Tappable Area - Expand touch area for small widgets
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

/// Expands the touch area of small widgets.
class TappableArea extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double padding;

  const TappableArea({
    super.key,
    required this.child,
    this.onTap,
    this.onLongPress,
    this.padding = 8,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      onLongPress: onLongPress,
      behavior: HitTestBehavior.opaque,
      child: Padding(padding: EdgeInsets.all(padding), child: child),
    );
  }
}
