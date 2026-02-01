// ============================================================================
// YouTube Provider - Riverpod provider for YouTube API
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/innertube/youtube_facade.dart';

/// Provider for the YouTube facade
///
/// We use a simple Provider (not StateProvider) because YouTubeFacade
/// is stateless - it just makes API calls.
final youtubeProvider = Provider<YouTubeFacade>((ref) {
  return YouTubeFacade();
});

/// Provider for home page data
final homePageProvider = FutureProvider<HomePageData>((ref) async {
  final youtube = ref.watch(youtubeProvider);
  return youtube.getHomePage();
});
