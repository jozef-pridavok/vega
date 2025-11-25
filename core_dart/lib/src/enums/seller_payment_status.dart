import "package:collection/collection.dart";

enum SellerPaymentStatus { waiting, pending, processing, canceled, failed, paid }

extension SellerPaymentStatusCode on SellerPaymentStatus {
  static final _codeMap = {
    SellerPaymentStatus.waiting: 0,
    SellerPaymentStatus.pending: 1,
    SellerPaymentStatus.processing: 2,
    SellerPaymentStatus.canceled: 3,
    SellerPaymentStatus.failed: 4,
    SellerPaymentStatus.paid: 5,
  };

  int get code => _codeMap[this]!;

  static SellerPaymentStatus fromCode(int? code, {SellerPaymentStatus def = SellerPaymentStatus.pending}) =>
      SellerPaymentStatus.values.firstWhere((r) => r.code == code, orElse: () => def);

  static SellerPaymentStatus? fromCodeOrNull(int? code) =>
      SellerPaymentStatus.values.firstWhereOrNull((r) => r.code == code);
}


// eof
