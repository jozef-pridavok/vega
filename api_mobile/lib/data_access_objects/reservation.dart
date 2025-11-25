import "package:collection/collection.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../data_models/session.dart";

class ReservationDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  ReservationDAO(this.session, this.context) : super(context.api);

  Future<List<UserReservation>> active({String? clientId}) async => withSqlLog(context, () async {
        final sql = """
          SELECT 
              r.reservation_id AS reservation_id,
              r.name AS reservation_name,
              r.description AS reservation_description,
              r.client_id AS client_id,
              r.program_id AS program_id,
              rs.reservation_slot_id AS reservation_slot_id,
              rs.name AS reservation_slot_name,
              rs.description AS reservation_slot_description,
              rs.price AS reservation_slot_price,
              rs.currency AS reservation_slot_currency,
              rs.duration AS reservation_slot_duration,
              rs.location_id  AS location_id,
              l.name AS location_name,
              l.address_line_1 AS location_address_line_1,
              l.address_line_2 AS location_address_line_2,
              l.zip AS location_zip,
              l.city AS location_city,
              l.state  AS location_state,
              rd.reservation_date_id AS reservation_date_id,
              rd.status AS reservation_date_status,
              rd.date_time_from AS reservation_date_from,
              rd.date_time_to AS reservation_date_to
          FROM reservations r 
          INNER JOIN reservation_slots rs ON rs.reservation_id = r.reservation_id AND rs.blocked = FALSE AND rs.deleted_at IS NULL
          INNER JOIN reservation_dates rd ON rd.reservation_id  = r.reservation_id AND rd.reservation_slot_id = rs.reservation_slot_id AND rd.deleted_at IS NULL
          LEFT JOIN locations l ON rs.location_id = l.location_id AND l.deleted_at IS NULL
          INNER JOIN clients c ON c.client_id = r.client_id AND c.client_id = rd.client_id AND c.blocked = FALSE AND c.deleted_at IS NULL
          WHERE r.client_id = @client_id AND rd.reserved_by_user_id = @user_id AND 
            --rd.date_time_to > (NOW() - INTERVAL '1 days') AND 
            r.blocked = false AND r.deleted_at IS NULL
          ORDER BY rd.date_time_from DESC
        """
            .tidyCode();

        final sqlParams = {
          "user_id": session.userId,
          "client_id": clientId,
        };

        log.logSql(context, sql, sqlParams);

        return (await api.select(sql, params: sqlParams))
            .map((row) => UserReservation.fromMap(row, UserReservation.snake))
            .toList();
      });

  Future<List<Reservation>> listClient(String clientId) async => withSqlLog(context, () async {
        final sql = """
          SELECT
            r.reservation_id AS reservation_id,
            r.client_id AS client_id,
            r.name AS reservation_name,
            r.description AS reservation_description,
            r.rank AS reservation_rank,
            r.loyalty_mode AS reservation_loyalty_mode,
            r.program_id AS program_id,
            r.meta->'discount' AS reservation_discount,
            rs.reservation_slot_id AS reservation_slot_id,
            c.client_id AS client_id,
            rs.name AS reservation_slot_name,
            rs.description AS reservation_slot_description,
            rs.price AS reservation_slot_price,
            rs.currency AS reservation_slot_currency,
            rs.duration AS reservation_slot_duration,
            rs.location_id  AS location_id,
            rs.meta->'discount' AS slot_discount,
            l.name AS location_name,
            l.address_line_1 AS location_address_line_1,
            l.address_line_2 AS location_address_line_2,
            l.zip AS location_zip,
            l.city AS location_city,
            l.state AS location_state
          FROM reservations r
          INNER JOIN reservation_slots rs ON rs.reservation_id = r.reservation_id AND rs.blocked = FALSE AND rs.deleted_at IS NULL
          LEFT JOIN locations l ON rs.location_id = l.location_id AND l.deleted_at IS NULL
          INNER JOIN clients c ON r.client_id = c.client_id AND c.blocked = FALSE AND c.deleted_at IS NULL
          WHERE c.client_id = @client_id AND c.blocked = FALSE AND c.deleted_at IS NULL AND r.blocked = FALSE AND r.deleted_at IS NULL
          ORDER BY r.rank, r.name, rs.rank, rs.name
        """
            .tidyCode();

        final sqlParams = {"client_id": clientId};

        log.logSql(context, sql, sqlParams);

        final reservations = <Reservation>[];

        (await api.select(sql, params: sqlParams))
            .map((row) {
              final reservation = Reservation.fromMap(row, Reservation.snake2);
              Reservation? existing =
                  reservations.firstWhereOrNull((r) => r.reservationId == reservation.reservationId);
              if (existing == null) {
                reservations.add(reservation);
                existing = reservation;
              }
              final slot = ReservationSlot.fromMap(row, ReservationSlot.snake2);
              existing.reservationSlots.add(slot);
              return existing;
            })
            .cast<Reservation>()
            .toList();

        return reservations;
      });
}

// eof
