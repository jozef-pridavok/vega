import "package:core_dart/core_dart.dart";
import "package:core_dart/core_repositories.dart";
import "package:core_flutter/core_widgets.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "state.dart";

@immutable
abstract class LoginState {}

extension LoginStateToActionButtonState on LoginState {
  static const stateMap = {
    LoginInitial: MoleculeActionButtonState.idle,
    LoginInProgress: MoleculeActionButtonState.loading,
    LoginFailed: MoleculeActionButtonState.fail,
    LoginSucceed: MoleculeActionButtonState.success,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class LoginInitial extends LoginState {}

class LoginInProgress extends LoginState {}

class LoginSucceed extends LoginState {
  final User user;
  LoginSucceed(this.user);
}

class LoginFailed extends LoginState {
  final CoreError error;
  LoginFailed(this.error);
}

class LoginNotifier extends StateNotifier<LoginState> with StateMixin {
  final DeviceRepository deviceRepository;
  final UserRepository userRepository;
  final ClientRepository clientRepository;

  LoginNotifier({
    required this.deviceRepository,
    required this.userRepository,
    required this.clientRepository,
  }) : super(LoginInitial());

  void reset() => state = LoginInitial();

  Future<void> login(String installationId, {String? email, String? login, required String password}) async {
    final initial = expect<LoginInitial>(state);
    if (initial == null) return;

    try {
      state = LoginInProgress();

      final authenticated = await userRepository.login(installationId, email, login, password);
      deviceRepository.put(DeviceKey.refreshToken, authenticated.refreshToken);
      deviceRepository.put(DeviceKey.accessToken, authenticated.accessToken);

      final user = await userRepository.read(authenticated.userId, ignoreCache: true);
      if (user == null) throw errorUserNotSignedIn;
      if (user.blocked) throw errorAccountBlocked;

      deviceRepository.put(DeviceKey.user, user);

      final userClientId = user.clientId;
      if (userClientId != null) {
        final client = await clientRepository.read(userClientId, ignoreCache: true);
        deviceRepository.put(DeviceKey.client, client);
      }

      state = LoginSucceed(user);
    } on CoreError catch (e) {
      state = LoginFailed(e);
    } on ApiResponse catch (res) {
      state = LoginFailed(CoreError(code: res.appCode, message: res.message ?? res.toString()));
    } catch (ex) {
      state = LoginFailed(errorUnexpectedException(ex));
    }
  }
}

// eof
