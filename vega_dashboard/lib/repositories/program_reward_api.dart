import "dart:io";

import "package:core_flutter/core_dart.dart";

import "program_reward.dart";

class ApiProgramRewardRepository with LoggerMixin implements RewardRepository {
  @override
  Future<List<Reward>> readAll(Program program) async {
    final path = "/v1/dashboard/program_reward/program/${program.programId}";
    final res = await ApiClient().get(path);
    final json = await res.handleStatusCodeWithJson();
    return (json?["program_rewards"] as JsonArray?)?.map((e) => Reward.fromMap(e, Convention.camel)).toList() ?? [];
  }

  @override
  Future<bool> create(Reward programReward, {List<int>? image}) async {
    final path = "/v1/dashboard/program_reward/${programReward.programRewardId}";
    final api = ApiClient();

    final res = image != null
        ? await api.postMultipart(path, [image, programReward.toMap(Convention.camel)])
        : await api.post(path, data: programReward.toMap(Convention.camel));

    final json = await res.handleStatusCodeWithJson(HttpStatus.created);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> update(Reward programReward, {List<int>? image}) async {
    final path = "/v1/dashboard/program_reward/${programReward.programRewardId}";
    final api = ApiClient();

    final res = image != null
        ? await api.putMultipart(path, [image, programReward.toMap(Convention.camel)])
        : await api.put(path, data: programReward.toMap(Convention.camel));

    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  Future<bool> _patch(Reward reward, Map<String, dynamic> data) async {
    final res = await ApiClient().patch("/v1/dashboard/program_reward/${reward.programRewardId}", data: data);
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> unblock(Reward reward) => _patch(reward, {"blocked": false});

  @override
  Future<bool> block(Reward reward) => _patch(reward, {"blocked": true});

  @override
  Future<bool> archive(Reward reward) => _patch(reward, {"archived": true});

  @override
  Future<bool> reorder(List<Reward> programRewards) async {
    final res = await ApiClient().put(
      "/v1/dashboard/program_reward/reorder",
      data: {"reorder": programRewards.map((e) => e.programRewardId).toList()},
    );
    final json = await res.handleStatusCodeWithJson(HttpStatus.accepted);
    return (json?["affected"] as int?) == programRewards.length;
  }
}

// eof
