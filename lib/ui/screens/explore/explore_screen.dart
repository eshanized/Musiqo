// ============================================================================
// Explore Screen - Discover new music
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../widgets/common/section_header.dart';
import '../../widgets/lists/carousel_card.dart';

/// Explore screen for discovering new music.
/// 
/// Shows:
/// - New releases
/// - Charts
/// - Moods & genres
/// - Trending artists
class ExploreScreen extends ConsumerWidget {
  const ExploreScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      body: CustomScrollView(
        slivers: [
          // App bar
          const SliverAppBar(
            floating: true,
            backgroundColor: EverblushColors.background,
            title: Text(
              'Explore',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: EverblushColors.textPrimary,
              ),
            ),
          ),
          
          // Content
          SliverPadding(
            padding: const EdgeInsets.only(bottom: 100),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                const SizedBox(height: 16),
                
                // Moods & Genres grid
                const SectionHeader(title: 'Moods & Genres'),
                const SizedBox(height: 12),
                _buildMoodsGrid(context),
                
                const SizedBox(height: 24),
                
                // New Releases
                const SectionHeader(
                  title: 'New Releases',
                  showSeeAll: true,
                ),
                const SizedBox(height: 12),
                _buildNewReleases(),
                
                const SizedBox(height: 24),
                
                // Charts
                const SectionHeader(
                  title: 'Charts',
                  subtitle: 'Top songs right now',
                ),
                const SizedBox(height: 12),
                _buildCharts(context),
                
                const SizedBox(height: 24),
                
                // Trending Artists
                const SectionHeader(
                  title: 'Trending Artists',
                  showSeeAll: true,
                ),
                const SizedBox(height: 12),
                _buildTrendingArtists(),
              ]),
            ),
          ),
        ],
      ),
    );
  }

  /// Moods and Genres grid
  Widget _buildMoodsGrid(BuildContext context) {
    final moods = [
      ('Chill', EverblushColors.tertiary),
      ('Workout', EverblushColors.error),
      ('Party', EverblushColors.secondary),
      ('Focus', EverblushColors.primary),
      ('Sleep', EverblushColors.textMuted),
      ('Romance', EverblushColors.error),
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: GridView.count(
        shrinkWrap: true,
        physics: const NeverScrollableScrollPhysics(),
        crossAxisCount: 2,
        childAspectRatio: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        children: moods.map((mood) {
          return InkWell(
            onTap: () {
              // Navigate to search with query
              context.pushNamed(
                'search', 
                extra: mood.$1, // Pass as initial query or handle in search screen
              );
            },
            borderRadius: BorderRadius.circular(12),
            child: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    mood.$2,
                    mood.$2.withValues(alpha: 0.6),
                  ],
                ),
                borderRadius: BorderRadius.circular(12),
              ),
              padding: const EdgeInsets.all(16),
              child: Align(
                alignment: Alignment.bottomLeft,
                child: Text(
                  mood.$1,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  /// New releases carousel
  Widget _buildNewReleases() {
    return SizedBox(
      height: 200,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 12),
            child: CarouselCard(
              width: 150,
              title: 'New Album ${index + 1}',
              subtitle: 'Artist Name',
              onTap: () {},
            ),
          );
        },
      ),
    );
  }

  /// Charts section
  Widget _buildCharts(BuildContext context) {
    return SizedBox(
      height: 200,
      child: ListView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _chartCard(context, 'Top 50\nGlobal', EverblushColors.primary),
          const SizedBox(width: 12),
          _chartCard(context, 'Top 50\nUSA', EverblushColors.error),
          const SizedBox(width: 12),
          _chartCard(context, 'Viral 50\nGlobal', EverblushColors.success),
          const SizedBox(width: 12),
          _chartCard(context, 'Top 50\nIndia', EverblushColors.warning),
        ],
      ),
    );
  }

  Widget _chartCard(BuildContext context, String title, Color color) {
    return GestureDetector(
      onTap: () => context.pushNamed('search', extra: title.replaceAll('\n', ' ')),
      child: Container(
        width: 150,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [color, color.withValues(alpha: 0.5)],
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Icon(Icons.bar_chart_rounded, color: Colors.white, size: 32),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Trending artists (circular)
  Widget _buildTrendingArtists() {
    return SizedBox(
      height: 160,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: 10,
        itemBuilder: (context, index) {
          return Padding(
            padding: const EdgeInsets.only(right: 16),
            child: CarouselCard(
              width: 100,
              title: 'Artist ${index + 1}',
              isCircular: true,
              onTap: () {},
            ),
          );
        },
      ),
    );
  }
}
