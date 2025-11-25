abstract class ProgramActionRepository {
  Future<bool> add(String programId, int points, {String? userCardId, String? number});
  Future<bool> subtract(String programId, int points, {String? userCardId, String? number});

  Future<bool> issueReward(String programRewardId, String userCardId);
}

// eof
