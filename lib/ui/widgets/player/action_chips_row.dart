// ============================================================================
// Action Chips Row - Row of action chips
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// A row of action chips for player screen.
class ActionChipsRow extends StatelessWidget {
  final bool isLiked;
  final bool isDownloaded;
  final VoidCallback? onLike;
  final VoidCallback? onDownload;
  final VoidCallback? onShare;
  final VoidCallback? onMore;

  const ActionChipsRow({
    super.key,
    this.isLiked = false,
    this.isDownloaded = false,
    this.onLike,
    this.onDownload,
    this.onShare,
    this.onMore,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _buildChip(
          icon: isLiked
              ? Icons.favorite_rounded
              : Icons.favorite_border_rounded,
          color: isLiked ? EverblushColors.error : null,
          onTap: onLike,
        ),
        const SizedBox(width: 16),
        _buildChip(
          icon: isDownloaded
              ? Icons.download_done_rounded
              : Icons.download_rounded,
          color: isDownloaded ? EverblushColors.success : null,
          onTap: onDownload,
        ),
        const SizedBox(width: 16),
        _buildChip(icon: Icons.share_rounded, onTap: onShare),
        const SizedBox(width: 16),
        _buildChip(icon: Icons.more_horiz_rounded, onTap: onMore),
      ],
    );
  }

  Widget _buildChip({
    required IconData icon,
    Color? color,
    VoidCallback? onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(10),
        decoration: BoxDecoration(
          color: EverblushColors.surface,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Icon(
          icon,
          color: color ?? EverblushColors.textSecondary,
          size: 20,
        ),
      ),
    );
  }
}
