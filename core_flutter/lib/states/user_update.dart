import "package:core_dart/core_dart.dart";
import "package:core_dart/core_repositories.dart";
import "package:flutter/material.dart" hide Theme;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core_flutter.dart";

@immutable
abstract class UserUpdateState {}

extension UserUpdateStateToActionButtonState on UserUpdateState {
  static const stateMap = {
    UserUpdateInitial: MoleculeActionButtonState.idle,
    UserUpdateInProgress: MoleculeActionButtonState.loading,
    UserUpdateFailed: MoleculeActionButtonState.fail,
    UserUpdateSucceed: MoleculeActionButtonState.success,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class UserUpdateInitial extends UserUpdateState {}

class UserUpdateInProgress extends UserUpdateState {}

class UserUpdateSucceed extends UserUpdateState {}

class UserUpdateFailed extends UserUpdateState implements FailedState {
  @override
  final CoreError error;
  UserUpdateFailed(this.error);
}

class UserUpdateNotifier extends StateNotifier<UserUpdateState> with LoggerMixin {
  final DeviceRepository deviceRepository;
  final UserRepository remoteUserRepository;

  UserUpdateNotifier({
    required this.deviceRepository,
    required this.remoteUserRepository,
  }) : super(UserUpdateInitial());

  Future<void> reset() async => state = UserUpdateInitial();

  Future<void> update({
    String? nick,
    int? yob,
    Gender? gender,
    Locale? language,
    Country? country,
    Theme? theme,
    Folders? folders,
    Map<String, dynamic>? meta,
  }) async {
    var userSyncedRemotely = false;
    try {
      state = UserUpdateInProgress();

      final user = deviceRepository.get(DeviceKey.user) as User;

      if (nick != null) user.nick = nick;
      if (yob != null) user.yob = yob;
      if (gender != null) user.gender = gender;
      if (language != null) user.language = language.languageCode;
      if (country != null) user.country = country.code;
      if (theme != null) user.theme = theme;
      if (folders != null) user.folders = folders;
      if (meta != null) user.meta = meta;

      deviceRepository.put(DeviceKey.user, user);
      deviceRepository.put(DeviceKey.userSyncedRemotely, false);

      userSyncedRemotely = await remoteUserRepository.update(user);
      if (userSyncedRemotely) deviceRepository.put(DeviceKey.userSyncedRemotely, true);

      state = userSyncedRemotely ? UserUpdateSucceed() : UserUpdateFailed(errorFailedToSaveData);
    } on CoreError catch (e) {
      error(e.toString());
      state = UserUpdateFailed(e);
    } catch (e) {
      error(e.toString());
      state = UserUpdateFailed(errorUnexpectedException(e));
    } finally {
      deviceRepository.put(DeviceKey.userSyncedRemotely, userSyncedRemotely);
    }
  }
}

// eof