import "package:collection/collection.dart";

enum UserRole {
  minimal,

  /// Administrator of client or system
  admin,

  /// Salesman in branch
  seller,

  /// Point of service
  pos,

  /// Order manager
  order,

  /// Delivery courier
  delivery,

  /// Reservation manager
  reservation,

  /// Report & statistics
  report,

  /// Marketing manager
  marketing,

  /// Support manager
  support,

  /// Owner of client or system
  owner,

  /// Development of system
  development,

  /// Finance manager of client or system
  finance,

  @Deprecated("Use owner or admin instead")
  superadmin,
}

extension UserRoleCode on UserRole {
  static final _codeMap = {
    UserRole.minimal: 0,
    UserRole.admin: 1,
    UserRole.seller: 2,
    UserRole.pos: 3,
    UserRole.order: 4,
    UserRole.delivery: 5,
    UserRole.reservation: 6,
    UserRole.report: 7,
    UserRole.marketing: 8,
    UserRole.support: 9,
    UserRole.owner: 10,
    UserRole.development: 11,
    UserRole.finance: 12,
  };

  int get code => _codeMap[this]!;

  static UserRole fromCode(int? code, {UserRole def = UserRole.minimal}) =>
      UserRole.values.firstWhere((r) => r.code == code, orElse: () => def);

  static UserRole? fromCodeOrNull(int? code) => UserRole.values.firstWhereOrNull((r) => r.code == code);

  static List<UserRole> fromCodes(List<int>? codes) {
    if (codes == null) return [];
    return codes.map((code) => fromCode(code)).toList();
  }

  static List<int> toCodes(List<UserRole>? roles) {
    if (roles == null) return [];
    return roles.map((role) => role.code).toList();
  }
}

extension UserRoles on UserRole {
  static List<UserRole> get all => UserRole.values;

  static List<UserRole> get customer => [UserRole.minimal];

  static List<UserRole> get client => [
        UserRole.admin,
        UserRole.pos,
        UserRole.order,
        UserRole.delivery,
        UserRole.reservation,
        UserRole.report,
        UserRole.marketing,
        UserRole.support,
        UserRole.owner,
        UserRole.finance,
      ];

  static List<UserRole> get partner => [UserRole.seller];
}

// eof
