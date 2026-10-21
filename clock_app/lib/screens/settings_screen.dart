import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../models/background_settings.dart';
import '../models/clock_settings.dart';
import '../providers/settings_provider.dart';
import '../utils/color_utils.dart';
import '../utils/constants.dart';
import '../widgets/alignment_grid_picker.dart';
import '../widgets/color_swatch_picker.dart';
import '../widgets/number_stepper_tile.dart';
import '../widgets/stored_image.dart';

/// The full settings surface: clock, font, background, animation, focus
/// and appearance — every knob the user can turn, grouped iOS-style.
class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = context.watch<SettingsProvider>();

    return Scaffold(
      backgroundColor: CupertinoColors.systemGroupedBackground.resolveFrom(context),
      appBar: AppBar(
        title: const Text('Settings'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        surfaceTintColor: Colors.transparent,
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 40),
        children: [
          _ClockSection(settings: settings),
          _FontSection(settings: settings),
          _BackgroundSection(settings: settings),
          _AnimationSection(settings: settings),
          _FocusSection(settings: settings),
          _AppearanceSection(settings: settings),
          _ResetSection(settings: settings),
        ],
      ),
    );
  }
}

class _ClockSection extends StatelessWidget {
  final SettingsProvider settings;
  const _ClockSection({required this.settings});

  @override
  Widget build(BuildContext context) {
    final clock = settings.clock;
    return CupertinoListSection.insetGrouped(
      header: const Text('Clock'),
      children: [
        CupertinoListTile(
          title: const Text('24-Hour Time'),
          trailing: CupertinoSwitch(
            value: clock.use24hFormat,
            onChanged: (v) => settings.updateClock((c) => c.copyWith(use24hFormat: v)),
          ),
        ),
        CupertinoListTile(
          title: const Text('Show Seconds'),
          trailing: CupertinoSwitch(
            value: clock.showSeconds,
            onChanged: (v) => settings.updateClock((c) => c.copyWith(showSeconds: v)),
          ),
        ),
        CupertinoListTile(
          title: const Text('Show Date'),
          trailing: CupertinoSwitch(
            value: clock.showDate,
            onChanged: (v) => settings.updateClock((c) => c.copyWith(showDate: v)),
          ),
        ),
        CupertinoListTile(
          title: const Text('Style'),
          trailing: CupertinoSlidingSegmentedControl<ClockStyle>(
            groupValue: clock.style,
            children: const {
              ClockStyle.digital: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Digital'),
              ),
              ClockStyle.flip: Padding(
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Text('Flip'),
              ),
            },
            onValueChanged: (v) {
              if (v != null) settings.updateClock((c) => c.copyWith(style: v));
            },
          ),
        ),
        CupertinoListTile(
          title: const Text('Weight'),
          trailing: CupertinoSlidingSegmentedControl<int>(
            // Keys must include ClockSettings' default weight (w600) or this
            // control asserts the instant Settings opens with fresh state.
            groupValue: clock.fontWeight.value,
            children: const {
              300: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Light')),
              500: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Regular')),
              600: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Semibold')),
              800: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Bold')),
            },
            onValueChanged: (v) {
              if (v == null) return;
              final weight = FontWeight.values.firstWhere((w) => w.value == v);
              settings.updateClock((c) => c.copyWith(fontWeight: weight));
            },
          ),
        ),
        CupertinoListTile(title: const Text('Alignment')),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: AlignmentGridPicker(
            selected: clock.alignment,
            onChanged: (a) => settings.updateClock((c) => c.copyWith(alignment: a)),
          ),
        ),
        CupertinoListTile(
          title: const Text('Size'),
          subtitle: Slider(
            value: clock.fontScale,
            min: AppConstants.minClockScale,
            max: AppConstants.maxClockScale,
            onChanged: (v) => settings.updateClock((c) => c.copyWith(fontScale: v)),
          ),
        ),
        CupertinoListTile(
          title: const Text('Letter Spacing'),
          subtitle: Slider(
            value: clock.letterSpacing,
            min: 0,
            max: 20,
            onChanged: (v) => settings.updateClock((c) => c.copyWith(letterSpacing: v)),
          ),
        ),
        CupertinoListTile(title: const Text('Color')),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          child: ColorSwatchPicker(
            selected: clock.textColor,
            onChanged: (c) =>
                settings.updateClock((s) => s.copyWith(textColorValue: c.toArgbInt())),
          ),
        ),
      ],
    );
  }
}

