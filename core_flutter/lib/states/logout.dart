import "package:core_dart/core_dart.dart";
import "package:core_dart/core_repositories.dart";
import "package:core_flutter/core_widgets.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

@immutable
abstract class LogoutState {}

extension LogoutStateToActionButtonState on LogoutState {
  static const stateMap = {
    LogoutInitial: MoleculeActionButtonState.idle,
    LogoutInProgress: MoleculeActionButtonState.loading,
    LogoutFailed: MoleculeActionButtonState.fail,
    LogoutSucceed: MoleculeActionButtonState.success,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class LogoutInitial extends LogoutState {}

class LogoutInProgress extends LogoutState {}

class LogoutSucceed extends LogoutState {
  final User user;
  LogoutSucceed(this.user);
}

class LogoutFailed extends LogoutState {
  final CoreError error;
  LogoutFailed(this.error);
}

class LogoutNotifier extends StateNotifier<LogoutState> with LoggerMixin {
  final DeviceRepository deviceRepository;
  final UserRepository userRepository;
  final ClientRepository clientRepository;

  LogoutNotifier({
    required this.deviceRepository,
    required this.userRepository,
    required this.clientRepository,
  }) : super(LogoutInitial());

  Future<void> reset() async => state = LogoutInitial();

  Future<void> logout() async {
    if (state is! LogoutInitial) return debug(() => errorUnexpectedState.toString());

    try {
      state = LogoutInProgress();

      final authenticated = await userRepository.logout();
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

      state = LogoutSucceed(user);
    } on CoreError catch (e) {
      error(e.toString());
      state = LogoutFailed(e);
    } catch (ex) {
      error(ex.toString());
      state = LogoutFailed(errorUnexpectedException(ex));
    }
  }
}

// eof
