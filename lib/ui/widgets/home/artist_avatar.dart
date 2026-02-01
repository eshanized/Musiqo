// ============================================================================
// Artist Avatar - Circular artist card with glow effect
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../data/models/song.dart';
import '../images/cached_artwork.dart';

/// Circular artist avatar with name and subtle glow effect.
class ArtistAvatar extends StatefulWidget {
  final Artist artist;
  final double size;
  final VoidCallback? onTap;

  const ArtistAvatar({
    super.key,
    required this.artist,
    this.size = 100,
    this.onTap,
  });

  @override
  State<ArtistAvatar> createState() => _ArtistAvatarState();
}

class _ArtistAvatarState extends State<ArtistAvatar> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: widget.onTap,
      onTapDown: (_) => setState(() => _isHovered = true),
      onTapUp: (_) => setState(() => _isHovered = false),
      onTapCancel: () => setState(() => _isHovered = false),
      child: SizedBox(
        width: widget.size,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Avatar with glow
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: _isHovered
                    ? [
                        BoxShadow(
                          color: EverblushColors.primary.withValues(alpha: 0.5),
                          blurRadius: 20,
                          spreadRadius: 2,
                        ),
                      ]
                    : [
                        BoxShadow(
                          color: Colors.black.withValues(alpha: 0.3),
                          blurRadius: 8,
                          offset: const Offset(0, 3),
                        ),
                      ],
              ),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                padding: EdgeInsets.all(_isHovered ? 3 : 0),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: _isHovered
                      ? Border.all(
                          color: EverblushColors.primary,
                          width: 2,
                        )
                      : null,
                ),
                child: ClipOval(
                  child: widget.artist.thumbnailUrl != null
                      ? CachedArtwork(
                          url: widget.artist.thumbnailUrl,
                          size: widget.size - (_isHovered ? 6 : 0),
                          isCircular: true,
                        )
                      : Container(
                          width: widget.size - (_isHovered ? 6 : 0),
                          height: widget.size - (_isHovered ? 6 : 0),
                          color: EverblushColors.surfaceVariant,
                          child: Icon(
                            Icons.person_rounded,
                            color: EverblushColors.textMuted,
                            size: widget.size * 0.4,
                          ),
                        ),
                ),
              ),
            ),
            const SizedBox(height: 10),

            // Name
            Text(
              widget.artist.name,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w500,
                color: _isHovered 
                    ? EverblushColors.primary 
                    : EverblushColors.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Horizontal scrolling list of artist avatars
class ArtistAvatarList extends StatelessWidget {
  final String title;
  final List<Artist> artists;
  final Function(Artist)? onArtistTap;
  final double avatarSize;

  const ArtistAvatarList({
    super.key,
    required this.title,
    required this.artists,
    this.onArtistTap,
    this.avatarSize = 100,
  });

  @override
  Widget build(BuildContext context) {
    if (artists.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
              color: EverblushColors.textPrimary,
            ),
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: avatarSize + 40,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            itemCount: artists.length,
            itemBuilder: (context, index) {
              return Padding(
                padding: const EdgeInsets.only(right: 16),
                child: ArtistAvatar(
                  artist: artists[index],
                  size: avatarSize,
                  onTap: () => onArtistTap?.call(artists[index]),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
