import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../utils/storage.dart";

class CardDAO extends ApiServerDAO {
  final ApiServerContext context;

  CardDAO(this.context) : super(context.api);

  Future<List<Card>> list({String? country}) async => withSqlLog(context, () async {
        final sql = """
          SELECT k.card_id, k.client_id, k.name, k.logo, k.color
          FROM cards k
          LEFT JOIN clients c ON c.client_id = k.client_id AND c.deleted_at IS NULL
          WHERE k.deleted_at IS NULL AND k.blocked = FALSE            
            ${country != null ? ' AND UPPER(@country) = ANY(k.countries || c.countries)' : ''}
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          if (country != null) "country": country,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map<Card>((row) {
          final card = Card.fromMap(row, Convention.snake);
          card.logo = api.storageUrl(card.logo, StorageObject.card, timeStamp: card.updatedAt);
          return card;
        }).toList();
      });

  /// Returns top cards for user (country based on session).
  Future<List<Card>> top({Country? country, int? limit}) async => withSqlLog(context, () async {
        final sql = """
          SELECT k.card_id, k.client_id, k.name, k.logo, k.color, 
            (k.countries || c.countries) AS countries, k.rank
          FROM cards k
          LEFT JOIN clients c ON c.client_id = k.client_id AND c.deleted_at IS NULL AND c.blocked = FALSE
          WHERE k.blocked = FALSE AND k.deleted_at IS NULL  
            ${country != null ? ' AND EXISTS (SELECT 1 FROM unnest(k.countries || c.countries) AS country WHERE country ILIKE @country)' : ''}          
          ORDER BY k.name ASC
          LIMIT @limit
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          if (country != null) "country": country.code,
          "limit": limit ?? 25,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map<Card>((row) {
          final card = Card.fromMap(row, Convention.snake);
          card.logo = api.storageUrl(card.logo, StorageObject.card, timeStamp: card.updatedAt);
          return card;
        }).toList();
      });

  Future<List<Card>> search({
    required String term,
    Country? country,
    int? limit,
    required bool otherCountries,
  }) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT card_id, client_id, name, logo, color, countries, rank, jaro_winkler FROM (
            SELECT k.card_id, k.client_id, k.name, k.logo, k.color, 
              (k.countries || c.countries) AS countries, k.rank, jaro_winkler(k.name, @term) AS jaro_winkler
            FROM cards k
            LEFT JOIN clients c ON c.client_id = k.client_id AND c.deleted_at IS NULL AND c.blocked = FALSE
            WHERE k.blocked = FALSE AND k.deleted_at IS NULL  
              ${country != null ? ' AND ${otherCountries ? 'NOT' : ''}(UPPER(@country) = ANY(k.countries || c.countries))' : ''}
          ) subq
          WHERE jaro_winkler > 0.625
          ORDER BY jaro_winkler DESC
          LIMIT @limit
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "term": term,
          if (country != null) "country": country.code,
          "limit": limit ?? 25,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map<Card>((row) {
          final card = Card.fromMap(row, Convention.snake);
          card.logo = api.storageUrl(card.logo, StorageObject.card, timeStamp: card.updatedAt);
          return card;
        }).toList();
      });
}

// eof
