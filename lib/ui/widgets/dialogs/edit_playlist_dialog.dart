// ============================================================================
// Edit Playlist Dialog - UI for renaming/editing playlists
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/playlist.dart';
import '../../../providers/playlist/playlist_provider.dart';

/// Dialog for editing an existing playlist
class EditPlaylistDialog extends ConsumerStatefulWidget {
  final Playlist playlist;

  const EditPlaylistDialog({super.key, required this.playlist});

  static Future<void> show(BuildContext context, Playlist playlist) {
    return showDialog(
      context: context,
      builder: (context) => EditPlaylistDialog(playlist: playlist),
    );
  }

  @override
  ConsumerState<EditPlaylistDialog> createState() => _EditPlaylistDialogState();
}

class _EditPlaylistDialogState extends ConsumerState<EditPlaylistDialog> {
  late final TextEditingController _nameController;
  late final TextEditingController _descController;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController(text: widget.playlist.name);
    _descController = TextEditingController(text: widget.playlist.description);
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descController.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) return;

    setState(() => _isLoading = true);
    
    try {
      final updatedPlaylist = widget.playlist.copyWith(
        name: name,
        description: _descController.text.trim(),
      );
      
      await ref.read(playlistActionsProvider.notifier).updatePlaylist(updatedPlaylist);
      
      if (mounted) Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to update playlist: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      backgroundColor: EverblushColors.surface,
      title: const Text(
        'Edit Playlist',
        style: TextStyle(color: EverblushColors.textPrimary),
      ),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _nameController,
            autofocus: true,
            style: const TextStyle(color: EverblushColors.textPrimary),
            decoration: InputDecoration(
              labelText: 'Name',
              labelStyle: TextStyle(color: EverblushColors.textMuted),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: EverblushColors.surfaceVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: EverblushColors.primary),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _descController,
            style: const TextStyle(color: EverblushColors.textPrimary),
            maxLines: 2,
            decoration: InputDecoration(
              labelText: 'Description',
              labelStyle: TextStyle(color: EverblushColors.textMuted),
              enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(color: EverblushColors.surfaceVariant),
                borderRadius: BorderRadius.circular(8),
              ),
              focusedBorder: OutlineInputBorder(
                borderSide: const BorderSide(color: EverblushColors.primary),
                borderRadius: BorderRadius.circular(8),
              ),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: _isLoading ? null : _save,
          child: _isLoading
              ? const SizedBox(
                  width: 16,
                  height: 16,
                  child: CircularProgressIndicator(strokeWidth: 2),
                )
              : const Text('Save'),
        ),
      ],
    );
  }
}