class _FontSection extends StatelessWidget {
  final SettingsProvider settings;
  const _FontSection({required this.settings});

  @override
  Widget build(BuildContext context) {
    final clock = settings.clock;
    return CupertinoListSection.insetGrouped(
      header: const Text('Font'),
      footer: const Text('Import a .ttf or .otf font from your device and use it for the clock.'),
      children: [
        CupertinoListTile(
          title: const Text('System Default'),
          trailing: clock.fontFamily == null
              ? const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeBlue)
              : null,
          onTap: () => settings.updateClock((c) => c.copyWith(clearFontFamily: true)),
        ),
        for (final font in settings.customFonts)
          CupertinoListTile(
            title: Text(font.displayName, style: TextStyle(fontFamily: font.familyName)),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (clock.fontFamily == font.familyName)
                  const Icon(CupertinoIcons.check_mark, color: CupertinoColors.activeBlue),
                CupertinoButton(
                  padding: EdgeInsets.zero,
                  minimumSize: const Size(32, 32),
                  onPressed: () => settings.deleteFont(font),
                  child: const Icon(CupertinoIcons.delete, size: 20, color: CupertinoColors.destructiveRed),
                ),
              ],
            ),
            onTap: () => settings.updateClock((c) => c.copyWith(fontFamily: font.familyName)),
          ),
        CupertinoListTile(
          title: const Text('Import Font (.ttf / .otf)', style: TextStyle(color: CupertinoColors.activeBlue)),
          leading: const Icon(CupertinoIcons.cloud_upload, color: CupertinoColors.activeBlue),
          onTap: () async {
            final font = await settings.importFont();
            if (font != null) {
              await settings.updateClock((c) => c.copyWith(fontFamily: font.familyName));
            }
          },
        ),
      ],
    );
  }
}

class _BackgroundSection extends StatelessWidget {
  final SettingsProvider settings;
  const _BackgroundSection({required this.settings});

