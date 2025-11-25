import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/extensions/theme.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Theme;
import "package:vega_app/states/providers.dart";
import "package:vega_app/strings.dart";

import "../screen_app.dart";

class ThemeScreen extends AppScreen {
  const ThemeScreen({super.key});

  @override
  createState() => _ThemeState();
}

class _ThemeState extends AppScreenState {
  late Theme selectedTheme;

  @override
  void initState() {
    super.initState();
    final user = ref.read(deviceRepository).get(DeviceKey.user) as User;
    selectedTheme = user.theme;
  }

  @override
  PreferredSizeWidget? buildAppBar(BuildContext context) => VegaAppBar(title: LangKeys.screenThemeTitle.tr());

  @override
  Widget buildBody(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(moleculeScreenPadding),
      child: ListView(
        physics: vegaScrollPhysic,
        children: Theme.values.map((theme) => _buildRow(context, theme)).toList(),
      ),
    );
  }

  Widget _buildRow(BuildContext context, Theme theme) {
    return MoleculeItemBasic(
      title: theme.localizedName,
      label: theme.localizedDescription,
      avatarColor: theme.getBackgroundColor(ref.scheme),
      icon: theme.icon,
      iconColor: theme.getForegroundColor(ref.scheme),
      actionIcon: selectedTheme == theme ? "check" : null,
      onAction: () {
        setState(() => selectedTheme = theme);
        ref.read(themeLogic.notifier).changeTheme(theme.material);
        ref.read(userUpdateLogic.notifier).update(theme: theme);
      },
    );
  }
}

// eof
