import "package:core_dart/core_dart.dart";

enum ClientKeys {
  clientId,
  name,
  description,
  logo,
  logoBh,
  color,
  blocked,
  countries,
  settings,
  categories,
  currency,
  meta,
  updatedAt,
}

class Client {
  String clientId;
  String name;
  String? description;
  String? logo;
  String? logoBh;
  Color color;
  bool blocked;
  List<Country>? countries;
  List<ClientCategory>? categories;
  Currency currency;
  Map<String, dynamic>? settings;
  Map<String, dynamic>? meta;
  DateTime? updatedAt;

  Client({
    required this.clientId,
    required this.name,
    this.description,
    this.logo,
    this.logoBh,
    this.color = Palette.white,
    this.blocked = false,
    this.countries,
    this.categories,
    this.currency = defaultCurrency,
    this.settings,
    this.meta,
    this.updatedAt,
  });

  static const camel = {
    ClientKeys.clientId: "clientId",
    ClientKeys.name: "name",
    ClientKeys.description: "description",
    ClientKeys.logo: "logo",
    ClientKeys.logoBh: "logoBh",
    ClientKeys.color: "color",
    ClientKeys.blocked: "blocked",
    ClientKeys.countries: "countries",
    ClientKeys.categories: "categories",
    ClientKeys.currency: "currency",
    ClientKeys.settings: "settings",
    ClientKeys.meta: "meta",
    ClientKeys.updatedAt: "updatedAt",
  };

  static const snake = {
    ClientKeys.clientId: "client_id",
    ClientKeys.name: "name",
    ClientKeys.description: "description",
    ClientKeys.logo: "logo",
    ClientKeys.logoBh: "logo_bh",
    ClientKeys.color: "color",
    ClientKeys.blocked: "blocked",
    ClientKeys.countries: "countries",
    ClientKeys.categories: "categories",
    ClientKeys.currency: "currency",
    ClientKeys.settings: "settings",
    ClientKeys.meta: "meta",
    ClientKeys.updatedAt: "updated_at",
  };

  factory Client.fromMap(Map<String, dynamic> map, Map<ClientKeys, String> mapper) {
    return Client(
      clientId: map[mapper[ClientKeys.clientId]!] as String,
      name: map[mapper[ClientKeys.name]!] as String,
      description: map[mapper[ClientKeys.description]!] as String?,
      logo: map[mapper[ClientKeys.logo]!] as String?,
      logoBh: map[mapper[ClientKeys.logoBh]!] as String?,
      color: Color.fromHexOrNull(map[mapper[ClientKeys.color]] as String?) ?? Palette.white,
      blocked: map[mapper[ClientKeys.blocked]!] as bool? ?? false,
      countries: CountryCode.fromCodesOrNull((map[mapper[ClientKeys.countries]!] as List<dynamic>?)?.cast<String>()),
      categories:
          ClientCategoryCode.fromCodesOrNull((map[mapper[ClientKeys.categories]] as List<dynamic>?)?.cast<int>()),
      currency: CurrencyCode.fromCode(map[mapper[ClientKeys.currency]!] as String?),
      settings: map[mapper[ClientKeys.settings]!] as Map<String, dynamic>?,
      meta: map[mapper[ClientKeys.meta]!] as Map<String, dynamic>?,
      updatedAt: tryParseDateTime(map[mapper[ClientKeys.updatedAt]!]),
    );
  }

  Map<String, dynamic> toMap(Map<ClientKeys, String> mapper) {
    return {
      mapper[ClientKeys.clientId]!: clientId,
      mapper[ClientKeys.name]!: name,
      if (description != null) mapper[ClientKeys.description]!: description,
      if (logo != null) mapper[ClientKeys.logo]!: logo,
      if (logoBh != null) mapper[ClientKeys.logoBh]!: logoBh,
      mapper[ClientKeys.color]!: color.toHex(),
      if (blocked) mapper[ClientKeys.blocked]!: blocked,
      if (countries != null) mapper[ClientKeys.countries]!: countries!.map((e) => e.code).toList(),
      if (categories != null) mapper[ClientKeys.categories]!: categories!.map((e) => e.code).toList(),
      mapper[ClientKeys.currency]!: currency.code,
      if (settings != null) mapper[ClientKeys.settings]!: settings,
      mapper[ClientKeys.currency]!: currency.code,
      if (meta != null) mapper[ClientKeys.meta]!: meta,
      if (updatedAt != null) mapper[ClientKeys.updatedAt]!: updatedAt!.toIso8601String(),
    };
  }

