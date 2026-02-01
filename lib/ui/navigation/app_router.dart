// ============================================================================
// App Router - Navigation configuration using GoRouter
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// GoRouter is a declarative routing package. Instead of Navigator.push(),
// you define all your routes upfront and navigate by path.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'routes.dart';
import '../screens/home/home_screen.dart';
import '../screens/explore/explore_screen.dart';
import '../screens/library/library_screen.dart';
import '../screens/search/search_screen.dart';
import '../screens/player/player_screen.dart';
import '../screens/artist/artist_screen.dart';
import '../screens/album/album_screen.dart';
import '../screens/playlist/playlist_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/auth/login_screen.dart';
import '../widgets/core/app_scaffold.dart';

/// The router provider - creates and provides our navigation configuration
final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    // Starting page
    initialLocation: Routes.home,
    
    // Uncomment to see navigation logs
    // debugLogDiagnostics: true,
    
    routes: [
      // Shell route wraps screens with bottom nav and mini player
      ShellRoute(
        builder: (context, state, child) {
          return AppScaffold(child: child);
        },
        routes: [
          // ====================
          // Main tab screens
          // ====================
          
          GoRoute(
            path: Routes.home,
            name: 'home',
            pageBuilder: (context, state) => _fadeTransition(
              state,
              const HomeScreen(),
            ),
          ),
          
          GoRoute(
            path: Routes.explore,
            name: 'explore',
            pageBuilder: (context, state) => _fadeTransition(
              state,
              const ExploreScreen(),
            ),
          ),
          
          GoRoute(
            path: Routes.library,
            name: 'library',
            pageBuilder: (context, state) => _fadeTransition(
              state,
              const LibraryScreen(),
            ),
          ),
          
          // ====================
          // Search
          // ====================
          
          GoRoute(
            path: Routes.search,
            name: 'search',
            pageBuilder: (context, state) => _slideUpTransition(
              state,
              const SearchScreen(),
            ),
          ),
          
          // ====================
          // Detail screens
          // ====================
          
          GoRoute(
            path: '${Routes.artist}/:id',
            name: 'artist',
            pageBuilder: (context, state) {
              final artistId = state.pathParameters['id']!;
              return _slideTransition(
                state,
                ArtistScreen(artistId: artistId),
              );
            },
          ),
          
          GoRoute(
            path: '${Routes.album}/:id',
            name: 'album',
            pageBuilder: (context, state) {
              final albumId = state.pathParameters['id']!;
              return _slideTransition(
                state,
                AlbumScreen(albumId: albumId),
              );
            },
          ),
          
          GoRoute(
            path: '${Routes.playlist}/:id',
            name: 'playlist',
            pageBuilder: (context, state) {
              final playlistId = state.pathParameters['id']!;
              return _slideTransition(
                state,
                PlaylistScreen(playlistId: playlistId),
              );
            },
          ),
          
          // ====================
          // Settings
          // ====================
          
          GoRoute(
            path: Routes.settings,
            name: 'settings',
            pageBuilder: (context, state) => _slideTransition(
              state,
              const SettingsScreen(),
            ),
          ),
        ],
      ),
      
      // ====================
      // Full-screen player (not in shell)
      // ====================
      
      GoRoute(
        path: Routes.player,
        name: 'player',
        pageBuilder: (context, state) => _slideUpTransition(
          state,
          const PlayerScreen(),
        ),
      ),

      // ====================
      // Login (optional auth)
      // ====================

      GoRoute(
        path: Routes.login,
        name: 'login',
        pageBuilder: (context, state) => _slideUpTransition(
          state,
          const LoginScreen(),
        ),
      ),
    ],
    
    // Handle errors (404, etc.)
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Page not found: ${state.uri.path}'),
      ),
    ),
  );
});

// =============================================================================
// Custom Page Transitions
// These make navigation feel smooth and premium
// =============================================================================

/// Fade transition - for tab switches
CustomTransitionPage<void> _fadeTransition(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 200),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(
        opacity: animation,
        child: child,
      );
    },
  );
}

/// Slide from right - for pushing detail screens
CustomTransitionPage<void> _slideTransition(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 300),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(1.0, 0.0),
          end: Offset.zero,
        ).animate(curve),
        child: child,
      );
    },
  );
}

/// Slide from bottom - for modals like search and player
CustomTransitionPage<void> _slideUpTransition(
  GoRouterState state,
  Widget child,
) {
  return CustomTransitionPage(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 350),
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      final curve = CurvedAnimation(
        parent: animation,
        curve: Curves.easeOutCubic,
      );
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0.0, 1.0),
          end: Offset.zero,
        ).animate(curve),
        child: FadeTransition(
          opacity: animation,
          child: child,
        ),
      );
    },
  );
}
