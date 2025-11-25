import "dart:io";

import "package:core_dart/core_dart.dart";
import "package:core_dart/core_repositories.dart";
import "package:device_info_plus/device_info_plus.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:package_info_plus/package_info_plus.dart";

import "../core_app.dart";
import "../core_flutter.dart";

@immutable
abstract class StartupState {}

class StartupInitial extends StartupState {}

class StartupInProgress extends StartupState {}

class StartupSucceed extends StartupState {
  final bool isOnline;
  final bool isWizardShowed;

  StartupSucceed({required this.isOnline, required this.isWizardShowed});
}

class StartupFailed extends StartupState implements FailedState {
  @override
  final CoreError error;

  final bool isOnline;
  final Locale locale;

  @override
  StartupFailed({required this.error, required this.isOnline, required this.locale});
}

class _StartupData {
  final Locale locale;
  final bool isOnline;
  final String installationId;
  final String? deviceToken;
  late final JsonObject? deviceInfo;
  late final String language;
  late final String country;
  _StartupData(
    this.locale, {
    required this.isOnline,
    required this.installationId,
    required this.deviceToken,
  }) {
    language = locale.languageCode;
    country = _getDeviceRegion(locale);
  }

  String _getDeviceRegion(Locale locale) {
    var countryCode = locale.countryCode;
    if (countryCode == null) {
      try {
        countryCode = Platform.localeName.split("_")[1];
      } catch (_) {}
    }
    return (countryCode ?? "").toLowerCase();
  }

  Future<void> getDeviceInfo() async {
    JsonObject deviceInfo = {};
    {
      final now = DateTime.now();
      deviceInfo["country"] = _getDeviceRegion(locale);
      deviceInfo["language"] = locale.languageCode;
      if (!kIsWeb) deviceInfo["locale"] = Platform.localeName;
      deviceInfo["os"] = !kIsWeb ? Platform.operatingSystem : "web";
      deviceInfo["timeZone"] = now.timeZoneName;
      deviceInfo["timeZoneOffset"] = now.timeZoneOffset.inSeconds;
    }
    {
      final info = await PackageInfo.fromPlatform();
      deviceInfo["appVersion"] = info.version;
      deviceInfo["appBuildNumber"] = info.buildNumber;
    }
    if (!kIsWeb) {
      final info = DeviceInfoPlugin();
      if (Platform.isIOS) {
        final iOsInfo = await info.iosInfo;
        deviceInfo["osManufacturer"] = "Apple";
        deviceInfo["osModel"] = iOsInfo.model;
        deviceInfo["osSystemVersion"] = iOsInfo.systemVersion;
        deviceInfo["osSystemName"] = iOsInfo.systemName;
        deviceInfo["osName"] = iOsInfo.name;
      }
      if (Platform.isAndroid) {
        final androidInfo = await info.androidInfo;
        deviceInfo["osManufacturer"] = androidInfo.manufacturer;
        deviceInfo["osModel"] = androidInfo.model;
        deviceInfo["osBrand"] = androidInfo.brand;
        deviceInfo["osVersionSdkInt"] = androidInfo.version.sdkInt;
        deviceInfo["osVersionRelease"] = androidInfo.version.release;
        deviceInfo["osDevice"] = androidInfo.device;
        deviceInfo["osDisplay"] = androidInfo.display;
      }
    }
    this.deviceInfo = deviceInfo.isNotEmpty ? deviceInfo : null;
  }
}

class StartupNotifier extends StateNotifier<StartupState> with LoggerMixin {
  final DeviceRepository deviceRepository;
  final UserRepository userRepository;
  final ClientRepository clientRepository;

  StartupNotifier({
    required this.deviceRepository,
    required this.userRepository,
    required this.clientRepository,
  }) : super(StartupInitial());

  Future<void> start(Locale locale) async {
    final isOnline = await isApiAvailable();
    try {
      if (state is StartupInProgress) return;

      state = StartupInProgress();

      final installationId = _getInstallationId();
      final data = _StartupData(
        locale,
        isOnline: isOnline,
        installationId: installationId,
        deviceToken: deviceRepository.get(DeviceKey.deviceToken) as String?,
      );
      await data.getDeviceInfo();

      await _checkUser(data);

      // Set startup state based on user and online status
      final isWizardShowed = (deviceRepository.get(DeviceKey.isWizardShowed) as bool?) ?? false;
      state = StartupSucceed(isOnline: isOnline, isWizardShowed: isWizardShowed);
    } on ApiResponse catch (e) {
      error(e.toString());
      final message = e.message ?? e.toString();
      state = StartupFailed(error: CoreError(code: e.appCode, message: message), isOnline: isOnline, locale: locale);
    } on CoreError catch (e) {
      state = StartupFailed(error: e, isOnline: isOnline, locale: locale);
    } catch (e) {
      error(e.toString());
      state = StartupFailed(error: errorUnexpectedException(e), isOnline: isOnline, locale: locale);
    }
  }

