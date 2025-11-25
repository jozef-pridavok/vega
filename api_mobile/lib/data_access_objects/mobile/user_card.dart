import "dart:convert";
import "dart:math" as math;

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";
import "../../utils/storage.dart";
import "../emit_card.dart";

class UserCardDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  UserCardDAO(this.session, this.context) : super(context.api);

  Future<List<UserCard>?> _select({String? userCardId}) async => withSqlLog(context, () async {
        final sql = """
          SELECT
            uc.user_card_id, uc.user_id, uc.card_id, uc.client_id, uc.code_type, uc.number, uc.name, uc.notes, 
            uc.logo, uc.logo_bh, uc.color AS color,
            uc.front, uc.front_bh, uc.back, uc.back_bh,
            c.name AS client_name, c.logo AS client_logo, c.logo_bh AS client_logo_bh, c.color AS client_color,
            cc.name AS card_name, cc.logo AS card_logo, cc.logo_bh AS card_logo_bh, cc.color AS card_color,
            cc.updated_at AS card_updated_at, c.updated_at AS client_updated_at,
            (SELECT COUNT(*) FROM reservation_dates AS rd WHERE rd.client_id = uc.client_id AND rd.reserved_by_user_id = uc.user_id) AS reservations_count,
            (SELECT COUNT(*) FROM reservations AS r WHERE r.client_id = uc.client_id AND r.blocked = FALSE AND r.deleted_at IS NULL) AS eligible_reservations_count,
            (SELECT COUNT(*) FROM product_offers AS pof WHERE pof.client_id = uc.client_id AND pof.blocked = FALSE AND pof.deleted_at IS NULL) AS offers_count,        
            (SELECT COUNT(*) FROM product_orders AS por WHERE por.client_id = uc.client_id AND por.user_id = uc.user_id) AS orders_count,
            (SELECT COUNT(*) FROM receipts AS rc WHERE rc.user_card_id = uc.user_card_id) AS receipts_count,
            (SELECT COUNT(*) FROM leaflets AS lf WHERE lf.client_id = uc.client_id AND LOWER(lf.country) = LOWER(u.country)) AS leaflets_count,
            TO_JSON(ARRAY(
              SELECT json_build_object(
                'user_coupon_id', ucp.user_coupon_id, 'coupon_id', ucp.coupon_id, 'coupon_type', cp.type,
                'expires_at', ucp.expires_at, 
                'name', cp.name, 'description', cp.description, 'discount', cp.discount, 
                'image', cp.image, 'image_bh', cp.image_bh,
                'type', cp.type,
                'code', COALESCE(ucp.meta->>'code', cp.code), 'valid_from',  cp.valid_from, 'valid_to', COALESCE(ucp.expires_at, cp.valid_to),
                'location_id', l.location_id, 'location_name', l.name, 'location_address_line_1', l.address_line_1, 'location_address_line_2', l.address_line_2, 'location_city', l.city
              )
              FROM user_coupons AS ucp
              INNER JOIN coupons AS cp ON ucp.coupon_id = cp.coupon_id AND cp.client_id = uc.client_id 
                AND cp.valid_from <= intDateNow() AND COALESCE(cp.valid_to >= intDateNow(), TRUE)
                AND cp.deleted_at IS NULL AND cp.blocked = FALSE
              LEFT JOIN locations l ON l.location_id = cp.location_id
              WHERE ucp.user_id = uc.user_id AND ucp.client_id = uc.client_id AND ucp.redeemed_at IS NULL AND ucp.expires_at >= intDateNow()
              ORDER BY ucp.created_at DESC
            )) AS user_coupons,	
            TO_JSON(ARRAY(
              SELECT json_build_object(
                'program_id', p.program_id, 'name', p.name, 
                'plural', COALESCE((p.meta->>'plural')::JSONB, '{}'::JSONB), 
                'type', p.type,  
                'user_points', (
                  SELECT COALESCE(SUM(lt.points), 0)
                  FROM loyalty_transactions lt
                  WHERE lt.user_card_id = uc.user_card_id AND lt.program_id = p.program_id
                ),
                'digits', p.digits,
                'last_location_id', MIN(lt.location_id),
                'last_location_name', MIN(lt.name),
                'last_transaction_date', MIN(lt.created_at)
                )
                FROM programs AS p
                LEFT JOIN (
                  SELECT program_id, location_id, ilt.created_at, name
                  FROM loyalty_transactions ilt
                  LEFT JOIN locations USING (location_id)
                  WHERE user_card_id = uc.user_card_id
                  ORDER BY created_at DESC
                  LIMIT 1
                ) AS lt ON p.program_id = lt.program_id
              WHERE p.client_id = uc.client_id AND p.card_id = uc.card_id 
                AND p.valid_from <= intDateNow() AND COALESCE(p.valid_to >= intDateNow(), TRUE)
                AND p.deleted_at IS NULL AND p.blocked = FALSE
              GROUP BY p.program_id
            )) AS programs,
            (
              SELECT x.* FROM (SELECT ROW_TO_JSON(row) 
                FROM (
                    SELECT po.product_order_id AS order_id, po.product_offer_id AS offer_id, po.client_id, po.user_card_id, 
                      po.created_at, po.updated_at, po.total_price, po.total_price_currency, po.delivery_type,
                      u.user_id, u.nick AS user_nickname, uc.client_id,
                      po.status, po.cancelled_reason, po.cancelled_at
                    FROM product_orders AS po
                    WHERE po.client_id = uc.client_id AND po.user_id = uc.user_id
                    ORDER BY po.created_at DESC
                    LIMIT 1
                  ) AS row
              ) x
            )  AS last_product_order
          FROM user_cards uc
          INNER JOIN users u ON uc.user_id = u.user_id
          LEFT JOIN clients c ON c.client_id = uc.client_id
          LEFT JOIN cards cc ON cc.card_id = uc.card_id
          WHERE 
            ${userCardId != null ? "uc.user_card_id = @user_card_id AND" : ""}
            uc.user_id = @user_id AND uc.deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "user_id": session.userId,
          if (userCardId != null) "user_card_id": userCardId,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) return null;

        return rows.map((row) {
          final userCard = UserCard.fromMap(row, Convention.snake);

          final userUpdatedAt = tryParseDateTime(row["user_updated_at"]);
          final cardUpdatedAt = tryParseDateTime(row["card_updated_at"]);
          final clientUpdatedAt = tryParseDateTime(row["client_updated_at"]);

          final userCardLogo = api.storageUrl(row["logo"] as String?, StorageObject.user, timeStamp: userUpdatedAt);

          final cardLogo = api.storageUrl(row["card_logo"] as String?, StorageObject.card, timeStamp: cardUpdatedAt);
          final cardLogoBh = cast<String>(row["card_logo_bh"]);

          final clientLogo =
              api.storageUrl(row["client_logo"] as String?, StorageObject.client, timeStamp: clientUpdatedAt);
          final clientLogoBh = cast<String>(row["client_logo_bh"]);

          final color = Color.fromHexOrNull(cast<String>(row["color"]));
          final cardColor = Color.fromHexOrNull(cast<String>(row["card_color"]));
          final clientColor = Color.fromHexOrNull(cast<String>(row["client_color"]));

          return userCard.copyWith(
            color: color ?? cardColor ?? clientColor,
            logo: userCardLogo ?? cardLogo ?? clientLogo,
            logoBh: cast<String>(row["logo_bh"]) ?? cardLogoBh ?? clientLogoBh,
            front: api.storageUrl(row["front"] as String?, StorageObject.user, timeStamp: userUpdatedAt),
            back: api.storageUrl(row["back"] as String?, StorageObject.user, timeStamp: userUpdatedAt),
            userCoupons: userCard.userCoupons?.map((userCoupon) {
              return userCoupon.copyWith(
                image: api.storageUrl(userCoupon.image, StorageObject.coupon),
              );
            }).toList(),
          );
        }).toList();
      });

  Future<List<UserCard>?> selectAll() async => withSqlLog(context, () async {
        return await _select();
      });

  Future<UserCard?> select(String userCardId) async => withSqlLog(context, () async {
        final userCards = await _select(userCardId: userCardId);
        return userCards?.firstOrNull;
      });

  Future<int> delete(String userCardId) async => withSqlLog(context, () async {
        final sql = """
          UPDATE user_cards
          SET deleted_at = NOW()
          WHERE user_id = @user_id AND user_card_id = @user_card_id AND deleted_at IS NULL
        """;

        final sqlParams = <String, dynamic>{
          "user_id": session.userId,
          "user_card_id": userCardId,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<String?> issue(String clientId, String? cardId, {Map<String, dynamic>? meta}) async =>
      withSqlLog(context, () async {
        final emitCard = EmitCardDAO(context);
        return await emitCard.emitNewUserCard(clientId, cardId, session.userId, meta: meta);
      });

  Future<UserCard?> userCardByClient(String clientId) async => withSqlLog(context, () async {
        final sql = """
          SELECT * FROM user_cards
          INNER JOIN cards ON cards.card_id = user_cards.card_id
          INNER JOIN clients ON clients.client_id = cards.client_id
          WHERE user_cards.user_id = @user_id AND user_cards.deleted_at IS NULL AND cards.blocked = FALSE             
              AND clients.client_id = @client_id AND clients.blocked = FALSE AND COALESCE((user_cards.meta->'userAdded')::BOOL, FALSE) = FALSE
          ORDER BY user_cards.created_at DESC
          LIMIT 1
        """;

        final sqlParams = <String, dynamic>{"user_id": session.userId, "client_id": clientId};

        log.logSql(context, sql, sqlParams);

        final row = (await api.select(sql, params: sqlParams)).firstOrNull;
        if (row == null) return null;

        return UserCard.fromMap(row, Convention.snake);
      });

  Future<UserCard?> userCardByMeta(ReceiptProvider provider, String id) async => withSqlLog(context, () async {
        final sql = """
          SELECT user_cards.* FROM user_cards
          INNER JOIN cards ON cards.card_id = user_cards.card_id
          INNER JOIN clients ON clients.client_id = cards.client_id
          WHERE user_cards.user_id = @user_id AND user_cards.deleted_at IS NULL
            AND cards.blocked = FALSE AND clients.blocked = FALSE
            AND (clients.meta->'qrCodeScanning'->>'provider')::INT = @provider
            AND @id=ANY(jsonb_array_to_text_array((clients.meta->'qrCodeScanning'->>'providerId')::JSONB))
          ORDER BY user_cards.created_at DESC
          LIMIT 1
        """;

        final sqlParams = <String, dynamic>{"user_id": session.userId, "provider": provider.code, "id": id};

        log.logSql(context, sql, sqlParams);

        final row = (await api.select(sql, params: sqlParams)).firstOrNull;
        if (row == null) return null;

        return UserCard.fromMap(row, Convention.snake);
      });

  Future<Receipt?> addReceipt(String userCardId, Receipt? receipt) async => withSqlLog(context, () async {
        if (receipt == null) return null;

        var sql = """
          SELECT receipt_id FROM receipts
          WHERE user_id = @userId AND external_id = @externalId
        """;

        var sqlParams = <String, dynamic>{"userId": session.userId, "externalId": receipt.externalId};

        log.logSql(context, sql, sqlParams);

        final results = await api.select(sql, params: sqlParams);
        if (results.isNotEmpty) return null; // already exists

        sql = """
          INSERT INTO receipts 
            (receipt_id, client_id, user_id, user_card_id, purchased_at_time, purchased_at_place, 
              total_items, total_price, total_price_currency, items, external_id, created_at)
          VALUES 
            (@receiptId, @clientId, @userId, @userCardId, @purchasedAtTime, @purchasedAtPlace, 
              @totalItems, @totalPrice, @totalPriceCurrency, @items, @externalId, NOW())
        """;

        sqlParams = <String, dynamic>{
          "receiptId": receipt.receiptId,
          "clientId": receipt.clientId,
          "userId": session.userId,
          "userCardId": userCardId,
          "purchasedAtTime": receipt.purchasedAtTime,
          "purchasedAtPlace": receipt.purchasedAtPlace,
          "totalItems": receipt.totalItems,
          "totalPrice": receipt.totalPrice,
          "totalPriceCurrency": receipt.totalPriceCurrency.code,
          "items": jsonEncode(receipt.items),
          "externalId": receipt.externalId,
        };

        log.logSql(context, sql, sqlParams);

        final insertedReceipts = await api.insert(sql, params: sqlParams);
        if (insertedReceipts != 1) return null;

        return receipt;
      });

  Future<num?> addPoints(
    String userCardId,
    LoyaltyTransactionObjectType objectType,
    String objectId,
    JsonObject log,
    Currency currency,
    num? price,
  ) async =>
      withSqlLog(context, () async {
        if (price == null) return null;

        var sql = """
          SELECT receipt_id 
          FROM loyalty_transactions 
          WHERE transaction_object_type = @object_type AND transaction_object_id = @object_id AND points IS NOT NULL
        """;

        var sqlParams = <String, dynamic>{
          "object_type": objectType.code,
          "object_id": objectId,
        };

        api.log.logSql(context, sql, sqlParams);

        final results = await api.select(sql, params: sqlParams);
        if (results.isNotEmpty) return null; // already used for points

        sql = """
          SELECT programs.*, COALESCE((programs.meta->'qrCodeScanning'->>'ratio')::INT, 1) AS ratio
          FROM user_cards
          INNER JOIN programs ON programs.card_id = user_cards.card_id
          WHERE user_cards.user_card_id = @userCardId 
            AND programs.type IN (${ProgramType.collect.code}, ${ProgramType.reach.code})
            AND (programs.ending_at IS NULL OR programs.ending_at > NOW())
          ORDER BY programs.rank ASC
          LIMIT 1
        """;

        sqlParams = <String, dynamic>{"userCardId": userCardId};

        api.log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.length != 1) return null;
        final row = rows.first;

        num ratio = row["ratio"] as num;
        int digits = row["digits"] as int;
        num points = (currency.collapse(price) * ratio);
        if (digits == 0) {
          points = points.ceil();
        } else {
          // digits=1, 0.5 => 5
          // digits=1, 0.15 => 2
          // digits=2, 0.5 => 50
          points = (currency.collapse(price) * ratio) * math.pow(10, digits).ceil();
        }
        assert(digits == points.decimalPlaces);

        sql = """
          INSERT INTO loyalty_transactions
            (loyalty_transaction_id, client_id, card_id, program_id, user_id, user_card_id, 
              transaction_object_type, transaction_object_id, points, log)
          VALUES 
            (@loyaltyTransactionId, @clientId, @cardId, @programId, @userId, @userCardId, 
              @objectType, @objectId, @points, @log)
        """;

        sqlParams = <String, dynamic>{
          "loyaltyTransactionId": uuid(),
          "clientId": row["client_id"],
          "cardId": row["card_id"],
          "programId": row["program_id"],
          "userId": session.userId,
          "userCardId": userCardId,
          "objectType": objectType.code,
          "objectId": objectId,
          "points": points.toInt(),
          "log": log,
        };

        api.log.logSql(context, sql, sqlParams);

        final insertedTransactions = await api.insert(sql, params: sqlParams);
        if (insertedTransactions != 1) return null;

        return points;
      });

  Future<int> update(
    String userCardId,
    String userId, {
    int? codeType,
    String? number,
    String? name,
    String? notes,
    String? color,
  }) async =>
      withSqlLog(context, () async {
        final sql = """
          UPDATE user_cards
          SET code_type = COALESCE(@code_type, code_type), 
              number = COALESCE(@number, number), 
              name = COALESCE(@name, name), 
              notes = COALESCE(@notes, notes), 
              color = COALESCE(@color, color), 
              updated_at = NOW()
          WHERE user_card_id = @user_card_id AND user_id = @user_id AND deleted_at IS NULL
        """;

        final sqlParams = <String, dynamic>{
          "user_id": userId,
          "user_card_id": userCardId,
          "code_type": codeType,
          "number": number,
          "name": name,
          "notes": notes,
          "color": color,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> insert(UserCard userCard) async => withSqlLog(context, () async {
        final sql = """
          INSERT INTO user_cards
            (user_card_id, card_id, user_id, code_type, number, name, 
              notes, color, touched_at, created_at, updated_at)
          VALUES 
            (@user_card_id, @card_id, @user_id, @code_type, @number, 
              @name, @notes, @color, NOW(), NOW(), NOW())
        """;

        final sqlParams = <String, dynamic>{
          "user_id": userCard.userId,
          "user_card_id": userCard.userCardId,
          "code_type": userCard.codeType,
          "number": userCard.number,
          "name": userCard.name,
          "notes": userCard.notes,
          "color": userCard.color,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
