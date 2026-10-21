import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

/// Handles picking a background photo from the device gallery.
///
/// On mobile/desktop the picked photo is copied into app storage and only
/// its file path is kept in settings — efficient, and keeps
/// SharedPreferences small. On web there is no filesystem, so the photo is
/// embedded directly as a base64 `data:` URI, which still renders (via
/// [Image.memory]) and still survives a page reload through
/// SharedPreferences.
class ImageService {
  final ImagePicker _picker = ImagePicker();

  Future<Directory> _backgroundsDir() async {
    final docs = await getApplicationDocumentsDirectory();
    final dir = Directory('${docs.path}/backgrounds');
    if (!await dir.exists()) {
      await dir.create(recursive: true);
    }
    return dir;
  }

  /// Opens the gallery/file picker and returns a value ready to store in
  /// `BackgroundSettings.imagePath` — a file path on mobile/desktop, or a
  /// `data:` URI on web. Returns null if the user cancelled.
  Future<String?> pickBackgroundImage() async {
    final picked = await _picker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
      maxWidth: 1600, // caps memory/storage use; plenty for any phone screen
    );
    if (picked == null) return null;
    final bytes = await picked.readAsBytes();

    if (kIsWeb) {
      return 'data:${_guessMimeType(picked.name)};base64,${base64Encode(bytes)}';
    }

    final dir = await _backgroundsDir();
    final ext = picked.name.contains('.')
        ? picked.name.substring(picked.name.lastIndexOf('.'))
        : '.jpg';
    final destFile = await File(
      '${dir.path}/bg_${DateTime.now().millisecondsSinceEpoch}$ext',
    ).writeAsBytes(bytes);
    return destFile.path;
  }

  String _guessMimeType(String fileName) {
    final lower = fileName.toLowerCase();
    if (lower.endsWith('.png')) return 'image/png';
    if (lower.endsWith('.webp')) return 'image/webp';
    if (lower.endsWith('.gif')) return 'image/gif';
    return 'image/jpeg';
  }

  Future<void> deleteImage(String reference) async {
    if (kIsWeb || reference.startsWith('data:')) return; // nothing on disk
    final file = File(reference);
    if (await file.exists()) {
      await file.delete();
    }
  }
}
