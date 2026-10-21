import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';

import '../utils/color_utils.dart';
import '../utils/constants.dart';

/// A row of curated color swatches plus a "custom" swatch that opens a
/// full HSV color picker sheet.
class ColorSwatchPicker extends StatelessWidget {
  final Color selected;
  final ValueChanged<Color> onChanged;

  const ColorSwatchPicker({
    super.key,
    required this.selected,
    required this.onChanged,
  });

  Future<void> _openCustomPicker(BuildContext context) async {
    Color temp = selected;
    final result = await showCupertinoModalPopup<Color>(
      context: context,
      builder: (context) {
        return Container(
          padding: const EdgeInsets.fromLTRB(20, 20, 20, 32),
          decoration: BoxDecoration(
            color: CupertinoTheme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(),
                  ),
                  const Text('Custom Color',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  CupertinoButton(
                    padding: EdgeInsets.zero,
                    child: const Text('Done'),
                    onPressed: () => Navigator.of(context).pop(temp),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ColorPicker(
                pickerColor: selected,
                onColorChanged: (c) => temp = c,
                enableAlpha: false,
                labelTypes: const [],
                pickerAreaHeightPercent: 0.7,
              ),
            ],
          ),
        );
      },
    );
    if (result != null) onChanged(result);
  }

  @override
  Widget build(BuildContext context) {
    final isCurated = AppConstants.curatedColors.any((c) => c.toArgbInt() == selected.toArgbInt());
    return SizedBox(
      height: 44,
      child: ListView(
        scrollDirection: Axis.horizontal,
        children: [
          for (final color in AppConstants.curatedColors)
            _Swatch(
              color: color,
              isSelected: color.toArgbInt() == selected.toArgbInt(),
              onTap: () => onChanged(color),
            ),
          _CustomSwatch(
            isSelected: !isCurated,
            color: selected,
            onTap: () => _openCustomPicker(context),
          ),
        ],
      ),
    );
  }
}

class _Swatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _Swatch({required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(right: 10),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
            border: Border.all(
              color: isSelected ? CupertinoColors.activeBlue : Colors.black12,
              width: isSelected ? 3 : 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _CustomSwatch extends StatelessWidget {
  final Color color;
  final bool isSelected;
  final VoidCallback onTap;

  const _CustomSwatch({required this.color, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const SweepGradient(colors: [
            Colors.red,
            Colors.yellow,
            Colors.green,
            Colors.cyan,
            Colors.blue,
            Colors.purple,
            Colors.red,
          ]),
          border: Border.all(
            color: isSelected ? CupertinoColors.activeBlue : Colors.black12,
            width: isSelected ? 3 : 1,
          ),
        ),
        child: const Icon(CupertinoIcons.eyedropper, size: 16, color: Colors.white),
      ),
    );
  }
}
