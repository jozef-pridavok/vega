import "package:core_flutter/core_dart.dart" hide UserRepository;
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/user.dart";

@immutable
abstract class SentClientMessageToUserState {}

extension ClientPaymentPayStateActionButtonState on SentClientMessageToUserState {
  static const stateMap = {
    SendMessageToUserSending: MoleculeActionButtonState.loading,
    SendClientMessageToUserSucceed: MoleculeActionButtonState.success,
    SendClientMessageToUserFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class SendClientMessageToUserInitial extends SentClientMessageToUserState {
  SendClientMessageToUserInitial();
}

class SendMessageToUserSending extends SentClientMessageToUserState {
  final String userId;
  SendMessageToUserSending(this.userId);
}

class SendClientMessageToUserSucceed extends SentClientMessageToUserState {
  final String userId;
  SendClientMessageToUserSucceed(this.userId);
}

class SendClientMessageToUserFailed extends SentClientMessageToUserState implements FailedState {
  @override
  final CoreError error;
  @override
  SendClientMessageToUserFailed(this.error);
}

class SendClientMessageToUserNotifier extends StateNotifier<SentClientMessageToUserState> with LoggerMixin {
  final UserRepository userRepository;

  SendClientMessageToUserNotifier({
    required this.userRepository,
  }) : super(SendClientMessageToUserInitial());

  Future<void> reset() async => state = SendClientMessageToUserInitial();

  Future<void> send(
    String userId, {
    required String subject,
    required String body,
    List<MessageType> messageTypes = const [MessageType.inApp, MessageType.pushNotification],
  }) async {
    if (cast<SendMessageToUserSending>(state) != null) return debug(() => errorAlreadyInProgress.toString());
    try {
      state = SendMessageToUserSending(userId);
      final ok = await userRepository.sendMessage(userId, subject, body, messageTypes);
      if (ok)
        state = SendClientMessageToUserSucceed(userId);
      else
        state = SendClientMessageToUserFailed(errorFailedToSaveData);
    } on CoreError catch (err) {
      warning(err.toString());
      state = SendClientMessageToUserFailed(err);
    } on Exception catch (ex) {
      state = SendClientMessageToUserFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = SendClientMessageToUserFailed(errorFailedToLoadData);
    }
  }
}


// eof
