import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../data_models/client.dart";
import "../repositories/client.dart" as dashboard;

@immutable
abstract class ClientSettingsState {}

extension ClientSettingsStateToActionButtonState on ClientSettingsState {
  static const stateMap = {
    ClientSettingsSaving: MoleculeActionButtonState.loading,
    ClientSettingsSaved: MoleculeActionButtonState.success,
    ClientSettingsSavingFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class ClientSettingsInitial extends ClientSettingsState {}

class ClientSettingsLoading extends ClientSettingsState {}

class ClientSettingsLoaded extends ClientSettingsState {
  final Client client;
  ClientSettingsLoaded(this.client);
}

class ClientSettingsLoadFailed extends ClientSettingsState implements FailedState {
  @override
  final CoreError error;

  ClientSettingsLoadFailed(this.error);
}

class ClientSettingsRefreshing extends ClientSettingsState {
  ClientSettingsRefreshing();
}

class ClientSettingsEditing extends ClientSettingsState {
  final Client client;
  ClientSettingsEditing(this.client);
}

class ClientSettingsSaving extends ClientSettingsState {
  final Client client;
  ClientSettingsSaving(this.client);
}

class ClientSettingsSaved extends ClientSettingsState {
  final Client client;
  ClientSettingsSaved(this.client);
}

class ClientSettingsSavingFailed extends ClientSettingsState implements FailedState {
  final Client client;
  @override
  final CoreError error;

  ClientSettingsSavingFailed(this.error, this.client);
}

class ClientSettingsFailed extends ClientSettingsState implements FailedState {
  final Client? client;
  @override
  final CoreError error;

  ClientSettingsFailed(this.error, this.client);
}

class ClientSettingsNotifier extends StateNotifier<ClientSettingsState> with StateMixin {
  final dashboard.ClientRepository clientRepository;

  ClientSettingsNotifier({
    required this.clientRepository,
  }) : super(ClientSettingsInitial());

  void reset() => state = ClientSettingsInitial();

  Future<void> load({bool reload = false}) async {
    final loaded = cast<ClientSettingsLoaded>(state);
    final editing = cast<ClientSettingsEditing>(state);
    if (!reload && (loaded != null || editing != null)) return debug(() => errorAlreadyLoaded.toString());
    try {
      if (state is! ClientSettingsRefreshing) state = ClientSettingsLoading();
      //await Future.delayed(const Duration(seconds: 3));
      final client = await clientRepository.detail();
      if (client == null) {
        state = ClientSettingsLoadFailed(errorFailedToLoadData);
        return;
      }
      state = ClientSettingsLoaded(client);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ClientSettingsLoadFailed(err);
    } on Exception catch (ex) {
      state = ClientSettingsLoadFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = ClientSettingsLoadFailed(errorFailedToLoadData);
    }
  }

  void edit() {
    final saved = cast<ClientSettingsSaved>(state);
    final loaded = cast<ClientSettingsLoaded>(state);
    if (saved == null && loaded == null) return;
    final client = saved?.client ?? loaded?.client;
    state = ClientSettingsEditing(client!);
  }

  Future<void> refresh() async {
    final loaded = cast<ClientSettingsLoaded>(state);
    final editing = cast<ClientSettingsEditing>(state);
    if (loaded == null && editing == null) return load();
    state = ClientSettingsRefreshing();
    await load(reload: true);
  }

  Future<void> save({
    String? name,
    String? description,
    Color? color,
    List<int>? newImage,
    Map<String, String> localizedDescription = const {},
    String? phone,
    String? email,
    String? web,
    String? invoicingName,
    String? invoicingCompanyNumber,
    String? invoicingCompanyVat,
    String? invoicingAddress1,
    String? invoicingAddress2,
    String? invoicingZip,
    String? invoicingCity,
    String? invoicingCountry,
    String? invoicingPhone,
    String? invoicingEmail,
    int? deliveryPriceCourier,
    int? deliveryPricePickup,
  }) async {
    final currentState = cast<ClientSettingsEditing>(state);
    if (currentState == null) return;

    final client = currentState.client.copyWith(
      name: name ?? currentState.client.name,
      description: description ?? currentState.client.description,
      color: color ?? currentState.client.color,
    );
    if (localizedDescription.isNotEmpty) {
      for (final lang in localizedDescription.keys) {
        client.setDescription(lang, localizedDescription[lang]!);
      }
    }
    if (phone != null) client.phone = phone;
    if (email != null) client.email = email;
    if (web != null) client.web = web;
    client.setInvoicing(
      name: invoicingName,
      companyNumber: invoicingCompanyNumber,
      companyVat: invoicingCompanyVat,
      address1: invoicingAddress1,
      address2: invoicingAddress2,
      zip: invoicingZip,
      city: invoicingCity,
      country: invoicingCountry,
      phone: invoicingPhone,
      email: invoicingEmail,
    );
    client.setDeliveryPrice(courierPrice: deliveryPriceCourier, pickupPrice: deliveryPricePickup);

    state = ClientSettingsSaving(client);
    try {
      final ok = await clientRepository.update(client, image: newImage);
      state = ok ? ClientSettingsSaved(client) : ClientSettingsFailed(errorFailedToSaveData, client);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = ClientSettingsSavingFailed(err, client);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = ClientSettingsSavingFailed(errorFailedToSaveDataEx(ex: ex), client);
    } catch (e) {
      verbose(() => e.toString());
      state = ClientSettingsSavingFailed(errorFailedToSaveData, client);
    }
  }

  recoverFromSaveFailed() {
    final saveFailed = cast<ClientSettingsSavingFailed>(state);
    if (saveFailed == null) return;
    state = ClientSettingsEditing(saveFailed.client);
    return true;
  }
}

// eof
