import 'package:flutter/material.dart';

import '../models/clock_settings.dart';
import '../utils/time_format.dart';

/// The plain (non-flip) digital clock: large time text with an optional
/// AM/PM suffix and date line, fully styled by [ClockSettings].
class DigitalClockDisplay extends StatelessWidget {
  final DateTime now;
  final ClockSettings settings;
  final double baseFontSize;

  const DigitalClockDisplay({
    super.key,
    required this.now,
    required this.settings,
    required this.baseFontSize,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = formatClockTime(now, settings);
    final fontSize = baseFontSize * settings.fontScale;

    final timeStyle = TextStyle(
      fontFamily: settings.fontFamily,
      fontSize: fontSize,
      fontWeight: settings.fontWeight,
      letterSpacing: settings.letterSpacing,
      color: settings.textColor,
      height: 1.0,
    );

    final dateStyle = TextStyle(
      fontFamily: settings.fontFamily,
      fontSize: (fontSize * 0.16).clamp(14, 28),
      fontWeight: FontWeight.w500,
      letterSpacing: 0.5,
      color: settings.textColor.withValues(alpha: 0.75),
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: settings.alignment.crossAxisAlignment,
      children: [
        if (settings.showDate)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Text(formatted.date, style: dateStyle),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.baseline,
          textBaseline: TextBaseline.alphabetic,
          children: [
            Text(formatted.main, style: timeStyle),
            if (formatted.suffix != null)
              Padding(
                padding: const EdgeInsets.only(left: 8),
                child: Text(
                  formatted.suffix!,
                  style: timeStyle.copyWith(
                    fontSize: fontSize * 0.28,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
          ],
        ),
      ],
    );
  }
}
