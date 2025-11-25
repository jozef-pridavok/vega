import "package:collection/collection.dart";

enum ReceiptProvider {
  skEkasa,
  pyEkuatia,
  uyEfactura,
  arAfip,
}

extension ReceiptProviderCode on ReceiptProvider {
  static final _codeMap = {
    ReceiptProvider.skEkasa: 1,
    ReceiptProvider.pyEkuatia: 2,
    ReceiptProvider.uyEfactura: 3,
    ReceiptProvider.arAfip: 4,
  };

  int get code => _codeMap[this]!;

  static ReceiptProvider fromCode(int? code, {ReceiptProvider def = ReceiptProvider.skEkasa}) =>
      ReceiptProvider.values.firstWhere((r) => r.code == code, orElse: () => def);

  static ReceiptProvider? fromCodeOrNull(int? code) => ReceiptProvider.values.firstWhereOrNull((r) => r.code == code);
}

// eof