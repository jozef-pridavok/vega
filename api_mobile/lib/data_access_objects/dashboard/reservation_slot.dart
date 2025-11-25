import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";

class ReservationSlotDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  ReservationSlotDAO(this.session, this.context) : super(context.api);

  Future<List<ReservationSlot>> list({
    required String reservationId,
    required int filter,
    String? search,
    int? limit,
  }) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT rs.reservation_slot_id, rs.client_id, rs.reservation_id, rs.location_id, rs.name,
            rs.description, rs.image, rs.image_bh, rs.rank, rs.price, rs.currency, rs.duration, rs.color, rs.blocked, rs.meta
          FROM reservation_slots rs
          INNER JOIN clients c ON c.client_id = rs.client_id
          WHERE rs.reservation_id = @reservation_id AND rs.client_id = @client_id AND c.blocked IS FALSE
          ${filter == 1 ? "AND rs.deleted_at IS NULL " : "AND rs.deleted_at IS NOT NULL "}
          ${(search?.isNotEmpty ?? false) ? "AND (rs.name ILIKE @search OR rs.description ILIKE @search) " : ""}
          ORDER BY rs.rank, rs.name
          ${limit != null ? "LIMIT $limit" : ""}
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "reservation_id": reservationId,
          "client_id": session.clientId,
          if ((search?.isNotEmpty ?? false)) "search": "%$search%",
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows
            .map<ReservationSlot>(
                (row) => ReservationSlot.fromMap(row, ReservationSlot.snake, reservationDatesMap: row))
            .toList();
      });

  Future<int> insert(ReservationSlot reservationSlot) async => withSqlLog(context, () async {
        final sql = """
          INSERT INTO reservation_slots (
            reservation_slot_id, client_id, reservation_id, name, color,
            ${reservationSlot.locationId != null ? 'location_id, ' : ''}
            ${reservationSlot.description != null ? 'description, ' : ''} 
            ${reservationSlot.image != null ? 'image, ' : ''}
            ${reservationSlot.imageBh != null ? 'image_bh, ' : ''}
            ${reservationSlot.price != null ? 'price, ' : ''}
            ${reservationSlot.currency != null ? 'currency, ' : ''}
            ${reservationSlot.duration != null ? 'duration, ' : ''}
            ${reservationSlot.meta != null ? 'meta, ' : ''}
            created_at
          ) VALUES(
            @reservation_slot_id, @client_id, @reservation_id, @name, @color,
            ${reservationSlot.locationId != null ? '@location_id, ' : ''}
            ${reservationSlot.description != null ? '@description, ' : ''} 
            ${reservationSlot.image != null ? '@image, ' : ''}
            ${reservationSlot.imageBh != null ? '@image_bh, ' : ''}
            ${reservationSlot.price != null ? '@price, ' : ''}
            ${reservationSlot.currency != null ? '@currency, ' : ''}
            ${reservationSlot.duration != null ? '@duration, ' : ''}
            ${reservationSlot.meta != null ? '@meta, ' : ''}
            NOW()
          )
        """
            .tidyCode();

        final sqlParams = reservationSlot.toMap(ReservationSlot.snake);

        log.logSql(context, sql, sqlParams);

        final inserted = await api.insert(sql, params: sqlParams);
        return inserted;
      });

  Future<int> update(ReservationSlot reservationSlot) async => withSqlLog(context, () async {
        final sql = """
          UPDATE reservation_slots SET
            name = @name, color = @color,
            ${reservationSlot.locationId != null ? 'location_id = @location_id, ' : ''}
            ${reservationSlot.description != null ? 'description = @description, ' : ''} 
            ${reservationSlot.image != null ? 'image = @image, ' : ''}
            ${reservationSlot.imageBh != null ? 'image_bh = @image_bh, ' : ''}
            ${reservationSlot.price != null ? 'price = @price, ' : ''}
            ${reservationSlot.currency != null ? 'currency = @currency, ' : ''}
            ${reservationSlot.duration != null ? 'duration = @duration, ' : ''}
            ${reservationSlot.meta != null ? 'meta = @meta, ' : ''} 
            updated_at = NOW()
          WHERE reservation_slot_id = @reservation_slot_id AND client_id = @client_id AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = reservationSlot.toMap(ReservationSlot.snake);

        log.logSql(context, sql, sqlParams);

        final updated = await api.update(sql, params: sqlParams);
        return updated;
      });

  Future<int> patch(String reservationSlotId, {bool? blocked, bool? archived}) async => withSqlLog(context, () async {
        final sql = """
          UPDATE reservation_slots SET
            ${blocked != null ? 'blocked = @blocked, ' : ''}
            ${archived == true ? 'deleted_at = NOW(), ' : ''}
            ${archived == false ? 'deleted_at = NULL, ' : ''}
            updated_at = NOW()
          WHERE client_id = @client_id AND reservation_slot_id = @reservation_slot_id
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "reservation_slot_id": reservationSlotId,
          "client_id": session.clientId,
          if (blocked != null) "blocked": (blocked ? 1 : 0),
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> reorder(List<String> slotIds) async => withSqlLog(context, () async {
        final sql = """
          UPDATE reservation_slots
          SET rank = array_position(@slots_ids, reservation_slot_id),
              updated_at = NOW()
          WHERE client_id = @client_id AND reservation_slot_id = ANY(@slots_ids)
        """
            .tidyCode();

        final sqlParams = {"client_id": session.clientId, "slots_ids": slotIds};

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
