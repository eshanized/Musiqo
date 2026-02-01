// ============================================================================
// Home Parser - Parse home page from InnerTube
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import '../youtube_facade.dart';
import '../../../data/models/song.dart';

/// Parser for YouTube Music home page.
class HomeParser {
  const HomeParser();

  /// Parse home page response
  HomePageData parse(Map<String, dynamic> response) {
    final sections = <HomeSection>[];

    try {
      final contents =
          response['contents']?['singleColumnBrowseResultsRenderer']?['tabs']?[0]?['tabRenderer']?['content']?['sectionListRenderer']?['contents']
              as List?;

      if (contents == null) return const HomePageData();

      for (final content in contents) {
        final shelf =
            content['musicCarouselShelfRenderer'] ??
            content['musicImmersiveCarouselShelfRenderer'];

        if (shelf != null) {
          final section = _parseShelf(shelf);
          if (section != null) {
            sections.add(section);
          }
        }
      }
    } catch (e) {
      // Parsing is fragile, return what we have
    }

    return HomePageData(sections: sections);
  }

  HomeSection? _parseShelf(Map<String, dynamic> shelf) {
    final header = shelf['header']?['musicCarouselShelfBasicHeaderRenderer'];
    final title = _getText(header?['title']);

    if (title.isEmpty) return null;

    final contents = shelf['contents'] as List? ?? [];
    final items = <dynamic>[];

    for (final content in contents) {
      final item = _parseShelfItem(content);
      if (item != null) {
        items.add(item);
      }
    }

    return HomeSection(
      title: title,
      subtitle: _getText(header?['strapline']),
      items: items,
    );
  }

  dynamic _parseShelfItem(Map<String, dynamic> content) {
    final twoRow = content['musicTwoRowItemRenderer'];
    if (twoRow != null) {
      return _parseTwoRowItem(twoRow);
    }

    final responsive = content['musicResponsiveListItemRenderer'];
    if (responsive != null) {
      return _parseResponsiveItem(responsive);
    }

    return null;
  }

  Song? _parseTwoRowItem(Map<String, dynamic> item) {
    final navEndpoint = item['navigationEndpoint'];
    final watchEndpoint = navEndpoint?['watchEndpoint'];

    if (watchEndpoint == null) return null;

    final videoId = watchEndpoint['videoId'] as String?;
    if (videoId == null) return null;

    return Song(
      id: videoId,
      title: _getText(item['title']),
      artists: [Artist(id: '', name: _getText(item['subtitle']))],
      duration: Duration.zero,
      thumbnailUrl: _getThumbnail(item['thumbnailRenderer']),
    );
  }

  Song? _parseResponsiveItem(Map<String, dynamic> item) {
    final flexColumns = item['flexColumns'] as List? ?? [];
    if (flexColumns.isEmpty) return null;

    final playEndpoint =
        item['overlay']?['musicItemThumbnailOverlayRenderer']?['content']?['musicPlayButtonRenderer']?['playNavigationEndpoint']?['watchEndpoint'];

    if (playEndpoint == null) return null;

    final videoId = playEndpoint['videoId'] as String?;
    if (videoId == null) return null;

    return Song(
      id: videoId,
      title: _getFlexColumnText(flexColumns, 0),
      artists: [Artist(id: '', name: _getFlexColumnText(flexColumns, 1))],
      duration: Duration.zero,
      thumbnailUrl: _getThumbnailFromItem(item),
    );
  }

  String _getText(Map<String, dynamic>? textObj) {
    if (textObj == null) return '';

    if (textObj.containsKey('simpleText')) {
      return textObj['simpleText'] as String;
    }

    final runs = textObj['runs'] as List?;
    if (runs != null && runs.isNotEmpty) {
      return runs.map((r) => r['text']).join('');
    }

    return '';
  }

  String _getFlexColumnText(List flexColumns, int index) {
    if (index >= flexColumns.length) return '';
    return _getText(
      flexColumns[index]['musicResponsiveListItemFlexColumnRenderer']?['text'],
    );
  }

  String? _getThumbnail(Map<String, dynamic>? renderer) {
    final thumbnails =
        renderer?['musicThumbnailRenderer']?['thumbnail']?['thumbnails']
            as List?;
    if (thumbnails == null || thumbnails.isEmpty) return null;
    return thumbnails.last['url'] as String?;
  }

  String? _getThumbnailFromItem(Map<String, dynamic> item) {
    final thumbnails =
        item['thumbnail']?['musicThumbnailRenderer']?['thumbnail']?['thumbnails']
            as List?;
    if (thumbnails == null || thumbnails.isEmpty) return null;
    return thumbnails.last['url'] as String?;
  }
}
