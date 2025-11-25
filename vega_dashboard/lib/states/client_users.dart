import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/client_users.dart";

@immutable
abstract class ClientUsersState {}

class ClientUsersInitial extends ClientUsersState {}

class ClientUsersLoading extends ClientUsersState {}

class SellerClientsSucceed extends ClientUsersState {
  final List<User> users;
  SellerClientsSucceed({required this.users});
}

class ClientUsersRefreshing extends SellerClientsSucceed {
  ClientUsersRefreshing({required super.users});
}

class ClientUsersFailed extends ClientUsersState implements FailedState {
  @override
  final CoreError error;
  @override
  ClientUsersFailed(this.error);
}

class UserEditorEditing extends ClientUsersState {
  final User user;
  final bool isNew;
  UserEditorEditing({required this.user, this.isNew = false});
}

class ClientUsersNotifier extends StateNotifier<ClientUsersState> with LoggerMixin {
  final String clientId;
  final ClientUserRepository clientUsersRepository;

  ClientUsersNotifier(
    this.clientId, {
    required this.clientUsersRepository,
  }) : super(ClientUsersInitial());

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<SellerClientsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());

    try {
      if (state is! ClientUsersRefreshing) state = ClientUsersLoading();
      final users = await clientUsersRepository.readAll(clientId);
      state = SellerClientsSucceed(users: users);
    } on CoreError catch (err) {
      warning(err.toString());
      state = ClientUsersFailed(err);
    } on Exception catch (ex) {
      state = ClientUsersFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = ClientUsersFailed(errorFailedToLoadData);
    }
  }

  Future<void> reload() async {
    final succeed = cast<SellerClientsSucceed>(state);
    if (succeed == null) return load(reload: true);
    state = ClientUsersRefreshing(users: succeed.users);
    await load(reload: true);
  }
}

// eof
