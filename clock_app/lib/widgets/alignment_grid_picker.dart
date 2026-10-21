import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/clock_settings.dart';

/// A 3x3 grid letting the user pick where on screen the clock sits.
class AlignmentGridPicker extends StatelessWidget {
  final ClockAlignment selected;
  final ValueChanged<ClockAlignment> onChanged;

  const AlignmentGridPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  static const _order = [
    ClockAlignment.topLeft,
    ClockAlignment.topCenter,
    ClockAlignment.topRight,
    ClockAlignment.centerLeft,
    ClockAlignment.center,
    ClockAlignment.centerRight,
    ClockAlignment.bottomLeft,
    ClockAlignment.bottomCenter,
    ClockAlignment.bottomRight,
  ];

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: 1.6,
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(14),
          color: CupertinoColors.systemGrey5.resolveFrom(context),
        ),
        child: GridView.count(
          crossAxisCount: 3,
          mainAxisSpacing: 6,
          crossAxisSpacing: 6,
          physics: const NeverScrollableScrollPhysics(),
          children: [
            for (final alignment in _order)
              GestureDetector(
                onTap: () => onChanged(alignment),
                child: Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: alignment == selected
                        ? CupertinoColors.activeBlue
                        : CupertinoTheme.of(context).scaffoldBackgroundColor,
                  ),
                  child: Center(
                    child: Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: alignment == selected
                            ? Colors.white
                            : CupertinoColors.systemGrey.resolveFrom(context),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
