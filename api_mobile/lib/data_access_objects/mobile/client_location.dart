import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

class ClientLocationDAO extends ApiServerDAO {
  final ApiServerContext context;

  ClientLocationDAO(this.context) : super(context.api);

  Future<List<Location>> select(String clientId) async => withSqlLog(context, () async {
        final sql = """
            SELECT client_id, location_id, type, rank, name, address_line_1, address_line_2, city, zip, state, country, 
                  phone, email, website, opening_hours, opening_hours_exceptions, latitude, longitude
            FROM locations
            WHERE client_id = @client_id AND deleted_at IS NULL
            ORDER BY rank
          """
            .tidyCode();

        final sqlParams = <String, dynamic>{"client_id": clientId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => Location.fromMap(row, Location.snake)).toList();
      });
}

// eof

