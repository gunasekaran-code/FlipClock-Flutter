import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

enum BackgroundType { solidColor, gradient, image }

enum GradientDirection {
  topToBottom,
  leftToRight,
  diagonal,
  radial,
}

extension GradientDirectionGeometry on GradientDirection {
  Alignment get begin {
    switch (this) {
      case GradientDirection.topToBottom:
        return Alignment.topCenter;
      case GradientDirection.leftToRight:
        return Alignment.centerLeft;
      case GradientDirection.diagonal:
        return Alignment.topLeft;
      case GradientDirection.radial:
        return Alignment.center;
    }
  }

  Alignment get end {
    switch (this) {
      case GradientDirection.topToBottom:
        return Alignment.bottomCenter;
      case GradientDirection.leftToRight:
        return Alignment.centerRight;
      case GradientDirection.diagonal:
        return Alignment.bottomRight;
      case GradientDirection.radial:
        return Alignment.center;
    }
  }
}

/// Everything that controls the full-screen background behind the clock.
class BackgroundSettings {
  final BackgroundType type;
  final int solidColorValue;
  final int gradientStartValue;
  final int gradientEndValue;
  final GradientDirection gradientDirection;
  final String? imagePath;
  final double imageOverlayOpacity;
  final double imageBlur;

  const BackgroundSettings({
    this.type = BackgroundType.gradient,
    this.solidColorValue = 0xFF000000,
    this.gradientStartValue = 0xFF0F0C29,
    this.gradientEndValue = 0xFF24243E,
    this.gradientDirection = GradientDirection.diagonal,
    this.imagePath,
    this.imageOverlayOpacity = 0.35,
    this.imageBlur = 0,
  });

  Color get solidColor => colorFromArgbInt(solidColorValue);
  Color get gradientStart => colorFromArgbInt(gradientStartValue);
  Color get gradientEnd => colorFromArgbInt(gradientEndValue);

  BackgroundSettings copyWith({
    BackgroundType? type,
    int? solidColorValue,
    int? gradientStartValue,
    int? gradientEndValue,
    GradientDirection? gradientDirection,
    String? imagePath,
    bool clearImagePath = false,
    double? imageOverlayOpacity,
    double? imageBlur,
  }) {
    return BackgroundSettings(
      type: type ?? this.type,
      solidColorValue: solidColorValue ?? this.solidColorValue,
      gradientStartValue: gradientStartValue ?? this.gradientStartValue,
      gradientEndValue: gradientEndValue ?? this.gradientEndValue,
      gradientDirection: gradientDirection ?? this.gradientDirection,
      imagePath: clearImagePath ? null : (imagePath ?? this.imagePath),
      imageOverlayOpacity: imageOverlayOpacity ?? this.imageOverlayOpacity,
      imageBlur: imageBlur ?? this.imageBlur,
    );
  }

  Map<String, dynamic> toJson() => {
        'type': type.index,
        'solidColorValue': solidColorValue,
        'gradientStartValue': gradientStartValue,
        'gradientEndValue': gradientEndValue,
        'gradientDirection': gradientDirection.index,
        'imagePath': imagePath,
        'imageOverlayOpacity': imageOverlayOpacity,
        'imageBlur': imageBlur,
      };

  factory BackgroundSettings.fromJson(Map<String, dynamic> json) {
    final defaults = const BackgroundSettings();
    return BackgroundSettings(
      type: BackgroundType.values[json['type'] as int? ?? 1],
      solidColorValue:
          json['solidColorValue'] as int? ?? defaults.solidColorValue,
      gradientStartValue:
          json['gradientStartValue'] as int? ?? defaults.gradientStartValue,
      gradientEndValue:
          json['gradientEndValue'] as int? ?? defaults.gradientEndValue,
      gradientDirection:
          GradientDirection.values[json['gradientDirection'] as int? ?? 2],
      imagePath: json['imagePath'] as String?,
      imageOverlayOpacity: (json['imageOverlayOpacity'] as num?)?.toDouble() ??
          defaults.imageOverlayOpacity,
      imageBlur: (json['imageBlur'] as num?)?.toDouble() ?? defaults.imageBlur,
    );
  }
}
