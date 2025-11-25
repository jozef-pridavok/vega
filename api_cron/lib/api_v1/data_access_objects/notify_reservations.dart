import "package:collection/collection.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

enum NotifyReservationsInterval {
  min15,
  min30,
  hour1,
  hour2,
  hour4,
  hour8,
  day1,
  day2,
  day3,
  day4,
}

extension NotifyReservationsIntervalExtensions on NotifyReservationsInterval {
  static final _tokens = {
    NotifyReservationsInterval.min15: "token:15m",
    NotifyReservationsInterval.min30: "token:30m",
    NotifyReservationsInterval.hour1: "token:1h",
    NotifyReservationsInterval.hour2: "token:2h",
    NotifyReservationsInterval.hour4: "token:4h",
    NotifyReservationsInterval.hour8: "token:8h",
    NotifyReservationsInterval.day1: "token:1d",
    NotifyReservationsInterval.day2: "token:2d",
    NotifyReservationsInterval.day3: "token:3d",
    NotifyReservationsInterval.day4: "token:4d",
  };

  String get token => _tokens[this]!;

  static final _sqlIntervals = {
    NotifyReservationsInterval.min15: "15 minutes",
    NotifyReservationsInterval.min30: "30 minutes",
    NotifyReservationsInterval.hour1: "1 hour",
    NotifyReservationsInterval.hour2: "2 hours",
    NotifyReservationsInterval.hour4: "4 hours",
    NotifyReservationsInterval.hour8: "8 hours",
    NotifyReservationsInterval.day1: "1 day",
    NotifyReservationsInterval.day2: "2 days",
    NotifyReservationsInterval.day3: "3 days",
    NotifyReservationsInterval.day4: "4 days",
  };

  String get sqlInterval => _sqlIntervals[this]!;
}

class NotifyReservationsDAO extends ApiServerDAO {
  final NotifyReservationsInterval interval;
  final ApiServerContext context;

  NotifyReservationsDAO(this.interval, this.context) : super(context.api);

