import "package:collection/collection.dart";

enum CodeType {
  upca,
  upce,
  ean8,
  ean13,
  code39,
  code93,
  code128,
  itf14,
  interleaved2of5,
  pdf417,
  aztec,
  qr,
  datamatrix,
}

extension CodeTypeCode on CodeType {
  static final _codeMap = {
    CodeType.upca: 1,
    CodeType.upce: 2,
    CodeType.ean8: 3,
    CodeType.ean13: 4,
    CodeType.code39: 5,
    CodeType.code93: 6,
    CodeType.code128: 7,
    CodeType.itf14: 8,
    CodeType.interleaved2of5: 9,
    CodeType.pdf417: 10,
    CodeType.aztec: 11,
    CodeType.qr: 12,
    CodeType.datamatrix: 13,
  };

  int get code => _codeMap[this]!;

  static CodeType fromCode(int? code, {CodeType def = CodeType.code128}) =>
      CodeType.values.firstWhere((r) => r.code == code, orElse: () => def);

  static CodeType? fromCodeOrNull(int? code) => CodeType.values.firstWhereOrNull((r) => r.code == code);
}

extension CodeTypeTopology on CodeType {
  bool get isSquare => this == CodeType.qr || this == CodeType.datamatrix;
  bool get isRectangular => !isSquare;
}

// eof
