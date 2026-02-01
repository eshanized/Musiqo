// ============================================================================
// App Scaffold - Main layout with bottom nav and mini player
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// This wraps all main screens with the bottom navigation bar
// and the mini player. It's like a frame around the content.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../navigation/routes.dart';
import '../player/mini_player.dart';
import 'bottom_nav_bar.dart';

/// The main scaffold that wraps all tabbed screens.
///
/// LAYOUT:
/// ┌─────────────────────┐
/// │                     │
/// │    Screen Content   │
/// │                     │
/// ├─────────────────────┤
/// │    Mini Player      │
/// ├─────────────────────┤
/// │  Bottom Nav Bar     │
/// └─────────────────────┘
class AppScaffold extends ConsumerWidget {
  final Widget child;

  const AppScaffold({super.key, required this.child});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Figure out which tab is currently active
    final currentPath = GoRouterState.of(context).uri.path;
    final currentIndex = _getTabIndex(currentPath);

    return Scaffold(
      backgroundColor: EverblushColors.background,

      // The main content
      body: child,

      // Bottom section with mini player and nav bar
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Mini player (shows when a song is playing)
          const MiniPlayer(),

          // Navigation bar
          BottomNavBar(
            currentIndex: currentIndex,
            onTap: (index) => _onTabTapped(context, index),
          ),
        ],
      ),
    );
  }

  /// Get the tab index from the current route path
  int _getTabIndex(String path) {
    if (path.startsWith(Routes.explore)) return 1;
    if (path.startsWith(Routes.library)) return 2;
    return 0; // Home is default
  }

  /// Handle tab taps
  void _onTabTapped(BuildContext context, int index) {
    switch (index) {
      case 0:
        context.go(Routes.home);
        break;
      case 1:
        context.go(Routes.explore);
        break;
      case 2:
        context.go(Routes.library);
        break;
    }
  }
}
