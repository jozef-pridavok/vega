import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/program_actions.dart";

@immutable
abstract class IssueRewardState {}

class IssueRewardInitial extends IssueRewardState {}

class IssueRewardInProcess extends IssueRewardState {}

class IssueRewardSucceed extends IssueRewardState {
  IssueRewardSucceed();
}

class IssueRewardFailed extends IssueRewardState implements FailedState {
  @override
  final CoreError error;
  @override
  IssueRewardFailed(this.error);
}

class IssueRewardNotifier extends StateNotifier<IssueRewardState> with LoggerMixin {
  final ProgramActionRepository programAction;

  IssueRewardNotifier({required this.programAction}) : super(IssueRewardInitial());

  void reset() => state = IssueRewardInitial();

  Future<void> issue(String programRewardId, String userCardId) async {
    try {
      state = IssueRewardInProcess();
      final issued = await programAction.issueReward(programRewardId, userCardId);
      state = issued ? IssueRewardSucceed() : IssueRewardFailed(errorFailedToSaveData);
    } on CoreError catch (err) {
      error("Unexpected error: $err");
      state = IssueRewardFailed(err);
    } catch (ex) {
      error("Unexpected exception: $ex");
      state = IssueRewardFailed(errorUnexpectedException(ex));
    }
  }
}

// eof
