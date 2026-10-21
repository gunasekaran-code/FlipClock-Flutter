import 'dart:async';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/clock_settings.dart';
import '../providers/settings_provider.dart';
import '../widgets/app_background.dart';
import '../widgets/digital_clock_display.dart';
import '../widgets/flip_clock_display.dart';
import '../widgets/glass_icon_button.dart';
import 'focus_timer_screen.dart';
import 'settings_screen.dart';

/// The full-screen clock — the app's home surface. Tapping anywhere toggles
/// a minimal set of floating controls (settings, focus timer) that
/// auto-hide again, keeping the default view distraction-free.
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late DateTime _now;
  Timer? _ticker;
  bool _controlsVisible = false;
  Timer? _hideTimer;

  @override
  void initState() {
    super.initState();
    _now = DateTime.now();
    _ticker = Timer.periodic(const Duration(seconds: 1), (_) {
      if (mounted) setState(() => _now = DateTime.now());
    });
  }

  @override
  void dispose() {
    _ticker?.cancel();
    _hideTimer?.cancel();
    super.dispose();
  }

  void _toggleControls() {
    setState(() => _controlsVisible = !_controlsVisible);
    _hideTimer?.cancel();
    if (_controlsVisible) {
      _hideTimer = Timer(const Duration(seconds: 4), () {
        if (mounted) setState(() => _controlsVisible = false);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();
    final clock = settings.clock;
    final size = MediaQuery.of(context).size;
    final baseFontSize = (size.shortestSide * 0.24).clamp(64.0, 220.0);
    final reduceMotion = settings.app.reduceMotion;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: _toggleControls,
        child: AppBackground(
          settings: settings.background,
          child: SafeArea(
            child: Stack(
              children: [
                Align(
                  alignment: clock.alignment.alignment,
                  child: Padding(
                    padding: const EdgeInsets.all(28),
                    // Scales the whole clock down (never up) so it always
                    // fits on screen — long formats (seconds + AM/PM) on
                    // narrow or small devices never clip or overflow.
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: clock.style == ClockStyle.flip
                          ? FlipClockDisplay(
                              now: _now,
                              settings: clock,
                              baseFontSize: baseFontSize,
                              animate: !reduceMotion,
                            )
                          : DigitalClockDisplay(
                              now: _now,
                              settings: clock,
                              baseFontSize: baseFontSize,
                            ),
                    ),
                  ),
                ),
                AnimatedOpacity(
                  opacity: _controlsVisible ? 1 : 0,
                  duration: const Duration(milliseconds: 220),
                  curve: Curves.easeOut,
                  child: IgnorePointer(
                    ignoring: !_controlsVisible,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GlassIconButton(
                            icon: CupertinoIcons.timer,
                            semanticLabel: 'Focus timer',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const FocusTimerScreen(),
                                ),
                              );
                            },
                          ),
                          GlassIconButton(
                            icon: CupertinoIcons.settings,
                            semanticLabel: 'Settings',
                            onTap: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const SettingsScreen(),
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
