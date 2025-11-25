import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/foundation.dart";
import "package:flutter/material.dart";
import "package:flutter/services.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_dashboard/screens/debug/navigation.dart";

import "../debug/screen_pickers.dart";

List<Widget> debugMenuList(BuildContext context, WidgetRef ref) {
  final lang = context.languageCode;
  final device = ref.read(deviceRepository);
  final user = device.get(DeviceKey.user) as User;
  final client = device.get(DeviceKey.client) as Client?;
  final installationId = device.get(DeviceKey.installationId);
  final refreshToken = device.get(DeviceKey.refreshToken);
  final accessToken = device.get(DeviceKey.accessToken);
  final layout = ref.watch(layoutLogic);
  return [
    const MoleculeItemSpace(),
    const MoleculeItemSeparator(),
    const MoleculeItemSpace(),
    const MoleculeItemTitle(header: "Debug"),
    //
    if (client != null) ...[
      MoleculeItemBasic(
        title: "ClientId - ClientName",
        label: "${client.clientId} - ${client.name}",
      ),
      MoleculeItemBasic(
        title: "License - Period - Base - Pricing",
        label:
            "${formatIntDate(context.languageCode, client.licenseValidTo)} - ${client.licenseActivityPeriod} - ${client.licenseCurrency.formatSymbol(client.licenseBase, lang)} - ${client.licenseCurrency.formatSymbol(client.licensePricing, lang)}",
      ),
      MoleculeItemBasic(
        title: "Demo Credit",
        label: client.licenseCurrency.formatSymbol(client.demoCredit, lang),
      ),
      MoleculeItemBasic(
        title: "Loyalty, Coupons, Leaflets, Orders, Reservations",
        label:
            "${client.licenseModuleLoyalty}, ${client.licenseModuleCoupons}, ${client.licenseModuleLeaflets}, ${client.licenseModuleOrders}, ${client.licenseModuleReservations}",
      ),
    ],
    MoleculeItemBasic(title: "Roles (${user.roles.length})", label: user.roles.join(", ")),
    MoleculeItemBasic(title: "Anonymous", label: user.isAnonymous.toString()),
    MoleculeItemBasic(
      title: "UserId | Email | Login",
      label: "${user.userId} | ${user.email} | ${user.login}",
      onAction: () {
        Clipboard.setData(ClipboardData(text: user.userId));
        context.toastInfo("User id copied to clipboard");
      },
    ),
    MoleculeItemBasic(
        title: "Installation id",
        label: installationId,
        onAction: () {
          Clipboard.setData(ClipboardData(text: installationId));
          context.toastInfo("Installation id copied to clipboard");
        }),
    MoleculeItemBasic(
      title: "Refresh token",
      label: refreshToken,
      onAction: () {
        Clipboard.setData(ClipboardData(text: refreshToken));
        context.toastInfo("Refresh token copied to clipboard");
        if (kDebugMode) print(refreshToken);
      },
    ),
    MoleculeItemBasic(
      title: "Access token",
      label: accessToken,
      onAction: () {
        Clipboard.setData(ClipboardData(text: accessToken));
        context.toastInfo("Access token copied to clipboard");
        if (kDebugMode) print(accessToken);
      },
    ), //
    const MoleculeItemSpace(),
    const MoleculeItemSeparator(),
    MoleculeItemBasic(
      title: "Screen Size",
      label: "${layout.screenWidth} x ${layout.screenHeight} | ${ScreenFactor.tablet} | ${ScreenFactor.desktop}}",
    ),
    MoleculeItemBasic(
        title: "Mobile - Table - Desktop", label: "${layout.isMobile} - ${layout.isTablet} - ${layout.isDesktop}"),
    MoleculeItemBasic(title: "Portrait", label: "${layout.isPortrait}"),
    //
    const MoleculeItemSpace(),
    const MoleculeItemSeparator(),
    const MoleculeItemSpace(),
    MoleculeItemBasic(
      title: "Pickers",
      label: "Pickers screen",
      onAction: () => context.push(const PickersScreen()),
    ),
    MoleculeItemBasic(
      title: "Screen A",
      label: "Navigation screens",
      onAction: () => context.push(const NavScreenA(showDrawer: true)),
    ),
    MoleculeItemBasic(
      title: "Screen B",
      label: "Navigation screens",
      onAction: () => context.push(const NavScreenB(showDrawer: true)),
    ),
  ];
}

// eof;
