enum PrintOrientation { portrait, landscape }

extension PrintOrientationCode on PrintOrientation {
  static final _codeMap = {
    PrintOrientation.portrait: 1,
    PrintOrientation.landscape: 2,
  };

  int get code => _codeMap[this]!;

  static PrintOrientation fromCode(int? code, {PrintOrientation def = PrintOrientation.portrait}) =>
      PrintOrientation.values.firstWhere(
        (r) => r.code == code,
        orElse: () => def,
      );
}


// eof
