// ============================================================================
// Musiqo App - Root widget and configuration
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// This is the root widget of our app. It sets up:
// - Material app configuration
// - Theme (Everblush dark theme)
// - Navigation (GoRouter)
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/theme/app_theme.dart';
import 'core/constants/app_constants.dart';
import 'ui/navigation/app_router.dart';

/// The root widget of Musiqo.
/// 
/// ConsumerWidget is like StatelessWidget but with Riverpod superpowers.
/// It can "watch" providers and automatically rebuild when they change.
class MusiqoApp extends ConsumerWidget {
  const MusiqoApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Get our navigation router
    final router = ref.watch(routerProvider);
    
    return MaterialApp.router(
      // App name shown in task switcher
      title: AppConstants.appName,
      
      // Hide that ugly debug banner
      debugShowCheckedModeBanner: false,
      
      // Our beautiful Everblush dark theme
      theme: AppTheme.darkTheme,
      
      // We only have dark mode for now
      // If you want light mode later, add it here
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.dark,
      
      // GoRouter handles navigation
      routerConfig: router,
      
      // Smooth scrolling on all platforms
      scrollBehavior: const MaterialScrollBehavior().copyWith(
        physics: const BouncingScrollPhysics(),
      ),
    );
  }
}
