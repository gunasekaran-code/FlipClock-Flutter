import 'package:flutter/material.dart';

import '../models/clock_settings.dart';
import '../utils/time_format.dart';
import 'flip_digit_card.dart';

/// Full flip-clock display: one [FlipDigitCard] per digit, grouped into
/// hours / minutes / seconds, plus the date line and AM/PM suffix.
class FlipClockDisplay extends StatelessWidget {
  final DateTime now;
  final ClockSettings settings;
  final double baseFontSize;
  final bool animate;

  const FlipClockDisplay({
    super.key,
    required this.now,
    required this.settings,
    required this.baseFontSize,
    this.animate = true,
  });

  @override
  Widget build(BuildContext context) {
    final formatted = formatClockTime(now, settings);
    final fontSize = baseFontSize * settings.fontScale;
    final cardHeight = fontSize * 1.25;
    final cardWidth = cardHeight * 0.72;
    final gap = cardWidth * 0.14;

    final style = TextStyle(
      fontFamily: settings.fontFamily,
      fontSize: fontSize,
      fontWeight: settings.fontWeight,
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

    Widget colonWidget() => Padding(
          padding: EdgeInsets.symmetric(horizontal: gap * 0.6),
          child: Text(':', style: style.copyWith(fontWeight: FontWeight.w700)),
        );

    Widget group(String value) => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < value.length; i++) ...[
              if (i > 0) SizedBox(width: gap),
              FlipDigitCard(
                digit: value[i],
                width: cardWidth,
                height: cardHeight,
                style: style,
                animate: animate,
              ),
            ],
          ],
        );

    final parts = formatted.main.split(':');

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: settings.alignment.crossAxisAlignment,
      children: [
        if (settings.showDate)
          Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Text(formatted.date, style: dateStyle),
          ),
        Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            for (var i = 0; i < parts.length; i++) ...[
              if (i > 0) colonWidget(),
              group(parts[i]),
            ],
            if (formatted.suffix != null)
              Padding(
                padding: EdgeInsets.only(left: gap),
                child: Text(
                  formatted.suffix!,
                  style: style.copyWith(
                    fontSize: fontSize * 0.24,
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
