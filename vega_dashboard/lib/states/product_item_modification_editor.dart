import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/product_item_modification.dart";
import "../repositories/product_item_modification.dart";

@immutable
abstract class ProductItemModificationEditorState {}

extension ProductItemModificationEditorStateToActionButtonState on ProductItemModificationEditorState {
  static const stateMap = {
    ProductItemModificationEditorSaving: MoleculeActionButtonState.loading,
    ProductItemModificationEditorSucceed: MoleculeActionButtonState.success,
    ProductItemModificationEditorFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class ProductItemModificationEditorInitial extends ProductItemModificationEditorState {}

class ProductItemModificationEditorEditing extends ProductItemModificationEditorState {
  final ProductItem item;
  final ProductItemModification modification;
  final bool isNew;
  ProductItemModificationEditorEditing({required this.item, required this.modification, this.isNew = false});
}

class ProductItemModificationEditorSaving extends ProductItemModificationEditorEditing {
  ProductItemModificationEditorSaving({required super.item, required super.modification, required super.isNew});
}

class ProductItemModificationEditorSucceed extends ProductItemModificationEditorEditing {
  ProductItemModificationEditorSucceed({required super.item, required super.modification});
}

class ProductItemModificationEditorFailed extends ProductItemModificationEditorSaving implements FailedState {
  @override
  final CoreError error;
  @override
  ProductItemModificationEditorFailed(this.error,
      {required super.item, required super.modification, required super.isNew});
}

class ProductItemModificationEditorNotifier extends StateNotifier<ProductItemModificationEditorState> with LoggerMixin {
  final ProductItemModificationRepository modificationRepository;

  ProductItemModificationEditorNotifier({
    required this.modificationRepository,
  }) : super(ProductItemModificationEditorInitial());

  Future<void> reset() async => state = ProductItemModificationEditorInitial();

  void edit(ProductItem item, ProductItemModification modification, {bool isNew = false}) async {
    state = ProductItemModificationEditorEditing(item: item, modification: modification, isNew: isNew);
  }

  Future<void> save({
    String? name,
    ProductItemModificationType? type,
    bool? mandatory,
    int? max,
  }) async {
    final currentState = cast<ProductItemModificationEditorEditing>(state);
    if (currentState == null) return debug(() => errorUnexpectedState.toString());
    final item = currentState.item;
    final modification = currentState.modification.copyWith(name: name, type: type, mandatory: mandatory, max: max);
    state = ProductItemModificationEditorSaving(item: item, modification: modification, isNew: currentState.isNew);
    try {
      final ok = currentState.isNew
          ? await modificationRepository.create(modification)
          : await modificationRepository.update(modification);
      state = ok
          ? ProductItemModificationEditorSucceed(item: item, modification: modification)
          : ProductItemModificationEditorFailed(errorFailedToSaveData,
              item: item, modification: modification, isNew: currentState.isNew);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state =
          ProductItemModificationEditorFailed(err, item: item, modification: modification, isNew: currentState.isNew);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = ProductItemModificationEditorFailed(errorFailedToSaveDataEx(ex: ex),
          item: item, modification: modification, isNew: currentState.isNew);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductItemModificationEditorFailed(errorFailedToSaveData,
          item: item, modification: modification, isNew: currentState.isNew);
    }
  }

  Future<void> reedit() async {
    final currentState = cast<ProductItemModificationEditorFailed>(state);
    if (currentState == null) {
      debug(() => errorUnexpectedState.toString());
      return;
    }
    state = ProductItemModificationEditorEditing(
      item: currentState.item,
      modification: currentState.modification,
      isNew: currentState.isNew,
    );
  }
}

// eof
