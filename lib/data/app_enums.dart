import 'package:flutter/material.dart';

/// Available color themes for the app
enum AppColorTheme {
  spellbook('Spellbook', Color(0xFF6750A4), '📖'), // Purple - default
  forest('Forest', Color(0xFF2E7D32), '🌲'),       // Green
  ocean('Ocean', Color(0xFF0288D1), '🌊'),         // Blue
  sunset('Sunset', Color(0xFFE64A19), '🌅'),       // Orange
  midnight('Midnight', Color(0xFF1A237E), '🌙'),   // Indigo
  rose('Rose', Color(0xFFAD1457), '🌹'),           // Pink
  ;

  final String displayName;
  final Color seedColor;
  final String emoji;

  const AppColorTheme(this.displayName, this.seedColor, this.emoji);
}

/// Measurement system preference
enum MeasurementSystem {
  us('US (cups, tsp, oz)'),
  metric('Metric (ml, g)'),
  ;

  final String displayName;

  const MeasurementSystem(this.displayName);
}