import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../enums/seller_template.dart";
import "../repositories/seller_client.dart";
import "../repositories/seller_template.dart";

@immutable
abstract class SellerClientEditorState {}

extension SellerClientEditorStateToActionButtonState on SellerClientEditorState {
  static const stateMap = {
    SellerClientEditorSaving: MoleculeActionButtonState.loading,
    SellerClientEditorSaved: MoleculeActionButtonState.success,
    SellerClientEditorFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class SellerClientEditorInitial extends SellerClientEditorState {}

class SellerClientEditorSaving extends SellerClientEditorState {
  final Client client;
  final bool isNew;
  SellerClientEditorSaving(this.client, {this.isNew = false});
}

class SellerClientEditorSaved extends SellerClientEditorSaving {
  SellerClientEditorSaved(super.client, {super.isNew = false});
}

class SellerClientEditorFailed extends SellerClientEditorState implements FailedState {
  @override
  final CoreError error;
  @override
  SellerClientEditorFailed(this.error);
}

class SellerClientEditorNotifier extends StateNotifier<SellerClientEditorState> with LoggerMixin {
  final SellerClientRepository sellerClientRepository;
  final SellerTemplateRepository sellerTemplateRepository;

  SellerClientEditorNotifier({
    required this.sellerClientRepository,
    required this.sellerTemplateRepository,
  }) : super(SellerClientEditorInitial());

  Future<void> reset() async => state = SellerClientEditorInitial();

  Future<void> create(Client client, {List<int>? logoImage, SellerTemplate? template}) async {
    try {
      state = SellerClientEditorSaving(client);
      client.clientId = uuid();
      var created = await sellerClientRepository.create(client, images: logoImage);
      if (!created) {
        state = SellerClientEditorFailed(errorFailedToSaveData);
        return;
      }
      if (template != null) {
        created = await sellerTemplateRepository.create(client, template);
      }
      state = created ? SellerClientEditorSaved(client) : SellerClientEditorFailed(errorFailedToSaveData);
    } on CoreError catch (err) {
      warning(err.toString());
      state = SellerClientEditorFailed(err);
    } catch (e) {
      verbose(() => e.toString());
      state = SellerClientEditorFailed(errorFailedToSaveData);
    }
  }

  Future<void> save(Client client, {List<int>? logoImage}) async {
    try {
      state = SellerClientEditorSaving(client);
      final saved = await sellerClientRepository.update(client, images: logoImage);
      state = saved ? SellerClientEditorSaved(client) : SellerClientEditorFailed(errorFailedToSaveData);
    } on CoreError catch (err) {
      warning(err.toString());
      state = SellerClientEditorFailed(err);
    } catch (e) {
      verbose(() => e.toString());
      state = SellerClientEditorFailed(errorFailedToSaveData);
    }
  }
}

// eof
