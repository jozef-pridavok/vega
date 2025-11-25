class Color {
  final int value;

  /// Construct a color from the lower 8 bits of four integers.
  ///
  /// * `a` is the alpha value, with 0 being transparent and 255 being fully
  ///   opaque.
  /// * `r` is [red], from 0 to 255.
  /// * `g` is [green], from 0 to 255.
  /// * `b` is [blue], from 0 to 255.
  ///
  /// Out of range values are brought into range using modulo 255.
  ///
  /// See also [fromRGBO], which takes the alpha value as a floating point
  /// value.
  const Color(int value) : value = value & 0xFFFFFFFF;

  /// Create a color from red, green, blue, and opacity, similar to `rgba()` in CSS.
  ///
  /// * `r` is [red], from 0 to 255.
  /// * `g` is [green], from 0 to 255.
  /// * `b` is [blue], from 0 to 255.
  /// * `opacity` is alpha channel of this color as a double, with 0.0 being
  ///   transparent and 1.0 being fully opaque.
  ///
  /// Out of range values are brought into range using modulo 255.
  ///
  /// See also [fromARGB], which takes the opacity as an integer value.
  const Color.fromARGB(int a, int r, int g, int b)
      : value = (((a & 0xff) << 24) | ((r & 0xff) << 16) | ((g & 0xff) << 8) | ((b & 0xff) << 0)) & 0xFFFFFFFF;

  /// The alpha channel of this color in an 8 bit value.
  ///
  /// A value of 0 means this color is fully transparent. A value of 255 means
  /// this color is fully opaque.
  int get alpha => (0xff000000 & value) >> 24;

  /// The alpha channel of this color as a double.
  ///
  /// A value of 0.0 means this color is fully transparent. A value of 1.0 means
  /// this color is fully opaque.
  double get opacity => alpha / 0xFF;

  /// The red channel of this color in an 8 bit value.
  int get red => (0x00ff0000 & value) >> 16;

  /// The green channel of this color in an 8 bit value.
  int get green => (0x0000ff00 & value) >> 8;

  /// The blue channel of this color in an 8 bit value.
  int get blue => (0x000000ff & value) >> 0;

  /// Returns a new color that matches this color with the alpha channel
  /// replaced with `a` (which ranges from 0 to 255).
  ///
  /// Out of range values will have unexpected effects.
  Color withAlpha(int a) {
    return Color.fromARGB(a, red, green, blue);
  }

  /// Returns a new color that matches this color with the alpha channel
  /// replaced with the given `opacity` (which ranges from 0.0 to 1.0).
  ///
  /// Out of range values will have unexpected effects.
  Color withOpacity(double opacity) {
    assert(opacity >= 0.0 && opacity <= 1.0);
    return withAlpha((255.0 * opacity).round());
  }

  /// String is in the format "aabbcc" or "ffaabbcc" with an optional leading "#".
  static Color fromHex(String hexString) {
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write("ff");
    buffer.write(hexString.replaceFirst("#", ""));
    return Color(int.tryParse(buffer.toString(), radix: 16) ?? 0xFFFFFFFF);
  }

  static Color? fromHexOrNull(String? hexString) {
    if (hexString == null) return null;
    final buffer = StringBuffer();
    if (hexString.length == 6 || hexString.length == 7) buffer.write("ff");
    buffer.write(hexString.replaceFirst("#", ""));
    return Color(int.tryParse(buffer.toString(), radix: 16) ?? 0xFFFFFFFF);
  }

  /// Prefixes a hash sign if [leadingHashSign] is set to `true` (default is `true`).
  String toHex({bool leadingHashSign = true}) => '${leadingHashSign ? '#' : ''}'
      '${alpha.toRadixString(16).padLeft(2, '0')}'
      '${red.toRadixString(16).padLeft(2, '0')}'
      '${green.toRadixString(16).padLeft(2, '0')}'
      '${blue.toRadixString(16).padLeft(2, '0')}';

  String toHtmlRgba() => "rgba("
      "${red.toString()},"
      "${green.toString()},"
      "${blue.toString()},"
      "${(alpha / 255.0).toString()}"
      ")";

  @override
  String toString() => "Color($value)";

  @override
  bool operator ==(Object other) => other is Color && value == other.value;

  @override
  int get hashCode => value.hashCode;
}

