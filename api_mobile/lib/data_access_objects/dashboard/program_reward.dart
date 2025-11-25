import "package:api_mobile/utils/storage.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";

class RewardDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  RewardDAO(this.session, this.context) : super(context.api);

  Future<List<Reward>> list(String programId, {required int filter, String? search, int? limit}) async {
    final sql = """
      SELECT pr.program_reward_id, pr.program_id, pr.name, pr.description, pr.image, pr.image_bh,
      pr.points, pr.rank, pr.count, pr.valid_from, pr.valid_to, pr.meta, pr.blocked,
      pr.updated_at
      FROM program_rewards pr
      INNER JOIN programs p ON p.program_id = pr.program_id
      WHERE pr.program_id = @program_id AND p.client_id = @client_id 
      AND pr.deleted_at IS NULL
      ${(search?.isNotEmpty ?? false) ? "AND (pr.name ILIKE @search OR pr.description ILIKE @search) " : ""}
      ${filter == 1 ? "AND COALESCE(pr.valid_from <= intDateNow() AND pr.valid_to >= intDateNow(), true) " : ""}
      ${filter == 2 ? "AND pr.valid_from > intDateNow() " : ""}
      ${filter == 3 ? "AND pr.valid_to < intDateNow() " : ""}
      ORDER BY pr.rank, pr.name
      ${limit != null ? "LIMIT $limit" : ""}
    """
        .tidyCode();

    final sqlParams = <String, dynamic>{
      "client_id": session.clientId,
      "program_id": programId,
      if ((search?.isNotEmpty ?? false)) "search": "%$search%",
      "filter": filter,
    };

    log.logSql(context, sql, sqlParams);

    final rows = await api.select(sql, params: sqlParams);
    return rows.map((row) {
      final reward = Reward.fromMap(row, Convention.snake);
      reward.image = api.storageUrl(reward.image, StorageObject.reward, timeStamp: reward.updatedAt);
      return reward;
    }).toList();
  }

  Future<int> insert(Reward reward) async {
    final sql = """
      INSERT INTO program_rewards (
        program_reward_id, program_id,
        count,
        ${reward.description != null ? 'description, ' : ''}
        ${reward.image != null ? 'image, ' : ''}
        ${reward.imageBh != null ? 'image_bh, ' : ''}
        ${reward.validTo != null ? 'valid_to, ' : ''}
        ${reward.meta != null ? 'meta, ' : ''}
        name, points, valid_from
      ) VALUES (
        @program_reward_id, @program_id,
        ${reward.count != null ? '@count, ' : 'NULL, '}
        ${reward.description != null ? '@description, ' : ''}
        ${reward.image != null ? '@image, ' : ''}
        ${reward.imageBh != null ? '@image_bh, ' : ''}
        ${reward.validTo != null ? '@valid_to, ' : ''}
        ${reward.meta != null ? '@meta, ' : ''}
        @name, @points, @valid_from
      )
      """
        .tidyCode();

    final sqlParams = reward.toMap(Convention.snake);

    log.logSql(context, sql, sqlParams);

    return await api.insert(sql, params: sqlParams);
  }

  Future<int> update(Reward reward) async {
    final sql = """
      UPDATE program_rewards pr 
      SET
        name = @name, points = @points, valid_from = @valid_from,
        ${reward.description != null ? 'description = @description, ' : ''}
        ${reward.count != null ? 'count = @count, ' : 'count = NULL, '}
        ${reward.image != null ? 'image = @image, ' : ''}
        ${reward.imageBh != null ? 'image_bh = @image_bh, ' : ''}
        ${reward.validTo != null ? 'valid_to = @valid_to, ' : ''}
        ${reward.meta != null ? 'meta = @meta, ' : ''}
        updated_at = NOW()
      FROM programs p
      WHERE p.program_id = pr.program_id AND p.client_id = @client_id
      AND pr.program_reward_id = @program_reward_id AND pr.deleted_at IS NULL
    """
        .tidyCode();

    final sqlParams = {
      ...reward.toMap(Convention.snake),
      "client_id": session.clientId,
    };

    log.logSql(context, sql, sqlParams);

    return await api.update(sql, params: sqlParams);
  }

  Future<int> patch(rewardId, {bool? blocked, bool? archived}) async {
    final sql = """
      UPDATE program_rewards SET
        ${blocked != null ? 'blocked = @blocked, ' : ''}
        ${archived == true ? 'deleted_at = NOW(), ' : ''}
        ${archived == false ? 'deleted_at = NULL, ' : ''}
        updated_at = NOW()
      WHERE program_reward_id = @program_reward_id
    """
        .tidyCode();

    final sqlParams = <String, dynamic>{
      "program_reward_id": rewardId,
      if (blocked != null) "blocked": (blocked ? 1 : 0),
    };

    log.logSql(context, sql, sqlParams);

    return await api.update(sql, params: sqlParams);
  }

  Future<int> reorder(List<String> rewardIds) async {
    final sql = """
      UPDATE program_rewards
      SET rank = array_position(@reward_ids, program_reward_id),
          updated_at = NOW()
      WHERE program_reward_id = ANY(@reward_ids)
    """
        .tidyCode();

    final sqlParams = {"reward_ids": rewardIds};

    log.logSql(context, sql, sqlParams);

    return await api.update(sql, params: sqlParams);
  }
}

// eof
