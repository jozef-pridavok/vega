import "package:core_dart/core_algorithm.dart";
import "package:core_dart/core_dart.dart";
import "package:flutter/material.dart" as material;
import "package:package_info_plus/package_info_plus.dart";

import "environment.dart";

class F {
  static final _instance = F._internal();
  factory F() => _instance;

  F._internal();

  late final String appName;
  late final String packageName;
  late final String version;
  late final String buildNumber;
  late final String? installerStore;

  // "computed"

  late final Flavor flavor;
  late final String name;
  late final String apiUrl;
  late final String apiHost;
  late final int apiPort;
  late final String apiKey;
  late final String receiptPassword;
  late final String title;
  late final material.Color bannerColor;

  late final String qrCodeKey;
  late final String qrCodeEnv;
  late final QrBuilder qrBuilder;

  late final Map<String, dynamic> variables;

  Future<void> setEnvironment(Environment environment) async {
    flavor = environment.flavor;
    name = flavor.name.toUpperCase();
    apiUrl = environment.apiUrl;
    final apiUri = Uri.tryParse(apiUrl);
    apiHost = apiUri?.host ?? "";
    apiPort = apiUri?.port ?? 80;
    apiKey = environment.apiKey;
    receiptPassword = environment.receiptPassword;
    title = _titles[flavor] ?? "title";
    bannerColor = _colors[flavor] ?? material.Colors.transparent;

    qrCodeKey = environment.qrCodeKey;
    qrBuilder = QrBuilder(qrCodeKey, "a", flavor.qrCode);

    final info = await PackageInfo.fromPlatform();
    appName = info.appName;
    packageName = info.packageName;
    version = info.version;
    buildNumber = info.buildNumber;
    installerStore = info.installerStore;

    variables = environment.variables ?? {};
  }

  static Map<Flavor, String> get _titles => {
        Flavor.dev: "Dev",
        Flavor.qa: "Qa",
        Flavor.demo: "Demo",
        Flavor.prod: "Vega",
      };

  static Map<Flavor, material.Color> get _colors => {
        Flavor.dev: material.Colors.red,
        Flavor.qa: material.Colors.green,
        Flavor.demo: material.Colors.blue,
        Flavor.prod: material.Colors.transparent,
      };

  bool get isDev => flavor == Flavor.dev;
  bool get isQa => flavor == Flavor.qa;
  bool get isDemo => flavor == Flavor.demo;
  bool get isProd => flavor == Flavor.prod;

  bool get isInternal => flavor == Flavor.dev || flavor == Flavor.qa;
}

// eof
