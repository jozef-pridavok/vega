import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart" hide Card;
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../repositories/program_reward.dart";

@immutable
abstract class RewardsState {}

class RewardsInitial extends RewardsState {}

class RewardsLoading extends RewardsState {}

class RewardsSucceed extends RewardsState {
  final List<Reward> rewards;
  RewardsSucceed(this.rewards);
}

class RewardsRefreshing extends RewardsSucceed {
  RewardsRefreshing(super.program);
}

class RewardsFailed extends RewardsState implements FailedState {
  @override
  final CoreError error;
  @override
  RewardsFailed(this.error);
}

class RewardsNotifier extends StateNotifier<RewardsState> with StateMixin {
  final Program program;
  final RewardRepository rewardRepository;

  RewardsNotifier(this.program, {required this.rewardRepository}) : super(RewardsInitial());

  void reset() => state = RewardsInitial();

  Future<void> load({bool reload = false}) async {
    if (!reload && cast<RewardsSucceed>(state) != null) return debug(() => errorAlreadyLoaded.toString());
    try {
      if (state is! RewardsRefreshing) state = RewardsLoading();
      final rewards = await rewardRepository.readAll(program);
      state = RewardsSucceed(rewards);
    } on CoreError catch (err) {
      warning(err.toString());
      state = RewardsFailed(err);
    } on Exception catch (ex) {
      state = RewardsFailed(errorFailedToLoadDataEx(ex: ex));
    } catch (e) {
      warning(e.toString());
      state = RewardsFailed(errorFailedToLoadData);
    }
  }

  Future<void> refresh() async {
    final succeed = cast<RewardsSucceed>(state);
    if (succeed == null) return await load(reload: true);
    state = RewardsRefreshing(succeed.rewards);
    await load(reload: true);
  }

  bool added(Reward reward) {
    return next(state, [RewardsSucceed], () {
      final rewards = cast<RewardsSucceed>(state)!.rewards;
      final index = rewards.indexWhere((e) => e.programRewardId == reward.programRewardId);
      if (index != -1) return false;
      rewards.insert(0, reward);
      state = RewardsSucceed(rewards);
      return true;
    });
  }

  bool updated(Reward reward) {
    return next(state, [RewardsSucceed], () {
      final rewards = cast<RewardsSucceed>(state)!.rewards;
      final index = rewards.indexWhere((e) => e.programRewardId == reward.programRewardId);
      if (index == -1) return false;
      rewards.replaceRange(index, index + 1, [reward]);
      state = RewardsSucceed(rewards);
      return true;
    });
  }

  bool removed(Reward reward) {
    return next(state, [RewardsSucceed], () {
      final rewards = cast<RewardsSucceed>(state)!.rewards;
      final index = rewards.indexWhere((r) => r.programRewardId == reward.programRewardId);
      if (index == -1) return false;
      rewards.removeAt(index);
      state = RewardsSucceed(rewards);
      return true;
    });
  }

  Future<void> reorder(int oldIndex, int newIndex) async {
    final succeed = expect<RewardsSucceed>(state);
    if (succeed == null) return;
    try {
      final currentRewards = succeed.rewards;
      final removedReward = currentRewards.removeAt(oldIndex);
      currentRewards.insert(newIndex, removedReward);
      final newRewards = currentRewards.map((card) => card.copyWith(rank: currentRewards.indexOf(card))).toList();
      final reordered = await rewardRepository.reorder(newRewards);
      state = reordered ? RewardsSucceed(newRewards) : RewardsFailed(errorFailedToSaveData);
    } on CoreError catch (err) {
      warning(err.toString());
      state = RewardsFailed(err);
    } catch (e) {
      warning(e.toString());
      state = RewardsFailed(errorFailedToSaveData);
    }
  }
}

// eof
