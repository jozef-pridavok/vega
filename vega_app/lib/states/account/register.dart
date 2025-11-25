import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_widgets.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

@immutable
abstract class RegisterState {}

extension RegisterStateToActionButtonState on RegisterState {
  static const _map = {
    RegisterInitial: MoleculeActionButtonState.idle,
    RegisterInProgress: MoleculeActionButtonState.loading,
    RegisterFailed: MoleculeActionButtonState.fail,
    RegisterSucceed: MoleculeActionButtonState.success,
  };

  MoleculeActionButtonState get buttonState => _map[runtimeType] ?? MoleculeActionButtonState.idle;
}

class RegisterInitial extends RegisterState {}

class RegisterInProgress extends RegisterState {}

class RegisterSucceed extends RegisterState {
  final User user;
  RegisterSucceed(this.user);
}

class RegisterFailed extends RegisterState {
  final CoreError error;
  RegisterFailed(this.error);
}

class RegisterNotifier extends StateNotifier<RegisterState> with LoggerMixin {
  final DeviceRepository device;
  final UserRepository users;

  RegisterNotifier({
    required this.device,
    required this.users,
  }) : super(RegisterInitial());

  void reset() => state = RegisterInitial();

  Future<void> register({String? email, String? login, required String password}) async {
    if (state is! RegisterInitial) return debug(() => errorUnexpectedState.toString());

    try {
      state = RegisterInProgress();

      final installationId = device.get(DeviceKey.installationId);
      final authenticated = await users.register(installationId, email, login, password);
      device.put(DeviceKey.refreshToken, authenticated.refreshToken);
      device.put(DeviceKey.accessToken, authenticated.accessToken);

      final user = await users.read(authenticated.userId);
      if (user == null) throw errorUserNotSignedIn;
      if (user.blocked) throw errorAccountBlocked;

      device.put(DeviceKey.user, user);

      state = RegisterSucceed(user);
    } on CoreError catch (err) {
      state = RegisterFailed(err);
    } catch (ex) {
      state = RegisterFailed(errorUnexpectedException(ex));
    }
  }
}

// eof
