import "package:core_dart/core_dart.dart";
import "package:core_dart/core_hive.dart" as core_dart;
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:hive_flutter/hive_flutter.dart";

import "../localization/localized_widget.dart";

typedef DeviceTokenCallback = void Function(String);
typedef PushNotificationCallback = void Function(String, PushNotification);
typedef AppInitCallback = Future<void> Function(DeviceTokenCallback, PushNotificationCallback);

class VegaApp extends StatefulWidget {
  final Widget child;
  final List<Locale> supportedLocales;
  final Locale fallbackLocale;

  const VegaApp({
    super.key,
    required this.child,
    required this.supportedLocales,
    required this.fallbackLocale,
  });

  @override
  State<VegaApp> createState() => _VegaAppState();

  static Future<void> ensureInitialized({
    Future<void> Function({bool registerAdapters})? initializeHive,
    Future<void> Function()? resetHive,
  }) async {
    WidgetsFlutterBinding.ensureInitialized();
    await LocalizedWidget.ensureInitialized();

    await Hive.initFlutter();

    // Init Core Hives

    try {
      await core_dart.initializeHive();
    } catch (e) {
      if (kDebugMode) print("Hive: Resetting core Hive due to error: $e");
      try {
        await core_dart.resetHive();
      } catch (e) {
        if (kDebugMode) print("Hive: Failed to reset core Hive: $e");
      }
      await core_dart.initializeHive(registerAdapters: false);
    }

    // Init application Hives

    if (initializeHive != null)
      try {
        await initializeHive(registerAdapters: true);
      } catch (e) {
        if (kDebugMode) print("Hive: Resetting application Hive due to error: $e");
        try {
          if (resetHive != null) await resetHive();
        } catch (e) {
          if (kDebugMode) print("Hive: Failed to reset application Hive: $e");
        }
        await initializeHive(registerAdapters: false);
      }
  }
}

class _VegaAppState extends State<VegaApp> {
  @override
  Widget build(BuildContext context) {
    return LocalizedWidget(
      useOnlyLangCode: true,
      supportedLocales: widget.supportedLocales,
      path: "assets/langs",
      fallbackLocale: widget.fallbackLocale,
      child: widget.child,
    );
  }
}

// eof
