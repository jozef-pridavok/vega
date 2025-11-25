import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/data_models/data_model.dart";

import "../repositories/program_reward.dart";

@immutable
abstract class RewardEditorState {}

extension RewardEditorStateToActionButtonState on RewardEditorState {
  static const stateMap = {
    RewardEditorSaving: MoleculeActionButtonState.loading,
    RewardEditorSucceed: MoleculeActionButtonState.success,
    RewardEditorFailed: MoleculeActionButtonState.fail,
  };

  MoleculeActionButtonState get buttonState => stateMap[runtimeType] ?? MoleculeActionButtonState.idle;
}

class RewardEditorInitial extends RewardEditorState {}

class RewardEditorEditing extends RewardEditorState {
  final Program program;
  final Reward reward;
  final bool isNew;
  RewardEditorEditing(this.program, this.reward, {this.isNew = false});
}

class RewardEditorSaving extends RewardEditorEditing {
  RewardEditorSaving(super.program, super.reward, {required super.isNew});
}

class RewardEditorSucceed extends RewardEditorSaving {
  RewardEditorSucceed(super.program, super.reward) : super(isNew: false);
}

class RewardEditorFailed extends RewardEditorSaving implements FailedState {
  @override
  final CoreError error;
  @override
  RewardEditorFailed(this.error, super.program, super.reward, {required super.isNew});
}

class RewardEditorNotifier extends StateNotifier<RewardEditorState> with StateMixin {
  final RewardRepository rewardRepository;

  RewardEditorNotifier({
    required this.rewardRepository,
  }) : super(RewardEditorInitial());

  void reset() async => state = RewardEditorInitial();

  void create(Program program) {
    final reward = DataModel.createReward(program);
    state = RewardEditorEditing(program, reward, isNew: true);
  }

  void edit(Program program, Reward reward) {
    state = RewardEditorEditing(program, reward);
  }

  void set({
    String? name,
    String? description,
    int? point,
    IntDate? validFrom,
    IntDate? validTo,
    int? points,
    int? count,
  }) async {
    final editing = expect<RewardEditorEditing>(state);
    if (editing == null) return;
    final reward = editing.reward.copyWith(
      name: name ?? editing.reward.name,
      description: description ?? editing.reward.description,
      points: point ?? editing.reward.points,
      count: count,
      validFrom: validFrom ?? editing.reward.validFrom,
      validTo: validTo ?? editing.reward.validTo,
    );
    state = RewardEditorEditing(editing.program, reward, isNew: editing.isNew);
  }

  Future<void> save({List<int>? newImage}) async {
    final editing = expect<RewardEditorEditing>(state);
    if (editing == null) return;
    final reward = editing.reward;
    final program = editing.program;
    state = RewardEditorSaving(program, reward, isNew: editing.isNew);
    try {
      final ok = editing.isNew
          ? await rewardRepository.create(reward, image: newImage)
          : await rewardRepository.update(reward, image: newImage);
      state = ok
          ? RewardEditorSucceed(program, reward)
          : RewardEditorFailed(errorFailedToSaveData, program, reward, isNew: editing.isNew);
    } on CoreError catch (err) {
      verbose(() => err.toString());
      state = RewardEditorFailed(err, program, reward, isNew: editing.isNew);
    } on Exception catch (ex) {
      verbose(() => ex.toString());
      state = RewardEditorFailed(errorFailedToSaveDataEx(ex: ex), program, reward, isNew: editing.isNew);
    } catch (e) {
      verbose(() => e.toString());
      state = RewardEditorFailed(errorFailedToSaveData, program, reward, isNew: editing.isNew);
    }
  }

  Future<void> reedit() async {
    final (saving) = expect<RewardEditorSaving>(state);
    if (saving == null) return;
    state = RewardEditorEditing(saving.program, saving.reward, isNew: saving.isNew);
  }
}

// eof
