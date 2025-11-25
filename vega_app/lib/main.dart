import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
//import "package:firebase_core/firebase_core.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:hive/hive.dart";
import "package:push/push.dart";

import "app.dart";
import "caches.dart";
import "hive_adapters/adapters.dart";
import "repositories/coupon/coupons_hive.dart";
import "repositories/leaflet/leaflet_detail_hive.dart";
import "repositories/leaflet/leaflet_overview_hive.dart";
import "repositories/location/location_hive.dart";
import "repositories/program/programs_hive.dart";
import "repositories/user/user_cards_hive.dart";

Future<void> initializeHive({bool registerAdapters = true}) async {
  if (registerAdapters) {
    Hive.registerAdapter(UserCardAdapter());
    Hive.registerAdapter(ProgramAdapter());
    Hive.registerAdapter(LeafletOverviewAdapter());
    Hive.registerAdapter(LeafletDetailAdapter());
    Hive.registerAdapter(LocationAdapter());
    Hive.registerAdapter(CouponAdapter());
  }

  await HiveUserCardsRepository.init();
  await HiveClientRepository.init();
  await HiveProgramsRepository.init();
  await HiveLeafletOverviewRepository.init();
  await HiveLeafletDetailRepository.init();
  await HiveLocationRepository.init();
  await HiveCouponsRepository.init();
}

Future<void> resetHive() async {
  await HiveUserCardsRepository.reset();
  await HiveClientRepository.reset();
  await HiveProgramsRepository.reset();
  await HiveLeafletOverviewRepository.reset();
  await HiveLeafletDetailRepository.reset();
  await HiveLocationRepository.reset();
  await HiveCouponsRepository.reset();
}

Future<void> clearHive() async {
  HiveUserCardsRepository.clear();
  HiveClientRepository.clear();
  HiveProgramsRepository.clear();
  HiveLeafletOverviewRepository.clear();
  HiveLeafletDetailRepository.clear();
  HiveLocationRepository.clear();
  HiveCouponsRepository.clear();
  HiveDeviceRepository().clearCacheKeys();
}

Map<String, dynamic>? _convertMapOO(Map<Object?, Object?>? nullableMap) {
  if (nullableMap == null) return null;
  return {
    for (var entry in nullableMap.entries)
      if (entry.key is String) entry.key.toString(): entry.value,
  };
}

Map<String, dynamic>? _convertMapSO(Map<String?, Object?>? nullableMap) {
  if (nullableMap == null) return null;
  return {
    for (var entry in nullableMap.entries)
      if (entry.key != null) entry.key!: entry.value,
  };
}

extension _RemoteMessageAsPush on RemoteMessage {
  PushNotification toPushNotification() {
    // on android "data" can be converted to a map of objects directly
    // on ios "data" contains APN payload { "aps": { "alert": { "title": "title", "body": "body" } }, "payload": { "key": "value" } }
    Map<String, dynamic>? extracted = _convertMapSO(data);
    if (extracted?["aps"] != null) {
      extracted = _convertMapOO(extracted?["payload"]);
    }
    return PushNotification(
      title: notification?.title,
      body: notification?.body,
      payload: extracted,
    );
  }
}

extension _ObjectMapToPushNotification on Map<String?, Object?> {
  PushNotification toPushNotification() {
    Map<String, dynamic>? extracted = _convertMapSO(this);
    String? title;
    String? body;
    if (extracted?["aps"] != null) {
      title = extracted?["aps"]?["alert"]?["title"] as String?;
      body = extracted?["aps"]?["alert"]?["body"] as String?;
      extracted = _convertMapOO(extracted?["payload"]);
    }
    return PushNotification(
      title: title,
      body: body,
      payload: extracted,
    );
  }
}

void log(Object? object) {
  if (kDebugMode) print(object);
}

void vega(Environment environment /*, FirebaseOptions? firebaseOptions*/) async {
  await VegaApp.ensureInitialized(initializeHive: initializeHive, resetHive: resetHive);

  Logger.setup(releaseMode: kReleaseMode);

  await F().setEnvironment(environment);

  log(F().name);
  log(F().apiUrl);

  //await Permission.requestNetwork();

  ApiClient.configure(
    endPoint: F().apiUrl,
    apiKey: F().apiKey,
    connectionTimeout: F().isDev ? const Duration(seconds: 5) : null,
    dynamicHeaders: () {
      final accessToken = HiveDeviceRepository().get(DeviceKey.accessToken) as String?;
      return <String, String>{
        if (accessToken != null) "Authorization": "Bearer $accessToken",
      };
    },
    refreshAccessToken: () async {
      final deviceRepository = HiveDeviceRepository();
      final refreshToken = deviceRepository.get(DeviceKey.refreshToken) as String?;
      if (refreshToken == null) throw errorInvalidRefreshToken;
      final remoteUserRepository = ApiUserRepository(
        deviceRepository: deviceRepository,
      );
      final installationId = deviceRepository.get(DeviceKey.installationId) as String;
      final user = deviceRepository.get(DeviceKey.user) as User;
      try {
        final authenticated = await remoteUserRepository.refreshAccessToken(refreshToken, installationId, user.userId);
        deviceRepository.put(DeviceKey.refreshToken, authenticated.refreshToken);
        deviceRepository.put(DeviceKey.accessToken, authenticated.accessToken);
      } catch (e) {
        Logger().error(e.toString());
        throw errorInvalidRefreshToken;
      }
    },
  );

  await Caches.init();
  //if (F().isDev) await Caches.clear();

  runApp(
    VegaApp(
      fallbackLocale: const Locale("en"),
      supportedLocales: const [Locale("en"), Locale("sk"), Locale("es")],
      child: ProviderScope(
        child: App(
          showBanner: F().isInternal,
          onInit: (handleToken, handleMessage) async {
            final isGranted = await Push.instance.requestPermission();
            if (!isGranted) {
              log("PN: Permission not granted");
              return;
            }

            try {
              final token = await Push.instance.token;
              if (token != null) {
                log("PN: Got token: $token");
                handleToken(token);
              }
              Push.instance.onNewToken.listen((token) {
                log("PN: Just got a new token: $token");
                handleToken(token);
              });
            } catch (e) {
              log("PN: Error getting token: $e");
            }

            // Handle notification launching app from terminated state

            final data = await Push.instance.notificationTapWhichLaunchedAppFromTerminated;
            if (data == null) {
              log("PN: App was not launched by tapping a notification");
            } else {
              log("PN: Notification tap launched app from terminated state");
              handleMessage("onForeground", PushNotification(payload: _convertMapSO(data)));
            }

            // Handle notification taps
            Push.instance.onNotificationTap.listen((data) {
              log("PN: Notification was tapped");
              handleMessage("onNotification", data.toPushNotification());
            });

            // Handle push notifications
            Push.instance.addOnMessage((message) {
              log("PN: RemoteMessage received while app is in foreground");
              handleMessage("onForeground", message.toPushNotification());
            });

            // Handle push notifications
            Push.instance.addOnBackgroundMessage((message) {
              log("PN: RemoteMessage received while app is in background");
              handleMessage("onBackground", message.toPushNotification());
            });
          },
        ),
      ),
    ),
  );
}

// eof
