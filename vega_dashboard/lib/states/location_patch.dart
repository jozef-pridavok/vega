import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/location.dart";

enum LocationPatchPhase {
  initial,
  archiving,
  archived,
  failed,
}

extension LocationPatchPhaseBool on LocationPatchPhase {
  bool get isInProgress => this == LocationPatchPhase.archiving;

  bool get isSuccessful => this == LocationPatchPhase.archived;
}

class LocationPatchState {
  final LocationPatchPhase phase;
  final Location location;
  LocationPatchState(this.phase, this.location);

  factory LocationPatchState.initial() => LocationPatchState(LocationPatchPhase.initial, Location.empty());

  factory LocationPatchState.archiving(Location location) => LocationPatchState(LocationPatchPhase.archiving, location);
  factory LocationPatchState.archived(Location location) => LocationPatchState(LocationPatchPhase.archived, location);
}

extension LocationPatchStateToActionButtonState on LocationPatchState {
  static const stateMap = {
    LocationPatchPhase.archiving: MoleculeActionButtonState.loading,
    LocationPatchPhase.archived: MoleculeActionButtonState.success,
    LocationPatchPhase.failed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[phase] ?? MoleculeActionButtonState.idle;
}

class LocationPatchFailed extends LocationPatchState implements FailedState {
  @override
  final CoreError error;
  @override
  LocationPatchFailed(this.error, Location location) : super(LocationPatchPhase.failed, location);

  factory LocationPatchFailed.from(CoreError error, LocationPatchState state) =>
      LocationPatchFailed(error, state.location);
}

class LocationPatchNotifier extends StateNotifier<LocationPatchState> with LoggerMixin {
  final LocationsRepository locationRepository;

  LocationPatchNotifier({
    required this.locationRepository,
  }) : super(LocationPatchState.initial());

  Future<void> reset() async => state = LocationPatchState.initial();

  Future<void> archive(Location location) async {
    try {
      state = LocationPatchState.archiving(location);
      bool archived = await locationRepository.archive(location);
      state = archived ? LocationPatchState.archived(location) : LocationPatchFailed(errorFailedToSaveData, location);
    } catch (e) {
      verbose(() => e.toString());
      state = LocationPatchFailed(errorFailedToSaveData, location);
    }
  }
}

// eof
