// ============================================================================
// Widget Extensions
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

/// Extensions for Widget class.
extension WidgetExtensions on Widget {
  /// Add padding around the widget
  Widget padding([EdgeInsetsGeometry padding = const EdgeInsets.all(16)]) {
    return Padding(padding: padding, child: this);
  }

  /// Add horizontal padding
  Widget paddingHorizontal([double padding = 16]) {
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: padding),
      child: this,
    );
  }

  /// Add vertical padding
  Widget paddingVertical([double padding = 16]) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: padding),
      child: this,
    );
  }

  /// Center the widget
  Widget centered() {
    return Center(child: this);
  }

  /// Expand within a Flex widget
  Widget expanded([int flex = 1]) {
    return Expanded(flex: flex, child: this);
  }

  /// Make the widget scrollable
  Widget scrollable() {
    return SingleChildScrollView(child: this);
  }

  /// Add a gesture detector with onTap
  Widget onTap(VoidCallback? onTap) {
    return GestureDetector(onTap: onTap, child: this);
  }
}
