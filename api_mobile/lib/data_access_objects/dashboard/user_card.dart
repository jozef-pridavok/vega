import "package:collection/collection.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../emit_card.dart";

class UserCardDAO extends ApiServerDAO {
  final ApiServerContext context;

  UserCardDAO(this.context) : super(context.api);

  Future<UserCard?> select(String userCardId) async => withSqlLog(context, () async {
        final sql = """
          SELECT * 
          FROM user_cards
          WHERE user_card_id = @user_card_id
        """;

        final sqlParams = <String, dynamic>{"user_card_id": userCardId};

        log.logSql(context, sql, sqlParams);

        final userCards = await api.select(sql, params: sqlParams);
        final dataObject = userCards.firstOrNull;
        return dataObject != null ? UserCard.fromMap(dataObject, Convention.snake) : null;
      });

  Future<int> delete(String userId, String userCardId) async => withSqlLog(context, () async {
        final sql = """
          UPDATE user_cards
          SET deleted_at = NOW()
          WHERE user_id = @user_id AND user_card_id = @user_card_id AND deleted_at IS NULL
        """;

        final sqlParams = <String, dynamic>{
          "user_id": userId,
          "user_card_id": userCardId,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  /// Issue a new user card. Returns the user card id.
  Future<String?> issue(String? cardId, String userId, String clientId, {JsonObject? meta}) async =>
      withSqlLog(context, () async {
        final emitCard = EmitCardDAO(context);
        return await emitCard.emitNewUserCard(clientId, cardId, userId, meta: meta);
      });

  Future<List<LoyaltyTransaction>> transactions(String userCardId) async => withSqlLog(context, () async {
        final sql = """
          SELECT 
            lt.loyalty_transaction_id, lt.client_id, lt.card_id, lt.program_id, lt.user_id, lt.user_card_id, lt.points, p.digits,
            lt.transaction_object_type AS object_type, lt.transaction_object_id AS object_id,
            lt.created_at AS date,
            p.name AS program_name
          FROM loyalty_transactions lt      
          LEFT JOIN programs p ON lt.program_id = p.program_id
          WHERE lt.user_card_id = @user_card_id
          ORDER BY lt.created_at DESC
        """;

        final sqlParams = <String, dynamic>{"user_card_id": userCardId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => LoyaltyTransaction.fromMap(row, LoyaltyTransaction.snake)).toList();
      });
}

// eof
