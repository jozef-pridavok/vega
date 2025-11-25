import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../data_models/session.dart";

class CardDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  CardDAO(this.session, this.context) : super(context.api);

  Future<Card?> selectById(String cardId) async => withSqlLog(context, () async {
        final sql = """
          SELECT card_id, client_id, code_type, name, logo, logo_bh, color, rank, countries, blocked
          FROM cards
          WHERE card_id = @card_id AND blocked = FALSE AND deleted_at IS NULL      
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"card_id": cardId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) return null;
        return Card.fromMap(rows.first, Convention.snake);
      });

  // Filter: 1 = Active, 2 = Archived
  Future<List<Card>> list({required int filter, String? search, int? limit}) async => withSqlLog(context, () async {
        final sql = """
            SELECT k.card_id, k.client_id, k.code_type, k.name, k.logo, k.color, k.rank,
              k.countries, k.blocked, k.meta, k.updated_at,
              ARRAY_TO_STRING(ARRAY(
                SELECT name 
                FROM programs p 
                WHERE p.deleted_at IS NULL AND p.blocked = FALSE 
                AND p.card_id = k.card_id ORDER BY p.rank), 
                ', '
              ) AS program_names
            FROM cards k
            INNER JOIN clients c ON k.client_id = c.client_id
            --LEFT JOIN programs p ON p.card_id = k.card_id
            WHERE k.client_id = @client_id AND c.deleted_at IS NULL
            ${filter == 1 ? "AND k.deleted_at IS NULL " : ""}
            ${filter == 2 ? "AND k.deleted_at IS NOT NULL " : ""}
            ${(search?.isNotEmpty ?? false) ? "AND k.name ILIKE @search " : ""}
            ORDER BY k.rank
            ${limit != null ? "LIMIT $limit" : ""}
          """
            .tidyCode();
        final sqlParams = <String, dynamic>{
          "client_id": session.clientId,
          if ((search?.isNotEmpty ?? false)) "search": "%$search%",
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => Card.fromMap(row, Convention.snake)).toList();
      });

  Future<int> insert(Card card) async => withSqlLog(context, () async {
        final sql = """
          INSERT INTO cards (
            card_id, client_id, code_type, name, countries, color,
            ${card.logo != null ? 'logo, ' : ''}
            ${card.logoBh != null ? 'logo_bh, ' : ''} 
            ${card.meta != null ? 'meta, ' : ''}
            created_at
          ) VALUES (
            @card_id, @client_id, @code_type, @name, @countries, @color,
            ${card.logo != null ? '@logo, ' : ''}
            ${card.logoBh != null ? '@logo_bh, ' : ''} 
            ${card.meta != null ? '@meta, ' : ''}
            NOW()
          )
        """
            .tidyCode();

        final sqlParams = card.toMap(Convention.snake);
        sqlParams["countries"] = card.countries != null ? "{${card.countries!.map((e) => e.code).join(",")}}" : null;

        log.logSql(context, sql, sqlParams);

        return await api.insert(sql, params: sqlParams);
      });

  Future<int> update(Card card) async => withSqlLog(context, () async {
        final sql = """
          UPDATE cards SET 
            name = @name, countries = @countries, color = @color,
            ${card.logo != null ? 'logo = @logo, ' : ''} 
            ${card.logoBh != null ? 'logo_bh = @logo_bh, ' : ''}
            ${card.meta != null ? 'meta = @meta, ' : ''}
            updated_at = NOW()
          WHERE card_id = @card_id AND client_id = @client_id AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = card.toMap(Convention.snake);
        sqlParams["countries"] = card.countries != null ? "{${card.countries!.map((e) => e.code).join(",")}}" : null;

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> patch(String cardId, {bool? blocked, bool? archived}) async => withSqlLog(context, () async {
        final sql = """
          UPDATE cards SET
            ${blocked != null ? 'blocked = @blocked, ' : ''}
            ${archived == true ? 'deleted_at = NOW(), ' : ''}
            ${archived == false ? 'deleted_at = NULL, ' : ''}
            updated_at = NOW()
          WHERE client_id = @client_id AND card_id = @card_id
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "card_id": cardId,
          "client_id": session.clientId,
          if (blocked != null) "blocked": (blocked ? 1 : 0),
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> reorder(List<String> cardIds) async => withSqlLog(context, () async {
        final sql = """
          UPDATE cards
          SET rank = array_position(@card_ids, card_id),
              updated_at = NOW()
          WHERE client_id = @client_id AND card_id = ANY(@card_ids)
        """
            .tidyCode();

        final sqlParams = {"client_id": session.clientId, "card_ids": cardIds};

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
