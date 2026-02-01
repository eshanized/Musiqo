// ============================================================================
// Login Screen - Google Authentication
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../../core/theme/everblush_colors.dart';
import '../../../providers/auth/auth_provider.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  late final WebViewController _controller;
  bool _isWebViewSupported = false;
  final TextEditingController _cookieController = TextEditingController();

  @override
  void initState() {
    super.initState();
    // WebView is supported on Android and iOS (and potentially macOS if configured)
    // For Linux/Windows, we fall back to manual token input
    if (Platform.isAndroid || Platform.isIOS) {
      _isWebViewSupported = true;
      _controller = WebViewController()
        ..setJavaScriptMode(JavaScriptMode.unrestricted)
        ..setUserAgent('Mozilla/5.0 (Linux; Android 10; K) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/120.0.0.0 Mobile Safari/537.36')
        ..setNavigationDelegate(
          NavigationDelegate(
            onPageFinished: (String url) async {
              if (url.contains('music.youtube.com')) {
                // We are logged in or on the music page
                // Try to extract cookies
                final cookies = await _controller.runJavaScriptReturningResult('document.cookie') as String;
                _handleLoginSuccess(cookies.replaceAll('"', ''));
              }
            },
          ),
        )
        ..loadRequest(Uri.parse('https://accounts.google.com/ServiceLogin?continue=https://music.youtube.com'));
    }
  }

  Future<void> _handleLoginSuccess(String cookies) async {
    if (cookies.contains('SAPISID')) {
      await ref.read(authProvider.notifier).login(cookies);
      if (mounted) context.pop();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Login incomplete. Please wait for redirection to YouTube Music.')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Login to YouTube Music'),
        backgroundColor: EverblushColors.background,
      ),
      body: _isWebViewSupported
          ? WebViewWidget(controller: _controller)
          : _buildManualLogin(),
    );
  }

  Widget _buildManualLogin() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'WebView login is not supported on this platform. Please enter your cookies manually.',
            style: TextStyle(color: EverblushColors.textPrimary),
          ),
          const SizedBox(height: 16),
          const Text(
            'Instructions:\n1. Open music.youtube.com in your browser\n2. Open Developer Tools (F12) -> Application -> Cookies\n3. Copy the "Correct" cookie string (format: key=value; key2=value2)',
            style: TextStyle(color: EverblushColors.textMuted, fontSize: 12),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: _cookieController,
            maxLines: 8,
            decoration: const InputDecoration(
              hintText: 'Paste cookies here...',
              border: OutlineInputBorder(),
              fillColor: EverblushColors.surface,
              filled: true,
            ),
            style: const TextStyle(color: EverblushColors.textPrimary),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              if (_cookieController.text.isNotEmpty) {
                 _handleLoginSuccess(_cookieController.text);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: EverblushColors.primary,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
            child: const Text('Login', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }
}
