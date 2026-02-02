// ============================================================================
// Player Screen - Full screen music player with shuffle/repeat/queue
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../core/theme/app_decorations.dart';
import '../../../core/extensions/duration_extensions.dart';
import '../../../providers/audio/player_provider.dart';
import '../../../providers/library/library_provider.dart' show likedSongsProvider, toggleLike;
import '../../../services/audio/audio_handler.dart';
import '../../navigation/routes.dart';
import '../../widgets/images/cached_artwork.dart';
import '../../widgets/dialogs/song_options_sheet.dart';

/// Full-screen player with album art, progress, and controls.
class PlayerScreen extends ConsumerWidget {
  const PlayerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSongAsync = ref.watch(currentSongProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);
    final shuffleAsync = ref.watch(shuffleEnabledProvider);
    final repeatModeAsync = ref.watch(repeatModeProvider);

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
        final shuffleEnabled = shuffleAsync.valueOrNull ?? false;
        final repeatMode = repeatModeAsync.valueOrNull ?? RepeatMode.off;

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
                  _buildTopBar(context, ref),

                  const Spacer(),

                  // Album artwork
                  _buildArtwork(song.thumbnailUrl),

                  const Spacer(),

                  // Song info
                  _buildSongInfo(ref, song.title, song.artistName),

                  const SizedBox(height: 32),

                  // Progress bar
                  _buildProgressBar(context, ref, position, duration),

                  const SizedBox(height: 16),

                  // Main controls with shuffle/repeat
                  _buildMainControls(ref, isPlaying, shuffleEnabled, repeatMode),

                  const SizedBox(height: 24),

                  // Bottom actions
                  _buildBottomActions(context, ref),

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
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: EverblushColors.primary),
            SizedBox(height: 16),
            Text(
              'Loading song...',
              style: TextStyle(color: EverblushColors.textMuted),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      body: SafeArea(
        child: Center(
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
                'Failed to load song',
                style: TextStyle(color: EverblushColors.textPrimary, fontSize: 18),
              ),
              const SizedBox(height: 8),
              const Text(
                'Check your network connection',
                style: TextStyle(color: EverblushColors.textMuted),
              ),
              const SizedBox(height: 24),
              OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go back'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      body: SafeArea(
        child: Center(
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
              const SizedBox(height: 8),
              const Text(
                'Search for something to play',
                style: TextStyle(color: EverblushColors.textMuted, fontSize: 14),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Go back'),
                  ),
                  const SizedBox(width: 16),
                  FilledButton.icon(
                    onPressed: () => context.push(Routes.search),
                    icon: const Icon(Icons.search),
                    label: const Text('Search'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(BuildContext context, WidgetRef ref) {
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
          Builder(
            builder: (context) {
              final song = ref.watch(currentSongProvider).valueOrNull;
              return IconButton(
                onPressed: song != null
                    ? () => SongOptionsSheet.show(context, song)
                    : null,
                icon: const Icon(
                  Icons.more_vert_rounded,
                  color: EverblushColors.textPrimary,
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildArtwork(String? thumbnailUrl) {
    return Hero(
      tag: 'album_art',
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: EverblushColors.surfaceVariant,
          borderRadius: BorderRadius.circular(20),
          boxShadow: AppDecorations.glow(EverblushColors.primary),
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: thumbnailUrl != null
              ? CachedArtwork(url: thumbnailUrl, size: 280, borderRadius: 20)
              : const Icon(
                  Icons.music_note_rounded,
                  size: 100,
                  color: EverblushColors.primary,
                ),
        ),
      ),
    );
  }

  Widget _buildSongInfo(WidgetRef ref, String title, String artist) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: EverblushColors.textPrimary,
            ),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 4),
          Builder(
            builder: (context) {
              final song = ref.watch(currentSongProvider).valueOrNull;
              final artistId = song?.artists.isNotEmpty == true ? song!.artists.first.id : null;
              return GestureDetector(
                onTap: artistId != null && artistId.isNotEmpty
                    ? () => context.push('/artist/$artistId')
                    : null,
                child: Text(
                  artist,
                  style: TextStyle(
                    fontSize: 15,
                    color: artistId != null && artistId.isNotEmpty
                        ? EverblushColors.textSecondary
                        : EverblushColors.textMuted,
                    decoration: artistId != null && artistId.isNotEmpty
                        ? TextDecoration.underline
                        : null,
                    decorationColor: EverblushColors.textSecondary.withValues(alpha: 0.5),
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              );
            },
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
    final maxValue = duration.inMilliseconds.toDouble();
    final currentValue = position.inMilliseconds.toDouble().clamp(0.0, maxValue);

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
                handler.seek(Duration(milliseconds: value.toInt()));
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

  Widget _buildMainControls(
    WidgetRef ref, 
    bool isPlaying, 
    bool shuffleEnabled, 
    RepeatMode repeatMode,
  ) {
    final handler = ref.read(audioHandlerProvider);

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Shuffle
        IconButton(
          onPressed: () => toggleShuffle(ref),
          icon: Icon(
            Icons.shuffle_rounded,
            color: shuffleEnabled 
                ? EverblushColors.primary 
                : EverblushColors.textSecondary,
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
          decoration: BoxDecoration(
            color: EverblushColors.primary,
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: EverblushColors.primary.withValues(alpha: 0.3),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
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
          onPressed: () => cycleRepeatMode(ref),
          icon: Icon(
            _getRepeatIcon(repeatMode),
            color: repeatMode != RepeatMode.off 
                ? EverblushColors.primary 
                : EverblushColors.textSecondary,
          ),
        ),
      ],
    );
  }

  IconData _getRepeatIcon(RepeatMode mode) {
    switch (mode) {
      case RepeatMode.off:
      case RepeatMode.all:
        return Icons.repeat_rounded;
      case RepeatMode.one:
        return Icons.repeat_one_rounded;
    }
  }

  Widget _buildBottomActions(BuildContext context, WidgetRef ref) {
    final song = ref.watch(currentSongProvider).valueOrNull;
    final likedSongsAsync = ref.watch(likedSongsProvider);
    final isLiked = likedSongsAsync.maybeWhen(
      data: (songs) => songs.any((s) => s.id == song?.id),
      orElse: () => false,
    );

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildActionButton(
            icon: isLiked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
            label: isLiked ? 'Liked' : 'Like',
            isActive: isLiked,
            onTap: () async {
              if (song != null) {
                await toggleLike(ref, song);
              }
            },
          ),
          _buildActionButton(
            icon: Icons.lyrics_outlined,
            label: 'Lyrics',
            onTap: () => context.push(Routes.lyrics),
          ),
          _buildActionButton(
            icon: Icons.queue_music_rounded,
            label: 'Queue',
            onTap: () => context.push(Routes.queue),
          ),
          _buildActionButton(
            icon: Icons.share_rounded,
            label: 'Share',
            onTap: () {
              if (song != null) {
                Share.share(
                  'Check out "${song.title}" by ${song.artistName} on Musiqo!',
                );
              }
            },
          ),
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isActive = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon, 
              color: isActive ? EverblushColors.primary : EverblushColors.textSecondary, 
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isActive ? EverblushColors.primary : EverblushColors.textMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
