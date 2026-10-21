# Flip & Focus

A premium, Apple-inspired full-screen clock and focus app for Android and iOS,
built with Flutter. Fully offline — every setting lives on the device, no
backend, no accounts, no network calls.

## Features

- **Full-screen clock** — 12/24-hour format, seconds, date, custom text
  color, size, letter spacing, weight, and 9-point screen alignment.
- **Flip Clock animation** — a real split-flap flip transition per digit, or
  a plain digital style; toggle between them any time.
- **Custom fonts** — import any `.ttf` / `.otf` font from the device and use
  it for the clock face. Imported fonts are copied into app storage and
  re-registered automatically on every launch.
- **Custom backgrounds** — solid color, gradient (with curated presets and a
  direction picker), or a photo from the device gallery (with dim overlay
  and blur controls).
- **Focus Timer** — Pomodoro-style timer with start / pause / reset / skip,
  configurable work & break durations, session-before-long-break count,
  auto-start, sound, and haptics.
- **Settings screen** — grouped, iOS-style sections for Clock, Font,
  Background, Animation, Focus, and Appearance (theme + keep-screen-on).
- **Light / dark mode**, distraction-free UI (controls stay hidden until you
  tap the screen), rounded glass controls, smooth animations throughout.
- **Everything persists** — all preferences (and imported fonts/photos) are
  saved locally via `shared_preferences` + app document storage, and restored
  automatically the next time the app opens.

## Project structure

```
lib/
  models/       Plain data classes for each settings group (clock,
                background, focus, app prefs, imported fonts) with
                JSON (de)serialization.
  services/     Local-only I/O: SharedPreferences storage, font import +
                registration, background photo import.
  providers/    SettingsProvider — the single source of truth, wired up
                with `provider`.
  screens/      HomeScreen (the clock), SettingsScreen, FocusTimerScreen.
  widgets/      Clock displays (digital + flip), background renderer,
                glass buttons, color/alignment pickers, etc.
```

## Getting started

```bash
flutter pub get
flutter run            # launches on a connected device/emulator
```

To build release artifacts:

```bash
flutter build apk      # Android
flutter build ios      # iOS (requires a full Xcode install on macOS)
```

## Notes

- Background photos and imported fonts are copied into the app's private
  document storage, so the app keeps working even if the original photo/file
  is later removed from the device.
- The focus timer runs while the app is in the foreground; it does not use
  background services, in keeping with the "no backend, fully local" design.