  Future<JsonObject> notify() async => withSqlLog(context, () async {
        final token = interval.token;
        final sqlInterval = interval.sqlInterval;
        final sql = """
            WITH user_timezones AS (
              SELECT DISTINCT ON (rd.reserved_by_user_id)
                rd.reserved_by_user_id,
                COALESCE(i.device_info->>'timeZoneOffset', '0')::int as user_timezone_offset
              FROM reservation_dates rd
              LEFT JOIN installations i ON rd.reserved_by_user_id = i.user_id
              WHERE i.deleted_at IS NULL
            )
            SELECT 
                rd.reservation_date_id, rd.reservation_slot_id, rd.date_time_from AS date_time_from, rd.date_time_to AS date_time_to, 
                u.user_id AS user_id, u.language AS user_language, u.email AS user_email,
                rs.name AS reservation_slot_name, rs.description AS reservation_slot_description, rs.price AS reservation_slot_price,  rs.currency AS reservation_slot_currency,
                l.location_id, l.name AS location_name, l.description AS location_description, l.address_line_1 AS location_address_line_1, l.address_line_2 AS location_address_line_2, l.city AS location_city, l.zip AS location_zip, l.state AS location_state, l.country AS location_country,
                l.phone AS location_phone, l.email AS location_email,
                r.name AS reservation_name, r.description AS reservation_description,
                c.name AS client_name, c.logo AS client_logo, c.updated_at AS client_updated_at
                """
            // rd.meta->>('token:2d:' || u.user_id || ':v') AS token,
            // rd.meta->>('token:2d:' || u.user_id || ':s') AS token_sent_at,
            // rd.meta->>('token:2d:' || u.user_id || ':e') AS token_expiration
            """
            FROM reservation_dates rd
            JOIN user_timezones ut ON rd.reserved_by_user_id = ut.reserved_by_user_id
            INNER JOIN reservation_slots rs ON rd.reservation_slot_id = rs.reservation_slot_id AND rs.deleted_at IS NULL
            INNER JOIN reservations r ON rd.reservation_id = r.reservation_id AND rs.reservation_id = r.reservation_id AND r.deleted_at IS NULL
            INNER JOIN clients c ON r.client_id = c.client_id AND r.client_id = c.client_id AND rs.client_id = c.client_id AND rd.client_id = c.client_id AND c.deleted_at IS NULL
            INNER JOIN users u ON rd.reserved_by_user_id = u.user_id AND u.deleted_at IS NULL
            LEFT JOIN locations l ON rs.location_id = l.location_id AND rs.client_id = l.client_id AND l.deleted_at IS NULL
            WHERE 
              rd.status = ${ReservationDateStatus.available.code} AND
              rd.meta->>('$token:' || u.user_id || ':s') IS NULL AND
              rd.deleted_at IS NULL
              AND (
                -- Konvertujeme server čas na užívateľov lokálny čas a porovnávame s reservation_date
                rd.date_time_from AT TIME ZONE 'UTC' + (ut.user_timezone_offset || ' seconds')::interval 
                BETWEEN 
                  (NOW() AT TIME ZONE 'UTC' + (ut.user_timezone_offset || ' seconds')::interval)
                  AND 
                  (NOW() AT TIME ZONE 'UTC' + (ut.user_timezone_offset || ' seconds')::interval + INTERVAL '$sqlInterval')
              )
            ORDER BY rd.date_time_from;
          """;

        log.logSql(context, sql);

        final rows = await api.select(sql);
        if (rows.isEmpty) return {"total": 0, "message": "No reservations to notify"};

        log.verbose("Notifying ${rows.length} reservations");

        final notify = rows
            .map((row) => {
                  "reservationDateId": row["reservation_date_id"],
                  "userId": row["user_id"],
                  "userEmail": row["user_email"],
                  "userLanguage": row["user_language"],
                  "dateFrom": row["date_time_from"].toString(),
                  "dateTo": row["date_time_to"].toString(),
                  "clientLogo": row["client_logo"],
                  "clientName": row["client_name"],
                  "clientUpdatedAt": row["client_updated_at"].toString(),
                  "locationId": row["location_id"],
                  "locationName": row["location_name"],
                  "locationDescription": row["location_description"],
                  "locationAddressLine1": row["location_address_line_1"],
                  "locationAddressLine2": row["location_address_line_2"],
                  "locationCity": row["location_city"],
                  "locationZip": row["location_zip"],
                  "locationState": row["location_state"],
                  "locationCountry": row["location_country"],
                  "locationPhone": row["location_phone"],
                  "locationEmail": row["location_email"],
                }.. // Remove null values
                    removeWhere((key, value) => value == null))
            .toList();

        {
          String sql = """
              UPDATE reservation_dates
              SET meta = COALESCE(meta, '{}'::JSONB) 
                  || jsonb_build_object('$token:' || reserved_by_user_id || ':s', NOW()::TEXT)
                  || jsonb_build_object('$token:' || reserved_by_user_id || ':v', GEN_RANDOM_UUID()::TEXT)
                  || jsonb_build_object('$token:' || reserved_by_user_id || ':e', (NOW() + INTERVAL '$sqlInterval')::TEXT)
              WHERE reservation_date_id = ANY(@reservation_date_ids)
          """;

          final sqlParams = {
            "reservation_date_ids": rows.map((row) => row["reservation_date_id"]).toList(),
          };

          log.logSql(context, sql, sqlParams);

          final updated = await api.update(sql, params: sqlParams);
          log.verbose("Updated $updated reservation dates");

          sql = """
              SELECT reservation_date_id, meta->>('$token:' || reserved_by_user_id || ':v') AS token
              FROM reservation_dates
              WHERE reservation_date_id = ANY(@reservation_date_ids)
          """;

          log.logSql(context, sql, sqlParams);

          final result = await api.select(sql, params: sqlParams);

          for (final n in notify) {
            final row = result.firstWhereOrNull((row) => row["reservation_date_id"] == n["reservationDateId"]);
            if (row != null) n["token"] = row["token"];
          }
        }

        return {"total": rows.length, "notify": notify};
      });
}

// eof
