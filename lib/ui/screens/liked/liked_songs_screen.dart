// ============================================================================
// Liked Songs Screen
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../widgets/common/empty_state.dart';

/// Screen displaying liked songs.
class LikedSongsScreen extends ConsumerWidget {
  const LikedSongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: const Text(
          'Liked Songs',
          style: TextStyle(color: EverblushColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Shuffle play
            },
            icon: const Icon(
              Icons.shuffle_rounded,
              color: EverblushColors.textSecondary,
            ),
          ),
        ],
      ),
      body: const EmptyState(
        icon: Icons.favorite_rounded,
        title: 'No Liked Songs',
        subtitle: 'Tap the heart icon on songs you like',
      ),
    );
  }
}
