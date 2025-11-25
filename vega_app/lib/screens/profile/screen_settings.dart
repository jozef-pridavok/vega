import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:vega_app/strings.dart";

import "../screen_app.dart";
import "row_country.dart";
import "row_language.dart";
import "row_location.dart";
import "row_theme.dart";

class SettingsScreen extends AppScreen {
  const SettingsScreen({super.key});

  @override
  createState() => _SettingsState();
}

class _SettingsState extends AppScreenState {
  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(title: LangKeys.screenSettings.tr());

  @override
  Widget buildBody(BuildContext context) {
    return SingleChildScrollView(
      physics: vegaScrollPhysic,
      child: Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding),
        child: Column(
          children: [
            MoleculeItemTitle(header: LangKeys.screenSettingsSectionNotifications.tr()),
            const MoleculeItemSpace(),
            MoleculeItemToggle(
              icon: "mail",
              title: LangKeys.settingsNotificationsDescription.tr(),
              on: true,
              onChanged: (value) {},
            ),
            const MoleculeItemSpace(),
            //
            const MoleculeItemSeparator(),
            const MoleculeItemSpace(),
            MoleculeItemTitle(header: LangKeys.screenSettingsSectionSystem.tr()),
            const LanguageRow(),
            const CountryRow(),
            const LocationRow(),
            const ThemeRow(),
          ],
        ),
      ),
    );
  }
}

// eof
