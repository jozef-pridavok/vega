import "package:core_dart/core_dart.dart";
import "package:core_dart/core_repositories.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../core_flutter.dart";

@immutable
abstract class UserState {}

class UserInitial extends UserState {}

class UserLoading extends UserState {}

class UserSucceed extends UserState {
  final User user;

  UserSucceed(this.user);
}

class UserFailed extends UserState implements FailedState {
  @override
  final CoreError error;

  @override
  UserFailed({required this.error});
}

class UserNotifier extends StateNotifier<UserState> with LoggerMixin {
  final DeviceRepository deviceRepository;
  final UserRepository remoteUserRepository;
  final ClientRepository clientRepository;

  UserNotifier({
    required this.deviceRepository,
    required this.remoteUserRepository,
    required this.clientRepository,
  }) : super(UserInitial());

  Future<void> refresh() async {
    try {
      if (state is UserLoading) return;

      state = UserLoading();

      final current = deviceRepository.get(DeviceKey.user) as User;

      if (!(deviceRepository.get(DeviceKey.userSyncedRemotely) as bool? ?? false)) {
        if (await remoteUserRepository.update(current)) {
          deviceRepository.put(DeviceKey.userSyncedRemotely, true);
        }
      }

      final updated = await remoteUserRepository.read(current.userId, ignoreCache: true);
      if (updated == null) {
        state = UserFailed(error: errorNoUser);
        return;
      }
      deviceRepository.put(DeviceKey.user, updated);

      final userClientId = updated.clientId;
      if (userClientId != null) {
        final client = await clientRepository.read(userClientId, ignoreCache: true);
        deviceRepository.put(DeviceKey.client, client);
      }

      state = UserSucceed(updated);
    } on ApiResponse catch (e) {
      error(e.toString());
      final message = e.message ?? e.toString();
      state = UserFailed(error: CoreError(code: e.appCode, message: message));
    } on CoreError catch (e) {
      state = UserFailed(error: e);
    } catch (e) {
      error(e.toString());
      state = UserFailed(error: errorUnexpectedException(e));
    }
  }
}

// eof
