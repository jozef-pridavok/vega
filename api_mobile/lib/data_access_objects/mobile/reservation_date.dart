import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../cache.dart";
import "../../data_models/session.dart";
import "../user_coupon.dart";

class ReservationDateDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  ReservationDateDAO(this.session, this.context) : super(context.api);

  Future<List<ReservationDate>> selectMonth({
    required DateTime dateOfMonth,
    required String reservationSlotId,
    int? limit,
  }) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT rd.reservation_date_id, rd.client_id, rd.reservation_id, rd.reservation_slot_id,
            rd.reserved_by_user_id, rd.status, rd.date_time_from, rd.date_time_to, rd.meta
          FROM reservation_dates rd
          WHERE rd.deleted_at IS NULL AND rd.reservation_slot_id = @reservation_slot_id 
            AND rd.reserved_by_user_id IS NULL
            AND EXTRACT(MONTH FROM date_time_from) = EXTRACT(MONTH FROM @date_of_month::timestamp)
          ${limit != null ? "LIMIT $limit" : ""}
          ORDER BY date_time_from
        """
            .tidyCode();

        final sqlParams = {
          "reservation_slot_id": reservationSlotId,
          "date_of_month": dateOfMonth,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => ReservationDate.fromMap(row, ReservationDate.snake)).toList();
      });

  Future<(int patched, int redeemed, bool credited)> patchReservation(
    String reservationDateId, {
    required bool confirm,
    String? userCouponId,
    bool useCredit = false,
    String? cardId,
    String? userCardId,
  }) async =>
      withSqlLog(context, () async {
        int redeemed = 0;
        bool credited = false;

        if (confirm && userCouponId != null) {
          redeemed = await UserCouponDAO(session, context).redeem(session.userId, userCouponId);
          if (redeemed != 1) return (0, 0, false);
        }

        ReservationDateStatus status = ReservationDateStatus.available;
        if (useCredit) {
          credited = await _useCredit(reservationDateId, cardId, userCardId);
          if (!credited) return (0, 0, false);
          status = ReservationDateStatus.confirmed;
        }

        final sql = """
          UPDATE reservation_dates 
          SET
            ${confirm ? 'reserved_by_user_id = @user_id, status = ${status.code}, ' : 'reserved_by_user_id = NULL, status=${ReservationDateStatus.available.code}, '}
            updated_at = NOW()
          WHERE reservation_date_id = @reservation_date_id AND
            ${confirm ? 'reserved_by_user_id IS NULL AND status = ${ReservationDateStatus.available.code}' : 'reserved_by_user_id  = @user_id'}
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "user_id": session.userId,
          "reservation_date_id": reservationDateId,
        };

        log.logSql(context, sql, sqlParams);

        return (await api.update(sql, params: sqlParams), redeemed, credited);
      });

  Future<bool> _useCredit(String reservationDateId, String? cardId, String? userCardId) async =>
      withSqlLog(context, () async {
        String sql = """
          SELECT r.program_id, c.client_id, r.meta->'discount' AS reservation_discount, rs.meta->'discount' AS slot_discount, rs.price, lts.points
          FROM reservation_dates rd
          INNER JOIN reservations r ON rd.reservation_id = r.reservation_id
          INNER JOIN reservation_slots rs ON rd.reservation_slot_id = rs.reservation_slot_id AND rs.reservation_id = r.reservation_id 
          INNER JOIN clients c ON r.client_id = c.client_id 
          INNER JOIN view_loyalty_transaction_status lts ON r.program_id = lts.program_id
          WHERE reservation_date_id = @reservation_date_id AND lts.user_id = @user_id
        """
            .tidyCode();

        Map<String, dynamic> sqlParams = {
          "reservation_date_id": reservationDateId,
          "user_id": session.userId,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) return false;

        final row = rows.first;
        final programId = row["program_id"] as String;
        final clientId = row["client_id"] as String;
        final reservationDiscount = row["reservation_discount"] as int?;
        final slotDiscount = row["slot_discount"] as int?;
        final price = row["price"] as int?;
        final points = row["points"] as int;

        final discount = reservationDiscount ?? slotDiscount ?? 0;
        if (discount <= 0 || price == null) return false;

        final discountedPrice = (price * (1.0 - (discount / 100.0))).round();

        if (points - discountedPrice < 0) return false;

        sql = """
          INSERT INTO loyalty_transactions
            (loyalty_transaction_id, client_id, card_id, program_id, user_id, user_card_id, 
              points, transaction_object_type, transaction_object_id, created_at, updated_at)
          VALUES 
            (@loyalty_transaction_id, @client_id, @card_id, @program_id, @user_id, @user_card_id, 
              @points, @object_type, @object_id, NOW(), NOW())
        """
            .tidyCode();

        sqlParams = {
          "loyalty_transaction_id": uuid(),
          "client_id": clientId,
          "card_id": cardId,
          "program_id": programId,
          "user_id": session.userId,
          "user_card_id": userCardId,
          "points": -discountedPrice,
          "object_type": LoyaltyTransactionObjectType.reservation.code,
          "object_id": reservationDateId,
        };

        log.logSql(context, sql, sqlParams);

        final inserted = await api.insert(sql, params: sqlParams);

        if (inserted == 1) {
          await Cache().clear(api.redis, CacheKeys.userUserCards(session.userId));
          if (userCardId != null) {
            await Cache().clear(api.redis, CacheKeys.userUserCard(session.userId, userCardId));
          }
        }

        return inserted == 1;
      });
}

// eof
