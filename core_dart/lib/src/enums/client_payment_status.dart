import "package:collection/collection.dart";

enum ClientPaymentStatus { pending, processing, canceled, failed, paid }

extension ClientPaymentStatusCode on ClientPaymentStatus {
  static final _codeMap = {
    ClientPaymentStatus.pending: 0,
    ClientPaymentStatus.processing: 1,
    ClientPaymentStatus.canceled: 2,
    ClientPaymentStatus.failed: 3,
    ClientPaymentStatus.paid: 4,
  };

  int get code => _codeMap[this]!;

  static ClientPaymentStatus fromCode(int? code, {ClientPaymentStatus def = ClientPaymentStatus.pending}) =>
      ClientPaymentStatus.values.firstWhere((r) => r.code == code, orElse: () => def);

  static ClientPaymentStatus? fromCodeOrNull(int? code) =>
      ClientPaymentStatus.values.firstWhereOrNull((r) => r.code == code);
}


// eof
