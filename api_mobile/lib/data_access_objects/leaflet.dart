import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";
import "package:intl/intl.dart";

import "../data_models/session.dart";

class LeafletDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  LeafletDAO(this.session, this.context) : super(context.api);

  Future<List<Leaflet>> select(int filter) async => withSqlLog(context, () async {
        final sql = """
          SELECT l.*, loc.name AS location_name, loc.city AS location_city,loc.zip AS location_zip
          FROM leaflets l  
          INNER JOIN clients c ON l.client_id = c.client_id  AND c.blocked = FALSE AND c.deleted_at is NULL
          LEFT JOIN locations loc ON loc.location_id = l.location_id
          WHERE l.client_id = @client_id
            ${filter == 1 ? "AND l.valid_from <= @now AND l.valid_to >= @now" : ""}
            ${filter == 2 ? "AND l.valid_from > @now AND l.valid_to > @now" : ""}
            ${filter == 3 ? "AND l.valid_to < @now" : ""}
            ${filter == 4 ? "AND l.deleted_at IS NOT NULL " : ""}
            ${filter != 4 ? "AND l.deleted_at IS NULL " : ""}
          ORDER BY l.rank, l.valid_to DESC, l.name
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "client_id": session.clientId,
          "now": int.parse(DateFormat("yyyyMMdd").format(DateTime.now())),
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => Leaflet.fromMap(row, Leaflet.snake)).toList();
      });

  Future<dynamic> insert(Leaflet leaflet) async => withSqlLog(context, () async {
        final sql = """
          INSERT INTO leaflets (leaflet_id, client_id, country, name, valid_from, valid_to,
            ${leaflet.thumbnail != null ? 'thumbnail, ' : ''} 
            ${leaflet.thumbnailBh != null ? 'thumbnail_bh, ' : ''} 
            ${leaflet.leaflet != null ? 'leaflet, ' : ''} 
            ${leaflet.meta != null ? 'meta, ' : ''} 
            ${leaflet.locationId != null ? 'location_id, ' : ''} 
            pages, pages_bh, created_at
          ) VALUES (@leaflet_id, @client_id, @country, @name, @valid_from, @valid_to,
            ${leaflet.locationId != null ? '@location_id, ' : ''} 
            ${leaflet.thumbnail != null ? '@thumbnail, ' : ''} 
            ${leaflet.thumbnailBh != null ? '@thumbnail_bh, ' : ''} 
            ${leaflet.leaflet != null ? '@leaflet, ' : ''} 
            ${leaflet.meta != null ? '@meta, ' : ''} 
            @pages, @pages_bh, NOW()
          )
        """
            .tidyCode();

        final sqlParams = leaflet.toMap(Leaflet.snake);

        log.logSql(context, sql, sqlParams);

        final inserted = await api.insert(sql, params: sqlParams);
        return inserted;
      });

  Future<int> update(Leaflet leaflet) async => withSqlLog(context, () async {
        final sql = """
          UPDATE leaflets SET 
            name = @name, country = @country, valid_from = @valid_from, valid_to = @valid_to,
            ${leaflet.locationId != null ? 'location_id = @location_id, ' : ''} 
            ${leaflet.thumbnail != null ? 'thumbnail = @thumbnail, ' : ''} 
            ${leaflet.thumbnailBh != null ? 'thumbnail_bh = @thumbnail_bh, ' : ''}  
            pages = @pages, pages_bh = @pages_bh, 
            ${leaflet.leaflet != null ? 'leaflet = @leaflet, ' : ''} 
            ${leaflet.meta != null ? 'meta = @meta, ' : ''} 
            updated_at = NOW()
          WHERE leaflet_id = @leaflet_id AND client_id = @client_id AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = leaflet.toMap(Leaflet.snake);

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> patch(String leafletId, {bool? start, bool? finish, bool? blocked, bool? archived}) async =>
      withSqlLog(context, () async {
        final sql = """
          UPDATE leaflets SET
            ${start != null ? 'valid_from = intDateNow(), blocked = FALSE,' : ''}
            ${finish != null ? 'valid_to = intDateYesterday(),' : ''}
            ${blocked != null ? 'blocked = @blocked, ' : ''}
            ${archived == true ? 'deleted_at = NOW(), ' : ''}
            ${archived == false ? 'deleted_at = NULL, ' : ''}
            updated_at = NOW()
          WHERE client_id = @client_id AND leaflet_id = @leaflet_id
        """
            .removeEmptyLines();

        final sqlParams = <String, dynamic>{
          "leaflet_id": leafletId,
          "client_id": session.clientId,
        };
        if (blocked != null) sqlParams["blocked"] = blocked ? 1 : 0;

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> reorder(List<String> leafletIds) async => withSqlLog(context, () async {
        final sql = """
          UPDATE leaflets
          SET rank = array_position(@leaflet_ids, leaflet_id),
              updated_at = NOW()
          WHERE client_id = @client_id AND leaflet_id = ANY(@leaflet_ids)
        """
            .tidyCode();

        final sqlParams = {"client_id": session.clientId, "leaflet_ids": leafletIds};

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
