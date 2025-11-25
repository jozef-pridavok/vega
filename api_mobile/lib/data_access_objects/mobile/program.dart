import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";
import "../../utils/storage.dart";

/*
CREATE TABLE qr_tag (
    qr_tag_id VARCHAR(64) NOT NULL,
    client_id VARCHAR(64) NOT NULL,
    program_id VARCHAR(64) NOT NULL,
    points INT NOT NULL DEFAULT 0,
    used_by_user_id VARCHAR(64),
    created_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE NOT NULL DEFAULT NOW(),
    deleted_at TIMESTAMP WITH TIME ZONE,
    used_at TIMESTAMP WITH TIME ZONE,
    CONSTRAINT pk_qr_tag PRIMARY KEY (qr_tag_id),
    CONSTRAINT fk_qr_tag_clients FOREIGN KEY(client_id) REFERENCES clients(client_id),
    CONSTRAINT fk_qr_tag_programs FOREIGN KEY(program_id) REFERENCES programs(program_id),
    CONSTRAINT fk_qr_tag_users FOREIGN KEY(used_by_user_id) REFERENCES users(user_id)
);
CREATE INDEX idx_qr_tag_client_id ON qr_tag(client_id);
CREATE INDEX idx_qr_tag_program_id ON qr_tag(program_id);
CREATE INDEX idx_qr_tag_used_by_user_id ON qr_tag(used_by_user_id);
*/

class ProgramDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  ProgramDAO(this.session, this.context) : super(context.api);

  Future<Program?> getDetail({required String programId}) async => withSqlLog(context, () async {
        final sql = """
          SELECT *,
            TO_JSON(ARRAY(
              SELECT json_build_object(
                'program_reward_id', r.program_reward_id, 
                'program_id', r.program_id, 
                'name', r.name, 'description', r.description,
                'image', r.image,  'image_bh', r.image_bh, 
                'points', r.points, 'digits', p.digits, 
                'valid_from', r.valid_from, 'valid_to', r.valid_to
                )
              FROM program_rewards AS r
              WHERE p.program_id = r.program_id AND
                r.blocked = FALSE AND r.deleted_at IS NULL AND 
                (r.valid_from IS NULL OR r.valid_from <= intDateNow()) AND 
                (r.valid_to IS NULL OR r.valid_to >= IntDateNow())
              ORDER BY r.rank ASC
            )) AS rewards
          FROM programs p
          WHERE 
            p.program_id = @program_id AND p.blocked = FALSE AND p.deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"program_id": programId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) return null;
        final program = Program.fromMap(rows.first, Convention.snake);
        program.image = api.storageUrl(program.image, StorageObject.program, timeStamp: program.updatedAt);

        program.rewards?.forEach((reward) {
          reward.image = api.storageUrl(reward.image, StorageObject.reward, timeStamp: reward.updatedAt);
        });
        return program;
      });

  Future<(String? programId, String? clientId, int? points)> selectProgramTag(String tagId) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT * 
          FROM qr_tag t
          INNER JOIN programs p ON t.program_id = p.program_id
          WHERE t.qr_tag_id = @tag_id AND t.deleted_at IS NULL AND t.used_by_user_id IS NULL AND t.used_at IS NULL
            AND p.deleted_at IS NULL AND p.blocked = FALSE
        """
            .tidyCode();

        final sqlParams = {"tag_id": tagId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) return (null, null, null);

        final row = rows.first;
        final clientId = row["client_id"] as String;
        final programId = row["program_id"] as String;
        final points = row["points"] as int;

        return (programId, clientId, points);
      });

  Future<List<(String cardId, String userCardId)>> selectUserCards(String programId) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT c.card_id, uc.user_card_id
          FROM user_cards uc
          INNER JOIN cards c ON uc.card_id = c.card_id
          INNER JOIN programs p ON c.card_id = p.card_id
          WHERE p.program_id = @program_id AND uc.user_id = @user_id AND uc.deleted_at IS NULL 
            AND c.deleted_at IS NULL AND c.blocked = FALSE
            AND p.deleted_at IS NULL AND p.blocked = FALSE
        """
            .tidyCode();

        final sqlParams = {
          "program_id": programId,
          "user_id": session.userId,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => (row["card_id"] as String, row["user_card_id"] as String)).toList();
      });

  Future<int> applyTag({
    required String clientId,
    required String programId,
    required String tagId,
    required String cardId,
    required String userCardId,
    required int points,
  }) async =>
      withSqlLog(context, () async {
        String sql = """
          UPDATE qr_tag
          SET used_by_user_id = @user_id, used_at = NOW(), updated_at = NOW()
          WHERE qr_tag_id = @tag_id
        """
            .tidyCode();

        Map<String, dynamic> sqlParams = {
          "tag_id": tagId,
          "user_id": session.userId,
        };

        log.logSql(context, sql, sqlParams);

        int updated = await api.update(sql, params: sqlParams);
        if (updated == 0) return 0;

        sql = """
          INSERT INTO loyalty_transactions
            (loyalty_transaction_id, client_id, card_id, program_id, user_id, user_card_id, 
              points, transaction_object_type, transaction_object_id, created_at, updated_at)
          VALUES 
            (@loyalty_transaction_id, @client_id, @card_id, @program_id, @user_id, @user_card_id, 
              @points, @object_type, @object_id, NOW(), NOW())
        """
            .tidyCode();

        sqlParams = <String, dynamic>{
          "loyalty_transaction_id": uuid(),
          "client_id": clientId,
          "card_id": cardId,
          "program_id": programId,
          "user_id": session.userId,
          "user_card_id": userCardId,
          "points": points,
          "object_type": LoyaltyTransactionObjectType.qrTag.code,
          "object_id": tagId,
        };

        log.logSql(context, sql, sqlParams);

        return await api.insert(sql, params: sqlParams);
      });
}

// eof
