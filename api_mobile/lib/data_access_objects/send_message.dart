import "package:core_dart/core_api_server.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:shelf/shelf.dart";

import "../data_models/session.dart";
import "../strings.dart";
import "../utils/send_message.dart";
import "../utils/storage.dart";

class SendMessage extends ApiServerDAO {
  final ApiServerContext context;

  SendMessage(this.context) : super(context.api);

  Future<void> sendUserCouponMessage(Request request, Session session, String userCouponId, ActionType action) async =>
      withSqlLog(context, () async {
        final sql = """
            SELECT u.user_id, u.language AS user_language,
              c.coupon_id, c.name AS coupon_name, c.image AS coupon_image, c.image_bh AS coupon_image_bh, c.updated_at AS coupon_updated_at,
              cl.client_id, cl.name AS client_name, cl.logo AS client_logo, cl.logo_bh AS client_logo_bh, cl.updated_at AS client_updated_at
            FROM user_coupons uc
            INNER JOIN users u ON uc.user_id = u.user_id AND u.deleted_at IS NULL
            JOIN coupons c ON uc.coupon_id = c.coupon_id
            JOIN clients cl ON uc.client_id = cl.client_id
            WHERE uc.user_coupon_id = @user_coupon_id
          """
            .tidyCode();

        final sqlParams = {"user_coupon_id": userCouponId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) throw "User coupon not found: $userCouponId";

        final row = rows.first;
        final userId = row["user_id"] as String;
        final userLanguage = row["user_language"] as String;
        final couponId = row["coupon_id"] as String;
        final couponName = row["coupon_name"] as String;
        final couponImage = row["coupon_image"] as String;
        final couponImageBh = row["coupon_image_bh"] as String;
        final couponUpdatedAt = tryParseDateTime(row["coupon_updated_at"]);
        final clientId = row["client_id"] as String;
        final clientName = row["client_name"] as String;
        final clientLogo = row["client_logo"] as String;
        final clientLogoBh = row["client_logo_bh"] as String;
        final clientUpdatedAt = tryParseDateTime(row["client_updated_at"]);

        final messageKeys = {
          ActionType.userCouponCreated: LangKeys.messageCouponHasBeenIssuedToYou.tr(),
          ActionType.userCouponRedeemed: LangKeys.messageCouponHasBeenRedeemed.tr(),
        };

        final messageKey = messageKeys[action];
        if (messageKey == null) throw "Message key not found for action $action";

        await sendMessageToUser(
          api,
          session,
          messageTypes: [MessageType.pushNotification, MessageType.inApp],
          userId: userId,
          subject: couponName,
          body: api.tr(userLanguage, messageKey, args: [couponName]),
          payload: {
            "action": action.code.toString(),
            "clientId": clientId,
            "clientName": clientName,
            "clientLogo": api.storageUrl(clientLogo, StorageObject.client, timeStamp: clientUpdatedAt),
            "clientLogoBh": clientLogoBh,
            "couponId": couponId,
            "couponName": couponName,
            "couponImage": api.storageUrl(couponImage, StorageObject.coupon, timeStamp: couponUpdatedAt),
            "couponImageBh": couponImageBh,
          },
        );
      });
}

// eof
