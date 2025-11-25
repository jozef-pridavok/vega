import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/product_section.dart";
import "../repositories/product_section.dart";

@immutable
abstract class ProductSectionEditorState {}

extension ProductSectionEditorStateToActionButtonState on ProductSectionEditorState {
  static const stateMap = {
    ProductSectionEditorSaving: MoleculeActionButtonState.loading,
    ProductSectionEditorSucceed: MoleculeActionButtonState.success,
    ProductSectionEditorFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class ProductSectionEditorInitial extends ProductSectionEditorState {}

class ProductSectionEditorEditing extends ProductSectionEditorState {
  final ProductSection productSection;
  final bool isNew;
  ProductSectionEditorEditing({required this.productSection, this.isNew = false});
}

class ProductSectionEditorSaving extends ProductSectionEditorEditing {
  ProductSectionEditorSaving({required super.productSection, required super.isNew});
}

class ProductSectionEditorSucceed extends ProductSectionEditorEditing {
  ProductSectionEditorSucceed({required super.productSection});
}

class ProductSectionEditorFailed extends ProductSectionEditorSaving implements FailedState {
  @override
  final CoreError error;
  @override
  ProductSectionEditorFailed(this.error, {required super.productSection, required super.isNew});
}

class ProductSectionEditorNotifier extends StateNotifier<ProductSectionEditorState> with LoggerMixin {
  final ProductSectionRepository productSectionRepository;

  ProductSectionEditorNotifier({
    required this.productSectionRepository,
  }) : super(ProductSectionEditorInitial());

  Future<void> reset() async => state = ProductSectionEditorInitial();

  void edit(ProductSection productSection, {bool isNew = false}) async {
    state = ProductSectionEditorEditing(productSection: productSection, isNew: isNew);
  }

  Future<void> save({
    String? name,
    String? description,
  }) async {
    final currentState = cast<ProductSectionEditorEditing>(state);
    if (currentState == null) return debug(() => errorUnexpectedState.toString());
    final productSection = currentState.productSection.copyWith(name: name, description: description);
    state = ProductSectionEditorSaving(productSection: productSection, isNew: currentState.isNew);
    try {
      final ok = currentState.isNew
          ? await productSectionRepository.create(productSection)
          : await productSectionRepository.update(productSection);
      state = ok
          ? ProductSectionEditorSucceed(productSection: productSection)
          : ProductSectionEditorFailed(errorFailedToSaveData,
              productSection: productSection, isNew: currentState.isNew);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = ProductSectionEditorFailed(err, productSection: productSection, isNew: currentState.isNew);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = ProductSectionEditorFailed(errorFailedToSaveDataEx(ex: ex),
          productSection: productSection, isNew: currentState.isNew);
    } catch (e) {
      verbose(() => e.toString());
      state =
          ProductSectionEditorFailed(errorFailedToSaveData, productSection: productSection, isNew: currentState.isNew);
    }
  }

  Future<void> reedit() async {
    final currentState = cast<ProductSectionEditorFailed>(state);
    if (currentState == null) {
      debug(() => errorUnexpectedState.toString());
      return;
    }
    state = ProductSectionEditorEditing(
      productSection: currentState.productSection,
      isNew: currentState.isNew,
    );
  }
}

// eof
