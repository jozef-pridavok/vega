// ignore_for_file: avoid_print

import "dart:developer";

import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/repositories/local.dart";
import "package:vega_app/repositories/providers.dart";

import "../../caches.dart";
import "../../repositories/user/user_cards_hive.dart";
import "../../states/providers.dart";
import "../../widgets/user_identity.dart";
import "../startup/screen_account.dart";
import "../startup/screen_wizard.dart";
import "screen_login.dart";
import "screen_register.dart";

List<Widget> debugMenuList(BuildContext context, WidgetRef ref) {
  final device = ref.read(deviceRepository);
  final user = device.get(DeviceKey.user) as User;
  final installationId = device.get(DeviceKey.installationId);
  final refreshToken = device.get(DeviceKey.refreshToken);
  final accessToken = device.get(DeviceKey.accessToken);
  final deviceToken = device.get(DeviceKey.deviceToken) as String?;
  return [
    const MoleculeItemSpace(),
    const MoleculeItemSeparator(),
    const MoleculeItemSpace(),
    const MoleculeItemTitle(header: "Debug"),
    const MoleculeItemSpace(),
    //
    MoleculeItemBasic(
      title: "Anonymous",
      label: user.isAnonymous.toString(),
      onAction: () => showUserIdentity(context, ref),
    ),
    GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: user.userId));
        context.toastInfo("UserId copied to clipboard");
      },
      child: MoleculeItemBasic(title: "UserId", label: user.userId),
    ),
    MoleculeItemBasic(title: "Email", label: user.email),
    MoleculeItemBasic(title: "Login", label: user.login),
    MoleculeItemBasic(title: "Nick", label: user.nick),
    GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: installationId));
        context.toastInfo("Installation id copied to clipboard");
      },
      child: MoleculeItemBasic(title: "Installation id", label: installationId),
    ),
    GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: refreshToken));
        context.toastInfo("Refresh token copied to clipboard");
        if (kDebugMode) print(refreshToken);
      },
      child: MoleculeItemBasic(title: "Refresh token", label: refreshToken),
    ),
    GestureDetector(
      onTap: () {
        Clipboard.setData(ClipboardData(text: accessToken));
        context.toastInfo("Access token copied to clipboard");
        if (kDebugMode) print(accessToken);
      },
      child: MoleculeItemBasic(title: "Access token", label: accessToken),
    ),
    GestureDetector(
      onTap: deviceToken != null
          ? () {
              Clipboard.setData(ClipboardData(text: deviceToken));
              context.toastInfo("Device token copied to clipboard");
            }
          : null,
      child: MoleculeItemBasic(title: "Device Token", label: deviceToken),
    ),
    const MoleculeItemSpace(),
    const MoleculeItemSeparator(),
    const MoleculeItemSpace(),
    MoleculeItemBasic(
      title: "Clear image caches",
      onAction: () => Caches.clear(),
    ),
    MoleculeItemBasic(
      title: "Clear device cached data",
      onAction: () => HiveDeviceRepository().clearCacheKeys(),
    ),
    MoleculeItemBasic(
        title: "Clear local caches",
        onAction: () {
          HiveDeviceRepository().clearCacheKeys();
          clearLocalData();
        }),
    MoleculeItemBasic(
      title: "Auto location disabled",
      label: user.metaLocationAutoDisabled.toString(),
      onAction: () {
        final autoDisabled = user.metaLocationAutoDisabled;
        user.setMetaLocation(autoDisabled: !autoDisabled);
        device.put(DeviceKey.user, user);
        device.put(DeviceKey.userSyncedRemotely, false);
        print("Location cleared");
        ref.read(incrementProvider.notifier).state++;
      },
    ),
    GestureDetector(
      onTap: () {
        final data = user.metaLocationPoint?.toString();
        if (data == null) return;
        Clipboard.setData(ClipboardData(text: data));
        context.toastInfo("Location copied to clipboard");
      },
      child: MoleculeItemBasic(
        title: "Location",
        label: user.metaLocationPoint?.toString(),
        onAction: () {
          ref.read(userLocationLogic.notifier).reset();
          ref.read(incrementProvider.notifier).state++;
        },
      ),
    ),
    MoleculeItemBasic(
      title: "Clean location",
      onAction: () {
        final meta = user.meta ?? {};
        meta[User.keyMetaLocation] = null;
        user.meta = meta;
        device.put(DeviceKey.user, user);
        device.put(DeviceKey.userSyncedRemotely, false);
        print("Location cleared");
        ref.read(incrementProvider.notifier).state++;
        //ref.read(promoLogic.notifier).reset();
      },
    ),
    MoleculeItemBasic(
      title: "Ask location",
      onAction: () => ref.read(userLocationLogic.notifier).ask(),
    ),
    //
    const MoleculeItemSpace(),
    const MoleculeItemSeparator(),
    const MoleculeItemSpace(),
    MoleculeItemBasic(
      title: "Dump user cards (local)",
      onAction: () async {
        if (!kDebugMode) return;
        final cards = await ref.read(localUserCardsRepository).readAll();
        if (cards == null || cards.isEmpty) return print("No cards found");
        for (final card in cards) {
          inspect(card);
        }
      },
    ),
    MoleculeItemBasic(
      title: "Dump user cards (remote)",
      onAction: () async {
        if (!kDebugMode) return;
        final cards = await ref.read(remoteUserCardsRepository).readAll();
        if (cards == null || cards.isEmpty) return print("No cards found");
        for (final card in cards) {
          inspect(card);
        }
      },
    ),
    MoleculeItemBasic(
      title: "Delete all user cards (local)",
      onAction: () => (ref.read(localUserCardsRepository) as HiveUserCardsRepository).deleteAll(),
    ),
    //
    const MoleculeItemSpace(),
    const MoleculeItemSeparator(),
    const MoleculeItemSpace(),
    //
    MoleculeItemBasic(
      title: "Refresh access token",
      actionIcon: AtomIcons.chevronRight,
      onAction: () {
        final userId = user.userId;
        final installationId = device.get(DeviceKey.installationId) as String;
        ref.read(remoteUserRepository).refreshAccessToken(refreshToken, installationId, userId);
      },
    ),
    MoleculeItemBasic(
      title: "Account Screen",
      actionIcon: AtomIcons.chevronRight,
      onAction: () => context.slideUp(const AccountScreen()),
    ),
    MoleculeItemBasic(
      title: "Login Screen",
      actionIcon: AtomIcons.chevronRight,
      onAction: () => context.slideUp(const LoginScreen()),
    ),
    MoleculeItemBasic(
      title: "Register Screen",
      actionIcon: AtomIcons.chevronRight,
      onAction: () => context.slideUp(const RegisterScreen()),
    ),
    MoleculeItemBasic(
      title: "Wizard",
      actionIcon: AtomIcons.chevronRight,
      onAction: () => context.replace(const WizardScreen()),
    ),
    MoleculeItemBasic(
      title: "Logout",
      onAction: () => ref.read(logoutLogic.notifier).logout(),
    ),
    const MoleculeItemSpace(),
    const MoleculeItemSeparator(),
    const MoleculeItemSpace(),
    MoleculeItemBasic(title: "context.toast", onAction: () => context.toast("toast.info")),
    MoleculeItemBasic(title: "context.toastInfo", onAction: () => context.toastInfo("toast.info", scheme: ref.scheme)),
    MoleculeItemBasic(
        title: "context.toastWarning", onAction: () => context.toastWarning("toast.warning", scheme: ref.scheme)),
    MoleculeItemBasic(
        title: "context.toastError", onAction: () => context.toastError("toast.error", scheme: ref.scheme)),
    MoleculeItemBasic(title: "app.info", onAction: () => ref.read(toastLogic.notifier).info("info")),
    MoleculeItemBasic(title: "app.warning", onAction: () => ref.read(toastLogic.notifier).warning("warning")),
    MoleculeItemBasic(title: "app.error", onAction: () => ref.read(toastLogic.notifier).error("error")),
    // end of debug list
    const MoleculeItemSpace(),
    const MoleculeItemSeparator(),
    const MoleculeItemSpace(),
  ];
}

// eof;
