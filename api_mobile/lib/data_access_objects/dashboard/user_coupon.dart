import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";

class UserCouponDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  UserCouponDAO(this.session, this.context) : super(context.api);

  Future<UserCoupon?> select(String userCouponId) async => withSqlLog(context, () async {
        final sql = """
          SELECT * 
          FROM user_coupons
          WHERE user_coupon_id = @user_coupon_id
        """;

        final sqlParams = <String, dynamic>{"user_coupon_id": userCouponId};

        log.logSql(context, sql, sqlParams);

        final userCoupons = await api.select(sql, params: sqlParams);
        final dataObject = userCoupons.firstOrNull;
        return dataObject != null ? UserCoupon.fromMap(dataObject, Convention.snake) : null;
      });

  Future<List<UserCoupon>> selectUserCoupons(String clientId,
          {int? period, String? filter, int? type, String? couponId}) async =>
      withSqlLog(context, () async {
        final hasFilter = filter != null && filter.isNotEmpty;
        final sql = """
          SELECT uc.user_coupon_id, uc.user_id, uc.coupon_id, uc.client_id, uc.expires_at, 
            uc.redeemed_at, uc.redeemed_by_pos_id, u.nick AS user_nick, c.name,
            c.description, c.type, c.valid_from, c.valid_to
          FROM user_coupons uc
          INNER JOIN users u ON uc.user_id = u.user_id
          INNER JOIN coupons c ON c.coupon_id = uc.coupon_id
          WHERE uc.client_id = @client_id
            ${type != null ? 'AND c.type = @type ' : ''}
            ${couponId != null ? 'AND uc.coupon_id = @coupon_id ' : ''}
            ${period != null && period > 0 ? 'AND uc.redeemed_at > NOW() - (@period::TEXT || \' days\')::INTERVAL ' : ''}
            ${hasFilter ? 'AND (' : ''}
            ${hasFilter ? 'c.name ILIKE \'%\' || @filter || \'%\' ' : ''}
            ${hasFilter ? 'OR c.description ILIKE \'%\' || @filter || \'%\' ' : ''}
            ${hasFilter ? 'OR u.nick ILIKE \'%\' || @filter || \'%\' ' : ''}
            ${hasFilter ? ') ' : ''}
          ORDER BY uc.redeemed_at DESC, uc.updated_at DESC, uc.created_at DESC
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "client_id": clientId,
          if (type != null) "type": type,
          if (period != null && period > 0) "period": period,
          if (hasFilter) "filter": filter,
          if (couponId != null) "coupon_id": couponId,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => UserCoupon.fromMap(row, Convention.snake)).toList();
      });

  Future<(int, String)> issue(String couponId, String userId) async => withSqlLog(context, () async {
        final sql = """
          INSERT INTO user_coupons (user_coupon_id, coupon_id, user_id, client_id, 
            expires_at, created_at
          )
          SELECT @user_coupon_id::VARCHAR, @coupon_id::VARCHAR, @user_id::VARCHAR, @client_id::VARCHAR, 
            COALESCE(c.valid_to, TO_CHAR(NOW() + INTERVAL '30 days', 'YYYYMMDD')::INT), NOW()
          FROM coupons c
          WHERE c.coupon_id = @coupon_id AND c.client_id = @client_id AND c.deleted_at IS NULL AND c.blocked = FALSE
        """
            .tidyCode();

        final userCouponId = uuid();

        final sqlParams = <String, dynamic>{
          "user_coupon_id": userCouponId,
          "coupon_id": couponId,
          "user_id": userId,
          "client_id": session.clientId
        };

        log.logSql(context, sql, sqlParams);

        return (await api.insert(sql, params: sqlParams), userCouponId);
      });

  Future<int> redeem(String userCouponId, String redeemedByUserId) async => withSqlLog(context, () async {
        final sql = """
          UPDATE user_coupons
            SET redeemed_at = NOW(), 
                updated_at = NOW(), 
                redeemed_by_user_id = @redeemed_by_user_id      
          WHERE 
            user_coupon_id = @user_coupon_id AND client_id = @client_id 
            AND redeemed_at IS NULL AND expires_at > intDateNow()
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "user_coupon_id": userCouponId,
          "redeemed_by_user_id": redeemedByUserId,
          "client_id": session.clientId
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof


// eof
