import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/state.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/product_item_modification.dart";
import "../repositories/product_item_modification.dart";

@immutable
abstract class ProductItemModificationsState {}

class ProductItemModificationsInitial extends ProductItemModificationsState {}

class ProductItemModificationsLoading extends ProductItemModificationsState {}

class ProductItemModificationsSucceed extends ProductItemModificationsState {
  final List<ProductItemModification> productItemModifications;
  ProductItemModificationsSucceed({required this.productItemModifications});
}

class ProductItemModificationsRefreshing extends ProductItemModificationsSucceed {
  ProductItemModificationsRefreshing({required super.productItemModifications});
}

class ProductItemModificationsFailed extends ProductItemModificationsState implements FailedState {
  @override
  final CoreError error;
  @override
  ProductItemModificationsFailed(this.error);
}

class ProductItemModificationsNotifier extends StateNotifier<ProductItemModificationsState> with StateMixin {
  final String productItemId;
  final ProductItemModificationRepository productItemModificationRepository;

  ProductItemModificationsNotifier(
    this.productItemId, {
    required this.productItemModificationRepository,
  }) : super(ProductItemModificationsInitial());

  final String _refreshKey = uuid();

  String? hasRefreshKey(List<String> keys) => keys.contains(_refreshKey) ? _refreshKey : null;

  String reset() {
    state = ProductItemModificationsInitial();
    return _refreshKey;
  }

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<ProductItemModificationsSucceed>(state) != null)
      return debug(() => errorAlreadyLoaded.toString());
    try {
      if (state is! ProductItemModificationsRefreshing) state = ProductItemModificationsLoading();
      final productItemModifications = await productItemModificationRepository.readForItem(productItemId);
      state = ProductItemModificationsSucceed(productItemModifications: productItemModifications);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ProductItemModificationsFailed(err);
    } on Exception catch (ex) {
      state = ProductItemModificationsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = ProductItemModificationsFailed(errorFailedToLoadData);
    }
  }

  Future<void> reload() async {
    final succeed = cast<ProductItemModificationsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = ProductItemModificationsRefreshing(productItemModifications: succeed.productItemModifications);
    await load(reload: true);
  }

  Future<void> refresh({String? refreshKey}) async {
    if (refreshKey == _refreshKey) return load();
    final succeed = expect<ProductItemModificationsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = ProductItemModificationsRefreshing(productItemModifications: succeed.productItemModifications);
    await load(reload: true);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final succeed = expect<ProductItemModificationsSucceed>(state);
    if (succeed == null) return;
    try {
      final currentModifications = cast<ProductItemModificationsSucceed>(state)!.productItemModifications;
      final removedModification = currentModifications.removeAt(oldIndex);
      currentModifications.insert(newIndex, removedModification);
      final newModifications = currentModifications
          .map((modification) => modification.copyWith(rank: currentModifications.indexOf(modification)))
          .toList();
      final reordered = await productItemModificationRepository.reorder(newModifications);
      state = reordered
          ? ProductItemModificationsSucceed(productItemModifications: newModifications)
          : ProductItemModificationsFailed(errorFailedToSaveData);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ProductItemModificationsFailed(err);
    } catch (e) {
      warning(e.toString());
      state = ProductItemModificationsFailed(errorFailedToSaveData);
    }
  }
}

// eof
