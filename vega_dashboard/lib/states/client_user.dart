import "package:core_flutter/core_dart.dart" hide UserRepository;
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/client_users.dart";
import "../repositories/user.dart";

@immutable
abstract class ClientUserState {}

extension ClientUserEditorStateToActionButtonState on ClientUserState {
  static const stateMap = {
    ClientUserSaving: MoleculeActionButtonState.loading,
    ClientUserSavedSuccess: MoleculeActionButtonState.success,
    ClientUserSavingFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class ClientUserInitial extends ClientUserState {}

class ClientUserLoading extends ClientUserState {}

class ClientUserSucceed extends ClientUserState {
  final User user;
  ClientUserSucceed({required this.user});
}

class ClientUserRefreshing extends ClientUserSucceed {
  ClientUserRefreshing({required super.user});
}

class ClientUserFailed extends ClientUserState implements FailedState {
  @override
  final CoreError error;
  @override
  ClientUserFailed(this.error);
}

class ClientUserSaving extends ClientUserSucceed {
  ClientUserSaving({required super.user});
}

class ClientUserSavedSuccess extends ClientUserSaving {
  ClientUserSavedSuccess({required super.user});
}

class ClientUserSavingFailed extends ClientUserSaving implements FailedState {
  @override
  final CoreError error;
  @override
  ClientUserSavingFailed(this.error, {required super.user});
}

class ClientUserNotifier extends StateNotifier<ClientUserState> with LoggerMixin {
  final String userId;
  final UserRepository userRepository;
  final ClientUserRepository clientUsersRepository;

  ClientUserNotifier(
    this.userId, {
    required this.userRepository,
    required this.clientUsersRepository,
  }) : super(ClientUserInitial());

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<ClientUserSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! ClientUserRefreshing) state = ClientUserLoading();
      final user = await userRepository.read(userId);
      if (user == null) {
        state = ClientUserFailed(errorFailedToLoadData);
        return;
      }
      state = ClientUserSucceed(user: user);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ClientUserFailed(err);
    } on Exception catch (ex) {
      state = ClientUserFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = ClientUserFailed(errorFailedToLoadData);
    }
  }

  Future<void> reload() async {
    final succeed = cast<ClientUserSucceed>(state);
    if (succeed == null) return await load(reload: true);
    state = ClientUserRefreshing(user: succeed.user);
    await load(reload: true);
  }

  Future<void> save(
    User user,
    String clientId, {
    required String displayName,
    String? id1,
    String? id2,
    String? id3,
    String? name,
    String? firstName,
    String? secondName,
    String? thirdName,
    String? lastName,
    String? addressLine1,
    String? addressLine2,
    String? zip,
    String? city,
    String? userState,
    String? country,
    String? email,
    String? phone,
    String? notes,
  }) async {
    try {
      final userClientData = UserClientMetaData(
        displayName: displayName,
        id1: id1,
        id2: id2,
        id3: id3,
        name: name,
        firstName: firstName,
        secondName: secondName,
        thirdName: thirdName,
        lastName: lastName,
        addressLine1: addressLine1,
        addressLine2: addressLine2,
        zip: zip,
        city: city,
        state: userState,
        country: country,
        email: email,
        phone: phone,
        notes: notes,
      );
      user.setClientData(clientId, userClientData);
      state = ClientUserSaving(user: user);
      final saved = await clientUsersRepository.updateMeta(user);
      state = saved ? ClientUserSavedSuccess(user: user) : ClientUserSavingFailed(errorFailedToSaveData, user: user);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ClientUserSavingFailed(err, user: user);
    } catch (e) {
      verbose(() => e.toString());
      state = ClientUserSavingFailed(errorFailedToSaveData, user: user);
    }
  }
}

// eof
