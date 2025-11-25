import "package:core_dart/core_enums.dart";

import "../data_models/session.dart";

bool checkRoles(Session session, List<UserRole> allowedRoles) {
  final userRoles = session.userRoles;
  for (final role in userRoles) {
    if (allowedRoles.contains(role)) return true;
  }
  return false;
}

// eof
