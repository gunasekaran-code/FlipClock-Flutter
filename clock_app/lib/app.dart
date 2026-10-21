import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'providers/settings_provider.dart';
import 'screens/home_screen.dart';

/// Root widget: wires up the settings provider, loads persisted
/// preferences, and applies the light/dark theme app-wide.
class FlipFocusApp extends StatefulWidget {
  const FlipFocusApp({super.key});

  @override
  State<FlipFocusApp> createState() => _FlipFocusAppState();
}

class _FlipFocusAppState extends State<FlipFocusApp> {
  late final SettingsProvider _settings;

  @override
  void initState() {
    super.initState();
    _settings = SettingsProvider();
    _settings.load();
  }

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider.value(
      value: _settings,
      child: Consumer<SettingsProvider>(
        builder: (context, settings, _) {
          return MaterialApp(
            title: 'Flip & Focus',
            debugShowCheckedModeBanner: false,
            themeMode: settings.app.themeMode,
            theme: _lightTheme,
            darkTheme: _darkTheme,
            home: settings.loaded
                ? const HomeScreen()
                : const _SplashScreen(),
          );
        },
      ),
    );
  }
}

final ThemeData _lightTheme = ThemeData(
  brightness: Brightness.light,
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFFF5F5F7),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF0A84FF),
    brightness: Brightness.light,
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    foregroundColor: Colors.black,
  ),
  sliderTheme: const SliderThemeData(
    trackHeight: 3,
  ),
);

final ThemeData _darkTheme = ThemeData(
  brightness: Brightness.dark,
  useMaterial3: true,
  scaffoldBackgroundColor: const Color(0xFF000000),
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xFF0A84FF),
    brightness: Brightness.dark,
  ),
  appBarTheme: const AppBarTheme(
    centerTitle: true,
    foregroundColor: Colors.white,
  ),
  sliderTheme: const SliderThemeData(
    trackHeight: 3,
  ),
);

class _SplashScreen extends StatelessWidget {
  const _SplashScreen();

  @override
  Widget build(BuildContext context) {
    return const ColoredBox(
      color: Colors.black,
      child: Center(
        child: CupertinoActivityIndicator(color: Colors.white, radius: 14),
      ),
    );
  }
}
