// ============================================================================
// Player Screen - Full screen music player with real playback
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/extensions/duration_extensions.dart';
import '../../../providers/audio/player_provider.dart';
import '../../navigation/routes.dart';
import '../../widgets/images/cached_artwork.dart';

/// Full-screen player with album art, progress, and controls.
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSongAsync = ref.watch(currentSongProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);

    return currentSongAsync.when(
      loading: () => _buildLoadingState(),
      error: (_, __) => _buildErrorState(context),
      data: (song) {
        if (song == null) {
          return _buildEmptyState(context);
        }

        final isPlaying = isPlayingAsync.valueOrNull ?? false;
        final position = positionAsync.valueOrNull ?? Duration.zero;
        final duration = durationAsync.valueOrNull ?? song.duration;

        return Scaffold(
          backgroundColor: EverblushColors.background,
          body: Container(
            decoration: BoxDecoration(
              gradient: AppDecorations.playerGlow(EverblushColors.primary),
            ),
            child: SafeArea(
              child: Column(
                children: [
                  // Top bar
                  _buildTopBar(context),

                  const Spacer(),

                  // Album artwork
                  _buildArtwork(song.thumbnailUrl),

                  const Spacer(),

                  // Song info
                  _buildSongInfo(song.title, song.artistName),

                  const SizedBox(height: 32),

                  // Progress bar
                  _buildProgressBar(context, ref, position, duration),

                  const SizedBox(height: 16),

                  // Main controls
                  _buildMainControls(ref, isPlaying),

                  const SizedBox(height: 24),

                  // Bottom actions
                  _buildBottomActions(context),

                  const SizedBox(height: 24),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildLoadingState() {
    return const Scaffold(
      backgroundColor: EverblushColors.background,
      body: Center(
        child: CircularProgressIndicator(color: EverblushColors.primary),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.error_outline,
              size: 64,
              color: EverblushColors.error,
            ),
            const SizedBox(height: 16),
            const Text(
              'Something went wrong',
              style: TextStyle(color: EverblushColors.textPrimary),
            ),
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.music_off,
              size: 64,
              color: EverblushColors.textMuted,
            ),
            const SizedBox(height: 16),
            const Text(
              'No song playing',
              style: TextStyle(color: EverblushColors.textMuted, fontSize: 18),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go back'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.keyboard_arrow_down_rounded,
              size: 32,
              color: EverblushColors.textPrimary,
            ),
          ),
          const Text(
            'Now Playing',
            style: TextStyle(
              color: EverblushColors.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
          IconButton(
            onPressed: () {
              // Show song menu
            },
            icon: const Icon(
              Icons.more_vert_rounded,
              color: EverblushColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(String? thumbnailUrl) {
    return Container(
      width: 280,
      height: 280,
      decoration: BoxDecoration(
        color: EverblushColors.surfaceVariant,
        borderRadius: BorderRadius.circular(20),
        boxShadow: AppDecorations.glow(EverblushColors.primary),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(20),
        child:
            thumbnailUrl != null
                ? CachedArtwork(url: thumbnailUrl, size: 280, borderRadius: 20)
                : const Icon(
                  Icons.music_note_rounded,
                  size: 100,
                  color: EverblushColors.primary,
                ),
      ),
    );
  }

  Widget _buildSongInfo(String title, String artist) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: EverblushColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Text(
            artist,
            style: const TextStyle(
              fontSize: 16,
              color: EverblushColors.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar(
    BuildContext context,
    WidgetRef ref,
    Duration position,
    Duration duration,
  ) {
    final maxValue = duration.inSeconds.toDouble();
    final currentValue = position.inSeconds.toDouble().clamp(0.0, maxValue);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        children: [
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 4,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              overlayShape: const RoundSliderOverlayShape(overlayRadius: 14),
            ),
            child: Slider(
              value: currentValue,
              max: maxValue > 0 ? maxValue : 1,
              onChanged: (value) {
                final handler = ref.read(audioHandlerProvider);
                handler.seek(Duration(seconds: value.toInt()));
              },
              activeColor: EverblushColors.primary,
              inactiveColor: EverblushColors.outline,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  position.formatted,
                  style: const TextStyle(
                    fontSize: 12,
                    color: EverblushColors.textMuted,
                  ),
                ),
                Text(
                  duration.formatted,
                  style: const TextStyle(
                    fontSize: 12,
                    color: EverblushColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainControls(WidgetRef ref, bool isPlaying) {
    final handler = ref.read(audioHandlerProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Shuffle
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.shuffle_rounded,
            color: EverblushColors.textSecondary,
          ),
        ),

        const SizedBox(width: 16),

        // Previous
        IconButton(
          onPressed: () => handler.skipToPrevious(),
          iconSize: 48,
          icon: const Icon(
            Icons.skip_previous_rounded,
            color: EverblushColors.textPrimary,
          ),
        ),

        const SizedBox(width: 8),

        // Play/Pause
        Container(
          width: 72,
          height: 72,
          decoration: const BoxDecoration(
            color: EverblushColors.primary,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            onPressed: () {
              if (isPlaying) {
                handler.pause();
              } else {
                handler.play();
              }
            },
            iconSize: 36,
            icon: Icon(
              isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded,
              color: EverblushColors.background,
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Next
        IconButton(
          onPressed: () => handler.skipToNext(),
          iconSize: 48,
          icon: const Icon(
            Icons.skip_next_rounded,
            color: EverblushColors.textPrimary,
          ),
        ),

        const SizedBox(width: 16),

        // Repeat
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.repeat_rounded,
            color: EverblushColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildBottomActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.favorite_border_rounded,
            color: EverblushColors.textSecondary,
          ),
        ),
        IconButton(
          onPressed: () => context.push(Routes.lyrics),
          icon: const Icon(
            Icons.lyrics_outlined,
            color: EverblushColors.textSecondary,
          ),
        ),
        IconButton(
          onPressed: () => context.push(Routes.queue),
          icon: const Icon(
            Icons.queue_music_rounded,
            color: EverblushColors.textSecondary,
          ),
        ),
        IconButton(
          onPressed: () {},
          icon: const Icon(
            Icons.download_outlined,
            color: EverblushColors.textSecondary,
          ),
        ),
      ],
    );
  }
}
