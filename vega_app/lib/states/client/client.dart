import "package:core_flutter/core_dart.dart";
import "package:core_flutter/states/state.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/location/location.dart";

@immutable
abstract class ClientState {}

class ClientInitial extends ClientState {}

class ClientLoading extends ClientState {}

class ClientSucceed extends ClientState {
  final Client client;
  final List<Location> locations;

  ClientSucceed({required this.client, required this.locations});
}

class ClientRefreshing extends ClientSucceed {
  ClientRefreshing({required super.client, required super.locations});
}

class ClientFailed extends ClientState implements FailedState {
  @override
  final CoreError error;
  ClientFailed(this.error);
}

class ClientNotifier extends StateNotifier<ClientState> with LoggerMixin {
  final String clientId;
  final ClientRepository remoteClients;
  final ClientRepository localClients;
  final LocationRepository remoteLocations;
  final LocationRepository localLocations;

  ClientNotifier(
    this.clientId, {
    required this.remoteClients,
    required this.localClients,
    required this.remoteLocations,
    required this.localLocations,
  }) : super(ClientInitial());

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<ClientSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! ClientRefreshing) state = ClientLoading();

      Client? client = reload ? null : await localClients.read(clientId);
      List<Location>? locations = reload ? null : await localLocations.readAll(clientId);

      if (client == null) {
        client = await remoteClients.read(clientId, ignoreCache: reload);
        if (client != null) await localClients.create(client);
      }

      if (locations == null) {
        locations = await remoteLocations.readAll(clientId, ignoreCache: reload);
        if (locations?.isNotEmpty ?? false) await localLocations.createAll(locations!);
      }

      state = (client != null && locations != null)
          ? ClientSucceed(client: client, locations: locations)
          : ClientFailed(errorFailedToLoadData);

      /*
      final res = await Future.wait([
        localClients.read(clientId),
        localLocations.readAll(clientId),
      ]);

      var client = res[0] as Client?;
      var locations = res[1] as List<Location>?;

      if (client == null || locations == null || reload) {
        client = await remoteClients.read(clientId, ignoreCache: reload);
        locations = await remoteLocations.readAll(clientId, noCache: reload);
        if (client != null) await localClients.create(client);
        if (locations?.isNotEmpty ?? false) await localLocations.createAll(locations!);
      }
      if (client != null) state = ClientSucceed(client: client, locations: locations ?? []);
      */
    } on CoreError catch (e) {
      error(e.toString());
      state = ClientFailed(e);
    } catch (e) {
      error(e.toString());
      state = ClientFailed(errorUnexpectedException(e));
    }
  }

  Future<void> load() => _load();

  Future<void> reload() => _load(reload: true);

  Future<void> refresh() async {
    if (state is! ClientSucceed) return;
    final program = cast<ClientSucceed>(state)!.client;
    final locations = cast<ClientSucceed>(state)!.locations;
    state = ClientRefreshing(client: program, locations: locations);
    await _load(reload: true);
  }
}

// eof
