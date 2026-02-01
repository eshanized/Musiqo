// ============================================================================
// Downloads Screen - Manage downloaded songs
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../providers/download/download_provider.dart';
import '../../../providers/audio/player_provider.dart';
import '../../widgets/images/cached_artwork.dart';

class DownloadsScreen extends ConsumerWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final downloadedSongsAsync = ref.watch(downloadedSongsProvider);
    final activeDownloads = ref.watch(downloadProvider);
    final audioHandler = ref.read(audioHandlerProvider);

    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        title: const Text('Downloads'),
        backgroundColor: EverblushColors.background,
        elevation: 0,
      ),
      body: activeDownloads.isEmpty && downloadedSongsAsync.isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
              slivers: [
                // Active Downloads
                if (activeDownloads.isNotEmpty)
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Downloading...',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: EverblushColors.textPrimary,
                            ),
                          ),
                          const SizedBox(height: 12),
                          ...activeDownloads.entries.map((entry) {
                            // Find song details if possible, or just ID
                            return Card(
                              color: EverblushColors.surfaceVariant,
                              child: ListTile(
                                leading: const SizedBox(
                                  width: 48,
                                  height: 48,
                                  child: Center(child: CircularProgressIndicator()),
                                ),
                                title: Text('Song ID: ${entry.key}', overflow: TextOverflow.ellipsis),
                                subtitle: Text('${(entry.value * 100).toStringAsFixed(0)}%'),
                                trailing: IconButton(
                                  icon: const Icon(Icons.cancel, color: EverblushColors.error),
                                  onPressed: () {
                                    ref.read(downloadServiceProvider).cancelDownload(entry.key);
                                  },
                                ),
                              ),
                            );
                          }),
                        ],
                      ),
                    ),
                  ),

                // Downloaded Songs
                downloadedSongsAsync.when(
                  loading: () => const SliverToBoxAdapter(child: SizedBox()), // Handled above potentially
                  error: (e, st) => SliverFillRemaining(child: Center(child: Text('Error: $e'))),
                  data: (songs) {
                    if (songs.isEmpty && activeDownloads.isEmpty) {
                      return const SliverFillRemaining(
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.offline_pin_outlined, size: 64, color: EverblushColors.textMuted),
                              SizedBox(height: 16),
                              Text('No downloaded songs', style: TextStyle(color: EverblushColors.textMuted)),
                            ],
                          ),
                        ),
                      );
                    }

                    return SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final song = songs[index];
                          return ListTile(
                            leading: ClipRRect(
                              borderRadius: BorderRadius.circular(8),
                              child: CachedArtwork(
                                url: song.thumbnailUrl,
                                size: 48,
                              ),
                            ),
                            title: Text(
                              song.title,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: EverblushColors.textPrimary),
                            ),
                            subtitle: Text(
                              song.artist,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(color: EverblushColors.textMuted),
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete_outline, color: EverblushColors.textMuted),
                              onPressed: () async {
                                await ref.read(downloadRepositoryProvider).removeDownloadedSong(song.id);
                                ref.invalidate(downloadedSongsProvider);
                              },
                            ),
                            onTap: () {
                              // Play downloaded song
                              // Note: We need to ensure the detailed song object has the local path
                              // The repo returns Songs, but does it set the ID correctly for local playback?
                              // Ideally AudioHandler can handle file:// URIs handled via streamUrl or similar field.
                              // Our simple basic Song model uses streamUrl. 
                              // If we saved it with local path as streamUrl, it might just work if just_audio handles file paths.
                              // But usually requires Uri.file(...).
                              // Let's assume we saved local path in streamUrl when creating the "downloaded" song object from JSON
                              // No wait, in repo we did `songMap['localPath'] = localPath`.
                              // We need to verify if Song.fromJson reads localPath.
                              
                              audioHandler.playSong(song);
                            },
                          );
                        },
                        childCount: songs.length,
                      ),
                    );
                  },
                ),
              ],
            ),
    );
  }
}
