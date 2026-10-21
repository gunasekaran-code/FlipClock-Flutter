import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

/// Renders a background photo persisted either as a local file path
/// (mobile/desktop) or as an inline base64 `data:` URI (web, where
/// dart:io filesystem access isn't available). Callers just pass whatever
/// `ImageService.pickBackgroundImage()` returned.
class StoredImage extends StatelessWidget {
  final String source;
  final BoxFit fit;
  final WidgetBuilder? errorBuilder;

  const StoredImage({
    super.key,
    required this.source,
    this.fit = BoxFit.cover,
    this.errorBuilder,
  });

  static bool isDataUri(String value) => value.startsWith('data:');

  @override
  Widget build(BuildContext context) {
    if (isDataUri(source)) {
      try {
        final bytes = base64Decode(source.substring(source.indexOf(',') + 1));
        return Image.memory(
          bytes,
          fit: fit,
          gaplessPlayback: true,
          errorBuilder: (context, _, _) => _fallback(context),
        );
      } catch (_) {
        return _fallback(context);
      }
    }
    if (kIsWeb) return _fallback(context); // web never stores raw paths
    final file = File(source);
    if (!file.existsSync()) return _fallback(context);
    return Image.file(
      file,
      fit: fit,
      errorBuilder: (context, _, _) => _fallback(context),
    );
  }

  Widget _fallback(BuildContext context) =>
      errorBuilder?.call(context) ?? const SizedBox.shrink();
}
