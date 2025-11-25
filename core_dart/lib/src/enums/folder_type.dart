import "package:collection/collection.dart";

enum FolderType {
  all,
  favorites,
  common,
}

extension FolderTypeCode on FolderType {
  static final _codeMap = {
    FolderType.all: 1,
    FolderType.favorites: 2,
    FolderType.common: 3,
  };

  int get code => _codeMap[this]!;

  static FolderType fromCode(int? code, {FolderType def = FolderType.all}) =>
      FolderType.values.firstWhere((r) => r.code == code, orElse: () => def);

  static FolderType? fromCodeOrNull(int? code) => FolderType.values.firstWhereOrNull((r) => r.code == code);
}

// eof
