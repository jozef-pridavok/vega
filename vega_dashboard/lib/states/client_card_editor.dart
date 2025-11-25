import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/data_model.dart";
import "../repositories/client_card.dart";

@immutable
abstract class ClientCardEditorState {}

extension ClientCardEditorStateToActionButtonState on ClientCardEditorState {
  static const stateMap = {
    ClientCardEditorSaving: MoleculeActionButtonState.loading,
    ClientCardEditorSucceed: MoleculeActionButtonState.success,
    ClientCardEditorFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class ClientCardEditorInitial extends ClientCardEditorState {}

class ClientCardEditorEditing extends ClientCardEditorState {
  final Card card;
  final bool isNew;
  ClientCardEditorEditing(this.card, {this.isNew = false});
}

class ClientCardEditorSaving extends ClientCardEditorEditing {
  ClientCardEditorSaving(super.card, {super.isNew});
}

class ClientCardEditorSucceed extends ClientCardEditorSaving {
  ClientCardEditorSucceed(super.card) : super(isNew: false);
}

class ClientCardEditorFailed extends ClientCardEditorSaving implements FailedState {
  @override
  final CoreError error;
  @override
  ClientCardEditorFailed(this.error, super.card, {required super.isNew});
}

class ClientCardEditorNotifier extends StateNotifier<ClientCardEditorState> with StateMixin {
  final DeviceRepository deviceRepository;
  final ClientCardRepository cardRepository;

  ClientCardEditorNotifier({
    required this.deviceRepository,
    required this.cardRepository,
  }) : super(ClientCardEditorInitial());

  void reset() => state = ClientCardEditorInitial();

  void create() {
    final client = deviceRepository.get(DeviceKey.client) as Client;
    final card = DataModel.createCard(client);
    state = ClientCardEditorEditing(card, isNew: true);
  }

  void edit(Card card) => state = ClientCardEditorEditing(card, isNew: false);

  Future<void> save({String? name, Color? color, List<Country>? countries, List<int>? newImage}) async {
    final editing = expect<ClientCardEditorEditing>(state);
    if (editing == null) return;
    final card = editing.card.copyWith(name: name, color: color, countries: countries);
    state = ClientCardEditorSaving(card, isNew: editing.isNew);
    try {
      final ok = editing.isNew
          ? await cardRepository.create(card, image: newImage)
          : await cardRepository.update(card, image: newImage);
      state = ok
          ? ClientCardEditorSucceed(card)
          : ClientCardEditorFailed(errorFailedToSaveData, card, isNew: editing.isNew);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = ClientCardEditorFailed(err, card, isNew: editing.isNew);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = ClientCardEditorFailed(errorFailedToSaveDataEx(ex: ex), card, isNew: editing.isNew);
    } catch (e) {
      verbose(() => e.toString());
      state = ClientCardEditorFailed(errorFailedToSaveData, card, isNew: editing.isNew);
    }
  }

  Future<void> reedit() async {
    final editing = cast<ClientCardEditorEditing>(state);
    if (editing == null) return;
    state = ClientCardEditorEditing(editing.card, isNew: editing.isNew);
  }
}

// eof
