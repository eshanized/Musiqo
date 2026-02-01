// ============================================================================
// Sleep Timer Dialog
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// Dialog for setting a sleep timer.
class SleepTimerDialog extends StatelessWidget {
  const SleepTimerDialog({super.key});

  static Future<Duration?> show(BuildContext context) {
    return showDialog<Duration>(
      context: context,
      builder: (context) => const SleepTimerDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: EverblushColors.surface,
      title: const Text(
        'Sleep Timer',
        style: TextStyle(color: EverblushColors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _timerOption(context, '15 minutes', const Duration(minutes: 15)),
          _timerOption(context, '30 minutes', const Duration(minutes: 30)),
          _timerOption(context, '45 minutes', const Duration(minutes: 45)),
          _timerOption(context, '1 hour', const Duration(hours: 1)),
          _timerOption(context, '2 hours', const Duration(hours: 2)),
          _timerOption(context, 'End of track', Duration.zero),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: EverblushColors.textMuted),
          ),
        ),
      ],
    );
  }

  Widget _timerOption(BuildContext context, String label, Duration duration) {
    return ListTile(
      title: Text(
        label,
        style: const TextStyle(color: EverblushColors.textPrimary),
      ),
      onTap: () => Navigator.pop(context, duration),
    );
  }
}
