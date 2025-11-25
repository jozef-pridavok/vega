import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/reservation_slot.dart";

@immutable
abstract class ReservationSlotsState {}

class ReservationSlotsInitial extends ReservationSlotsState {}

class ReservationSlotsLoading extends ReservationSlotsState {
  final String reservationId;
  ReservationSlotsLoading({
    required this.reservationId,
  });
}

class ReservationSlotsSucceed extends ReservationSlotsState {
  final String reservationId;
  final List<ReservationSlot> slots;
  ReservationSlotsSucceed({required this.reservationId, required this.slots});
}

class ReservationSlotsRefreshing extends ReservationSlotsSucceed {
  ReservationSlotsRefreshing({required super.reservationId, required super.slots});
}

class ReservationSlotsFailed extends ReservationSlotsState implements FailedState {
  final String reservationId;
  @override
  final CoreError error;
  @override
  ReservationSlotsFailed(this.error, {required this.reservationId});
}

class ReservationSlotsNotifier extends StateNotifier<ReservationSlotsState> with StateMixin {
  final ReservationSlotRepositoryFilter filter;
  final ReservationSlotRepository slotRepository;

  ReservationSlotsNotifier(
    this.filter, {
    required this.slotRepository,
  }) : super(ReservationSlotsInitial());

  final String _refreshKey = uuid();

  String? hasRefreshKey(List<String> keys) => keys.contains(_refreshKey) ? _refreshKey : null;

  String reset() {
    state = ReservationSlotsInitial();
    return _refreshKey;
  }

  Future<void> load(String reservationId, {bool reload = false}) async {
    if (!reload && cast<ReservationSlotsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    try {
      if (state is! ReservationSlotsRefreshing) state = ReservationSlotsLoading(reservationId: reservationId);
      final reservationSlots = await slotRepository.readAll(reservationId, filter: filter);
      state = ReservationSlotsSucceed(reservationId: reservationId, slots: reservationSlots);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ReservationSlotsFailed(err, reservationId: reservationId);
    } on Exception catch (ex) {
      state = ReservationSlotsFailed(errorFailedToLoadDataEx(ex: ex), reservationId: reservationId);
    } catch (e) {
      warning(e.toString());
      state = ReservationSlotsFailed(errorFailedToLoadData, reservationId: reservationId);
    }
  }

  Future<void> refresh(String reservationId, {String? refreshKey}) async {
    if (refreshKey == _refreshKey) return load(reservationId);
    final succeed = cast<ReservationSlotsSucceed>(state);
    if (succeed == null) return await load(reservationId, reload: true);
    state = ReservationSlotsRefreshing(reservationId: reservationId, slots: succeed.slots);
    await load(reservationId, reload: true);
  }

  bool added(ReservationSlot slot) {
    return next(state, [ReservationSlotsSucceed], () {
      final succeed = cast<ReservationSlotsSucceed>(state)!;
      final reservationId = succeed.reservationId;
      final slots = succeed.slots;
      final index = slots.indexWhere((r) => r.reservationSlotId == slot.reservationSlotId);
      if (index != -1) return false;
      slots.insert(0, slot);
      state = ReservationSlotsSucceed(reservationId: reservationId, slots: slots);
      return true;
    });
  }

  bool updated(ReservationSlot slot) {
    return next(state, [ReservationSlotsSucceed], () {
      final succeed = cast<ReservationSlotsSucceed>(state)!;
      final reservationId = succeed.reservationId;
      final slots = succeed.slots;
      final index = slots.indexWhere((r) => r.reservationSlotId == slot.reservationSlotId);
      if (index == -1) return false;
      slots.replaceRange(index, index + 1, [slot]);
      state = ReservationSlotsSucceed(reservationId: reservationId, slots: slots);
      return true;
    });
  }

  bool removed(ReservationSlot slot) {
    return next(state, [ReservationSlotsSucceed], () {
      final succeed = cast<ReservationSlotsSucceed>(state)!;
      final reservationId = succeed.reservationId;
      final slots = succeed.slots;
      final index = slots.indexWhere((r) => r.reservationSlotId == slot.reservationSlotId);
      if (index == -1) return false;
      slots.removeAt(index);
      state = ReservationSlotsSucceed(reservationId: reservationId, slots: slots);
      return true;
    });
  }

  Future<void> reorder(ReservationSlot reservationSlot, int oldIndex, int newIndex) async {
    if (state is! ReservationSlotsSucceed) return debug(() => errorUnexpectedState.toString());
    final succeed = cast<ReservationSlotsSucceed>(state)!;
    final reservationSlots = succeed.slots;
    try {
      final removedSlot = reservationSlots.removeAt(oldIndex);
      reservationSlots.insert(newIndex, removedSlot);
      final newSlots = reservationSlots.map((slot) => slot.copyWith(rank: reservationSlots.indexOf(slot))).toList();
      state = ReservationSlotsRefreshing(reservationId: succeed.reservationId, slots: reservationSlots);
      // ignore: unused_local_variable
      final affected = await slotRepository.reorder(newSlots);
      state = ReservationSlotsSucceed(reservationId: succeed.reservationId, slots: newSlots);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ReservationSlotsFailed(err, reservationId: succeed.reservationId);
    } catch (e) {
      warning(e.toString());
      state = ReservationSlotsFailed(errorFailedToSaveData, reservationId: succeed.reservationId);
    }
  }
}

// eof
