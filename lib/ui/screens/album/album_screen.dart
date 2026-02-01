// ============================================================================
// Album Screen - Album details and track list
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';

/// Album detail screen showing tracks and info.
class AlbumScreen extends ConsumerWidget {
  final String albumId;

  const AlbumScreen({
    super.key,
    required this.albumId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      body: CustomScrollView(
        slivers: [
          // Collapsing header with album art
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: EverblushColors.background,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Album art placeholder
                  Container(
                    margin: const EdgeInsets.all(48),
                    decoration: BoxDecoration(
                      color: EverblushColors.surfaceVariant,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(
                      Icons.album_rounded,
                      size: 80,
                      color: EverblushColors.textMuted,
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Album info
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Album Name',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: EverblushColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Artist Name',
                    style: TextStyle(
                      fontSize: 16,
                      color: EverblushColors.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    '2024 • 12 songs • 45 min',
                    style: TextStyle(
                      fontSize: 12,
                      color: EverblushColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 16),
                  
                  // Action buttons
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play'),
                      ),
                      const SizedBox(width: 12),
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.favorite_border_rounded,
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
                      IconButton(
                        onPressed: () {},
                        icon: const Icon(
                          Icons.share_outlined,
                          color: EverblushColors.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          
          // Track list
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(
                  leading: SizedBox(
                    width: 32,
                    child: Text(
                      '${index + 1}',
                      style: const TextStyle(
                        color: EverblushColors.textMuted,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                  title: Text(
                    'Track ${index + 1}',
                    style: const TextStyle(color: EverblushColors.textPrimary),
                  ),
                  subtitle: Text(
                    '${3 + (index % 2)}:${30 + (index * 5) % 30}',
                    style: const TextStyle(
                      fontSize: 12,
                      color: EverblushColors.textMuted,
                    ),
                  ),
                  trailing: IconButton(
                    onPressed: () {},
                    icon: const Icon(
                      Icons.more_vert,
                      color: EverblushColors.textMuted,
                    ),
                  ),
                  onTap: () {
                    // TODO: Play track
                  },
                );
              },
              childCount: 12,
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }
}
