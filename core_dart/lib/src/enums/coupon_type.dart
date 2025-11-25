import "package:collection/collection.dart";

enum CouponType { universal, array, manual, reservation, product }

enum CouponCodeMaskType { onlyUpperCase, onlyLetters, onlyDigits, lettersAndDigits }

extension CouponTypeCode on CouponType {
  static final _codeMap = {
    CouponType.universal: 1,
    CouponType.array: 2,
    CouponType.manual: 3,
    CouponType.reservation: 4,
    CouponType.product: 5,
  };

  int get code => _codeMap[this]!;

  static CouponType fromCode(int? code, {CouponType def = CouponType.universal}) =>
      CouponType.values.firstWhere((r) => r.code == code, orElse: () => def);

  static CouponType? fromCodeOrNull(int? code) => CouponType.values.firstWhereOrNull((r) => r.code == code);
}

extension CouponCodeMaskTypeCode on CouponCodeMaskType {
  static final _translationKeyMap = {
    CouponCodeMaskType.onlyUpperCase: "only_upper_case",
    CouponCodeMaskType.onlyLetters: "only_letters",
    CouponCodeMaskType.onlyDigits: "only_digits",
    CouponCodeMaskType.lettersAndDigits: "letters_and_digits",
  };

  String get translationKey => _translationKeyMap[this]!;

  static final _codeMap = {
    CouponCodeMaskType.onlyUpperCase: 1,
    CouponCodeMaskType.onlyLetters: 2,
    CouponCodeMaskType.onlyDigits: 3,
    CouponCodeMaskType.lettersAndDigits: 4,
  };

  int get code => _codeMap[this]!;

  static CouponCodeMaskType fromCode(int? code, {CouponCodeMaskType def = CouponCodeMaskType.onlyUpperCase}) =>
      CouponCodeMaskType.values.firstWhere((r) => r.code == code, orElse: () => def);

  static CouponCodeMaskType? fromCodeOrNull(int? code) =>
      CouponCodeMaskType.values.firstWhereOrNull((r) => r.code == code);
}

// eof
