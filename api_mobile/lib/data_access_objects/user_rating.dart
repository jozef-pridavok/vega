import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

class UserRatingDAO extends ApiServerDAO {
  final ApiServerContext context;

  UserRatingDAO(this.context) : super(context.api);

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
              UPDATE user_ratings
              SET rating = @rating, language = @language
              ${comment != null ? ', comment = @comment ' : ''}
              WHERE user_id = @user_id AND client_id = @client_id
              RETURNING user_rating_id
          )
          INSERT INTO user_ratings 
            (user_rating_id, user_id, client_id, rating, language
            ${comment != null ? ', comment ' : ''}
            )
          SELECT @user_rating_id, @user_id, @client_id, @rating, @language
            ${comment != null ? ', @comment ' : ''}
          WHERE NOT EXISTS (SELECT user_rating_id FROM upsert);
        """
            .tidyCode();

        final sqlParams = {
          "user_rating_id": uuid(),
          "user_id": userId,
          "client_id": clientId,
          "rating": rating,
          if (comment != null) "comment": comment,
        };

        log.logSql(context, sql, sqlParams);

        return await api.insert(sql, params: sqlParams);
      });

  Future<int?> getUserRating({required String userId}) async => withSqlLog(context, () async {
        final sql = """
          WITH user_ratings_filtered AS (
              SELECT rating
              FROM user_ratings
              WHERE user_id = @user_id AND deleted_at IS NULL
          )
          SELECT ROUND((AVG(rating) / 5.0) * 10000) AS rating
          FROM user_ratings_filtered;
        """
            .tidyCode();

        final sqlParams = {
          "user_id": userId,
        };

        log.logSql(context, sql, sqlParams);

        final result = await api.select(sql, params: sqlParams);
        return result[0]["rating"] as int?;
      });
}

// eof
