import "package:collection/collection.dart";

enum ClientPaymentProviderType {
  cash,
  stripe,
  googlePay,
  applePay,
  btcServer,
  paypal,
  bankTransfer,
  demoCredit,
}

extension ClientPaymentProviderTypeCode on ClientPaymentProviderType {
  static final _codeMap = {
    ClientPaymentProviderType.cash: 1,
    ClientPaymentProviderType.stripe: 2,
    ClientPaymentProviderType.googlePay: 3,
    ClientPaymentProviderType.applePay: 4,
    ClientPaymentProviderType.btcServer: 5,
    ClientPaymentProviderType.paypal: 6,
    ClientPaymentProviderType.bankTransfer: 7,
    ClientPaymentProviderType.demoCredit: 8,
  };

  int get code => _codeMap[this]!;

  static ClientPaymentProviderType fromCode(int? code,
          {ClientPaymentProviderType def = ClientPaymentProviderType.cash}) =>
      ClientPaymentProviderType.values.firstWhere((r) => r.code == code, orElse: () => def);

  static ClientPaymentProviderType? fromCodeOrNull(int? code) =>
      ClientPaymentProviderType.values.firstWhereOrNull((r) => r.code == code);
}

// eof
