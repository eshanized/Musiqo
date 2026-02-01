// ============================================================================
// History Screen
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../widgets/common/empty_state.dart';

/// Screen displaying play history.
class HistoryScreen extends ConsumerWidget {
  const HistoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: const Text(
          'Recently Played',
          style: TextStyle(color: EverblushColors.textPrimary),
        ),
        actions: [
          TextButton(
            onPressed: () {
              // TODO: Clear history
            },
            child: const Text('Clear'),
          ),
        ],
      ),
      body: const EmptyState(
        icon: Icons.history_rounded,
        title: 'No History Yet',
        subtitle: 'Songs you play will appear here',
      ),
    );
  }
}
