import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/user/user_address.dart";

@immutable
abstract class UserAddressState {}

extension UpdateUserCardStateToActionButtonState on UserAddressState {
  static const stateMap = {
    UserAddressSaving: MoleculeActionButtonState.loading,
    UserAddressDeleting: MoleculeActionButtonState.loading,
    UserAddressSavingFailed: MoleculeActionButtonState.fail,
    UserAddressDeletingFailed: MoleculeActionButtonState.fail,
    UserAddressSaved: MoleculeActionButtonState.success,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class UserAddressInitial extends UserAddressState {}

class UserAddressEditing extends UserAddressState {
  final UserAddress address;
  final bool isNew;
  UserAddressEditing(this.address, this.isNew);
}

class UserAddressSaving extends UserAddressState {
  final UserAddress address;
  final bool isNew;

  UserAddressSaving(this.address, this.isNew);
}

class UserAddressSaved extends UserAddressState {
  final UserAddress address;

  UserAddressSaved(this.address);
}

class UserAddressSavingFailed extends UserAddressState implements FailedState {
  final UserAddress address;
  final bool isNew;

  @override
  final CoreError error;

  UserAddressSavingFailed(this.error, this.address, this.isNew);
}

class UserAddressDeleting extends UserAddressState {
  final UserAddress address;
  UserAddressDeleting(this.address);
}

class UserAddressDeleted extends UserAddressState {
  final UserAddress address;
  UserAddressDeleted(this.address);
}

class UserAddressDeletingFailed extends UserAddressState implements FailedState {
  final UserAddress address;
  final bool isNew;

  @override
  final CoreError error;

  UserAddressDeletingFailed(this.error, this.address, this.isNew);
}

class UserAddressEditorNotifier extends StateNotifier<UserAddressState> with StateMixin {
  final DeviceRepository deviceRepository;
  final UserAddressRepository remoteAddresses;

  UserAddressEditorNotifier({
    required this.deviceRepository,
    required this.remoteAddresses,
  }) : super(UserAddressInitial());

  void reset() => state = UserAddressInitial();

  void create() {
    final user = deviceRepository.get(DeviceKey.user) as User;
    final address = UserAddress(
      userAddressId: uuid(),
      userId: user.userId,
      name: "",
    );
    state = UserAddressEditing(address, true);
  }

  void edit(UserAddress address) {
    state = UserAddressEditing(address, false);
  }

  void reedit() {
    final saving = expect<UserAddressEditing>(state);
    if (saving == null) return;
    state = UserAddressEditing(saving.address, saving.isNew);
  }

  Future<void> delete() async {
    final editing = expect<UserAddressEditing>(state);
    if (editing == null) return;
    if (editing.isNew) {
      state = UserAddressDeleted(editing.address);
      return;
    }
    state = UserAddressDeleting(editing.address);
    try {
      final deleted = await remoteAddresses.delete(editing.address);
      state = deleted
          ? UserAddressDeleted(editing.address)
          : UserAddressDeletingFailed(errorFailedToSaveData, editing.address, false);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = UserAddressDeletingFailed(err, editing.address, false);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = UserAddressDeletingFailed(errorFailedToSaveDataEx(ex: ex), editing.address, false);
    } catch (e) {
      verbose(() => e.toString());
      state = UserAddressDeletingFailed(errorFailedToSaveData, editing.address, false);
    }
  }

  Future<void> save({
    String? name,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? zip,
    String? state,
    Country? country,
    GeoPoint? geoPoint,
  }) async {
    final editing = expect<UserAddressEditing>(this.state);
    if (editing == null) return;
    final saving = UserAddressSaving(
      editing.address.copyWith(
        name: name,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        city: city,
        zip: zip,
        state: state,
        country: country,
        geoPoint: geoPoint,
      ),
      editing.isNew,
    );
    this.state = saving;
    try {
      final isNew = saving.isNew;
      final address = saving.address;
      final saved = isNew ? await remoteAddresses.create(address) : await remoteAddresses.update(address);
      this.state = saved
          ? UserAddressSaved(address)
          : UserAddressSavingFailed(errorFailedToSaveData, saving.address, saving.isNew);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      this.state = UserAddressSavingFailed(err, saving.address, saving.isNew);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      this.state = UserAddressSavingFailed(errorFailedToSaveDataEx(ex: ex), saving.address, saving.isNew);
    } catch (e) {
      verbose(() => e.toString());
      this.state = UserAddressSavingFailed(errorFailedToSaveData, saving.address, saving.isNew);
    }
  }
}

// eof
