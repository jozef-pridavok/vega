import "package:core_dart/core_logging.dart";
import "package:flutter/material.dart";
import "package:flutter/scheduler.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core_theme.dart";

@immutable
class ThemeState {
  final ThemeMode mode;
  final ThemeData data;
  final MoleculeTheme scheme;

  const ThemeState(this.mode, this.data, this.scheme);

  @override
  bool operator ==(other) {
    return (other is ThemeState) && mode == other.mode;
  }

  @override
  int get hashCode => mode.hashCode; // ^ themeColor.hashCode;

  @override
  String toString() => "Theme $mode"; //  with $themeColor

  static ThemeState initial() => ThemeState(
        ThemeMode.light,
        kLightBlueTheme,
        lightBlueTheme,
      );
}

class ThemeNotifier extends /*ThemeNotifierBase*/ StateNotifier<ThemeState> with LoggerMixin {
  ThemeNotifier() : super(ThemeState.initial());

  void load() {
    const mode = ThemeMode.light;
    changeTheme(mode);
  }

  void checkSystem() {
    if (state.mode != ThemeMode.system) return;
    final scheme = _getThemeScheme(state.mode);
    if (state.scheme == scheme) return;
    state = ThemeState(state.mode, _getThemeData(state.mode), scheme);
  }

  void changeTheme(ThemeMode mode) {
    try {
      if (mode == state.mode) return;
      state = ThemeState(mode, _getThemeData(mode), _getThemeScheme(mode));
    } catch (ex) {
      error("Error changing theme: ${ex.toString()}");
      state = ThemeState.initial();
    }
  }

  MoleculeTheme _getThemeScheme(ThemeMode mode) {
    switch (mode) {
      case ThemeMode.system:
        final brightness = SchedulerBinding.instance.window.platformBrightness;
        switch (brightness) {
          case Brightness.dark:
            return darkBlueTheme;
          case Brightness.light:
            return lightBlueTheme;
        }
      case ThemeMode.light:
        return lightBlueTheme;
      case ThemeMode.dark:
        return darkBlueTheme;
    }
  }

  ThemeData _getThemeData(ThemeMode mode) {
    var themeData = kLightBlueTheme;
    switch (mode) {
      case ThemeMode.system:
        final brightness = SchedulerBinding.instance.window.platformBrightness;
        switch (brightness) {
          case Brightness.dark:
            themeData = kDarkBlueTheme;
            break;
          case Brightness.light:
            themeData = kLightBlueTheme;
            break;
        }
        break;
      case ThemeMode.light:
        themeData = kLightBlueTheme;
        break;
      case ThemeMode.dark:
        themeData = kDarkBlueTheme;
        break;
    }
    return themeData;
  }
}

// eof
