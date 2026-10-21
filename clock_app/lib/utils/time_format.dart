import 'package:intl/intl.dart';

import '../models/clock_settings.dart';

/// Formats [now] into the main clock string and an optional AM/PM suffix,
/// according to [settings].
class FormattedTime {
  final String main; // e.g. "09:41" or "09:41:07" or "9:41"
  final String? suffix; // "AM" / "PM", null in 24h mode
  final String date; // e.g. "Monday, 8 September"

  const FormattedTime({required this.main, this.suffix, required this.date});
}

FormattedTime formatClockTime(DateTime now, ClockSettings settings) {
  final hour24 = now.hour;
  String hourStr;
  String? suffix;

  if (settings.use24hFormat) {
    hourStr = hour24.toString().padLeft(2, '0');
  } else {
    final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
    hourStr = hour12.toString();
    suffix = hour24 >= 12 ? 'PM' : 'AM';
  }

  final minuteStr = now.minute.toString().padLeft(2, '0');
  final secondStr = now.second.toString().padLeft(2, '0');

  final main = settings.showSeconds
      ? '$hourStr:$minuteStr:$secondStr'
      : '$hourStr:$minuteStr';

  final date = DateFormat('EEEE, d MMMM').format(now);

  return FormattedTime(main: main, suffix: suffix, date: date);
}
