import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/app_preferences.dart';
import '../models/background_settings.dart';
import '../models/clock_settings.dart';
import '../models/custom_font.dart';
import '../models/focus_settings.dart';
import '../utils/constants.dart';

/// Thin wrapper around SharedPreferences that (de)serializes every setting
/// group to/from a single local JSON blob. No network calls, ever.
class StorageService {
  Future<void> saveAll({
    required ClockSettings clock,
    required BackgroundSettings background,
    required FocusSettings focus,
    required AppPreferences app,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final blob = {
      'clock': clock.toJson(),
      'background': background.toJson(),
      'focus': focus.toJson(),
      'app': app.toJson(),
    };
    await prefs.setString(AppConstants.prefsSettingsKey, jsonEncode(blob));
  }

  Future<
      ({
        ClockSettings clock,
        BackgroundSettings background,
        FocusSettings focus,
        AppPreferences app,
      })> loadAll() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.prefsSettingsKey);
    if (raw == null) {
      return (
        clock: const ClockSettings(),
        background: const BackgroundSettings(),
        focus: const FocusSettings(),
        app: const AppPreferences(),
      );
    }
    try {
      final blob = jsonDecode(raw) as Map<String, dynamic>;
      return (
        clock: ClockSettings.fromJson(
            (blob['clock'] as Map?)?.cast<String, dynamic>() ?? const {}),
        background: BackgroundSettings.fromJson(
            (blob['background'] as Map?)?.cast<String, dynamic>() ?? const {}),
        focus: FocusSettings.fromJson(
            (blob['focus'] as Map?)?.cast<String, dynamic>() ?? const {}),
        app: AppPreferences.fromJson(
            (blob['app'] as Map?)?.cast<String, dynamic>() ?? const {}),
      );
    } catch (_) {
      // Corrupt or outdated data — fall back to defaults rather than crash.
      return (
        clock: const ClockSettings(),
        background: const BackgroundSettings(),
        focus: const FocusSettings(),
        app: const AppPreferences(),
      );
    }
  }

  Future<void> saveCustomFonts(List<CustomFont> fonts) async {
    final prefs = await SharedPreferences.getInstance();
    final list = fonts.map((f) => f.toJson()).toList();
    await prefs.setString(AppConstants.prefsFontsKey, jsonEncode(list));
  }

  Future<List<CustomFont>> loadCustomFonts() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(AppConstants.prefsFontsKey);
    if (raw == null) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((e) => CustomFont.fromJson((e as Map).cast<String, dynamic>()))
          .toList();
    } catch (_) {
      return [];
    }
  }
}
