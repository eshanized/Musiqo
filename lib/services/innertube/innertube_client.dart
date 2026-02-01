// ============================================================================
// InnerTube API Client - The heart of YouTube Music integration
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// InnerTube is YouTube's internal API. It's the same API that the
// official YouTube apps use. We "speak" InnerTube to get music data.
// ============================================================================

import 'dart:convert';
import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:dio/dio.dart';

import '../../core/constants/api_constants.dart';
import '../../core/utils/logger.dart';

/// Different client types for different API operations.
/// 
/// WHY MULTIPLE CLIENTS?
/// YouTube requires different client types for different operations:
/// - WEB_REMIX: For browse/search operations on YouTube Music
/// - IOS: For getting stream URLs (works without authentication)
enum YouTubeClientType {
  /// YouTube Music web client - for browse, search, etc.
  webRemix,
  /// iOS app client - for getting stream URLs
  ios,
}

/// Client configuration for each client type
class YouTubeClientConfig {
  final String clientName;
  final String clientVersion;
  final String clientId;
  final String userAgent;
  final String? osVersion;
  final String apiUrl;
  
  const YouTubeClientConfig({
    required this.clientName,
    required this.clientVersion,
    required this.clientId,
    required this.userAgent,
    this.osVersion,
    required this.apiUrl,
  });
  
  static const webRemix = YouTubeClientConfig(
    clientName: 'WEB_REMIX',
    clientVersion: '1.20250310.01.00',
    clientId: '67',
    userAgent: 'Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:128.0) Gecko/20100101 Firefox/128.0',
    apiUrl: 'https://music.youtube.com/youtubei/v1',
  );
  
  static const ios = YouTubeClientConfig(
    clientName: 'IOS',
    clientVersion: '20.10.4',
    clientId: '5',
    userAgent: 'com.google.ios.youtube/20.10.4 (iPhone16,2; U; CPU iOS 18_3_2 like Mac OS X;)',
    osVersion: '18.3.2.22D82',
    apiUrl: 'https://www.youtube.com/youtubei/v1',
  );
}

/// The InnerTube API client that handles all YouTube Music requests.
/// 
/// HOW INNERTUBE WORKS:
/// 1. Every request needs a "context" with client info
/// 2. Requests go to /youtubei/v1/{endpoint}
/// 3. Responses are deeply nested JSON (we'll parse these later)
/// 
/// This class is LOW LEVEL - it just makes raw API calls.
/// Higher level classes will use this and parse the responses.
class InnerTubeClient {
  late final Dio _dioWebRemix;
  late final Dio _dioIos;
  String? _visitorData;

  InnerTubeClient() {
    _dioWebRemix = _createDio(YouTubeClientConfig.webRemix);
    _dioIos = _createDio(YouTubeClientConfig.ios);
  }
  
  Dio _createDio(YouTubeClientConfig config) {
    return Dio(BaseOptions(
      baseUrl: config.apiUrl,
      headers: {
        'User-Agent': config.userAgent,
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'Origin': 'https://music.youtube.com',
        'Referer': 'https://music.youtube.com/',
        'X-Goog-Api-Format-Version': '1',
        'X-YouTube-Client-Name': config.clientId,
        'X-YouTube-Client-Version': config.clientVersion,
      },
      responseType: ResponseType.json,
      connectTimeout: const Duration(seconds: 15),
      receiveTimeout: const Duration(seconds: 30),
    ))..interceptors.add(LogInterceptor(
        request: false,
        requestHeader: false,
        requestBody: false,
        responseHeader: false,
        responseBody: false,
        error: true,
        logPrint: (o) => Log.network('InnerTube', o.toString()),
      ));
  }

  /// Build the context object for WEB_REMIX client.
  Map<String, dynamic> _buildWebRemixContext({
    String? language,
    String? country,
  }) {
    return {
      'client': {
        'clientName': YouTubeClientConfig.webRemix.clientName,
        'clientVersion': YouTubeClientConfig.webRemix.clientVersion,
        'hl': language ?? ApiConstants.defaultLanguage,
        'gl': country ?? ApiConstants.defaultCountry,
        'platform': 'DESKTOP',
        'userAgent': YouTubeClientConfig.webRemix.userAgent,
        if (_visitorData != null) 'visitorData': _visitorData,
      },
      'user': {
        'lockedSafetyMode': false,
      },
    };
  }
  
  /// Build the context object for iOS client (for streaming).
  Map<String, dynamic> _buildIosContext({
    String? language,
    String? country,
  }) {
    return {
      'client': {
        'clientName': YouTubeClientConfig.ios.clientName,
        'clientVersion': YouTubeClientConfig.ios.clientVersion,
        'hl': language ?? ApiConstants.defaultLanguage,
        'gl': country ?? ApiConstants.defaultCountry,
        'osVersion': YouTubeClientConfig.ios.osVersion,
        'deviceMake': 'Apple',
        'deviceModel': 'iPhone16,2',
        'osName': 'iOS',
        if (_visitorData != null) 'visitorData': _visitorData,
      },
      'user': {
        'lockedSafetyMode': false,
      },
    };
  }

