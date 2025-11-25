import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../cache.dart";
import "../../data_access_objects/emit_card.dart";
import "../../data_models/session.dart";
import "../../utils/storage.dart";
//import "../dashboard/user_card.dart";
import "user_card.dart";

enum CouponTakeResult {
  ok,
  couponNotFound,
  clientBlocked,
  manualCoupon,
  userAlreadyHasCoupon,
  clientHasNoDefaultCard,
  userCardNotCreated,
  arrayCouponHasNoCodes,
  failedToUpdateCouponCodes,
  userCouponNotInserted,
  userIssueLimitReached,
}

extension CouponTakeResultCode on CouponTakeResult {
  static final _couponTakeResultCodeMap = {
    CouponTakeResult.ok: 0,
    CouponTakeResult.couponNotFound: 1,
    CouponTakeResult.clientBlocked: 2,
    CouponTakeResult.manualCoupon: 3,
    CouponTakeResult.userAlreadyHasCoupon: 4,
    CouponTakeResult.clientHasNoDefaultCard: 5,
    CouponTakeResult.userCardNotCreated: 6,
    CouponTakeResult.arrayCouponHasNoCodes: 7,
    CouponTakeResult.failedToUpdateCouponCodes: 8,
    CouponTakeResult.userCouponNotInserted: 9,
    CouponTakeResult.userIssueLimitReached: 10,
  };
  int get code => _couponTakeResultCodeMap[this] ?? -1;
}

class CouponDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  CouponDAO(this.session, this.context) : super(context.api);

  // TODO: remove `search` and `filter` parameter, search = null, filter = 1
  Future<List<Coupon>> list(String? search, int filter, int? limit,
          {Country? country, ClientCategory? clientCategory, num? lon, num? lat, List<int>? couponTypes}) async =>
      withSqlLog(context, () async {
        final isValidRange = IntDateRange.isValid(BigInt.from(filter));
        final range = isValidRange ? IntDateRange.decompose(BigInt.from(filter)) : null;
        final orderByDistance = lon != null && lat != null;
        final withCount = [1, 3].contains(filter);
        final leftJoinCouponCount = """
          LEFT JOIN (
            SELECT coupon_id, COUNT(*) AS coupons_issued
            FROM user_coupons
            GROUP BY coupon_id
          ) uc ON uc.coupon_id = c.coupon_id 
        """;
        final sql = """
          SELECT c.*${withCount ? ", COALESCE(uc.coupons_issued, 0) AS coupons_issued " : ""}
          FROM coupons c
          ${clientCategory != null ? "INNER JOIN clients cli ON cli.client_id = c.client_id " : ""}
          ${orderByDistance ? "LEFT JOIN locations loc ON loc.location_id = c.location_id " : ""}
          ${withCount ? leftJoinCouponCount : ""}
          WHERE c.client_id = @client_id 
          ${(search?.isNotEmpty ?? false) ? "AND (c.name ILIKE @search OR c.description ILIKE @search) " : ""}
          ${filter == 1 ? "AND c.valid_from <= intDateNow() AND COALESCE(c.valid_to >= intDateNow(), true) " : ""}
          ${filter == 2 ? "AND c.valid_from > intDateNow() AND COALESCE(c.valid_to > intDateNow(), true) " : ""}
          ${filter == 3 ? "AND c.valid_to < intDateNow() " : ""}
          ${filter == 4 ? "AND c.deleted_at IS NOT NULL " : ""}
          ${filter != 4 ? "AND c.deleted_at IS NULL " : ""}
          ${country != null ? "AND @country ILIKE ANY(c.countries) " : ""}
          ${couponTypes != null ? "AND c.type = ANY(@coupon_types) " : ""}
          ${clientCategory != null ? "AND @category = ANY(cli.categories) " : ""}
          ${isValidRange ? "AND COALESCE(c.valid_to >= @range_start, true) AND COALESCE(c.valid_to <= @range_end, true) " : ""}
          ORDER BY ${orderByDistance ? "distance(@lat, @lon, loc.latitude, loc.longitude) " : country != null ? "c.valid_to " : "c.rank, c.name "}
          ${limit != null ? "LIMIT $limit" : ""}
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "client_id": session.clientId,
          if ((search?.isNotEmpty ?? false)) "search": "%$search%",
          if (isValidRange && range != null) ...{
            "range_start": range.startingAt.value,
            "range_end": range.endingAt.value,
          },
          if (country != null) "country": country.code,
          if (clientCategory != null) "category": clientCategory.code,
          if (couponTypes != null) "coupon_types": couponTypes,
          if (orderByDistance) ...{"lon": lon, "lat": lat}
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => Coupon.fromMap(row, Convention.snake)).toList();
      });

  Future<List<Coupon>?> _select(String sql, Map<String, dynamic> sqlParams) async => withSqlLog(context, () async {
        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) return null;

        return rows.map(
          (row) {
            final coupon = Coupon.fromMap(row, Convention.snake);
            coupon.image = api.storageUrl(coupon.image, StorageObject.coupon, timeStamp: coupon.updatedAt);
            coupon.clientLogo = api.storageUrl(coupon.clientLogo, StorageObject.client);
            return coupon;
          },
        ).toList();
      });

  Future<Coupon?> select(String couponId /*, int? cached*/) async => withSqlLog(context, () async {
        final sql = """
          SELECT 
            k.coupon_id, k.client_id, k.location_id, k.type, k.name, k.description, k.discount, k.code, k.codes, k.image, k.image_bh, k.rank, 
            k.valid_from, k.valid_to, k.updated_at,
            c.logo AS client_Logo, c.logo_bh AS client_logo_bh, c.color AS client_color, c.name AS client_name,
            l.name AS location_name, l.address_line_1 AS location_address_line_1, l.address_line_2 AS location_address_line_2, l.city AS location_city,
            l.longitude AS location_longitude, l.latitude AS location_latitude,
            k.meta
          FROM coupons k
          INNER JOIN clients c ON k.client_id = c.client_id AND c.blocked = FALSE AND c.deleted_at IS NULL
          LEFT JOIN locations l ON k.location_id = l.location_id 
          WHERE k.deleted_at IS NULL AND k.blocked = FALSE 
            AND k.coupon_id = @coupon_id
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"coupon_id": couponId};

        final coupons = await _select(sql, sqlParams);
        if (coupons == null || coupons.isEmpty) return null;

        return coupons.first;
      });

  Future<List<Coupon>> selectFromCategory({required int categoryCode, required Country country}) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT 
            k.coupon_id, k.client_id, k.location_id, k.type, k.name, k.description, 
            k.discount, k.code, k.codes, k.image, k.image_bh, k.rank, k.valid_from, k.valid_to,
            c.logo AS client_Logo, c.logo_bh AS client_logo_bh, c.color AS client_color, c.name AS client_name,
            l.name AS location_name, l.address_line_1 AS location_address_line_1, 
            l.address_line_2 AS location_address_line_2, l.city AS location_city,
            l.longitude AS location_longitude, l.latitude AS location_latitude
          FROM coupons k
          INNER JOIN clients c ON k.client_id = c.client_id AND c.blocked = FALSE 
            AND c.deleted_at IS NULL AND @category = ANY(c.categories)
          LEFT JOIN locations l ON k.location_id = l.location_id 
          WHERE k.deleted_at IS NULL AND k.blocked = FALSE 
            AND (k.type IN (${CouponType.universal.code}, ${CouponType.reservation.code}, ${CouponType.product.code}) 
              OR (k.type = ${CouponType.array.code} AND ARRAY_LENGTH(k.codes, 1) > 0))
            AND k.valid_from <= intDateNow() AND COALESCE(k.valid_to >= intDateNow(), TRUE)
            AND @country = ANY(k.countries || c.countries)
          ORDER BY k.created_at DESC 
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "category": categoryCode,
          "country": country.code,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map<Coupon>((row) {
          final coupon = Coupon.fromMap(row, Convention.snake);
          coupon.image = api.storageUrl(coupon.image, StorageObject.coupon, timeStamp: coupon.updatedAt);
          coupon.clientLogo = api.storageUrl(coupon.clientLogo, StorageObject.client);
          return coupon;
        }).toList();
      });

  Future<List<Coupon>?> selectNewest(Country country) async => withSqlLog(context, () async {
        final sql = """
          SELECT 
            k.coupon_id, k.client_id, k.location_id, k.type, k.name, k.description, k.discount, k.code, k.codes, k.image, k.image_bh, k.rank, 
            k.valid_from, k.valid_to, k.updated_at,
            c.logo AS client_Logo, c.logo_bh AS client_logo_bh, c.color AS client_color, c.name AS client_name,
            l.name AS location_name, l.address_line_1 AS location_address_line_1, l.address_line_2 AS location_address_line_2, l.city AS location_city,
            l.longitude AS location_longitude, l.latitude AS location_latitude,
            k.meta
          FROM coupons k
          INNER JOIN clients c ON k.client_id = c.client_id AND c.blocked = FALSE AND c.deleted_at IS NULL
          LEFT JOIN locations l ON k.location_id = l.location_id 
          WHERE k.deleted_at IS NULL AND k.blocked = FALSE 
            AND (k.type IN (${CouponType.universal.code}, ${CouponType.reservation.code}, ${CouponType.product.code}) OR (k.type = ${CouponType.array.code} AND ARRAY_LENGTH(k.codes, 1) > 0))
            AND k.valid_from <= intDateNow() AND COALESCE(k.valid_to >= intDateNow(), TRUE)
            AND @country = ANY(k.countries || c.countries)
          ORDER BY k.created_at DESC 
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"country": country.code};

        return await _select(sql, sqlParams);
      });

  Future<List<Coupon>?> selectNearest(double lon, double lat) async => withSqlLog(context, () async {
        final sql = """
          SELECT 
            k.coupon_id, k.client_id, k.location_id, k.type, k.name, k.description, k.discount, k.code, k.codes, k.image, k.image_bh, k.rank, 
            k.valid_from, k.valid_to, k.updated_at,
            c.logo AS client_Logo, c.logo_bh AS client_logo_bh, c.color AS client_color, c.name AS client_name,
            l.name AS location_name, l.address_line_1 AS location_address_line_1, l.address_line_2 AS location_address_line_2, l.city AS location_city,
            l.longitude AS location_longitude, l.latitude AS location_latitude,
            k.meta
          FROM coupons k
          INNER JOIN clients c ON k.client_id = c.client_id AND c.blocked = FALSE AND c.deleted_at IS NULL
          INNER JOIN locations l ON k.location_id = l.location_id AND k.client_id = l.client_id AND l.longitude IS NOT NULL AND l.latitude IS NOT NULL
          WHERE k.deleted_at IS NULL AND k.blocked = FALSE 
            AND (k.type IN (${CouponType.universal.code}, ${CouponType.reservation.code}, ${CouponType.product.code}) OR (k.type = ${CouponType.array.code} AND ARRAY_LENGTH(k.codes, 1) > 0))
            AND k.valid_from <= intDateNow() AND COALESCE(k.valid_to >= intDateNow(), TRUE)
          ORDER BY distance(@lat, @lon, l.latitude, l.longitude) 
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"lon": lon, "lat": lat};

        return await _select(sql, sqlParams);
      });

  Future<Coupon?> _selectValidCoupon(String couponId) async => withSqlLog(context, () async {
        final sql = """
          SELECT k.*
          FROM coupons k
          INNER JOIN clients c ON k.client_id = c.client_id
          WHERE k.coupon_id = @coupon_id AND k.deleted_at IS NULL 
            AND k.valid_from <= intDateNow() AND COALESCE(k.valid_to >= intDateNow(), TRUE)
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"coupon_id": couponId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => Coupon.fromMap(row, Convention.snake)).firstOrNull;
      });

  // Returns (result, cardId, userCardId, userCouponId)
  Future<(CouponTakeResult, String?, String?, String?)> take(String couponId) async => withSqlLog(context, () async {
        // Check if coupon exists and client is not blocked
        final coupon = await _selectValidCoupon(couponId);

        // Coupon not found or client is blocked
        if (coupon == null) {
          api.log.error("CouponDAO.take: Coupon not found! CouponId: $couponId");
          return (CouponTakeResult.couponNotFound, null, null, null);
        }

        final clientId = coupon.clientId;

        // Manual coupon cannot be taken
        if (coupon.type == CouponType.manual) {
          log.error("CouponDAO.take: Manual coupon cannot be taken! CouponId: $couponId");
          return (CouponTakeResult.manualCoupon, clientId, null, null);
        }

        if (coupon.meta?["userIssueLimit"] != null) {
          // Check if coupon hasn't been already issued maximum times
          final userIssueLimit = tryParseInt(coupon.meta?["userIssueLimit"]) ?? 0;
          if (userIssueLimit > 0) {
            final sql = """
              SELECT COUNT(*) AS count 
              FROM user_coupons
              WHERE coupon_id = @coupon_id AND user_id = @user_id
            """
                .tidyCode();

            final Map<String, dynamic> sqlParams = {
              "coupon_id": couponId,
              "user_id": session.userId,
            };

            log.logSql(context, sql, sqlParams);

            final userCoupons = await api.select(sql, params: sqlParams);

            if (userCoupons[0]["count"] >= userIssueLimit) {
              log.error(
                  "CouponDAO.take: Maximum number of coupon's has already been issued! CouponId: $couponId, count: $userIssueLimit");
              return (CouponTakeResult.userIssueLimitReached, null, null, null);
            }
          }
        }

        final emitCard = EmitCardDAO(context);
        final cardId = await emitCard.getDefaultCard(clientId);
        // Client has no default card
        if (cardId == null) {
          log.error("CouponDAO.take: Client has no default card! CouponId: $couponId");
          return (CouponTakeResult.clientHasNoDefaultCard, null, null, null);
        }

        final userCard = await UserCardDAO(session, context).userCardByClient(clientId);
        String? userCardId = userCard?.userCardId;
        if (userCardId == null) {
          // Create user card automatically
          userCardId = await UserCardDAO(session, context).issue(clientId, cardId, meta: {
            "note": "Created automatically by issuing coupon",
            "couponId": couponId,
          });
          // User card not created
          if (userCardId == null) {
            log.verbose("CouponDAO.take: User card not created! CouponId: $couponId");
            return (CouponTakeResult.userCardNotCreated, cardId, null, null);
          }
          // TODO: send message to user, new card created
          await Cache().clear(api.redis, CacheKeys.userUserCards(session.userId));
        } else {
          await Cache().clear(api.redis, CacheKeys.userUserCards(session.userId));
          await Cache().clear(api.redis, CacheKeys.userUserCard(session.userId, userCardId));
        }

        String code = "";
        if (coupon.type == CouponType.array) {
          final codes = coupon.codes ?? [];
          if (codes.isEmpty) {
            log.error("CouponDAO.take: Array coupon has no codes! CouponId: $couponId");
            return (CouponTakeResult.arrayCouponHasNoCodes, cardId, userCardId, null);
          }
          final code = codes.first;
          codes.removeWhere((x) => x == code);
          final sql = """
            UPDATE coupons SET codes = @codes, updated_at = NOW()
            WHERE coupon_id = @coupon_id  AND deleted_at IS NULL
          """;
          final sqlParams = {"coupon_id": couponId, "codes": codes};
          log.logSql(context, sql, sqlParams);
          final updated = await api.update(sql, params: sqlParams);
          if (updated == 0) {
            log.error("CouponDAO.take: Failed to update coupon codes! CouponId: $couponId");
            return (CouponTakeResult.failedToUpdateCouponCodes, cardId, userCardId, null);
          }
        }

        final sql = """
          INSERT INTO user_coupons (user_coupon_id, coupon_id, user_id, client_id, meta, created_at, expires_at)
          VALUES (@user_coupon_id, @coupon_id, @user_id, @client_id, @meta, NOW(), @expires_at)    
          RETURNING *
        """;

        final userCouponId = uuid();
        final expiresAt = coupon.validTo?.toDate() ?? DateTime.now().add(Duration(days: 30));

        final sqlParams = {
          "user_coupon_id": userCouponId,
          "coupon_id": couponId,
          "client_id": clientId,
          "user_id": session.userId,
          "meta": code.isEmpty ? null : {"code": code},
          "expires_at": IntDate.fromDate(expiresAt).value,
        };

        log.logSql(context, sql, sqlParams);

        final userCouponInserted = (await api.insert(sql, params: sqlParams)) == 1;
        if (!userCouponInserted) {
          log.error("CouponDAO.take: User coupon not inserted! CouponId: $couponId");
          return (CouponTakeResult.userCouponNotInserted, cardId, userCardId, null);
        }
        return (CouponTakeResult.ok, cardId, userCardId, userCouponId);
      });
}

// eof
