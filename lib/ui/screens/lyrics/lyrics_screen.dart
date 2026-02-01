// ============================================================================
// Lyrics Screen - Full screen lyrics view
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../widgets/lyrics/lyrics_view.dart';
import '../../../data/models/lyrics.dart';

/// Full screen lyrics display with synced scrolling.
class LyricsScreen extends ConsumerWidget {
  const LyricsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Get from lyrics provider
    final lyrics = Lyrics(
      songId: 'test',
      plainText: '''
      These are sample lyrics
      For the current song
      They would scroll automatically
      When synced lyrics are available
      
      This is a beautiful app
      Made with love and care
      Enjoy your music journey
      With Musiqo
      ''',
      source: LyricsSource.lrclib,
    );

    final position = Duration.zero; // TODO: Get from player

    return Scaffold(
      backgroundColor: EverblushColors.background,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          onPressed: () => Navigator.pop(context),
          icon: const Icon(Icons.close_rounded),
        ),
        title: const Text(
          'Lyrics',
          style: TextStyle(color: EverblushColors.textPrimary),
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              EverblushColors.primary.withValues(alpha: 0.2),
              EverblushColors.background,
            ],
          ),
        ),
        child: LyricsView(
          lyrics: lyrics,
          currentPosition: position,
          onLineTap: (position) {
            // TODO: Seek to position
          },
        ),
      ),
    );
  }
}
