import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../data_models/session.dart";

class QrTagDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  QrTagDAO(this.session, this.context) : super(context.api);

  Future<List<QrTag>> list(String programId, {required int filter, int? limit, int? period}) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT qr.qr_tag_id, qr.client_id, qr.program_id, qr.points, qr.used_by_user_id,
          qr.used_at, COALESCE(u.meta->'${session.clientId}'->>'displayName', u.nick) AS used_by_user_nick
          FROM qr_tag qr
          LEFT JOIN users u ON u.user_id = qr.used_by_user_id
          WHERE qr.program_id = @program_id AND qr.client_id = @client_id AND qr.deleted_at IS NULL 
          ${filter == 1 ? "AND qr.used_by_user_id IS NULL " : ""}
          ${filter == 2 ? "AND qr.used_by_user_id IS NOT NULL " : ""}
          ${filter == 2 && period != null ? 'AND qr.used_at > NOW() - (@period::TEXT || \' days\')::INTERVAL ' : ''}
          ORDER BY qr.created_at
          ${limit != null ? "LIMIT $limit" : ""}
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"program_id": programId, "client_id": session.clientId, "filter": filter};
        if (period != null) sqlParams["period"] = period;

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => QrTag.fromMap(row, QrTag.snake)).toList();
      });

  Future<int> insertMany(List<QrTag> newQrTags) async => withSqlLog(context, () async {
        var sql = """
          INSERT INTO qr_tag (
            qr_tag_id, client_id, program_id, points, created_at
          ) VALUES
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{};
        for (int i = 0; i < newQrTags.length; i++) {
          sql += """
            ( 
              @qr_tag_id_$i, @client_id_$i, @program_id_$i, @points_$i, NOW()
            )${i < newQrTags.length - 1 ? ',' : ''}
          """
              .tidyCode();
          sqlParams.addAll({
            "qr_tag_id_$i": newQrTags[i].qrTagId,
            "client_id_$i": newQrTags[i].clientId,
            "program_id_$i": newQrTags[i].programId,
            "points_$i": newQrTags[i].points,
          });
        }

        log.logSql(context, sql, sqlParams);

        final inserted = await api.insert(sql, params: sqlParams);
        return inserted;
      });

  Future<int> deleteMany(List<String> qrTagIds) async => withSqlLog(context, () async {
        final sql = """
          UPDATE qr_tag
          SET deleted_at = NOW()
          WHERE client_id = @client_id AND qr_tag_id = ANY(@qr_tag_ids)
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "qr_tag_ids": qrTagIds,
          "client_id": session.clientId,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
