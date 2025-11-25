import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../cache.dart";
import "../data_models/session.dart";

class UserAddressDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  UserAddressDAO(this.session, this.context) : super(context.api);

  Future<(JsonObject?, bool)> list(int? cached, bool noCache) async => withSqlLog(context, () async {
        final sql = """
          SELECT 
              user_address_id, user_id, name, 
              address_line_1, address_line_2, city, zip, state, country, latitude, longitude
          FROM user_addresses
          WHERE user_id = @user_id AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"user_id": session.userId};

        final cacheKey = CacheKeys.userUserAddresses(session.userId);
        var (isCached, timestamp) = await Cache().isCached(api.redis, cacheKey, cached);
        if (isCached) return (null, true);

        JsonObject? json = await Cache().getJson(api.redis, cacheKey);
        if (json == null) {
          log.logSql(context, sql, sqlParams);

          final addresses = (await api.select(sql, params: sqlParams)).map(
            (row) => UserAddress.fromMap(row, Convention.snake),
          );
          json = {
            "length": addresses.length,
            "addresses": addresses.map((e) => e.toMap(Convention.camel)).toList(),
          };
          timestamp = await Cache().putJson(api.redis, cacheKey, json);
        }

        json = {"cache": timestamp, ...json};
        return (json, false);
      });

  Future<int> insert(UserAddress address) async => withSqlLog(context, () async {
        final sql = """
          INSERT INTO user_addresses (
              user_address_id, user_id, name, 
              ${address.addressLine1 != null ? 'address_line_1, ' : ''}
              ${address.addressLine2 != null ? 'address_line_2, ' : ''}
              ${address.city != null ? 'city, ' : ''}
              ${address.zip != null ? 'zip, ' : ''}
              ${address.state != null ? 'state, ' : ''}
              ${address.country != null ? 'country, ' : ''}
              ${address.geoPoint?.latitude != null ? 'latitude, ' : ''}
              ${address.geoPoint?.longitude != null ? 'longitude, ' : ''}
              created_at            
          ) VALUES (
              @user_address_id, @user_id, @name, 
              ${address.addressLine1 != null ? '@address_line_1, ' : ''}
              ${address.addressLine2 != null ? '@address_line_2, ' : ''}
              ${address.city != null ? '@city, ' : ''}
              ${address.zip != null ? '@zip, ' : ''}
              ${address.state != null ? '@state, ' : ''}
              ${address.country != null ? '@country, ' : ''}
              ${address.geoPoint?.latitude != null ? '@latitude, ' : ''}
              ${address.geoPoint?.longitude != null ? '@longitude, ' : ''}
              NOW()
          )
        """
            .tidyCode();

        final sqlParams = address.toMap(Convention.snake);

        log.logSql(context, sql, sqlParams);

        return await api.insert(sql, params: sqlParams);
      });

  Future<int> update(UserAddress address) async => withSqlLog(context, () async {
        final sql = """
          UPDATE user_addresses SET 
              name = @name, 
              ${address.addressLine1 != null ? 'address_line_1 = @address_line_1, ' : ''}
              ${address.addressLine2 != null ? 'address_line_2 = @address_line_2, ' : ''}
              ${address.city != null ? 'city = @city, ' : ''}
              ${address.zip != null ? 'zip = @zip, ' : ''}
              ${address.state != null ? 'state = @state, ' : ''}
              ${address.country != null ? 'country = @country, ' : ''}
              ${address.geoPoint?.latitude != null ? 'latitude = @latitude, ' : ''}
              ${address.geoPoint?.longitude != null ? 'longitude = @longitude, ' : ''}
              updated_at = NOW()
          WHERE user_address_id = @user_address_id AND user_id = @user_id AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = address.toMap(Convention.snake);

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> delete(String userAddressId) async => withSqlLog(context, () async {
        final sql = """
          UPDATE user_addresses SET 
              deleted_at = NOW()
          WHERE user_address_id = @user_address_id AND user_id = @user_id AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "user_address_id": userAddressId,
          "user_id": session.userId,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
