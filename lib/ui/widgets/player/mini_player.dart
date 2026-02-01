// ============================================================================
// Mini Player - The compact player at the bottom with real playback state
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../core/constants/app_constants.dart';
import '../../../providers/audio/player_provider.dart';
import '../../navigation/routes.dart';
import '../images/cached_artwork.dart';

/// A compact player bar that appears when music is playing.
class MiniPlayer extends ConsumerWidget {
  const MiniPlayer({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentSongAsync = ref.watch(currentSongProvider);
    final isPlayingAsync = ref.watch(isPlayingProvider);
    final positionAsync = ref.watch(positionProvider);
    final durationAsync = ref.watch(durationProvider);

    return currentSongAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (song) {
        if (song == null) {
          return const SizedBox.shrink();
        }

        final isPlaying = isPlayingAsync.valueOrNull ?? false;
        final position = positionAsync.valueOrNull ?? Duration.zero;
        final duration = durationAsync.valueOrNull ?? song.duration;
        final progress =
            duration.inMilliseconds > 0
                ? position.inMilliseconds / duration.inMilliseconds
                : 0.0;

        return GestureDetector(
          onTap: () => context.push(Routes.player),
          child: Container(
            height: AppConstants.miniPlayerHeight,
            decoration: const BoxDecoration(
              color: EverblushColors.surface,
              border: Border(
                top: BorderSide(color: EverblushColors.outline, width: 0.5),
              ),
            ),
            child: Column(
              children: [
                // Progress indicator line
                LinearProgressIndicator(
                  value: progress.clamp(0.0, 1.0),
                  backgroundColor: EverblushColors.outline,
                  valueColor: const AlwaysStoppedAnimation(
                    EverblushColors.primary,
                  ),
                  minHeight: 2,
                ),

                // Player content
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Row(
                      children: [
                        // Album art
                        ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child:
                              song.thumbnailUrl != null
                                  ? CachedArtwork(
                                    url: song.thumbnailUrl,
                                    size: 48,
                                    borderRadius: 8,
                                  )
                                  : Container(
                                    width: 48,
                                    height: 48,
                                    color: EverblushColors.surfaceVariant,
                                    child: const Icon(
                                      Icons.music_note_rounded,
                                      color: EverblushColors.primary,
                                    ),
                                  ),
                        ),

                        const SizedBox(width: 12),

                        // Song info
                        Expanded(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                song.title,
                                style: const TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: EverblushColors.textPrimary,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                song.artistName,
                                style: const TextStyle(
                                  fontSize: 12,
                                  color: EverblushColors.textMuted,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),

                        // Play/Pause button
                        IconButton(
                          onPressed: () {
                            final handler = ref.read(audioHandlerProvider);
                            if (isPlaying) {
                              handler.pause();
                            } else {
                              handler.play();
                            }
                          },
                          icon: Icon(
                            isPlaying
                                ? Icons.pause_rounded
                                : Icons.play_arrow_rounded,
                            color: EverblushColors.textPrimary,
                            size: 32,
                          ),
                        ),

                        // Next button
                        IconButton(
                          onPressed: () {
                            final handler = ref.read(audioHandlerProvider);
                            handler.skipToNext();
                          },
                          icon: const Icon(
                            Icons.skip_next_rounded,
                            color: EverblushColors.textSecondary,
                            size: 28,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
