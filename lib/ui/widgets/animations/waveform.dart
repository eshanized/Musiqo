// ============================================================================
// Waveform Animation - Audio visualizer
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'dart:math';
import 'package:flutter/material.dart';

import '../../../core/theme/everblush_colors.dart';

/// Animated waveform bars for audio visualization.
class Waveform extends StatefulWidget {
  final int barCount;
  final double height;
  final Color? color;
  final bool isAnimating;

  const Waveform({
    super.key,
    this.barCount = 4,
    this.height = 20,
    this.color,
    this.isAnimating = true,
  });

  @override
  State<Waveform> createState() => _WaveformState();
}

class _WaveformState extends State<Waveform>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final _random = Random();
  late List<double> _phases;

  @override
  void initState() {
    super.initState();
    _phases = List.generate(widget.barCount, (_) => _random.nextDouble() * pi);
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    if (widget.isAnimating) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(Waveform oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.isAnimating != oldWidget.isAnimating) {
      if (widget.isAnimating) {
        _controller.repeat();
      } else {
        _controller.stop();
      }
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: List.generate(widget.barCount, (index) {
            final height = widget.isAnimating
                ? (0.3 +
                      0.7 *
                          sin(
                            _controller.value * 2 * pi + _phases[index],
                          ).abs())
                : 0.5;
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 1),
              child: Container(
                width: 3,
                height: widget.height * height,
                decoration: BoxDecoration(
                  color: widget.color ?? EverblushColors.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}