  ////////////////////////////////////////////////////////////////////////////////
  // Settings

  static const String keySettingsDescription = "description";
  static const String keySettingsPhone = "phone";
  static const String keySettingsEmail = "email";
  static const String keySettingsWeb = "web";

  static const String keySettingsInvoicing = "invoicing";
  static const String keySettingsInvoicingName = "name";
  static const String keySettingsInvoicingCompanyNumber = "id";
  static const String keySettingsInvoicingCompanyVat = "vat";
  static const String keySettingsInvoicingAddress1 = "address_line1";
  static const String keySettingsInvoicingAddress2 = "address_line2";
  static const String keySettingsInvoicingZip = "zip";
  static const String keySettingsInvoicingCity = "city";
  static const String keySettingsInvoicingCountry = "country";
  static const String keySettingsInvoicingPhone = "phone";
  static const String keySettingsInvoicingEmail = "email";

  static const String keySettingsDeliveryPrice = "deliveryPrice";
  static const String keySettingsDeliveryPricePickup = "1";
  static const String keySettingsDeliveryPriceCourier = "2";

  String getDescription(String lang, {String fallback = ""}) {
    final map = (settings?[keySettingsDescription] as Map<dynamic, dynamic>?)?.asStringMap;
    final value = cast<String>(map?[lang]);
    if (value != null) return value;
    return cast<String>(map?.entries.firstOrNull?.value) ?? fallback;
  }

  setDescription(String lang, String description) {
    final settings = this.settings ?? {};
    settings[keySettingsDescription] ??= {};
    settings[keySettingsDescription][lang] = description;
    this.settings = settings;
  }

  String get phone => cast<String>(settings?[keySettingsPhone]) ?? "";
  set phone(String phone) {
    final settings = this.settings ?? {};
    settings[keySettingsPhone] = phone;
    this.settings = settings;
  }

  String get email => cast<String>(settings?[keySettingsEmail]) ?? "";
  set email(String email) {
    final settings = this.settings ?? {};
    settings[keySettingsEmail] = email;
    this.settings = settings;
  }

  String get web => cast<String>(settings?[keySettingsWeb]) ?? "";
  set web(String web) {
    final settings = this.settings ?? {};
    settings[keySettingsWeb] = web;
    this.settings = settings;
  }

  // Settings - invoicing

  Map<dynamic, dynamic> get invoicing => settings?[keySettingsInvoicing] ?? {};
  void setInvoicing({
    String? name,
    String? companyNumber,
    String? companyVat,
    String? address1,
    String? address2,
    String? zip,
    String? city,
    String? country,
    String? phone,
    String? email,
  }) {
    final invoicing = {
      if (name != null) keySettingsInvoicingName: name,
      if (companyNumber != null) keySettingsInvoicingCompanyNumber: companyNumber,
      if (companyVat != null) keySettingsInvoicingCompanyVat: companyVat,
      if (address1 != null) keySettingsInvoicingAddress1: address1,
      if (address2 != null) keySettingsInvoicingAddress2: address2,
      if (zip != null) keySettingsInvoicingZip: zip,
      if (city != null) keySettingsInvoicingCity: city,
      if (country != null) keySettingsInvoicingCountry: country,
      if (phone != null) keySettingsInvoicingPhone: phone,
      if (email != null) keySettingsInvoicingEmail: email,
    };
    if (invoicing.isNotEmpty) {
      final settings = this.settings ?? {};
      settings[keySettingsInvoicing] = {...(settings[keySettingsInvoicing] ?? {}), ...invoicing};
      this.settings = settings;
    }
  }

