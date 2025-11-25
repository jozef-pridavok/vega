import "package:collection/collection.dart";
import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

import "../../utils/storage.dart";

class ClientDAO extends ApiServerDAO {
  final ApiServerContext context;

  ClientDAO(this.context) : super(context.api);

  Future<List<Client>> list({required UserType? userType, required String clientId}) async =>
      withSqlLog(context, () async {
        final sql = """
          SELECT client_id, name, description, logo, logo_bh, color, 
            countries, categories, currency, settings
          ${userType == UserType.client ? ", meta" : ""}
          FROM clients
          WHERE client_id = @clientId AND deleted_at IS NULL
        """
            .tidyCode();

        final sqlParams = <String, dynamic>{
          "clientId": clientId,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.map<Client>((row) {
          final client = Client.fromMap(row, Client.snake);
          client.logo = api.storageUrl(client.logo, StorageObject.client, timeStamp: client.updatedAt);
          return client;
        }).toList();
      });

  Future<JsonObject?> clientByMeta(ReceiptProvider provider, String id) async => withSqlLog(context, () async {
        final sql = """
          SELECT * FROM clients
          WHERE clients.blocked = FALSE
            AND (clients.meta->'qrCodeScanning'->>'provider')::INT = @provider
            AND @id=ANY(jsonb_array_to_text_array((clients.meta->'qrCodeScanning'->>'providerId')::JSONB))
          LIMIT 1
        """;

        final sqlParams = <String, dynamic>{"provider": provider.code, "id": id};

        log.logSql(context, sql, sqlParams);

        return (await api.select(sql, params: sqlParams)).firstOrNull;
      });
}

// eof
