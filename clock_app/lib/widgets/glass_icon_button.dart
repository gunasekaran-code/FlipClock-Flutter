import 'dart:ui';

import 'package:flutter/material.dart';

/// A frosted-glass round icon button, Apple-control-center style. Used for
/// the minimal floating controls over the clock so they read as premium
/// chrome rather than a typical Material app bar.
class GlassIconButton extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  final String? semanticLabel;
  final double size;

  const GlassIconButton({
    super.key,
    required this.icon,
    required this.onTap,
    this.semanticLabel,
    this.size = 46,
  });

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Material(
            color: Colors.white.withValues(alpha: 0.14),
            shape: const CircleBorder(
              side: BorderSide(color: Colors.white24, width: 0.6),
            ),
            child: InkWell(
              onTap: onTap,
              child: SizedBox(
                width: size,
                height: size,
                child: Icon(icon, color: Colors.white, size: size * 0.48),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
