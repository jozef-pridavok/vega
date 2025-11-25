import "package:collection/collection.dart";

enum Theme { system, dark, light }

extension ThemeCode on Theme {
  static final _codeMap = {
    Theme.system: 1,
    Theme.dark: 2,
    Theme.light: 3,
  };

  int get code => _codeMap[this]!;

  static Theme fromCode(int? code, {Theme def = Theme.system}) => Theme.values.firstWhere(
        (r) => r.code == code,
        orElse: () => def,
      );

  static Theme? fromCodeOrNull(int? code) => Theme.values.firstWhereOrNull((r) => r.code == code);
}
// eof
