import "../../core_dart.dart";

enum UserKeys {
  userId,
  userType,
  clientId,
  roles,
  login,
  email,
  nick,
  gender,
  yob,
  language,
  country,
  theme,
  emailVerified,
  blocked,
  folders,
  meta,
}

class User {
  String userId;
  UserType userType;
  String? clientId;
  List<UserRole> roles;
  String? login;
  String? email;
  String? nick;
  Gender? gender;
  int? yob;
  String? language;
  String? country;
  Theme theme;
  bool emailVerified;
  bool blocked;
  String? selectedFolder;
  Folders folders;
  Map<String, dynamic>? meta;

  bool get isAnonymous => (login?.isEmpty ?? true) && (email?.isEmpty ?? true);
  bool get isNotAnonymous => !isAnonymous;

  late final bool isAdmin;
  late final bool isPos;
  late final bool isOrder;
  late final bool isDelivery;
  late final bool isReservation;
  late final bool isReport;
  late final bool isMarketing;
  late final bool isSupport;
  late final bool isFinance;
  late final bool isOwner;
  late final bool isDevelopment;
  late final bool isSeller;

  User({
    required this.userId,
    required this.userType,
    this.clientId,
    required this.roles,
    this.login,
    this.email,
    this.nick,
    this.gender,
    this.yob,
    this.language,
    this.country,
    this.theme = Theme.system,
    this.emailVerified = false,
    this.blocked = false,
    this.selectedFolder,
    this.folders = Folders.empty,
    this.meta,
  })  : isAdmin = roles.contains(UserRole.admin),
        isPos = roles.contains(UserRole.pos),
        isOrder = roles.contains(UserRole.order),
        isDelivery = roles.contains(UserRole.delivery),
        isReservation = roles.contains(UserRole.reservation),
        isReport = roles.contains(UserRole.report),
        isMarketing = roles.contains(UserRole.marketing),
        isSupport = roles.contains(UserRole.support),
        isFinance = roles.contains(UserRole.finance),
        isOwner = roles.contains(UserRole.owner),
        isDevelopment = roles.contains(UserRole.development),
        isSeller = roles.contains(UserRole.seller);

  static const camel = {
    UserKeys.userId: "userId",
    UserKeys.userType: "userType",
    UserKeys.clientId: "clientId",
    UserKeys.roles: "roles",
    UserKeys.login: "login",
    UserKeys.email: "email",
    UserKeys.nick: "nick",
    UserKeys.gender: "gender",
    UserKeys.yob: "yob",
    UserKeys.language: "language",
    UserKeys.country: "country",
    UserKeys.theme: "theme",
    UserKeys.emailVerified: "emailVerified",
    UserKeys.blocked: "blocked",
    UserKeys.folders: "folders",
    UserKeys.meta: "meta",
  };

  static const snake = {
    UserKeys.userId: "user_id",
    UserKeys.userType: "user_type",
    UserKeys.clientId: "client_id",
    UserKeys.roles: "roles",
    UserKeys.login: "login",
    UserKeys.email: "email",
    UserKeys.nick: "nick",
    UserKeys.gender: "gender",
    UserKeys.yob: "yob",
    UserKeys.language: "language",
    UserKeys.country: "country",
    UserKeys.theme: "theme",
    UserKeys.emailVerified: "email_verified",
    UserKeys.blocked: "blocked",
    UserKeys.folders: "folders",
    UserKeys.meta: "meta",
  };

  factory User.fromMap(Map<String, dynamic> map, Map<UserKeys, String> mapper) {
    final foldersMapper = mapper == User.camel ? Folders.camel : Folders.snake;
    return User(
      userId: map[mapper[UserKeys.userId]] as String,
      userType: UserTypeCode.fromCode(map[mapper[UserKeys.userType]] as int),
      clientId: map[mapper[UserKeys.clientId]] as String?,
      roles: UserRoleCode.fromCodes((map[mapper[UserKeys.roles]] as List<dynamic>?)?.cast<int>()),
      login: map[mapper[UserKeys.login]] as String?,
      email: map[mapper[UserKeys.email]] as String?,
      nick: map[mapper[UserKeys.nick]] as String?,
      gender: GenderCode.fromCodeOrNull(map[mapper[UserKeys.gender]] as int?),
      yob: map[mapper[UserKeys.yob]] as int?,
      language: map[mapper[UserKeys.language]] as String?,
      country: map[mapper[UserKeys.country]] as String?,
      theme: ThemeCode.fromCode(map[mapper[UserKeys.theme]] as int?, def: Theme.system),
      emailVerified: tryParseBool(map[mapper[UserKeys.emailVerified]]) ?? false,
      blocked: tryParseBool(map[mapper[UserKeys.blocked]]) ?? false,
      folders: Folders.fromMap(map[mapper[UserKeys.folders]] as Map<String, dynamic>, foldersMapper),
      meta: map[mapper[UserKeys.meta]!] as Map<String, dynamic>?,
    );
  }

