import 'dart:convert';
import 'dart:io';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';

import '../models/custom_font.dart';

/// Handles importing .ttf / .otf font files from the device and
/// registering them with the Flutter engine so they can be used as a
/// fontFamily immediately and after app restart.
///
/// Everything is driven by raw bytes (not a file path), since file_picker
/// never returns a usable path on web — this makes import work uniformly
/// on mobile, desktop and web. On mobile/desktop the bytes are additionally
/// written to a file in app storage for efficient, restart-safe reuse; on
/// web (no filesystem) they're kept as base64 in the saved settings.
class FontService {
  static const _allowedExt = ['ttf', 'otf'];

  Future<Directory> _fontsDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/imported_fonts');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Opens a file picker restricted to font files, registers the chosen
  /// font with the engine, and returns it. Returns null if the user
  /// cancelled the picker or the platform handed back no data.
  Future<CustomFont?> importFont() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: _allowedExt,
      withData: true, // required to get bytes on web; harmless elsewhere
    );
    if (result == null || result.files.isEmpty) return null;
    final picked = result.files.single;

    // On mobile/desktop, prefer the already-loaded bytes but fall back to
    // reading from the picked path if the platform didn't attach data.
    Uint8List? bytes = picked.bytes;
    if (bytes == null && !kIsWeb && picked.path != null) {
      bytes = await File(picked.path!).readAsBytes();
    }
    if (bytes == null) return null;

    final baseName = picked.name.contains('.')
        ? picked.name.substring(0, picked.name.lastIndexOf('.'))
        : picked.name;
    final familyName = 'CustomFont_${DateTime.now().millisecondsSinceEpoch}';

    CustomFont font;
    if (kIsWeb) {
      font = CustomFont(
        familyName: familyName,
        displayName: baseName,
        filePath: '',
        bytesBase64: base64Encode(bytes),
      );
    } else {
      final ext = (picked.extension ?? 'ttf').toLowerCase();
      final dir = await _fontsDir();
      final destFile =
          await File('${dir.path}/$familyName.$ext').writeAsBytes(bytes);
      font = CustomFont(
        familyName: familyName,
        displayName: baseName,
        filePath: destFile.path,
      );
    }

    await registerFont(font);
    return font;
  }

  /// Loads the font bytes (from disk or embedded base64) and registers
  /// them with the engine under [CustomFont.familyName]. Must be called
  /// for every saved custom font on app startup, since font registration
  /// doesn't survive process restarts even though the storage does.
  Future<void> registerFont(CustomFont font) async {
    Uint8List? bytes;
    if (!kIsWeb && font.filePath.isNotEmpty) {
      final file = File(font.filePath);
      if (await file.exists()) {
        bytes = await file.readAsBytes();
      }
    } else if (font.bytesBase64 != null) {
      bytes = base64Decode(font.bytesBase64!);
    }
    if (bytes == null) return;

    final fontLoader = FontLoader(font.familyName);
    fontLoader.addFont(
      Future.value(ByteData.view(bytes.buffer, bytes.offsetInBytes, bytes.length)),
    );
    await fontLoader.load();
  }

  Future<void> deleteFont(CustomFont font) async {
    if (kIsWeb || font.filePath.isEmpty) return; // nothing on disk
    final file = File(font.filePath);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