  @override
  Widget build(BuildContext context) {
    final bg = settings.background;
    return CupertinoListSection.insetGrouped(
      header: const Text('Background'),
      children: [
        CupertinoListTile(
          title: const Text('Type'),
          trailing: CupertinoSlidingSegmentedControl<BackgroundType>(
            groupValue: bg.type,
            children: const {
              BackgroundType.solidColor:
                  Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Color')),
              BackgroundType.gradient:
                  Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Gradient')),
              BackgroundType.image:
                  Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Photo')),
            },
            onValueChanged: (v) {
              if (v != null) settings.updateBackground((b) => b.copyWith(type: v));
            },
          ),
        ),
        if (bg.type == BackgroundType.solidColor) ...[
          CupertinoListTile(title: const Text('Color')),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ColorSwatchPicker(
              selected: bg.solidColor,
              onChanged: (c) =>
                  settings.updateBackground((b) => b.copyWith(solidColorValue: c.toArgbInt())),
            ),
          ),
        ],
        if (bg.type == BackgroundType.gradient) ...[
          CupertinoListTile(
            title: const Text('Direction'),
            trailing: CupertinoSlidingSegmentedControl<GradientDirection>(
              groupValue: bg.gradientDirection,
              children: const {
                GradientDirection.topToBottom:
                    Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(CupertinoIcons.arrow_down, size: 18)),
                GradientDirection.leftToRight:
                    Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(CupertinoIcons.arrow_right, size: 18)),
                GradientDirection.diagonal:
                    Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(CupertinoIcons.arrow_down_right, size: 18)),
                GradientDirection.radial:
                    Padding(padding: EdgeInsets.symmetric(horizontal: 6), child: Icon(CupertinoIcons.smallcircle_circle, size: 18)),
              },
              onValueChanged: (v) {
                if (v != null) settings.updateBackground((b) => b.copyWith(gradientDirection: v));
              },
            ),
          ),
          CupertinoListTile(title: const Text('Start Color')),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ColorSwatchPicker(
              selected: bg.gradientStart,
              onChanged: (c) =>
                  settings.updateBackground((b) => b.copyWith(gradientStartValue: c.toArgbInt())),
            ),
          ),
          CupertinoListTile(title: const Text('End Color')),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: ColorSwatchPicker(
              selected: bg.gradientEnd,
              onChanged: (c) =>
                  settings.updateBackground((b) => b.copyWith(gradientEndValue: c.toArgbInt())),
            ),
          ),
          CupertinoListTile(title: const Text('Presets')),
          SizedBox(
            height: 44,
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              scrollDirection: Axis.horizontal,
              children: [
                for (final preset in AppConstants.gradientPresets)
                  Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: GestureDetector(
                      onTap: () => settings.updateBackground((b) => b.copyWith(
                            gradientStartValue: preset[0].toArgbInt(),
                            gradientEndValue: preset[1].toArgbInt(),
                          )),
                      child: Container(
                        width: 36,
                        height: 36,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          gradient: LinearGradient(colors: preset),
                          border: Border.all(color: Colors.black12),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 8),
        ],
        if (bg.type == BackgroundType.image) ...[
          if (bg.imagePath != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: AspectRatio(
                  aspectRatio: 16 / 9,
                  child: StoredImage(
                    source: bg.imagePath!,
                    fit: BoxFit.cover,
                    errorBuilder: (_) => const ColoredBox(color: CupertinoColors.systemGrey5),
                  ),
                ),
              ),
            ),
          CupertinoListTile(
            title: const Text('Choose Photo', style: TextStyle(color: CupertinoColors.activeBlue)),
            leading: const Icon(CupertinoIcons.photo, color: CupertinoColors.activeBlue),
            onTap: () => settings.pickBackgroundImage(),
          ),
          if (bg.imagePath != null)
            CupertinoListTile(
              title: const Text('Remove Photo', style: TextStyle(color: CupertinoColors.destructiveRed)),
              leading: const Icon(CupertinoIcons.trash, color: CupertinoColors.destructiveRed),
              onTap: () => settings.clearBackgroundImage(),
            ),
          CupertinoListTile(
            title: const Text('Dim Overlay'),
            subtitle: Slider(
              value: bg.imageOverlayOpacity,
              onChanged: (v) => settings.updateBackground((b) => b.copyWith(imageOverlayOpacity: v)),
            ),
          ),
          CupertinoListTile(
            title: const Text('Blur'),
            subtitle: Slider(
              value: bg.imageBlur,
              max: 20,
              onChanged: (v) => settings.updateBackground((b) => b.copyWith(imageBlur: v)),
            ),
          ),
        ],
      ],
    );
  }
}

class _AnimationSection extends StatelessWidget {
  final SettingsProvider settings;
  const _AnimationSection({required this.settings});

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      header: const Text('Animation & Motion'),
      footer: const Text('Reduce Motion turns off the flip-clock animation for a calmer, static display.'),
      children: [
        CupertinoListTile(
          title: const Text('Reduce Motion'),
          trailing: CupertinoSwitch(
            value: settings.app.reduceMotion,
            onChanged: (v) => settings.updateApp((a) => a.copyWith(reduceMotion: v)),
          ),
        ),
      ],
    );
  }
}

class _FocusSection extends StatelessWidget {
  final SettingsProvider settings;
  const _FocusSection({required this.settings});