  Map<String, dynamic> toMap(Map<UserKeys, String> mapper) => {
        mapper[UserKeys.userId]!: userId,
        mapper[UserKeys.userType]!: userType.code,
        if (clientId != null) mapper[UserKeys.clientId]!: clientId,
        mapper[UserKeys.roles]!: roles.map((e) => e.code).toList(),
        if (login != null) mapper[UserKeys.login]!: login,
        if (email != null) mapper[UserKeys.email]!: email,
        if (nick != null) mapper[UserKeys.nick]!: nick,
        if (gender != null) mapper[UserKeys.gender]!: gender?.code,
        if (yob != null) mapper[UserKeys.yob]!: yob,
        if (language != null) mapper[UserKeys.language]!: language,
        if (country != null) mapper[UserKeys.country]!: country,
        if (theme != Theme.system) mapper[UserKeys.theme]!: theme.code,
        if (emailVerified) mapper[UserKeys.emailVerified]!: emailVerified,
        if (blocked) mapper[UserKeys.blocked]!: blocked,
        mapper[UserKeys.folders]!: folders.toMap(mapper == User.camel ? Folders.camel : Folders.snake),
        if (meta != null) mapper[UserKeys.meta]!: meta,
      };

  ////////////////////////////////////////////////////////////////////////////////
  // Meta

  static const String keyMetaClient = "client";
  static const String keyMetaClientNote = "note";

  // Meta - client

  Map<dynamic, dynamic> get metaClient => meta?[keyMetaClient] ?? {};
  void setMetaClient({String? note}) {
    final client = {
      if (note != null) keyMetaClientNote: note,
    };
    if (client.isNotEmpty) {
      final meta = this.meta ?? {};
      meta[keyMetaClient] = {...(meta[keyMetaClient] ?? {}), ...client};
      this.meta = meta;
    }
  }

  String get metaClientNote => cast<String>(metaClient[keyMetaClientNote]) ?? "";

  static const String keyMetaLocation = "location";
  static const String keyMetaLocationAutoDisabled = "autoDisabled";
  static const String keyMetaLocationLatitude = "latitude";
  static const String keyMetaLocationLongitude = "longitude";

  static const String keyMetaRating = "rating";

  int? get rating => tryParseInt(meta?[keyMetaRating]);

  Map<dynamic, dynamic> get metaLocation => meta?[keyMetaLocation] ?? {};
  void setMetaLocation({bool? autoDisabled, double? latitude, double? longitude}) {
    final location = {
      if (autoDisabled != null) keyMetaLocationAutoDisabled: autoDisabled,
      if (latitude != null) keyMetaLocationLatitude: latitude,
      if (longitude != null) keyMetaLocationLongitude: longitude,
    };
    if (location.isNotEmpty) {
      final meta = this.meta ?? {};
      meta[keyMetaLocation] = {...(meta[keyMetaLocation] ?? {}), ...location};
      this.meta = meta;
    }
  }

  bool get metaLocationAutoDisabled => cast<bool>(metaLocation[keyMetaLocationAutoDisabled]) ?? false;
  double? get metaLocationLatitude => cast<double>(metaLocation[keyMetaLocationLatitude]);
  double? get metaLocationLongitude => cast<double>(metaLocation[keyMetaLocationLongitude]);

  GeoPoint? get metaLocationPoint {
    final lat = metaLocationLatitude;
    final lon = metaLocationLongitude;
    if (lat == null || lon == null) return null;
    return GeoPoint(latitude: lat, longitude: lon);
  }

  // Meta - clients

