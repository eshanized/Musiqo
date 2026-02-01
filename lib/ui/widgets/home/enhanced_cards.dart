// ============================================================================
// Enhanced Album Card - Album/Playlist card with premium styling
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../images/cached_artwork.dart';

/// Enhanced card for albums and playlists with shadows and hover effects.
class EnhancedAlbumCard extends StatefulWidget {
  final String title;
  final String? subtitle;
  final String? imageUrl;
  final double width;
  final VoidCallback? onTap;
  final bool showPlayButton;

  const EnhancedAlbumCard({
    super.key,
    required this.title,
    this.subtitle,
    this.imageUrl,
    this.width = 150,
    this.onTap,
    this.showPlayButton = true,
  });

  @override
  State<EnhancedAlbumCard> createState() => _EnhancedAlbumCardState();
}

class _EnhancedAlbumCardState extends State<EnhancedAlbumCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: SizedBox(
        width: widget.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Image with overlay
            Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _isHovered
                            ? EverblushColors.primary.withValues(alpha: 0.3)
                            : Colors.black.withValues(alpha: 0.3),
                        blurRadius: _isHovered ? 16 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.imageUrl != null
                        ? CachedArtwork(
                            url: widget.imageUrl,
                            size: widget.width,
                            borderRadius: 12,
                          )
                        : Container(
                            width: widget.width,
                            height: widget.width,
                            decoration: BoxDecoration(
                              color: EverblushColors.surfaceVariant,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Icon(
                              Icons.album_rounded,
                              size: widget.width * 0.3,
                              color: EverblushColors.textMuted,
                            ),
                          ),
                  ),
                ),

                // Hover overlay with play button
                if (widget.showPlayButton)
                  Positioned.fill(
                    child: AnimatedOpacity(
                      duration: const Duration(milliseconds: 200),
                      opacity: _isHovered ? 1.0 : 0.0,
                      child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          color: Colors.black.withValues(alpha: 0.4),
                        ),
                        child: Center(
                          child: Container(
                            width: 48,
                            height: 48,
                            decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: EverblushColors.primary,
                            ),
                            child: const Icon(
                              Icons.play_arrow_rounded,
                              color: Colors.white,
                              size: 28,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),

            const SizedBox(height: 10),

            // Title
            Text(
              widget.title,
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: _isHovered 
                    ? EverblushColors.primary 
                    : EverblushColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Subtitle
            if (widget.subtitle != null) ...[
              const SizedBox(height: 2),
              Text(
                widget.subtitle!,
                style: const TextStyle(
                  fontSize: 12,
                  color: EverblushColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}

/// Enhanced song card with play overlay
class EnhancedSongCard extends StatefulWidget {
  final String title;
  final String? artistName;
  final String? imageUrl;
  final double width;
  final VoidCallback? onTap;

  const EnhancedSongCard({
    super.key,
    required this.title,
    this.artistName,
    this.imageUrl,
    this.width = 150,
    this.onTap,
  });

  @override
  State<EnhancedSongCard> createState() => _EnhancedSongCardState();
}

class _EnhancedSongCardState extends State<EnhancedSongCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: SizedBox(
        width: widget.width,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            // Thumbnail with play overlay
            Stack(
              children: [
                AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  transform: Matrix4.diagonal3Values(
                    _isHovered ? 1.03 : 1.0,
                    _isHovered ? 1.03 : 1.0,
                    1.0,
                  ),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: _isHovered
                            ? EverblushColors.secondary.withValues(alpha: 0.4)
                            : Colors.black.withValues(alpha: 0.25),
                        blurRadius: _isHovered ? 20 : 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(12),
                    child: widget.imageUrl != null
                        ? CachedArtwork(
                            url: widget.imageUrl,
                            size: widget.width,
                            borderRadius: 12,
                          )
                        : Container(
                            width: widget.width,
                            height: widget.width,
                            color: EverblushColors.surfaceVariant,
                            child: const Icon(
                              Icons.music_note_rounded,
                              color: EverblushColors.textMuted,
                              size: 40,
                            ),
                          ),
                  ),
                ),

                // Always-visible subtle play icon
                Positioned(
                  right: 8,
                  bottom: 8,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    width: _isHovered ? 44 : 36,
                    height: _isHovered ? 44 : 36,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: _isHovered 
                          ? EverblushColors.primary
                          : Colors.black.withValues(alpha: 0.6),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 6,
                        ),
                      ],
                    ),
                    child: Icon(
                      Icons.play_arrow_rounded,
                      color: Colors.white,
                      size: _isHovered ? 26 : 20,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 10),

            // Song title
            Text(
              widget.title,
              style: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: EverblushColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),

            // Artist name
            if (widget.artistName != null) ...[
              const SizedBox(height: 2),
              Text(
                widget.artistName!,
                style: const TextStyle(
                  fontSize: 12,
                  color: EverblushColors.textMuted,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ],
        ),
      ),
    );
  }
}
