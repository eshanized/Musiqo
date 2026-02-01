// ============================================================================
// Explore Categories Widget
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/mood.dart';
import '../lists/mood_card.dart';

/// Grid of explore categories (moods and genres).
class ExploreCategories extends StatelessWidget {
  final List<Mood> moods;
  final List<Genre> genres;
  final Function(Mood)? onMoodTap;
  final Function(Genre)? onGenreTap;

  const ExploreCategories({
    super.key,
    this.moods = const [],
    this.genres = const [],
    this.onMoodTap,
    this.onGenreTap,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (moods.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Moods & Activities',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: EverblushColors.textPrimary,
                ),
              ),
            ),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: moods.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final mood = moods[index];
                  return MoodCard(
                    title: mood.name,
                    color: mood.color,
                    onTap: () => onMoodTap?.call(mood),
                  );
                },
              ),
            ),
          ],
          if (genres.isNotEmpty) ...[
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                'Genres',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: EverblushColors.textPrimary,
                ),
              ),
            ),
            SizedBox(
              height: 90,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: genres.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (context, index) {
                  final genre = genres[index];
                  return MoodCard(
                    title: genre.name,
                    color: genre.color,
                    onTap: () => onGenreTap?.call(genre),
                  );
                },
              ),
            ),
          ],
        ],
      ),
    );
  }
}
