import 'dart:math' as math;

import 'package:flutter/material.dart';

/// A single split-flap "flip clock" character. When [digit] changes, the
/// top half rotates away (revealing the new top half already underneath)
/// then the new bottom flap drops down to cover the swapped bottom half —
/// the classic two-stage split-flap animation.
class FlipDigitCard extends StatefulWidget {
  final String digit;
  final double width;
  final double height;
  final TextStyle style;
  final Duration duration;
  final bool animate;

  const FlipDigitCard({
    super.key,
    required this.digit,
    required this.width,
    required this.height,
    required this.style,
    this.duration = const Duration(milliseconds: 450),
    this.animate = true,
  });

  @override
  State<FlipDigitCard> createState() => _FlipDigitCardState();
}

class _FlipDigitCardState extends State<FlipDigitCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late String _previousDigit;

  @override
  void initState() {
    super.initState();
    _previousDigit = widget.digit;
    _controller = AnimationController(vsync: this, duration: widget.duration);
  }

  @override
  void didUpdateWidget(covariant FlipDigitCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.digit != widget.digit) {
      _previousDigit = oldWidget.digit;
      if (widget.animate) {
        _controller
          ..stop()
          ..forward(from: 0);
      } else {
        _controller.value = 1;
      }
    }
    if (widget.duration != oldWidget.duration) {
      _controller.duration = widget.duration;
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isLightText = widget.style.color!.computeLuminance() > 0.5;
    final cardColor =
        isLightText ? Colors.black.withValues(alpha: 0.55) : Colors.white.withValues(alpha: 0.88);
    final dividerColor = Colors.black.withValues(alpha: 0.35);
    final radius = math.min(widget.width, widget.height) * 0.12;

    return SizedBox(
      width: widget.width,
      height: widget.height,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, _) {
          final t = _controller.value;
          return Stack(
            children: [
              // Resting bottom half: old digit before the midpoint swap,
              // new digit after — the falling top flap and dropping bottom
              // flap hide the instantaneous swap either side of t = 0.5.
              _Half(
                digit: t < 0.5 ? _previousDigit : widget.digit,
                top: false,
                width: widget.width,
                height: widget.height,
                style: widget.style,
                color: cardColor,
                radius: radius,
              ),
              // Resting top half: always the new digit — it's revealed once
              // the falling flap has rotated away.
              _Half(
                digit: widget.digit,
                top: true,
                width: widget.width,
                height: widget.height,
                style: widget.style,
                color: cardColor,
                radius: radius,
              ),
              if (t < 0.5)
                _Flap(
                  digit: _previousDigit,
                  top: true,
                  progress: t * 2,
                  width: widget.width,
                  height: widget.height,
                  style: widget.style,
                  color: cardColor,
                  radius: radius,
                )
              else if (widget.animate)
                _Flap(
                  digit: widget.digit,
                  top: false,
                  progress: (t - 0.5) * 2,
                  width: widget.width,
                  height: widget.height,
                  style: widget.style,
                  color: cardColor,
                  radius: radius,
                ),
              // Hinge crease across the middle.
              Positioned(
                left: 0,
                right: 0,
                top: widget.height / 2 - 0.6,
                child: Container(height: 1.2, color: dividerColor),
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Renders exactly the top or bottom half of a full-size digit glyph,
/// clipped at the card's midline, inside a rounded half-card panel.
class _Half extends StatelessWidget {
  final String digit;
  final bool top;
  final double width;
  final double height;
  final TextStyle style;
  final Color color;
  final double radius;

  const _Half({
    required this.digit,
    required this.top,
    required this.width,
    required this.height,
    required this.style,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: 0,
      right: 0,
      top: top ? 0 : height / 2,
      height: height / 2,
      child: ClipRRect(
        borderRadius: BorderRadius.vertical(
          top: top ? Radius.circular(radius) : Radius.zero,
          bottom: top ? Radius.zero : Radius.circular(radius),
        ),
        child: Container(
          color: color,
          alignment: Alignment.center,
          child: ClipRect(
            child: Align(
              alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
              heightFactor: 0.5,
              child: SizedBox(
                width: width,
                height: height,
                child: Center(child: Text(digit, style: style)),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// The animated rotating flap that sells the "flip" — a half-card that
/// rotates about its hinge edge using a perspective transform, darkening
/// as it turns edge-on to simulate shading.
class _Flap extends StatelessWidget {
  final String digit;
  final bool top; // true = falling top flap, false = rising bottom flap
  final double progress; // 0..1 local to this flap's half of the animation
  final double width;
  final double height;
  final TextStyle style;
  final Color color;
  final double radius;

  const _Flap({
    required this.digit,
    required this.top,
    required this.progress,
    required this.width,
    required this.height,
    required this.style,
    required this.color,
    required this.radius,
  });

  @override
  Widget build(BuildContext context) {
    // Top flap: angle sweeps 0 -> -90deg (falling away).
    // Bottom flap: angle sweeps +90 -> 0deg (dropping into place).
    final angle = top ? -progress * (math.pi / 2) : (1 - progress) * (math.pi / 2);
    final shade = (angle.abs() / (math.pi / 2)).clamp(0.0, 1.0) * 0.55;

    return Positioned(
      left: 0,
      right: 0,
      top: top ? 0 : height / 2,
      height: height / 2,
      child: Transform(
        alignment: top ? Alignment.bottomCenter : Alignment.topCenter,
        transform: Matrix4.identity()
          ..setEntry(3, 2, 0.0022)
          ..rotateX(angle),
        child: ClipRRect(
          borderRadius: BorderRadius.vertical(
            top: top ? Radius.circular(radius) : Radius.zero,
            bottom: top ? Radius.zero : Radius.circular(radius),
          ),
          child: Stack(
            children: [
              Container(
                color: color,
                alignment: Alignment.center,
                child: ClipRect(
                  child: Align(
                    alignment: top ? Alignment.topCenter : Alignment.bottomCenter,
                    heightFactor: 0.5,
                    child: SizedBox(
                      width: width,
                      height: height,
                      child: Center(child: Text(digit, style: style)),
                    ),
                  ),
                ),
              ),
              Container(color: Colors.black.withValues(alpha: shade)),
            ],
          ),
        ),
      ),
    );
  }
}
