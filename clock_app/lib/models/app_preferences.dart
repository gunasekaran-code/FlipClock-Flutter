import 'package:flutter/material.dart';

/// General app-level preferences (theme, motion, screen behavior).
class AppPreferences {
  final ThemeMode themeMode;
  final bool keepScreenOn;
  final bool reduceMotion;

  const AppPreferences({
    this.themeMode = ThemeMode.system,
    this.keepScreenOn = true,
    this.reduceMotion = false,
  });

  AppPreferences copyWith({
    ThemeMode? themeMode,
    bool? keepScreenOn,
    bool? reduceMotion,
  }) {
    return AppPreferences(
      themeMode: themeMode ?? this.themeMode,
      keepScreenOn: keepScreenOn ?? this.keepScreenOn,
      reduceMotion: reduceMotion ?? this.reduceMotion,
    );
  }

  Map<String, dynamic> toJson() => {
        'themeMode': themeMode.index,
        'keepScreenOn': keepScreenOn,
        'reduceMotion': reduceMotion,
      };

  factory AppPreferences.fromJson(Map<String, dynamic> json) {
    final defaults = const AppPreferences();
    return AppPreferences(
      themeMode: ThemeMode.values[json['themeMode'] as int? ?? 0],
      keepScreenOn: json['keepScreenOn'] as bool? ?? defaults.keepScreenOn,
      reduceMotion: json['reduceMotion'] as bool? ?? defaults.reduceMotion,
    );
  }
}
