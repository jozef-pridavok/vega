import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/product_item.dart";
import "../repositories/product_item.dart";

@immutable
abstract class ProductItemEditorState {}

extension ProductItemEditorStateToActionButtonState on ProductItemEditorState {
  static const stateMap = {
    ProductItemEditorSaving: MoleculeActionButtonState.loading,
    ProductItemEditorSucceed: MoleculeActionButtonState.success,
    ProductItemEditorFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class ProductItemEditorInitial extends ProductItemEditorState {}

class ProductItemEditorEditing extends ProductItemEditorState {
  final ProductItem productItem;
  final bool isNew;
  final List<int>? newImage;
  ProductItemEditorEditing({required this.productItem, this.isNew = false, this.newImage});
}

class ProductItemEditorSaving extends ProductItemEditorEditing {
  ProductItemEditorSaving({required super.productItem, required super.isNew, super.newImage});
}

class ProductItemEditorSucceed extends ProductItemEditorEditing {
  ProductItemEditorSucceed({required super.productItem, super.newImage});
}

class ProductItemEditorFailed extends ProductItemEditorSaving implements FailedState {
  @override
  final CoreError error;
  @override
  ProductItemEditorFailed(this.error, {required super.productItem, required super.isNew, super.newImage});
}

class ProductItemEditorNotifier extends StateNotifier<ProductItemEditorState> with LoggerMixin {
  final ProductItemRepository productItemRepository;

  ProductItemEditorNotifier({
    required this.productItemRepository,
  }) : super(ProductItemEditorInitial());

  Future<void> reset() async => state = ProductItemEditorInitial();

  void edit(ProductItem productItem, {bool isNew = false}) async {
    state = ProductItemEditorEditing(productItem: productItem, isNew: isNew);
  }

  Future<void> save({
    String? name,
    int? price,
    String? unit,
    String? description,
    List<int>? newImage,
  }) async {
    final currentState = cast<ProductItemEditorEditing>(state);
    if (currentState == null) return debug(() => errorUnexpectedState.toString());
    final productItem =
        currentState.productItem.copyWith(name: name, price: price, unit: unit, description: description);
    state = ProductItemEditorSaving(productItem: productItem, isNew: currentState.isNew);
    try {
      final ok = currentState.isNew
          ? await productItemRepository.create(productItem, image: newImage)
          : await productItemRepository.update(productItem, image: newImage);
      state = ok
          ? ProductItemEditorSucceed(productItem: productItem)
          : ProductItemEditorFailed(errorFailedToSaveData, productItem: productItem, isNew: currentState.isNew);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = ProductItemEditorFailed(err, productItem: productItem, isNew: currentState.isNew);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state =
          ProductItemEditorFailed(errorFailedToSaveDataEx(ex: ex), productItem: productItem, isNew: currentState.isNew);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductItemEditorFailed(errorFailedToSaveData, productItem: productItem, isNew: currentState.isNew);
    }
  }

  Future<void> reedit() async {
    final currentState = cast<ProductItemEditorFailed>(state);
    if (currentState == null) {
      debug(() => errorUnexpectedState.toString());
      return;
    }
    state = ProductItemEditorEditing(
      productItem: currentState.productItem,
      isNew: currentState.isNew,
    );
  }
}

// eof
