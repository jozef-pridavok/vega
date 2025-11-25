import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../cache.dart";
import "../data_models/session.dart";
import "../utils/storage.dart";

class LeafletDetailDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  LeafletDetailDAO(this.session, this.context) : super(context.api);

  /// Returns record (JsonObject?, bool). JsonObject contains list of LeafletDetail entities.
  /// Boolean is true, if there are the most current data cached in device,
  /// in that case no data has to be returned, so first field would be null.
  Future<(JsonObject?, bool)> select(String clientId, int? cached, bool noCache) async => withSqlLog(context, () async {
        final now = DateTime.now();

        final sql = """
          SELECT lf.leaflet_id, lf.client_id, lf.location_id, lf.updated_at, loc.name AS location_name,
            loc.address_line_1 AS location_address_line_1, loc.address_line_2 AS location_address_line_2,
            loc.city AS location_city, lf.country, lf.name, lf.rank, lf.valid_from, lf.valid_to,
            COALESCE(lf.thumbnail, lf.pages[1]) as thumbnail, 
            COALESCE(lf.thumbnail_bh, lf.pages_bh[1]) as thumbnail_bh, 
            lf.leaflet, lf.pages, lf.pages_bh
          FROM leaflets lf
          LEFT JOIN locations loc ON loc.location_id = lf.location_id
          LEFT JOIN clients c ON c.client_id = lf.client_id AND c.deleted_at IS NULL
          WHERE lf.client_id = @client_id AND lf.deleted_at IS NULL AND lf.blocked = FALSE
            AND UPPER(lf.country) = UPPER(@country) 
            AND (lf.valid_from <= @to AND lf.valid_to >= @from)
          ORDER BY lf.rank DESC, lf.valid_to ASC
        """
            .tidyCode();

        // AND lf.valid_to >= @to AND lf.valid_from <= @from
        // AND ((lf.valid_from >= @from AND lf.valid_from <= @to) OR (lf.valid_to >= @from AND lf.valid_to <= @to))

        final sqlParams = <String, dynamic>{
          "client_id": clientId,
          "country": (session.country ?? Country.slovakia).code,
          "from": IntDate.fromDate(now.subtract(Duration(days: 1))).value,
          "to": IntDate.fromDate(now.add(Duration(days: 5))).value,
        };

        final cacheKey = CacheKeys.leaflets(clientId);

        var (isCached, timestamp) = await Cache().isCached(api.redis, cacheKey, cached);
        if (isCached) return (null, true);

        JsonObject? json = await Cache().getJson(api.redis, cacheKey);
        if (json == null) {
          log.logSql(context, sql, sqlParams);

          final rows = await api.select(sql, params: sqlParams);
          final leafletDetails = rows.map<LeafletDetail>(
            (row) {
              final detail = LeafletDetail.fromMap(row, LeafletDetail.snake);
              detail.thumbnail = api.storageUrl(detail.thumbnail, StorageObject.leaflet, timeStamp: detail.updatedAt);
              detail.pages = detail.pages?.map((e) => api.storageUrl(e, StorageObject.leaflet) ?? "").toList();
              return detail;
            },
          );
          json = {
            "length": leafletDetails.length,
            "leaflets": leafletDetails.map((e) => e.toMap(LeafletDetail.camel)).toList(),
          };
          timestamp = await Cache().putJson(api.redis, cacheKey, json);
        }

        json = {"cache": timestamp, ...json};
        return (json, false);
      });
}

// eof