  @override
  Widget build(BuildContext context) {
    final focus = settings.focus;
    return CupertinoListSection.insetGrouped(
      header: const Text('Focus Timer'),
      children: [
        NumberStepperTile(
          label: 'Focus Duration',
          value: focus.workMinutes,
          min: 1,
          max: 180,
          onChanged: (v) => settings.updateFocus((f) => f.copyWith(workMinutes: v)),
        ),
        NumberStepperTile(
          label: 'Short Break',
          value: focus.shortBreakMinutes,
          min: 1,
          max: 60,
          onChanged: (v) => settings.updateFocus((f) => f.copyWith(shortBreakMinutes: v)),
        ),
        NumberStepperTile(
          label: 'Long Break',
          value: focus.longBreakMinutes,
          min: 1,
          max: 90,
          onChanged: (v) => settings.updateFocus((f) => f.copyWith(longBreakMinutes: v)),
        ),
        NumberStepperTile(
          label: 'Sessions / Long Break',
          value: focus.sessionsBeforeLongBreak,
          min: 2,
          max: 12,
          unit: '',
          onChanged: (v) => settings.updateFocus((f) => f.copyWith(sessionsBeforeLongBreak: v)),
        ),
        CupertinoListTile(
          title: const Text('Auto-Start Next Session'),
          trailing: CupertinoSwitch(
            value: focus.autoStartNext,
            onChanged: (v) => settings.updateFocus((f) => f.copyWith(autoStartNext: v)),
          ),
        ),
        CupertinoListTile(
          title: const Text('Sound'),
          trailing: CupertinoSwitch(
            value: focus.soundEnabled,
            onChanged: (v) => settings.updateFocus((f) => f.copyWith(soundEnabled: v)),
          ),
        ),
        CupertinoListTile(
          title: const Text('Haptics'),
          trailing: CupertinoSwitch(
            value: focus.hapticsEnabled,
            onChanged: (v) => settings.updateFocus((f) => f.copyWith(hapticsEnabled: v)),
          ),
        ),
      ],
    );
  }
}

class _AppearanceSection extends StatelessWidget {
  final SettingsProvider settings;
  const _AppearanceSection({required this.settings});

  @override
  Widget build(BuildContext context) {
    final app = settings.app;
    return CupertinoListSection.insetGrouped(
      header: const Text('Appearance'),
      children: [
        CupertinoListTile(
          title: const Text('Theme'),
          trailing: CupertinoSlidingSegmentedControl<ThemeMode>(
            groupValue: app.themeMode,
            children: const {
              ThemeMode.system: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Auto')),
              ThemeMode.light: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Light')),
              ThemeMode.dark: Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('Dark')),
            },
            onValueChanged: (v) {
              if (v != null) settings.updateApp((a) => a.copyWith(themeMode: v));
            },
          ),
        ),
        CupertinoListTile(
          title: const Text('Keep Screen On'),
          trailing: CupertinoSwitch(
            value: app.keepScreenOn,
            onChanged: (v) => settings.updateApp((a) => a.copyWith(keepScreenOn: v)),
          ),
        ),
      ],
    );
  }
}

class _ResetSection extends StatelessWidget {
  final SettingsProvider settings;
  const _ResetSection({required this.settings});

  @override
  Widget build(BuildContext context) {
    return CupertinoListSection.insetGrouped(
      children: [
        CupertinoListTile(
          title: const Center(
            child: Text('Reset to Defaults', style: TextStyle(color: CupertinoColors.destructiveRed)),
          ),
          onTap: () async {
            final confirmed = await showCupertinoDialog<bool>(
              context: context,
              builder: (context) => CupertinoAlertDialog(
                title: const Text('Reset to Defaults'),
                content: const Text('This resets clock, background and focus timer settings. This cannot be undone.'),
                actions: [
                  CupertinoDialogAction(
                    child: const Text('Cancel'),
                    onPressed: () => Navigator.of(context).pop(false),
                  ),
                  CupertinoDialogAction(
                    isDestructiveAction: true,
                    child: const Text('Reset'),
                    onPressed: () => Navigator.of(context).pop(true),
                  ),
                ],
              ),
            );
            if (confirmed == true) {
              await settings.resetToDefaults();
            }
          },
        ),
      ],
    );
  }
}
