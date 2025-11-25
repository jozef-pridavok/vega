import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../data_models/session.dart";

class ClientDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  ClientDAO(this.session, this.context) : super(context.api);

  Future<IntDate?> getClientLicense(String clientId) async => withSqlLog(context, () async {
        final sql = """
          SELECT COALESCE((meta->'license'->'validTo')::INT, 0) as valid_to
          FROM clients
          WHERE client_id = @client_id AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"client_id": clientId};
        log.logSql(context, sql, sqlParams);
        final rows = await api.select(sql, params: sqlParams);
        final row = rows.first;
        final license = row["valid_to"] as int;
        return IntDate.parseInt(license);
      });

  Future<List<ClientPaymentProvider>> readPaymentProviders(String clientId) async => withSqlLog(context, () async {
        // Tento select vráti providerov, ale v inom poradí ako je to povedané v clients.meta{license.providers}

        /*
        final sql = """
          SELECT client_payment_provider_id, name, type,fixed_price, currency, percentage, meta->'clientConfig' AS client_config
          FROM client_payment_providers
          WHERE deleted_at IS NULL AND client_payment_provider_id IN (
              SELECT jsonb_array_elements_text((meta->'license'->>'providers')::JSONB)
              FROM clients
              WHERE client_id = @client_id
          )
        """;
        */

        final sql = """
          SELECT 
              cpp.client_payment_provider_id, 
              cpp.name, 
              cpp.type, 
              cpp.fixed_price, 
              cpp.currency, 
              cpp.percentage, 
              cpp.meta->'clientConfig' AS client_config,
              idx
          FROM 
              client_payment_providers cpp
          JOIN (
              SELECT 
                  jsonb_array_elements_text((meta->'license'->>'providers')::JSONB) as provider_id,
                  row_number() over() as idx
              FROM 
                  clients
              WHERE 
                  client_id = @client_id
          ) as c
          ON cpp.client_payment_provider_id = c.provider_id
          WHERE  cpp.deleted_at IS NULL
          ORDER BY c.idx
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"client_id": clientId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => ClientPaymentProvider.fromMap(row, ClientPaymentProvider.snake)).toList();
      });

  Future<(String?, String?, JsonObject?)> getStripeCustomerId(String clientId) async => withSqlLog(context, () async {
        final sql = """
          SELECT 
            name,
            meta->>'stripeCustomerId' AS stripe_customer_id,
            (meta->'invoicing')::JSONB AS invoicing
          FROM clients
          WHERE client_id = @client_id AND deleted_at IS NULL AND blocked = FALSE
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"client_id": clientId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        final row = rows.first;

        final clientName = row["name"] as String?;
        final stripeCustomerId = row["stripe_customer_id"] as String?;
        final invoicing = row["invoicing"] as JsonObject?;

        return (clientName, stripeCustomerId, invoicing);
      });

  Future<List<UserCard>?> selectUserCards({int? period, String? filter, String? programId, String? cardId}) async =>
      withSqlLog(context, () async {
        final hasFilter = filter != null && filter.isNotEmpty;
        final sql = """
          SELECT 
            TO_JSON(ARRAY(
                SELECT json_build_object(
                  'program_id', p.program_id, 'name', p.name,
                  'plural', COALESCE((p.meta->>'plural')::JSONB, '{}'::JSONB), 
                  'type', p.type,  
                  'user_points', (
                    SELECT COALESCE(SUM(lt.points), 0)
                    FROM loyalty_transactions lt
                    WHERE lt.user_card_id = uc.user_card_id AND lt.program_id = p.program_id
                  ),
                  'digits', p.digits
                )
                FROM programs AS p
                WHERE 
                  ${programId != null ? 'p.program_id = @program_id AND' : ''}
                  p.card_id = cd.card_id AND
                  p.client_id = cl.client_id AND NOT (p.valid_from > intDateNow() AND COALESCE(p.valid_to > intDateNow(), true))
            )) AS programs,
            uc.user_card_id, uc.user_id, uc.card_id, uc.client_id, uc.code_type, 
            cd.name, uc.number, COALESCE(u.meta->'clients'->'${session.clientId}'->>'displayName', u.nick) AS user_name,
            uc.touched_at as last_activity, uc.points
          FROM user_cards uc
          INNER JOIN users u ON uc.user_id = u.user_id
          INNER JOIN clients cl ON cl.client_id = uc.client_id 
          INNER JOIN cards cd ON cd.card_id = uc.card_id AND cd.client_id = cl.client_id AND cd.client_id = uc.client_id AND cd.deleted_at IS NULL
          WHERE cl.client_id = @client_id AND uc.deleted_at IS NULL
            ${cardId != null ? 'AND uc.card_id = @card_id ' : ''}        
            ${period != null && period > 0 ? 'AND uc.touched_at > NOW() - (@period::TEXT || \' days\')::INTERVAL ' : ''}
            ${period != null && period < 0 ? 'AND uc.touched_at < NOW() - ((cl.meta->\'license\'->\'activityPeriod\')::TEXT || \' days\')::INTERVAL ' : ''}
            ${programId != null ? 'AND EXISTS (SELECT 1 FROM programs WHERE program_id = @program_id AND card_id = uc.card_id AND client_id = uc.client_id) ' : ''}
            ${hasFilter ? 'AND (' : ''}
            ${hasFilter ? 'uc.number ILIKE \'%\' || @filter || \'%\' ' : ''}
            ${hasFilter ? 'OR uc.name ILIKE \'%\' || @filter || \'%\' ' : ''}
            ${hasFilter ? 'OR cd.name ILIKE \'%\' || @filter || \'%\' ' : ''}
            ${hasFilter ? 'OR u.nick ILIKE \'%\' || @filter || \'%\' ' : ''}
            ${hasFilter ? 'OR u.meta->\'clients\'->\'${session.clientId}\'->>\'displayName\' ILIKE \'%\' || @filter || \'%\' ' : ''}
            ${hasFilter ? 'OR u.meta->\'clients\'->\'${session.clientId}\'->>\'name\' ILIKE \'%\' || @filter || \'%\' ' : ''}
            ${hasFilter ? 'OR u.meta->\'clients\'->\'${session.clientId}\'->>\'firstName\' ILIKE \'%\' || @filter || \'%\' ' : ''}
            ${hasFilter ? 'OR u.meta->\'clients\'->\'${session.clientId}\'->>\'secondName\' ILIKE \'%\' || @filter || \'%\' ' : ''}
            ${hasFilter ? 'OR u.meta->\'clients\'->\'${session.clientId}\'->>\'thirdName\' ILIKE \'%\' || @filter || \'%\' ' : ''}
            ${hasFilter ? 'OR u.meta->\'clients\'->\'${session.clientId}\'->>\'lastName\' ILIKE \'%\' || @filter || \'%\' ' : ''}
            ${hasFilter ? ') ' : ''}
          ORDER BY uc.updated_at DESC
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "client_id": session.clientId,
          if (cardId != null) "card_id": cardId,
          if (programId != null) "program_id": programId,
          if (period != null) "period": period,
          if (hasFilter) "filter": filter,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) return null;

        return rows.map((row) => UserCard.fromMap(row, Convention.snake)).toList();
      });

  Future<Client?> select(String clientId) async => withSqlLog(context, () async {
        final sql = """
          SELECT client_id, name, description, logo, logo_bh, color, countries, settings, meta, updated_at
          FROM clients
          WHERE blocked = FALSE AND client_id=@clientId
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"clientId": clientId};

        log.logSql(context, sql, sqlParams);

        final results = await api.select(sql, params: sqlParams);
        if (results.isEmpty) return null;

        return Client.fromMap(results.first, Client.snake);
      });

  /// Do not save meta!
  Future<int> update(Client client) async => withSqlLog(context, () async {
        final sql = """
          UPDATE clients SET
            name = @name, countries = @countries, color = @color,
            ${client.description != null ? 'description = @description, ' : ''} 
            ${client.logo != null ? 'logo = @logo, ' : ''}
            ${client.logoBh != null ? 'logo_bh = @logo_bh, ' : ''} 
            ${client.settings != null ? 'settings = @settings, ' : ''}
            updated_at = NOW()
          WHERE client_id = @client_id AND deleted_at IS NULL
        """
            .tidyCode();

        // Update meta except {license}
//         ${client.meta != null ? 'meta = jsonb_set(@meta, \'license\', COALESCE((meta->\'license\')::jsonb, \'{}\'::jsonb), true), ' : ''}

        final sqlParams = client.toMap(Client.snake);
        sqlParams["countries"] =
            client.countries != null ? "{${client.countries!.map((e) => e.code).join(",")}}" : null;

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<List<User>> selectUsers(String clientId, {bool? blocked, String? like}) async => withSqlLog(context, () async {
        final sql = """
          SELECT user_id, client_id, login, email, nick, roles, user_type, folders, blocked, meta
          FROM users
          WHERE client_id = @client_id AND deleted_at IS NULL
            ${blocked != null ? 'AND blocked = @blocked ' : ''}
            ${like != null ? 'AND (LOWER(UNACCENT(nick)) LIKE (\'%\' || LOWER(UNACCENT(@like)) || \'%\') OR LOWER(UNACCENT(login)) LIKE (\'%\' || LOWER(UNACCENT(@like))) || \'%\') ' : ''}
          ORDER BY created_at DESC
        """;

        final sqlParams = <String, dynamic>{
          "client_id": clientId,
          "like": like,
          if (blocked != null) "blocked": blocked ? 1 : 0,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        if (rows.isEmpty) return [];

        return rows.map((row) => User.fromMap(row, User.snake)).toList();
      });

  Future<int?> getDemoCredit(String clientId) async => withSqlLog(context, () async {
        final sql = """
          SELECT name, (meta->>'demoCredit')::INT AS demo_credit
          FROM clients
          WHERE client_id = @client_id AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"client_id": clientId};

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return tryParseInt(rows.first["demo_credit"]);
      });

  Future<int> setDemoCredit(String clientId, int demoCredit) async => withSqlLog(context, () async {
        final sql = """
          UPDATE clients SET meta = JSONB_SET(meta, '{demoCredit}', @demo_credit::JSONB, TRUE)
          WHERE client_id = @client_id  
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "client_id": clientId,
          "demo_credit": demoCredit,
        };

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<bool> setStripeCustomerId(String clientId, String customerId) async => withSqlLog(context, () async {
        final sql = """
          UPDATE clients
            SET meta = JSONB_SET(meta, '{stripeCustomerId}', TO_JSON(@customer_id::TEXT)::JSONB, TRUE)
          WHERE client_id = @client_id AND deleted_at IS NULL AND blocked = FALSE
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "client_id": clientId,
          "customer_id": customerId,
        };

        log.logSql(context, sql, sqlParams);

        return (await api.update(sql, params: sqlParams)) == 1;
      });

  Future<int> updateClientRating(String clientId, int rating) async => withSqlLog(context, () async {
        final sql = """
          UPDATE clients 
            SET 
              meta = jsonb_set(
                meta, 
                '{rating}', 
                to_jsonb(@rating), 
                true
              ),
              updated_at = NOW()
            WHERE client_id = @client_id
        """;

        final sqlParams = <String, dynamic>{"client_id": clientId, "rating": rating};

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
