import "../../core_dart.dart";

enum ClientPaymentProviderKeys {
  clientPaymentProviderId,
  name,
  type,
  fixedPrice,
  currency,
  percentage,
  clientConfig,
}

class ClientPaymentProvider {
  String clientPaymentProviderId;
  String name;
  ClientPaymentProviderType type;
  int fixedPrice;
  Currency currency;
  int percentage; // in bps, 1 = 0.01%, 25 = 0.25%, 425 = 4.25%, 100 = 1%, 1000 = 10%, 10000 = 100%
  JsonObject? clientConfig;

  ClientPaymentProvider({
    required this.clientPaymentProviderId,
    required this.name,
    required this.type,
    required this.fixedPrice,
    required this.currency,
    required this.percentage,
    this.clientConfig,
  });

  static const camel = {
    ClientPaymentProviderKeys.clientPaymentProviderId: "clientPaymentProviderId",
    ClientPaymentProviderKeys.name: "name",
    ClientPaymentProviderKeys.type: "type",
    ClientPaymentProviderKeys.fixedPrice: "fixedPrice",
    ClientPaymentProviderKeys.currency: "currency",
    ClientPaymentProviderKeys.percentage: "percentage",
    ClientPaymentProviderKeys.clientConfig: "clientConfig",
  };

  static const snake = {
    ClientPaymentProviderKeys.clientPaymentProviderId: "client_payment_provider_id",
    ClientPaymentProviderKeys.name: "name",
    ClientPaymentProviderKeys.type: "type",
    ClientPaymentProviderKeys.fixedPrice: "fixed_price",
    ClientPaymentProviderKeys.currency: "currency",
    ClientPaymentProviderKeys.percentage: "percentage",
    ClientPaymentProviderKeys.clientConfig: "client_config",
  };

  static ClientPaymentProvider fromMap(Map<String, dynamic> map, Map<ClientPaymentProviderKeys, String> mapper) =>
      ClientPaymentProvider(
        clientPaymentProviderId: map[mapper[ClientPaymentProviderKeys.clientPaymentProviderId]] as String,
        name: map[mapper[ClientPaymentProviderKeys.name]] as String,
        type: ClientPaymentProviderTypeCode.fromCode(map[mapper[ClientPaymentProviderKeys.type]] as int),
        fixedPrice: map[mapper[ClientPaymentProviderKeys.fixedPrice]] as int,
        currency: CurrencyCode.fromCode(map[mapper[ClientPaymentProviderKeys.currency]] as String),
        percentage: map[mapper[ClientPaymentProviderKeys.percentage]] as int,
        clientConfig: map[mapper[ClientPaymentProviderKeys.clientConfig]] as JsonObject?,
      );

  Map<String, dynamic> toMap(Map<ClientPaymentProviderKeys, String> mapper) => {
        mapper[ClientPaymentProviderKeys.clientPaymentProviderId]!: clientPaymentProviderId,
        mapper[ClientPaymentProviderKeys.name]!: name,
        mapper[ClientPaymentProviderKeys.type]!: type.code,
        mapper[ClientPaymentProviderKeys.fixedPrice]!: fixedPrice,
        mapper[ClientPaymentProviderKeys.currency]!: currency.code,
        mapper[ClientPaymentProviderKeys.percentage]!: percentage,
        if (clientConfig != null) mapper[ClientPaymentProviderKeys.clientConfig]!: clientConfig,
      };
}

// eof
