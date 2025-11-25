import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/product_item_option.dart";
import "../repositories/product_item_option.dart";

@immutable
abstract class ProductItemOptionEditorState {}

extension ProductItemOptionEditorStateToActionButtonState on ProductItemOptionEditorState {
  static const stateMap = {
    ProductItemOptionEditorSaving: MoleculeActionButtonState.loading,
    ProductItemOptionEditorSucceed: MoleculeActionButtonState.success,
    ProductItemOptionEditorFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class ProductItemOptionEditorInitial extends ProductItemOptionEditorState {}

class ProductItemOptionEditorEditing extends ProductItemOptionEditorState {
  final ProductItemOption productItemOption;
  final bool isNew;
  ProductItemOptionEditorEditing({required this.productItemOption, this.isNew = false});
}

class ProductItemOptionEditorSaving extends ProductItemOptionEditorEditing {
  ProductItemOptionEditorSaving({required super.productItemOption, required super.isNew});
}

class ProductItemOptionEditorSucceed extends ProductItemOptionEditorEditing {
  ProductItemOptionEditorSucceed({required super.productItemOption});
}

class ProductItemOptionEditorFailed extends ProductItemOptionEditorSaving implements FailedState {
  @override
  final CoreError error;
  @override
  ProductItemOptionEditorFailed(this.error, {required super.productItemOption, required super.isNew});
}

class ProductItemOptionEditorNotifier extends StateNotifier<ProductItemOptionEditorState> with LoggerMixin {
  final ProductItemOptionRepository productItemOptionRepository;

  ProductItemOptionEditorNotifier({
    required this.productItemOptionRepository,
  }) : super(ProductItemOptionEditorInitial());

  Future<void> reset() async => state = ProductItemOptionEditorInitial();

  void edit(ProductItemOption productItemOption, {bool isNew = false}) async {
    state = ProductItemOptionEditorEditing(productItemOption: productItemOption, isNew: isNew);
  }

  Future<void> save({
    String? name,
    ProductItemOptionPricing? pricing,
    int? price,
    String? unit,
  }) async {
    final currentState = cast<ProductItemOptionEditorEditing>(state);
    if (currentState == null) return debug(() => errorUnexpectedState.toString());
    final productItemOption =
        currentState.productItemOption.copyWith(name: name, pricing: pricing, price: price, unit: unit);
    state = ProductItemOptionEditorSaving(productItemOption: productItemOption, isNew: currentState.isNew);
    try {
      final ok = currentState.isNew
          ? await productItemOptionRepository.create(productItemOption)
          : await productItemOptionRepository.update(productItemOption);
      state = ok
          ? ProductItemOptionEditorSucceed(productItemOption: productItemOption)
          : ProductItemOptionEditorFailed(errorFailedToSaveData,
              productItemOption: productItemOption, isNew: currentState.isNew);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = ProductItemOptionEditorFailed(err, productItemOption: productItemOption, isNew: currentState.isNew);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = ProductItemOptionEditorFailed(errorFailedToSaveDataEx(ex: ex),
          productItemOption: productItemOption, isNew: currentState.isNew);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductItemOptionEditorFailed(errorFailedToSaveData,
          productItemOption: productItemOption, isNew: currentState.isNew);
    }
  }

  Future<void> reedit() async {
    final currentState = cast<ProductItemOptionEditorFailed>(state);
    if (currentState == null) {
      debug(() => errorUnexpectedState.toString());
      return;
    }
    state = ProductItemOptionEditorEditing(
      productItemOption: currentState.productItemOption,
      isNew: currentState.isNew,
    );
  }
}

// eof
