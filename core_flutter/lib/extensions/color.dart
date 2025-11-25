import "package:core_dart/core_dart.dart" as core;
import "package:flutter/material.dart" as material;
import "package:flutter/rendering.dart";

extension ColorCoreToMaterial on core.Color {
  material.Color toMaterial() {
    return material.Color(value);
  }
}

extension ColorMaterialToCore on material.Color {
  core.Color toCore() {
    return core.Color(value);
  }
}

extension ColorModifications on Color {
  double getBrightness() {
    return (red * 299 + green * 587 + blue * 114) / 1000;
  }

/*
static Brightness estimateBrightnessForColor(Color color) {
  final double relativeLuminance = color.computeLuminance();

  // See <https://www.w3.org/TR/WCAG20/#contrast-ratiodef>
  // The spec says to use kThreshold=0.0525, but Material Design appears to bias
  // more towards using light text than WCAG20 recommends. Material Design spec
  // doesn't say what value to use, but 0.15 seemed close to what the Material
  // Design spec shows for its color palette on
  // <https://material.io/go/design-theming#color-color-palette>.
  const double kThreshold = 0.15;
  if ((relativeLuminance + 0.05) * (relativeLuminance + 0.05) > kThreshold)
    return Brightness.light;
  return Brightness.dark;
}
*/

  bool isDark() => getBrightness() < 128.0;
  bool isLight() => !isDark();

  Color darken([double amount = .15]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

    return hslDark.toColor();
  }

  Color lighten([double amount = .15]) {
    assert(amount >= 0 && amount <= 1);

    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));

    return hslLight.toColor();
  }

  /// Returns darken or lighten color (lighten if color is dark and darken if color is light).
  /// Darken or lighten color is determined by [amount] (default 15%).
  Color dol([double amount = .15]) {
    return isDark() ? lighten(amount) : darken(amount);
  }

  /// Returns [dark] if this color is dark, otherwise returns [light]
  Color dolText(Color dark, Color light) {
    return isDark() ? light : dark;
  }
}

// eof
