import 'package:flutter/foundation.dart';
import 'package:wakelock_plus/wakelock_plus.dart';

import '../models/app_preferences.dart';
import '../models/background_settings.dart';
import '../models/clock_settings.dart';
import '../models/custom_font.dart';
import '../models/focus_settings.dart';
import '../services/font_service.dart';
import '../services/image_service.dart';
import '../services/storage_service.dart';

/// Single source of truth for every user preference in the app. Loads
/// persisted state on startup and writes it back to disk on every change,
/// so preferences always survive a restart.
class SettingsProvider extends ChangeNotifier {
  final StorageService _storage = StorageService();
  final FontService _fontService = FontService();
  final ImageService _imageService = ImageService();

  ClockSettings clock = const ClockSettings();
  BackgroundSettings background = const BackgroundSettings();
  FocusSettings focus = const FocusSettings();
  AppPreferences app = const AppPreferences();
  List<CustomFont> customFonts = [];

  bool _loaded = false;
  bool get loaded => _loaded;

  Future<void> load() async {
    // Local storage should never be able to strand the app on its splash
    // screen — fall back to defaults (already the initial field values) on
    // any failure so the clock always ends up on screen.
    // A stuck platform channel (e.g. shared_preferences/wakelock not yet
    // wired up, such as in a plain widget test) must never block first
    // paint forever, so every step below is capped with a timeout.
    const stepTimeout = Duration(seconds: 5);
    try {
      final data = await _storage.loadAll().timeout(stepTimeout);
      clock = data.clock;
      background = data.background;
      focus = data.focus;
      app = data.app;

      customFonts = await _storage.loadCustomFonts().timeout(stepTimeout);
      // Re-register every imported font with the engine; registration does
      // not survive process restarts even though the files do.
      for (final font in customFonts) {
        await _fontService.registerFont(font).timeout(stepTimeout);
      }
      // If the previously selected font was deleted/missing, fall back safely.
      if (clock.fontFamily != null &&
          !customFonts.any((f) => f.familyName == clock.fontFamily)) {
        clock = clock.copyWith(clearFontFamily: true);
      }

      await _applyWakelock().timeout(stepTimeout);
    } catch (e, st) {
      debugPrint('SettingsProvider.load failed, using defaults: $e\n$st');
    }
    _loaded = true;
    notifyListeners();
  }

  Future<void> _persist() async {
    await _storage.saveAll(
      clock: clock,
      background: background,
      focus: focus,
      app: app,
    );
  }

  Future<void> _applyWakelock() async {
    try {
      if (app.keepScreenOn) {
        await WakelockPlus.enable();
      } else {
        await WakelockPlus.disable();
      }
    } catch (_) {
      // Not available on this platform (e.g. desktop/web) — ignore.
    }
  }

  // ---- Clock ----
  Future<void> updateClock(ClockSettings Function(ClockSettings) updater) async {
    clock = updater(clock);
    notifyListeners();
    await _persist();
  }

  // ---- Background ----
  Future<void> updateBackground(
      BackgroundSettings Function(BackgroundSettings) updater) async {
    background = updater(background);
    notifyListeners();
    await _persist();
  }

  Future<void> pickBackgroundImage() async {
    final path = await _imageService.pickBackgroundImage();
    if (path == null) return;
    final previous = background.imagePath;
    background = background.copyWith(
      imagePath: path,
      type: BackgroundType.image,
    );
    notifyListeners();
    await _persist();
    if (previous != null && previous != path) {
      await _imageService.deleteImage(previous);
    }
  }

  Future<void> clearBackgroundImage() async {
    final previous = background.imagePath;
    background = background.copyWith(clearImagePath: true);
    notifyListeners();
    await _persist();
    if (previous != null) {
      await _imageService.deleteImage(previous);
    }
  }

  // ---- Focus ----
  Future<void> updateFocus(FocusSettings Function(FocusSettings) updater) async {
    focus = updater(focus);
    notifyListeners();
    await _persist();
  }

  // ---- App preferences ----
  Future<void> updateApp(AppPreferences Function(AppPreferences) updater) async {
    app = updater(app);
    notifyListeners();
    await _persist();
    await _applyWakelock();
  }

  // ---- Fonts ----
  Future<CustomFont?> importFont() async {
    final font = await _fontService.importFont();
    if (font == null) return null;
    customFonts = [...customFonts, font];
    await _storage.saveCustomFonts(customFonts);
    notifyListeners();
    return font;
  }

  Future<void> deleteFont(CustomFont font) async {
    customFonts = customFonts.where((f) => f.familyName != font.familyName).toList();
    await _storage.saveCustomFonts(customFonts);
    if (clock.fontFamily == font.familyName) {
      clock = clock.copyWith(clearFontFamily: true);
    }
    notifyListeners();
    await _persist();
    await _fontService.deleteFont(font);
  }

  Future<void> resetToDefaults() async {
    clock = const ClockSettings();
    background = const BackgroundSettings();
    focus = const FocusSettings();
    app = app.copyWith(reduceMotion: false);
    notifyListeners();
    await _persist();
  }
}
