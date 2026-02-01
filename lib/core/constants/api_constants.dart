// ============================================================================
// API Constants - YouTube InnerTube configuration
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

/// Configuration for the YouTube InnerTube API.
/// 
/// WHAT IS INNERTUBE?
/// InnerTube is YouTube's internal API. It's what the official YouTube
/// app uses behind the scenes. We use the same API to fetch music data.
/// 
/// Note: This is an unofficial API, so it might change. But OpenTune
/// and Echo-Music have been using it successfully for years!
class ApiConstants {
  ApiConstants._();

  // Base URLs
  static const String youtubeMusic = 'https://music.youtube.com';
  static const String innertubeApi = 'https://music.youtube.com/youtubei/v1';
  
  // The API key - this is publicly available in YouTube's source
  static const String apiKey = 'AIzaSyC9XL3ZjWddXya6X74dJoCTL-WEYFDNX30';
  
  // Client info - we pretend to be the web client
  static const String clientName = 'WEB_REMIX';
  static const String clientVersion = '1.20240101.01.00';
  
  // User agent - looks like a normal browser
  static const String userAgent = 
      'Mozilla/5.0 (Windows NT 10.0; Win64; x64) '
      'AppleWebKit/537.36 (KHTML, like Gecko) '
      'Chrome/120.0.0.0 Safari/537.36';
  
  // Default locale
  static const String defaultLanguage = 'en';
  static const String defaultCountry = 'US';
  
  // Browse IDs for different pages
  static const String browseHome = 'FEmusic_home';
  static const String browseExplore = 'FEmusic_explore';
  static const String browseLibrary = 'FEmusic_liked_videos';
  static const String browseHistory = 'FEmusic_history';
  static const String browseMoods = 'FEmusic_moods_and_genres';
  static const String browseCharts = 'FEmusic_charts';
  static const String browseNewReleases = 'FEmusic_new_releases_albums';
}
