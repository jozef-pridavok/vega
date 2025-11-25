import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/location/location.dart";

@immutable
abstract class LocationState {}

class LocationInitial extends LocationState {}

class LocationLoading extends LocationState {}

class LocationSucceed extends LocationState {
  final Location location;

  LocationSucceed({required this.location});
}

class LocationRefreshing extends LocationSucceed {
  LocationRefreshing({required super.location});
}

class LocationFailed extends LocationState implements FailedState {
  @override
  final CoreError error;
  LocationFailed(this.error);
}

class LocationNotifier extends StateNotifier<LocationState> with LoggerMixin {
  final String locationId;
  final LocationRepository remoteRepository;
  final LocationRepository localRepository;

  LocationNotifier(
    this.locationId, {
    required this.remoteRepository,
    required this.localRepository,
  }) : super(LocationInitial());

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<LocationSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! LocationRefreshing) state = LocationLoading();

      var location = await localRepository.read(locationId);
      if (location == null || reload) {
        location = await remoteRepository.read(locationId, ignoreCache: reload);
        if (location != null) await localRepository.create(location);
      }
      state = location != null ? LocationSucceed(location: location) : LocationFailed(errorNoData);
    } on CoreError catch (e) {
      error(e.toString());
      state = LocationFailed(e);
    } catch (e) {
      error(e.toString());
      state = LocationFailed(errorUnexpectedException(e));
    }
  }

  Future<void> load() => _load();

  Future<void> reload() => _load(reload: true);

  Future<void> refresh() async {
    if (state is! LocationSucceed) return _load(reload: true);
    final location = cast<LocationSucceed>(state)!.location;
    state = LocationRefreshing(location: location);
    await _load(reload: true);
  }
}

// eof
