import "package:api_mobile/implementations/api_shelf2.dart";
import "package:postgres/postgres.dart" as psql;

extension MobileApiPostgres on MobileApi {
  Future<psql.Connection> connectPostgres() async {
    return await psql.Connection.open(
      psql.Endpoint(
        host: config.postgresHost,
        port: config.postgresPort,
        database: config.postgresDatabase,
        username: config.postgresUsername,
        password: config.postgresPassword,
      ),
      settings: psql.PoolSettings(
        sslMode: config.postgresSslMode == "require" ? psql.SslMode.require : psql.SslMode.disable,
        connectTimeout: const Duration(seconds: 5),
        queryTimeout: Duration(seconds: config.isDev ? 3 : 15),
        ignoreSuperfluousParameters: true,
      ),
    );
  }

  Future<psql.Result> executeSqlCommand(psql.Connection connection, dynamic sql,
          {Map<String, dynamic>? params}) async =>
      await connection.execute(psql.Sql.named(sql), parameters: params);
}

// eof
