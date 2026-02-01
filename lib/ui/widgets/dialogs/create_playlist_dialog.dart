// ============================================================================
// Create Playlist Dialog
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// Dialog for creating a new playlist.
class CreatePlaylistDialog extends StatefulWidget {
  const CreatePlaylistDialog({super.key});

  /// Show the dialog and return playlist name if created
  static Future<String?> show(BuildContext context) {
    return showDialog<String>(
      context: context,
      builder: (context) => const CreatePlaylistDialog(),
    );
  }

  @override
  State<CreatePlaylistDialog> createState() => _CreatePlaylistDialogState();
}

class _CreatePlaylistDialogState extends State<CreatePlaylistDialog> {
  final _controller = TextEditingController();
  bool _isValid = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(() {
      setState(() {
        _isValid = _controller.text.trim().isNotEmpty;
      });
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: EverblushColors.surface,
      title: const Text(
        'New Playlist',
        style: TextStyle(color: EverblushColors.textPrimary),
      ),
      content: TextField(
        controller: _controller,
        autofocus: true,
        style: const TextStyle(color: EverblushColors.textPrimary),
        decoration: const InputDecoration(
          hintText: 'Playlist name',
          hintStyle: TextStyle(color: EverblushColors.textMuted),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: EverblushColors.outline),
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: EverblushColors.primary),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text(
            'Cancel',
            style: TextStyle(color: EverblushColors.textMuted),
          ),
        ),
        TextButton(
          onPressed: _isValid
              ? () => Navigator.pop(context, _controller.text.trim())
              : null,
          child: Text(
            'Create',
            style: TextStyle(
              color: _isValid
                  ? EverblushColors.primary
                  : EverblushColors.textMuted,
            ),
          ),
        ),
      ],
    );
  }
}
