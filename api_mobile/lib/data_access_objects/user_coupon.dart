import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../data_models/session.dart";

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

  Future<int> redeem(String userId, String userCouponId) async => withSqlLog(context, () async {
        final sql = """
          UPDATE user_coupons
          SET redeemed_at = NOW(), 
              updated_at = NOW(), 
              redeemed_by_user_id = @user_id      
          WHERE user_id = @user_id 
            AND user_coupon_id = @user_coupon_id
            AND redeemed_at IS NULL 
            AND expires_at > intDateNow()
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"user_id": userId, "user_coupon_id": userCouponId};

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
  
