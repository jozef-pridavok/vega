import "package:core_flutter/core_flutter.dart";

import "../core_dart.dart";

// localize to slovak, english, spanish

extension ThemeTranslation on Theme {
  // TODO: localize core_theme_light "Svetlá téma", "Light theme", "Tema claro"
  // TODO: localize core_theme_dark "Tmavá téma", "Dark theme", "Tema oscuro"
  // TODO: localize core_theme_auto "Automaticky", "Autimatic", "Automático"

  static final Map<Theme, String> _nameMap = {
    Theme.light: "core_theme_light".tr(),
    Theme.dark: "core_theme_dark".tr(),
    Theme.system: "core_theme_auto".tr(),
  };

  String get localizedName => _nameMap[this]!;

  // TODO: localize core_theme_light_description "Jasný a slnečný deň", "Bright and sunny day", "Día brillante y soleado"
  // TODO: localize core_theme_dark_description "Kľudná a pokojná noc", "Calm and peaceful night", "Noche tranquila y pacífica"
  // TODO: localize core_theme_auto_description "Podľa východu a západu slnka", "According to sunrise and sunset", "Según el amanecer y el atardecer"

  static final Map<Theme, String> _descriptionMap = {
    Theme.light: "core_theme_light_description".tr(),
    Theme.dark: "core_theme_dark_description".tr(),
    Theme.system: "core_theme_auto_description".tr(),
  };

  String get localizedDescription => _descriptionMap[this]!;
}

// eof
