import "package:core_flutter/core_dart.dart";

enum ReservationSlotRepositoryFilter {
  active,
  archived,
}

abstract class ReservationSlotRepository {
  Future<List<ReservationSlot>> readAll(String reservationId, {ReservationSlotRepositoryFilter filter});
  Future<bool> create(ReservationSlot slot);
  Future<bool> update(ReservationSlot slot);

  Future<bool> reorder(List<ReservationSlot> slots);

  Future<bool> archive(ReservationSlot slot);
  Future<bool> block(ReservationSlot slot);
  Future<bool> unblock(ReservationSlot slot);
}

// eof
