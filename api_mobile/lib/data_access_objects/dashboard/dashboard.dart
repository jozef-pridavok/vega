import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";

class DashboardDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  DashboardDAO(this.session, this.context) : super(context.api);

  Future<List<Program>> selectClientPrograms() async {
    final sqlParams = <String, dynamic>{"client_id": session.clientId};
    final sql = """
      SELECT program_id, client_id, card_id, type, name, description, digits, countries, 
        rank, blocked, valid_from,
        COALESCE((meta->>'plural')::JSONB, '{}'::JSONB) AS plural,
        (meta->>'actions')::JSONB AS actions,
        TO_JSON(ARRAY(
          SELECT json_build_object(
            'program_reward_id', pr.program_reward_id, 
            'program_id', pr.program_id, 
            'name', pr.name, 'description', pr.description, 
            'image', pr.image, 'image_bh', pr.image_bh, 
            'points', pr.points,              
            'valid_from', pr.valid_from, 'valid_to', pr.valid_to
            )
          FROM program_rewards AS pr 
          WHERE pr.program_id = p.program_id 
          ORDER BY pr.rank
        )) AS rewards
      FROM programs p
      WHERE p.client_id = @client_id AND p.deleted_at IS NULL 
        AND p.valid_from <= intDateNow() AND COALESCE(p.valid_to >= intDateNow(), true)
      ORDER BY p.rank
    """
        .tidyCode();

    log.logSql(context, sql, sqlParams);

    final rows = await api.select(sql, params: sqlParams);
    return rows.map((row) => Program.fromMap(row, Convention.snake)).toList();
  }

  Future<List<Coupon>> selectClientCoupons() async => withSqlLog(context, () async {
        final sqlParams = <String, dynamic>{"client_id": session.clientId};
        final sql = """
          SELECT coupon_id, client_id, location_id, type, name, description, valid_from, valid_to, rank
          FROM coupons c
          WHERE c.client_id = @client_id AND type IN (2, 3, 4, 5) AND c.deleted_at IS NULL 
            AND c.valid_from <= intDateNow() AND COALESCE(c.valid_to >= intDateNow(), true)
          ORDER BY c.rank
        """
            .tidyCode();

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => Coupon.fromMap(row, Convention.snake)).toList();
      });

  Future<List<Card>> selectClientCards() async => withSqlLog(context, () async {
        final sqlParams = <String, dynamic>{"client_id": session.clientId};
        final sql = """
          SELECT card_id, client_id, code_type, name, rank, blocked
          FROM cards
          WHERE client_id = @client_id AND deleted_at IS NULL
          ORDER BY created_at
        """
            .tidyCode();

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => Card.fromMap(row, Convention.snake)).toList();
      });
}

// eof
