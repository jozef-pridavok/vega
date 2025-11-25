import "package:collection/collection.dart";

enum FolderLayout {
  twoColumns,
  threeColumns,
  fourColumns,
  fiveColumns,
}

extension FolderLayoutCode on FolderLayout {
  static final _codeMap = {
    FolderLayout.twoColumns: 2,
    FolderLayout.threeColumns: 3,
    FolderLayout.fourColumns: 4,
    FolderLayout.fiveColumns: 5,
  };

  int get code => _codeMap[this]!;

  static FolderLayout fromCode(int? code, {FolderLayout def = FolderLayout.twoColumns}) =>
      FolderLayout.values.firstWhere((r) => r.code == code, orElse: () => def);

  static FolderLayout? fromCodeOrNull(int? code) => FolderLayout.values.firstWhereOrNull((r) => r.code == code);
}

// eof
