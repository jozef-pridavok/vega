import "package:collection/collection.dart";

enum DeliveryType {
  delivery,
  pickup,
}

extension DeliveryTypeCode on DeliveryType {
  static final _codeMap = {
    DeliveryType.delivery: 1,
    DeliveryType.pickup: 2,
  };

  int get code => _codeMap[this]!;

  static DeliveryType fromCode(int? code, {DeliveryType def = DeliveryType.delivery}) =>
      DeliveryType.values.firstWhere((r) => r.code == code, orElse: () => def);

  static DeliveryType? fromCodeOrNull(int? code) => DeliveryType.values.firstWhereOrNull((r) => r.code == code);
}

// eof
