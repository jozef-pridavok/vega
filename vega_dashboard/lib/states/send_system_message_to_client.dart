import "package:core_flutter/core_dart.dart" hide UserRepository;
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/user.dart";

@immutable
abstract class SendSystemMessageToClientState {}

extension SendSystemMessageToClientStateToActionButtonState on SendSystemMessageToClientState {
  static const stateMap = {
    SendSystemMessageToClientSending: MoleculeActionButtonState.loading,
    SendSystemMessageToClientSucceed: MoleculeActionButtonState.success,
    SendSystemMessageToClientFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class SendSystemMessageToClientInitial extends SendSystemMessageToClientState {
  SendSystemMessageToClientInitial();
}

class SendSystemMessageToClientSending extends SendSystemMessageToClientState {
  final String userId;
  SendSystemMessageToClientSending(this.userId);
}

class SendSystemMessageToClientSucceed extends SendSystemMessageToClientState {
  final String userId;
  SendSystemMessageToClientSucceed(this.userId);
}

class SendSystemMessageToClientFailed extends SendSystemMessageToClientState implements FailedState {
  @override
  final CoreError error;
  @override
  SendSystemMessageToClientFailed(this.error);
}

class SendSystemMessageToClientNotifier extends StateNotifier<SendSystemMessageToClientState> with LoggerMixin {
  final UserRepository userRepository;

  SendSystemMessageToClientNotifier({
    required this.userRepository,
  }) : super(SendSystemMessageToClientInitial());

  Future<void> reset() async => state = SendSystemMessageToClientInitial();

  Future<void> send(
    String userId, {
    required String subject,
    required String body,
    List<MessageType> messageTypes = const [MessageType.inApp, MessageType.pushNotification],
  }) async {
    if (cast<SendSystemMessageToClientSending>(state) != null) return debug(() => errorAlreadyInProgress.toString());
    try {
      state = SendSystemMessageToClientSending(userId);
      final ok = await userRepository.sendMessage(userId, subject, body, messageTypes);
      if (ok)
        state = SendSystemMessageToClientSucceed(userId);
      else
        state = SendSystemMessageToClientFailed(errorFailedToSaveData);
    } on CoreError catch (err) {
      warning(err.toString());
      state = SendSystemMessageToClientFailed(err);
    } on Exception catch (ex) {
      state = SendSystemMessageToClientFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = SendSystemMessageToClientFailed(errorFailedToLoadData);
    }
  }
}

// eof
