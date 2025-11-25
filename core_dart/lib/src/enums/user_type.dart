import "package:collection/collection.dart";

enum UserType {
  /// Root user of system
  root,

  /// End user (customer of client with mobile app)
  customer,

  /// Client of our platform
  client,

  // Partner of our platform
  partner,
}

extension UserTypeCode on UserType {
  static final _codeMap = {
    UserType.root: 1,
    UserType.customer: 2,
    UserType.client: 3,
    UserType.partner: 4,
  };
  int get code => _codeMap[this]!;

  static UserType fromCode(int? code, {UserType def = UserType.customer}) =>
      UserType.values.firstWhere((r) => r.code == code, orElse: () => def);

  static UserType? fromCodeOrNull(int? code) => UserType.values.firstWhereOrNull((r) => r.code == code);
}

// eof
