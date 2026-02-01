// ============================================================================
// Artist Screen - Artist profile and discography
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/lists/carousel_card.dart';

/// Artist detail screen showing bio, top songs, and albums.
class ArtistScreen extends ConsumerWidget {
  final String artistId;

  const ArtistScreen({
    super.key,
    required this.artistId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // TODO: Load artist data from provider
    
    return Scaffold(
      backgroundColor: EverblushColors.background,
      body: CustomScrollView(
        slivers: [
          // Collapsing header with artist image
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            backgroundColor: EverblushColors.background,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                'Artist Name',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: EverblushColors.textPrimary,
                ),
              ),
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Artist image placeholder
                  Container(
                    color: EverblushColors.surfaceVariant,
                    child: const Icon(
                      Icons.person_rounded,
                      size: 100,
                      color: EverblushColors.textMuted,
                    ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          EverblushColors.background.withValues(alpha: 0.7),
                          EverblushColors.background,
                        ],
                        stops: const [0.0, 0.7, 1.0],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          
          // Content
          SliverPadding(
            padding: const EdgeInsets.all(16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Stats row
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _statItem('1.2M', 'Monthly Listeners'),
                    _statItem('50', 'Songs'),
                    _statItem('5', 'Albums'),
                  ],
                ),
                
                const SizedBox(height: 24),
                
                // Play and Follow buttons
                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.play_arrow_rounded),
                        label: const Text('Play'),
                      ),
                    ),
                    const SizedBox(width: 12),
                    OutlinedButton(
                      onPressed: () {},
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: EverblushColors.primary),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                      ),
                      child: const Text(
                        'Follow',
                        style: TextStyle(color: EverblushColors.primary),
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 32),
                
                // Top Songs
                const SectionHeader(title: 'Top Songs'),
                const SizedBox(height: 12),
                ...List.generate(5, (index) => _songTile(index)),
                
                const SizedBox(height: 24),
                
                // Albums
                const SectionHeader(title: 'Albums', showSeeAll: true),
                const SizedBox(height: 12),
              ]),
            ),
          ),
          
          // Albums carousel
          SliverToBoxAdapter(
            child: SizedBox(
              height: 200,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: 5,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(right: 12),
                    child: CarouselCard(
                      width: 150,
                      title: 'Album ${index + 1}',
                      subtitle: '2024',
                      onTap: () {},
                    ),
                  );
                },
              ),
            ),
          ),
          
          const SliverToBoxAdapter(child: SizedBox(height: 100)),
        ],
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: EverblushColors.primary,
          ),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 12,
            color: EverblushColors.textMuted,
          ),
        ),
      ],
    );
  }

  Widget _songTile(int index) {
    return ListTile(
      contentPadding: EdgeInsets.zero,
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: EverblushColors.surfaceVariant,
          borderRadius: BorderRadius.circular(8),
        ),
        child: const Icon(
          Icons.music_note_rounded,
          color: EverblushColors.textMuted,
        ),
      ),
      title: Text(
        'Song ${index + 1}',
        style: const TextStyle(color: EverblushColors.textPrimary),
      ),
      subtitle: Text(
        '${(index + 1) * 1000000} plays',
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
    );
  }
}
