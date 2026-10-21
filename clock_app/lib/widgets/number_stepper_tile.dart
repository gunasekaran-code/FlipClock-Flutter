import 'package:flutter/cupertino.dart';

/// A labeled "value  [-] [+]" row for adjusting a bounded integer, used for
/// the focus timer's duration settings.
class NumberStepperTile extends StatelessWidget {
  final String label;
  final int value;
  final int min;
  final int max;
  final String unit;
  final ValueChanged<int> onChanged;

  const NumberStepperTile({
    super.key,
    required this.label,
    required this.value,
    required this.onChanged,
    this.min = 1,
    this.max = 120,
    this.unit = 'min',
  });

  @override
  Widget build(BuildContext context) {
    return CupertinoListTile(
      title: Text(label),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(32, 32),
            onPressed: value > min ? () => onChanged(value - 1) : null,
            child: const Icon(CupertinoIcons.minus_circle, size: 26),
          ),
          SizedBox(
            width: 64,
            child: Text(
              '$value $unit',
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          CupertinoButton(
            padding: EdgeInsets.zero,
            minimumSize: const Size(32, 32),
            onPressed: value < max ? () => onChanged(value + 1) : null,
            child: const Icon(CupertinoIcons.plus_circle, size: 26),
          ),
        ],
      ),
    );
  }
}
