import "package:meta/meta.dart";
import "package:riverpod/riverpod.dart";

import "../../core_logging.dart";
import "../../core_repositories.dart";
import "../data_models/user.dart";
import "../lang.dart";

@immutable
abstract class LoginState {}

class LoginInitial extends LoginState {}

class LoginInProgress extends LoginState {}

class LoginSucceed extends LoginState {
  final User user;
  LoginSucceed(this.user);
}

class LoginFailed extends LoginState {
  final String message;
  LoginFailed(this.message);
}

class LoginNotifier extends StateNotifier<LoginState> with LoggerMixin {
  final DeviceRepository deviceRepository;
  final UserRepository userRepository;
  LoginNotifier({required this.deviceRepository, required this.userRepository}) : super(LoginInitial());

  Future<void> anonymous(
    String installationId, {
    String? deviceToken,
    JsonObject? deviceInfo,
    required String language,
    required String country,
  }) async {
    state = LoginInProgress();
    try {
      final authenticated = await userRepository.anonymous(
        installationId,
        deviceToken: deviceToken,
        deviceInfo: deviceInfo,
        language: language,
        country: country,
      );
      final user = await userRepository.read(authenticated.userId);
      if (user == null) throw Exception("User not found");
      deviceRepository.put(DeviceKey.user, user);
      deviceRepository.put(DeviceKey.refreshToken, authenticated.refreshToken);
      deviceRepository.put(DeviceKey.accessToken, authenticated.accessToken);
      state = LoginSucceed(user);
    } catch (e) {
      state = LoginFailed(e.toString());
    }
  }

  Future<void> login(String installationId, String? email, String? login, String password) async {
    state = LoginInProgress();
    try {
      final authenticated = await userRepository.login(installationId, email, login, password);
      final user = await userRepository.read(authenticated.userId);
      if (user == null) throw Exception("User not found");
      deviceRepository.put(DeviceKey.user, user);
      deviceRepository.put(DeviceKey.refreshToken, authenticated.refreshToken);
      deviceRepository.put(DeviceKey.accessToken, authenticated.accessToken);
      state = LoginSucceed(user);
    } catch (e) {
      state = LoginFailed(e.toString());
    }
  }

  Future<void> register(String installationId, String? email, String? login, String password) async {
    state = LoginInProgress();
    try {
      final authenticated = await userRepository.register(installationId, email, login, password);
      final user = await userRepository.read(authenticated.userId);
      if (user == null) throw Exception("User not found");
      deviceRepository.put(DeviceKey.user, user);
      deviceRepository.put(DeviceKey.refreshToken, authenticated.refreshToken);
      deviceRepository.put(DeviceKey.accessToken, authenticated.accessToken);
      state = LoginSucceed(user);
    } catch (e) {
      state = LoginFailed(e.toString());
    }
  }

  Future<void> logout() async {
    state = LoginInProgress();
    try {
      final authenticated = await userRepository.logout();
      final user = await userRepository.read(authenticated.userId);
      if (user == null) throw Exception("User not found");
      deviceRepository.put(DeviceKey.user, user);
      deviceRepository.put(DeviceKey.refreshToken, authenticated.refreshToken);
      deviceRepository.put(DeviceKey.accessToken, authenticated.accessToken);
    } catch (e) {
      state = LoginFailed(e.toString());
    }
  }
}

// eof
