import 'package:flutter/material.dart';

/// Small helpers for persisting [Color] values as plain ints (ARGB32),
/// since SharedPreferences / JSON can't store Color objects directly.
extension ColorSerialization on Color {
  int toArgbInt() =>
      (((a * 255).round() & 0xff) << 24) |
      (((r * 255).round() & 0xff) << 16) |
      (((g * 255).round() & 0xff) << 8) |
      ((b * 255).round() & 0xff);
}

Color colorFromArgbInt(int value) => Color(value);