  static const String keyMetaClients = "clients";
  static const String keyMetaClientDisplayName = "displayName";
  static const String keyMetaClientId1 = "id1";
  static const String keyMetaClientId2 = "id2";
  static const String keyMetaClientId3 = "id3";
  static const String keyMetaClientName = "name";
  static const String keyMetaClientFirstName = "firstName";
  static const String keyMetaClientSecondName = "secondName";
  static const String keyMetaClientThirdName = "thirdName";
  static const String keyMetaClientLastName = "lastName";
  static const String keyMetaClientAddressLine1 = "addressLine1";
  static const String keyMetaClientAddressLine2 = "addressLine2";
  static const String keyMetaClientZip = "zip";
  static const String keyMetaClientCity = "city";
  static const String keyMetaClientState = "state";
  static const String keyMetaClientCountry = "country";
  static const String keyMetaClientEmail = "email";
  static const String keyMetaClientPhone = "phone";
  static const String keyMetaClientNotes = "notes";

  String? getClientName(String clientId) {
    final data = getClientData(clientId);
    return data.displayName ?? nick;
  }

  Map<String, dynamic> get _metaClients => meta?[keyMetaClients] ?? {};
  void _setMetaClients(Map<String, dynamic> clients) {
    final meta = this.meta ?? {};
    meta[keyMetaClients] = clients;
    this.meta = meta;
  }

  // get meta by clientId
  Map<dynamic, dynamic> _getClientMeta(String clientId) {
    final clients = _metaClients;
    return clients[clientId] ?? {};
  }

  // set meta by clientId
  void _setClientMeta(String clientId, Map<dynamic, dynamic> client) {
    final clients = _metaClients;
    clients[clientId] = client;
    _setMetaClients(clients);
  }

  UserClientMetaData getClientData(String clientId) {
    final data = _getClientMeta(clientId);
    return UserClientMetaData(
      displayName: cast<String>(data[keyMetaClientDisplayName]),
      id1: cast<String>(data[keyMetaClientId1]),
      id2: cast<String>(data[keyMetaClientId2]),
      id3: cast<String>(data[keyMetaClientId3]),
      name: cast<String>(data[keyMetaClientName]),
      firstName: cast<String>(data[keyMetaClientFirstName]),
      secondName: cast<String>(data[keyMetaClientSecondName]),
      thirdName: cast<String>(data[keyMetaClientThirdName]),
      lastName: cast<String>(data[keyMetaClientLastName]),
      addressLine1: cast<String>(data[keyMetaClientAddressLine1]),
      addressLine2: cast<String>(data[keyMetaClientAddressLine2]),
      zip: cast<String>(data[keyMetaClientZip]),
      city: cast<String>(data[keyMetaClientCity]),
      state: cast<String>(data[keyMetaClientState]),
      country: cast<String>(data[keyMetaClientCountry]),
      email: cast<String>(data[keyMetaClientEmail]),
      phone: cast<String>(data[keyMetaClientPhone]),
      notes: cast<String>(data[keyMetaClientNotes]),
    );
  }

  void setClientData(String clientId, UserClientMetaData userData) {
    final data = _getClientMeta(clientId);
    final updated = {
      keyMetaClientDisplayName: userData.displayName,
      keyMetaClientId1: userData.id1,
      keyMetaClientId2: userData.id2,
      keyMetaClientId3: userData.id3,
      keyMetaClientName: userData.name,
      keyMetaClientFirstName: userData.firstName,
      keyMetaClientSecondName: userData.secondName,
      keyMetaClientThirdName: userData.thirdName,
      keyMetaClientLastName: userData.lastName,
      keyMetaClientAddressLine1: userData.addressLine1,
      keyMetaClientAddressLine2: userData.addressLine2,
      keyMetaClientZip: userData.zip,
      keyMetaClientCity: userData.city,
      keyMetaClientState: userData.state,
      keyMetaClientCountry: userData.country,
      keyMetaClientEmail: userData.email,
      keyMetaClientPhone: userData.phone,
      keyMetaClientNotes: userData.notes,
    };
    _setClientMeta(clientId, {...data, ...updated});
  }
}

class UserClientMetaData {
  String? displayName;
  String? id1;
  String? id2;
  String? id3;
  String? name;
  String? firstName;
  String? secondName;
  String? thirdName;
  String? lastName;
  String? addressLine1;
  String? addressLine2;
  String? zip;
  String? city;
  String? state;
  String? country;
  String? email;
  String? phone;
  String? notes;

  UserClientMetaData({
    this.displayName,
    this.id1,
    this.id2,
    this.id3,
    this.name,
    this.firstName,
    this.secondName,
    this.thirdName,
    this.lastName,
    this.addressLine1,
    this.addressLine2,
    this.zip,
    this.city,
    this.state,
    this.country,
    this.email,
    this.phone,
    this.notes,
  });
}

// eof
