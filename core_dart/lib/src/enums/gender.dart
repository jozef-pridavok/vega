import "package:collection/collection.dart";

enum Gender { man, woman }

extension GenderCode on Gender {
  static final _codeMap = {
    Gender.man: 1,
    Gender.woman: 2,
  };

  int get code => _codeMap[this]!;

  static Gender fromCode(int? code, {Gender def = Gender.man}) => Gender.values.firstWhere(
        (r) => r.code == code,
        orElse: () => def,
      );

  static Gender? fromCodeOrNull(int? code) => Gender.values.firstWhereOrNull((r) => r.code == code);
}

// eof
