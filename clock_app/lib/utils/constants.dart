import 'package:flutter/material.dart';

/// Shared constants: default palette, gradient presets and layout values
/// used across the settings screen and clock display.
class AppConstants {
  AppConstants._();

  static const String prefsSettingsKey = 'flip_focus_settings_v2';
  static const String prefsFontsKey = 'flip_focus_custom_fonts_v2';

  /// Curated accent / text colors, Apple-style flat palette.
  static const List<Color> curatedColors = [
    Colors.white,
    Color(0xFFF5F5F7),
    Color(0xFF0A84FF), // iOS blue
    Color(0xFF30D158), // iOS green
    Color(0xFFFF9F0A), // iOS orange
    Color(0xFFFF375F), // iOS pink/red
    Color(0xFFBF5AF2), // iOS purple
    Color(0xFF64D2FF), // iOS teal
    Color(0xFFFFD60A), // iOS yellow
    Colors.black,
  ];

  /// Curated gradient presets [colorA, colorB].
  static const List<List<Color>> gradientPresets = [
    [Color(0xFF0F0C29), Color(0xFF24243E)],
    [Color(0xFF000000), Color(0xFF1C1C1E)],
    [Color(0xFF1E3C72), Color(0xFF2A5298)],
    [Color(0xFF360033), Color(0xFF0B8793)],
    [Color(0xFFFF512F), Color(0xFFDD2476)],
    [Color(0xFF00C6FF), Color(0xFF0072FF)],
    [Color(0xFF11998E), Color(0xFF38EF7D)],
    [Color(0xFFF7971E), Color(0xFFFFD200)],
    [Color(0xFFEEEEEE), Color(0xFFFFFFFF)],
    [Color(0xFFC9D6FF), Color(0xFFE2E2E2)],
  ];

  static const double minClockScale = 0.6;
  static const double maxClockScale = 1.6;
}
