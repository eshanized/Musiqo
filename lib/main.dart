// ============================================================================
// Musiqo - Main Entry Point
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// This is where the app starts! When you tap the app icon,
// Android/iOS runs this main() function.
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app.dart';
import 'core/utils/logger.dart';
import 'providers/audio/player_provider.dart';

/// The entry point of Musiqo.
///
/// WHAT HAPPENS HERE:
/// 1. We make sure Flutter is ready (ensureInitialized)
/// 2. Initialize the audio service for background playback
/// 3. Set up the status bar to look nice
/// 4. Wrap everything in ProviderScope for state management
/// 5. Launch the app!
void main() async {
  // This must be called first when using async in main
  WidgetsFlutterBinding.ensureInitialized();

  Log.info('Starting Musiqo...', tag: 'Main');

  // Initialize audio service for background playback
  try {
    await initAudioService();
    Log.info('Audio service initialized', tag: 'Main');
  } catch (e) {
    Log.error('Failed to initialize audio service', error: e, tag: 'Main');
  }

  // Make the status bar transparent with light icons
  // This gives us that edge-to-edge look
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: Colors.transparent,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Allow both portrait and landscape
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // ProviderScope is required for Riverpod to work
  // It holds all our state at the top of the widget tree
  runApp(const ProviderScope(child: MusiqoApp()));
}
