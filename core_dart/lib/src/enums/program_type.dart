import "package:collection/collection.dart";

enum ProgramType { reach, collect, credit }

extension ProgramTypeCode on ProgramType {
  static final _codeMap = {
    ProgramType.reach: 1,
    ProgramType.collect: 2,
    ProgramType.credit: 3,
  };

  int get code => _codeMap[this]!;

  static ProgramType fromCode(int? code, {ProgramType def = ProgramType.reach}) =>
      ProgramType.values.firstWhere((r) => r.code == code, orElse: () => def);

  static ProgramType? fromCodeOrNull(int? code) => ProgramType.values.firstWhereOrNull((r) => r.code == code);
}

// eof