  String get invoicingName => cast<String>(invoicing[keySettingsInvoicingName]) ?? "";
  String get invoicingCompanyNumber => cast<String>(invoicing[keySettingsInvoicingCompanyNumber]) ?? "";
  String get invoicingCompanyVat => cast<String>(invoicing[keySettingsInvoicingCompanyVat]) ?? "";
  String get invoicingAddress1 => cast<String>(invoicing[keySettingsInvoicingAddress1]) ?? "";
  String get invoicingAddress2 => cast<String>(invoicing[keySettingsInvoicingAddress2]) ?? "";
  String get invoicingZip => cast<String>(invoicing[keySettingsInvoicingZip]) ?? "";
  String get invoicingCity => cast<String>(invoicing[keySettingsInvoicingCity]) ?? "";
  String get invoicingCountry => cast<String>(invoicing[keySettingsInvoicingCountry]) ?? "";
  String get invoicingPhone => cast<String>(invoicing[keySettingsInvoicingPhone]) ?? "";
  String get invoicingEmail => cast<String>(invoicing[keySettingsInvoicingEmail]) ?? "";

  // Settings - deliveryPrice

  Map<dynamic, dynamic> get deliveryPrice => settings?[keySettingsDeliveryPrice] ?? {};
  void setDeliveryPrice({int? pickupPrice, int? courierPrice}) {
    final deliveryPrice = {
      keySettingsDeliveryPricePickup: pickupPrice,
      keySettingsDeliveryPriceCourier: courierPrice,
    };
    //if (deliveryPrice.isNotEmpty) {
    final settings = this.settings ?? {};
    settings[keySettingsDeliveryPrice] = {...(settings[keySettingsDeliveryPrice] ?? {}), ...deliveryPrice};
    this.settings = settings;
    //}
  }

  int? get deliveryPricePickup => cast<int>(deliveryPrice[keySettingsDeliveryPricePickup]);
  int? get deliveryPriceCourier => cast<int>(deliveryPrice[keySettingsDeliveryPriceCourier]);

  ////////////////////////////////////////////////////////////////////////////////
  // Meta

  static const String keyMetaAccountPrefix = "accountPrefix";
  static const String keyMetaDemoCredit = "demoCredit";
  static const String keyMetaNewUserCardMask = "newUserCardMask";
  static const String keyMetaLicense = "license";
  static const String keyMetaLicenseProviders = "providers";
  static const String keyMetaLicenseBase = "base";
  static const String keyMetaLicensePricing = "pricing";
  static const String keyMetaLicenseCurrency = "currency";
  static const String keyMetaLicenseValidTo = "validTo";
  static const String keyMetaLicenseActivityPeriod = "activityPeriod";
  static const String keyMetaLicenseModuleLoyalty = "moduleLoyalty";
  static const String keyMetaLicenseModuleCoupons = "moduleCoupons";
  static const String keyMetaLicenseModuleLeaflets = "moduleLeaflets";
  static const String keyMetaLicenseModuleReservations = "moduleReservations";
  static const String keyMetaLicenseModuleOrders = "moduleOrders";

  static const String keyMetaQrCodeScanning = "qrCodeScanning";
  static const String keyMetaQrCodeScanningProvider = "provider";
  static const String keyMetaQrCodeScanningProviderId = "providerId";
  static const String keyMetaQrCodeScanningCreateNewUserCard = "createNewUserCard";
  static const String keyMetaQrCodeScanningRatio = "ratio";

  static const String keyMetaRating = "rating";

  // Meta - account prefix

  String get accountPrefix => cast<String>(meta?[keyMetaAccountPrefix]) ?? "";
  set accountPrefix(String prefix) {
    final meta = this.meta ?? {};
    meta[keyMetaAccountPrefix] = prefix;
    this.meta = meta;
  }

  // Meta - demoCredit

  int get demoCredit => tryParseInt(meta?[keyMetaDemoCredit]) ?? 0;
  set demoCredit(int credit) {
    final meta = this.meta ?? {};
    meta[keyMetaDemoCredit] = credit;
    this.meta = meta;
  }

