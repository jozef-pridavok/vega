import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:core_flutter/core_screens.dart";
import "package:core_flutter/extensions/theme.dart";
import "package:core_flutter/states/provider.dart";
import "package:flutter/material.dart" hide Theme;

import "../../states/providers.dart";
import "../../strings.dart";

class ThemeScreen extends Screen {
  const ThemeScreen({super.key});

  @override
  createState() => _ThemeState();
}

class _ThemeState extends ScreenState {
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
    final isMobile = ref.watch(layoutLogic).isMobile;
    final themes = <Theme>[];
    themes.addAll(Theme.values);
    return Align(
      alignment: Alignment.topLeft,
      child: Padding(
        padding: const EdgeInsets.all(moleculeScreenPadding),
        child: ConstrainedBox(
          constraints: BoxConstraints(maxWidth: !isMobile ? ScreenFactor.tablet : double.infinity),
          child: ListView(
            physics: vegaScrollPhysic,
            children: themes.map((theme) => _buildRow(context, theme)).toList(),
          ),
        ),
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
      actionIcon: selectedTheme == theme ? AtomIcons.check : null,
      onAction: () async {
        setState(() => selectedTheme = theme);
        ref.read(themeLogic.notifier).changeTheme(theme.material);
        context.pop();
        await ref.read(userUpdateLogic.notifier).update(theme: theme);
      },
    );
  }
}

// eof
