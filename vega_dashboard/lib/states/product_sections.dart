import "package:core_flutter/core_dart.dart";
import "package:core_flutter/states/state.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/product_section.dart";
import "../repositories/product_section.dart";

@immutable
abstract class ProductSectionsState {}

class ProductSectionsInitial extends ProductSectionsState {}

class ProductSectionsLoading extends ProductSectionsState {}

class ProductSectionsSucceed extends ProductSectionsState {
  final List<ProductSection> productSections;
  ProductSectionsSucceed({required this.productSections});
}

class ProductSectionsRefreshing extends ProductSectionsSucceed {
  ProductSectionsRefreshing({required super.productSections});
}

class ProductSectionsFailed extends ProductSectionsState implements FailedState {
  @override
  final CoreError error;
  @override
  ProductSectionsFailed(this.error);
}

class ProductSectionsNotifier extends StateNotifier<ProductSectionsState> with LoggerMixin {
  final ProductSectionRepository productSectionRepository;

  ProductSectionsNotifier({
    required this.productSectionRepository,
  }) : super(ProductSectionsInitial());

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<ProductSectionsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    try {
      if (state is! ProductSectionsRefreshing) state = ProductSectionsLoading();
      final productSections = await productSectionRepository.readAll();
      state = ProductSectionsSucceed(productSections: productSections);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ProductSectionsFailed(err);
    } on Exception catch (ex) {
      state = ProductSectionsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = ProductSectionsFailed(errorFailedToLoadData);
    }
  }

  Future<void> refresh() async {
    final succeed = cast<ProductSectionsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = ProductSectionsRefreshing(productSections: succeed.productSections);
    await load(reload: true);
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    if (state is! ProductSectionsSucceed) return debug(() => errorUnexpectedState.toString());
    try {
      final currentProductSections = cast<ProductSectionsSucceed>(state)!.productSections;
      final removedProductItem = currentProductSections.removeAt(oldIndex);
      currentProductSections.insert(newIndex, removedProductItem);
      final newProductSections = currentProductSections
          .map((section) => section.copyWith(rank: currentProductSections.indexOf(section)))
          .toList();
      state = ProductSectionsRefreshing(productSections: newProductSections);
      // ignore: unused_local_variable
      final affected = await productSectionRepository.reorder(newProductSections);
      state = ProductSectionsSucceed(productSections: newProductSections);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ProductSectionsFailed(err);
    } catch (e) {
      warning(e.toString());
      state = ProductSectionsFailed(errorFailedToSaveData);
    }
  }
}

// eof
