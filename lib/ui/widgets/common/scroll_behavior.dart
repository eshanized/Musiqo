// ============================================================================
// Scroll Behavior - Custom scroll physics
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

/// Custom scroll behavior without glow effect.
class NoGlowScrollBehavior extends ScrollBehavior {
  @override
  Widget buildOverscrollIndicator(
    BuildContext context,
    Widget child,
    ScrollableDetails details,
  ) {
    return child;
  }
}

/// Apply no-glow scroll behavior to a widget tree.
class NoGlowScroll extends StatelessWidget {
  final Widget child;

  const NoGlowScroll({super.key, required this.child});

  @override
  Widget build(BuildContext context) {
    return ScrollConfiguration(behavior: NoGlowScrollBehavior(), child: child);
  }
}
