import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";

class ReservationDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  ReservationDAO(this.session, this.context) : super(context.api);

  Future<List<Reservation>> list({required int filter, String? search, int? limit}) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT r.reservation_id, r.client_id, r.program_id, r.loyalty_mode, r.name, 
            r.description, r.image, r.image_bh, r.rank, r.blocked, r.meta,
            TO_JSON(ARRAY(
              SELECT json_build_object(
                'reservation_slot_id', rs.reservation_slot_id, 'client_id', rs.client_id,
                'reservation_id', rs.reservation_id, 'location_id', rs.location_id, 'name', rs.name,
                'description', rs.description, 'image', rs.image, 'image_bh', rs.image_bh, 'rank', rs.rank,
                'price', rs.price, 'duration', rs.duration, 'blocked', rs.blocked, 'meta', rs.meta, 
                'deleted_at', rs.deleted_at
              )
              FROM reservation_slots rs
              WHERE rs.reservation_id = r.reservation_id
              ORDER BY rs.rank
            )) AS reservation_slots
          FROM reservations r
          INNER JOIN clients c ON c.client_id = r.client_id
          WHERE r.client_id = @client_id AND c.blocked IS FALSE
          ${(search?.isNotEmpty ?? false) ? "AND (r.name ILIKE @search OR r.description ILIKE @search) " : ""}
          ${filter == 1 ? "AND r.deleted_at IS NULL " : "AND r.deleted_at IS NOT NULL "}
          ORDER BY r.rank, r.name
          ${limit != null ? "LIMIT $limit" : ""}
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "client_id": session.clientId,
          if ((search?.isNotEmpty ?? false)) "search": "%$search%",
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => Reservation.fromMap(row, Reservation.snake, reservationSlotsMap: row)).toList();
      });

  Future<List<ReservationForDashboard>> _listForAction({
    required int limit,
    required ReservationDateStatus fromStatus,
    required String dateFilter,
  }) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT 
            r.reservation_id, rs.reservation_slot_id, rd.reservation_date_id, 
            r.name AS reservation_name, rs.name AS slot_name, rs.color,
            rd.date_time_from, rd.date_time_to, rd.reserved_by_user_id AS user_id,
            COALESCE(u.meta->'clients'->'${session.clientId}'->>'displayName', u.nick) AS user_nick
          FROM reservations r
          INNER JOIN reservation_slots rs ON rs.reservation_id = r.reservation_id
          INNER JOIN reservation_dates rd ON rd.reservation_slot_id = rs.reservation_slot_id
          INNER JOIN users u ON u.user_id = rd.reserved_by_user_id
          WHERE r.client_id = @client_id AND r.blocked IS FALSE
            AND r.deleted_at IS NULL AND rs.blocked IS FALSE AND rs.deleted_at IS NULL
            AND rd.status = ${fromStatus.code} AND rd.deleted_at IS NULL
            $dateFilter
          ORDER BY rd.date_time_from, r.rank, r.name
          LIMIT $limit
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "client_id": session.clientId,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => ReservationForDashboard.fromMap(row, Convention.snake)).toList();
      });

  Future<List<ReservationForDashboard>> listForConfirmation({required int limit}) async =>
      withSqlLog(context, () async {
        return await _listForAction(
          limit: limit,
          fromStatus: ReservationDateStatus.available,
          dateFilter: "AND (rd.date_time_from::DATE >= CURRENT_DATE OR rd.date_time_to::DATE >= CURRENT_DATE)",
        );
      });

  Future<List<ReservationForDashboard>> listForFinalization({required int limit}) async =>
      withSqlLog(context, () async {
        return await _listForAction(
          limit: limit,
          fromStatus: ReservationDateStatus.confirmed,
          dateFilter: "AND (rd.date_time_from::DATE <= CURRENT_DATE OR rd.date_time_to::DATE <= CURRENT_DATE)",
        );
      });

  Future<int> insert(Reservation reservation) async => withSqlLog(context, () async {
        final sql = """
          INSERT INTO reservations (
            reservation_id, client_id, loyalty_mode, name,
            program_id,
            ${reservation.description != null ? 'description, ' : ''} 
            ${reservation.image != null ? 'image, ' : ''}
            ${reservation.imageBh != null ? 'image_bh, ' : ''} 
            ${reservation.meta != null ? 'meta, ' : ''}
            created_at
          ) VALUES (
            @reservation_id, @client_id, @loyalty_mode, @name,
            ${reservation.programId != null ? '@program_id, ' : 'NULL, '}
            ${reservation.description != null ? '@description, ' : ''} 
            ${reservation.image != null ? '@image, ' : ''}
            ${reservation.imageBh != null ? '@image_bh, ' : ''} 
            ${reservation.meta != null ? '@meta, ' : ''}
            NOW())
        """
            .tidyCode();

        final sqlParams = reservation.toMap(Reservation.snake);

        log.logSql(context, sql, sqlParams);

        final inserted = await api.insert(sql, params: sqlParams);
        return inserted;
      });

  Future<int> update(Reservation reservation) async => withSqlLog(context, () async {
        final sql = """
          UPDATE reservations SET 
            loyalty_mode = @loyalty_mode, name = @name,
            ${reservation.programId != null ? 'program_id = @program_id, ' : 'program_id = NULL, '}
            ${reservation.description != null ? 'description = @description, ' : ''} 
            ${reservation.image != null ? 'image = @image, ' : ''}
            ${reservation.imageBh != null ? 'image_bh = @image_bh, ' : ''} 
            ${reservation.meta != null ? 'meta = @meta, ' : ''} 
            updated_at = NOW()
          WHERE reservation_id = @reservation_id AND client_id = @client_id AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = reservation.toMap(Reservation.snake);

        log.logSql(context, sql, sqlParams);

        final updated = await api.update(sql, params: sqlParams);
        return updated;
      });

  Future<int> patch(String reservationId, {bool? blocked, bool? archived}) async => withSqlLog(context, () async {
        final sql = """
          UPDATE reservations SET
            ${blocked != null ? 'blocked = @blocked, ' : ''}
            ${archived == true ? 'deleted_at = NOW(), ' : ''}
            ${archived == false ? 'deleted_at = NULL, ' : ''}
            updated_at = NOW()
          WHERE client_id = @client_id AND reservation_id = @reservation_id
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "reservation_id": reservationId,
          "client_id": session.clientId,
          if (blocked != null) "blocked": (blocked ? 1 : 0),
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> reorder(List<String> reservationIds) async => withSqlLog(context, () async {
        final sql = """
          UPDATE reservations
          SET rank = array_position(@reservation_ids, reservation_id),
              updated_at = NOW()
          WHERE client_id = @client_id AND reservation_id = ANY(@reservation_ids)
        """
            .tidyCode();

        final sqlParams = {"client_id": session.clientId, "reservation_ids": reservationIds};

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
