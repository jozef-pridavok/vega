import "package:core_dart/core_dart.dart";

class Session {
  final String userId;
  final UserType? userType;
  final String? login;
  final String? email;
  final List<UserRole> userRoles;
  final String? language;
  final Country? country;
  final String? clientId;
  final String installationId;
  final int timeZoneOffset;

  Session({
    required this.userId,
    required this.userType,
    required this.login,
    required this.email,
    required this.userRoles,
    required this.language,
    required this.country,
    required this.clientId,
    required this.installationId,
    required this.timeZoneOffset,
  });

  bool get isAnonymous => (email?.isEmpty ?? true) && (login?.isEmpty ?? true);
  bool get isNotAnonymous => !isAnonymous;

  JsonObject toJson() => {
        "installationId": installationId,
        "userId": userId,
        if (userType != null) "userType": userType!.code,
        if (login != null) "login": login,
        if (email != null) "email": email,
        if (userRoles.isNotEmpty) "userRoles": userRoles.map((e) => e.code).toList(),
        if (language != null) "language": language,
        if (country != null) "country": country!.code,
        if (clientId != null) "clientId": clientId,
        if (timeZoneOffset != 0) "timeZoneOffset": timeZoneOffset,
      };

  static Session fromJson(JsonObject json) => Session(
        installationId: json["installationId"] as String,
        userId: json["userId"] as String,
        userType: json["userType"] != null ? UserTypeCode.fromCode(json["userType"] as int) : null,
        login: json["login"] as String?,
        email: json["email"] as String?,
        userRoles: UserRoleCode.fromCodes((json["userRoles"] as List<dynamic>?)?.cast<int>() ?? []),
        language: json["language"] as String?,
        country: CountryCode.fromCodeOrNull(json["country"] as String?),
        clientId: json["clientId"] as String?,
        timeZoneOffset: json["timeZoneOffset"] as int? ?? 0,
      );
}

// eof
