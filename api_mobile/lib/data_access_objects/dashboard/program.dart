import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";

class ProgramDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  ProgramDAO(this.session, this.context) : super(context.api);

  // Filter: 1 = Active, 2 = Prepared, 3 = Finished, 4 = Archived
  Future<List<Program>> list({required int filter, String? search, int? limit}) async => withSqlLog(context, () async {
        final sql = """
          SELECT p.program_id, p.client_id, p.card_id, p.type, p.digits, p.name, p.description, p.countries, p.rank,
            p.image, p.image_bh, p.valid_from, p.valid_to, p.meta, p.updated_at,
            COALESCE((p.meta->>'plural')::JSONB, '{}'::JSONB) AS plural,
            (p.meta->>'actions')::JSONB AS actions, p.blocked, ca.name AS card_name,
            TO_JSON(ARRAY(
              SELECT json_build_object(
                'program_reward_id', pr.program_reward_id, 'program_id', pr.program_id, 'name', pr.name,
                'description', pr.description, 'points', pr.points, 'rank', pr.rank, 'count', pr.count,
                'image', pr.image, 'image_bh', pr.image_bh, 'valid_from', pr.valid_from, 'valid_to', pr.valid_to,
                'meta', pr.meta, 'blocked', pr.blocked
              )
              FROM program_rewards AS pr
              WHERE pr.program_id = p.program_id
              ORDER BY pr.rank
            )) AS rewards
          FROM programs p
          INNER JOIN clients c ON p.client_id = c.client_id AND c.deleted_at IS NULL
          LEFT JOIN cards ca ON ca.card_id = p.card_id
          WHERE p.client_id = @client_id
          ${(search?.isNotEmpty ?? false) ? "AND (p.name ILIKE @search OR p.description ILIKE @search) " : ""}
          ${filter == 1 ? "AND p.valid_from <= intDateNow() AND COALESCE(p.valid_to >= intDateNow(), true) " : ""}
          ${filter == 2 ? "AND p.valid_from > intDateNow() AND COALESCE(p.valid_to > intDateNow(), true) " : ""}
          ${filter == 3 ? "AND p.valid_to < intDateNow() " : ""}
          ${filter == 4 ? "AND p.deleted_at IS NOT NULL " : ""}
          ${filter != 4 ? "AND p.deleted_at IS NULL " : ""}
          ORDER BY p.rank, p.name
          ${limit != null ? "LIMIT $limit" : ""}
        """
            .tidyCode();
        final sqlParams = <String, dynamic>{
          "client_id": session.clientId,
          if ((search?.isNotEmpty ?? false)) "search": "%$search%",
          "filter": filter,
        };

        log.logSql(context, sql, sqlParams);

        return (await api.select(sql, params: sqlParams))
            .map((row) => Program.fromMap(row, Convention.snake))
            .cast<Program>()
            .toList();
      });

  Future<int> insert(Program program) async => withSqlLog(context, () async {
        final sql = """
          INSERT INTO programs (
            program_id, client_id, card_id, name, type, countries, valid_from,
            ${program.locationId != null ? 'location_id, ' : ''}
            ${program.description != null ? 'description, ' : ''} 
            ${program.image != null ? 'image, ' : ''}
            ${program.imageBh != null ? 'image_bh, ' : ''} 
            ${program.validTo != null ? 'valid_to, ' : ''}
            ${program.meta != null ? 'meta, ' : ''}
            created_at
          ) VALUES (
            @program_id, @client_id, @card_id, @name, @type, @countries, @valid_from,
            ${program.locationId != null ? '@location_id, ' : ''}
            ${program.description != null ? '@description, ' : ''} 
            ${program.image != null ? '@image, ' : ''}
            ${program.imageBh != null ? '@image_bh, ' : ''} 
            ${program.validTo != null ? '@valid_to, ' : ''}
            ${program.meta != null ? '@meta, ' : ''}
            NOW() 
          )
        """
            .tidyCode();

        final sqlParams = program.toMap(Convention.snake);
        sqlParams["countries"] =
            program.countries != null ? "{${program.countries!.map((e) => e.code).join(",")}}" : null;

        log.logSql(context, sql, sqlParams);

        final inserted = await api.insert(sql, params: sqlParams);
        return inserted;
      });

  Future<int> update(Program program) async => withSqlLog(context, () async {
        final sql = """
          UPDATE programs SET 
            ${program.locationId != null ? 'location_id = @location_id, ' : ''}
            type = @type, digits = @digits, name = @name, card_id = @card_id,
            countries = @countries, valid_from = @valid_from,
            ${program.description != null ? 'description = @description, ' : ''} 
            ${program.image != null ? 'image = @image, ' : ''}
            ${program.imageBh != null ? 'image_bh = @image_bh, ' : ''} 
            ${program.validTo != null ? 'valid_to = @valid_to, ' : ''}
            ${program.meta != null ? 'meta = @meta, ' : ''}
            updated_at = NOW()
          WHERE program_id = @program_id AND client_id = @client_id AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = program.toMap(Convention.snake);
        sqlParams["digits"] = program.digits;
        sqlParams["countries"] =
            program.countries != null ? "{${program.countries!.map((e) => e.code).join(",")}}" : null;

        log.logSql(context, sql, sqlParams);

        final updated = await api.update(sql, params: sqlParams);
        return updated;
      });

  Future<(int, String)> patch(String programId, {bool? start, bool? finish, bool? blocked, bool? archived}) async =>
      withSqlLog(context, () async {
        final sql = """
          UPDATE programs SET
            ${start != null ? 'valid_from = intDateNow(), blocked = FALSE,' : ''}
            ${finish != null ? 'valid_to = intDateYesterday(),' : ''}
            ${blocked != null ? 'blocked = @blocked, ' : ''}
            ${archived == true ? 'deleted_at = NOW(), ' : ''}
            ${archived == false ? 'deleted_at = NULL, ' : ''}
            updated_at = NOW()
          WHERE client_id = @client_id AND program_id = @program_id
          RETURNING card_id
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "program_id": programId,
          "client_id": session.clientId,
          if (blocked != null) "blocked": (blocked ? 1 : 0),
        };

        log.logSql(context, sql, sqlParams);

        final (affected, result) = await api.updateWithResult(sql, params: sqlParams);
        return (affected, result.first["card_id"] as String);
      });

  Future<int> reorder(List<String> programIds) async => withSqlLog(context, () async {
        final sql = """
          UPDATE programs
          SET rank = array_position(@program_ids, program_id),
              updated_at = NOW()
          WHERE client_id = @client_id AND program_id = ANY(@program_ids)
        """
            .tidyCode();

        final sqlParams = {"client_id": session.clientId, "program_ids": programIds};

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
