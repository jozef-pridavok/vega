import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../../repositories/leaflet/leaflet_detail.dart";

@immutable
abstract class LeafletDetailState {}

class LeafletDetailInitial extends LeafletDetailState {}

class LeafletDetailLoading extends LeafletDetailState {}

class LeafletDetailSucceed extends LeafletDetailState {
  final List<LeafletDetail> leaflets;
  LeafletDetailSucceed({required this.leaflets});
}

class LeafletDetailRefreshing extends LeafletDetailSucceed {
  LeafletDetailRefreshing({required super.leaflets});
}

class LeafletDetailFailed extends LeafletDetailState implements FailedState {
  @override
  final CoreError error;
  @override
  LeafletDetailFailed(this.error);
}

class LeafletDetailNotifier extends StateNotifier<LeafletDetailState> with LoggerMixin {
  final String clientId;
  final LeafletDetailRepository remoteRepository;
  final LeafletDetailRepository localRepository;

  LeafletDetailNotifier(
    this.clientId, {
    required this.localRepository,
    required this.remoteRepository,
  }) : super(LeafletDetailInitial());

  Future<void> _load({bool reload = false}) async {
    if (!reload && cast<LeafletDetailSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! LeafletDetailRefreshing) state = LeafletDetailLoading();

      var leaflets = await localRepository.readAll(clientId);
      if ((leaflets?.isEmpty ?? true) || reload) {
        leaflets = await remoteRepository.readAll(clientId, noCache: reload);
        if (leaflets != null) await localRepository.createAll(leaflets);
      }
      state = LeafletDetailSucceed(leaflets: leaflets ?? []);
    } on CoreError catch (e) {
      error(e.toString());
      state = LeafletDetailFailed(e);
    } catch (e) {
      error(e.toString());
      state = LeafletDetailFailed(errorUnexpectedException(e));
    }
  }

  Future<void> load() => _load();

  Future<void> reload() => _load(reload: true);

  Future<void> refresh() async {
    if (state is! LeafletDetailSucceed) return;
    final leaflets = cast<LeafletDetailSucceed>(state)!.leaflets;
    state = LeafletDetailRefreshing(leaflets: leaflets);
    await _load(reload: true);
  }
}

// eof
