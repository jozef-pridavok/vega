import "package:core_dart/core_enums.dart";
import "package:flutter/material.dart" as ui;

import "../themes/theme.dart";

extension ThemeMaterial on Theme {
  static final Map<Theme, ui.ThemeMode> _nameMap = {
    Theme.light: ui.ThemeMode.light,
    Theme.dark: ui.ThemeMode.dark,
    Theme.system: ui.ThemeMode.system,
  };

  ui.ThemeMode get material => _nameMap[this]!;
}

extension ThemeBackgroundColor on Theme {
  ui.Color getBackgroundColor(MoleculeTheme scheme) {
    switch (this) {
      case Theme.system:
        return scheme.paper;
      case Theme.dark:
        return ui.Colors.black;
      case Theme.light:
        return scheme.accent;
    }
  }
}

extension ThemeForegroundColor on Theme {
  ui.Color getForegroundColor(MoleculeTheme scheme) {
    switch (this) {
      case Theme.system:
        return scheme.primary;
      case Theme.dark:
        return scheme.secondary;
      case Theme.light:
        return ui.Colors.black;
    }
  }
}

extension ThemeIcon on Theme {
  static final Map<Theme, String> _iconMap = {
    Theme.light: "sun",
    Theme.dark: "moon",
    Theme.system: "refresh_cw",
  };

  String get icon => _iconMap[this]!;
}

// eof
