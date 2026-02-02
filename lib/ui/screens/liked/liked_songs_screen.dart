// ============================================================================
// Liked Songs Screen
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../providers/audio/player_provider.dart';
import '../../../providers/library/library_provider.dart';
import '../../navigation/routes.dart';
import '../../widgets/common/empty_state.dart';
import '../../widgets/lists/song_tile.dart';

/// Screen displaying liked songs.
class LikedSongsScreen extends ConsumerWidget {
  const LikedSongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final likedSongsAsync = ref.watch(likedSongsProvider);

    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: const Text(
          'Liked Songs',
          style: TextStyle(color: EverblushColors.textPrimary),
        ),
        actions: [
          likedSongsAsync.maybeWhen(
            data: (songs) => songs.isNotEmpty
                ? IconButton(
                    onPressed: () {
                      final audioHandler = ref.read(audioHandlerProvider);
                      // Shuffle and play all liked songs
                      final shuffled = List.of(songs)..shuffle();
                      if (shuffled.isNotEmpty) {
                        audioHandler.playQueue(shuffled, startIndex: 0);
                        context.push(Routes.player);
                      }
                    },
                    icon: const Icon(
                      Icons.shuffle_rounded,
                      color: EverblushColors.textSecondary,
                    ),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: likedSongsAsync.when(
        loading: () => const Center(
          child: CircularProgressIndicator(color: EverblushColors.primary),
        ),
        error: (error, _) => Center(
          child: Text(
            'Error: $error',
            style: const TextStyle(color: EverblushColors.error),
          ),
        ),
        data: (songs) {
          if (songs.isEmpty) {
            return const EmptyState(
              icon: Icons.favorite_rounded,
              title: 'No Liked Songs',
              subtitle: 'Tap the heart icon on songs you like',
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.only(bottom: 100),
            itemCount: songs.length,
            itemBuilder: (context, index) {
              final song = songs[index];
              return SongTile(
                song: song,
                onTap: () {
                  final audioHandler = ref.read(audioHandlerProvider);
                  audioHandler.playQueue(songs, startIndex: index);
                  context.push(Routes.player);
                },
              );
            },
          );
        },
      ),
    );
  }
}
