import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../api_v1/check_role.dart";
import "../data_models/session.dart";

class SellerClientDAO extends ApiServerDAO {
  final ApiServerContext context;
  final Session session;

  SellerClientDAO(this.session, this.context) : super(context.api);

  Future<List<Client>> readAll({
    required String sellerId,
    required String like,
    String? country,
    int? filter = 1,
    bool? blocked,
  }) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT c.client_id, c.name, c.logo, c.logo_bh, c.color, c.countries, c.categories, c.currency,
            c.settings, c.blocked, c.meta
          FROM clients c
          INNER JOIN client_sellers cs ON cs.client_id = c.client_id        
          WHERE cs.seller_id = @seller_id AND cs.blocked = FALSE AND c.deleted_at is NULL
            ${filter == 1 ? ' AND c.deleted_at IS NULL ' : 'AND c.deleted_at IS NOT NULL'}
            ${country != null ? ' AND @country=ANY(c.countries)' : ''}
            ${blocked != null ? ' AND c.blocked = @blocked' : ''}
            ${like.isNotEmpty ? ' AND LOWER(UNACCENT(c.name)) LIKE LOWER(UNACCENT(@like))' : ''}
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "seller_id": sellerId,
          if (country != null) "country": country,
          if (blocked != null) "blocked": blocked ? 1 : 0,
          if (like.isNotEmpty) "like": like,
          "filter": filter,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map((row) => Client.fromMap(row, Client.snake)).cast<Client>().toList();
      });

  Future<int> create(Client client, String sellerId) async => withSqlLog(context, () async {
        // client.meta.accountPrefix must be unigue

        var sql = "SELECT * FROM clients WHERE meta->>'accountPrefix' = @accountPrefix AND deleted_at IS NULL";
        var sqlParams = <String, dynamic>{"accountPrefix": client.meta?["accountPrefix"]};

        log.logSql(context, sql, sqlParams);

        final result = await api.select(sql, params: sqlParams);
        if (result.isNotEmpty) return 0;

        sql = """
          INSERT INTO clients
          (
            client_id, name, color, countries, categories, currency,
            ${client.description != null ? 'description, ' : ''}
            ${client.logo != null ? 'logo , ' : ''}
            ${client.logoBh != null ? 'logo_bh, ' : ''}
            ${client.meta != null ? 'meta, ' : ''}
            created_at
          ) VALUES ( 
            @client_id, @name,  @color, @countries, @categories, @currency,
            ${client.description != null ? '@description, ' : ''}
            ${client.logo != null ? '@logo, ' : ''}
            ${client.logoBh != null ? '@logo_bh, ' : ''}
            ${client.meta != null ? ' @meta, ' : ''}
            NOW()
          )
        """
            .tidyCode();

        if (IntDate.parseInt(client.metaLicense[Client.keyMetaLicenseValidTo] as int?) == null) {
          final validTo = IntDate.fromDate(DateTime.now().add(const Duration(days: 30)));
          client.metaLicense[Client.keyMetaLicenseValidTo] = validTo.value;
        }
        if (CurrencyCode.fromCodeOrNull(client.metaLicense[Client.keyMetaLicenseCurrency]) == null) {
          client.metaLicense[Client.keyMetaLicenseCurrency] = client.currency.code;
        }

        sqlParams = client.toMap(Client.snake);
        sqlParams["countries"] =
            client.countries != null ? "{${client.countries!.map((e) => e.code).join(",")}}" : null;
        sqlParams["categories"] =
            client.categories != null ? "{${client.categories!.map((e) => e.code).join(",")}}" : null;

        log.logSql(context, sql, sqlParams);

        final created = await api.insert(sql, params: sqlParams);
        if (created == 1) {
          sql = """
            INSERT INTO client_sellers (client_seller_id, seller_id, client_id, share, created_at)
            SELECT @client_seller_id::VARCHAR, @seller_id::VARCHAR, @client_id::VARCHAR, COALESCE((meta->'seller'->>'share')::INT, 2500), NOW()
            FROM users
            WHERE user_id = @seller_id;
          """
              .tidyCode();

          sqlParams = <String, dynamic>{
            "client_seller_id": uuid(),
            "seller_id": sellerId,
            "client_id": client.clientId,
          };

          log.logSql(context, sql, sqlParams);

          final inserted = await api.insert(sql, params: sqlParams);
          if (inserted != 1) {
            // TODO: tu sa nepodarilo uložiť seller_client, treba rollback alebo vymazať klienta vyššie vytvoreného
            return 0;
          }
        }

        return created;
      });

  Future<int> update(Client client) async => withSqlLog(context, () async {
        if (!checkRoles(session, [UserRole.seller])) return 0;

        // keep {license.validTo}
        final sql = """
          UPDATE clients SET
            name = @name, countries = @countries, categories = @categories, currency = @currency,
            ${client.description != null ? 'description = @description, ' : ''}  
            ${client.logo != null ? 'logo = @logo, ' : ''}
            ${client.logoBh != null ? 'logo_bh = @logo_bh, ' : ''} 
            ${client.meta != null ? 'meta = jsonb_set(@meta, \'{license,validTo}\', to_jsonb(COALESCE((meta->\'license\'->\'validTo\')::int, 0)), true), ' : ''} 
            updated_at = NOW()
          WHERE client_id = @client_id AND deleted_at IS NULL
        """
            .tidyCode();

//         ${client.meta != null ? 'meta = @meta || jsonb_build_object(\'license\', COALESCE((meta->>\'license\')::JSONB, \'{}\'::JSONB))::jsonb , ' : ''}

        final sqlParams = client.toMap(Client.snake);
        sqlParams["countries"] =
            client.countries != null ? "{${client.countries!.map((e) => e.code).join(",")}}" : null;
        sqlParams["categories"] =
            client.categories != null ? "{${client.categories!.map((e) => e.code).join(",")}}" : null;

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });

  Future<int> patch(String clientId, {bool? blocked, bool? archived, int? demoCredit}) async =>
      withSqlLog(context, () async {
        /*
          clients.meta = {"demoCredit": 100}
        */
        final sql = """
          UPDATE clients SET
            ${blocked != null ? 'blocked = @blocked, ' : ''}
            ${archived == true ? 'deleted_at = NOW(), ' : ''}
            ${archived == false ? 'deleted_at = NULL, ' : ''}
            ${demoCredit != null ? 'meta = jsonb_set(meta, \'{demoCredit}\', to_jsonb(@demoCredit::INT), true), ' : ''}
            updated_at = NOW()
          WHERE client_id = @client_id
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{"client_id": clientId};
        if (blocked != null) sqlParams["blocked"] = blocked ? 1 : 0;
        if (demoCredit != null) sqlParams["demoCredit"] = demoCredit;

        log.logSql(context, sql, sqlParams);

        return await api.update(sql, params: sqlParams);
      });
}

// eof
