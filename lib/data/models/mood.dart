// ============================================================================
// Mood/Genre Model
// Author: Eshan Roy <eshanized@proton.me>
// SPDX-License-Identifier: MIT
// ============================================================================

import 'package:flutter/material.dart';

import '../../core/theme/everblush_colors.dart';

/// Music mood or genre for explore page.
class Mood {
  final String id;
  final String name;
  final Color color;

  const Mood({required this.id, required this.name, required this.color});

  static const List<Mood> predefined = [
    Mood(id: 'energize', name: 'Energize', color: EverblushColors.red),
    Mood(id: 'workout', name: 'Workout', color: EverblushColors.yellow),
    Mood(id: 'relaxation', name: 'Relaxation', color: EverblushColors.teal),
    Mood(id: 'romance', name: 'Romance', color: EverblushColors.pink),
    Mood(id: 'feel_good', name: 'Feel Good', color: EverblushColors.green),
    Mood(id: 'focus', name: 'Focus', color: EverblushColors.purple),
    Mood(id: 'party', name: 'Party', color: EverblushColors.primary),
    Mood(id: 'sleep', name: 'Sleep', color: EverblushColors.blue),
  ];
}

/// Music genre
class Genre {
  final String id;
  final String name;
  final Color color;

  const Genre({required this.id, required this.name, required this.color});

  static const List<Genre> predefined = [
    Genre(id: 'pop', name: 'Pop', color: EverblushColors.pink),
    Genre(id: 'hip_hop', name: 'Hip-Hop', color: EverblushColors.yellow),
    Genre(id: 'rock', name: 'Rock', color: EverblushColors.red),
    Genre(id: 'indie', name: 'Indie', color: EverblushColors.green),
    Genre(id: 'electronic', name: 'Electronic', color: EverblushColors.teal),
    Genre(id: 'r_b', name: 'R&B', color: EverblushColors.purple),
    Genre(id: 'jazz', name: 'Jazz', color: EverblushColors.blue),
    Genre(id: 'classical', name: 'Classical', color: EverblushColors.cyan),
    Genre(id: 'country', name: 'Country', color: EverblushColors.yellow),
    Genre(id: 'metal', name: 'Metal', color: EverblushColors.red),
  ];
}
