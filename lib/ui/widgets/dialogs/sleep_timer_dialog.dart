// ============================================================================
// Sleep Timer Dialog - UI for setting sleep timer
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../services/timer/sleep_timer_service.dart';

/// Sleep timer bottom sheet dialog
class SleepTimerDialog extends ConsumerWidget {
  const SleepTimerDialog({super.key});

  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: EverblushColors.surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (context) => const SleepTimerDialog(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final timerState = ref.watch(sleepTimerProvider);
    final timerNotifier = ref.read(sleepTimerProvider.notifier);

    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Handle bar
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: EverblushColors.textMuted,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Title
          const Text(
            'Sleep Timer',
            style: TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: EverblushColors.textPrimary,
            ),
          ),
          const SizedBox(height: 8),

          // Status
          if (timerState.isActive) ...[
            _buildActiveTimer(context, timerState, timerNotifier),
          ] else ...[
            const Text(
              'Set a timer to stop playback',
              style: TextStyle(color: EverblushColors.textMuted),
            ),
            const SizedBox(height: 24),
            _buildPresetGrid(context, timerNotifier),
          ],

          const SizedBox(height: 24),
        ],
      ),
    );
  }

  Widget _buildActiveTimer(
    BuildContext context,
    SleepTimerState state,
    SleepTimerNotifier notifier,
  ) {
    return Column(
      children: [
        const SizedBox(height: 24),
        
        // Timer display
        Center(
          child: Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 150,
                height: 150,
                child: CircularProgressIndicator(
                  value: state.progress,
                  strokeWidth: 8,
                  backgroundColor: EverblushColors.surfaceVariant,
                  valueColor: const AlwaysStoppedAnimation(EverblushColors.primary),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    state.displayTime,
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: EverblushColors.textPrimary,
                    ),
                  ),
                  const Text(
                    'remaining',
                    style: TextStyle(
                      color: EverblushColors.textMuted,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        
        const SizedBox(height: 32),
        
        // Action buttons
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // Add 5 minutes
            _buildActionButton(
              icon: Icons.add_rounded,
              label: '+5 min',
              onTap: () => notifier.extend(const Duration(minutes: 5)),
            ),
            // Add 10 minutes
            _buildActionButton(
              icon: Icons.add_rounded,
              label: '+10 min',
              onTap: () => notifier.extend(const Duration(minutes: 10)),
            ),
            // Cancel
            _buildActionButton(
              icon: Icons.close_rounded,
              label: 'Cancel',
              isDestructive: true,
              onTap: () {
                notifier.cancel();
                Navigator.pop(context);
              },
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPresetGrid(BuildContext context, SleepTimerNotifier notifier) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: SleepTimerPreset.values.map((preset) {
        return FilledButton.tonal(
          onPressed: () {
            notifier.startWithPreset(preset);
            Navigator.pop(context);
          },
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          ),
          child: Text(preset.label),
        );
      }).toList(),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: isDestructive
                  ? EverblushColors.error.withValues(alpha: 0.2)
                  : EverblushColors.surfaceVariant,
              shape: BoxShape.circle,
            ),
            child: Icon(
              icon,
              color: isDestructive
                  ? EverblushColors.error
                  : EverblushColors.primary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isDestructive
                  ? EverblushColors.error
                  : EverblushColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
