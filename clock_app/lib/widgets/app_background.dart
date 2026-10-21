import 'dart:io';
import 'dart:ui';

import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';

import '../models/background_settings.dart';
import 'stored_image.dart';

/// Renders the full-screen background: solid color, gradient, or a device
/// photo with a dimming overlay (so clock text stays legible) and optional
/// blur.
class AppBackground extends StatelessWidget {
  final BackgroundSettings settings;
  final Widget child;

  const AppBackground({super.key, required this.settings, required this.child});

  @override
  Widget build(BuildContext context) {
    switch (settings.type) {
      case BackgroundType.solidColor:
        return ColoredBox(color: settings.solidColor, child: child);
      case BackgroundType.gradient:
        return DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: settings.gradientDirection.begin,
              end: settings.gradientDirection.end,
              colors: [settings.gradientStart, settings.gradientEnd],
            ),
          ),
          child: child,
        );
      case BackgroundType.image:
        final path = settings.imagePath;
        // On web the image is always an inline data: URI (no filesystem);
        // on mobile/desktop it's a file path that may have been removed.
        final hasValidImage = path != null &&
            (StoredImage.isDataUri(path) || (!kIsWeb && File(path).existsSync()));
        if (!hasValidImage) {
          // Graceful fallback if there's no image, or it was removed from disk.
          return DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [settings.gradientStart, settings.gradientEnd],
              ),
            ),
            child: child,
          );
        }
        return Stack(
          fit: StackFit.expand,
          children: [
            StoredImage(source: path, fit: BoxFit.cover),
            if (settings.imageBlur > 0)
              BackdropFilter(
                filter: ImageFilter.blur(
                  sigmaX: settings.imageBlur,
                  sigmaY: settings.imageBlur,
                ),
                child: const SizedBox.expand(),
              ),
            Container(color: Colors.black.withValues(alpha: settings.imageOverlayOpacity)),
            child,
          ],
        );
    }
  }
}