  Future<void> _checkUser(_StartupData data) async {
    User? user = deviceRepository.get(DeviceKey.user) as User?;
    if (user == null) {
      user = await _handleNoUser(data);
    } else if (data.isOnline) {
      user = await _handleUser(user, data);
    }
    deviceRepository.put(DeviceKey.client, null);
    final userClientId = user.clientId;
    if (userClientId == null) return;
    final client = await clientRepository.read(userClientId, ignoreCache: true);
    deviceRepository.put(DeviceKey.client, client);
  }

  Future<User> _handleNoUser(_StartupData data, {bool retry = true}) async {
    if (!data.isOnline) throw errorNoUser;

    try {
      final authenticated = await userRepository.anonymous(
        data.installationId,
        deviceToken: data.deviceToken,
        deviceInfo: data.deviceInfo,
        language: data.language,
        country: data.country,
      );
      deviceRepository.put(DeviceKey.refreshToken, authenticated.refreshToken);
      deviceRepository.put(DeviceKey.accessToken, authenticated.accessToken);
      final user = await userRepository.read(authenticated.userId, ignoreCache: true);
      if (user == null) throw errorNoData;
      deviceRepository.put(DeviceKey.user, user);
      return Future.value(user);
    } on CoreError catch (e) {
      if (retry && e == errorInvalidAccessToken) {
        final refreshToken = deviceRepository.get(DeviceKey.refreshToken) as String?;
        if (refreshToken == null) throw errorInvalidRefreshToken;
        final installationId = deviceRepository.get(DeviceKey.installationId) as String;
        final user = deviceRepository.get(DeviceKey.user) as User;
        final authenticated = await userRepository.refreshAccessToken(refreshToken, installationId, user.userId);
        deviceRepository.put(DeviceKey.refreshToken, authenticated.refreshToken);
        deviceRepository.put(DeviceKey.accessToken, authenticated.accessToken);
        return await _handleNoUser(data, retry: false);
      }
      rethrow;
    }
  }

  Future<User> _handleUser(User user, _StartupData data, {bool retry = true}) async {
    if (!(deviceRepository.get(DeviceKey.userSyncedRemotely) as bool? ?? false)) {
      try {
        if (await userRepository.update(user)) {
          deviceRepository.put(DeviceKey.userSyncedRemotely, true);
        }
      } catch (e) {
        error(e.toString());
      }
    }

    final refreshToken = deviceRepository.get(DeviceKey.refreshToken) as String?;
    if (refreshToken == null) throw errorInvalidRefreshToken;

    try {
      final authenticated = await userRepository.startup(
        refreshToken,
        deviceToken: data.deviceToken,
        deviceInfo: data.deviceInfo,
      );
      deviceRepository.put(DeviceKey.refreshToken, authenticated.refreshToken);
      deviceRepository.put(DeviceKey.accessToken, authenticated.accessToken);
    } on CoreError catch (e) {
      if (retry && e == errorInvalidAccessToken) {
        final installationId = deviceRepository.get(DeviceKey.installationId) as String;
        final authenticated = await userRepository.refreshAccessToken(refreshToken, installationId, user.userId);
        deviceRepository.put(DeviceKey.refreshToken, authenticated.refreshToken);
        deviceRepository.put(DeviceKey.accessToken, authenticated.accessToken);
        return await _handleUser(user, data, retry: false);
      }
      rethrow;
    }

    final updatedUser = await userRepository.read(user.userId, ignoreCache: true);

    // TODO: localize core_message_user_not_found "Používateľ nebol nájdený!", "User not found!", "¡Usuario no encontrado!"
    if (updatedUser == null) throw Exception("core_message_user_not_found");

    //  TODO: localize core_message_your_account_has_been_blocked "Váš účet bol zablokovaný!", "Your account has been blocked!", "¡Su cuenta ha sido bloqueada!"
    if (updatedUser.blocked) throw Exception("core_message_your_account_has_been_blocked".tr());

    deviceRepository.put(DeviceKey.user, updatedUser);

    return updatedUser;
  }

  String _getInstallationId() {
    var installationId = deviceRepository.get(DeviceKey.installationId) as String?;
    if (installationId == null) {
      installationId = uuid();
      deviceRepository.put(DeviceKey.installationId, installationId);
    }
    return installationId;
  }
}

// eof
