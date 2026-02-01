// ============================================================================
// YouTube Provider - Riverpod provider for YouTube API
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../services/innertube/youtube_facade.dart';
import '../../services/innertube/innertube_client.dart';
import '../../core/utils/logger.dart';

/// Provider for the InnerTube client (low-level API access)
final innerTubeClientProvider = Provider<InnerTubeClient>((ref) {
  return InnerTubeClient();
});

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
  Log.info('Fetching home page data...', tag: 'HomeProvider');
  try {
    final data = await youtube.getHomePage();
    Log.info('Home page loaded: ${data.sections.length} sections', tag: 'HomeProvider');
    for (final section in data.sections) {
      Log.info('  Section: ${section.title} - ${section.items.length} items', tag: 'HomeProvider');
    }
    return data;
  } catch (e, stack) {
    Log.error('Failed to load home page', error: e, tag: 'HomeProvider');
    Log.error('Stack: $stack', tag: 'HomeProvider');
    rethrow;
  }
});
