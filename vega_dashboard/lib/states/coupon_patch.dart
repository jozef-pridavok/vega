import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/data_model.dart";
import "../repositories/coupon.dart";

enum CouponPatchPhase {
  initial,
  starting,
  started,
  finishing,
  finished,
  blocking,
  blocked,
  unblocking,
  unblocked,
  archiving,
  archived,
  failed,
}

class CouponPatchState {
  final CouponPatchPhase phase;
  final Coupon coupon;
  CouponPatchState(this.phase, this.coupon);

  factory CouponPatchState.initial() => CouponPatchState(CouponPatchPhase.initial, DataModel.emptyCoupon());

  factory CouponPatchState.starting(Coupon coupon) => CouponPatchState(CouponPatchPhase.starting, coupon);
  factory CouponPatchState.started(Coupon coupon) => CouponPatchState(CouponPatchPhase.started, coupon);

  factory CouponPatchState.finishing(Coupon coupon) => CouponPatchState(CouponPatchPhase.finishing, coupon);
  factory CouponPatchState.finished(Coupon coupon) => CouponPatchState(CouponPatchPhase.finished, coupon);

  factory CouponPatchState.blocking(Coupon coupon) => CouponPatchState(CouponPatchPhase.blocking, coupon);
  factory CouponPatchState.blocked(Coupon coupon) => CouponPatchState(CouponPatchPhase.blocked, coupon);

  factory CouponPatchState.unblocking(Coupon coupon) => CouponPatchState(CouponPatchPhase.unblocking, coupon);
  factory CouponPatchState.unblocked(Coupon coupon) => CouponPatchState(CouponPatchPhase.unblocked, coupon);

  factory CouponPatchState.archiving(Coupon coupon) => CouponPatchState(CouponPatchPhase.archiving, coupon);
  factory CouponPatchState.archived(Coupon coupon) => CouponPatchState(CouponPatchPhase.archived, coupon);
}

extension CouponPatchStateToActionButtonState on CouponPatchState {
  static const stateMap = {
    CouponPatchPhase.starting: MoleculeActionButtonState.loading,
    CouponPatchPhase.started: MoleculeActionButtonState.success,
    CouponPatchPhase.finishing: MoleculeActionButtonState.loading,
    CouponPatchPhase.finished: MoleculeActionButtonState.success,
    CouponPatchPhase.blocking: MoleculeActionButtonState.loading,
    CouponPatchPhase.blocked: MoleculeActionButtonState.success,
    CouponPatchPhase.unblocking: MoleculeActionButtonState.loading,
    CouponPatchPhase.unblocked: MoleculeActionButtonState.success,
    CouponPatchPhase.archiving: MoleculeActionButtonState.loading,
    CouponPatchPhase.archived: MoleculeActionButtonState.success,
    CouponPatchPhase.failed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[phase] ?? MoleculeActionButtonState.idle;
}

class CouponPatchFailed extends CouponPatchState implements FailedState {
  @override
  final CoreError error;
  @override
  CouponPatchFailed(this.error, Coupon coupon) : super(CouponPatchPhase.failed, coupon);

  factory CouponPatchFailed.from(CoreError error, CouponPatchState state) => CouponPatchFailed(error, state.coupon);
}

class CouponPatchNotifier extends StateNotifier<CouponPatchState> with LoggerMixin {
  final CouponRepository couponRepository;

  CouponPatchNotifier({
    required this.couponRepository,
  }) : super(CouponPatchState.initial());

  void reset() async => state = CouponPatchState.initial();

  Future<void> start(Coupon coupon) async {
    try {
      state = CouponPatchState.starting(coupon);
      bool started = await couponRepository.start(coupon);
      state = started ? CouponPatchState.started(coupon) : CouponPatchFailed(errorFailedToSaveData, coupon);
    } catch (e) {
      verbose(() => e.toString());
      state = CouponPatchFailed(errorFailedToSaveData, coupon);
    }
  }

  Future<void> finish(Coupon coupon) async {
    try {
      state = CouponPatchState.finishing(coupon);
      bool stopped = await couponRepository.finish(coupon);
      state = stopped ? CouponPatchState.finished(coupon) : CouponPatchFailed(errorFailedToSaveData, coupon);
    } catch (e) {
      verbose(() => e.toString());
      state = CouponPatchFailed(errorFailedToSaveData, coupon);
    }
  }

  Future<void> block(Coupon coupon) async {
    try {
      state = CouponPatchState.blocking(coupon);
      bool stopped = await couponRepository.block(coupon);
      state = stopped
          ? CouponPatchState.blocked(coupon.copyWith(blocked: true))
          : CouponPatchFailed(errorFailedToSaveData, coupon);
    } catch (e) {
      verbose(() => e.toString());
      state = CouponPatchFailed(errorFailedToSaveData, coupon);
    }
  }

  Future<void> unblock(Coupon coupon) async {
    try {
      state = CouponPatchState.unblocking(coupon);
      bool stopped = await couponRepository.unblock(coupon);
      state = stopped
          ? CouponPatchState.unblocked(coupon.copyWith(blocked: false))
          : CouponPatchFailed(errorFailedToSaveData, coupon);
    } catch (e) {
      verbose(() => e.toString());
      state = CouponPatchFailed(errorFailedToSaveData, coupon);
    }
  }

  Future<void> archive(Coupon coupon) async {
    try {
      state = CouponPatchState.archiving(coupon);
      bool archived = await couponRepository.archive(coupon);
      state = archived ? CouponPatchState.archived(coupon) : CouponPatchFailed(errorFailedToSaveData, coupon);
    } catch (e) {
      verbose(() => e.toString());
      state = CouponPatchFailed(errorFailedToSaveData, coupon);
    }
  }
}

// eof