  /// Make a POST request to an InnerTube endpoint.
  Future<Map<String, dynamic>> _post(
    Dio dio,
    String endpoint,
    Map<String, dynamic> context, {
    Map<String, dynamic>? body,
  }) async {
    final requestBody = {
      'context': context,
      ...?body,
    };

    try {
      Log.network('POST', endpoint);
      
      final response = await dio.post(
        '/$endpoint',
        queryParameters: {'key': ApiConstants.apiKey},
        data: jsonEncode(requestBody),
      );

      if (response.data is Map) {
        final data = response.data as Map<String, dynamic>;
        _visitorData = data['responseContext']?['visitorData'] ?? _visitorData;
        return data;
      }

      return {};
    } on DioException catch (e) {
      Log.error('InnerTube request failed: ${e.message}', error: e);
      rethrow;
    }
  }

  /// Search for music (uses WEB_REMIX)
  Future<Map<String, dynamic>> search(String query, {String? filter}) {
    return _post(
      _dioWebRemix,
      'search',
      _buildWebRemixContext(),
      body: {
        'query': query,
        if (filter != null) 'params': filter,
      },
    );
  }

  /// Get next/related items (uses WEB_REMIX)
  Future<Map<String, dynamic>> next({
    required String videoId,
    String? playlistId,
  }) {
    return _post(
      _dioWebRemix, 
      'next',
      _buildWebRemixContext(),
      body: {
        'videoId': videoId,
        if (playlistId != null) 'playlistId': playlistId,
      },
    );
  }

  /// Browse a page (home, explore, etc.) (uses WEB_REMIX)
  Future<Map<String, dynamic>> browse(String browseId) {
    return _post(
      _dioWebRemix,
      'browse',
      _buildWebRemixContext(),
      body: {'browseId': browseId},
    );
  }

  /// Get player info and stream URL.
  /// 
  /// IMPORTANT: Uses iOS client which returns stream URLs without authentication!
  /// WEB_REMIX doesn't return stream URLs reliably.
  Future<Map<String, dynamic>> player(String videoId) {
    Log.info('Getting stream for video: $videoId', tag: 'Player');
    return _post(
      _dioIos,
      'player',
      _buildIosContext(),
      body: {
        'videoId': videoId,
        'playbackContext': {
          'contentPlaybackContext': {
            'html5Preference': 'HTML5_PREF_WANTS',
          },
        },
        'contentCheckOk': true,
        'racyCheckOk': true,
      },
    );
  }

  /// Get search suggestions as you type
  Future<List<String>> searchSuggestions(String query) async {
    try {
      final response = await Dio().get(
        'https://suggestqueries-clients6.youtube.com/complete/search',
        queryParameters: {
          'client': 'youtube',
          'ds': 'yt',
          'q': query,
        },
      );

      final text = response.data.toString();
      final jsonStart = text.indexOf('(') + 1;
      final jsonEnd = text.lastIndexOf(')');
      final jsonStr = text.substring(jsonStart, jsonEnd);
      
      final data = jsonDecode(jsonStr) as List;
      final suggestions = (data[1] as List)
          .map((e) => (e as List).first.toString())
          .toList();
      
      return suggestions;
    } catch (e) {
      Log.error('Failed to get suggestions', error: e);
      return [];
    }
  }

  /// Set visitor data (for personalization)
  void setVisitorData(String visitorData) {
    _visitorData = visitorData;
  }

  /// Update authentication (cookies and SAPISID) for WEB_REMIX
  void setAuth(Map<String, String> cookies) {
    _dioWebRemix.options.headers['Cookie'] = cookies.entries.map((e) => '${e.key}=${e.value}').join('; ');
    
    if (cookies.containsKey('SAPISID')) {
      final sapisid = cookies['SAPISID']!;
      _dioWebRemix.options.headers['Authorization'] = _generateAuthHeader(sapisid);
    } else {
      _dioWebRemix.options.headers.remove('Authorization');
    }
  }

  /// Clear authentication
  void clearAuth() {
    _dioWebRemix.options.headers.remove('Cookie');
    _dioWebRemix.options.headers.remove('Authorization');
  }

  /// Generate SAPISIDHASH Authorization header
  String _generateAuthHeader(String sapisid) {
    final timestamp = DateTime.now().millisecondsSinceEpoch ~/ 1000;
    final origin = 'https://music.youtube.com';
    final strToHash = '$timestamp $sapisid $origin';
    final hash = sha1.convert(utf8.encode(strToHash)).toString();
    return 'SAPISIDHASH ${timestamp}_$hash';
  }
}

