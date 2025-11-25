import "package:core_flutter/core_dart.dart";
import "package:core_flutter/states/state.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/product_item_option.dart";

@immutable
abstract class ProductItemOptionsState {}

class ProductItemOptionsInitial extends ProductItemOptionsState {}

class ProductItemOptionsLoading extends ProductItemOptionsState {}

class ProductItemOptionsSucceed extends ProductItemOptionsState {
  final List<ProductItemOption> productItemOptions;
  ProductItemOptionsSucceed({required this.productItemOptions});
}

class ProductItemOptionsRefreshing extends ProductItemOptionsSucceed {
  ProductItemOptionsRefreshing({required super.productItemOptions});
}

class ProductItemOptionsFailed extends ProductItemOptionsState implements FailedState {
  @override
  final CoreError error;
  @override
  ProductItemOptionsFailed(this.error);
}

class ProductItemOptionsNotifier extends StateNotifier<ProductItemOptionsState> with LoggerMixin {
  final String productItemId;
  final ProductItemOptionRepository productItemOptionRepository;

  ProductItemOptionsNotifier(
    this.productItemId, {
    required this.productItemOptionRepository,
  }) : super(ProductItemOptionsInitial());

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<ProductItemOptionsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    try {
      if (state is! ProductItemOptionsRefreshing) state = ProductItemOptionsLoading();
      final productItemOptions = await productItemOptionRepository.readForItem(productItemId);
      state = ProductItemOptionsSucceed(productItemOptions: productItemOptions);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ProductItemOptionsFailed(err);
    } on Exception catch (ex) {
      state = ProductItemOptionsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = ProductItemOptionsFailed(errorFailedToLoadData);
    }
  }

  Future<void> reload() async {
    final succeed = cast<ProductItemOptionsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = ProductItemOptionsRefreshing(productItemOptions: succeed.productItemOptions);
    await load(reload: true);
  }
}

// eof
