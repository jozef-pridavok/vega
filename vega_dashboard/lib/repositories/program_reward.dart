import "package:core_flutter/core_dart.dart";

abstract class RewardRepository {
  Future<List<Reward>> readAll(Program program);
  Future<bool> create(Reward reward, {List<int>? image});
  Future<bool> update(Reward reward, {List<int>? image});

  Future<bool> block(Reward reward);
  Future<bool> unblock(Reward reward);
  Future<bool> archive(Reward reward);

  Future<bool> reorder(List<Reward> rewards);
}

// eof
