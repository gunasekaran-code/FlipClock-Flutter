/// Configuration for the Pomodoro-style focus timer.
class FocusSettings {
  final int workMinutes;
  final int shortBreakMinutes;
  final int longBreakMinutes;
  final int sessionsBeforeLongBreak;
  final bool autoStartNext;
  final bool soundEnabled;
  final bool hapticsEnabled;

  const FocusSettings({
    this.workMinutes = 25,
    this.shortBreakMinutes = 5,
    this.longBreakMinutes = 15,
    this.sessionsBeforeLongBreak = 4,
    this.autoStartNext = false,
    this.soundEnabled = true,
    this.hapticsEnabled = true,
  });

  FocusSettings copyWith({
    int? workMinutes,
    int? shortBreakMinutes,
    int? longBreakMinutes,
    int? sessionsBeforeLongBreak,
    bool? autoStartNext,
    bool? soundEnabled,
    bool? hapticsEnabled,
  }) {
    return FocusSettings(
      workMinutes: workMinutes ?? this.workMinutes,
      shortBreakMinutes: shortBreakMinutes ?? this.shortBreakMinutes,
      longBreakMinutes: longBreakMinutes ?? this.longBreakMinutes,
      sessionsBeforeLongBreak:
          sessionsBeforeLongBreak ?? this.sessionsBeforeLongBreak,
      autoStartNext: autoStartNext ?? this.autoStartNext,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      hapticsEnabled: hapticsEnabled ?? this.hapticsEnabled,
    );
  }

  Map<String, dynamic> toJson() => {
        'workMinutes': workMinutes,
        'shortBreakMinutes': shortBreakMinutes,
        'longBreakMinutes': longBreakMinutes,
        'sessionsBeforeLongBreak': sessionsBeforeLongBreak,
        'autoStartNext': autoStartNext,
        'soundEnabled': soundEnabled,
        'hapticsEnabled': hapticsEnabled,
      };

  factory FocusSettings.fromJson(Map<String, dynamic> json) {
    final defaults = const FocusSettings();
    return FocusSettings(
      workMinutes: json['workMinutes'] as int? ?? defaults.workMinutes,
      shortBreakMinutes:
          json['shortBreakMinutes'] as int? ?? defaults.shortBreakMinutes,
      longBreakMinutes:
          json['longBreakMinutes'] as int? ?? defaults.longBreakMinutes,
      sessionsBeforeLongBreak: json['sessionsBeforeLongBreak'] as int? ??
          defaults.sessionsBeforeLongBreak,
      autoStartNext: json['autoStartNext'] as bool? ?? defaults.autoStartNext,
      soundEnabled: json['soundEnabled'] as bool? ?? defaults.soundEnabled,
      hapticsEnabled:
          json['hapticsEnabled'] as bool? ?? defaults.hapticsEnabled,
    );
  }
}
