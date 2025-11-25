import "package:core_dart/core_api_server2.dart";
import "package:core_dart/core_dart.dart";

class ClientPaymentProviderDAO extends ApiServerDAO {
  final ApiServerContext context;

  ClientPaymentProviderDAO(this.context) : super(context.api);

  Future<List<ClientPaymentProvider>> select() async => withSqlLog(context, () async {
        final sql = """
          SELECT client_payment_provider_id, name, type, fixed_price, currency, meta, percentage
          FROM client_payment_providers 
          WHERE deleted_at IS NULL
          ORDER BY name
        """
            .tidyCode();

        log.logSql(context, sql);

        final rows = await api.select(sql);

        return rows.map((row) => ClientPaymentProvider.fromMap(row, ClientPaymentProvider.snake)).toList();
      });

  Future<String?> getStripePrivateKey(String clientPaymentProviderId) async => withSqlLog(context, () async {
        final sql = """
          SELECT meta->>'privateKey' AS private_key
          FROM client_payment_providers
          WHERE client_payment_provider_id = @client_payment_provider_id
          LIMIT 1
        """;

        final sqlParams = <String, dynamic>{
          "client_payment_provider_id": clientPaymentProviderId,
        };

        log.logSql(context, sql, sqlParams);

        final rows = await api.select(sql, params: sqlParams);
        return rows.first["private_key"] as String?;
      });
}

// eof