  // Meta - new user card mask

  String get newUserCardMask => cast<String>(meta?[keyMetaNewUserCardMask]) ?? "";
  set newUserCardMask(String mask) {
    final meta = this.meta ?? {};
    meta[keyMetaNewUserCardMask] = mask;
    this.meta = meta;
  }

  // Meta - rating

  int? get rating => tryParseInt(meta?[keyMetaRating]);

  // License

  Map<dynamic, dynamic> get metaLicense => meta?[keyMetaLicense] ?? {};
  void setMetaLicense({
    List<String>? providers,
    int? base,
    int? pricing,
    Currency? currency,
    int? activityPeriod,
    bool? moduleLoyalty,
    bool? moduleCoupons,
    bool? moduleLeaflets,
    bool? moduleReservations,
    bool? moduleOrders,
  }) {
    final license = {
      if (providers != null) keyMetaLicenseProviders: providers,
      if (base != null) keyMetaLicenseBase: base,
      if (pricing != null) keyMetaLicensePricing: pricing,
      if (currency != null) keyMetaLicenseCurrency: currency.code,
      if (activityPeriod != null) keyMetaLicenseActivityPeriod: activityPeriod,
      if (moduleLoyalty != null) keyMetaLicenseModuleLoyalty: moduleLoyalty,
      if (moduleCoupons != null) keyMetaLicenseModuleCoupons: moduleCoupons,
      if (moduleLeaflets != null) keyMetaLicenseModuleLeaflets: moduleLeaflets,
      if (moduleReservations != null) keyMetaLicenseModuleReservations: moduleReservations,
      if (moduleOrders != null) keyMetaLicenseModuleOrders: moduleOrders,
    };
    if (license.isNotEmpty) {
      final meta = this.meta ?? {};
      meta[keyMetaLicense] = {...(meta[keyMetaLicense] ?? {}), ...license};
      this.meta = meta;
    }
  }

  List<String> get licenseProviders => cast<List<dynamic>>(metaLicense[keyMetaLicenseProviders])?.cast<String>() ?? [];
  int get licenseBase => cast<int>(metaLicense[keyMetaLicenseBase]) ?? 0;
  int get licensePricing => cast<int>(metaLicense[keyMetaLicensePricing]) ?? 0;
  Currency get licenseCurrency => CurrencyCode.fromCode(cast<String>(metaLicense[keyMetaLicenseCurrency]) ?? "");
  IntDate get licenseValidTo => IntDate.fromInt(metaLicense[keyMetaLicenseValidTo] as int);
  int get licenseActivityPeriod => cast<int>(metaLicense[keyMetaLicenseActivityPeriod]) ?? 0;

  bool get licenseModuleLoyalty => cast<bool>(metaLicense[keyMetaLicenseModuleLoyalty]) ?? true;
  bool get licenseModuleCoupons => cast<bool>(metaLicense[keyMetaLicenseModuleCoupons]) ?? true;
  bool get licenseModuleLeaflets => cast<bool>(metaLicense[keyMetaLicenseModuleLeaflets]) ?? true;
  bool get licenseModuleReservations => cast<bool>(metaLicense[keyMetaLicenseModuleReservations]) ?? true;
  bool get licenseModuleOrders => cast<bool>(metaLicense[keyMetaLicenseModuleOrders]) ?? true;

  bool? get licenseModuleLoyaltyOrNull => cast<bool>(metaLicense[keyMetaLicenseModuleLoyalty]);
  bool? get licenseModuleCouponsOrNull => cast<bool>(metaLicense[keyMetaLicenseModuleCoupons]);
  bool? get licenseModuleLeafletsOrNull => cast<bool>(metaLicense[keyMetaLicenseModuleLeaflets]);
  bool? get licenseModuleReservationsOrNull => cast<bool>(metaLicense[keyMetaLicenseModuleReservations]);
  bool? get licenseModuleOrdersOrNull => cast<bool>(metaLicense[keyMetaLicenseModuleOrders]);
}

// eof
