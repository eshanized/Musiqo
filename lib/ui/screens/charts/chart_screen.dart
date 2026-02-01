// ============================================================================
// Chart Screen - Top charts
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// Top music charts screen.
class ChartScreen extends StatelessWidget {
  final String chartId;
  final String chartName;

  const ChartScreen({
    super.key,
    required this.chartId,
    required this.chartName,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: Text(
          chartName,
          style: const TextStyle(color: EverblushColors.textPrimary),
        ),
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: 100,
        itemBuilder: (context, index) {
          return ListTile(
            leading: SizedBox(
              width: 30,
              child: Text(
                '${index + 1}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: index < 3
                      ? EverblushColors.primary
                      : EverblushColors.textSecondary,
                ),
              ),
            ),
            title: Text(
              'Chart Song ${index + 1}',
              style: const TextStyle(color: EverblushColors.textPrimary),
            ),
            subtitle: const Text(
              'Artist Name',
              style: TextStyle(color: EverblushColors.textMuted),
            ),
            trailing: const Icon(
              Icons.play_arrow_rounded,
              color: EverblushColors.primary,
            ),
          );
        },
      ),
    );
  }
}
