import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

class ClientRatingDAO extends ApiServerDAO {
  final ApiServerContext context;

  ClientRatingDAO(this.context) : super(context.api);

  Future<List<JsonObject>> list({
    required String clientId,
    String? language,
    int? limit,
  }) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT client_rating_id, rating, comment
          FROM client_ratings
          WHERE client_id = @client_id AND deleted_at IS NULL
          ${language != null ? ' AND language = @language ' : ''}
          ORDER BY created_at DESC
          ${limit != null ? ' LIMIT @limit ' : ''}
        """
            .tidyCode();

        final sqlParams = {
          "client_id": clientId,
          if (language != null) "language": language,
        };

        log.logSql(context, sql, sqlParams);

        return await api.select(sql, params: sqlParams);
      });

  Future<int> upsert({
    required String clientId,
    required String userId,
    required int rating,
    required String language,
    String? comment,
  }) async =>
      withSqlLog(context, () async {
        final sql = """
          WITH upsert AS (
              UPDATE client_ratings
              SET rating = @rating, language = @language
              ${comment != null ? ', comment = @comment ' : ''}
              WHERE user_id = @user_id AND client_id = @client_id
              RETURNING client_rating_id
          )
          INSERT INTO client_ratings 
            (client_rating_id, client_id, user_id, rating, language
            ${comment != null ? ', comment ' : ''}
            )
          SELECT @client_rating_id, @client_id, @user_id, @rating, @language
            ${comment != null ? ', @comment ' : ''}
          WHERE NOT EXISTS (SELECT client_rating_id FROM upsert);
        """
            .tidyCode();

        final sqlParams = {
          "client_rating_id": uuid(),
          "client_id": clientId,
          "user_id": userId,
          "rating": rating,
          if (comment != null) "comment": comment,
        };

        log.logSql(context, sql, sqlParams);

        return await api.insert(sql, params: sqlParams);
      });

  Future<int?> getClientRating({required String clientId}) async => withSqlLog(context, () async {
        final sql = """
          WITH client_ratings_filtered AS (
              SELECT rating
              FROM client_ratings
              WHERE client_id = @client_id AND deleted_at IS NULL
          )
          SELECT ROUND((AVG(rating) / 5.0) * 10000) AS rating
          FROM client_ratings_filtered;
        """
            .tidyCode();

        final sqlParams = {
          "client_id": clientId,
        };

        log.logSql(context, sql, sqlParams);

        final result = await api.select(sql, params: sqlParams);
        return result[0]["rating"] as int?;
      });
}

// eof
