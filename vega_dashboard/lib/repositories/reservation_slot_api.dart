import "dart:io";

import "package:core_flutter/core_dart.dart";

import "reservation_slot.dart";

extension _ReservationSlotRepositoryFilterCode on ReservationSlotRepositoryFilter {
  static final _codeMap = {
    ReservationSlotRepositoryFilter.active: 1,
    ReservationSlotRepositoryFilter.archived: 2,
  };
  int get code => _codeMap[this]!;
}

class ApiReservationSlotRepository with LoggerMixin implements ReservationSlotRepository {
  @override
  Future<List<ReservationSlot>> readAll(
    String reservationId, {
    filter = ReservationSlotRepositoryFilter.active,
  }) async {
    final res = await ApiClient().get(
      "/v1/dashboard/reservation_slot/$reservationId",
      params: {"filter": filter.code},
    );
    final json = await res.handleStatusCodeWithJson();
    return (json?["reservationSlots"] as JsonArray?)
            ?.map((e) => ReservationSlot.fromMap(e, ReservationSlot.camel, reservationDatesMap: e))
            .toList() ??
        [];
  }

  @override
  Future<bool> create(ReservationSlot slot) async {
    final res = await ApiClient().post(
      "/v1/dashboard/reservation_slot/${slot.reservationSlotId}",
      data: slot.toMap(ReservationSlot.camel),
    );
    final json = await res.handleStatusCodeWithJson(HttpStatus.created);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> update(ReservationSlot slot, {List<int>? image}) async {
    final res = await ApiClient().put(
      "/v1/dashboard/reservation_slot/${slot.reservationSlotId}",
      data: slot.toMap(ReservationSlot.camel),
    );
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> reorder(List<ReservationSlot> slots) async {
    final ApiResponse res = await ApiClient().put(
      "/v1/dashboard/reservation_slot/reorder",
      data: {"reorder": slots.map((e) => e.reservationSlotId).toList()},
    );
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == slots.length;
  }

  Future<bool> _patch(ReservationSlot slot, Map<String, dynamic> data) async {
    final res = await ApiClient().patch(
      "/v1/dashboard/reservation_slot/${slot.reservationSlotId}",
      data: data,
    );
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> block(ReservationSlot reservationSlot) => _patch(reservationSlot, {"blocked": true});

  @override
  Future<bool> unblock(ReservationSlot reservationSlot) => _patch(reservationSlot, {"blocked": false});

  @override
  Future<bool> archive(ReservationSlot reservationSlot) => _patch(reservationSlot, {"archived": true});
}

// eof
