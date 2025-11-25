import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/data_models/data_model.dart";

import "../repositories/program_reward.dart";

enum RewardPatchPhase {
  initial,
  blocking,
  blocked,
  unblocking,
  unblocked,
  archiving,
  archived,
  reordering,
  reordered,
  failed,
}

extension RewardPatchPhaseBool on RewardPatchPhase {
  bool get isInProgress =>
      this == RewardPatchPhase.blocking ||
      this == RewardPatchPhase.unblocking ||
      this == RewardPatchPhase.archiving ||
      this == RewardPatchPhase.reordering;

  bool get isSuccessful =>
      this == RewardPatchPhase.blocked ||
      this == RewardPatchPhase.unblocked ||
      this == RewardPatchPhase.archived ||
      this == RewardPatchPhase.reordered;
}

class RewardPatchState {
  final RewardPatchPhase phase;
  final Reward reward;
  RewardPatchState(this.phase, this.reward);

  factory RewardPatchState.initial() => RewardPatchState(RewardPatchPhase.initial, DataModel.emptyReward());

  factory RewardPatchState.blocking(Reward reward) => RewardPatchState(RewardPatchPhase.blocking, reward);
  factory RewardPatchState.blocked(Reward reward) => RewardPatchState(RewardPatchPhase.blocked, reward);

  factory RewardPatchState.unblocking(Reward reward) => RewardPatchState(RewardPatchPhase.unblocking, reward);
  factory RewardPatchState.unblocked(Reward reward) => RewardPatchState(RewardPatchPhase.unblocked, reward);

  factory RewardPatchState.archiving(Reward reward) => RewardPatchState(RewardPatchPhase.archiving, reward);
  factory RewardPatchState.archived(Reward reward) => RewardPatchState(RewardPatchPhase.archived, reward);

  factory RewardPatchState.reordering(Reward reward) => RewardPatchState(RewardPatchPhase.reordering, reward);
  factory RewardPatchState.reordered(Reward reward) => RewardPatchState(RewardPatchPhase.reordered, reward);
}

class RewardPatchFailed extends RewardPatchState implements FailedState {
  @override
  final CoreError error;
  @override
  RewardPatchFailed(this.error, Reward reward) : super(RewardPatchPhase.failed, reward);

  factory RewardPatchFailed.from(CoreError error, RewardPatchState state) => RewardPatchFailed(error, state.reward);
}

class RewardPatchNotifier extends StateNotifier<RewardPatchState> with StateMixin {
  final RewardRepository repository;

  RewardPatchNotifier({required this.repository}) : super(RewardPatchState.initial());

  Future<void> reset() async => state = RewardPatchState.initial();

  Future<void> block(Reward reward) async {
    try {
      state = RewardPatchState.blocking(reward);
      bool stopped = await repository.block(reward);
      state = stopped
          ? RewardPatchState.blocked(reward.copyWith(blocked: true))
          : RewardPatchFailed(errorFailedToSaveData, reward);
    } catch (e) {
      verbose(() => e.toString());
      state = RewardPatchFailed(errorFailedToSaveData, reward);
    }
  }

  Future<void> unblock(Reward reward) async {
    try {
      state = RewardPatchState.unblocking(reward);
      bool stopped = await repository.unblock(reward);
      state = stopped
          ? RewardPatchState.unblocked(reward.copyWith(blocked: false))
          : RewardPatchFailed(errorFailedToSaveData, reward);
    } catch (e) {
      verbose(() => e.toString());
      state = RewardPatchFailed(errorFailedToSaveData, reward);
    }
  }

  Future<void> archive(Reward reward) async {
    try {
      state = RewardPatchState.archiving(reward);
      bool archived = await repository.archive(reward);
      state = archived ? RewardPatchState.archived(reward) : RewardPatchFailed(errorFailedToSaveData, reward);
    } catch (e) {
      verbose(() => e.toString());
      state = RewardPatchFailed(errorFailedToSaveData, reward);
    }
  }

  Future<void> reorder(List<Reward> rewards, int oldIndex, int newIndex) async {
    throw UnimplementedError();
    /*
    try {
      state = RewardPatchState.archiving(rewards.first);
      final removedReward = rewards.removeAt(oldIndex);
      rewards.insert(newIndex, removedReward);
      final newRewards = rewards.map((reward) => reward.copyWith(rank: rewards.indexOf(reward))).toList();
      //final newProgram = program.copyWith(rewards: newRewards);
      final reordered = await repository.reorder(newRewards);
      state = reordered ? RewardPatchState.archived(reward) : RewardPatchFailed(errorFailedToSaveData, reward);
    } on CoreError catch (err) {
      warning(err.toString());
      state = RewardPatchFailed(err, program: program);
    } catch (e) {
      warning(e.toString());
      state = RewardPatchFailed(errorFailedToSaveData, program: program);
    }
    */
  }
}

// eof
