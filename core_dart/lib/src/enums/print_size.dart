enum PrintSize { a3, a4, a5, letter, legal, tabloid }

extension PrintSizeCode on PrintSize {
  static final _codeMap = {
    PrintSize.a3: 1,
    PrintSize.a4: 2,
    PrintSize.a5: 3,
    PrintSize.letter: 4,
    PrintSize.legal: 5,
    PrintSize.tabloid: 6,
  };

  int get code => _codeMap[this]!;

  static PrintSize fromCode(int? code, {PrintSize def = PrintSize.a4}) => PrintSize.values.firstWhere(
        (size) => size.code == code,
        orElse: () => def,
      );
}

// eof
