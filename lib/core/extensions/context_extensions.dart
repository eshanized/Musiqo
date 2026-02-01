// ============================================================================
// Context Extensions - Shortcuts for common BuildContext operations
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
//
// These extension methods make our code cleaner and shorter.
// ============================================================================

import 'package:flutter/material.dart';

/// Extensions on BuildContext for quick access to common properties.
/// 
/// WHAT ARE EXTENSIONS?
/// Extensions let you add new methods to existing classes.
/// Instead of writing Theme.of(context).colorScheme.primary
/// you can just write context.colorScheme.primary - much cleaner!
extension ContextExtensions on BuildContext {
  
  // Theme shortcuts
  
  /// Get the current theme data
  ThemeData get theme => Theme.of(this);
  
  /// Get the color scheme (primary, secondary, etc.)
  ColorScheme get colorScheme => Theme.of(this).colorScheme;
  
  /// Get the text theme (headline, body, label styles)
  TextTheme get textTheme => Theme.of(this).textTheme;
  
  // Screen size helpers
  
  /// Width of the screen
  double get screenWidth => MediaQuery.sizeOf(this).width;
  
  /// Height of the screen
  double get screenHeight => MediaQuery.sizeOf(this).height;
  
  /// Is this a tablet or large screen?
  bool get isLargeScreen => screenWidth > 600;
  
  /// Safe area padding (for notches, home indicators)
  EdgeInsets get safeArea => MediaQuery.paddingOf(this);
  
  /// Bottom padding for the system navigation bar
  double get bottomPadding => MediaQuery.paddingOf(this).bottom;
  
  // Navigation helpers
  
  /// Push a new screen
  Future<T?> push<T>(Widget page) {
    return Navigator.push<T>(
      this,
      MaterialPageRoute(builder: (_) => page),
    );
  }
  
  /// Go back to previous screen
  void pop<T>([T? result]) => Navigator.pop(this, result);
  
  /// Show a snackbar message
  void showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(this).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError 
            ? colorScheme.error 
            : colorScheme.surfaceContainerHighest,
      ),
    );
  }
  
  /// Show a bottom sheet
  Future<T?> showSheet<T>({required Widget child}) {
    return showModalBottomSheet<T>(
      context: this,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => child,
    );
  }
}
