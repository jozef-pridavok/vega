import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/location.dart";

@immutable
abstract class LocationsState {}

class LocationsInitial extends LocationsState {}

class LocationsLoading extends LocationsState {}

class LocationsSucceed extends LocationsState {
  final List<Location> locations;
  LocationsSucceed(this.locations);
}

class LocationsRefreshing extends LocationsSucceed {
  LocationsRefreshing(super.locations);
}

class LocationsFailed extends LocationsState implements FailedState {
  @override
  final CoreError error;
  @override
  LocationsFailed(this.error);
}

class LocationsNotifier extends StateNotifier<LocationsState> with StateMixin {
  final LocationsRepository locationRepository;

  LocationsNotifier({required this.locationRepository}) : super(LocationsInitial());

  final String _refreshKey = uuid();

  String? hasRefreshKey(List<String> keys) => keys.contains(_refreshKey) ? _refreshKey : null;

  String reset() {
    state = LocationsInitial();
    return _refreshKey;
  }

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<LocationsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! LocationsRefreshing) state = LocationsLoading();
      final locations = await locationRepository.readAll();
      state = LocationsSucceed(locations);
    } on CoreError catch (err) {
      warning(err.toString());
      state = LocationsFailed(err);
    } on Exception catch (ex) {
      state = LocationsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = LocationsFailed(errorFailedToLoadData);
    }
  }

  Future<void> refresh({String? refreshKey}) async {
    if (refreshKey == _refreshKey) return load();
    final succeed = cast<LocationsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = LocationsRefreshing(succeed.locations);
    await load(reload: true);
  }

  bool added(Location location) {
    return next(state, [LocationsSucceed], () {
      final locations = cast<LocationsSucceed>(state)!.locations;
      final index = locations.indexWhere((e) => e.locationId == location.locationId);
      if (index != -1) return false;
      locations.insert(0, location);
      state = LocationsSucceed(locations);
      return true;
    });
  }

  bool updated(Location location) {
    return next(state, [LocationsSucceed], () {
      final locations = cast<LocationsSucceed>(state)!.locations;
      final index = locations.indexWhere((e) => e.locationId == location.locationId);
      if (index == -1) return false;
      locations.replaceRange(index, index + 1, [location]);
      state = LocationsSucceed(locations);
      return true;
    });
  }

  bool removed(Location location) {
    return next(state, [LocationsSucceed], () {
      final locations = cast<LocationsSucceed>(state)!.locations;
      final index = locations.indexWhere((e) => e.locationId == location.locationId);
      if (index == -1) return false;
      locations.removeAt(index);
      state = LocationsSucceed(locations);
      return true;
    });
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final succeed = expect<LocationsSucceed>(state);
    if (succeed == null) return;
    try {
      final currentLocations = succeed.locations;
      final removedLocation = currentLocations.removeAt(oldIndex);
      currentLocations.insert(newIndex, removedLocation);
      final newLocations = currentLocations.map((loc) => loc.copyWith(rank: currentLocations.indexOf(loc))).toList();
      final reordered = await locationRepository.reorder(newLocations);
      state = reordered ? LocationsSucceed(newLocations) : LocationsFailed(errorFailedToSaveData);
    } on CoreError catch (err) {
      warning(err.toString());
      state = LocationsFailed(err);
    } catch (e) {
      warning(e.toString());
      state = LocationsFailed(errorFailedToSaveData);
    }
  }
}

// eof
