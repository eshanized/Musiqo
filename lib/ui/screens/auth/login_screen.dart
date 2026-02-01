// ============================================================================
// Login Screen - WebView-based Google login for YouTube Music
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// This screen uses a WebView to load Google's login page.
// After the user logs in, we capture the cookies for authenticated
// API requests. Login is OPTIONAL - the app works without it.
// ============================================================================

import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../core/utils/logger.dart';
import '../../../providers/auth/auth_provider.dart';

/// The Google login screen using WebView.
/// 
/// HOW IT WORKS:
/// 1. We load Google's login page in a WebView
/// 2. User logs in with their Google account
/// 3. Google redirects to YouTube Music
/// 4. We capture cookies via JavaScript and extract auth tokens
/// 5. We fetch account info and save everything
class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  bool _isProcessingLogin = false;
  String _currentUrl = '';

  // We extract these from the page via JavaScript
  String _visitorData = '';
  String _dataSyncId = '';

  @override
  void initState() {
    super.initState();
    _initWebView();
  }

  void _initWebView() {
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(EverblushColors.background)
      ..setNavigationDelegate(
        NavigationDelegate(
          onProgress: (progress) {
            if (progress == 100) {
              setState(() => _isLoading = false);
            }
          },
          onPageStarted: (url) {
            setState(() {
              _isLoading = true;
              _currentUrl = url;
            });
          },
          onPageFinished: (url) async {
            setState(() => _isLoading = false);
            
            // Extract visitor data and data sync ID from the page
            await _extractAuthData();
            
            // Check if we're on YouTube Music (login successful)
            if (url.startsWith('https://music.youtube.com') && !_isProcessingLogin) {
              await _processLogin();
            }
          },
          onWebResourceError: (error) {
            Log.error('WebView error: ${error.description}', tag: 'Login');
          },
        ),
      )
      ..loadRequest(Uri.parse(
        'https://accounts.google.com/ServiceLogin?continue=https://music.youtube.com',
      ));
  }

  Future<void> _extractAuthData() async {
    try {
      // Extract visitor data
      final visitorDataResult = await _controller.runJavaScriptReturningResult(
        'window.yt && window.yt.config_ && window.yt.config_.VISITOR_DATA || ""',
      );
      final visitorData = visitorDataResult.toString().replaceAll('"', '');
      if (visitorData.isNotEmpty) {
        _visitorData = visitorData;
        Log.debug('Got visitor data', tag: 'Login');
      }

      // Extract data sync ID
      final dataSyncIdResult = await _controller.runJavaScriptReturningResult(
        'window.yt && window.yt.config_ && window.yt.config_.DATASYNC_ID || ""',
      );
      final dataSyncId = dataSyncIdResult.toString().replaceAll('"', '');
      if (dataSyncId.isNotEmpty) {
        // Extract just the first part before "||"
        _dataSyncId = dataSyncId.split('||').first;
        Log.debug('Got data sync ID', tag: 'Login');
      }
    } catch (e) {
      Log.error('Failed to extract auth data', error: e, tag: 'Login');
    }
  }

  Future<void> _processLogin() async {
    if (_isProcessingLogin) return;
    
    setState(() => _isProcessingLogin = true);
    Log.info('Processing login...', tag: 'Login');

    try {
      // Get cookies via JavaScript since WebViewCookieManager.getCookies isn't available
      final cookieResult = await _controller.runJavaScriptReturningResult(
        'document.cookie',
      );
      
      String cookieString = cookieResult.toString().replaceAll('"', '');
      
      if (cookieString.isEmpty) {
        Log.error('No cookies found', tag: 'Login');
        _showError('Login failed - no cookies');
        setState(() => _isProcessingLogin = false);
        return;
      }

      // Check if we have SAPISID (required for authenticated requests)
      if (!cookieString.contains('SAPISID')) {
        Log.warning('No SAPISID in cookies, may not be fully logged in', tag: 'Login');
        // Don't fail - some cookies might still work for basic features
      }

      // Try to extract account name from page
      String accountName = 'YouTube User';
      String accountEmail = '';
      String? accountThumbnail;

      try {
        final nameResult = await _controller.runJavaScriptReturningResult(
          '''
          (function() {
            var img = document.querySelector('img.yt-core-image');
            return img ? img.alt : '';
          })()
          '''
        );
        final name = nameResult.toString().replaceAll('"', '');
        if (name.isNotEmpty) accountName = name;
      } catch (e) {
        // Ignore - use default
      }

      // Save auth data
      await ref.read(authNotifierProvider.notifier).login(
        cookie: cookieString,
        visitorData: _visitorData,
        dataSyncId: _dataSyncId,
        accountName: accountName,
        accountEmail: accountEmail,
        accountThumbnail: accountThumbnail,
      );

      Log.info('Login successful!', tag: 'Login');
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Login successful!'),
            backgroundColor: EverblushColors.success,
          ),
        );
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      Log.error('Login failed', error: e, tag: 'Login');
      _showError('Login failed: $e');
    } finally {
      if (mounted) {
        setState(() => _isProcessingLogin = false);
      }
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: EverblushColors.error,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Check platform support - WebView only on mobile
    if (!Platform.isAndroid && !Platform.isIOS) {
      return Scaffold(
        backgroundColor: EverblushColors.background,
        appBar: AppBar(
          backgroundColor: EverblushColors.background,
          title: const Text('Login', style: TextStyle(color: EverblushColors.textPrimary)),
        ),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.desktop_windows,
                  size: 64,
                  color: EverblushColors.textMuted,
                ),
                const SizedBox(height: 16),
                const Text(
                  'WebView login is not available on desktop',
                  style: TextStyle(
                    color: EverblushColors.textPrimary,
                    fontSize: 18,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                const Text(
                  'Sign-in is optional. The app works great without it!',
                  style: TextStyle(
                    color: EverblushColors.textMuted,
                    fontSize: 14,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                OutlinedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Go Back'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: EverblushColors.background,
      appBar: AppBar(
        backgroundColor: EverblushColors.background,
        title: const Text(
          'Sign in with Google',
          style: TextStyle(color: EverblushColors.textPrimary),
        ),
        leading: IconButton(
          icon: const Icon(Icons.close, color: EverblushColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          if (_isProcessingLogin)
            const Padding(
              padding: EdgeInsets.all(16),
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  color: EverblushColors.primary,
                ),
              ),
            ),
        ],
      ),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading)
            const Center(
              child: CircularProgressIndicator(
                color: EverblushColors.primary,
              ),
            ),
        ],
      ),
    );
  }
}
