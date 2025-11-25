import "package:core_flutter/core_app.dart";
import "package:core_flutter/core_dart.dart";
import "package:core_flutter/core_flutter.dart";
import "package:flutter/material.dart";
import "package:flutter_riverpod/flutter_riverpod.dart";
import "package:vega_app/states/providers.dart";
import "package:vega_app/strings.dart";

import "../screen_tab.dart";
import "button_logout.dart";
import "row_about.dart";
import "row_debug.dart";
import "row_folder.dart";
import "row_profile.dart";
import "row_settings.dart";

class ProfileScreen extends TabScreen {
  const ProfileScreen({Key? key}) : super(2, "screen_profile_title", key: key);

  @override
  createState() => _ProfileScreenState();
}

class _ProfileScreenState extends TabScreenState<ProfileScreen> {
  @override
  Widget? buildPrimaryAppBar(BuildContext context) {
    return Consumer(
      builder: (BuildContext context, WidgetRef ref, Widget? child) {
        ref.watch(loginLogic);
        ref.watch(registerLogic);
        ref.watch(logoutLogic);
        ref.watch(userLogic);
        final device = ref.read(deviceRepository);
        final user = device.get(DeviceKey.user) as User;
        final isAnonymous = user.isAnonymous;
        return VegaPrimaryAppBar(
          LangKeys.screenProfileTitle.tr(),
          actions: isAnonymous ? const [] : const [LogoutButton()],
        );
      },
    );
  }

  @override
  Widget buildBody(BuildContext context) => const Padding(
        padding: EdgeInsets.symmetric(horizontal: moleculeScreenPadding),
        child: _Body(),
      );
}

class _Body extends ConsumerWidget {
  const _Body();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    var defaultList = [
      const MoleculeItemSpace(),
      const ProfileRow(),
      const MoleculeItemSpace(),
      const MoleculeItemSeparator(),
      const MoleculeItemSpace(),
      MoleculeItemTitle(header: LangKeys.sectionApplication.tr()),
      const MoleculeItemSpace(),
      if (F().isDemo) const FoldersRow(),
      const FoldersRow(),
      const SettingsRow(),
      const AboutRow(),
    ];
    List<Widget> debugList = [];
    if (F().isInternal) {
      debugList = debugMenuList(context, ref);
      ref.watch(incrementProvider);
    }
    return PullToRefresh(
      onRefresh: () => ref.read(userLogic.notifier).refresh(),
      child: ListView(
        //physics: vegaScrollPhysic,
        children: defaultList + debugList,
      ),
    );
  }
}

// eof
