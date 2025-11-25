import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/data_model.dart";
import "../repositories/coupon.dart";

@immutable
abstract class CouponEditorState {
  final Coupon coupon;
  final bool isNew;
  CouponEditorState(this.coupon, {this.isNew = false});
}

extension CouponEditorStateToActionButtonState on CouponEditorState {
  static const stateMap = {
    CouponEditorSaving: MoleculeActionButtonState.loading,
    CouponEditorSaved: MoleculeActionButtonState.success,
    CouponEditorFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class CouponEditorInitial extends CouponEditorState {
  CouponEditorInitial() : super(DataModel.emptyCoupon());
}

class CouponEditorEditing extends CouponEditorState {
  CouponEditorEditing(super.coupon, {super.isNew = false});

  factory CouponEditorEditing.from(CouponEditorState state) => CouponEditorEditing(state.coupon, isNew: state.isNew);
}

class CouponEditorSaving extends CouponEditorEditing {
  CouponEditorSaving(super.coupon, {required super.isNew});

  factory CouponEditorSaving.from(CouponEditorState state) => CouponEditorSaving(
        state.coupon,
        isNew: state.isNew,
      );
}

class CouponEditorSaved extends CouponEditorSaving {
  CouponEditorSaved(super.leaflet, {required super.isNew});

  factory CouponEditorSaved.from(CouponEditorState state, {bool? isNew}) => CouponEditorSaved(
        state.coupon,
        isNew: isNew ?? state.isNew,
      );
}

class CouponEditorFailed extends CouponEditorSaving implements FailedState {
  @override
  final CoreError error;
  @override
  CouponEditorFailed(this.error, super.coupon, {required super.isNew});

  factory CouponEditorFailed.from(CoreError error, CouponEditorState state) =>
      CouponEditorFailed(error, state.coupon, isNew: state.isNew);
}

class CouponEditorNotifier extends StateNotifier<CouponEditorState> with StateMixin {
  final DeviceRepository deviceRepository;
  final CouponRepository couponRepository;

  CouponEditorNotifier({
    required this.deviceRepository,
    required this.couponRepository,
  }) : super(CouponEditorInitial());

  void create() {
    final client = deviceRepository.get(DeviceKey.client) as Client;
    final coupon = DataModel.createCoupon(client);
    state = CouponEditorEditing(coupon, isNew: true);
  }

  void edit(Coupon coupon) => state = CouponEditorEditing(coupon, isNew: false);

  void reedit() {
    final savedOrFailed = expect<CouponEditorSaving>(state);
    if (savedOrFailed != null) state = CouponEditorEditing.from(state);
    state = CouponEditorEditing.from(state);
  }

  void set({
    String? name,
    String? discount,
    String? description,
    String? code,
    List<String>? codes,
    CouponType? type,
    List<Country>? countries,
    IntDate? validFrom,
    IntDate? validTo,
    String? locationId,
    CouponReservation? couponReservation,
    CouponOrder? couponOrder,
    int? userIssueLimit,
  }) {
    final currentState = expect<CouponEditorEditing>(state);
    if (currentState == null) return;
    var updatedMeta = currentState.coupon.meta;
    if (userIssueLimit != null) (updatedMeta ??= {})["userIssueLimit"] = userIssueLimit;
    final coupon = currentState.coupon.copyWith(
      name: name ?? currentState.coupon.name,
      description: description ?? currentState.coupon.description,
      type: type ?? currentState.coupon.type,
      discount: discount ?? currentState.coupon.discount,
      code: code ?? currentState.coupon.code,
      codes: codes ?? currentState.coupon.codes,
      countries: countries ?? currentState.coupon.countries,
      validFrom: validFrom ?? currentState.coupon.validFrom,
      validTo: validTo ?? currentState.coupon.validTo,
      locationId: locationId ?? currentState.coupon.locationId,
      reservation: couponReservation ?? currentState.coupon.reservation,
      order: couponOrder ?? currentState.coupon.order,
      meta: updatedMeta,
    );
    state = CouponEditorEditing(coupon, isNew: currentState.isNew);
  }

  Future<void> save({List<int>? newImage}) async {
    final editing = expect<CouponEditorEditing>(state);
    if (editing == null) return;
    state = CouponEditorSaving.from(editing);
    try {
      final saved = state.isNew
          ? await couponRepository.create(state.coupon, image: newImage)
          : await couponRepository.update(state.coupon, image: newImage);
      state =
          saved ? CouponEditorSaved.from(state, isNew: false) : CouponEditorFailed.from(errorFailedToSaveData, state);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = CouponEditorFailed.from(err, state);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = CouponEditorFailed.from(errorFailedToSaveDataEx(ex: ex), state);
    } catch (e) {
      verbose(() => e.toString());
      state = CouponEditorFailed.from(errorFailedToSaveData, state);
    }
  }
}

// eof
