// ============================================================================
// Countdown Timer Widget
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:async';
import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// Countdown timer display widget.
class CountdownTimer extends StatefulWidget {
  final Duration duration;
  final VoidCallback? onComplete;
  final TextStyle? style;

  const CountdownTimer({
    super.key,
    required this.duration,
    this.onComplete,
    this.style,
  });

  @override
  State<CountdownTimer> createState() => _CountdownTimerState();
}

class _CountdownTimerState extends State<CountdownTimer> {
  late Duration _remaining;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _remaining = widget.duration;
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remaining.inSeconds <= 0) {
        _timer?.cancel();
        widget.onComplete?.call();
      } else {
        setState(() {
          _remaining = _remaining - const Duration(seconds: 1);
        });
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  String _formatDuration(Duration d) {
    final hours = d.inHours;
    final minutes = d.inMinutes.remainder(60);
    final seconds = d.inSeconds.remainder(60);

    if (hours > 0) {
      return '${hours.toString().padLeft(2, '0')}:'
          '${minutes.toString().padLeft(2, '0')}:'
          '${seconds.toString().padLeft(2, '0')}';
    }
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}';
  }

  @override
  Widget build(BuildContext context) {
    return Text(
      _formatDuration(_remaining),
      style:
          widget.style ??
          const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: EverblushColors.textPrimary,
            fontFeatures: [FontFeature.tabularFigures()],
          ),
    );
  }
}
