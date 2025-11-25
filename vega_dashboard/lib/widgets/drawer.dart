import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";

import "../screens/login.dart";
import "../screens/menu/client/row_calendar.dart" as menu_client;
import "../screens/menu/client/row_cards.dart" as menu_client;
import "../screens/menu/client/row_coupons.dart" as menu_client;
import "../screens/menu/client/row_locations.dart" as menu_client;
import "../screens/menu/client/row_offers.dart" as menu_client;
import "../screens/menu/client/row_orders.dart" as menu_client;
import "../screens/menu/client/row_payments.dart" as menu_client;
import "../screens/menu/client/row_programs.dart" as menu_client;
import "../screens/menu/client/row_reservations.dart" as menu_client;
import "../screens/menu/client/row_settings.dart" as menu_client;
import "../screens/menu/client/row_user_cards.dart" as menu_client;
import "../screens/menu/client/row_users.dart" as menu_client;
import "../screens/menu/developer/row_translations.dart" as menu_developer;
import "../screens/menu/row_dashboard.dart";
import "../screens/menu/row_debug.dart";
import "../screens/menu/row_language.dart";
import "../screens/menu/row_leaflets.dart";
import "../screens/menu/row_logout.dart";
import "../screens/menu/row_system.dart";
import "../screens/menu/row_theme.dart";
import "../screens/menu/seller/row_clients.dart" as menu_seller;
import "../screens/menu/seller/row_sales.dart" as menu_seller;
import "../states/developer_translations.dart";
import "../states/providers.dart";
import "../strings.dart";

class VegaDrawer extends ConsumerStatefulWidget {
  const VegaDrawer({super.key});

  @override
  createState() => _VegaDrawerState();
}

class _VegaDrawerState extends ConsumerState<VegaDrawer> {
  @override
  Widget build(BuildContext context) {
    ref.listen(logoutLogic, (previous, state) {
      if (state is LogoutSucceed) context.replace(LoginScreen());
    });
    return const _Drawer();
  }
}

class _Drawer extends ConsumerWidget {
  const _Drawer();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    final client = ref.read(deviceRepository).get(DeviceKey.client) as Client?;
    final isAdmin = user.isAdmin;
    final isOrder = user.isOrder;
    final isReservation = user.isReservation;
    final isMarketing = user.isMarketing;
    final isSeller = user.isSeller;
    final isDevelopment = user.isDevelopment;
    return Drawer(
      elevation: 0,
      backgroundColor: ref.scheme.paper,
      width: ScreenFactor.tablet,
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const MoleculeItemSpace(),
                if (client != null) ...[
                  const DashboardRow(),
                  if (isAdmin) ...[
                    const menu_client.ClientCardsRow(),
                    if (client.licenseModuleLoyalty) const menu_client.ProgramsRow(),
                    const menu_client.UserCardsRow(),
                  ],
                  if (isAdmin || isMarketing) ...[
                    if (client.licenseModuleCoupons) const menu_client.CouponsRow(),
                    if (client.licenseModuleLeaflets) const LeafletsRow(),
                  ],
                  if (F().isInternal && client.licenseModuleOrders && (isAdmin || isOrder)) ...[
                    const menu_client.OffersRow(),
                    const menu_client.OrdersRow(),
                  ],
                  if (client.licenseModuleReservations && (isAdmin || isReservation)) ...[
                    const menu_client.ReservationsRow(),
                    const menu_client.CalendarRow(),
                  ],
                  if (isAdmin) ...[
                    const menu_client.UsersRow(),
                    const menu_client.LocationsRow(),
                    if (client.licenseBase > 0 || client.licensePricing > 0) const menu_client.PaymentsRow(),
                    const menu_client.SettingsRow(),
                  ],
                ],
                if (isSeller) ...[
                  const menu_seller.ClientsRow(),
                  const menu_seller.SalesRow(),
                ],
                if (isDevelopment) ...[
                  const MoleculeItemSpace(),
                  const MoleculeItemSeparator(),
                  const MoleculeItemSpace(),
                  MoleculeItemTitle(header: "Development".tr()),
                  const SystemRow(),
                  if (/*[UserType.root, UserType.partner].contains(user.userType) &&*/ F()
                      .translationConfig
                      .isValid) ...[
                    const menu_developer.TranslationsRow(),
                  ],
                ],

                const MoleculeItemSpace(),
                const MoleculeItemSeparator(),
                const MoleculeItemSpace(),
                MoleculeItemTitle(header: LangKeys.screenSettingsSectionSystem.tr()),
                const LanguageRow(),
                const ThemeRow(),
                const LogoutRow(),
                //
                const MoleculeItemSpace(),
                const MoleculeItemSeparator(),
                const MoleculeItemSpace(),
                MoleculeTableRow(
                  label: LangKeys.labelAppVersion.tr(),
                  value: F().version,
                ),
                const SizedBox(height: 16),
                MoleculeTableRow(
                  label: LangKeys.labelAppBuild.tr(),
                  value: F().buildNumber,
                ),
                const SizedBox(height: 16),
                MoleculeTableRow(
                  label: LangKeys.labelAppTranslation.tr(),
                  value: LangKeys.translationVersion.tr(),
                ),
                //
                if (F().isInternal) ...debugMenuList(context, ref),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// eof
