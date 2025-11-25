import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_states.dart";
import "package:core_flutter/core_widgets.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:geolocator/geolocator.dart";

@immutable
abstract class UserLocationState {}

extension LoginStateToActionButtonState on UserLocationState {
  static const stateMap = {
    UserLocationInitial: MoleculeActionButtonState.idle,
    UserLocationRefreshing: MoleculeActionButtonState.loading,
    UserLocationFailed: MoleculeActionButtonState.fail,
    UserLocationSucceed: MoleculeActionButtonState.success,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class UserLocationInitial extends UserLocationState {}

class UserLocationInProgress extends UserLocationState {
  final bool ask;

  UserLocationInProgress({required this.ask});
}

class UserLocationSucceed extends UserLocationState {
  final GeoPoint location;
  final bool userAutomaticLocationDisabled;

  bool get userAutomaticLocationEnabled => !userAutomaticLocationDisabled;

  UserLocationSucceed({required this.location, required this.userAutomaticLocationDisabled});
}

class UserLocationRefreshing extends UserLocationSucceed {
  UserLocationRefreshing({required super.location, required super.userAutomaticLocationDisabled});
}

class UserLocationFailed extends UserLocationState implements FailedState {
  @override
  final CoreError error;
  UserLocationFailed(this.error);

  @override
  @override
  String toString() => error.toString();
}

class UserLocationNotifier extends StateNotifier<UserLocationState> with LoggerMixin {
  final DeviceRepository deviceRepository;

  UserLocationNotifier({required this.deviceRepository}) : super(UserLocationInitial());

  Future<void> reset() async => state = UserLocationInitial();

  Future<void> _load({/*bool reload = false,*/ bool ask = false}) async {
    if (state is UserLocationInProgress) return debug(() => errorAlreadyInProgress.toString());

    try {
      if (state is! UserLocationRefreshing) state = UserLocationInProgress(ask: ask);

      final user = deviceRepository.get(DeviceKey.user) as User;

      bool userAutomaticLocationDisabled = user.metaLocationAutoDisabled;
      final manualLocation = user.metaLocationPoint;

      if (userAutomaticLocationDisabled) {
        state = UserLocationSucceed(
          location: manualLocation ?? (CountryCode.fromCodeOrNull(user.country) ?? Country.slovakia).countryCentroid,
          userAutomaticLocationDisabled: userAutomaticLocationDisabled,
        );
        return;
      }

      final serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        state = UserLocationFailed(errorLocationPermanentlyDenied);
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.deniedForever) {
        state = UserLocationFailed(errorLocationPermanentlyDenied);
        return;
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied && ask) {
        permission = await Geolocator.requestPermission();
      }

      final systemAutomaticLocationEnabled =
          permission == LocationPermission.whileInUse || permission == LocationPermission.always;

      GeoPoint? userLocation = manualLocation;
      if (systemAutomaticLocationEnabled) {
        final pos = await Geolocator.getCurrentPosition();
        userLocation = GeoPoint(latitude: pos.latitude, longitude: pos.longitude);
      }

      if (ask && !systemAutomaticLocationEnabled) {
        userAutomaticLocationDisabled = true;
        user.setMetaLocation(autoDisabled: userAutomaticLocationDisabled);
        deviceRepository.put(DeviceKey.user, user);
        deviceRepository.put(DeviceKey.userSyncedRemotely, false);
      }

      if (userLocation == null) {
        final country = CountryCode.fromCodeOrNull(user.country) ?? Country.slovakia;
        userLocation = country.countryCentroid;
      }

      if (!userAutomaticLocationDisabled) {
        user.setMetaLocation(latitude: userLocation.latitude, longitude: userLocation.longitude);
        deviceRepository.put(DeviceKey.user, user);
        deviceRepository.put(DeviceKey.userSyncedRemotely, false);
      }

      state = UserLocationSucceed(location: userLocation, userAutomaticLocationDisabled: userAutomaticLocationDisabled);
    } catch (ex) {
      state = UserLocationFailed(errorUnexpectedException(ex));
    }
  }

  Future<void> ask() => _load(ask: true);

  Future<void> refresh() async {
    final currentState = cast<UserLocationSucceed>(state);
    if (currentState == null) return _load();
    state = UserLocationRefreshing(
      location: currentState.location,
      userAutomaticLocationDisabled: currentState.userAutomaticLocationDisabled,
    );
    await _load();
  }

  Future<void> enableAutomaticLocation() async {
    final user = deviceRepository.get(DeviceKey.user) as User;
    if (!user.metaLocationAutoDisabled) return;
    user.setMetaLocation(autoDisabled: false);
    deviceRepository.put(DeviceKey.user, user);
    deviceRepository.put(DeviceKey.userSyncedRemotely, false);
    await _load(ask: true);
  }

  Future<void> disableAutomaticLocation() async {
    final user = deviceRepository.get(DeviceKey.user) as User;
    if (user.metaLocationAutoDisabled) return;
    user.setMetaLocation(autoDisabled: true);
    deviceRepository.put(DeviceKey.user, user);
    deviceRepository.put(DeviceKey.userSyncedRemotely, false);
    GeoPoint lastLocation = cast<UserLocationSucceed>(state)?.location ??
        user.metaLocationPoint ??
        (CountryCode.fromCodeOrNull(user.country) ?? Country.slovakia).countryCentroid;
    state = UserLocationSucceed(location: lastLocation, userAutomaticLocationDisabled: true);
  }

  Future<void> updateManualLocation(GeoPoint location) async {
    final succeed = cast<UserLocationSucceed>(state);
    if (succeed == null) throw errorUnexpectedState;
    final user = deviceRepository.get(DeviceKey.user) as User;
    user.setMetaLocation(latitude: location.latitude, longitude: location.longitude);
    deviceRepository.put(DeviceKey.user, user);
    deviceRepository.put(DeviceKey.userSyncedRemotely, false);
    state = UserLocationSucceed(
      location: location,
      userAutomaticLocationDisabled: succeed.userAutomaticLocationDisabled,
    );
  }
}

// eof
