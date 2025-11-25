import "package:collection/collection.dart";

enum ReservationDateStatus { available, confirmed, completed, forfeited }

extension ReservationDateStatusCode on ReservationDateStatus {
  static final _codeMap = {
    ReservationDateStatus.available: 1,
    ReservationDateStatus.confirmed: 2,
    ReservationDateStatus.completed: 3,
    ReservationDateStatus.forfeited: 4,
  };

  int get code => _codeMap[this]!;

  static ReservationDateStatus fromCode(int? code, {ReservationDateStatus def = ReservationDateStatus.available}) =>
      ReservationDateStatus.values.firstWhere(
        (r) => r.code == code,
        orElse: () => def,
      );

  static ReservationDateStatus? fromCodeOrNull(int? code) =>
      ReservationDateStatus.values.firstWhereOrNull((r) => r.code == code);
}

// eof
