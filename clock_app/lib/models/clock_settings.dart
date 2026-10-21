import 'package:flutter/material.dart';
import '../utils/color_utils.dart';

enum ClockStyle { digital, flip }

enum ClockAlignment {
  topLeft,
  topCenter,
  topRight,
  centerLeft,
  center,
  centerRight,
  bottomLeft,
  bottomCenter,
  bottomRight,
}

extension ClockAlignmentGeometry on ClockAlignment {
  Alignment get alignment {
    switch (this) {
      case ClockAlignment.topLeft:
        return Alignment.topLeft;
      case ClockAlignment.topCenter:
        return Alignment.topCenter;
      case ClockAlignment.topRight:
        return Alignment.topRight;
      case ClockAlignment.centerLeft:
        return Alignment.centerLeft;
      case ClockAlignment.center:
        return Alignment.center;
      case ClockAlignment.centerRight:
        return Alignment.centerRight;
      case ClockAlignment.bottomLeft:
        return Alignment.bottomLeft;
      case ClockAlignment.bottomCenter:
        return Alignment.bottomCenter;
      case ClockAlignment.bottomRight:
        return Alignment.bottomRight;
    }
  }

  CrossAxisAlignment get crossAxisAlignment {
    switch (this) {
      case ClockAlignment.topLeft:
      case ClockAlignment.centerLeft:
      case ClockAlignment.bottomLeft:
        return CrossAxisAlignment.start;
      case ClockAlignment.topRight:
      case ClockAlignment.centerRight:
      case ClockAlignment.bottomRight:
        return CrossAxisAlignment.end;
      case ClockAlignment.topCenter:
      case ClockAlignment.center:
      case ClockAlignment.bottomCenter:
        return CrossAxisAlignment.center;
    }
  }
}

/// Everything that controls how the full-screen clock looks.
class ClockSettings {
  final bool use24hFormat;
  final bool showSeconds;
  final bool showDate;
  final ClockStyle style;
  final ClockAlignment alignment;
  final String? fontFamily; // null => platform default
  final double fontScale; // multiplier applied to the base responsive size
  final double letterSpacing;
  final FontWeight fontWeight;
  final int textColorValue;

  const ClockSettings({
    this.use24hFormat = true,
    this.showSeconds = true,
    this.showDate = true,
    this.style = ClockStyle.digital,
    this.alignment = ClockAlignment.center,
    this.fontFamily,
    this.fontScale = 1.0,
    this.letterSpacing = 0,
    this.fontWeight = FontWeight.w600,
    this.textColorValue = 0xFFFFFFFF,
  });

  Color get textColor => colorFromArgbInt(textColorValue);

  ClockSettings copyWith({
    bool? use24hFormat,
    bool? showSeconds,
    bool? showDate,
    ClockStyle? style,
    ClockAlignment? alignment,
    String? fontFamily,
    bool clearFontFamily = false,
    double? fontScale,
    double? letterSpacing,
    FontWeight? fontWeight,
    int? textColorValue,
  }) {
    return ClockSettings(
      use24hFormat: use24hFormat ?? this.use24hFormat,
      showSeconds: showSeconds ?? this.showSeconds,
      showDate: showDate ?? this.showDate,
      style: style ?? this.style,
      alignment: alignment ?? this.alignment,
      fontFamily: clearFontFamily ? null : (fontFamily ?? this.fontFamily),
      fontScale: fontScale ?? this.fontScale,
      letterSpacing: letterSpacing ?? this.letterSpacing,
      fontWeight: fontWeight ?? this.fontWeight,
      textColorValue: textColorValue ?? this.textColorValue,
    );
  }

  Map<String, dynamic> toJson() => {
        'use24hFormat': use24hFormat,
        'showSeconds': showSeconds,
        'showDate': showDate,
        'style': style.index,
        'alignment': alignment.index,
        'fontFamily': fontFamily,
        'fontScale': fontScale,
        'letterSpacing': letterSpacing,
        'fontWeight': fontWeight.value,
        'textColorValue': textColorValue,
      };

  factory ClockSettings.fromJson(Map<String, dynamic> json) {
    final defaults = const ClockSettings();
    return ClockSettings(
      use24hFormat: json['use24hFormat'] as bool? ?? defaults.use24hFormat,
      showSeconds: json['showSeconds'] as bool? ?? defaults.showSeconds,
      showDate: json['showDate'] as bool? ?? defaults.showDate,
      style: ClockStyle.values[json['style'] as int? ?? 0],
      alignment: ClockAlignment.values[json['alignment'] as int? ?? 4],
      fontFamily: json['fontFamily'] as String?,
      fontScale: (json['fontScale'] as num?)?.toDouble() ?? defaults.fontScale,
      letterSpacing:
          (json['letterSpacing'] as num?)?.toDouble() ?? defaults.letterSpacing,
      fontWeight: FontWeight.values.firstWhere(
        (w) => w.value == (json['fontWeight'] as int? ?? 600),
        orElse: () => defaults.fontWeight,
      ),
      textColorValue:
          json['textColorValue'] as int? ?? defaults.textColorValue,
    );
  }
}
