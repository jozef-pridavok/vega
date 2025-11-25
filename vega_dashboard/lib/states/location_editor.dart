import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/data_models/data_model.dart";

import "../data_models/location.dart";
import "../repositories/location.dart";

@immutable
abstract class LocationEditorState {}

extension LocationEditorStateToActionButtonState on LocationEditorState {
  static const stateMap = {
    LocationEditorSaving: MoleculeActionButtonState.loading,
    LocationEditorSaved: MoleculeActionButtonState.success,
    LocationEditorFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class LocationEditorInitial extends LocationEditorState {}

class LocationEditorEditing extends LocationEditorState {
  final Location location;
  final bool isNew;
  LocationEditorEditing({required this.location, this.isNew = false});
}

class LocationEditorSaving extends LocationEditorEditing {
  LocationEditorSaving({required super.location, required super.isNew});
}

class LocationEditorSaved extends LocationEditorSaving {
  LocationEditorSaved({required super.location}) : super(isNew: false);
}

class LocationEditorFailed extends LocationEditorSaving implements FailedState {
  @override
  final CoreError error;
  @override
  LocationEditorFailed(this.error, {required super.location, required super.isNew});
}

class LocationEditorNotifier extends StateNotifier<LocationEditorState> with StateMixin {
  final DeviceRepository deviceRepository;
  final LocationsRepository locationRepository;

  LocationEditorNotifier({
    required this.deviceRepository,
    required this.locationRepository,
  }) : super(LocationEditorInitial());

  void reset() => state = LocationEditorInitial();

  void create() {
    final client = deviceRepository.get(DeviceKey.client) as Client;
    final location = DataModel.createLocation(client);
    state = LocationEditorEditing(location: location, isNew: true);
  }

  void edit(Location location) => state = LocationEditorEditing(location: location.copy());

  void set({
    String? name,
    String? description,
    String? addressLine1,
    String? addressLine2,
    String? city,
    String? zip,
    String? state,
    Country? country,
    String? phone,
    String? email,
    String? website,
    double? latitude,
    double? longitude,
    LocationType? type,
    OpeningHours? openingHours,
    //OpeningHoursExceptions? openingHoursExceptions,
    //IntDate? deleteException,
    //({IntDate date, String exc})? addException,
  }) {
    final editing = expect<LocationEditorEditing>(this.state);
    if (editing == null) return;

    //var openingHoursExceptions = editing.location.openingHoursExceptions;
    //if (deleteException != null) openingHoursExceptions?.deleteException(deleteException);
    //if (addException != null) {
    //  openingHoursExceptions = OpeningHoursExceptions.fromMap({});
    //  openingHoursExceptions.addException(addException.date, addException.exc);
    //}

    final location = editing.location.copyWith(
      name: name,
      description: description,
      addressLine1: addressLine1,
      addressLine2: addressLine2,
      city: city,
      zip: zip,
      state: state,
      country: country,
      phone: phone,
      email: email,
      website: website,
      latitude: latitude,
      longitude: longitude,
      type: type,
      openingHours: openingHours,
      //openingHoursExceptions: openingHoursExceptions,
    );

    this.state = LocationEditorEditing(location: location, isNew: editing.isNew);
  }

  void addException(IntDate date, String exception) {
    final editing = expect<LocationEditorEditing>(state);
    if (editing == null) return;

    final openingHoursExceptions = editing.location.openingHoursExceptions ?? OpeningHoursExceptions.fromMap({});
    openingHoursExceptions.addException(date, exception);

    final location = editing.location.copyWith(
      openingHoursExceptions: openingHoursExceptions,
    );

    state = LocationEditorEditing(location: location, isNew: editing.isNew);
  }

  void deleteException(IntDate date) {
    final editing = expect<LocationEditorEditing>(state);
    if (editing == null) return;

    final openingHoursExceptions = editing.location.openingHoursExceptions ?? OpeningHoursExceptions.fromMap({});
    openingHoursExceptions.deleteException(date);

    final location = editing.location.copyWith(
      openingHoursExceptions: openingHoursExceptions,
    );

    state = LocationEditorEditing(location: location, isNew: editing.isNew);
  }

  Future<void> save() async {
    final currentState = cast<LocationEditorEditing>(state);
    if (currentState == null) return debug(() => errorUnexpectedState.toString());
    final location = currentState.location;
    state = LocationEditorSaving(location: location, isNew: currentState.isNew);
    try {
      final ok =
          currentState.isNew ? await locationRepository.create(location) : await locationRepository.update(location);
      state = ok
          ? LocationEditorSaved(location: location)
          : LocationEditorFailed(errorFailedToSaveData, location: location, isNew: currentState.isNew);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = LocationEditorFailed(err, location: location, isNew: currentState.isNew);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = LocationEditorFailed(errorFailedToSaveDataEx(ex: ex), location: location, isNew: currentState.isNew);
    } catch (e) {
      verbose(() => e.toString());
      state = LocationEditorFailed(errorFailedToSaveData, location: location, isNew: currentState.isNew);
    }
  }

  void reedit() {
    final saving = expect<LocationEditorSaving>(state);
    if (saving == null) return;
    state = LocationEditorEditing(location: saving.location, isNew: saving.isNew);
  }

  Future<void> refresh() async {
    final editing = expect<LocationEditorEditing>(state);
    if (editing == null) return;
    state = LocationEditorEditing(location: editing.location, isNew: editing.isNew);
  }
}

// eof
