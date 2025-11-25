import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../cache.dart";
import "../data_models/session.dart";
import "../utils/storage.dart";

class LeafletOverviewDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  LeafletOverviewDAO(this.session, this.context) : super(context.api);

  /// Returns record (JsonObject?, bool). JsonObject contains list of ClientLeaflet entities.
  /// Boolean is true, if there are the most current data cached in device,
  /// in that case no data has to be returned, so first field would be null.
  Future<(JsonObject?, bool)> newest(Country country, int limit, int? cached, bool noCache) async =>
      withSqlLog(context, () async {
        final now = DateTime.now();

        final sql = """
          SELECT
            c.client_id, c.name, c.color, c.logo, c.logo_bh,
            l.first_country AS country,
            l.first_thumbnail AS thumbnail,
            l.first_thumbnail_bh AS thumbnail_bh,
            l.leaflets
          FROM clients c
          LEFT JOIN (
            SELECT
              client_id,
              MAX(country) AS first_country,
              COALESCE(MAX(thumbnail), MAX(pages[1])) AS first_thumbnail,
              COALESCE(MAX(thumbnail_bh), MAX(pages_bh[1])) AS first_thumbnail_bh,
              COUNT(leaflet_id) AS leaflets,
              MIN(valid_from) AS valid_from
            FROM leaflets
            WHERE deleted_at IS NULL AND blocked = FALSE AND
              UPPER(country) = UPPER(@country) 
                AND (valid_from <= @to AND valid_to >= @from)
            GROUP BY client_id
          ) l ON c.client_id = l.client_id
          WHERE c.deleted_at IS NULL AND c.blocked = FALSE AND COALESCE(leaflets, 0) > 0
          ORDER BY l.valid_from;
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "country": (session.country ?? Country.slovakia).code,
          "limit": limit,
          "from": IntDate.fromDate(now.subtract(Duration(days: 1))).value,
          "to": IntDate.fromDate(now.add(Duration(days: 5))).value,
        };

        final cacheKey = CacheKeys.leafletsOverviewForCountry(country, limit);
        var (isCached, timestamp) = await Cache().isCached(api.redis, cacheKey, cached);
        if (isCached) return (null, true);

        JsonObject? json = await Cache().getJson(api.redis, cacheKey);
        if (json == null) {
          log.logSql(context, sql, sqlParams);

          final rows = await api.select(sql, params: sqlParams);
          final clientLeaflets = rows.map(
            (row) {
              final overview = LeafletOverview.fromMap(row, LeafletOverview.snake);
              overview.clientLogo = api.storageUrl(overview.clientLogo, StorageObject.client);
              overview.thumbnail = api.storageUrl(overview.thumbnail, StorageObject.leaflet);
              return overview;
            },
          ).cast<LeafletOverview>();
          json = {
            "length": clientLeaflets.length,
            "clients": clientLeaflets.map((e) => e.toMap(LeafletOverview.camel)).toList(),
          };
          timestamp = await Cache().putJson(api.redis, cacheKey, json);
        }

        json = {"cache": timestamp, ...json};
        return (json, false);
      });
}


// eof
