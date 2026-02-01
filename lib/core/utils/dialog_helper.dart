// ============================================================================
// Dialog Helper - Show dialogs consistently
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../theme/everblush_colors.dart';

/// Helper for showing dialogs.
class DialogHelper {
  DialogHelper._();

  /// Show a confirmation dialog
  static Future<bool> confirm(
    BuildContext context, {
    required String title,
    required String message,
    String confirmLabel = 'Confirm',
    String cancelLabel = 'Cancel',
    bool isDestructive = false,
  }) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: EverblushColors.surface,
        title: Text(
          title,
          style: const TextStyle(color: EverblushColors.textPrimary),
        ),
        content: Text(
          message,
          style: const TextStyle(color: EverblushColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              cancelLabel,
              style: const TextStyle(color: EverblushColors.textMuted),
            ),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: Text(
              confirmLabel,
              style: TextStyle(
                color: isDestructive
                    ? EverblushColors.error
                    : EverblushColors.primary,
              ),
            ),
          ),
        ],
      ),
    );
    return result ?? false;
  }

  /// Show an alert dialog
  static Future<void> alert(
    BuildContext context, {
    required String title,
    required String message,
    String buttonLabel = 'OK',
  }) async {
    await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: EverblushColors.surface,
        title: Text(
          title,
          style: const TextStyle(color: EverblushColors.textPrimary),
        ),
        content: Text(
          message,
          style: const TextStyle(color: EverblushColors.textSecondary),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              buttonLabel,
              style: const TextStyle(color: EverblushColors.primary),
            ),
          ),
        ],
      ),
    );
  }
}
