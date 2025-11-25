import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

class DashboardAnalyticsDAO extends ApiServerDAO {
  final ApiServerContext context;

  DashboardAnalyticsDAO(this.context) : super(context.api);

  Future<int> _count(String sql, Map<String, dynamic> sqlParams) async => withSqlLog(context, () async {
        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) return 0;
        return rows[0]["count"] as int;
      });

  Future<List<int>> _array(String subquery, Map<String, dynamic> sqlParams) async => withSqlLog(context, () async {
        final sql = """
          WITH date_series AS (
              SELECT generate_series(@from, @from::TIMESTAMPTZ + MAKE_INTERVAL(days => (@days - 1)), '1 day') AS day
          ),
          counts AS (
              $subquery
          )
          SELECT EXTRACT(DAY FROM ds.day - @from) + 1 AS day, COUNT(counts.id) AS count
          FROM date_series ds
          LEFT JOIN counts ON counts.date::DATE = ds.DAY::DATE
          GROUP BY ds.day
          ORDER BY day
        """
            .tidyCode();

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) return [];
        return rows.map((row) => row["count"] as int).toList();
      });

  Future<int> countTotalUsers(String clientId) async {
    return await _count(
      """
        SELECT COUNT(*) FROM
        (
            SELECT u.user_id
            FROM users u
            INNER JOIN user_cards uc ON uc.user_id = u.user_id AND uc.client_id = @client_id AND uc.deleted_at IS NULL AND uc.active = TRUE
            WHERE u.deleted_at IS NULL
            GROUP BY u.user_id
        ) AS count
        """
          .tidyCode(),
      {
        "client_id": clientId,
      },
    );
  }

  Future<List<int>> countNewUsers(String clientId, IntDate from, int days) async {
    return await _array(
      """
        SELECT u.user_id AS id, MIN(uc.created_at)::DATE AS date
        FROM users u
        JOIN user_cards uc ON u.user_id = uc.user_id
        WHERE uc.client_id = @client_id AND uc.deleted_at IS NULL AND uc.active = TRUE AND u.deleted_at IS NULL
        GROUP BY u.user_id
          """,
      {
        "client_id": clientId,
        "from": from.toDate().startOfDay.toUtc().toIso8601String(),
        "days": days,
      },
    );
  }

  Future<int> countTotalCards(String clientId) async {
    return await _count(
      """
        SELECT COUNT(*) AS count
        FROM user_cards uc
        WHERE uc.client_id = @client_id AND uc.deleted_at IS NULL AND uc.active = TRUE
        """
          .tidyCode(),
      {
        "client_id": clientId,
      },
    );
  }

  Future<List<int>> countActiveCards(String clientId, IntDate from, int days) async {
    return await _array(
      """
        SELECT uc.user_card_id AS id, lt.created_at::DATE AS date
        FROM user_cards uc
        INNER JOIN loyalty_transactions lt ON lt.user_card_id = uc.user_card_id AND lt.client_id = uc.client_id AND lt.card_id = uc.card_id
        WHERE uc.client_id = @client_id AND uc.deleted_at IS NULL AND uc.active = TRUE 
        GROUP BY uc.user_card_id, lt.created_at::DATE
        """,
      {
        "client_id": clientId,
        "from": from.toDate().startOfDay.toUtc().toIso8601String(),
        "days": days,
      },
    );
  }

  Future<List<int>> countNewCards(String clientId, IntDate from, int days) async {
    return await _array(
      """
        SELECT uc.user_card_id AS ID, uc.created_at::DATE AS date
        FROM user_cards uc
        WHERE uc.client_id = @client_id AND uc.deleted_at IS NULL AND uc.active = TRUE 
        GROUP BY uc.user_card_id, uc.created_at::DATE
        """,
      {
        "client_id": clientId,
        "from": from.toDate().startOfDay.toUtc().toIso8601String(),
        "days": days,
      },
    );
  }

  Future<List<int>> countReservationDates(String clientId, ReservationDateStatus status, IntDate from, int days) async {
    return await _array(
      """
        SELECT rd.reservation_date_id AS id, rd.date_time_from::DATE AS date
        FROM reservation_dates rd 
        WHERE rd.client_id = @client_id AND rd.deleted_at IS NULL 
          AND rd.status = @status
          ${status == ReservationDateStatus.available ? "AND rd.reserved_by_user_id IS NOT NULL" : ""}
        GROUP BY rd.reservation_date_id, rd.date_time_from::DATE
      """,
      {
        "client_id": clientId,
        "from": from.toDate().startOfDay.toUtc().toIso8601String(),
        "days": days,
        "status": status.code,
      },
    );
  }
}

// eof
