import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/leaflet.dart";

@immutable
abstract class LeafletsState {}

class LeafletsInitial extends LeafletsState {}

class LeafletsLoading extends LeafletsState {}

class LeafletsSucceed extends LeafletsState {
  final List<Leaflet> leaflets;
  LeafletsSucceed({required this.leaflets});
}

class LeafletsRefreshing extends LeafletsSucceed {
  LeafletsRefreshing({required super.leaflets});
}

class LeafletsFailed extends LeafletsState implements FailedState {
  @override
  final CoreError error;
  @override
  LeafletsFailed(this.error);
}

class LeafletsNotifier extends StateNotifier<LeafletsState> with StateMixin {
  final LeafletRepositoryFilter filter;
  final LeafletsRepository leafletRepository;

  LeafletsNotifier(
    this.filter, {
    required this.leafletRepository,
  }) : super(LeafletsInitial());

  final String _refreshKey = uuid();

  String? hasRefreshKey(List<String> keys) => keys.contains(_refreshKey) ? _refreshKey : null;

  String reset() {
    state = LeafletsInitial();
    return _refreshKey;
  }

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<LeafletsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    try {
      if (state is! LeafletsRefreshing) state = LeafletsLoading();
      final leaflets = await leafletRepository.readAll(filter: filter);
      state = LeafletsSucceed(leaflets: leaflets);
    } on CoreError catch (err) {
      warning(err.toString());
      state = LeafletsFailed(err);
    } on Exception catch (ex) {
      state = LeafletsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = LeafletsFailed(errorFailedToLoadData);
    }
  }

  Future<void> refresh({String? refreshKey}) async {
    if (refreshKey == _refreshKey) return load();
    final succeed = cast<LeafletsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = LeafletsRefreshing(leaflets: succeed.leaflets);
    await load(reload: true);
  }

  bool added(Leaflet leaflet) {
    return next(state, [LeafletsSucceed], () {
      final leaflets = cast<LeafletsSucceed>(state)!.leaflets;
      final index = leaflets.indexWhere((e) => e.leafletId == leaflet.leafletId);
      if (index != -1) return false;
      leaflets.insert(0, leaflet);
      state = LeafletsSucceed(leaflets: leaflets);
      return true;
    });
  }

  bool updated(Leaflet leaflet) {
    return next(state, [LeafletsSucceed], () {
      final leaflets = cast<LeafletsSucceed>(state)!.leaflets;
      final index = leaflets.indexWhere((e) => e.leafletId == leaflet.leafletId);
      if (index == -1) return false;
      leaflets.replaceRange(index, index + 1, [leaflet]);
      state = LeafletsSucceed(leaflets: leaflets);
      return true;
    });
  }

  bool removed(Leaflet leaflet) {
    return next(state, [LeafletsSucceed], () {
      final leaflets = cast<LeafletsSucceed>(state)!.leaflets;
      final index = leaflets.indexWhere((r) => r.leafletId == leaflet.leafletId);
      if (index == -1) return false;
      leaflets.removeAt(index);
      state = LeafletsSucceed(leaflets: leaflets);
      return true;
    });
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final succeed = expect<LeafletsSucceed>(state);
    if (succeed == null) return;
    try {
      final currentLeaflets = succeed.leaflets;
      final removedLeaflet = currentLeaflets.removeAt(oldIndex);
      currentLeaflets.insert(newIndex, removedLeaflet);
      final newLeaflets = currentLeaflets.map((card) => card.copyWith(rank: currentLeaflets.indexOf(card))).toList();
      final reordered = await leafletRepository.reorder(newLeaflets);
      state = reordered ? LeafletsSucceed(leaflets: newLeaflets) : LeafletsFailed(errorFailedToSaveData);
    } on CoreError catch (err) {
      warning(err.toString());
      state = LeafletsFailed(err);
    } catch (e) {
      warning(e.toString());
      state = LeafletsFailed(errorFailedToSaveData);
    }
  }
}

// eof
