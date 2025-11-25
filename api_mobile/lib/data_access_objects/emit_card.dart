import "package:collection/collection.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

class EmitCardDAO extends ApiServerDAO {
  final ApiServerContext context;

  EmitCardDAO(this.context) : super(context.api);

  // TODO: dopracovať ako sa bude získavať defaultná karta
  Future<String?> getDefaultCard(String clientId) async => withSqlLog(context, () async {
        final sql = """
          SELECT card_id FROM cards
          INNER JOIN clients ON clients.client_id = cards.client_id
          WHERE cards.blocked = FALSE AND clients.blocked = FALSE AND cards.deleted_at IS NULL
              AND clients.client_id = @client_id
          ORDER BY cards.rank DESC
          LIMIT 1
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"client_id": clientId};

        log.logSql(context, sql, sqlParams);

        final cards = await api.select(sql, params: sqlParams);
        return cards.firstOrNull?["card_id"];
      });

  /// Returns the user card id or null if the user card could not be created.
  Future<String?> emitNewUserCard(String clientId, String? cardId, String userId, {JsonObject? meta}) async =>
      withSqlLog(context, () async {
        cardId ??= (await getDefaultCard(clientId));

        var sql = """
          SELECT next_user_card_number, clients.meta->>'newUserCardMask' AS new_user_card_mask, cards.*
          FROM clients
          INNER JOIN cards ON cards.client_id = clients.client_id
          WHERE clients.blocked = FALSE AND cards.blocked = FALSE
              AND clients.client_id = @client_id AND cards.card_id = @card_id
          LIMIT 1
        """
            .tidyCode();

        var sqlParams = <String, dynamic>{"client_id": clientId, "card_id": cardId};

        log.logSql(context, sql, sqlParams);

        final res = await api.select(sql, params: sqlParams);
        final row = res.firstOrNull;
        if (row == null) return null;

        final yyyy = DateTime.now().toUtc().year.toString();
        final yy = yyyy.substring(yyyy.length - 2);
        final mask =
            (row["new_user_card_mask"] as String? ?? "YY-***-***").replaceAll("YYYY", yyyy).replaceAll("YY", yy);
        final number = (row["next_user_card_number"] as int? ?? 1).toString().padLeft(mask.length, "0");

        var finalNumber = "";
        for (var n = 0; n < mask.length; n++) {
          finalNumber += (mask[n] == "*") ? number[n] : mask[n];
        }
        finalNumber = finalNumber.replaceAll(RegExp(r"\D"), "");

        sql = """
          INSERT INTO user_cards(user_card_id, user_id, card_id, client_id, code_type, number, name, notes, color, meta, touched_at, created_at, updated_at)
          VALUES 
          (@user_card_id, @user_id, @card_id, @client_id, @code_type, @number, @name, @notes, @color, @meta, NOW(), NOW(), NOW())
        """
            .tidyCode();

        final userCardId = uuid();
        sqlParams = <String, dynamic>{
          "user_card_id": userCardId,
          "user_id": userId,
          "card_id": cardId,
          "client_id": clientId,
          "code_type": row["code_type"] as int,
          "number": finalNumber,
          "name": row["name"] as String?,
          "notes": "",
          "color": row["color"] as String?,
          "meta": meta,
        };

        log.logSql(context, sql, sqlParams);

        final inserted = await api.insert(sql, params: sqlParams);
        return inserted == 1 ? userCardId : null;
      });
}

// eof
