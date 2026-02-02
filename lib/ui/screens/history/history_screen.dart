// ============================================================================
// History Screen
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

/// Screen displaying play history.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final historyAsync = ref.watch(recentHistoryProvider);

    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: const Text(
          'Recently Played',
          style: TextStyle(color: EverblushColors.textPrimary),
        ),
        actions: [
          historyAsync.maybeWhen(
            data: (songs) => songs.isNotEmpty
                ? TextButton(
                    onPressed: () => _showClearDialog(context, ref),
                    child: const Text('Clear'),
                  )
                : const SizedBox.shrink(),
            orElse: () => const SizedBox.shrink(),
          ),
        ],
      ),
      body: historyAsync.when(
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
              icon: Icons.history_rounded,
              title: 'No History Yet',
              subtitle: 'Songs you play will appear here',
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
                  audioHandler.playSong(song);
                  context.push(Routes.player);
                },
              );
            },
          );
        },
      ),
    );
  }

  void _showClearDialog(BuildContext context, WidgetRef ref) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: EverblushColors.surface,
        title: const Text(
          'Clear History',
          style: TextStyle(color: EverblushColors.textPrimary),
        ),
        content: const Text(
          'This will remove all your play history. This action cannot be undone.',
          style: TextStyle(color: EverblushColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () async {
              final repo = ref.read(historyRepositoryProvider);
              await repo.clearHistory();
              ref.invalidate(recentHistoryProvider);
              if (context.mounted) {
                Navigator.pop(context);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('History cleared')),
                );
              }
            },
            child: const Text(
              'Clear',
              style: TextStyle(color: EverblushColors.error),
            ),
          ),
        ],
      ),
    );
  }
}