class Palette {
  static const Color transparent = Color(0x00000000);
  static const Color white = Color(0xFFFFFFFF);
  static const Color black = Color(0xFF000000);
  static const Color red = Color(0xFFFF0000);
  static const Color green = Color(0xFF00FF00);
  static const Color blue = Color(0xFF0000FF);
  static const Color yellow = Color(0xFFFFFF00);
  static const Color cyan = Color(0xFF00FFFF);
  static const Color magenta = Color(0xFFFF00FF);
  static const Color orange = Color(0xFFFFA500);
  static const Color purple = Color(0xFF800080);
  static const Color pink = Color(0xFFFFC0CB);
  static const Color teal = Color(0xFF008080);
  static const Color brown = Color(0xFFA52A2A);
  static const Color grey = Color(0xFF808080);
  static const Color lightGrey = Color(0xFFD3D3D3);
  static const Color darkGrey = Color(0xFFA9A9A9);
  static const Color lightBlue = Color(0xFFADD8E6);
  static const Color lightGreen = Color(0xFF90EE90);
  static const Color lightPink = Color(0xFFFFB6C1);
  static const Color lightPurple = Color(0xFF9370DB);
  static const Color lightRed = Color(0xFFFFA07A);
  static const Color lightYellow = Color(0xFFFFFFE0);
  static const Color darkBlue = Color(0xFF00008B);
  static const Color darkGreen = Color(0xFF006400);
  static const Color darkPink = Color(0xFFFF1493);
  static const Color darkPurple = Color(0xFF800080);
  static const Color darkRed = Color(0xFF8B0000);
  static const Color darkYellow = Color(0xFFBDB76B);
  static const Color amber = Color(0xFFFFD700);
  static const Color lime = Color(0xFF00FF00);
  static const Color indigo = Color(0xFF4B0082);
  static const Color cyanAccent = Color(0xFF00FFFF);
  static const Color pinkAccent = Color(0xFFFF4081);
  static const Color purpleAccent = Color(0xFF7C4DFF);
  static const Color redAccent = Color(0xFFFF5252);
  static const Color yellowAccent = Color(0xFFFFFF6B);
  static const Color greenAccent = Color(0xFF69F0AE);
  static const Color blueAccent = Color(0xFF64B5F6);
  static const Color tealAccent = Color(0xFF64FFDA);
  static const Color orangeAccent = Color(0xFFFFAB40);
  static const Color brownAccent = Color(0xFFD7CCC8);
  static const Color greyAccent = Color(0xFFE0E0E0);
  static const Color lightGreyAccent = Color(0xFFFAFAFA);
  static const Color darkGreyAccent = Color(0xFF424242);
  static const Color lightBlueAccent = Color(0xFFB3E5FC);
  static const Color lightGreenAccent = Color(0xFFCCFF90);
  static const Color lightPinkAccent = Color(0xFFFF80AB);
  static const Color lightPurpleAccent = Color(0xFFB388FF);
  static const Color lightRedAccent = Color(0xFFFF8A80);
  static const Color lightYellowAccent = Color(0xFFFFFF8D);
  static const Color darkBlueAccent = Color(0xFF2962FF);
  static const Color darkGreenAccent = Color(0xFF64DD17);
  static const Color darkPinkAccent = Color(0xFFFF4081);
  static const Color darkPurpleAccent = Color(0xFF651FFF);
  static const Color darkRedAccent = Color(0xFFD50000);
  static const Color darkYellowAccent = Color(0xFFFFD600);
  static const Color amberAccent = Color(0xFFFFAB00);
  static const Color limeAccent = Color(0xFFAEEA00);
  static const Color indigoAccent = Color(0xFF536DFE);
}

// eof
