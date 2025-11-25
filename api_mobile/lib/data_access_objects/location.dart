import "dart:convert";

import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../data_models/session.dart";

class LocationDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  LocationDAO(this.session, this.context) : super(context.api);

  Future<List<Location>> list() async => withSqlLog(context, () async {
        final sql = """
      SELECT client_id, location_id, type, rank, name, description, address_line_1, address_line_2, 
      city, zip, state, country, phone, email, website, opening_hours, opening_hours_exceptions, 
      latitude, longitude
      FROM locations
      WHERE client_id = @client_id AND deleted_at IS NULL
      ORDER BY rank 
      """
            .tidyCode();

        final sqlParams = <String, dynamic>{"client_id": session.clientId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map<Location>((row) => Location.fromMap(row, Location.snake)).toList();
      });

  Future<int> insert(Location location) async => withSqlLog(context, () async {
        final sql = """
      INSERT INTO locations (
        client_id, location_id, type, name, latitude, longitude, 
        ${location.description != null ? "description, " : ""}
        ${location.addressLine1 != null ? "address_line_1, " : ""}
        ${location.addressLine2 != null ? "address_line_2, " : ""}
        ${location.city != null ? "city, " : ""}
        ${location.zip != null ? "zip, " : ""}
        ${location.state != null ? "state, " : ""}
        ${location.country != null ? "country, " : ""}
        ${location.phone != null ? "phone, " : ""}
        ${location.email != null ? "email, " : ""}
        ${location.website != null ? "website, " : ""}
        ${location.openingHours != null ? "opening_hours, " : ""}
        ${location.openingHoursExceptions != null ? "opening_hours_exceptions, " : ""}
        created_at
      ) VALUES (
        @client_id, @location_id, @type, @name, @latitude, @longitude, 
        ${location.description != null ? "@description, " : ""}
        ${location.addressLine1 != null ? "@address_line_1, " : ""}
        ${location.addressLine2 != null ? "@address_line_2, " : ""}
        ${location.city != null ? "@city, " : ""}
        ${location.zip != null ? "@zip, " : ""}
        ${location.state != null ? "@state, " : ""}
        ${location.country != null ? "@country, " : ""}
        ${location.phone != null ? "@phone, " : ""}
        ${location.email != null ? "@email, " : ""}        
        ${location.website != null ? "@website, " : ""}
        ${location.openingHours != null ? "@opening_hours, " : ""}
        ${location.openingHoursExceptions != null ? "@opening_hours_exceptions, " : ""}
        NOW()
      )
    """
            .tidyCode();

        final sqlParams = location.toMap(Location.snake);

        log.logSql(context, sql, sqlParams);

        return await api.insert(sql, params: sqlParams);
      });

  Future<int> update(Location location) async => withSqlLog(context, () async {
        final sql = """
      UPDATE locations
      SET 
        type = @type, name = @name, latitude = @latitude, longitude = @longitude,
        description = ${location.description != null ? "@description, " : "NULL, "}
        address_line_1 = ${location.addressLine1 != null ? "@address_line_1, " : "NULL, "}
        address_line_2 = ${location.addressLine2 != null ? "@address_line_2, " : "NULL, "}
        city = ${location.city != null ? "@city, " : "NULL, "}
        zip = ${location.zip != null ? "@zip, " : "NULL, "}
        state = ${location.state != null ? "@state, " : "NULL, "}
        country = ${location.country != null ? "@country, " : "NULL, "}
        phone = ${location.phone != null ? "@phone, " : "NULL, "}
        email = ${location.email != null ? "@email, " : "NULL, "}        
        website = ${location.website != null ? "@website, " : "NULL, "}
        opening_hours = ${location.openingHours != null ? " @opening_hours, " : "NULL, "}
        opening_hours_exceptions = ${location.openingHoursExceptions != null ? " @opening_hours_exceptions, " : "NULL, "}
        updated_at = NOW()
      WHERE client_id = @client_id AND location_id = @location_id
      """
            .tidyCode();

        final sqlParams = location.toMap(Location.snake);

        log.logSql(context, sql, sqlParams);

        sqlParams[Location.snake[LocationKeys.openingHoursExceptions]!] =
            jsonEncode(sqlParams["opening_hours_exceptions"]);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> patch(String locationId, {bool? archived}) async => withSqlLog(context, () async {
        final sql = """
      UPDATE locations SET
        ${archived == true ? 'deleted_at = NOW(), ' : ''}
        ${archived == false ? 'deleted_at = NULL, ' : ''}
        updated_at = NOW()
      WHERE client_id = @client_id AND location_id = @location_id
      """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "location_id": locationId,
          "client_id": session.clientId,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> reorder(List<String> locationIds) async => withSqlLog(context, () async {
        final sql = """
      UPDATE locations
      SET rank = array_position(@location_ids, location_id),
          updated_at = NOW()
      WHERE client_id = @client_id AND location_id = ANY(@location_ids)
      """
            .tidyCode();

        final sqlParams = {"client_id": session.clientId, "location_ids": locationIds};

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
