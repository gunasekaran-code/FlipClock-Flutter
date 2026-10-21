import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../providers/settings_provider.dart';
import '../widgets/app_background.dart';
import '../widgets/glass_icon_button.dart';

enum _FocusMode { work, shortBreak, longBreak }

/// Full-screen Pomodoro-style focus timer with start / pause / reset,
/// automatic work/break cycling, and a session dot tracker.
class FocusTimerScreen extends StatefulWidget {
  const FocusTimerScreen({super.key});

  @override
  State<FocusTimerScreen> createState() => _FocusTimerScreenState();
}

class _FocusTimerScreenState extends State<FocusTimerScreen> {
  Timer? _ticker;
  bool _running = false;
  _FocusMode _mode = _FocusMode.work;
  int _remainingSeconds = 25 * 60;
  int _completedSessions = 0;
  bool _initializedFromSettings = false;

  int _durationFor(_FocusMode mode, SettingsProvider settings) {
    switch (mode) {
      case _FocusMode.work:
        return settings.focus.workMinutes * 60;
      case _FocusMode.shortBreak:
        return settings.focus.shortBreakMinutes * 60;
      case _FocusMode.longBreak:
        return settings.focus.longBreakMinutes * 60;
    }
  }

  void _start() {
    if (_running) return;
    setState(() => _running = true);
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (_remainingSeconds <= 1) {
        _onCycleComplete();
      } else {
        setState(() => _remainingSeconds--);
      }
    });
  }

  void _pause() {
    _ticker?.cancel();
    setState(() => _running = false);
  }

  void _reset() {
    _ticker?.cancel();
    final settings = context.read<SettingsProvider>();
    setState(() {
      _running = false;
      _mode = _FocusMode.work;
      _completedSessions = 0;
      _remainingSeconds = _durationFor(_mode, settings);
    });
  }

  void _onCycleComplete() {
    final settings = context.read<SettingsProvider>();
    _ticker?.cancel();

    // Best-effort: some platforms (e.g. web) don't implement these
    // channels, and a session transition must never be blocked by that.
    if (settings.focus.hapticsEnabled) {
      unawaited(HapticFeedback.mediumImpact().catchError((_) {}));
    }
    if (settings.focus.soundEnabled) {
      unawaited(SystemSound.play(SystemSoundType.alert).catchError((_) {}));
    }

    setState(() {
      if (_mode == _FocusMode.work) {
        _completedSessions++;
        final isLong =
            _completedSessions % settings.focus.sessionsBeforeLongBreak == 0;
        _mode = isLong ? _FocusMode.longBreak : _FocusMode.shortBreak;
      } else {
        _mode = _FocusMode.work;
      }
      _remainingSeconds = _durationFor(_mode, settings);
      _running = false;
    });

    if (settings.focus.autoStartNext) {
      _start();
    }
  }

  String get _modeLabel {
    switch (_mode) {
      case _FocusMode.work:
        return 'Focus';
      case _FocusMode.shortBreak:
        return 'Short Break';
      case _FocusMode.longBreak:
        return 'Long Break';
    }
  }

  String get _formattedTime {
    final m = (_remainingSeconds ~/ 60).toString().padLeft(2, '0');
    final s = (_remainingSeconds % 60).toString().padLeft(2, '0');
    return '$m:$s';
  }

  @override
  void dispose() {
    _ticker?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    if (!_initializedFromSettings) {
      _initializedFromSettings = true;
      _remainingSeconds = _durationFor(_mode, settings);
    }
    final clock = settings.clock;
    final total = _durationFor(_mode, settings).clamp(1, 1 << 30);
    final progress = 1 - (_remainingSeconds / total);
    final accent = clock.textColor;

    return Scaffold(
      body: AppBackground(
        settings: settings.background,
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  children: [
                    GlassIconButton(
                      icon: CupertinoIcons.chevron_down,
                      semanticLabel: 'Close focus timer',
                      onTap: () => Navigator.of(context).pop(),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        _modeLabel.toUpperCase(),
                        style: TextStyle(
                          color: accent.withValues(alpha: 0.8),
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 3,
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        width: 260,
                        height: 260,
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            SizedBox(
                              width: 260,
                              height: 260,
                              child: CircularProgressIndicator(
                                value: progress.clamp(0, 1),
                                strokeWidth: 6,
                                backgroundColor: accent.withValues(alpha: 0.15),
                                valueColor: AlwaysStoppedAnimation(accent),
                              ),
                            ),
                            Text(
                              _formattedTime,
                              style: TextStyle(
                                color: accent,
                                fontFamily: clock.fontFamily,
                                fontSize: 56,
                                fontWeight: FontWeight.w600,
                                fontFeatures: const [FontFeature.tabularFigures()],
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      Builder(builder: (context) {
                        final perCycle = settings.focus.sessionsBeforeLongBreak;
                        final filled = _completedSessions % perCycle == 0 && _completedSessions > 0
                            ? perCycle
                            : _completedSessions % perCycle;
                        return Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: List.generate(
                            perCycle,
                            (i) => Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 4),
                              child: Container(
                                width: 8,
                                height: 8,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: i < filled ? accent : accent.withValues(alpha: 0.2),
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 40, top: 12),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    GlassIconButton(
                      icon: CupertinoIcons.refresh,
                      semanticLabel: 'Reset',
                      onTap: _reset,
                    ),
                    const SizedBox(width: 22),
                    GlassIconButton(
                      icon: _running ? CupertinoIcons.pause_fill : CupertinoIcons.play_fill,
                      semanticLabel: _running ? 'Pause' : 'Start',
                      size: 64,
                      onTap: _running ? _pause : _start,
                    ),
                    const SizedBox(width: 22),
                    GlassIconButton(
                      icon: CupertinoIcons.forward_fill,
                      semanticLabel: 'Skip',
                      onTap: _onCycleComplete,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
