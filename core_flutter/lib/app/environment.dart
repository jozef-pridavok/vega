import "dart:io";

import "package:app_settings/app_settings.dart";
import "package:core_dart/core_enums.dart";
import "package:flutter/foundation.dart";
import "package:url_launcher/url_launcher.dart";

class Environment {
  Flavor flavor;
  String apiUrl;
  String apiKey;
  String qrCodeKey;
  String receiptPassword;
  String vapidKey;
  Map<String, dynamic>? variables;

  Environment({
    required this.flavor,
    required this.apiUrl,
    required this.apiKey,
    required this.qrCodeKey,
    required this.receiptPassword,
    required this.vapidKey,
    this.variables,
  });

  static Future<bool> openWebBrowser(String url) async {
    final uri = Uri.tryParse(url);
    if (uri == null) return false;
    return await launchUrl(uri, mode: LaunchMode.externalApplication);
  }

  static Future<bool> openEmail(String to) async {
    final Uri uri = Uri(
      scheme: "mailto",
      path: to,
      //query: "subject=App Feedback&body=App Version 3.23", //add subject and body here
    );
    if (await launchUrl(uri)) return await launchUrl(uri);
    return false;
  }

  static Future<bool> makePhoneCall(String phoneNumber) => launchUrl(Uri(scheme: "tel", path: phoneNumber));

  static Future<void> openAppSettings() => AppSettings.openAppSettings();

  static Future<void> openNotificationSettings() => AppSettings.openAppSettings(type: AppSettingsType.notification);

  static final bool isLinux = !kIsWeb && Platform.isLinux;

  static final bool isMacOS = !kIsWeb && Platform.isMacOS;

  static final bool isWindows = !kIsWeb && Platform.isWindows;

  static final bool isIOS = !kIsWeb && Platform.isIOS;

  static final bool isAndroid = !kIsWeb && Platform.isAndroid;

  static final bool isFuchsia = !kIsWeb && Platform.isFuchsia;

  static const bool isWeb = kIsWeb;
}

// eof
