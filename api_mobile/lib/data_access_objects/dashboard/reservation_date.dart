import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";

class ReservationDateDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  ReservationDateDAO(this.session, this.context) : super(context.api);

  Future<List<ReservationDate>> selectWeek({
    required String reservationId,
    required DateTime dateOfWeek,
    int? limit,
  }) async =>
      withSqlLog(context, () async {
        final sqlParams = {
          "client_id": session.clientId,
          "reservation_id": reservationId,
          "date_of_week": dateOfWeek.copyWith(hour: 12),
        };
        final sql = """
          SELECT rd.reservation_date_id, rd.client_id, rd.reservation_id, rd.reservation_slot_id,
            rd.reserved_by_user_id,
            COALESCE(u.meta->'clients'->'${session.clientId}'->>'displayName', u.nick) AS user_nick,        
            rd.status, rd.date_time_from, rd.date_time_to, rd.meta
          FROM reservation_dates rd
          LEFT JOIN users u ON u.user_id = rd.reserved_by_user_id
          -- TODO: need user_card, remove me later
          LEFT JOIN (
              SELECT user_id, MAX(number) AS number FROM user_cards
              WHERE client_id = @client_id AND deleted_at IS NULL
              GROUP BY user_id
          ) uc ON uc.user_id = rd.reserved_by_user_id
          WHERE rd.deleted_at IS NULL AND rd.client_id = @client_id AND rd.reservation_id = @reservation_id
            AND EXTRACT(WEEK FROM date_time_from) = EXTRACT(WEEK FROM (@date_of_week::timestamptz AT TIME ZONE 'UTC'))
          ${limit != null ? "LIMIT $limit" : ""}
        """
            .tidyCode();

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map<ReservationDate>((row) => ReservationDate.fromMap(row, ReservationDate.snake)).toList();
      });

  Future<
      ({
        String? reservedByUserId,
        DateTime dateTimeFrom,
        DateTime dateTimeTo,
        String reservationSlotId,
        String reservationSlotName,
        String reservationId,
        String reservationName,
        String clientId,
        String clientName,
        String? clientLogo,
        String? clientLogoBh,
        String? clientColor,
      })?> userReservationDataForMessage({
    required String termId,
  }) async =>
      withSqlLog(context, () async {
        final sqlParams = <String, dynamic>{"reservation_date_id": termId};
        final sql = """
          SELECT 
              rd.reserved_by_user_id,
              rd.date_time_from,
              rd.date_time_to,
              rs.reservation_slot_id, 
              rs.name AS reservation_slot_name, 
              r.reservation_id,
              r.name AS reservation_name,
              c.client_id,
              c.name AS client_name,
              c.logo AS client_logo,
              c.logo_bh AS client_logo_bh,
              c.color AS client_color
          FROM reservation_dates rd 
          INNER JOIN reservation_slots rs ON rs.reservation_slot_id = rd.reservation_slot_id 
          INNER JOIN reservations r ON r.reservation_id = rd.reservation_id 
          INNER JOIN clients c ON c.client_id = rd.client_id AND c.blocked = FALSE AND c.deleted_at IS NULL
          WHERE rd.reservation_date_id = @reservation_date_id
        """
            .tidyCode();

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) return null;
        final row = rows.first;
        return (
          reservedByUserId: row["reserved_by_user_id"] as String?,
          dateTimeFrom: row["date_time_from"] as DateTime,
          dateTimeTo: row["date_time_to"] as DateTime,
          reservationSlotId: row["reservation_slot_id"] as String,
          reservationSlotName: row["reservation_slot_name"] as String,
          reservationId: row["reservation_id"] as String,
          reservationName: row["reservation_name"] as String,
          clientId: row["client_id"] as String,
          clientName: row["client_name"] as String,
          clientLogo: row["client_logo"] as String?,
          clientLogoBh: row["client_logo_bh"] as String?,
          clientColor: row["client_color"] as String?,
        );
      });

  Future<int> insertMany(List<ReservationDate> newReservationDates) async => withSqlLog(context, () async {
        var sql = """
          INSERT INTO reservation_dates (
            reservation_date_id, client_id, reservation_id, reservation_slot_id,
            status, date_time_from, date_time_to, created_at
          ) VALUES
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{};

        for (int i = 0; i < newReservationDates.length; i++) {
          sql += """
            ( 
              @reservation_date_id_$i, @client_id_$i, @reservation_id_$i, @reservation_slot_id_$i,
              @status_$i, @date_time_from_$i, @date_time_to_$i, NOW()
            )${i < newReservationDates.length - 1 ? ',' : ''}
          """
              .tidyCode();
          sqlParams.addAll({
            "reservation_date_id_$i": newReservationDates[i].reservationDateId,
            "client_id_$i": newReservationDates[i].clientId,
            "reservation_id_$i": newReservationDates[i].reservationId,
            "reservation_slot_id_$i": newReservationDates[i].reservationSlotId,
            "status_$i": newReservationDates[i].status.code,
            "date_time_from_$i": newReservationDates[i].dateTimeFrom,
            "date_time_to_$i": newReservationDates[i].dateTimeTo,
          });
        }

        log.logSql(context, sql, sqlParams);

        final inserted = await api.insert(sql, params: sqlParams);
        return inserted;
      });

  Future<int> deleteMany({
    required String reservationSlotId,
    required List<int> days,
    required DateTime dateTimeFrom,
    required DateTime dateTimeTo,
    required bool removeReservedDates,
  }) async =>
      withSqlLog(context, () async {
        final sqlParams = {
          "client_id": session.clientId,
          "reservation_slot_id": reservationSlotId,
          "days": days,
          "date_time_from": dateTimeFrom,
          "date_time_to": dateTimeTo,
        };
        final sql = """
          UPDATE reservation_dates
            SET deleted_at = NOW()
          WHERE deleted_at IS NULL AND client_id = @client_id AND reservation_slot_id = @reservation_slot_id
            AND date_time_from >= @date_time_from AND date_time_to <= @date_time_to
            AND EXTRACT(ISODOW FROM (date_time_from::date)) = ANY(@days)
            ${!removeReservedDates ? "AND reserved_by_user_id IS NULL " : ""};
        """
            .tidyCode();

        log.logSql(context, sql, sqlParams);

        final updated = await api.update(sql, params: sqlParams);
        return updated;
      });

  Future<(int, String?)> confirm({
    required String reservationDateId,
  }) async =>
      withSqlLog(context, () async {
        final sql = """
          UPDATE reservation_dates
            SET status = @status, updated_at = NOW()
          WHERE reservation_date_id = @reservation_date_id AND client_id = @client_id AND deleted_at IS NULL
          RETURNING reserved_by_user_id
        """
            .tidyCode();

        final sqlParams = {
          "client_id": session.clientId,
          "reservation_date_id": reservationDateId,
          "status": ReservationDateStatus.confirmed.code,
        };

        log.logSql(context, sql, sqlParams);

        final (affected, result) = await api.updateWithResult(sql, params: sqlParams);
        return (affected, result.firstOrNull?["reserved_by_user_id"] as String?);
      });

  Future<int> complete({
    required String reservationDateId,
  }) async =>
      withSqlLog(context, () async {
        final sqlParams = {
          "client_id": session.clientId,
          "reservation_date_id": reservationDateId,
          "status": ReservationDateStatus.completed.code,
        };
        final sql = """
          UPDATE reservation_dates
            SET status = @status, updated_at = NOW()
          WHERE reservation_date_id = @reservation_date_id AND client_id = @client_id AND deleted_at IS NULL
        """
            .tidyCode();

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> forfeit({
    required String reservationDateId,
  }) async =>
      withSqlLog(context, () async {
        final sqlParams = {
          "client_id": session.clientId,
          "reservation_date_id": reservationDateId,
          "status": ReservationDateStatus.forfeited.code,
        };
        final sql = """
          UPDATE reservation_dates
            SET status = @status, updated_at = NOW()
          WHERE reservation_date_id = @reservation_date_id AND client_id = @client_id AND deleted_at IS NULL
       """
            .tidyCode();

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> addUserToDate(String reservationDateId, String userId) async => withSqlLog(context, () async {
        final sqlParams = {
          "client_id": session.clientId,
          "reservation_date_id": reservationDateId,
          "user_id": userId,
          "status": ReservationDateStatus.confirmed.code,
        };

        final sql = """
          UPDATE reservation_dates
            SET reserved_by_user_id = @user_id, status = @status,
                updated_at = NOW()
          WHERE reservation_date_id = @reservation_date_id AND reserved_by_user_id IS NULL
            AND client_id = @client_id AND deleted_at IS NULL
        """
            .tidyCode();

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> cancel(String reservationDateId) async => withSqlLog(context, () async {
        final sql = """
          UPDATE reservation_dates
            SET reserved_by_user_id = NULL, status = @status,
                updated_at = NOW()
          WHERE reservation_date_id = @reservation_date_id AND client_id = @client_id AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = {
          "client_id": session.clientId,
          "reservation_date_id": reservationDateId,
          "status": ReservationDateStatus.available.code,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<(int, String?)> delete({required String reservationDateId}) async => withSqlLog(context, () async {
        final sqlParams = {
          "client_id": session.clientId,
          "reservation_date_id": reservationDateId,
        };

        String sql = """
          SELECT reserved_by_user_id AS user_id
          FROM reservation_dates rd
          INNER JOIN users u ON u.user_id = rd.reserved_by_user_id
          WHERE rd.reservation_date_id = @reservation_date_id AND rd.client_id = @client_id AND rd.deleted_at IS NULL
            AND u.deleted_at IS NULL
        """
            .tidyCode();

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        final userId = rows.isEmpty ? null : rows.first["user_id"] as String?;

        sql = """
          UPDATE reservation_dates
            SET deleted_at = NOW()
          WHERE reservation_date_id = @reservation_date_id AND client_id = @client_id AND deleted_at IS NULL
        """
            .tidyCode();

        log.logSql(context, sql, sqlParams);

        return (await api.delete(sql, params: sqlParams), userId);
      });

  Future<int> swapDates(String dateId1, String dateId2) async => withSqlLog(context, () async {
        final sqlParams = {
          "client_id": session.clientId,
          "date_id_1": dateId1,
          "date_id_2": dateId2,
        };

        final sql = """
          UPDATE reservation_dates
          SET date_time_from = CASE
                WHEN reservation_date_id = @date_id_1 THEN (SELECT date_time_from FROM reservation_dates WHERE reservation_date_id = @date_id_2)
                WHEN reservation_date_id = @date_id_2 THEN (SELECT date_time_from FROM reservation_dates WHERE reservation_date_id = @date_id_1)
              END,
              date_time_to = CASE
                WHEN reservation_date_id = @date_id_1 THEN (SELECT date_time_to FROM reservation_dates WHERE reservation_date_id = @date_id_2)
                WHEN reservation_date_id = @date_id_2 THEN (SELECT date_time_to FROM reservation_dates WHERE reservation_date_id = @date_id_1)
              END
          WHERE reservation_date_id IN (@date_id_1, @date_id_2) AND client_id = @client_id AND deleted_at IS NULL;
        """
            .tidyCode();

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
