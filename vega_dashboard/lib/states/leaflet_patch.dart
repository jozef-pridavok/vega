import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/data_models/data_model.dart";

import "../../repositories/leaflet.dart";

enum LeafletPatchPhase {
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

class LeafletPatchState {
  final LeafletPatchPhase phase;
  final Leaflet leaflet;
  LeafletPatchState(this.phase, this.leaflet);

  factory LeafletPatchState.initial() => LeafletPatchState(LeafletPatchPhase.initial, DataModel.emptyLeaflet());

  factory LeafletPatchState.starting(Leaflet leaflet) => LeafletPatchState(LeafletPatchPhase.starting, leaflet);
  factory LeafletPatchState.started(Leaflet leaflet) => LeafletPatchState(LeafletPatchPhase.started, leaflet);

  factory LeafletPatchState.finishing(Leaflet leaflet) => LeafletPatchState(LeafletPatchPhase.finishing, leaflet);
  factory LeafletPatchState.finished(Leaflet leaflet) => LeafletPatchState(LeafletPatchPhase.finished, leaflet);

  factory LeafletPatchState.blocking(Leaflet leaflet) => LeafletPatchState(LeafletPatchPhase.blocking, leaflet);
  factory LeafletPatchState.blocked(Leaflet leaflet) => LeafletPatchState(LeafletPatchPhase.blocked, leaflet);

  factory LeafletPatchState.unblocking(Leaflet leaflet) => LeafletPatchState(LeafletPatchPhase.unblocking, leaflet);
  factory LeafletPatchState.unblocked(Leaflet leaflet) => LeafletPatchState(LeafletPatchPhase.unblocked, leaflet);

  factory LeafletPatchState.archiving(Leaflet leaflet) => LeafletPatchState(LeafletPatchPhase.archiving, leaflet);
  factory LeafletPatchState.archived(Leaflet leaflet) => LeafletPatchState(LeafletPatchPhase.archived, leaflet);
}

extension LeafletPatchStateToActionButtonState on LeafletPatchState {
  static const stateMap = {
    LeafletPatchPhase.starting: MoleculeActionButtonState.loading,
    LeafletPatchPhase.started: MoleculeActionButtonState.success,
    LeafletPatchPhase.finishing: MoleculeActionButtonState.loading,
    LeafletPatchPhase.finished: MoleculeActionButtonState.success,
    LeafletPatchPhase.blocking: MoleculeActionButtonState.loading,
    LeafletPatchPhase.blocked: MoleculeActionButtonState.success,
    LeafletPatchPhase.unblocking: MoleculeActionButtonState.loading,
    LeafletPatchPhase.unblocked: MoleculeActionButtonState.success,
    LeafletPatchPhase.archiving: MoleculeActionButtonState.loading,
    LeafletPatchPhase.archived: MoleculeActionButtonState.success,
    LeafletPatchPhase.failed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[phase] ?? MoleculeActionButtonState.idle;
}

class LeafletPatchFailed extends LeafletPatchState implements FailedState {
  @override
  final CoreError error;
  @override
  LeafletPatchFailed(this.error, Leaflet leaflet) : super(LeafletPatchPhase.failed, leaflet);

  factory LeafletPatchFailed.from(CoreError error, LeafletPatchState state) => LeafletPatchFailed(error, state.leaflet);
}

class LeafletPatchNotifier extends StateNotifier<LeafletPatchState> with LoggerMixin {
  final DeviceRepository deviceRepository;
  final LeafletsRepository leafletRepository;

  LeafletPatchNotifier({
    required this.deviceRepository,
    required this.leafletRepository,
  }) : super(LeafletPatchState.initial());

  Future<void> reset() async => state = LeafletPatchState.initial();

  Future<void> start(Leaflet leaflet) async {
    try {
      state = LeafletPatchState.starting(leaflet);
      bool started = await leafletRepository.start(leaflet);
      state = started ? LeafletPatchState.started(leaflet) : LeafletPatchFailed(errorFailedToSaveData, leaflet);
    } catch (e) {
      verbose(() => e.toString());
      state = LeafletPatchFailed(errorFailedToSaveData, leaflet);
    }
  }

  Future<void> finish(Leaflet leaflet) async {
    try {
      state = LeafletPatchState.finishing(leaflet);
      bool finished = await leafletRepository.finish(leaflet);
      state = finished ? LeafletPatchState.finished(leaflet) : LeafletPatchFailed(errorFailedToSaveData, leaflet);
    } catch (e) {
      verbose(() => e.toString());
      state = LeafletPatchFailed(errorFailedToSaveData, leaflet);
    }
  }

  Future<void> block(Leaflet leaflet) async {
    try {
      state = LeafletPatchState.blocking(leaflet);
      bool blocked = await leafletRepository.block(leaflet);
      state = blocked
          ? LeafletPatchState.blocked(leaflet.copyWith(blocked: true))
          : LeafletPatchFailed(errorFailedToSaveData, leaflet);
    } catch (e) {
      verbose(() => e.toString());
      state = LeafletPatchFailed(errorFailedToSaveData, leaflet);
    }
  }

  Future<void> unblock(Leaflet leaflet) async {
    try {
      state = LeafletPatchState.unblocking(leaflet);
      bool unblocked = await leafletRepository.unblock(leaflet);
      state = unblocked
          ? LeafletPatchState.unblocked(leaflet.copyWith(blocked: false))
          : LeafletPatchFailed(errorFailedToSaveData, leaflet);
    } catch (e) {
      verbose(() => e.toString());
      state = LeafletPatchFailed(errorFailedToSaveData, leaflet);
    }
  }

  Future<void> archive(Leaflet leaflet) async {
    try {
      state = LeafletPatchState.archiving(leaflet);
      bool archived = await leafletRepository.archive(leaflet);
      state = archived ? LeafletPatchState.archived(leaflet) : LeafletPatchFailed(errorFailedToSaveData, leaflet);
    } catch (e) {
      verbose(() => e.toString());
      state = LeafletPatchFailed(errorFailedToSaveData, leaflet);
    }
  }
}

// eof
