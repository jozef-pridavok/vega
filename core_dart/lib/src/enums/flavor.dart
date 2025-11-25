import "package:collection/collection.dart";

enum Flavor {
  dev,
  qa,
  demo,
  prod,
}

extension FlavorCode on Flavor {
  static final Map<Flavor, String> _codeMap = {
    Flavor.dev: "dev",
    Flavor.qa: "qa",
    Flavor.demo: "demo",
    Flavor.prod: "prod",
  };

  String get code => _codeMap[this]!;

  static Flavor fromCode(String? code, {Flavor def = Flavor.dev}) =>
      Flavor.values.firstWhere((r) => r.code == code, orElse: () => def);

  static Flavor? fromCodeOrNull(String? code) => Flavor.values.firstWhereOrNull((r) => r.code == code);
}

extension FlavorQrCode on Flavor {
  static final Map<Flavor, String> _codeMap = {
    Flavor.dev: "d",
    Flavor.qa: "q",
    Flavor.demo: "e",
    Flavor.prod: "p",
  };

  String get qrCode => _codeMap[this]!;
}

// eof
