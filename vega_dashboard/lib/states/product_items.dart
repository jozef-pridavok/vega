import "package:core_flutter/core_dart.dart";
import "package:core_flutter/states/state.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/product_item.dart";
import "../repositories/product_item.dart";

@immutable
abstract class ProductItemsState {}

class ProductItemsInitial extends ProductItemsState {}

class ProductItemsLoading extends ProductItemsState {}

class ProductItemsSucceed extends ProductItemsState {
  final List<ProductItem> productItems;
  ProductItemsSucceed({required this.productItems});
}

class ProductItemsRefreshing extends ProductItemsSucceed {
  ProductItemsRefreshing({required super.productItems});
}

class ProductItemsFailed extends ProductItemsState implements FailedState {
  @override
  final CoreError error;
  @override
  ProductItemsFailed(this.error);
}

class ProductItemsNotifier extends StateNotifier<ProductItemsState> with StateMixin {
  final ProductItemRepository productItemRepository;

  ProductItemsNotifier({
    required this.productItemRepository,
  }) : super(ProductItemsInitial());

  final String _refreshKey = uuid();

  String? hasRefreshKey(List<String> keys) => keys.contains(_refreshKey) ? _refreshKey : null;

  String reset() {
    state = ProductItemsInitial();
    return _refreshKey;
  }

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<ProductItemsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    try {
      if (state is! ProductItemsRefreshing) state = ProductItemsLoading();
      final productItems = await productItemRepository.readAll();
      state = ProductItemsSucceed(productItems: productItems);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ProductItemsFailed(err);
    } on Exception catch (ex) {
      state = ProductItemsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = ProductItemsFailed(errorFailedToLoadData);
    }
  }

  Future<void> refresh({String? refreshKey}) async {
    if (refreshKey == _refreshKey) return load();
    final succeed = cast<ProductItemsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = ProductItemsRefreshing(productItems: succeed.productItems);
    await load(reload: true);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final succeed = expect<ProductItemsSucceed>(state);
    if (succeed == null) return;
    try {
      final currentItems = cast<ProductItemsSucceed>(state)!.productItems;
      final removedItem = currentItems.removeAt(oldIndex);
      currentItems.insert(newIndex, removedItem);
      final newItems = currentItems.map((it) => it.copyWith(rank: currentItems.indexOf(it))).toList();
      final reordered = await productItemRepository.reorder(newItems);
      state = reordered ? ProductItemsSucceed(productItems: newItems) : ProductItemsFailed(errorFailedToSaveData);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ProductItemsFailed(err);
    } catch (e) {
      warning(e.toString());
      state = ProductItemsFailed(errorFailedToSaveData);
    }
  }
}

// eof
