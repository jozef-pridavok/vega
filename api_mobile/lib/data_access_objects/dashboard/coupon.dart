import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";

class CouponDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  CouponDAO(this.session, this.context) : super(context.api);

  Future<Coupon?> select(String couponId) async => withSqlLog(context, () async {
        final sql = """
          SELECT k.*
          FROM coupons k
          INNER JOIN clients c ON k.client_id = c.client_id
          WHERE k.coupon_id = @coupon_id AND k.deleted_at IS NULL 
            AND COALESCE(k.valid_to >= intDateNow(), TRUE)
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"coupon_id": couponId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => Coupon.fromMap(row, Convention.snake)).firstOrNull;
      });

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

  Future<int> insert(Coupon coupon) async => withSqlLog(context, () async {
        final sql = """
          INSERT INTO coupons (
            coupon_id, client_id, type, name, countries,
            ${coupon.locationId != null ? 'location_id, ' : ''}
            ${coupon.description != null ? 'description, ' : ''} 
            ${coupon.discount != null ? 'discount, ' : ''} 
            ${coupon.code != null ? 'code, ' : ''}
            ${coupon.codes != null ? 'codes, ' : ''}
            ${coupon.image != null ? 'image, ' : ''}
            ${coupon.imageBh != null ? 'image_bh, ' : ''} 
            ${coupon.validTo != null ? 'valid_to, ' : ''} 
            ${coupon.meta != null ? 'meta, ' : ''} 
            valid_from, created_at
          ) VALUES (
            @coupon_id, @client_id, @type, @name, @countries,
            ${coupon.locationId != null ? '@location_id, ' : ''}        
            ${coupon.description != null ? '@description, ' : ''} 
            ${coupon.discount != null ? '@discount, ' : ''} 
            ${coupon.code != null ? '@code, ' : ''}
            ${coupon.codes != null ? '@codes, ' : ''}
            ${coupon.image != null ? '@image, ' : ''}
            ${coupon.imageBh != null ? '@image_bh, ' : ''} 
            ${coupon.validTo != null ? '@valid_to, ' : ''} 
            ${coupon.meta != null ? '@meta, ' : ''} 
            @valid_from, NOW()
          )
      """
            .tidyCode();

        final sqlParams = coupon.toMap(Convention.snake);
        sqlParams["countries"] =
            coupon.countries != null ? "{${coupon.countries!.map((e) => e.code).join(",")}}" : null;

        log.logSql(context, sql, sqlParams);

        return await api.insert(sql, params: sqlParams);
      });

  Future<int> update(Coupon coupon) async => withSqlLog(context, () async {
        final sql = """
          UPDATE coupons SET 
            type = @type, name = @name, valid_from = @valid_from,
            ${coupon.locationId != null ? 'location_id = @location_id, ' : ''}
            ${coupon.description != null ? 'description = @description, ' : ''} 
            ${coupon.discount != null ? 'discount = @discount, ' : ''} 
            ${coupon.code != null ? 'code = @code, ' : ''}
            ${(coupon.codes?.isNotEmpty ?? false) ? 'codes = @codes, ' : ''}
            ${coupon.image != null ? 'image = @image, ' : ''}
            ${coupon.imageBh != null ? 'image_bh = @image_bh, ' : ''} 
            ${(coupon.countries?.isNotEmpty ?? false) ? 'countries = @countries, ' : ''}         
            ${coupon.validTo != null ? 'valid_to = @valid_to, ' : ''} 
            ${coupon.meta != null ? 'meta = @meta, ' : ''} 
            updated_at = NOW()
          WHERE coupon_id = @coupon_id AND client_id = @client_id AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = coupon.toMap(Convention.snake);
        sqlParams["countries"] =
            coupon.countries != null ? "{${coupon.countries!.map((e) => e.code).join(",")}}" : null;

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> patch(String couponId, {bool? start, bool? finish, bool? blocked, bool? archived}) async =>
      withSqlLog(context, () async {
        final sql = """
          UPDATE coupons SET
            ${start != null ? 'valid_from = intDateNow(), blocked = FALSE,' : ''}
            ${finish != null ? 'valid_to = intDateYesterday(), ' : ''}
            ${blocked != null ? 'blocked = @blocked, ' : ''}
            ${archived == true ? 'deleted_at = NOW(), ' : ''}
            ${archived == false ? 'deleted_at = NULL, ' : ''}
            updated_at = NOW()
          WHERE client_id = @client_id AND coupon_id = @coupon_id
        """
            .removeEmptyLines();

        final sqlParams = <String, dynamic>{
          "coupon_id": couponId,
          "client_id": session.clientId,
        };
        if (blocked != null) sqlParams["blocked"] = (blocked ? 1 : 0);

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> reorder(List<String> couponIds) async => withSqlLog(context, () async {
        final sql = """
          UPDATE coupons
          SET rank = array_position(@coupon_ids, coupon_id),
              updated_at = NOW()
          WHERE client_id = @client_id AND coupon_id = ANY(@coupon_ids)
        """
            .tidyCode();

        final sqlParams = {"client_id": session.clientId, "coupon_ids": couponIds};

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
