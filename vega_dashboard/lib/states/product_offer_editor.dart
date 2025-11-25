import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/product_offer.dart";
import "../repositories/product_offer.dart";

@immutable
abstract class ProductOfferEditorState {}

extension ProductOfferEditorStateToActionButtonState on ProductOfferEditorState {
  static const stateMap = {
    ProductOfferEditorSaving: MoleculeActionButtonState.loading,
    ProductOfferEditorSucceed: MoleculeActionButtonState.success,
    ProductOfferEditorFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class ProductOfferEditorInitial extends ProductOfferEditorState {}

class ProductOfferEditorEditing extends ProductOfferEditorState {
  final ProductOffer productOffer;
  final bool isNew;
  ProductOfferEditorEditing({required this.productOffer, this.isNew = false});
}

class ProductOfferEditorSaving extends ProductOfferEditorEditing {
  ProductOfferEditorSaving({required super.productOffer, required super.isNew});
}

class ProductOfferEditorSucceed extends ProductOfferEditorEditing {
  ProductOfferEditorSucceed({required super.productOffer});
}

class ProductOfferEditorFailed extends ProductOfferEditorSaving implements FailedState {
  @override
  final CoreError error;
  @override
  ProductOfferEditorFailed(this.error, {required super.productOffer, required super.isNew});
}

class ProductOfferEditorNotifier extends StateNotifier<ProductOfferEditorState> with LoggerMixin {
  final ProductOfferRepository productOfferRepository;

  ProductOfferEditorNotifier({
    required this.productOfferRepository,
  }) : super(ProductOfferEditorInitial());

  Future<void> reset() async => state = ProductOfferEditorInitial();

  void edit(ProductOffer productOffer, {bool isNew = false}) async {
    state = ProductOfferEditorEditing(productOffer: productOffer, isNew: isNew);
  }

  Future<void> save({
    String? name,
    ProductOfferType? type,
    IntDate? date,
    String? description,
    LoyaltyMode? loyaltyMode,
    String? locationId,
  }) async {
    final currentState = cast<ProductOfferEditorEditing>(state);
    if (currentState == null) return debug(() => errorUnexpectedState.toString());
    final productOffer = currentState.productOffer.copyWith(
        name: name, type: type, date: date, description: description, loyaltyMode: loyaltyMode, locationId: locationId);
    state = ProductOfferEditorSaving(productOffer: productOffer, isNew: currentState.isNew);
    try {
      final ok = currentState.isNew
          ? await productOfferRepository.create(productOffer)
          : await productOfferRepository.update(productOffer);
      state = ok
          ? ProductOfferEditorSucceed(productOffer: productOffer)
          : ProductOfferEditorFailed(errorFailedToSaveData, productOffer: productOffer, isNew: currentState.isNew);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = ProductOfferEditorFailed(err, productOffer: productOffer, isNew: currentState.isNew);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = ProductOfferEditorFailed(errorFailedToSaveDataEx(ex: ex),
          productOffer: productOffer, isNew: currentState.isNew);
    } catch (e) {
      verbose(() => e.toString());
      state = ProductOfferEditorFailed(errorFailedToSaveData, productOffer: productOffer, isNew: currentState.isNew);
    }
  }

  Future<void> reedit() async {
    final currentState = cast<ProductOfferEditorFailed>(state);
    if (currentState == null) {
      debug(() => errorUnexpectedState.toString());
      return;
    }
    state = ProductOfferEditorEditing(
      productOffer: currentState.productOffer,
      isNew: currentState.isNew,
    );
  }
}

// eof
