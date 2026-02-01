// ============================================================================
// Downloaded Songs Screen
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../widgets/common/empty_state.dart';

/// Screen displaying downloaded songs.
class DownloadedSongsScreen extends ConsumerWidget {
  const DownloadedSongsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: const Text(
          'Downloaded Songs',
          style: TextStyle(color: EverblushColors.textPrimary),
        ),
        actions: [
          IconButton(
            onPressed: () {
              // TODO: Sort options
            },
            icon: const Icon(
              Icons.sort_rounded,
              color: EverblushColors.textSecondary,
            ),
          ),
        ],
      ),
      body: const EmptyState(
        icon: Icons.download_done_rounded,
        title: 'No Downloads Yet',
        subtitle: 'Download songs to listen offline',
      ),
    );
  }
}
