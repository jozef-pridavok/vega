import "package:core_flutter/core_dart.dart";

import "program_actions.dart";

class ApiProgramActionRepository with LoggerMixin implements ProgramActionRepository {
  @override
  Future<bool> add(String programId, int points, {String? userCardId, String? number}) async {
    final res = await ApiClient().post("/v1/dashboard/pos_transaction/add", data: {
      "programId": programId,
      "points": points,
      "userCardId": userCardId,
      "number": number,
    });
    final json = await res.handleStatusCodeWithJson();
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> subtract(String programId, int points, {String? userCardId, String? number}) async {
    final res = await ApiClient().post("/v1/dashboard/pos_transaction/spend", data: {
      "programId": programId,
      "points": points,
      "userCardId": userCardId,
      "number": number,
    });
    final json = await res.handleStatusCodeWithJson();
    return (json?["affected"] as int?) == 1;
  }

  @override
  Future<bool> issueReward(String rewardId, String userCardId) async {
    final res = await ApiClient().post(
      "/v1/dashboard/pos_transaction/request_reward",
      data: {"rewardId": rewardId, "userCardId": userCardId},
    );
    final json = await res.handleStatusCodeWithJson();
    return (json?["affected"] as int?) == 1;
  }
}

// eof
