import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/leaflet.dart";
import "../data_models/data_model.dart";

@immutable
abstract class LeafletEditorState {}

extension LeafletEditorStateToActionButtonState on LeafletEditorState {
  static const stateMap = {
    LeafletEditorSaving: MoleculeActionButtonState.loading,
    LeafletEditorSaved: MoleculeActionButtonState.success,
    LeafletEditorFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class LeafletEditorInitial extends LeafletEditorState {
  LeafletEditorInitial() : super();
}

class LeafletEditorEditing extends LeafletEditorState {
  final Leaflet leaflet;
  final bool isNew;
  LeafletEditorEditing(this.leaflet, this.isNew);
}

class LeafletEditorSaving extends LeafletEditorEditing {
  LeafletEditorSaving(super.leaflet, super.isNew);
}

class LeafletEditorSaved extends LeafletEditorSaving {
  LeafletEditorSaved(Leaflet leaflet) : super(leaflet, false);
}

class LeafletEditorFailed extends LeafletEditorEditing implements FailedState {
  @override
  final CoreError error;
  @override
  LeafletEditorFailed(this.error, Leaflet leaflet, bool isNew) : super(leaflet, isNew);

  factory LeafletEditorFailed.from(CoreError error, LeafletEditorSaving state) =>
      LeafletEditorFailed(error, state.leaflet, state.isNew);
}

class LeafletEditorNotifier extends StateNotifier<LeafletEditorState> with StateMixin {
  final DeviceRepository deviceRepository;
  final LeafletsRepository leafletRepository;

  LeafletEditorNotifier({
    required this.deviceRepository,
    required this.leafletRepository,
  }) : super(LeafletEditorInitial());

  void reset() => state = LeafletEditorInitial();

  void create() {
    final client = deviceRepository.get(DeviceKey.client) as Client;
    final leaflet = DataModel.createLeaflet(client);
    state = LeafletEditorEditing(leaflet, true);
  }

  void edit(Leaflet leaflet) {
    state = LeafletEditorEditing(leaflet, false);
  }

  void reedit() {
    final saving = expect<LeafletEditorEditing>(state);
    if (saving == null) return;
    state = LeafletEditorEditing(saving.leaflet, saving.isNew);
  }

  Future<void> save({
    String? name,
    IntDate? validFrom,
    IntDate? validTo,
    Country? country,
    String? locationId,
    List<dynamic>? pages,
  }) async {
    final editing = expect<LeafletEditorEditing>(state);
    if (editing == null) return;
    final saving = LeafletEditorSaving(
        editing.leaflet.copyWith(
          name: name,
          validFrom: validFrom,
          validTo: validTo,
          country: country,
          locationId: locationId,
        ),
        editing.isNew);
    state = saving;
    try {
      final isNew = saving.isNew;
      final leaflet = saving.leaflet;
      final saved = isNew
          ? await leafletRepository.create(leaflet, pages: pages)
          : await leafletRepository.update(leaflet, pages: pages);
      state = saved ? LeafletEditorSaved(leaflet) : LeafletEditorFailed.from(errorFailedToSaveData, saving);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = LeafletEditorFailed.from(err, saving);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = LeafletEditorFailed.from(errorFailedToSaveDataEx(ex: ex), saving);
    } catch (e) {
      verbose(() => e.toString());
      state = LeafletEditorFailed.from(errorFailedToSaveData, saving);
    }
  }
}

// eof
